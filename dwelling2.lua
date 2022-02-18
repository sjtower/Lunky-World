local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")

define_tile_code("skull")
define_tile_code("torch")
define_tile_code("arrow")


local dwelling2 = {
    identifier = "dwelling2",
    title = "Dwelling 2",
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

    local skull;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local skull_id = spawn_entity(ENT_TYPE.ITEM_SKULL, x, y, layer, 0, 0)
        skull = get_entity(skull_id)
        return true
    end, "skull")

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
        --Caveman carries torch
        local torch_uid = spawn_entity(ENT_TYPE.ITEM_TORCH, entity.x, entity.y, entity.layer, 0, 0)
        spawn_entity(ENT_TYPE.ITEM_TORCHFLAME, entity.x, entity.y, entity.layer, 0, 0)
        --get_entity(torch_uid).is_lit = true
        pick_up(entity.uid, torch_uid)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_CAVEMAN)

end

dwelling2.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling2
