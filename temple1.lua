local death_blocks = require("Modules.JawnGC.death_blocks")
local checkpoints = require("Checkpoints/checkpoints")

local temple1 = {
    identifier = "temple1",
    title = "Temple 1: Super Crush",
    theme = THEME.TEMPLE,
    width = 4,
    height = 4,
    file_name = "temp-1.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

temple1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()
    death_blocks.activate(level_state)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.MONS_SKELETON)

	toast(temple1.title)
end

temple1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple1

