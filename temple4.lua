local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

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

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (firebug)
        firebug.type.max_speed = 0
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FIREBUG)


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

    local key_blocks = {}
    define_tile_code("key_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:yellow()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        key_blocks[#key_blocks + 1] = get_entity(floor_uid)
        return true
    end, "key_block")

    local block_keys = {}
    define_tile_code("block_key")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
        local key = get_entity(uid)
        key.color = Color:yellow()
        block_keys[#block_keys + 1] = get_entity(uid)
        set_pre_collision2(key.uid, function(self, collision_entity)
            for _, block in ipairs(key_blocks) do
                if collision_entity.uid == block.uid then
                    -- kill_entity(door_uid)
                    kill_entity(block.uid)
                    kill_entity(key.uid)
                    sound.play_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
                end
            end
        end)
        return true
    end, "block_key")


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

    --Death Blocks - from JawnGC
	define_tile_code("death_block")
	local death_blocks = {}
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn(ENT_TYPE.FLOORSTYLED_TEMPLE, x, y, layer, 0, 0)
		death_blocks[#death_blocks + 1] = get_entity(block_id)
		death_blocks[#death_blocks].color:set_rgba(100, 0, 0, 255) --Dark Red
		death_blocks[#death_blocks].more_flags = set_flag(death_blocks[#death_blocks].more_flags, 17) --Unpushable
		death_blocks[#death_blocks].flags = set_flag(death_blocks[#death_blocks].flags, 10) --No Gravity
		return true
	end, "death_block")

    local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()

		for i = 1,#death_blocks do
			death_blocks[i].color:set_rgba(100 + math.ceil(40 * math.sin(0.05 * frames)), 0, 0, 255) --Pulse effect
			if #players ~= 0 and players[1].standing_on_uid == death_blocks[i].uid then
				kill_entity(players[1].uid, false)
			end
		end
        
        frames = frames + 1
    end, ON.FRAME)

	toast(temple4.title)
end

temple4.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple4

