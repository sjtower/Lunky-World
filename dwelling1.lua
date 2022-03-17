local nocrap = require("Modules.Dregu.no_crap")
local moving_totems = require("Modules.JayTheBusinessGoose.moving_totems")
local checkpoints = require("Checkpoints/checkpoints")

define_tile_code("moving_totem")
define_tile_code("totem_switch")

local dwelling1 = {
    identifier = "dwelling1",
    title = "Dwelling 1: Bounce Zone",
    theme = THEME.DWELLING,
    width = 6,
    height = 5,
    file_name = "dwell-1.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

dwelling1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (snake)

        snake.health = 100
        snake.color = Color:red()
        snake.type.max_speed = 0.05
        snake.flags = set_flag(snake.flags, ENT_FLAG.TAKE_NO_DAMAGE)

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SNAKE)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (bat)

        bat.health = 10
        bat.type.max_speed = 0.07
        bat.color = Color:red()
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_BAT)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mole)
        --Set moles - no stun, walk on thorns
        mole.health = 100
        mole.color = Color:red()
        mole.flags = clr_flag(mole.flags, ENT_FLAG.STUNNABLE)

        mole:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MOLE)

    moving_totems.activate(level_state)
    checkpoints.activate()

    if not checkpoints.get_saved_checkpoint() then
        toast(dwelling1.title)
    end

end

dwelling1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    moving_totems.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling1
