-- destroy random monsters
set_post_entity_spawn(function(ent, flags)
    ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
    ent:destroy()
end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, ENT_TYPE.MONS_SKELETON, ENT_TYPE.MONS_BAT, ENT_TYPE.MONS_SCARAB)

-- destroy treasure, random pots
set_post_entity_spawn(function(ent, flags)
    ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
    ent:destroy()
end, SPAWN_TYPE.LEVEL_GEN_GENERAL, MASK.ITEM)

-- destroy embed treasure and items
set_post_entity_spawn(function(ent, flags)
    if ent.overlay and (ent.overlay.type.search_flags & MASK.FLOOR) > 0 then
        ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
        ent:destroy()
    end
end, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, crust_items)

-- entrance with no textures or pots, just the player
define_tile_code("entrance_nocrap")
set_pre_tile_code_callback(function(x, y, layer)
    spawn_grid_entity(ENT_TYPE.FLOOR_DOOR_ENTRANCE, x, y, layer)
    state.level_gen.spawn_x = x
    state.level_gen.spawn_y = y
    local rx, ry = get_room_index(x, y)
    state.level_gen.spawn_room_x = rx
    state.level_gen.spawn_room_y = ry
    return true
end, "entrance_nocrap")