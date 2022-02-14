
local function timed_sound(time) 
    set_timeout(function()
        local sound = get_sound(VANILLA_SOUND.ENEMIES_EGGPLANT_DOG_BOUNCE)
        sound:play()
    end, time)
end

local timed_doors = {};
local timed_switches = {};

local function open_door() 
    for _, door in ipairs(timed_doors) do
        door.color:set_rgba(217, 224, 252, 100) --white blue, semi-opaque
        door.flags = clr_flag(door.flags, ENT_FLAG.SOLID)
    end
end

local function close_door() 
    for _, door in ipairs(timed_doors) do
        door.color:set_rgba(217, 224, 252, 255) --white blue
        door.flags = set_flag(door.flags, ENT_FLAG.SOLID)
    end
end

local function activate(level_state, time)
    -- Creates a wall that opens for a time when a switch is hit
    define_tile_code("timed_door_switch")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        local switch = get_entity(switch_id)
        switch.color = Color:white()
        timed_switches[#timed_switches + 1] = switch
        local door_timer = time
        local sound = get_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
        set_on_damage(switch_id, function(self)
            if self.timer > 0 then return end
            self.timer = door_timer
            self.animation_frame = self.animation_frame == 86 and 96 or 86
            open_door()
            sound:play()
            set_timeout(function()
                self.animation_frame = self.animation_frame == 86 and 96 or 86
                close_door()
                sound:play()
            end, door_timer)
        end)
    end, "timed_door_switch")

    define_tile_code("timed_door")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local ent_id = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
        local ent = get_entity(ent_id)
        ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
        ent.color:set_rgba(217, 224, 252, 255) --white blue
        timed_doors[#timed_doors + 1] = ent
        return true
    end, "timed_door")
end

local function deactivate()
    timed_doors = {}
    timed_switches = {}
end

return {
    activate = activate,
    deactivate = deactivate
}
