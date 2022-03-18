local death_blocks = require("Modules.JawnGC.death_blocks")
local clear_embeds = require('clear_embeds')

define_tile_code("quillback_jump_switch")
define_tile_code("switchable_quillback")

local dwelling6 = {
    identifier = "dwelling6",
    title = "Dwelling 6: They see me Rollin'",
    theme = THEME.DWELLING,
    width = 4,
    height = 4,
    file_name = "dwell-6.lvl",
    world = 1,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local quilliams = {}
local qb_jump_switches = {};

dwelling6.load_level = function()
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

       
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, quilliam in ipairs(quilliams) do
            -- if quilliam.seen_player then
                quilliam.move_state = 10
            -- end
        end
    end, ON.FRAME)

    toast(dwelling6.title)
end

dwelling6.unload_level = function()
    if not level_state.loaded then return end

    qb_jump_switches = {};
    quilliams = {}

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _,callback in ipairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return dwelling6
