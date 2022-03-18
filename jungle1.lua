local checkpoints = require("Checkpoints/checkpoints")
local signs = require("Modules.JayTheBusinessGoose.signs")

local jungle1 = {
    identifier = "jungle1",
    title = "Jungle 1: Deadly Canopy",
    theme = THEME.JUNGLE,
    width = 4,
    height = 4,
    file_name = "jung-1.lvl",
    world = 2
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()
    signs.activate(level_state, {"Pro Tip: whip-jump - while hanging, press jump and whip at the exact same time without any movement left or right", "Pro Tip: Going through doors gives you temporary invincibility"})

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mantrap)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.STUNNABLE)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.FACING_LEFT)
        mantrap.flags = set_flag(mantrap.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        mantrap.color = Color:red()

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MANTRAP)

    if not checkpoints.get_saved_checkpoint() then
        toast(jungle1.title)
    end
end

jungle1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    signs.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle1
