local checkpoints = require("Checkpoints/checkpoints")

local tidepool1 = {
    identifier = "tidepool1",
    title = "Tidepool 1: Octolus Rift",
    theme = THEME.TIDE_POOL,
    width = 4,
    height = 4,
    file_name = "tide-1.lvl",
    world = 4,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    define_tile_code("spike_shoes")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local shoes = spawn_entity(ENT_TYPE.ITEM_PICKUP_SPIKESHOES, x, y, layer, 0, 0)
        shoes = get_entity(shoes)
        return true
    end, "spike_shoes")

    if not checkpoints.get_saved_checkpoint() then
        toast(tidepool1.title)
    end
end

tidepool1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool1
