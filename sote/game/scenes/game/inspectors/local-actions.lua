local ui = require "engine.ui"
local ut = require "game.ui-utils"
local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"

local travel_effects = require "game.raws.effects.travel"
local military_effects = require "game.raws.effects.military"

local inspector = {}

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	return fs:subrect(ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 16, ut.BASE_HEIGHT * 9, "left", "up")
end

local function is_visible()
	---@type pop_id
	local player = WORLD.player_character
	if player == INVALID_ID then
		return false
	end

	local tile = POP_TILE(player)
	local province = POP_PROVINCE(player)

	if province == INVALID_ID then
		return false
	end
	if tile == INVALID_ID then
		return false
	end
	if tile == DATA.province_get_center(province) then
		return true
	end

	return false
end

---Returns whether or not clicks on the planet can be registered.
---@return boolean
function inspector.mask()

	if not is_visible() then
		return true
	end

	if ui.trigger(get_main_panel()) then
		return false
	else
		return true
	end
end

function inspector.draw(gamescene)
	if not is_visible() then
		return true
	end

    local rect = get_main_panel()
	ui.panel(rect)

	---@type pop_id
	local player = WORLD.player_character
	local province = POP_PROVINCE(player)

	local base = ut.BASE_HEIGHT

	local settlement_image_rect = rect:subrect(0, 0, base * 7, base * 7, "left", "up")
	local settlement_name_rect = rect:subrect(0, base * 7, base * 7, base * 2, "left", "up")
	local actions_rect = rect:subrect(base * 7, 0, base * 9, base * 9, "left", "up")

	settlement_image_rect:shrink(2)
	settlement_name_rect:shrink(2)
	actions_rect:shrink(2)

	ui.image(ASSETS.images.settlement, settlement_image_rect)
	ui.panel(settlement_image_rect, 0, true, false)

	ib.text_button_to_province_tile(gamescene, POP_TILE(player), settlement_name_rect, "")

	local action_rect = actions_rect:subrect(0, 0, actions_rect.width * 0.8, actions_rect.height / 9, "center", "up")

	if POP_PROVINCE(player) == INVALID_ID then
		if ut.text_button("Enter", action_rect, "Enter the settlement") then
			travel_effects.enter_settlement(player)
		end
	else
		if ut.text_button("Leave", action_rect, "Leave the settlement") then
			if LEADER_OF_ESTATE(player) == INVALID_ID then
				military_effects.gather_warband(player)
			end
			travel_effects.exit_settlement(player)
		end
	end

	if POP_PROVINCE(player) == INVALID_ID then
		action_rect.y = action_rect.y + action_rect.height
		if ut.text_button("Raid", action_rect, "Raid the local settlement") then
			military_effects.raid(player, false)
		end
	end

	-- TODO: add tribute/migration/conquest related actions
end

return inspector