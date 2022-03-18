local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")

local sunkencity2 = {
    identifier = "sunkencity 2",
    title = "Sunken City 2: Thorny Jail",
    theme = THEME.SUNKEN_CITY,
    width = 4,
    height = 4,
    file_name = "sunk-2.lvl",
    world = 7,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

sunkencity2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("spike_shoes")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_PICKUP_SPIKESHOES, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "spike_shoes")

    define_tile_code("spring_shoes")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "spring_shoes")

    define_tile_code("vlads_cape")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_VLADS_CAPE, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "vlads_cape")

    define_tile_code("sunken_arrow_trap")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.FLOOR_POISONED_ARROW_TRAP, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sunken_arrow_trap")

    checkpoints.activate()

	if not checkpoints.get_saved_checkpoint() then
        toast(sunkencity2.title)
    end
end

sunkencity2.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity2

