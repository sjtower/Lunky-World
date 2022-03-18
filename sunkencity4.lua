local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local inverse_timed_doors = require("Modules.GetimOliver.inverse_timed_door")
local timed_doors = require("Modules.GetimOliver.timed_door")

local sunkencity4 = {
    identifier = "sunkencity 4",
    title = "Sunken City 4: Switch Hitter",
    theme = THEME.SUNKEN_CITY,
    width = 8,
    height = 3,
    file_name = "sunk-4.lvl",
    world = 7,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

sunkencity4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("firefrog")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.MONS_FIREFROG, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "firefrog")

    define_tile_code("sunken_arrow_trap")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.FLOOR_POISONED_ARROW_TRAP, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sunken_arrow_trap")

    define_tile_code("jetpack")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_JETPACK, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "jetpack")

    define_tile_code("vlads_cape")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_VLADS_CAPE, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "vlads_cape")

    death_blocks.activate(level_state)
    inverse_timed_doors.activate(level_state, 50)
    timed_doors.activate(level_state, 100)

    checkpoints.activate()

	if not checkpoints.get_saved_checkpoint() then
        toast(sunkencity4.title)
    end
end

sunkencity4.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    inverse_timed_doors.deactivate()
    timed_doors.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity4

