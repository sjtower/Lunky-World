local function activate(level_state)

    define_tile_code("death_elevator")
    local death_elevators = {}
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local elevator_id = spawn(ENT_TYPE.ACTIVEFLOOR_ELEVATOR, x, y, layer, 0, 0)
        death_elevators[#death_elevators + 1] = get_entity(elevator_id)
        death_elevators[#death_elevators].color:set_rgba(100, 0, 0, 255) --Dark Red
        return true
    end, "death_elevator")

    local frames = 0
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()

        for i = 1,#death_elevators do
            death_elevators[i].color:set_rgba(100 + math.ceil(50 * math.sin(0.05 * frames)), 0, 0, 255) --Pulse effect
            if #players ~= 0 and players[1].standing_on_uid == death_elevators[i].uid then
                kill_entity(players[1].uid, false)
            end
        end

        frames = frames + 1
    end, ON.FRAME)
end

return {
    activate = activate,
}
