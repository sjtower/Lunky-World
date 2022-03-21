local signs = require("Modules.JayTheBusinessGoose.signs")

local volcana6 = {
    identifier = "volcana6",
    title = "Volcana 6: Hot Foot",
    theme = THEME.VOLCANA,
    width = 3,
    height = 3,
    file_name = "volc-6.lvl",
    world = 3,
    level = 6,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local lavamanders = {}
volcana6.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    signs.activate(level_state, {"Kill the Lavamanders!"})

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        lavamanders[#lavamanders + 1] = get_entity(ent.uid)
        set_on_kill(ent.uid, function(self)
            local uid = spawn_entity(ENT_TYPE.ITEM_BOMB, 30.0, 121.0, 0, 0, 0)
        end)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_LAVAMANDER)

    define_tile_code("cape")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_CAPE, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "cape")

    define_tile_code("location_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local location = tostring(x) .. " | " .. tostring(y)
        print(location)
        return true
    end, "location_block")

    toast(volcana6.title)
end

volcana6.unload_level = function()
    if not level_state.loaded then return end

    signs.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana6
