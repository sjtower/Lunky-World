local save_state = {}

function save_state.save(game_state, level_sequence, ctx)
	local function saved_run_datar(saved_run)
		if not saved_run or not saved_run.has_saved_run then return nil end
		local saved_run_data = {
			has_saved_run = saved_run.has_saved_run,
			level = level_sequence.index_of_level(saved_run.saved_run_level) - 1,
			attempts = saved_run.saved_run_attempts,
			run_time = saved_run.saved_run_time,
		}
		return saved_run_data
	end
	local normal_saved_run_data = saved_run_datar(game_state.normal_saved_run)
	local function convert_stats(stats)
		if not stats then return nil end
		local new_stats = {}
		for k,v in pairs(stats) do new_stats[k] = v end
		local best_level = level_sequence.index_of_level(stats.best_level)
		if best_level then
			new_stats.best_level = best_level - 1
		else
			new_stats.best_level = nil
		end
		return new_stats
	end
    local save_data = {
		version = '1.5',
		saved_run_data = normal_saved_run_data,
		stats = convert_stats(game_state.stats.normal),
    }

    ctx:save(json.encode(save_data))
end

function save_state.load(game_state, level_sequence, ctx)
    local load_data_str = ctx:load()

    if load_data_str ~= '' then
        local load_data = json.decode(load_data_str)
		local load_version = load_data.version
		
		local function load_saved_run_data(saved_run, saved_run_data)
            if not saved_run_data or not saved_run_data.has_saved_run then return end
			saved_run.has_saved_run = saved_run_data.has_saved_run or not load_version
			saved_run.saved_run_level = level_sequence.levels()[saved_run_data.level+1]
			saved_run.saved_run_attempts = saved_run_data.attempts
			saved_run.saved_run_time = saved_run_data.run_time
		end
		
		local saved_run_data = load_data.saved_run_data
		if saved_run_data then
			load_saved_run_data(game_state.normal_saved_run, saved_run_data)
		end
    end
    return game_state
end

return save_state