local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local volcana2 = {
    identifier = "volcana2",
    title = "Volcana 2",
    theme = THEME.VOLCANA,
    width = 2,
    height = 8,
    file_name = "volc-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

volcana2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

end

volcana2.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana2
