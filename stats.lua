return function()
    local stats = {}

    -- Stats for games played in the default difficulty.
    stats.normal = {
        best_time = 0,
        best_level = nil,
        completions = 0,
    }
    return stats
end