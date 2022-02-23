local key_blocks = require("Modules.GetimOliver.key_blocks")
local death_blocks = require("Modules.JawnGC.death_blocks")

local temple5 = {
    identifier = "temple5",
    title = "Temple 5: Super Twiggle World",
    theme = THEME.TEMPLE,
    width = 4,
    height = 4,
    file_name = "temp-5.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

temple5.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    key_blocks.activate(level_state)
    death_blocks.activate(level_state)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent, flags)
        ent.flags = set_flag(ent.flags, ENT_FLAG.DEAD)
        ent:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, ENT_TYPE.MONS_SKELETON, ENT_TYPE.MONS_BAT, ENT_TYPE.MONS_SCARAB)

	toast(temple5.title)
end

temple5.unload_level = function()
    if not level_state.loaded then return end

    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return temple5

