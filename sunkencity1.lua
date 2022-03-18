local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local sunkencity1 = {
    identifier = "sunkencity 1",
    title = "Sunken City 1: Sticky Situation",
    theme = THEME.SUNKEN_CITY,
    width = 4,
    height = 6,
    file_name = "sunk-1.lvl",
    world = 7,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

sunkencity1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("sunken_arrow_trap")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.FLOOR_POISONED_ARROW_TRAP, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "sunken_arrow_trap")

    checkpoints.activate()

	if not checkpoints.get_saved_checkpoint() then
        toast(sunkencity1.title)
    end
end

sunkencity1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return sunkencity1

