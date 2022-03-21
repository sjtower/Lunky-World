local checkpoints = require("Checkpoints/checkpoints")
local key_blocks = require("Modules.GetimOliver.key_blocks")

local jungle5 = {
    identifier = "jungle5",
    title = "Jungle 5: The Fast & The Thorny",
    theme = THEME.JUNGLE,
    width = 8,
    height = 3,
    file_name = "jung-5.lvl",
    world = 2,
    level = 5,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle5.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    key_blocks.activate(level_state)
    checkpoints.activate()

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

    if not checkpoints.get_saved_checkpoint() then
        toast(jungle5.title)
    end
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

jungle5.unload_level = function()
    if not level_state.loaded then return end

    key_blocks.deactivate()
    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle5
