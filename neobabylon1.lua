local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")

local neobabylon1 = {
    identifier = "neobabylon 1",
    title = "Neo Babylon1 1: I Want To Believe",
    theme = THEME.NEO_BABYLON,
    width = 2,
    height = 6,
    file_name = "neob-1.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local saved_checkpoint

local function save_checkpoint(checkpoint)
    saved_checkpoint = checkpoint
end

neobabylon1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent, flags)
        ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
        ent:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, ENT_TYPE.MONS_SKELETON, ENT_TYPE.MONS_BAT, ENT_TYPE.MONS_SCARAB)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.type.max_speed = 0.05
        ent.color:set_rgba(104, 37, 71, 255) --deep red
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_UFO)

    checkpoints.activate()

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

    -- local checkpoint
    -- level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
    --     local ent_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
    --     local ent = get_entity(floor_uid)
    --     ent.color = Color:purple()
    --     ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
    --     -- checkpoints[#checkpoints + 1] = get_entity(floor_uid)
    --     return true
    -- end, "checkpoint")


    local key_blocks = {}
    define_tile_code("key_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:purple()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        key_blocks[#key_blocks + 1] = get_entity(floor_uid)
        return true
    end, "key_block")

    local block_keys = {}
    define_tile_code("block_key")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local uid = spawn_entity(ENT_TYPE.ITEM_KEY, x, y, layer, 0, 0)
        local key = get_entity(uid)
        key.color = Color:purple()
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
			death_blocks[i].color:set_rgba(100 + math.ceil(50 * math.sin(0.05 * frames)), 0, 0, 255) --Pulse effect
			if #players ~= 0 and players[1].standing_on_uid == death_blocks[i].uid then
				kill_entity(players[1].uid, false)
			end
		end

        frames = frames + 1
    end, ON.FRAME)

	toast(neobabylon1.title)
end

neobabylon1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon1

