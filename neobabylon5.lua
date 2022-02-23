local checkpoints = require("Checkpoints/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local death_blocks = require("Modules.JawnGC.death_blocks")
local key_blocks = require("Modules.GetimOliver.key_blocks")
local inverse_timed_doors = require("Modules.GetimOliver.inverse_timed_door")

local neobabylon5 = {
    identifier = "neobabylon 5",
    title = "Neo Babylon 5: Space Invaders",
    theme = THEME.NEO_BABYLON,
    width = 6,
    height = 6,
    file_name = "neob-5.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

neobabylon5.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    define_tile_code("wooden_shield")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_WOODEN_SHIELD, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "wooden_shield")

    define_tile_code("unpushable_push_block")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        ent = get_entity(ent)
        ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT) --Unpushable
        ent.color = Color:black()
        return true
    end, "unpushable_push_block")

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent = spawn_entity(ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, x, y, layer, 0, 0)
        ent = get_entity(ent)
        return true
    end, "pitchers_mitt")

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_UFO)

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (ent)
        ent.flags = set_flag(ent.flags, ENT_FLAG.INDESTRUCTIBLE_OR_SPECIAL_FLOOR)
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.color = Color:green()

        set_post_statemachine(ent.uid, function(ent)
            if ent.last_owner_uid ~= -1 then
              local pusher = get_entity(ent.last_owner_uid)
              local x, y, l = get_position(ent.uid)
              local dx = pusher.movex*0.1 -- here's the speed
              move_entity(ent.uid, x+dx, y, 0, 0)
            end
          end)

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK)

    checkpoints.activate()
    death_blocks.activate(level_state)
    key_blocks.activate(level_state)
    inverse_timed_doors.activate(level_state, 1500)

	toast(neobabylon5.title)
end

neobabylon5.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    inverse_timed_doors.deactivate()
    key_blocks.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon5

