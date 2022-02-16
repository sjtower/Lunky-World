local checkpoints = require("Checkpoints/checkpoints")
-- local nocrap = require("Modules.Dregu.no_crap")
local timed_doors = require("Modules.GetimOliver.timed_door")

local neobabylon2 = {
    identifier = "neobabylon 2",
    title = "Neo Babylon1 2: Time",
    theme = THEME.NEO_BABYLON,
    width = 8,
    height = 2,
    file_name = "neob-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local saved_checkpoint

local function save_checkpoint(checkpoint)
    saved_checkpoint = checkpoint
end

neobabylon2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    timed_doors.activate(level_state, 180)

    modify_sparktraps(0.1, 1.1)

    define_tile_code("horizontal_ufo")
    local ufos = {}
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_uid = spawn_entity(ENT_TYPE.MONS_UFO, x, y, layer, 0, 0)
        local ent = get_entity(ent_uid)
        ent.velocityy = 0
        ent.color:set_rgba(104, 37, 71, 255) --deep red
        ent.flags = set_flag(ent.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        ent.flags = clr_flag(ent.flags, ENT_FLAG.FACING_LEFT)
        ufos[#ufos + 1] = ent
    end, "horizontal_ufo")

    checkpoints.activate()

    checkpoints.checkpoint_activate_callback(function(x, y, layer, time)
        save_checkpoint({
            position = {
                x = x,
                y = y,
                layer = layer,
            },
            time = time,
        })
    end)

    if saved_checkpoint then
        checkpoints.activate_checkpoint_at(
            saved_checkpoint.position.x,
            saved_checkpoint.position.y,
            saved_checkpoint.position.layer,
            saved_checkpoint.time
        )
    end

	toast(neobabylon2.title)
end

neobabylon2.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()
    timed_doors.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon2

