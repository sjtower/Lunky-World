local function activate(level_state)

    -- Creates walls that will be destroyed when the totem_switch is switched. Don't ask why these are called totems, they're just walls.
    local moving_totems = {}
    define_tile_code("moving_totem")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local totem_uid = spawn_entity(ENT_TYPE.FLOOR_GENERIC, x, y, layer, 0, 0)
        moving_totems[#moving_totems + 1] = get_entity(totem_uid)
        return true
    end, "moving_totem")

    local totem_switch;
    define_tile_code("totem_switch")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        totem_switch = get_entity(switch_id)
        return true
    end, "totem_switch")

    local has_activated_totem = false
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        if not totem_switch then return end
        if totem_switch.timer > 0 and not has_activated_totem then
            has_activated_totem = true
            for _, moving_totem in ipairs(moving_totems) do
                kill_entity(moving_totem.uid)
            end
            moving_totems = {}
        end
    end, ON.FRAME)
end

return {
    activate = activate,
}