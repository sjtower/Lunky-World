local checkpoints = require("Checkpoints/checkpoints")

local volcana5 = {
    identifier = "volcana5",
    title = "Volcana 5: Trash Compactor",
    theme = THEME.VOLCANA,
    width = 4,
    height = 6,
    file_name = "volc-5.lvl",
    world = 3,
    level = 5,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

volcana5.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    if not checkpoints.get_saved_checkpoint() then
        toast(volcana5.title)
    end
end

volcana5.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana5
