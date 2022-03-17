local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")

define_tile_code("skull")
define_tile_code("torch")
define_tile_code("arrow")

local dwelling2 = {
    identifier = "dwelling2",
    title = "Dwelling 2: Crush & Burn",
    theme = THEME.DWELLING,
    width = 6,
    height = 6,
    file_name = "dwell-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

dwelling2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    checkpoints.activate()

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.MONS_SKELETON)

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "pitchers_mitt")

    local torch;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local torch_id = spawn_entity(ENT_TYPE.ITEM_TORCH, x, y, layer, 0, 0)
        torch = get_entity(torch_id)
        return true
    end, "torch")

    if checkpoints.get_saved_checkpoint() then
        define_tile_code("checkpoint_torch")
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            local torch_id = spawn_entity(ENT_TYPE.ITEM_TORCH, x, y, layer, 0, 0)
            torch = get_entity(torch_id)
            return true
        end, "checkpoint_torch")
    end

    local arrow;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local arrow_id = spawn_entity(ENT_TYPE.ITEM_WOODEN_ARROW, x, y, layer, 0, 0)
        arrow = get_entity(arrow_id)
        return true
    end, "arrow")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (snake)

        snake.health = 100
        snake.color = Color:red()
        snake.type.max_speed = 0.05
        snake.flags = set_flag(snake.flags, ENT_FLAG.TAKE_NO_DAMAGE)

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SNAKE)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        entity.health = 10
        entity.flags = set_flag(entity.flags, ENT_FLAG.FACING_LEFT)
        --Caveman carries torch
        local torch_uid = spawn_entity(ENT_TYPE.ITEM_TORCH, entity.x, entity.y, entity.layer, 0, 0)
        get_entity(torch_uid):light_up(true)
        pick_up(entity.uid, torch_uid)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_CAVEMAN)

    if not checkpoints.get_saved_checkpoint() then
        toast(dwelling2.title)
    end
end

dwelling2.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling2
