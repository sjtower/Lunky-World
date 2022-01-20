local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local jungle3 = {
    identifier = "jungle3",
    title = "Jungle 3",
    theme = THEME.JUNGLE,
    width = 5,
    height = 5,
    file_name = "jung-3.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mantrap)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.STUNNABLE)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.FACING_LEFT)
        mantrap.flags = set_flag(mantrap.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        mantrap.color = Color:red()

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MANTRAP)
    
    -- local falling_platforms = {}
    -- level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
    --     local falling_platform = spawn_entity(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    --     falling_platform = get_entity(falling_platform)
    --     falling_platforms[#falling_platforms + 1] = falling_platform
    --     falling_platform.type.max_speed = 0.025
    --     falling_platform.type.sprint_factor = 1
    --     falling_platform.color = Color:green()
    --     return true
    -- end, "slow_falling_platform")

    -- level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
    --     for _, falling_platform in ipairs(falling_platforms) do
    --             local x, y, l = get_position(falling_platform)
    --             local vx, vy = falling_platform.velocityx, falling_platform.velocityy
    --             move_entity(falling_platform, x-vx/2, y-vy/2, vx, vy)
    --     end
    -- end, ON.FRAME)

end

-- set_callback(function()
--     local f = get_entities_by_type({ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM})
--     for i, id in ipairs(f) do
--         local e = get_entity(id):as_movable()
--         local x, y, l = get_position(id)
--         local vx, vy = e.velocityx, e.velocityy
--         move_entity(id, x-vx/2, y-vy/2, vx, vy)
--     end
-- end, ON.FRAME)

define_tile_code("slow_falling_platform")
set_pre_tile_code_callback(function(x, y, layer)
    local uid = spawn_critical(ENT_TYPE.ACTIVEFLOOR_FALLING_PLATFORM, x, y, layer, 0, 0)
    set_post_statemachine(uid, function(ent)
        if ent.velocityy < 0.001 then ent.velocityy = 0.001 end
    end)
    return true
end, "slow_falling_platform")

jungle3.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle3
