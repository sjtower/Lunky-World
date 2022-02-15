local function activate(level_state)

    define_tile_code("fast_push_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        ent = get_entity(ent)    
        ent.flags = set_flag(ent.flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.color = Color:green()

        set_post_statemachine(ent.uid, function(ent)
            if ent.last_owner_uid ~= -1 then
                local pusher = get_entity(ent.last_owner_uid)
                local x, y, l = get_position(ent.uid)
                local dx = pusher.movex*0.1 -- here's the speed
                move_entity(ent.uid, x+dx, y, 0, 0)
            end
            end)

    end, "fast_push_block")

end

return {
    activate = activate
}
