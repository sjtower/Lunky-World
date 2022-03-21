local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local death_elevators = require("Modules.GetimOliver.death_elevators")

local neobabylon4 = {
    identifier = "neobabylon 4",
    title = "Neo Babylon 4: Hold Right",
    theme = THEME.NEO_BABYLON,
    width = 6,
    height = 6,
    file_name = "neob-4.lvl",
    world = 6,
    level = 4,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

neobabylon4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()
    death_blocks.activate(level_state)
    death_elevators.activate(level_state)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.type.max_speed = 0.02
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_UFO)

    if not checkpoints.get_saved_checkpoint() then
        toast(neobabylon4.title)
    end
end

neobabylon4.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon4

