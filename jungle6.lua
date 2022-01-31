local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local jungle6 = {
    identifier = "jungle6",
    title = "Jungle 6",
    theme = THEME.JUNGLE,
    width = 8,
    height = 3,
    file_name = "jung-6.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mantrap)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.STUNNABLE)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.FACING_LEFT)
        mantrap.flags = set_flag(mantrap.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        mantrap.color = Color:red()

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MANTRAP)

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local mattock = spawn_entity(ENT_TYPE.ITEM_MATTOCK, x, y, layer, 0, 0)
        mattock = get_entity(mattock)
        return true
    end, "mattock")

    local key_blocks = {}
    define_tile_code("key_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_BUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:yellow()
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

end

define_tile_code("slow_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    local falling_platform = get_entity(uid)
    falling_platform.color = Color:green()
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then ent.velocityy = -.02 end
    end)
    return true
end, "slow_falling_platform")

define_tile_code("fast_right_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    local falling_platform = get_entity(uid)
    falling_platform.color = Color:yellow()
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then
            ent.velocityy = 0.015 --keeps platform from falling
            -- ent.velocityx = 0.026
            ent.velocityx = 0.1
        end
    end)
    return true
end, "fast_right_falling_platform")

define_tile_code("fast_left_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    local falling_platform = get_entity(uid)
    falling_platform.color = Color:purple()
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then
            ent.velocityy = 0.015 --keeps platform from falling
            -- ent.velocityx = 0.026
            ent.velocityx = -0.1
        end
    end)
    return true
end, "fast_left_falling_platform")

jungle6.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle6
