local function activate(level_state)

    --Death Blocks - from JawnGC
    define_tile_code("death_block")
    local death_blocks = {}
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local block_id = spawn(ENT_TYPE.FLOORSTYLED_TEMPLE, x, y, layer, 0, 0)
        death_blocks[#death_blocks + 1] = get_entity(block_id)
        death_blocks[#death_blocks].color:set_rgba(100, 0, 0, 255) --Dark Red
        death_blocks[#death_blocks].more_flags = set_flag(death_blocks[#death_blocks].more_flags, 17) --Unpushable
        death_blocks[#death_blocks].flags = set_flag(death_blocks[#death_blocks].flags, 10) --No Gravity
        return true
    end, "death_block")

    local frames = 0
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()

        for i = 1,#death_blocks do
            death_blocks[i].color:set_rgba(100 + math.ceil(50 * math.sin(0.05 * frames)), 0, 0, 255) --Pulse effect
            if #players ~= 0 and players[1].standing_on_uid == death_blocks[i].uid then
                kill_entity(players[1].uid, false)
            end
        end

        frames = frames + 1
    end, ON.FRAME)
end

return {
    activate = activate,
}
