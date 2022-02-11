local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local temple6 = {
    identifier = "temple6",
    title = "Temple 6: Ghosts",
    theme = THEME.TEMPLE,
    width = 4,
    height = 4,
    file_name = "temp-6.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

temple6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent, flags)
        ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
        ent:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, ENT_TYPE.MONS_SKELETON, ENT_TYPE.MONS_BAT, ENT_TYPE.MONS_SCARAB)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.type.max_speed = 0.3
        ent.color:set_rgba(104, 37, 71, 150) --deep red, semi-opaque
        ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)

        set_on_kill(ent.uid, function(self)
            local x, y, l = get_position(self.uid)
            local uid = spawn_entity(ENT_TYPE.ITEM_BOMB, x, y-1, l, 0, 0)
        end)

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MUMMY)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.health = 10
        ent.type.max_speed = 0.2
        ent.color:set_rgba(104, 37, 71, 150) --deep red, semi-opaque
        ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.SORCERESS)

    -- from Dregu: double fly speed. Anything faster and you should turn it in to a hitscan weapon
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
        set_timeout(function() -- they don't have velocity when spawned, wait a frame
            local x = ent.velocityx
            local y = ent.velocityy
            local vel = 0.6 -- base velocity
            local sx = x>0 and vel or x<0 and -vel or 0 -- get sign x
            local sy = y>0 and vel or y<0 and -vel or 0 -- get sign y
            ent.velocityx = sx 
            -- ent.velocityy = sy/100 -- remove y velocity to stop spread
        end, 1)
        end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLY, ENT_TYPE.FLYHEAD)

    local key_blocks = {}
    define_tile_code("key_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:purple()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        key_blocks[#key_blocks + 1] = get_entity(floor_uid)
        return true
    end, "key_block")

    local block_keys = {}
    define_tile_code("block_key")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
        local key = get_entity(uid)
        key.color = Color:purple()
        block_keys[#block_keys + 1] = get_entity(uid)
        set_pre_collision2(key.uid, function(self, collision_entity)
            for _, block in ipairs(key_blocks) do
                if collision_entity.uid == block.uid then
                    -- kill_entity(door_uid)
                    kill_entity(block.uid)
                    kill_entity(key.uid)
                    sound.play_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
                end
            end
        end)
        return true
    end, "block_key")

    --Death Blocks - from JawnGC
	define_tile_code("death_block")
	local death_blocks = {}
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn(ENT_TYPE.FLOORSTYLED_TEMPLE, x, y, layer, 0, 0)
		death_blocks[#death_blocks + 1] = get_entity(block_id)
		death_blocks[#death_blocks].color:set_rgba(100, 0, 0, 255) --Dark Red
		death_blocks[#death_blocks].more_flags = set_flag(death_blocks[#death_blocks].more_flags, 17) --Unpushable
		death_blocks[#death_blocks].flags = set_flag(death_blocks[#death_blocks].flags, 10) --No Gravity
		return true
	end, "death_block")

    local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()

		for i = 1,#death_blocks do
			death_blocks[i].color:set_rgba(100 + math.ceil(50 * math.sin(0.05 * frames)), 0, 0, 255) --Pulse effect
			if #players ~= 0 and players[1].standing_on_uid == death_blocks[i].uid then
				kill_entity(players[1].uid, false)
			end
		end

        frames = frames + 1
    end, ON.FRAME)

	toast(temple6.title)
end

temple6.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple6

