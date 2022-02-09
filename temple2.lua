local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local temple2 = {
    identifier = "temple2",
    title = "Temple 2: Biathalon",
    theme = THEME.TEMPLE,
    width = 4,
    height = 4,
    file_name = "temp-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

temple2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    -- from Dregu: double bullet speed. Anything faster and you should turn it in to a hitscan weapon
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        set_timeout(function() -- they don't have velocity when spawned, wait a frame
          local x = ent.velocityx
          local y = ent.velocityy
          local vel = 0.6 -- base velocity
          local sx = x>0 and vel or x<0 and -vel or 0 -- get sign x
          local sy = y>0 and vel or y<0 and -vel or 0 -- get sign y
          ent.velocityx = sx 
          ent.velocityy = sy/100 -- remove y velocity to stop spread
        end, 1)
      end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_BULLET)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        spawn_entity(ENT_TYPE.MONS_CATMUMMY, x, y, layer, 0, 0)
        return true
    end, "catmummy")

    define_tile_code("shotgun")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local shotgun = spawn_entity(ENT_TYPE.ITEM_SHOTGUN, x, y, layer, 0, 0)
        shotgun = get_entity(shotgun)
        return true
    end, "shotgun")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (boss_bones)
        boss_bones.color = Color:red()
        boss_bones.health = 25
        boss_bones.flags = clr_flag(boss_bones.flags, ENT_FLAG.STUNNABLE)
        boss_bones:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FEMALE_JIANGSHI)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (thorn)
        thorn.color = Color:red()
        set_pre_collision2(thorn.uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid and players[1].invincibility_frames_timer <= 0 then
                -- todo: get directional damage working
                if players[1].FACING_LEFT then
                    players[1]:damage(thorn.uid, 1, 30, 0, .1, 100)
                else
                    players[1]:damage(thorn.uid, 1, 30, 0, .1, 100)
                end
            end
        end)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

    local key_blocks = {}
    define_tile_code("key_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:yellow()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        key_blocks[#key_blocks + 1] = get_entity(floor_uid)
        return true
    end, "key_block")

    local block_keys = {}
    define_tile_code("block_key")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
        local key = get_entity(uid)
        key.color = Color:yellow()
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
			death_blocks[i].color:set_rgba(100 + math.ceil(40 * math.sin(0.05 * frames)), 0, 0, 255) --Pulse effect
			if #players ~= 0 and players[1].standing_on_uid == death_blocks[i].uid then
				kill_entity(players[1].uid, false)
			end
		end
        
        frames = frames + 1
    end, ON.FRAME)

	toast(temple2.title)
end

temple2.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple2

