local key_blocks = require("Modules.GetimOliver.key_blocks")
local death_blocks = require("Modules.JawnGC.death_blocks")

local tidepool3 = {
    identifier = "tidepool3",
    title = "Tidepool 3: Fishmonger",
    theme = THEME.TIDE_POOL,
    width = 4,
    height = 4,
    file_name = "tide-3.lvl",
    world = 4,
    level = 3,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    key_blocks.activate(level_state)
    death_blocks.activate()

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.MONS_SKELETON)

    define_tile_code("spike_shoes")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local shoes = spawn_entity(ENT_TYPE.ITEM_PICKUP_SPIKESHOES, x, y, layer, 0, 0)
        shoes = get_entity(shoes)
        return true
    end, "spike_shoes")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (fish)
        fish.color = Color:red()
        fish.type.max_speed = 0.01
		fish.health = 5
        fish.flags = clr_flag(fish.flags, ENT_FLAG.STUNNABLE)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FISH)

    define_tile_code("fast_fish")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local fish = spawn_entity(ENT_TYPE.MONS_FISH, x, y, layer, 0, 0)
        fish = get_entity(fish)
        fish.color = Color:yellow()
        fish.type.max_speed = 0.1
        fish.health = 5
        fish.flags = clr_flag(fish.flags, ENT_FLAG.STUNNABLE)
        -- fish.flags = set_flag(fish.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        return true
    end, "fast_fish")

    define_tile_code("fastest_fish")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local fish = spawn_entity(ENT_TYPE.MONS_FISH, x, y, layer, 0, 0)
        fish = get_entity(fish)
        fish.color = Color:green()
        fish.type.max_speed = 0.2
        fish.health = 5
        fish.flags = clr_flag(fish.flags, ENT_FLAG.STUNNABLE)
        return true
    end, "fastest_fish")

	toast(tidepool3.title)
end

tidepool3.unload_level = function()
    if not level_state.loaded then return end

    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool3

