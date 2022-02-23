local key_blocks = require("Modules.GetimOliver.key_blocks")
local death_blocks = require("Modules.JawnGC.death_blocks")

local temple4 = {
    identifier = "temple4",
    title = "Temple 4: Super Twiggle World",
    theme = THEME.TEMPLE,
    width = 4,
    height = 5,
    file_name = "temp-4.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

temple4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    key_blocks.activate(level_state)
    death_blocks.activate(level_state)

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_RUBY, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "ruby")

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_EMERALD, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "emerald")

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_SAPPHIRE, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sapphire")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_DIAMOND)

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_CAPE, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "cape")

    define_tile_code("jetpack")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_JETPACK, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "jetpack")

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_PASTE, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "paste")

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_BOMBBOX, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "bomb_box")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.MONS_SKELETON)

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        spawn_entity(ENT_TYPE.MONS_CATMUMMY, x, y, layer, 0, 0)
        return true
    end, "catmummy")

    local poor_money_gates = {}
    define_tile_code("poor_money_gate")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:yellow()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        poor_money_gates[#poor_money_gates + 1] = get_entity(floor_uid)
        return true
    end, "poor_money_gate")

    local middle_class_money_gates = {}
    define_tile_code("middle_class_money_gate")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:green()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        middle_class_money_gates[#middle_class_money_gates + 1] = get_entity(floor_uid)
        return true
    end, "middle_class_money_gate")

    local wealthy_money_gates = {}
    define_tile_code("wealthy_money_gate")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:purple()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        wealthy_money_gates[#wealthy_money_gates + 1] = get_entity(floor_uid)
        return true
    end, "wealthy_money_gate")
    
    local frames = 0
    local is_poor = true
    local is_middle_class = false
    local is_wealthy = false
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()

        if (players[1].inventory.money > 1000000) and is_wealthy then
            for i = 1,#wealthy_money_gates do
                kill_entity(wealthy_money_gates[i].uid)
                sound.play_sound(VANILLA_SOUND.ENEMIES_YETI_KING_ROAR)
                is_wealthy = false
            end
        elseif (players[1].inventory.money > 100000) and is_middle_class then
            for i = 1,#middle_class_money_gates do
                kill_entity(middle_class_money_gates[i].uid)
                sound.play_sound(VANILLA_SOUND.SHOP_SHOP_BUY)
                is_middle_class = false
                is_wealthy = true
            end
        elseif (players[1].inventory.money > 10000) and is_poor then
            for i = 1,#poor_money_gates do
                kill_entity(poor_money_gates[i].uid)
                sound.play_sound(VANILLA_SOUND.SHOP_SHOP_ENTER)
                is_poor = false
                is_middle_class = true
            end
        end
        
        frames = frames + 1
    end, ON.FRAME)

	toast(temple4.title)
end

temple4.unload_level = function()
    if not level_state.loaded then return end

    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple4

