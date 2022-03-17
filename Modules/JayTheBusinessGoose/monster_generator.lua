local function activate(level_state, ent_type)
    if ent_type == nil then
        ent_type = ENT_TYPE.MONS_BAT
    end

    define_tile_code("monster_generator")
    local monster_generator
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        -- Creates a generator that will spawn monsters when turned on. Defaults to off.
        local generator_id = spawn_entity(ENT_TYPE.FLOOR_SUNCHALLENGE_GENERATOR, x, y, layer, 0.0, 0.0)
        local generator = get_entity(generator_id)
        generator.on_off = false
        monster_generator = generator
        return true
    end, "monster_generator")
    
    define_tile_code("monster_switch")
    local monster_switch
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        monster_switch = get_entity(switch_id)
        return true
    end, "monster_switch")
    
    local last_spawn
    local spawned_monster
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(ent)
        if last_spawn ~= nil then
            -- Kill the last enemy that was spawned so that we don't end up with too many enemies in
            -- memory. Doing this here since we couldn't kill the enemy earlier.
            kill_entity(last_spawn.uid)
        end
        last_spawn = ent
        local x, y, l = get_position(ent.uid)
        -- Spawn a monster one tile lower than the tile the enemy was spawned at; otherwise the monster will be
        -- crushed in the generator.
        spawned_monster = spawn_entity_nonreplaceable(ent_type, x, y - 1, l, 0, 0)
        -- Move the actual spawn out of the way instead of killing it; killing it now causes the
        --  generator to immediately spawn again, leading to infinite spawns.
        ent.x = 10000
        -- Turn off the generator when a monster is spawned to make sure only one monster is ever spawned at a time.
        monster_generator.on_off = false
    end, SPAWN_TYPE.SYSTEMIC, 0, {ENT_TYPE.MONS_SORCERESS, ENT_TYPE.MONS_VAMPIRE, ENT_TYPE.MONS_WITCHDOCTOR, ENT_TYPE.MONS_NECROMANCER})
    
    local has_activated_monsters = false
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
        local monster_entity = get_entity(spawned_monster)
        if monster_entity and monster_entity.health == 0 then
            -- Turn the generator back on now that the monster is dead.
            monster_generator.on_off = true
            spawned_monster = nil
        end
        if monster_switch and monster_switch.timer > 0 and not has_activated_monsters then
            monster_generator.on_off = true
            has_activated_monsters = true
            
            get_sound(VANILLA_SOUND.UI_SECRET):play()
            
        end
    end, ON.FRAME)
    
end

return {
    activate = activate,
}