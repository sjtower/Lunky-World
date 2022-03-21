local checkpoints = require("Checkpoints/checkpoints")
local signs = require("Modules.JayTheBusinessGoose.signs")
local key_blocks = require("Modules.GetimOliver.key_blocks")

local jungle1 = {
    identifier = "jungle1",
    title = "Jungle 1: Deadly Canopy",
    theme = THEME.JUNGLE,
    width = 4,
    height = 4,
    file_name = "jung-1.lvl",
    world = 2,
    level = 1,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()
    key_blocks.activate(level_state)
    signs.activate(level_state, 
    {
        "Pro Tip: Whip-Jump - while hanging, press jump and whip at the exact same time without any movement left or right",
        "Pro Tip: Going through doors gives you temporary invincibility"
    })

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mantrap)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.STUNNABLE)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.FACING_LEFT)
        mantrap.flags = set_flag(mantrap.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        mantrap.color:set_rgba(209, 15, 18, 255) --deep red

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MANTRAP)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    if not checkpoints.get_saved_checkpoint() then
        toast(jungle1.title)
    end
end

jungle1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    signs.deactivate()
    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle1
