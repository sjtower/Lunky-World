local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local checkpoints = require("Checkpoints/checkpoints")
local signs = require("Modules.JayTheBusinessGoose.signs")

local sunkencity5 = {
    identifier = "sunkencity 5",
    title = "Sunken City 5: LightoriArrow Glue Glue Bow",
    theme = THEME.SUNKEN_CITY,
    width = 6,
    height = 5,
    file_name = "sunk-5.lvl",
    world = 7,
    level = 5,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local death_push_blocks = {}

sunkencity5.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("sunken_arrow_trap")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.FLOOR_POISONED_ARROW_TRAP, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sunken_arrow_trap")

    define_tile_code("paste")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_PASTE, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "paste")

    define_tile_code("bomb_bag")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_BOMBBAG, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "bomb_bag")

    checkpoints.activate()
    --Only spawn these if the player has reached a checkpoint
    if checkpoints.get_saved_checkpoint() then
        define_tile_code("checkpoint_door")
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            spawn_entity(ENT_TYPE.FLOOR_DOOR_LAYER, x, y, layer, 0, 0)
            spawn_entity(ENT_TYPE.BG_DOOR_FRONT_LAYER, x, y, layer, 0, 0)
            return true
        end, "checkpoint_door")
    end

    replace_drop(DROP.POISONEDARROWTRAP_WOODENARROW, ENT_TYPE.ITEM_METAL_ARROW)

    death_blocks.set_ent_type(ENT_TYPE.FLOOR_BORDERTILE)
    death_blocks.activate(level_state)
    signs.activate(level_state, {
        "Pro Tip: You can attach sticky bombs to arrows and shoot them",
        "Pro Tip: Bow-Jump - while holding a bow, press jump and shoot at the exact same time"
    })

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.color:set_rgba(108, 220, 235, 255) --light blue
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

    define_tile_code("death_push_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent.flags = set_flag(ent.flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        death_push_blocks[#death_push_blocks + 1] = ent
        return true
    end, "death_push_block")

    local frames = 0
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()

        for i = 1,#death_push_blocks do
            death_push_blocks[i].color:set_rgba(100 + math.ceil(50 * math.sin(0.05 * frames)), 0, 0, 255) --Pulse effect
            if #players ~= 0 and players[1].standing_on_uid == death_push_blocks[i].uid then
                kill_entity(players[1].uid, false)
            end
        end

        frames = frames + 1
    end, ON.FRAME)

	if not checkpoints.get_saved_checkpoint() then
        toast(sunkencity5.title)
    end
end

sunkencity5.unload_level = function()
    if not level_state.loaded then return end

    death_blocks.deactivate()
    signs.deactivate()
    death_push_blocks = {}

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity5

