local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local death_elevators = require("Modules.GetimOliver.death_elevators")
local monster_generators = require("Modules.JayTheBusinessGoose.monster_generator")

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
    monster_generators.activate(level_state, ENT_TYPE.MONS_UFO)

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
        ent.health = 60
        ent.color:set_rgba(104, 37, 71, 255) --deep red

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_ALIENQUEEN)

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

