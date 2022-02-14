local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local checkpoints = require("Checkpoints/checkpoints")
local checkpoints2 = require("Checkpoints2/checkpoints")
local nocrap = require("Modules.Dregu.no_crap")
local key_blocks = require("Modules.GetimOliver.key_blocks")
local timed_doors = require("Modules.GetimOliver.timed_door")
local death_blocks = require("Modules.JawnGC.death_blocks")

local neobabylon2 = {
    identifier = "neobabylon 2",
    title = "Neo Babylon1 2: Time",
    theme = THEME.NEO_BABYLON,
    width = 4,
    height = 4,
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

    key_blocks.activate(level_state)
    death_blocks.activate(level_state)
    timed_doors.activate(level_state)

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

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon2

