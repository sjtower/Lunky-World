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