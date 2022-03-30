local nocrap = require("Modules.Dregu.no_crap")
local moving_totems = require("Modules.JayTheBusinessGoose.moving_totems")
local checkpoints = require("Checkpoints/checkpoints")
local signs = require("Modules.JayTheBusinessGoose.signs")

define_tile_code("moving_totem")
define_tile_code("totem_switch")

local dwelling1 = {
    identifier = "dwelling1",
    title = "Dwelling 1: Bounce Zoo",
    theme = THEME.DWELLING,
    width = 6,
    height = 5,
    file_name = "dwell-1.lvl",
    world = 1,
    level = 1,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local snakes = {}
local bats = {}
local moles = {}

dwelling1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("red_snake")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.MONS_SNAKE, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent.health = 100
        ent.color = Color:red()
        ent.type.max_speed = 0.05
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        snakes[#snakes + 1] = ent
        return true
    end, "red_snake")

    define_tile_code("red_mole")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.MONS_MOLE, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent.health = 100
        ent.color = Color:red()
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
        moles[#moles + 1] = ent
        return true
    end, "red_mole")

    define_tile_code("red_bat")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.MONS_BAT, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent.health = 10
        ent.type.max_speed = 0.07
        ent.color = Color:red()
        bats[#bats + 1] = ent
        return true
    end, "red_bat")

    moving_totems.activate(level_state)
    signs.activate(level_state, {"Pro Tip: Hit the snake at the bottom of its bounce and hold right"})
    checkpoints.activate()

    if not checkpoints.get_saved_checkpoint() then
        toast(dwelling1.title)
    end

end

dwelling1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    moving_totems.deactivate()
    signs.deactivate()

    snakes = {}
    moles = {}
    bats = {}

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling1
