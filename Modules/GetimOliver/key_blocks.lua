local key_blocks = {}
local block_keys = {}

local function activate(level_state)
    
    define_tile_code("key_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_uid)
        ent.color = Color:yellow()
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
        key_blocks[#key_blocks + 1] = get_entity(ent_uid)
        return true
    end, "key_block")

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
end

local function deactivate()
    block_keys = {}
    key_blocks = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
