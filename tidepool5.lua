local key_blocks = require("Modules.GetimOliver.key_blocks")

local tidepool5 = {
    identifier = "tidepool5",
    title = "Tidepool 5: Thaxe-el-ottl Nuts!",
    theme = THEME.TIDE_POOL,
    width = 4,
    height = 4,
    file_name = "tide-5.lvl",
    world = 4,
    level = 5,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool5.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    key_blocks.activate(level_state)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.MONS_SKELETON)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        --Tame Axolotl
        --TODO: this is not working
        entity:tame(true)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MOUNT_AXOLOTL)

    --Oscillating Blocks
	local osc_blocks = {}
	local y_pos
	define_tile_code("osc_block")
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		osc_blocks[#osc_blocks + 1] = get_entity(spawn(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0))
		y_pos = y
	end, "osc_block")
	
	--Set Velocities of Oscillating Blocks
	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		if frames == 0 then	
			for i = 1,#osc_blocks do
				osc_blocks[i].color:set_rgba(200, 150, 90, 255) --Light Brown
				osc_blocks[i].flags = set_flag(osc_blocks[i].flags, 10) -- No Gravity
				osc_blocks[i].flags = clr_flag(osc_blocks[i].flags, 13) -- No Collision with walls
			end
		end
		osc_blocks[1].velocityx = 0.12 * -math.cos(0.04 * frames)
		
		--These blocks drift downward for some reason, reset y position every frame. (Cringe)
		osc_blocks[1].y = y_pos
		
		frames = frames + 1
    end, ON.FRAME)

	toast(tidepool5.title)
end

tidepool5.unload_level = function()
    if not level_state.loaded then return end

    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool5

