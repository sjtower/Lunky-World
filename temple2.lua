local death_blocks = require("Modules.JawnGC.death_blocks")
local checkpoints = require("Checkpoints/checkpoints")
local temple2 = {
    identifier = "temple2",
    title = "Temple 2: Sqaure Peg",
    theme = THEME.TEMPLE,
    width = 4,
    height = 4,
    file_name = "temp-2.lvl",
    world = 5,
    level = 2,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local key_blocks = {}
local block_keys = {}

temple2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    death_blocks.activate(level_state)
    checkpoints.activate()

    -- from Dregu: double bullet speed. Anything faster and you should turn it in to a hitscan weapon
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        set_timeout(function() -- they don't have velocity when spawned, wait a frame
          local x = ent.velocityx
          local y = ent.velocityy
          local vel = 0.6 -- base velocity
          local sx = x>0 and vel or x<0 and -vel or 0 -- get sign x
          local sy = y>0 and vel or y<0 and -vel or 0 -- get sign y
          ent.velocityx = sx 
          ent.velocityy = sy/100 -- remove y velocity to stop spread
        end, 1)
      end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_BULLET)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        spawn_entity(ENT_TYPE.MONS_CATMUMMY, x, y, layer, 0, 0)
        return true
    end, "catmummy")

    define_tile_code("shotgun")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local shotgun = spawn_entity(ENT_TYPE.ITEM_SHOTGUN, x, y, layer, 0, 0)
        shotgun = get_entity(shotgun)
        return true
    end, "shotgun")

    define_tile_code("key_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local floor = get_entity(floor_uid)
        floor.color = Color:yellow()
        floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
        key_blocks[#key_blocks + 1] = get_entity(floor_uid)
        return true
    end, "key_block")

    --Only spawn this key_block if the player has not reached a checkpoint
    if not checkpoints.get_saved_checkpoint() then
        define_tile_code("no_checkpoint_key_block")
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            local floor_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
            local floor = get_entity(floor_uid)
            floor.color = Color:yellow()
            floor.flags = set_flag(floor.flags, ENT_FLAG.NO_GRAVITY)
            key_blocks[#key_blocks + 1] = get_entity(floor_uid)
            return true
        end, "no_checkpoint_key_block")
    end

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
                    local sound = get_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
                    sound:play()
                end
            end
        end)
        return true
    end, "block_key")

    --Only spawn these if the player has reached a checkpoint
    if checkpoints.get_saved_checkpoint() then
        define_tile_code("checkpoint_crushtraplarge")
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            spawn_entity(ENT_TYPE.ACTIVEFLOOR_CRUSH_TRAP_LARGE, x + 0.5, y - 0.5, layer, 0, 0)
            return true
        end, "checkpoint_crushtraplarge")
        define_tile_code("checkpoint_door")
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            spawn_entity(ENT_TYPE.FLOOR_DOOR_LAYER, x, y, layer, 0, 0)
            spawn_entity(ENT_TYPE.BG_DOOR, x, y, layer, 0, 0)
            return true
        end, "checkpoint_door")
    end

	if not checkpoints.get_saved_checkpoint() then
        toast(temple2.title)
    end
end

temple2.unload_level = function()
    if not level_state.loaded then return end

    block_keys = {}
    key_blocks = {}
    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple2

