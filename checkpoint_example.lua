local checkpoints = require("Checkpoints/checkpoints")

local neobabylon1 = {
    identifier = "neobabylon 1",
    title = "Neo Babylon1 1: I Want To Believe",
    theme = THEME.NEO_BABYLON,
    width = 2,
    height = 6,
    file_name = "neob-1.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local saved_checkpoint

local function save_checkpoint(checkpoint)
    saved_checkpoint = checkpoint
end

neobabylon1.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

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
end

neobabylon1.unload_level = function()
    if not level_state.loaded then return end

    checkpoints.deactivate()

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return neobabylon1

