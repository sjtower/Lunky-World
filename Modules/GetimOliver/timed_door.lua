
local function timed_sound(time) 
    set_timeout(function()
        local sound = get_sound(VANILLA_SOUND.ENEMIES_EGGPLANT_DOG_BOUNCE)
        sound:play()
    end, time)
end

local function activate(level_state)
    -- Creates a wall that opens for a time when a switch is hit
    local timed_switches = {};
    define_tile_code("timed_door_switch")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        local switch = get_entity(switch_id)
        switch.color = Color:white()
        timed_switches[#timed_switches + 1] = switch
        return true
    end, "timed_door_switch")

    local timed_doors = {};
    define_tile_code("timed_door")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        ent.color:set_rgba(217, 224, 252, 255) --white blue
        timed_doors[#timed_doors + 1] = ent
        return true
    end, "timed_door")

    local is_open = false
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, switch in ipairs(timed_switches) do
            if not switch then return end
            set_timeout(function()
                is_open = false
                switch.timer = 0
                for _, door in ipairs(timed_doors) do
                    door.color:set_rgba(217, 224, 252, 255) --white blue
                    door.flags = set_flag(door.flags, ENT_FLAG.SOLID)
                end
            end, 360)
            if switch.timer > 0 and not is_open then
                is_open = true
                for _, door in ipairs(timed_doors) do
                    door.color:set_rgba(217, 224, 252, 100) --white blue, semi-opaque
                    door.flags = clr_flag(door.flags, ENT_FLAG.SOLID)
                end
            end
        end
    end, ON.FRAME)
end

return {
    activate = activate,
}
