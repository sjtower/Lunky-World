local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

local jungle2 = {
    identifier = "jungle2",
    title = "Jungle 2",
    theme = THEME.JUNGLE,
    width = 8,
    height = 4,
    file_name = "jung-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

jungle2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mantrap)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.STUNNABLE)
        mantrap.flags = clr_flag(mantrap.flags, ENT_FLAG.FACING_LEFT)
        mantrap.flags = set_flag(mantrap.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        mantrap.color = Color:red()

    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MANTRAP)
    
    -- level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (mosquito)
    --     mosquito.flags = clr_flag(mosquito.flags, ENT_FLAG.STUNNABLE)
    --     mosquito.flags = clr_flag(mosquito.flags, ENT_FLAG.FACING_LEFT)
    --     mosquito.flags = set_flag(mosquito.flags, ENT_FLAG.TAKE_NO_DAMAGE)
    --     -- mosquito.type.max_speed = 0.0575
    --     mosquito.type.max_speed = 0.035
    --     -- mosquito.move_state = 1
    --     mosquito.color = Color:red()

    -- end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MOSQUITO)

        -- Creates a Quilliam that will stun or jump when with a "quillback switch".
        local mosquitos = {}
        level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
            clear_embeds.perform_block_without_embeds(function()        
                local mosquito = spawn_entity(ENT_TYPE.MONS_MOSQUITO, x, y, layer, 0, 0)
                mosquito = get_entity(mosquito)
                mosquitos[#mosquitos + 1] = mosquito
                mosquito.type.max_speed = 0.035
                mosquito.color = Color:red()
                mosquito.flags = clr_flag(mosquito.flags, ENT_FLAG.STUNNABLE)
                mosquito.flags = clr_flag(mosquito.flags, ENT_FLAG.FACING_LEFT)
                mosquito.flags = set_flag(mosquito.flags, ENT_FLAG.TAKE_NO_DAMAGE)
            end)
            return true
        end, "mosquito")

    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, mosquito in ipairs(mosquitos) do
            -- if quilliam.seen_player then
                mosquito.flags = clr_flag(mosquito.flags, ENT_FLAG.FACING_LEFT)
            -- end
        end
    end, ON.FRAME)

end

jungle2.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return jungle2
