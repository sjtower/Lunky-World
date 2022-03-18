local sound = require('play_sound')
local clear_embeds = require('clear_embeds')

define_tile_code("quillback_jump_switch")
define_tile_code("switchable_quillback")

local dwelling5 = {
    identifier = "dwelling5",
    title = "Dwelling 5: Roll Out",
    theme = THEME.DWELLING,
    width = 8,
    height = 3,
    file_name = "dwell-5.lvl",
    world = 1,
}

local level_state = {
    loaded = false,
    callbacks = {},
}

local quilliams = {}
local qb_jump_switches = {};

local function quilliam_jump(height) 
    for _, q in ipairs(quilliams) do
        q:damage(q.uid, 0, 0, 0, height, 0)
    end
end

dwelling5.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

    level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

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

    define_tile_code("quillback_jump_switch")
    local has_quilliam_jumped = false
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local switch_id = spawn_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
        local switch = get_entity(switch_id)
        switch.color = Color:green()
        qb_jump_switches[#qb_jump_switches + 1] = switch
        local timer = 1
        local sound = get_sound(VANILLA_SOUND.ENEMIES_CAVEMAN_TRIGGER)
        set_on_damage(switch_id, function(self)
            if self.timer > 0 then return end
                if not has_quilliam_jumped then
                    self.timer = timer
                    self.animation_frame = self.animation_frame == 86 and 96 or 86
                    has_quilliam_jumped = true
                    quilliam_jump(.2)
                    sound:play()
                end
            self.animation_frame = self.animation_frame == 86 and 96 or 86
            has_quilliam_jumped = false
            self.timer = 0
        end)
    end, "quillback_jump_switch")
       
    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        for _, quilliam in ipairs(quilliams) do
            -- if quilliam.seen_player then
                quilliam.move_state = 10
            -- end
        end
    end, ON.FRAME)
    
    toast(dwelling5.title)
end

dwelling5.unload_level = function()
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

return dwelling5
