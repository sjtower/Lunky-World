local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local volcana6 = {
    identifier = "volcana6",
    title = "Volcana 6: Hot Foot",
    theme = THEME.VOLCANA,
    width = 3,
    height = 3,
    file_name = "volc-6.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local lavamanders = {}
volcana6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        lavamanders[#lavamanders + 1] = get_entity(ent.uid)
        set_on_kill(ent.uid, function(self)
            local uid = spawn_entity(ENT_TYPE.ITEM_BOMB, 28, 2, 1, 0, 0)
        end)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_LAVAMANDER)

    toast(volcana6.title)
end

volcana6.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana6
