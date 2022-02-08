local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local tidepool6 = {
    identifier = "tidepool6",
    title = "Tidepool 6: Thorny Tiny Box",
    theme = THEME.TIDE_POOL,
    width = 4,
    height = 4,
    file_name = "tide-6.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)


    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (boss_bones)
        boss_bones.color = Color:red()
        boss_bones.health = 25
        boss_bones.flags = clr_flag(boss_bones.flags, ENT_FLAG.STUNNABLE)
        boss_bones:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)

        
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FEMALE_JIANGSHI)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (minion_bones)
        minion_bones.color = Color:blue()
        minion_bones.health = 6
        minion_bones.flags = clr_flag(minion_bones.flags, ENT_FLAG.STUNNABLE)
        minion_bones:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_JIANGSHI)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (thorn)
        thorn.color = Color:red()
        set_pre_collision2(thorn.uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid and players[1].invincibility_frames_timer <= 0 then
                -- todo: get directional damage working
                if players[1].FACING_LEFT then
                    players[1]:damage(thorn.uid, 1, 30, 0, .1, 600)
                else
                    players[1]:damage(thorn.uid, 1, 30, 0, .1, 600)
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

	toast(tidepool6.title)
end

tidepool6.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool6

