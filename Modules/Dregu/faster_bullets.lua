local function activate(level_state)

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

    define_tile_code("shotgun")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local shotgun = spawn_entity(ENT_TYPE.ITEM_SHOTGUN, x, y, layer, 0, 0)
        shotgun = get_entity(shotgun)
        return true
    end, "shotgun")

end

return {
    activate = activate
}
