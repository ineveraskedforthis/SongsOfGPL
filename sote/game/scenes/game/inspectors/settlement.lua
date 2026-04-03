--- this file is dedicated to inspector of local settlement
--- when player enters the settlement, it stays over the central square of the screen


local ui = require "engine.ui"
local ut = require "game.ui-utils"
local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"

local inspector = {}

---@enum SETTLEMENT_TAB
local SETTLEMENT_TAB = {
	MARKET = 1,
	HIRE_WARRIORS = 2,
	ESTATE = 3,
	ACTIONS = 4
}

---@type SETTLEMENT_TAB
local selected_tab = SETTLEMENT_TAB.MARKET

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	return fs:subrect(ut.BASE_HEIGHT * 18, ut.BASE_HEIGHT * 2, fs.width - ut.BASE_HEIGHT * 18 - ut.BASE_HEIGHT * 15, fs.height - ut.BASE_HEIGHT * 2, "left", "up")
end

local function is_visible()
	---@type pop_id
	local player = WORLD.player_character
	if player == INVALID_ID then
		return false
	end
	local province = POP_PROVINCE(player)
	if province == INVALID_ID then
		return false
	end
	return true
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
	local tile_id = POP_TILE(player)
	local province = POP_PROVINCE(player)

	local base = ut.BASE_HEIGHT

	local header = rect:subrect(0, 0, rect.width, rect.height / 10, "left", "up")

	local data_entry = header:copy()
	data_entry.width = data_entry.width / 4
	data_entry.height = data_entry.height / 4

	ut.money_entry("Local wealth:", DATA.province_get_local_wealth(province), data_entry)
	data_entry.x = data_entry.x + data_entry.width
    ut.money_entry("Trade wealth:", DATA.province_get_trade_wealth(province), data_entry)
    data_entry.x = data_entry.x + data_entry.width

	local tabs = header:copy()
	tabs.y = tabs.y + header.height
	tabs.height = base

	local buttons = 10
	tabs.width = tabs.width / buttons

	if ut.text_button("Market", tabs, "Visit local market", nil, selected_tab == SETTLEMENT_TAB.MARKET) then
		selected_tab = SETTLEMENT_TAB.MARKET
	end
	tabs.x = tabs.x + tabs.width
	if ut.text_button("Warriors", tabs, "Hire local warriors", nil, selected_tab == SETTLEMENT_TAB.HIRE_WARRIORS) then
		selected_tab = SETTLEMENT_TAB.HIRE_WARRIORS
	end
	tabs.x = tabs.x + tabs.width
	if ut.text_button("Estate", tabs, "Manage local estate", nil, selected_tab == SETTLEMENT_TAB.ESTATE) then
		selected_tab = SETTLEMENT_TAB.ESTATE
	end
	tabs.x = tabs.x + tabs.width
	if ut.text_button("Actions", tabs, "Action", nil, selected_tab == SETTLEMENT_TAB.ACTIONS) then
		selected_tab = SETTLEMENT_TAB.ACTIONS
	end
	tabs.x = tabs.x + tabs.width
	local content_rect = rect:copy()
	content_rect.y = tabs.y + tabs.height
	content_rect.height = rect.y + rect.height - content_rect.y

	if selected_tab == SETTLEMENT_TAB.MARKET then
		require "game.scenes.game.widgets.market-extended"(province, content_rect, ut.BASE_HEIGHT)()
	end

	local local_estate = INVALID_ID
	DATA.for_each_ownership_from_owner(player, function (item)
		local estate = DATA.ownership_get_estate(item)
		local estate_tile = ESTATE_TILE(estate)
		if estate_tile == tile_id then
			local_estate = estate
		end
	end)

	if selected_tab == SETTLEMENT_TAB.ESTATE then
		require "game.scenes.game.widgets.estate-extended"(content_rect, local_estate)
	end
end

return inspector