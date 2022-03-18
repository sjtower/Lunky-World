local checkpoints = require("Checkpoints/checkpoints")

local volcana1 = {
    identifier = "volcana1",
    title = "Volcana 1: Blast Furnace",
    theme = THEME.VOLCANA,
    width = 4,
    height = 4,
    file_name = "volc-1.lvl",
    world = 3,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

volcana1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    if not checkpoints.get_saved_checkpoint() then
        toast(volcana1.title)
    end
end

volcana1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana1
