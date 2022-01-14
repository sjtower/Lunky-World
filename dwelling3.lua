local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

define_tile_code("sleeping_bat")

local dwelling3 = {
    identifier = "dwelling3",
    title = "Dwelling 3",
    theme = THEME.DWELLING,
    width = 8,
    height = 4,
    file_name = "dwell-3.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

dwelling3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (snake)

        snake.health = 100
        snake.color = Color:red()
        snake.type.max_speed = 0.05
        snake.flags = set_flag(snake.flags, ENT_FLAG.TAKE_NO_DAMAGE)

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SNAKE)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (horned_lizard)
        horned_lizard.flags = clr_flag(horned_lizard.flags, ENT_FLAG.STUNNABLE)
        horned_lizard.flags = clr_flag(horned_lizard.flags, ENT_FLAG.FACING_LEFT)
        horned_lizard.flags = set_flag(horned_lizard.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        -- horned_lizard.flags = set_flag(horned_lizard.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        horned_lizard.color = Color:red()
        horned_lizard.type.max_speed = 0.00

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_HORNEDLIZARD)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (spring_trap)
        
        spring_trap.color = Color:red()
        
        set_pre_collision2(spring_trap.uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid then
                -- players[1].health = 0
                players[1]:damage(spring_trap.uid, 2, 0, 0, 0, 0)
            end
        end)

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_SPRING_TRAP)

    local sleeping_bat;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local bat_id = spawn_entity(ENT_TYPE.MONS_BAT, x, y, layer, 0, 0)
        sleeping_bat = get_entity(bat_id)
        return true
    end, "sleeping_bat")

end

dwelling3.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling3
