local checkpoints = require("Checkpoints/checkpoints")
local key_blocks = require("Modules.GetimOliver.key_blocks")

local volcana3 = {
    identifier = "volcana3",
    title = "Volcana 3: Fire Walker",
    theme = THEME.VOLCANA,
    width = 4,
    height = 4,
    file_name = "volc-3.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

volcana3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()
    key_blocks.activate(level_state)

    toast(volcana3.title)
end

volcana3.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana3
