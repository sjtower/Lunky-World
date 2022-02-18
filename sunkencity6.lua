local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")

local sunkencity6 = {
    identifier = "sunkencity 6",
    title = "Sunken City 6: LightoriArrow Glue Glue Bow",
    theme = THEME.SUNKEN_CITY,
    width = 8,
    height = 8,
    file_name = "sunk-6.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local saved_checkpoint

local function save_checkpoint(checkpoint)
    saved_checkpoint = checkpoint
end

local quilliams = {}

sunkencity6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.color:set_rgba(104, 37, 71, 255) --deep red
        ent.health = 60
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_GIANTFROG)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_AMMIT)

    define_tile_code("sunken_arrow_trap")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.FLOOR_POISONED_ARROW_TRAP, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sunken_arrow_trap")

    define_tile_code("vlads_cape")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_VLADS_CAPE, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "vlads_cape")

    -- Creates an invincible Quilliam that always rolls
    define_tile_code("infinite_quillback")
    local quilliams = {}
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        clear_embeds.perform_block_without_embeds(function()        
            local ent = spawn_entity(ENT_TYPE.MONS_CAVEMAN_BOSS, x, y, layer, 0, 0)
            ent = get_entity(ent)
            ent.color:set_rgba(156, 150, 98, 250) --sandy brown
            quilliams[#quilliams + 1] = ent

            ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
            ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)

        end)
        return true
    end, "infinite_quillback")

    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, quilliam in ipairs(quilliams) do
            quilliam.move_state = 10
        end
    end, ON.FRAME)


    -- Creates a Quilliam that always rolls only if a checkpoint has been activated
    if saved_checkpoint then
        define_tile_code("infinite_checkpoint_quillback")
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            clear_embeds.perform_block_without_embeds(function()        
                local ent = spawn_entity(ENT_TYPE.MONS_CAVEMAN_BOSS, x, y, layer, 0, 0)
                ent = get_entity(ent)
                ent.color:set_rgba(156, 150, 98, 250) --sandy brown
                quilliams[#quilliams + 1] = ent

                ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
                ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)

            end)
            return true
        end, "infinite_checkpoint_quillback")
    end

    -- local cavemen = {}
    -- level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
    --     ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    --     ent = get_entity(ent)
    --     cavemen[#cavemen + 1] = ent
    -- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_CAVEMAN)

    -- level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
    --     for _, caveman in ipairs(cavemen) do
    --         caveman.move_state = 10
    --     end
    -- end, ON.FRAME)

    death_blocks.set_ent_type(ENT_TYPE.FLOORSTYLED_SUNKEN)
    death_blocks.activate(level_state)

    checkpoints.activate()
    checkpoints.checkpoint_activate_callback(function(x, y, layer, time)
        save_checkpoint({
            position = {
                x = x,
                y = y,
                layer = layer,
            },
            time = time,
        })
    end)

    if saved_checkpoint then
        checkpoints.activate_checkpoint_at(
            saved_checkpoint.position.x,
            saved_checkpoint.position.y,
            saved_checkpoint.position.layer,
            saved_checkpoint.time
        )
    end

	toast(sunkencity6.title)
end

sunkencity6.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    quilliams = {}

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity6

