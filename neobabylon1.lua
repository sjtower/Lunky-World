local neobabylon1 = {
    identifier = "neobabylon 1",
    title = "Neo Babylon1 1: I Want To Believe",
    theme = THEME.NEO_BABYLON,
    width = 2,
    height = 6,
    file_name = "neob-1.lvl",
    world = 6,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

neobabylon1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("shield_wooden")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_WOODEN_SHIELD, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "shield_wooden")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.type.max_speed = 0.05
        ent.color:set_rgba(104, 37, 71, 255) --deep red
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_UFO)

    toast(neobabylon1.title)
end

neobabylon1.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon1

