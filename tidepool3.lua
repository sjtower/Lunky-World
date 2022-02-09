local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local tidepool3 = {
    identifier = "tidepool3",
    title = "Tidepool 3: Fish",
    theme = THEME.TIDE_POOL,
    width = 4,
    height = 4,
    file_name = "tide-3.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.MONS_SKELETON)

    define_tile_code("spike_shoes")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local shoes = spawn_entity(ENT_TYPE.ITEM_PICKUP_SPIKESHOES, x, y, layer, 0, 0)
        shoes = get_entity(shoes)
        return true
    end, "spike_shoes")

    -- todo: fish with different speeds
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (fish)
        fish.color = Color:red()
        fish.type.max_speed = 0.01
        fish.flags = clr_flag(fish.flags, ENT_FLAG.STUNNABLE)
        fish.flags = set_flag(fish.flags, ENT_FLAG.TAKE_NO_DAMAGE)
		-- fish.flags = clr_flag(fish.flags, 13)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FISH)

    define_tile_code("fast_fish")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local fish = spawn_entity(ENT_TYPE.MONS_FISH, x, y, layer, 0, 0)
        fish = get_entity(fish)
        fish.color = Color:yellow()
        fish.type.max_speed = 0.05
        fish.flags = clr_flag(fish.flags, ENT_FLAG.STUNNABLE)
        fish.flags = set_flag(fish.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        return true
    end, "fast_fish")

    define_tile_code("fastest_fish")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local fish = spawn_entity(ENT_TYPE.MONS_FISH, x, y, layer, 0, 0)
        fish = get_entity(fish)
        fish.color = Color:green()
        fish.type.max_speed = 0.1
        fish.flags = clr_flag(fish.flags, ENT_FLAG.STUNNABLE)
        fish.flags = set_flag(fish.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        return true
    end, "fastest_fish")

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

	toast(tidepool3.title)
end

tidepool3.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool3
