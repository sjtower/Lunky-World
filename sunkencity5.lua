local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local checkpoints = require("Checkpoints/checkpoints")
local sunkencity5 = {
    identifier = "sunkencity 5",
    title = "Sunken City 5: LightoriArrow Glue Glue Bow",
    theme = THEME.SUNKEN_CITY,
    width = 6,
    height = 4,
    file_name = "sunk-5.lvl",
    world = 7,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

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
            spawn_entity(ENT_TYPE.BG_DOOR, x, y, layer, 0, 0)
            return true
        end, "checkpoint_door")
    end

    replace_drop(DROP.POISONEDARROWTRAP_WOODENARROW, ENT_TYPE.ITEM_METAL_ARROW)

    death_blocks.set_ent_type(ENT_TYPE.FLOOR_BORDERTILE)
    death_blocks.activate(level_state)

	if not checkpoints.get_saved_checkpoint() then
        toast(sunkencity5.title)
    end
end

sunkencity5.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity5

