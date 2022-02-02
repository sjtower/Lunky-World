local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local volcana3 = {
    identifier = "volcana3",
    title = "Volcana 3",
    theme = THEME.VOLCANA,
    width = 4,
    height = 4,
    file_name = "volc-3.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

volcana3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

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

end

volcana3.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana3
