local key_blocks = require("Modules.GetimOliver.key_blocks")
local death_blocks = require("Modules.JawnGC.death_blocks")
local checkpoints = require("Checkpoints/checkpoints")
local temple2 = {
    identifier = "temple2",
    title = "Temple 2: Sqaure Peg",
    theme = THEME.TEMPLE,
    width = 4,
    height = 4,
    file_name = "temp-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

temple2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    key_blocks.activate(level_state)
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

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (thorn)
        thorn.color = Color:red()
        set_pre_collision2(thorn.uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid and players[1].invincibility_frames_timer <= 0 then
                -- todo: get directional damage working
                if players[1].FACING_LEFT then
                    players[1]:damage(thorn.uid, 1, 30, 0, .1, 100)
                else
                    players[1]:damage(thorn.uid, 1, 30, 0, .1, 100)
                end
            end
        end)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

	toast(temple2.title)
end

temple2.unload_level = function()
    if not level_state.loaded then return end

    key_blocks.deactivate()
    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple2

