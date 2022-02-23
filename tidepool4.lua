local checkpoints = require("Checkpoints/checkpoints")

local tidepool4 = {
    identifier = "tidepool4",
    title = "Tidepool 4: Free Willy",
    theme = THEME.TIDE_POOL,
    width = 8,
    height = 2,
    file_name = "tide-4.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.MONS_SKELETON)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (fish)
        fish.color = Color:red()
        fish.type.max_speed = 0.01
        fish.flags = clr_flag(fish.flags, ENT_FLAG.STUNNABLE)
        fish.flags = set_flag(fish.flags, ENT_FLAG.TAKE_NO_DAMAGE)
		-- fish.flags = clr_flag(fish.flags, 13)
        
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FISH)

	toast(tidepool4.title)
end

tidepool4.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool4

