local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local death_elevators = require("Modules.GetimOliver.death_elevators")
local signs = require("Modules.JayTheBusinessGoose.signs")

local neobabylon3 = {
    identifier = "neobabylon 3",
    title = "Neo Babylon 3: Lava Lamp",
    theme = THEME.NEO_BABYLON,
    width = 6,
    height = 5,
    file_name = "neob-3.lvl",
    world = 6,
    level = 3,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

neobabylon3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()
    death_blocks.activate(level_state)
    death_elevators.activate(level_state)
    signs.activate(level_state, {"Pro Tip: You can hang from the elevator even with lots of lava on top"})

    if not checkpoints.get_saved_checkpoint() then
        toast(neobabylon3.title)
    end
end

neobabylon3.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    death_elevators.deactivate()
    death_blocks.deactivate()
    signs.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon3

