local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

define_tile_code("quillback_switch")
define_tile_code("switchable_quillback")
define_tile_code("quillback_spring")
local dwelling4 = {
    identifier = "dwelling4",
    title = "Dwelling 4",
    theme = THEME.DWELLING,
    width = 4,
    height = 4,
    file_name = "dwell-4.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

dwelling4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    -- Creates a Quilliam that will stop when the quillback_switch is switched.
    local quilliams = {}
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        clear_embeds.perform_block_without_embeds(function()        
            local quilliam = spawn_entity(ENT_TYPE.MONS_CAVEMAN_BOSS, x, y, layer, 0, 0)
            quilliams[#quilliams + 1] = get_entity(quilliam)
        end)
        return true
    end, "switchable_quillback")

    local quillback_switch;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        quillback_switch = get_entity(switch_id)
        return true
    end, "quillback_switch")

    local has_stopped_quilliam = false
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        if not quillback_switch then return end
        if quillback_switch.timer > 0 and not has_stopped_quilliam then
            has_stopped_quilliam = true
            for _, quilliam in ipairs(quilliams) do
                --kill_entity(quilliam.uid)	
                
                quilliam.flags = set_flag(quilliam.flags, ENT_FLAG.STUNNABLE)
                quilliam.flags = clr_flag(quilliam.flags, ENT_FLAG.TAKE_NO_DAMAGE)
                quilliam:damage(quillback_switch.uid, 0, 120, 0, 0, 0)
                has_stopped_quilliam = false
            end
            -- quilliams = {}
        end
    end, ON.FRAME)

end

dwelling4.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling4
