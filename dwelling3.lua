local checkpoints = require("Checkpoints/checkpoints")

define_tile_code("sleeping_bat")

local dwelling3 = {
    identifier = "dwelling3",
    title = "Dwelling 3: Lizard Ladder",
    theme = THEME.DWELLING,
    width = 8,
    height = 4,
    file_name = "dwell-3.lvl",
    world = 1,
    level = 3,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

dwelling3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.flags = set_flag(ent.flags, ENT_FLAG.CAN_BE_STOMPED)
        ent.color = Color:red()
        ent.type.max_speed = 0.00

        set_pre_collision2(ent.uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid and players[1].invincibility_frames_timer <= 0 then
                players[1]:damage(ent.uid, 0, 0, .1, .1, 1)
            end
        end)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_HORNEDLIZARD)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.color = Color:red()
        set_pre_collision2(ent.uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid and players[1].invincibility_frames_timer <= 0 then
                players[1]:damage(ent.uid, 1, 0, 0, 0, 600)
            end
        end)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_SPRING_TRAP)

    local sleeping_bat;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local bat_id = spawn_entity(ENT_TYPE.MONS_BAT, x, y, layer, 0, 0)
        sleeping_bat = get_entity(bat_id)
        return true
    end, "sleeping_bat")

    if not checkpoints.get_saved_checkpoint() then
        toast(dwelling3.title)
    end
end

dwelling3.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling3
