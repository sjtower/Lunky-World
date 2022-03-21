local tidepool6 = {
    identifier = "tidepool6",
    title = "Tidepool 6: Thorny Tiny Box",
    theme = THEME.TIDE_POOL,
    width = 4,
    height = 5,
    file_name = "tide-6.lvl",
    world = 4,
    level = 6,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    define_tile_code("cape")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_CAPE, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "cape")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.color:set_rgba(235, 61, 96, 255) --hot pink
        ent.health = 20
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)        
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FEMALE_JIANGSHI)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.color:set_rgba(108, 220, 235, 255) --light blue
        ent.health = 4
        ent.flags = clr_flag(ent.flags, ENT_FLAG.STUNNABLE)
        ent:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_JIANGSHI)

	toast(tidepool6.title)
end

tidepool6.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool6

