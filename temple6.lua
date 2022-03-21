local death_blocks = require("Modules.JawnGC.death_blocks")
local signs = require("Modules.JayTheBusinessGoose.signs")
local temple6 = {
    identifier = "temple6",
    title = "Temple 6: Ghostbusters",
    theme = THEME.TEMPLE,
    width = 4,
    height = 4,
    file_name = "temp-6.lvl",
    world = 5,
    level = 6,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

temple6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    death_blocks.activate(level_state)
    signs.activate(level_state, {"Kill the Ghost Mummy!"})

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent, flags)
        ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
        ent:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, ENT_TYPE.MONS_SKELETON, ENT_TYPE.MONS_BAT, ENT_TYPE.MONS_SCARAB)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.type.max_speed = 0.3
        ent.color:set_rgba(104, 37, 71, 150) --deep red, semi-opaque
        ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)

        set_on_kill(ent.uid, function(self)
            local x, y, l = get_position(self.uid)
            local uid = spawn_entity(ENT_TYPE.ITEM_BOMB, x, y-1, l, 0, 0)
        end)

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MUMMY)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.health = 10
        ent.type.max_speed = 0.2
        ent.color:set_rgba(104, 37, 71, 150) --deep red, semi-opaque
        ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_PLAYER)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.SORCERESS)

    -- from Dregu: double fly speed. Anything faster and you should turn it in to a hitscan weapon
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_OBJECTS)
        set_timeout(function() -- they don't have velocity when spawned, wait a frame
            local x = ent.velocityx
            local y = ent.velocityy
            local vel = 0.6 -- base velocity
            local sx = x>0 and vel or x<0 and -vel or 0 -- get sign x
            local sy = y>0 and vel or y<0 and -vel or 0 -- get sign y
            ent.velocityx = sx 
            -- ent.velocityy = sy/100 -- remove y velocity to stop spread
        end, 1)
        end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLY, ENT_TYPE.FLYHEAD)

	toast(temple6.title)
end

temple6.unload_level = function()
    if not level_state.loaded then return end

    signs.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple6

