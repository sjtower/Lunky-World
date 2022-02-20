local sound = require('play_sound')
local clear_embeds = require('clear_embeds')
local death_blocks = require("Modules.JawnGC.death_blocks")

define_tile_code("quillback_jump_switch")
define_tile_code("quillback_stun_switch")
define_tile_code("switchable_quillback")
define_tile_code("infinite_quillback")

local dwelling4 = {
    identifier = "dwelling4",
    title = "Dwelling 4: Roll Up",
    theme = THEME.DWELLING,
    width = 6,
    height = 4,
    file_name = "dwell-4.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local invincible_quilliams = {}
local quilliams = {}
local qb_jump_switches = {};
local qb_stun_switches = {};

dwelling4.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    death_blocks.set_ent_type(ENT_TYPE.FLOOR_BORDERTILE)
    death_blocks.activate(level_state)

    -- Creates a Quilliam that will stun or jump when with a "quillback switch".
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        clear_embeds.perform_block_without_embeds(function()        
            local quilliam = spawn_entity(ENT_TYPE.MONS_CAVEMAN_BOSS, x, y, layer, 0, 0)
            quilliam = get_entity(quilliam)
            quilliams[#quilliams + 1] = quilliam
            quilliam.color = Color:red()
            quilliam.flags = clr_flag(quilliam.flags, ENT_FLAG.FACING_LEFT)
            quilliam.flags = set_flag(quilliam.flags, ENT_FLAG.TAKE_NO_DAMAGE)
            -- quilliam.health = 800
        end)
        return true
    end, "switchable_quillback")

    -- Creates an invincible Quilliam that always rolls
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        clear_embeds.perform_block_without_embeds(function()        
            local quilliam = spawn_entity(ENT_TYPE.MONS_CAVEMAN_BOSS, x, y, layer, 0, 0)
            quilliam = get_entity(quilliam)
            invincible_quilliams[#invincible_quilliams + 1] = quilliam
            quilliam.color = Color:black()
            quilliam.flags = clr_flag(quilliam.flags, ENT_FLAG.FACING_LEFT)
            quilliam.flags = set_flag(quilliam.flags, ENT_FLAG.TAKE_NO_DAMAGE)
        end)
        return true
    end, "infinite_quillback")

    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        local switch = get_entity(switch_id)
        switch.color = Color:white()
        qb_jump_switches[#qb_jump_switches + 1] = switch
        return true
    end, "quillback_jump_switch")

    local has_quilliam_jumped = false
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, qb_jump_switch in ipairs(qb_jump_switches) do
            if not qb_jump_switch then return end
            if qb_jump_switch.timer > 10 and has_quilliam_jumped then
                has_quilliam_jumped = false
                qb_jump_switch.timer = 0
            end
            if qb_jump_switch.timer > 0 and not has_quilliam_jumped then
                has_quilliam_jumped = true
                for _, quilliam in ipairs(quilliams) do
                    quilliam:damage(qb_jump_switch.uid, 0, 0, 0, .2, 0)
                end
            end
        end
    end, ON.FRAME)

    
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        local switch = get_entity(switch_id)
        switch.color = Color:teal()
        qb_stun_switches[#qb_stun_switches + 1] = switch
        return true
    end, "quillback_stun_switch")

    local has_quilliam_stunned = false
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, qb_stun_switch in ipairs(qb_stun_switches) do
            if not qb_stun_switch then return end
            if qb_stun_switch.timer > 10 and has_quilliam_stunned then
                has_quilliam_stunned = false
                qb_stun_switch.timer = 0
            end
            if qb_stun_switch.timer > 0 and not has_quilliam_stunned then
                has_quilliam_stunned = true
                for _, quilliam in ipairs(quilliams) do
                    quilliam.flags = set_flag(quilliam.flags, ENT_FLAG.STUNNABLE)
                    quilliam.flags = clr_flag(quilliam.flags, ENT_FLAG.TAKE_NO_DAMAGE)

                    quilliam:damage(qb_stun_switch.uid, 0, 0, 30, 0, 0)
                end
            end
        end
    end, ON.FRAME)

    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, quilliam in ipairs(quilliams) do
            -- if quilliam.seen_player then
                quilliam.move_state = 10
            -- end
        end
        for _, quilliam in ipairs(invincible_quilliams) do
                quilliam.move_state = 10
        end
    end, ON.FRAME)

end

dwelling4.unload_level = function()
    if not level_state.loaded then return end

    qb_stun_switches = {};
    qb_jump_switches = {};
    invincible_quilliams = {}
    quilliams = {}

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling4
