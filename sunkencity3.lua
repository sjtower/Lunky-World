local nocrap = require("Modules.Dregu.no_crap")
local key_blocks = require("Modules.GetimOliver.key_blocks")
local sunkencity3 = {
    identifier = "sunkencity 3",
    title = "Sunken City 3: Diplomatic Relationships",
    theme = THEME.EGGPLANT_WORLD,
    width = 3,
    height = 3,
    file_name = "sunk-3.lvl",
    world = 7,
    level = 3,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

sunkencity3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("jetpack")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local gloves = spawn_entity(ENT_TYPE.ITEM_JETPACK, x, y, layer, 0, 0)
        gloves = get_entity(gloves)
        return true
    end, "jetpack")

    key_blocks.activate(level_state)

	toast(sunkencity3.title)
end

sunkencity3.unload_level = function()
    if not level_state.loaded then return end

    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity3

