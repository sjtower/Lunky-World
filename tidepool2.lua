local tidepool2 = {
    identifier = "tidepool2",
    title = "Tidepool 2: Thorny Duct",
    theme = THEME.TIDE_POOL,
    width = 8,
    height = 1,
    file_name = "tide-2.lvl",
    world = 4,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    toast(tidepool2.title)
end

tidepool2.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool2
