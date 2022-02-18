local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")

local sunkencity6 = {
    identifier = "sunkencity 6",
    title = "Sunken City 6: LightoriArrow Glue Glue Bow",
    theme = THEME.SUNKEN_CITY,
    width = 3,
    height = 3,
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

sunkencity6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("firefrog")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.MONS_FIREFROG, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "firefrog")

    define_tile_code("giantfly")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.MONS_GIANTFLY, x, y, layer, 0, 0)
        ent = get_entity(ent)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.color:set_rgba(104, 37, 71, 255) --deep red
        ent.type.max_speed = 0.10
        return true
    end, "giantfly")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.color:set_rgba(104, 37, 71, 255) --deep red
        ent.health = 60

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_GIANTFROG)

    define_tile_code("sunken_arrow_trap")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.FLOOR_POISONED_ARROW_TRAP, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sunken_arrow_trap")

    define_tile_code("pitchers_mitt")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "pitchers_mitt")

    replace_drop(DROP.POISONEDARROWTRAP_WOODENARROW, ENT_TYPE.ITEM_METAL_ARROW)

    death_blocks.set_ent_type(ENT_TYPE.FLOOR_BORDERTILE)
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

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity6

