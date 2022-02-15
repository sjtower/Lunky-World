local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local death_elevators = require("Modules.GetimOliver.death_elevators")

local neobabylon6 = {
    identifier = "neobabylon 6",
    title = "Neo Babylon 6: Lamassu",
    theme = THEME.NEO_BABYLON,
    width = 3,
    height = 3,
    file_name = "neob-6.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local saved_checkpoint

local function save_checkpoint(checkpoint)
    saved_checkpoint = checkpoint
end

neobabylon6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_PARACHUTE, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "parachute")

    checkpoints.activate()
    death_blocks.activate(level_state)
    death_elevators.activate(level_state)

    checkpoints.checkpoint_activate_callback(function(x, y, layer, time)
        save_checkpoint({
            position = {
                x = x,
                y = y,
                layer = layer,
            },
            time = time,
        })
    end)

    if saved_checkpoint then
        checkpoints.activate_checkpoint_at(
            saved_checkpoint.position.x,
            saved_checkpoint.position.y,
            saved_checkpoint.position.layer,
            saved_checkpoint.time
        )
    end

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_UFO)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = set_flag(ent.flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR)
        ent.type.weight = 0
        ent.type.max_speed = 1
        ent.type.elasticity = 1
        ent.type.acceleration = 1
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.color = Color:green()

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK)

	toast(neobabylon6.title)
end

neobabylon6.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon6

