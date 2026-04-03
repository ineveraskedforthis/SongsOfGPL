local re = {}

local ui = require "engine.ui"
local ut = require "game.ui-utils"
local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"
local put = require "game.entities.pop".POP
local pui = require "game.scenes.game.widgets.pop-ui-widgets"
local party_ui = require "game.scenes.game.widgets.party-ui-widgets"

local ev = require "game.raws.values.economy"
local ee = require "game.raws.effects.economy"

local strings = require "engine.string"

KEY_PRESS_MODIFIER = 1

local filter_unavailable = false
local good_case_toggle = false
local interaction_toggle = true
local good_list_state = nil
local case_list_state = nil

local civilian_toggle = true
local follower_toggle = true
local recruit_list_state = nil

local hire_toggle = true
local hire_index = 0
local unit_list_state = nil

---@alias InspectorPartyStatsTabs "TRVL"|"TRSR"|"CMBT"
---@type InspectorPartyStatsTabs
local stats_tab = "TRVL"

---@alias InspectorPartyInfoTabs "INV"|"HIR"|"UNT"
---@type InspectorPartyInfoTabs
local party_tab = "INV"

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	local panel = fs:subrect(ut.BASE_HEIGHT * 2, 0, ut.BASE_HEIGHT * 16, ut.BASE_HEIGHT * 25, "left", "down")
	return panel
end

---Returns whether or not clicks on the planet can be registered.
---@return boolean
function re.mask()
	if ui.trigger(get_main_panel()) then
		return false
	else
		return true
	end
end

---@enum PARTY_TAB
local PARTY_TAB = {
	UNITS = 1, -- active comander?
	RECRUIT = 1, -- recruiter?
	MANAGEMENT = 2 -- active leader?
}

---@type ESTATE_TAB
local selected_tab = PARTY_TAB.UNITS

local party_inventory_state = nil

---@param game GameScene
function re.draw(game)

	--- combining key presses for increments of 1, 2, 5, 10, 20, 50, and 100
	KEY_PRESS_MODIFIER = 1
	if ui.is_key_held("lshift") or ui.is_key_held("rshift") then
		KEY_PRESS_MODIFIER = KEY_PRESS_MODIFIER * 2
	end
	if ui.is_key_held("lctrl") or ui.is_key_held("rctrl") then
		KEY_PRESS_MODIFIER = KEY_PRESS_MODIFIER * 5
	end
	if ui.is_key_held("lalt") or ui.is_key_held("ralt") then
		KEY_PRESS_MODIFIER = KEY_PRESS_MODIFIER * 10
	end

	local ui_panel = get_main_panel()
	ui.panel(ui_panel)

	local layout = ui.layout_builder():position(ui_panel.x,ui_panel.y):vertical():build()

	-- header : inspector name and close button
	ib.render_inspector_header(game,layout:next(ui_panel.width,ut.BASE_HEIGHT),"Party View")

	local player_id = WORLD.player_character or INVALID_ID
	if player_id == INVALID_ID then
		interaction_toggle = true
	end
	---@cast player_id pop_id
	local party_id = game.selected.warband
	if party_id ~= nil and party_id ~= INVALID_ID and DCON.dcon_warband_is_valid(party_id - 1) then

		local tile_id = ESTATE_TILE(party_id)
		local province = TILE_PROVINCE(tile_id)
		local trade_wealth = DATA.province_get_trade_wealth(province)
		local party_savings = DATA.warband_get_treasury(party_id)
		local leader_id = require "game.entities.warband".active_leader(party_id)
		local recruiter_id = ESTATE_RECRUITER(party_id)

		-- interaction calculations
		local daily_consumption = require "game.entities.warband".daily_supply_consumption(party_id)
		local local_limit = 0
		if IN_SETTLEMENT(party_id) then
			local_limit = ev.get_local_amount_of_use(province,CALORIES_USE_CASE)
		end
		local inv_limit = ev.available_use_case_for_party(party_id,CALORIES_USE_CASE)
		local price = ev.get_local_price_of_use(province,CALORIES_USE_CASE)
		local buy_limit = DATA.warband_get_treasury(party_id) / price
		local sell_limit = DATA.province_get_trade_wealth(province) / price
		local to_trade = KEY_PRESS_MODIFIER*daily_consumption
		local to_buy = math.min(to_trade,local_limit,buy_limit)
		local to_sell = math.min(to_trade,inv_limit,sell_limit)
		local to_take = math.min(KEY_PRESS_MODIFIER, DATA.warband_get_treasury(party_id))
		local to_give = math.min(KEY_PRESS_MODIFIER, player_id~= INVALID_ID and SAVINGS(player_id) or 0)

		-- check player ability to interact with warband and set tooltips
		local can_give,can_take,can_buy,can_sell,can_hire,player_savings,party_savings = false,false,false,false,false,0,0
		local buy_tt,sell_tt,give_tt,take_tt = OBSERVER_BUTTON_TOOLTIP,OBSERVER_BUTTON_TOOLTIP,OBSERVER_BUTTON_TOOLTIP,OBSERVER_BUTTON_TOOLTIP
		if player_id ~= INVALID_ID then
			player_savings = SAVINGS(player_id)
			party_savings = ESTATE_SAVINGS(party_id)
			if leader_id == player_id or recruiter_id == player_id then
				can_give,can_take,can_hire = true,true,true
				give_tt = "Give " .. ut.to_fixed_point2(to_give) .. MONEY_SYMBOL .. " to " .. ESTATE_NAME(party_id)
				take_tt = "Take " .. ut.to_fixed_point2(to_take) .. MONEY_SYMBOL .. " from " .. ESTATE_NAME(party_id)
				if IN_SETTLEMENT(party_id) then
					if to_buy > 0 then
						can_buy = true
						buy_tt = "Buy " .. ut.to_fixed_point2(to_buy/daily_consumption) .. " days of supplies for "
							.. ut.to_fixed_point2(to_buy*price) .. MONEY_SYMBOL
					else
						buy_tt = "There is no food available for purchase!"
					end
					if to_sell > 0 then
						can_sell = true
						sell_tt = "Sell " .. ut.to_fixed_point2(to_sell/daily_consumption) .. " days of supplies for "
							.. ut.to_fixed_point2(to_sell*price) .. MONEY_SYMBOL
					else
						sell_tt = ESTATE_NAME(party_id) .. " has no food in inventory!"
					end
				else
					buy_tt = "You are not in a settlement!"
					sell_tt = buy_tt
				end
			elseif province == POP_PROVINCE(player_id) then
				can_give = true
				give_tt = "Give " .. ut.to_fixed_point2(to_give) .. MONEY_SYMBOL .. " to " .. ESTATE_NAME(party_id)
				take_tt = "You do not have permision to take from " .. ESTATE_NAME(party_id) .. " savings"
				buy_tt = "You do not have permision to spend from " .. ESTATE_NAME(party_id) .. " savings"
				sell_tt = "You do not have permision to sell " .. ESTATE_NAME(party_id) .. "'s supplies"
			else
				buy_tt = "You are not in the same province as " .. ESTATE_NAME(party_id)
				give_tt, take_tt = buy_tt, buy_tt
			end
		end

		-- top panel : portrait and general info

		local leader_rect = layout:next(ui_panel.width, ut.BASE_HEIGHT*5)

		party_ui.render_party_overview(game,leader_rect,party_id, function(title)
			local party_name = ESTATE_NAME(party_id)
			ui.panel(title,2,true)
			ui.text(party_name,title,"left","center")
			local status = DATA.warband_get_current_status(party_id)
			---@diagnostic disable-next-line
			---@cast status warband_status_id
			local party_tooltip = party_name .. " is currently "
				.. DATA.warband_status_get_action_string(status)
				.. " in " .. PROVINCE_NAME(province)
			ui.tooltip(party_tooltip,title)
		end)
        -- party location and leader local popularity or biome
        party_ui.render_location_buttons(game,
			leader_rect:subrect(
				0,ut.BASE_HEIGHT,
				leader_rect.width-(leader_rect.height-ut.BASE_HEIGHT),
				ut.BASE_HEIGHT,
				"right",
				"up"
			),party_id)
			--#endregion top

--#region mid
    -- middle panel : statistics
    local stats_tab_panel = layout:next(ui_panel.width,ut.BASE_HEIGHT*3)
    local stats_tab_layout = ui.layout_builder():position(stats_tab_panel.x,stats_tab_panel.y):vertical():build()

    local draw_width = ut.BASE_HEIGHT*3
    local border_panel = stats_tab_panel:subrect(0,0,stats_tab_panel.width,stats_tab_panel.height,"left","up")
    ui.panel(border_panel,2,true)

	local spacing = (border_panel.height-ut.BASE_HEIGHT*3)/2
	local offset = (border_panel.width-draw_width*5)/2
	local mid_layout = ui.layout_builder()
		:position(border_panel.x+offset,border_panel.y+spacing)
		:grid(6)
		:build()
	-- top row : treasury
	party_ui.render_morale(mid_layout:next(draw_width,ut.BASE_HEIGHT),party_id)
	party_ui.render_upkeep(mid_layout:next(draw_width,ut.BASE_HEIGHT),party_id)
	if ut.icon_button(ASSETS.icons["minus.png"],
		mid_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),
		"-"..ut.to_fixed_point2(to_take) .. MONEY_SYMBOL .. "\n" ..take_tt,
		can_take)
	then
		require "game.raws.effects.economy".add_party_savings(party_id,-to_take,ECONOMY_REASON.SIPHON)
		require "game.raws.effects.economy".add_pop_savings(player_id,to_take,ECONOMY_REASON.WARBAND)
	end
	party_ui.render_savings(mid_layout:next(draw_width*2-ut.BASE_HEIGHT*2,ut.BASE_HEIGHT),party_id)
	if ut.icon_button(ASSETS.icons["plus.png"],
		mid_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),
		"+"..ut.to_fixed_point2(to_give) .. MONEY_SYMBOL .. "\n" .. give_tt,
		can_give)
	then
		if leader_id == player_id then
			require "game.raws.effects.economy".add_party_savings(party_id,to_give,ECONOMY_REASON.DONATION)
			require "game.raws.effects.economy".add_pop_savings(player_id,-to_give,ECONOMY_REASON.WARBAND)
		else
			require "game.raws.effects.economy".gift_to_warband(party_id,player_id,to_give)
		end
	end
	local months_of_upkeep = DATA.warband_get_treasury(party_id)/DATA.warband_get_total_upkeep(party_id)
	ut.generic_number_field(
		"two-coins.png",
		months_of_upkeep,
		mid_layout:next(draw_width,ut.BASE_HEIGHT),
		ESTATE_NAME(party_id) .. " can afford to pay its troops for " .. ut.to_fixed_point2(months_of_upkeep) .. " months",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
	-- middle row : supplies
	party_ui.render_supply_capacity(mid_layout:next(draw_width,ut.BASE_HEIGHT),party_id)
	party_ui.render_daily_supply_consumption(mid_layout:next(draw_width,ut.BASE_HEIGHT),party_id)
	if ut.icon_button(ASSETS.icons["minus.png"],
		mid_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),
		"-"..ut.to_fixed_point2(to_sell) .. "\n " .. sell_tt,
		can_sell)
	then
		require "game.raws.effects.economy".party_sell_use(party_id,CALORIES_USE_CASE,to_sell)
	end
	party_ui.render_supply_available(mid_layout:next(draw_width*2-ut.BASE_HEIGHT*2,ut.BASE_HEIGHT),party_id)
	if ut.icon_button(ASSETS.icons["plus.png"],
		mid_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),
		"+"..ut.to_fixed_point2(to_buy) .. "\n" .. buy_tt,
		can_buy)
	then
		require "game.raws.effects.economy".party_buy_use(party_id,CALORIES_USE_CASE,to_buy)
	end
	party_ui.render_days_of_travel(mid_layout:next(draw_width,ut.BASE_HEIGHT),party_id)
	-- bottom row : travel target
	party_ui.render_travel_speed(mid_layout:next(draw_width,ut.BASE_HEIGHT),party_id)
	party_ui.render_target_buttons(game,mid_layout:next(draw_width*4,ut.BASE_HEIGHT),party_id)
--#endregion mid

--#region bot
    -- bot panel : tabs to units, hiring, and inventory
    local tabs_layout_rect = layout:next(ui_panel.width,ut.BASE_HEIGHT)
    local tabs_layout = ui.layout_builder()
        :position(tabs_layout_rect.x+tabs_layout_rect.width,tabs_layout_rect.y)
            :horizontal(true)
            :build()
    local tabs_panel_rect = layout:next(ui_panel.width, ui_panel.height-layout._pivot_y)

	local bottom_layout = ui.layout_builder()
		:position(tabs_panel_rect.x,tabs_panel_rect.y)
		:vertical()
		:build()
	local toggle_buttons = bottom_layout:next(tabs_panel_rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT)

    party_tab = ut.tabs(party_tab, tabs_layout,{
		{
			text = "INV",
			tooltip = "Party inventory",
			closure = function()
				ui.panel(tabs_panel_rect,2,true)
				-- MARKET/SELF option
				local good_use_tooltip = good_case_toggle and "List trade goods" or "List use cases"
				local inventory_tooltip = interaction_toggle and "Market interaction" or "Inventory interaction"
				local filter_tooltip = filter_unavailable and "Only show available" or "Show all"

				-- player interactions
				local can_give_buy,can_take_sell = false,false
				local give_buy_tooltip,take_sell_tooltip = OBSERVER_BUTTON_TOOLTIP,OBSERVER_BUTTON_TOOLTIP
				if player_id ~= INVALID_ID then
					good_use_tooltip = good_use_tooltip .. "\nClick to view "
						.. (good_case_toggle and "use cases" or "trade goods")
					inventory_tooltip = inventory_tooltip .. "\nClick to interact with "
						.. (interaction_toggle and "inventory" or "local market")
					-- interaction checks
					if interaction_toggle then
						if IN_SETTLEMENT(party_id) then
							can_give_buy = true
							if leader_id == player_id or recruiter_id == player_id then
								can_give_buy, can_take_sell = true, true
							end
						else
							give_buy_tooltip = ESTATE_NAME(party_id) .. " can only buy from market when in a settlement"
							take_sell_tooltip = ESTATE_NAME(party_id) .. " can only sell to market when in a settlement"
						end
					else
						if (IN_SETTLEMENT(party_id) and POP_PROVINCE(player_id) == province)
							or ESTATE_TILE(UNIT_OF(player_id)) == tile_id
						then
							can_give_buy = true
							if leader_id == player_id then
								can_take_sell = true
							else
								take_sell_tooltip = "I do not have permision to take from " .. ESTATE_NAME(party_id)
									.. "'s inventory"
							end
						else
							local base = "I need to be in the same location as " .. ESTATE_NAME(party_id)
							give_buy_tooltip = base .. " to gift goods"
							take_sell_tooltip = base .. " to take goods"
						end
					end
				end
				-- draw toggle buttons
				if ut.text_button(
					good_case_toggle and "Trade good" or "Use case",
					toggle_buttons:subrect(0,0,toggle_buttons.width/3,ut.BASE_HEIGHT,"left","up"),
					good_use_tooltip,
					true,
					not good_case_toggle)
				then
					good_case_toggle = not good_case_toggle
				end
				if ut.text_button(
					interaction_toggle and "Market" or "Player",
					toggle_buttons:subrect(0,0,toggle_buttons.width/3,ut.BASE_HEIGHT,"center","up"),
					inventory_tooltip,
					player_id~=INVALID_ID,
					not interaction_toggle)
				then
					interaction_toggle = not interaction_toggle
				end
				if ut.text_button(
					filter_unavailable and "Avail." or "All",
					toggle_buttons:subrect(0,0,toggle_buttons.width/3,ut.BASE_HEIGHT,"right","up"),
					filter_tooltip,
					true,
					not filter_unavailable)
				then
					filter_unavailable = not filter_unavailable
				end

				-- for each trade good or use case : on market or in an inventory filter
				local list_table = {}
				if good_case_toggle then
					DATA.for_each_trade_good(function (item)
						if not filter_unavailable or (DATA.warband_get_inventory(party_id,item)
							or DATA.province_get_local_storage(province,item) > 0
							or (player_id ~= INVALID_ID and DATA.pop_get_inventory(player_id,item) > 0))
						then
							table.insert(list_table, item)
						end
					end)
				else
					DATA.for_each_use_case(function (item)
						if not filter_unavailable or (ev.available_use_case_for_party(party_id,item) > 0
							or ev.get_local_amount_of_use(province,item) > 0
							or (player_id ~= INVALID_ID and ev.available_use_case_from_inventory(player_id,item) > 0))
						then
							table.insert(list_table, item)
						end
					end)
				end

				-- list of goods/cases
				local list_rect = bottom_layout:next(tabs_panel_rect.width, tabs_panel_rect.height-bottom_layout._pivot_y)
				-- icon w/tooltip,local/self price,market/self amount,sell/take,party inventory,buy/give
				local list_columns = {
					{
						header = ".",
						render_closure = function(rect, k, v)
							local icon, r, g, b, tooltip
							if good_case_toggle then
								icon = DATA.trade_good_get_icon(v)
								r = DATA.trade_good_get_r(v)
								g = DATA.trade_good_get_g(v)
								b = DATA.trade_good_get_b(v)
								tooltip = DATA.trade_good_get_name(v) .. "\n " .. DATA.trade_good_get_description(v) .. "\nUse cases"
								DATA.for_each_use_weight_from_trade_good(v, function (item)
									local case = DATA.use_weight_get_use_case(item)
									local weight = DATA.use_weight_get_weight(item)
									tooltip = tooltip .. "\n" .. (DATA.use_case_get_name(case) or case) .. "\t" .. ut.to_fixed_point2(weight)
								end)
							else
								icon = DATA.use_case_get_icon(v)
								r = DATA.use_case_get_r(v)
								g = DATA.use_case_get_g(v)
								b = DATA.use_case_get_b(v)
								tooltip = strings.title(DATA.use_case_get_name(v)) .. "\n " .. DATA.use_case_get_description(v) .. "\nTrade goods"
								DATA.for_each_use_weight_from_use_case(v, function (item)
									local good = DATA.use_weight_get_trade_good(item)
									local weight = DATA.use_weight_get_weight(item)
									tooltip = tooltip .. "\n - " .. (DATA.trade_good_get_name(good) or good) .. "\t" .. ut.to_fixed_point2(weight)
								end)
							end
							ut.render_icon(rect, icon, r, g, b, 1, true)
							ui.tooltip(tooltip, rect)
						end,
						width = 1,
						value = function(k, v)
							return good_case_toggle and DATA.trade_good_get_name(v) or DATA.use_case_get_name(v)
						end
					},
					{
						header = "price",
						render_closure = function(rect, k, v)
							local value = ev.get_local_price(province,v)
							local tooltip = "One unit of " .. DATA.trade_good_get_name(v) .. " cost "
								.. ut.to_fixed_point2(value) .. MONEY_SYMBOL .. " on "
								.. PROVINCE_NAME(province) .. "'s local market"
							local value, tooltip
							if good_case_toggle then
								value = ev.get_local_price(province,v)
								-- ??? player/leader belief of price?
							else
								value = ev.get_local_price_of_use(province,v)
								-- ??? player/leader belief of price of use case, buy & sell?, (pop,province) => cost / unit of use case?
							end
							ut.generic_number_field(
								"two-coins.png",
								value,
								rect,
								tooltip,
								ut.NUMBER_MODE.MONEY,
								ut.NAME_MODE.ICON)
						end,
						width = 4,
						value = function(k, v)
							return good_case_toggle and ev.get_local_price(province,v)
								or ev.get_local_price_of_use(province,v)
						end
					},
					{
						header = "avail.",
						render_closure = function(rect, k, v)
							local value = interaction_toggle
								and (good_case_toggle and DATA.province_get_local_storage(province,v)
									or ev.get_local_amount_of_use(province,v))
								or (good_case_toggle and DATA.pop_get_inventory(player_id,v)
										or ev.available_use_case_from_inventory(player_id,v))
							local tooltip = (interaction_toggle and "There are " or "I have ") .. ut.to_fixed_point2(value) .. " "
								.. (good_case_toggle and DATA.trade_good_get_name(v) or DATA.use_case_get_name(v))
								.. (interaction_toggle and " on market in " .. PROVINCE_NAME(province) or " in my inventory")

							ut.generic_number_field(
								"cubes.png",
								value,
								rect,
								tooltip,
								ut.NUMBER_MODE.SQRT,
								ut.NAME_MODE.ICON
							)
						end,
						width = 4,
						value = function(k, v)
							return interaction_toggle
								and (good_case_toggle and DATA.province_get_local_storage(province,v)
									or ev.get_local_amount_of_use(province,v))
								or (good_case_toggle and DATA.pop_get_inventory(player_id,v)
										or ev.available_use_case_from_inventory(player_id,v))
						end
					},
					{
						header = "<<",
						render_closure = function(rect, k, v)
							local value = KEY_PRESS_MODIFIER
							local tooltip = take_sell_tooltip
							-- limit by warband inventory
							local available = good_case_toggle and DATA.warband_get_inventory(party_id,v)
								or ev.available_use_case_for_party(party_id,v)
							-- limit by available trade wealth
							local price = good_case_toggle and ev.get_local_price(province,v)
								or ev.get_local_price_of_use(province,v)
							value = math.min(KEY_PRESS_MODIFIER,available,trade_wealth/price)

							local can_interact = can_take_sell
							if player_id ~= INVALID_ID then
								if available > 0 then
									tooltip = (interaction_toggle and "Sell " or "Move ") .. ut.to_fixed_point2(value)
										.. (interaction_toggle and (" for " .. ut.to_fixed_point2(value*price) .. MONEY_SYMBOL .. " ") or " ")
										.. (good_case_toggle and DATA.trade_good_get_name(v) or DATA.use_case_get_name(v))
										.. (interaction_toggle and " to market" or " to my inventory")
								else
									tooltip = ESTATE_NAME(party_id) .. " does not have any "
										.. (good_case_toggle and DATA.trade_good_get_name(v) or DATA.use_case_get_name(v))
										.. " in inventory"
									can_interact = false
								end
								if interaction_toggle and leader_id ~= player_id then
									tooltip = tooltip .. "\nI do not have permision to trade for " .. ESTATE_NAME(party_id)
									can_interact = false
								end
								if interaction_toggle and trade_wealth <= 0 then
									tooltip = tooltip .. "\n" .. PROVINCE_NAME(province) .. " does not have any wealth to buy with"
									can_interact = false
								end
							end
							if ut.icon_button(ASSETS.icons["fast-backward-button.png"],
								rect,
								tooltip,
								can_interact)
							then
								if interaction_toggle then
									if good_case_toggle then
										ee.party_sell_good(party_id,v,value)
									else
										ee.party_sell_use(party_id,v,value)
									end
								else
									if good_case_toggle then
										ee.pop_transfer_good_to_party(player_id,party_id,v,-value)
									else
										ee.pop_transfer_use_to_party(player_id,party_id,v,-value)
									end
								end
							end
						end,
						width = 1,
						value = function(k, v)
							return good_case_toggle and DATA.warband_get_inventory(party_id,v)
								or ev.available_use_case_for_party(party_id,v)
						end,
						clickable = true
					},
					{
						header = ">>",
						render_closure = function(rect, k, v)
							local value = KEY_PRESS_MODIFIER
							local tooltip = give_buy_tooltip
							-- limit by available or inventory
							local available = interaction_toggle
								and (good_case_toggle and DATA.province_get_local_storage(province,v)
									or ev.get_local_amount_of_use(province,v))
								or (good_case_toggle and DATA.pop_get_inventory(player_id,v)
									or ev.available_use_case_from_inventory(player_id,v))
							-- limit by available savings
							local price = good_case_toggle and ev.get_local_price(province,v)
								or ev.get_local_price_of_use(province,v)
							value = math.min(KEY_PRESS_MODIFIER,available)
							if interaction_toggle then
								value = math.min(value, party_savings/price)
							end
							local can_interact = can_give_buy
							if player_id ~= INVALID_ID then
								if available > 0 then
									tooltip = (interaction_toggle and "Buy " or "Move ") .. ut.to_fixed_point2(value)
										.. (interaction_toggle and (" for " .. ut.to_fixed_point2(value*price) .. MONEY_SYMBOL .. " ") or " ")
										.. (good_case_toggle and DATA.trade_good_get_name(v) or DATA.use_case_get_name(v))
										.. (interaction_toggle and " from market" or " from my inventory")
								else
									tooltip = (interaction_toggle and PROVINCE_NAME(province) .. " does not have any " or "I do not have any ")
										.. (good_case_toggle and DATA.trade_good_get_name(v) or DATA.use_case_get_name(v))
										.. (interaction_toggle and " on market" or " in inventory")
									can_interact = false
								end
								if interaction_toggle and leader_id ~= player_id then
									tooltip = tooltip .. "\nI do not have permision to trade for " .. ESTATE_NAME(party_id)
									can_interact = false
								end
								if interaction_toggle and party_savings <= 0 then
									tooltip = tooltip .. "\n" .. ESTATE_NAME(party_id) .. " does not have any wealth to buy with"
										can_interact = false
								end
							end
							if ut.icon_button(ASSETS.icons["fast-forward-button.png"],
								rect,
								tooltip,
								can_interact)
							then
								if interaction_toggle then
									if good_case_toggle then
										ee.party_buy_good(party_id,v,value)
									else
										ee.party_buy_use(party_id,v,value)
									end
								else
									if good_case_toggle then
										ee.pop_transfer_good_to_party(player_id,party_id,v,value)
									else
										ee.pop_transfer_use_to_party(player_id,party_id,v,value)
									end
								end
							end
						end,
						width = 1,
						value = function(k, v)
							return good_case_toggle and DATA.warband_get_inventory(party_id,v)
								or ev.available_use_case_for_party(party_id,v)
						end,
						clickable = true
					},
					{
						header = "amount",
						render_closure = function(rect, k, v)
							local value, tooltip
							if good_case_toggle then
								value = DATA.warband_get_inventory(party_id,v)
								tooltip = ESTATE_NAME(party_id) .. " has " .. ut.to_fixed_point2(value)
									.. " units of " .. DATA.trade_good_get_name(v) .. " in inventory"
							else
								value = ev.available_use_case_for_party(party_id,v)
								tooltip = ESTATE_NAME(party_id) .. " has " .. ut.to_fixed_point2(value)
									.. " units of " .. DATA.use_case_get_name(v) .. " in inventory"
							end
							ut.generic_number_field(
								"cardboard-box.png",
								value,
								rect,
								tooltip,
								ut.NUMBER_MODE.SQRT,
								ut.NAME_MODE.ICON
							)
						end,
						width = 4,
						value = function(k, v)
							return good_case_toggle and DATA.warband_get_inventory(party_id,v)
								or ev.available_use_case_for_party(party_id,v)
						end
					},
				}
				if good_case_toggle then
					good_list_state = require "game.scenes.game.widgets.list-widget"(
						list_rect,
						list_table,
						list_columns,
						good_list_state)()
				else
					case_list_state = require "game.scenes.game.widgets.list-widget"(
						list_rect,
						list_table,
						list_columns,
						case_list_state)()
				end
			end
		},
		{
			text = "UNT",
			tooltip = "Party Inventory",
			closure = function()
				ui.panel(tabs_panel_rect,2,true)

				-- toggles to filter civilian and follower
				local warrior_tooltip = civilian_toggle and "Displaying warriors\nClick to hide!"
				or "Not including warriors units\nClick to show!"
				local civilian_tooltip = civilian_toggle and "Displaying civilians\nClick to hide!"
					or "Not including civilian units\nClick to show!"
				local follower_tooltip = follower_toggle and "Displaying followers\nClick to hide!"
					or "Not including follower units\nClick to show!"

				-- filter unit list
				local list_table = {}
				DATA.for_each_warband_unit_from_warband(party_id, function (item)
					local unit = DATA.warband_unit_get_unit(item)
					if (civilian_toggle or UNIT_TYPE_OF(unit) ~= UNIT_TYPE.CIVILIAN)
						and (follower_toggle or UNIT_TYPE_OF(unit) ~= UNIT_TYPE.FOLLOWER)
					then
						table.insert(list_table, item)
					end
				end)

				if ut.text_button(
					civilian_toggle and "Civilians" or "No civilians",
					toggle_buttons:subrect(0,0,toggle_buttons.width/2,ut.BASE_HEIGHT,"left","up"),
					civilian_tooltip,
					true,
					civilian_toggle)
				then
					civilian_toggle = not civilian_toggle
				end
				if ut.text_button(
					follower_toggle and "Followers" or "No followers",
					toggle_buttons:subrect(0,0,toggle_buttons.width/2,ut.BASE_HEIGHT,"right","up"),
					follower_tooltip,
					true,
					follower_toggle)
				then
					follower_toggle = not follower_toggle
				end

				-- list of goods/cases
				local list_rect = bottom_layout:next(tabs_panel_rect.width, tabs_panel_rect.height-bottom_layout._pivot_y)
				-- icon w/tooltip,local/self price,market/self amount,sell/take,party inventory,buy/give
				local list_columns = {
					{
						header = ".",
						render_closure = function(rect, k, v)
							ib.icon_button_to_character(game,v,rect)
								--, strings.title(DATA.unit_type_get_name(UNIT_TYPE_OF(v))
								--.. " " .. pui.pop_tooltip(v)))
						end,
						width = 1,
						value = function(k, v)
							return NAME(v)
						end,
						clickable = true
					},
					{
						header = "spot",
						render_closure = function(rect, k, v)
							pui.render_spotting(rect,v)
						end,
						width = 3,
						value = function(k, v)
							return put.get_spotting(v)
						end
					},
					{
						header = "vis",
						render_closure = function(rect, k, v)
							pui.render_visibility(rect,v)
						end,
						width = 3,
						value = function(k, v)
							return put.get_visibility(v)
						end
					},
					{
						header = "carry",
						render_closure = function(rect, k, v)
							pui.render_supply_capacity(rect,v)
						end,
						width = 3,
						value = function(k, v)
							return put.get_supply_capacity(v)
						end
					},
					{
						header = "speed",
						render_closure = function(rect, k, v)
							pui.render_speed(rect,v)
						end,
						width = 3,
						value = function(k, v)
							return put.get_speed(v).base
						end
					},
					{
						header = "x",
						render_closure = function(rect, k, v)
							local tooltip = OBSERVER_BUTTON_TOOLTIP
							local can_fire = false
							local unit_type = UNIT_TYPE_OF(v)
							if player_id ~= INVALID_ID then
								if v == player_id then
									if player_id == ESTATE_LEADER(party_id) then
										tooltip = "I cannot quit my personal party!"
									else
										tooltip = "Quit warband?"
										can_fire = true
									end
								elseif not IN_SETTLEMENT(party_id) and unit_type == UNIT_TYPE.FOLLOWER then
									tooltip = "Cannot oust followers outside settlements"
								elseif IS_DEPENDENT(v) then
									local parent = PARENT(v)
									tooltip = "Cannot oust " .. NAME(v).. " as " .. HESHE(v)
										.. (player_id == parent and " is my dependent" or (" is a dependent of " .. NAME(parent)))
								elseif player_id == leader_id or player_id == recruiter_id then
									tooltip = (unit_type == UNIT_TYPE.FOLLOWER and "Oust " or "Unrecruit ")
										.. NAME(v) .. "?"
									can_fire = true
								else
									tooltip = "I do not have permision to remove units from " .. ESTATE_NAME(party_id)
								end
							end
							if ut.icon_button(
								unit_type == UNIT_TYPE.FOLLOWER and ASSETS.icons["exit-door.png"]
									or ASSETS.icons["cancel.png"],
								rect,
								tooltip,
								can_fire)
							then
								require "game.raws.effects.demography".unrecruit(v)
							end
						end,
						width = 1,
						value = function(k, v)
							return RANK(v)
						end,
						clickable = true
					},
				}
				unit_list_state = require "game.scenes.game.widgets.list-widget"(
					list_rect,
					list_table,
					list_columns,
					unit_list_state)()
			end
		},
		{
			text = "HIR",
			tooltip = "Hire units",
			closure = function()
				ui.panel(tabs_panel_rect,2,true)

				-- toggles to swap between hiring as a warrior or civilian
				if ut.text_button(
					hire_toggle and "Warriors" or "Civilians",
					toggle_buttons:subrect(0,0,toggle_buttons.width/2,ut.BASE_HEIGHT,"left","up"),
					hire_toggle and "Hiring as warriors\nClick to change to civilans" or "Hiring as civlians\nClick to change to warriors",
					can_hire,
					not hire_toggle)
				then
					hire_toggle = not hire_toggle
				end

				local list_rect = bottom_layout:next(tabs_panel_rect.width, tabs_panel_rect.height-bottom_layout._pivot_y)

				if leader_id ~= player_id or recruiter_id ~= player_id then
					ui.text("No permission to hire units for " .. ESTATE_NAME(party_id), list_rect, "center", "center")
					return
				end
				local province = POP_PROVINCE(ESTATE_RECRUITER(party_id))
				if province == INVALID_ID then
					ui.text("Can't hire units outside of settlement", list_rect, "center", "center")
					return
				end

				local unemployed_pops
				unemployed_pops = require "game.raws.values.demography".unemployed_pops(tile_id)
				hire_index = ut.scrollview(
					list_rect,
					function(i, rect)
						local unit_type = hire_toggle and UNIT_TYPE.WARRIOR or UNIT_TYPE.CIVILIAN
						local base_price = DATA.unit_type_get_base_cost(unit_type)
						local hire_price = base_price * 24 -- 2 years wages, warriors 12, civilians 6
						local can_hire_pop = can_hire and party_savings > hire_price

						local portrait_rect = rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT*3,"left","up")
						local info_width = rect.width-ut.BASE_HEIGHT*3
						local name_rect = rect:subrect(0,0,info_width,ut.BASE_HEIGHT,"right","up")
						local unit_rect = rect:subrect(0,0,info_width,ut.BASE_HEIGHT,"right","center")
						local hire_rect = rect:subrect(0,0,info_width,ut.BASE_HEIGHT,"right","down")

						ib.render_portrait_with_overlay(game, portrait_rect, unemployed_pops[i], pui.pop_tooltip(unemployed_pops[i]))
						party_ui.render_hire_size(name_rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"left","center"),unemployed_pops[i])
						party_ui.render_hire_spotting(name_rect:subrect(-info_width/8,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"center","center"),unemployed_pops[i])
						party_ui.render_hire_visibility(name_rect:subrect(info_width/8,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"center","center"),unemployed_pops[i])
						party_ui.render_hire_hauling(name_rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"right","center"),unemployed_pops[i])
						if hire_toggle then
							pui.render_health(unit_rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"left","center"),unemployed_pops[i])
							pui.render_armor(unit_rect:subrect(-info_width/8,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"center","center"),unemployed_pops[i])
							pui.render_attack(unit_rect:subrect(info_width/8,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"center","center"),unemployed_pops[i])
						else -- TODO figure out what to put for civilian stats
							--pui.render_spotting(unit_rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"left","center"),unemployed_pops[i])
							--pui.render_visibility(unit_rect:subrect(-info_width/8,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"center","center"),unemployed_pops[i])
							--pui.render_supply_capacity(unit_rect:subrect(info_width/8,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"center","center"),unemployed_pops[i])
						end
						party_ui.render_hire_speed(unit_rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"right","center"),unemployed_pops[i])
						if ut.text_button(
							"Hire for " .. tostring(hire_price) .. MONEY_SYMBOL
								.. " (" .. tostring(base_price) .. MONEY_SYMBOL .. " monthly)",
							hire_rect,
							can_hire_pop and ("Cost: " .. tostring(hire_price) .. MONEY_SYMBOL .. "\nUpkeep: " .. tostring(base_price) .. MONEY_SYMBOL .. ")")
								or (ESTATE_NAME(party_id) .. " does not have enough wealth to hire " .. NAME(unemployed_pops[i])),
							can_hire_pop
						) then
							require "game.raws.effects.demography".recruit(unemployed_pops[i], party_id, unit_type)
							ee.add_party_savings(
								party_id,
								-hire_price,
								ECONOMY_REASON.LOYALTY_GIFT)
							ee.add_pop_savings(
								unemployed_pops[i],
								hire_price,
								ECONOMY_REASON.WARBAND)
						end
					end,
					ut.BASE_HEIGHT*3,
					#unemployed_pops,
					UI_STYLE.slider_width,
					hire_index
				)
			end
		},
	}, 1, ut.BASE_HEIGHT * 3)
--#endregion bot_panel
--party_inventory_state = require "game.scenes.game.widgets.party-inventory-list"(game, management_rect, party_id, party_inventory_state, nil, true)()
else
	---@diagnostic disable-next-line
		game.selected.warband = INVALID_ID
	end
end

return re