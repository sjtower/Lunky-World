local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local timed_doors = require("Modules.GetimOliver.timed_door")

local neobabylon2 = {
    identifier = "neobabylon 2",
    title = "Neo Babylon1 2: Emergency Access Doors",
    theme = THEME.NEO_BABYLON,
    width = 8,
    height = 2,
    file_name = "neob-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

neobabylon2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    timed_doors.activate(level_state, 180)

    modify_sparktraps(0.1, 1.1)

    checkpoints.activate()

	toast(neobabylon2.title)
end

neobabylon2.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    timed_doors.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon2

