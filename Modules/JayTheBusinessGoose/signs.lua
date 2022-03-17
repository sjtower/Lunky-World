local button_prompts = require("ButtonPrompts/button_prompts")

local signs = {}

-- TODO test
local function handle_sign_toasts(sign_texts)
    if #players < 1 then return end
    local player = players[1]

	-- Show a toast when pressing the door button on signs.
    if player:is_button_pressed(BUTTON.DOOR) then
        -- print("door pressed")
        for i, sign in pairs(signs) do
            if player.layer == sign.layer then
                -- print(distance(player.uid, sign.sign.uid))
                if distance(player.uid, sign.uid) <= 0.5
                then
                    toast(sign_texts[i])
                end
            end
        end
    end
end

local function activate(level_state, sign_texts)

    button_prompts.activate()

    define_tile_code("sign")
    level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
        local sign_uid = spawn_entity(ENT_TYPE.ITEM_SPEEDRUN_SIGN, x, y, layer, 0, 0)
        local sign = get_entity(sign_uid)
        sign.flags = clr_flag(sign.flags, ENT_FLAG.ENABLE_BUTTON_PROMPT)
        signs[#signs + 1] = sign
        button_prompts.spawn_button_prompt(button_prompts.PROMPT_TYPE.VIEW, x, y, layer)
        return true
    end, "sign")

    level_state.callbacks[#level_state.callbacks+1] = set_callback(function()
        handle_sign_toasts(sign_texts)
    end, ON.FRAME)
end

local function deactivate()
    button_prompts.deactivate()
    signs = {}
end

return {
    activate = activate,
    deactivate = deactivate,
}