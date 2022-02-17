local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local key_blocks = require("Modules.GetimOliver.key_blocks")
local inverse_timed_doors = require("Modules.GetimOliver.inverse_timed_door")
local timed_doors = require("Modules.GetimOliver.timed_door")

local sunkencity5 = {
    identifier = "sunkencity 5",
    title = "Sunken City 5: LightoriArrow Glue Glue Bow",
    theme = THEME.SUNKEN_CITY,
    width = 6,
    height = 4,
    file_name = "sunk-5.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local saved_checkpoint

local function save_checkpoint(checkpoint)
    saved_checkpoint = checkpoint
end

sunkencity5.load_level = function()
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
        return true
    end, "giantfly")

    define_tile_code("sunken_arrow_trap")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.FLOOR_POISONED_ARROW_TRAP, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sunken_arrow_trap")

    define_tile_code("paste")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_PASTE, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "paste")

    define_tile_code("bomb_bag")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_BOMBBAG, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "bomb_bag")

    replace_drop(DROP.POISONEDARROWTRAP_WOODENARROW, ENT_TYPE.ITEM_METAL_ARROW)

    death_blocks.set_ent_type(ENT_TYPE.FLOOR_BORDERTILE)
    death_blocks.activate(level_state)
    inverse_timed_doors.activate(level_state, 50)
    timed_doors.activate(level_state, 100)
    key_blocks.activate(level_state)

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

	toast(sunkencity5.title)
end

sunkencity5.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    inverse_timed_doors.deactivate()
    timed_doors.deactivate()
    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity5

