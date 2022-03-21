local checkpoints = require("Checkpoints/checkpoints")
local volcana4 = {
    identifier = "volcana4",
    title = "Volcana 4: Dangerous Machinery",
    theme = THEME.VOLCANA,
    width = 4,
    height = 4,
    file_name = "volc-4.lvl",
    world = 3,
    level = 4,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

volcana4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    define_tile_code("left_facing_robot")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.MONS_ROBOT, x, y, layer, 0, 0)
        local robot = get_entity(uid)
        robot.color = Color:purple()
        robot.flags = set_flag(robot.flags, ENT_FLAG.FACING_LEFT)
        return true
    end, "left_facing_robot")

    define_tile_code("right_facing_robot")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.MONS_ROBOT, x, y, layer, 0, 0)
        local robot = get_entity(uid)
        robot.color = Color:yellow()
        robot.flags = clr_flag(robot.flags, ENT_FLAG.FACING_LEFT)
        return true
    end, "right_facing_robot")

    if not checkpoints.get_saved_checkpoint() then
        toast(volcana4.title)
    end
end

volcana4.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana4
