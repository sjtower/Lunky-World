# Enemy carries an item

```lua
level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        --Bat carries elixir
        entity:give_powerup(ENT_TYPE.ITEM_PICKUP_ELIXIR)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_BAT)
```
    
# Enemy has lots of health
```lua
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        --Set all bats HP to 10
        entity.health = 10
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_BAT)
```    

```lua
    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        --Caveman carries torch
        local torch_uid = spawn_entity(ENT_TYPE.ITEM_TORCH, entity.x, entity.y, entity.layer, 0, 0)
        spawn_entity(ENT_TYPE.ITEM_TORCHFLAME, entity.x, entity.y, entity.layer, 0, 0)
        pick_up(entity.uid, torch_uid)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_CAVEMAN)`
```

# Custom tilecodes
```lua
    local skull;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local skull_id = spawn_entity(ENT_TYPE.ITEM_SKULL, x, y, layer, 0, 0)
        skull = get_entity(skull_id)
        return true
    end, "skull")

    local torch;
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local torch_id = spawn_entity(ENT_TYPE.ITEM_TORCH, x, y, layer, 0, 0)
        torch = get_entity(torch_id)
        return true
    end, "torch")
```

```lua
    local quillback_spring; --NOT WORKING
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local spring = spawn_entity(ENT_TYPE.FLOOR_SPRING_TRAP, x, y, layer, 0, 0)
        quillback_spring = get_entity(spring)

        quillback_spring.color = Color:red()
        
        set_pre_collision1(quillback_spring.uid, function(self, collision_entity)
            if collision_entity.uid == players[1].uid then
                -- players[1].health = 0
                players[1]:damage(quillback_spring.uid, 0, 0, 0, 1, 0)
            elseif collision_entity.uid == quilliams[1].uid then
                collision_entity:damage(quillback_spring.uid, 0, 0, 0, 50, 0)
            end
        end)
        return true
    end, "quillback_spring")
```

```lua
set_callback(function() --NOT WORKING
    set_interval(function()
        local quillbacks = get_entities_by_type(ENT_TYPE.MONS_CAVEMAN_BOSS)
        for _, quilliam in ipairs(quillbacks) do
            quilliam:damage(quilliam.uid, 1, 0, 0, 100, 0)
        end
    end, 10)
  end, ON.LEVEL)
```

quilliam.flags = clr_flag(mole.flags, ENT_FLAG.STUNNABLE)



level_state.callbacks[#level_state.callbacks+1] =set_callback(function()
  state:force_current_theme(THEME.ICE_CAVES)
end, ON.POST_ROOM_GENERATION)

--[[Spawns a stack of n olmites
If n is one or zero, it will spawn a single helmet olmite that does not attack because it thinks it's in a stack
Higher values for n should work, including n>4
See also: https://github.com/spelunky-fyi/overlunky/blob/main/docs/script-api.md#olmite]]--
function spawn_olmite_stack(x, y, layer, n)
    local y_offset = 0.64
    
    local stack_olmites = {get_entity(spawn_entity(ENT_TYPE.MONS_OLMITE_HELMET, x, y+y_offset*(n-1), layer, 0.0, 0.0))} --Spawn Olmite with helmet
    stack_olmites[1].in_stack = true
    
    --Repeat n-1 times (spawn body armor olmites)
    for i = 2, n, 1 do
        stack_olmites[i] = get_entity(spawn_entity(ENT_TYPE.MONS_OLMITE_BODYARMORED, x, y+y_offset*(n-i), layer, 0.0, 0.0)) --Spawn Olmite with body armor
        stack_olmites[i].in_stack = true --Disables attack and stun, makes direction dependent on stack
        stack_olmites[i].on_top_uid = stack_olmites[i-1].uid --Set the olmite on top of this one to be the previous one spawned
        attach_entity(stack_olmites[i].uid, stack_olmites[i-1].uid) --Attach previous olmite to this one
    end
end