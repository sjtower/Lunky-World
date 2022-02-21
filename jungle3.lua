local checkpoints = require("Checkpoints/checkpoints")
local jungle3 = {
    identifier = "jungle3",
    title = "Jungle 3: Slow Burn",
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

    checkpoints.activate()

    if checkpoints.saved_checkpoint then
        define_tile_code("checkpoint_key")
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            local ent = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
            ent = get_entity(ent)
            return true
        end, "checkpoint_key")
    end

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mantrap)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.STUNNABLE)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.FACING_LEFT)
        mantrap.flags = set_flag(mantrap.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        mantrap.color = Color:red()
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MANTRAP)

    toast(jungle3.title)
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

jungle3.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle3
