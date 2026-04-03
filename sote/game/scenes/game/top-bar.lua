local tabb = require "engine.table"
local ui = require "engine.ui"
local uit = require "game.ui-utils"
local pui = require "game.scenes.game.widgets.pop-ui-widgets"

local realm_utils = require "game.entities.realm".Realm
local province_utils = require "game.entities.province".Province
local warband_utils = require "game.entities.warband"

local politics_values = require "game.raws.values.politics"
local economy_values = require "game.raws.values.economy"

local tb = {}

local alerts_amount = 0

function tb.rect()
	return ui.rect(0, 0, uit.BASE_HEIGHT * 33 + alerts_amount * uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT * 2)
end

---@return boolean
function tb.mask(gam)
	local tr = tb.rect()
	---@type pop_id
	local character = WORLD.player_character
	if character == INVALID_ID then
		return true
	end
	local province = POP_PROVINCE(character)
	if province == INVALID_ID then
		return true
	end
	local realm = WORLD:player_realm()
	if realm == INVALID_ID then
		return true
	end
	return not ui.trigger(tr)
end

---@class (exact) TreasuryDisplayEffect
---@field reason ECONOMY_REASON
---@field amount number
---@field timer number

---@type TreasuryDisplayEffect[]
CURRENT_EFFECTS = {}
MAX_TREASURY_TIMER = 4.0
MIN_DELAY = 0.3


function HANDLE_EFFECTS()
	local counter = 0
	while WORLD.treasury_effects:length() > 0 do
		local temp = WORLD.treasury_effects:dequeue()
		---@type TreasuryDisplayEffect
		local new_effect = {
			reason = temp.reason,
			amount = temp.amount,
			timer = MAX_TREASURY_TIMER + counter * MIN_DELAY
		}
		table.insert(CURRENT_EFFECTS, new_effect)
		WORLD.old_treasury_effects:enqueue(temp)
		while WORLD.old_treasury_effects:length() > OPTIONS["treasury_ledger"] do
			WORLD.old_treasury_effects:dequeue()
		end
		counter = counter + 1
	end
end

---comment
---@param parent_rect Rect
function DRAW_EFFECTS(parent_rect)
	local new_rect = parent_rect:copy()
	for _, effect in pairs(CURRENT_EFFECTS) do
		if (effect.timer < MAX_TREASURY_TIMER) then
			local r, g, b, a = love.graphics.getColor()
			if effect.amount > 0 then
				love.graphics.setColor(1, 1, 0, (effect.timer) / MAX_TREASURY_TIMER)
			else
				love.graphics.setColor(1, 0, 0, (effect.timer) / MAX_TREASURY_TIMER)
			end

			new_rect.x = parent_rect.x
			new_rect.y = parent_rect.y +
			2 * uit.BASE_HEIGHT * (1 + 4 * (MAX_TREASURY_TIMER - effect.timer) / MAX_TREASURY_TIMER)
			ui.right_text(uit.to_fixed_point2(effect.amount) .. MONEY_SYMBOL, new_rect)

			new_rect.x = parent_rect.x - parent_rect.width
			ui.left_text(DATA.economy_reason_get_description(effect.reason), new_rect)
			love.graphics.setColor(r, g, b, a)
		end
	end
end

---@param dt number
function tb.update(dt)
	---@type integer[]
	EFFECTS_TO_REMOVE = {}
	for _, effect in pairs(CURRENT_EFFECTS) do
		effect.timer = effect.timer - dt
		if effect.timer < 0 then
			table.insert(EFFECTS_TO_REMOVE, _)
		end
	end

	for _, key in pairs(EFFECTS_TO_REMOVE) do
		table.remove(CURRENT_EFFECTS, key)
	end
end

---Draws the bar at the top of the screen (if a player realm has been selected...)
---@param gam table
function tb.draw(gam)
	local character = WORLD.player_character

	if character == INVALID_ID then
		return
	end

	local settlment = POP_PROVINCE(character)
	local province = POP_PROVINCE(character)

	local tr = tb.rect()
	ui.panel(tr)

	if ui.trigger(tr) then
		gam.click_callback = function() return end
	end

	-- portrait
	local portrait_rect = tr:subrect(0, 0, uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT * 2, "left", "up")
	require "game.scenes.game.widgets.inspector-redirect-buttons".icon_button_to_character(gam, character, portrait_rect,
		"I am " .. require "game.scenes.game.widgets.pop-ui-widgets".pop_tooltip(character))


	--- current character
	local layout = ui.layout_builder()
		:position(uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT)
		:horizontal()
		:build()

	local name_rect = layout:next(7 * uit.BASE_HEIGHT, uit.BASE_HEIGHT)
	if uit.text_button(NAME(character), name_rect) then
		gam.selected.character = character
		gam.inspector = "character"
	end

	local rect = layout:next(uit.BASE_HEIGHT * 5, uit.BASE_HEIGHT)
	if uit.text_button("", rect) then
		gam.inspector = "treasury-ledger"
		(require "game.scenes.game.inspector-treasury-ledger").current_tab = "Character"
	end

	uit.money_entry_icon(
		SAVINGS(character),
		rect,
		"My personal savings")

	-- food goods in player character inventory
	local food_amount = economy_values.available_use_case_from_inventory(character, CALORIES_USE_CASE)
	local food_in_inventory, food_size = "", 0
	if food_amount > 0 then
		DATA.for_each_use_weight_from_use_case(CALORIES_USE_CASE,function(item)
			local good = DATA.use_weight_get_trade_good(item)
			local count = DATA.pop_get_inventory(character,good)
			if count > 0 then
				food_size = food_size + count
				local weight = DATA.use_weight_get_weight(item)
				food_in_inventory = food_in_inventory .. "\n\t" .. DATA.trade_good_get_name(good)
				.. "\t" .. uit.to_fixed_point2(count) .. " at " .. uit.to_fixed_point2(weight) .. " calories"
				.. "\n\t\t=>\t" .. uit.to_fixed_point2(count*weight) .. "\t[" .. uit.to_fixed_point2(count*weight/food_amount*100) .. "%]"
			end
		end)
		food_in_inventory = "\nFood in my inventory: (" .. food_size .. ")" .. food_in_inventory
	end
	uit.sqrt_number_entry_icon(
		"sliced-bread.png",
		food_amount,
		layout:next(uit.BASE_HEIGHT * 4, uit.BASE_HEIGHT),
		"I have  " .. uit.to_fixed_point2(food_size) .. " units of goods that have a value of "
			.. uit.to_fixed_point2(food_amount) .. " calories."
			.. food_in_inventory)

	-- food goods in player party inventory for travel expenses
	local days_of_travel, party_food, party_supplies = 0,0,0
	local party_supplies_tooltip = "."
	local party = UNIT_OF(character)
	if party ~= INVALID_ID then
		party_supplies_tooltip = party_supplies_tooltip .. "\nFood in party inventory:"
		party_supplies = economy_values.get_supply_available(party)
		days_of_travel = economy_values.days_of_travel(party)
		DATA.for_each_use_weight_from_use_case(CALORIES_USE_CASE,function(item)
			local good = DATA.use_weight_get_trade_good(item)
			local count = DATA.estate_get_inventory(party,good)
			if count > 0 then
				party_food = party_food + count
				local weight = DATA.use_weight_get_weight(item)
				party_supplies_tooltip = party_supplies_tooltip .. "\n\t" .. DATA.trade_good_get_name(good)
					.. "\t" .. uit.to_fixed_point2(count) .. " at " .. uit.to_fixed_point2(weight) .. " calories"
					.. "\n\t\t=>\t" .. uit.to_fixed_point2(count*weight) .. "\t[" .. uit.to_fixed_point2(count*weight/party_supplies*100) .. "%]"
			end
		end)
		party_supplies_tooltip = " and a traveling cost of "
			.. uit.to_fixed_point2(warband_utils.daily_supply_consumption(party)) .. " calories per day"
			.. party_supplies_tooltip

		uit.balance_entry_icon(
			"horizon-road.png",
			days_of_travel,
			layout:next(uit.BASE_HEIGHT * 3, uit.BASE_HEIGHT),
			"My party can travel for " .. uit.to_fixed_point2(days_of_travel) .. " days from "
				.. uit.to_fixed_point2(party_food) .. " units of goods that have a value of "
				.. uit.to_fixed_point2(party_supplies) .. " calories"
				.. party_supplies_tooltip)
		require "game.scenes.game.widgets.inspector-redirect-buttons".text_button_to_party(
			gam,
			party,
			layout:next(uit.BASE_HEIGHT*6,uit.BASE_HEIGHT),
			"Inspect my party")
	else
		if uit.text_button(
			"Gather party",
			layout:next(uit.BASE_HEIGHT*9,uit.BASE_HEIGHT),
			"Gather my own party?")
		then
			require "game.raws.effects.military".gather_warband(character)
		end
	end


	-- local popularity
	if settlment ~= INVALID_ID then
		pui.render_realm_popularity(layout:next(uit.BASE_HEIGHT*3,uit.BASE_HEIGHT),character,PROVINCE_REALM(settlment))
	else

	end

	pui.render_basic_needs_satsifaction(
		layout:next(uit.BASE_HEIGHT * 3, uit.BASE_HEIGHT),
		character)

	-- COA + name
	local layout = ui.layout_builder()
		:position(uit.BASE_HEIGHT * 2, 0)
		:horizontal()
		:build()

	require "game.scenes.game.widgets.realm-name" (
		gam,
		LOCAL_REALM(character),
		layout:next(
			uit.BASE_HEIGHT * 7,
			uit.BASE_HEIGHT
		)
	)

	-- Treasury
	local trt = layout:next(uit.BASE_HEIGHT * 5, uit.BASE_HEIGHT)

	if uit.text_button("", trt) then
		gam.inspector = "treasury-ledger"
		(require "game.scenes.game.inspector-treasury-ledger").current_tab = "Treasury"
	end

	uit.money_entry_icon(
		DATA.realm_get_budget_treasury(LOCAL_REALM(character)),
		trt,
		"Realm treasury")

	HANDLE_EFFECTS()
	DRAW_EFFECTS(trt)

	-- Food
	local amount = economy_values.get_local_amount_of_use(POP_PROVINCE(character), CALORIES_USE_CASE)
	uit.sqrt_number_entry_icon(
		"noodles.png",
		amount,
		layout:next(uit.BASE_HEIGHT * 4, uit.BASE_HEIGHT),
		"Purchasable local calories")

	-- Technology
	local amount = realm_utils.get_education_efficiency(LOCAL_REALM(character))
	local tr = layout:next(uit.BASE_HEIGHT * 3, uit.BASE_HEIGHT)
	local trs =
	"Current ability to research new technologies. When it's under 100%, technologies will be slowly forgotten, when above 100% they will be researched. Controlled largely through treasury spending on research and education but in most states the bulk of the contribution will come from POPs in the realm instead."
	uit.generic_number_field("erlenmeyer.png", amount, tr, trs, uit.NUMBER_MODE.PERCENTAGE, uit.NAME_MODE.ICON)

	-- Happiness
	local amount = realm_utils.get_average_mood(LOCAL_REALM(character))
	local tr = layout:next(uit.BASE_HEIGHT * 3, uit.BASE_HEIGHT)
	local trs =
	"Average mood (happiness) of population in our realm. Happy pops contribute more voluntarily to our treasury, whereas unhappy ones contribute less."
	uit.balance_entry_icon("duality-mask.png", amount, tr, trs)

	-- Quality of life
	local amount = realm_utils.get_average_needs_satisfaction(LOCAL_REALM(character))
	local tr = layout:next(uit.BASE_HEIGHT * 3, uit.BASE_HEIGHT)
	local trs = "Average quality of life of population in our realm. Pops which do not starve do not die."
	uit.generic_number_field("duality-mask.png", amount, tr, trs, uit.NUMBER_MODE.PERCENTAGE, uit.NAME_MODE.ICON)

	-- POP
	local amount = realm_utils.get_total_population(LOCAL_REALM(character))
	local tr = layout:next(uit.BASE_HEIGHT * 3, uit.BASE_HEIGHT)
	local trs = "Current population of our realm."
	uit.data_entry_icon("minions.png", tostring(math.floor(amount)), tr, trs)

	-- Army size
	local amount = warband_utils.size(LEADER_OF_ESTATE(character))

	local tr = layout:next(uit.BASE_HEIGHT * 3, uit.BASE_HEIGHT)
	local trs = "Size of our realms armies."
	uit.data_entry_icon("barbute.png", tostring(math.floor(amount)), tr, trs)


	-- ALERTS
	---@class (exact) Alert
	---@field icon string
	---@field tooltip string

	---@type Alert[]
	local alerts = {}

	local race = F_RACE(character);

	if AGE_YEARS(character) > race.elder_age then
		table.insert(alerts, {
			["icon"] = "tombstone.png",
			["tooltip"] = "You have reached elder age age will make a death roll of " .. uit.to_fixed_point2((race.max_age - AGE_YEARS(character)) / (race.max_age - race.elder_age) * race.fecundity / 12 / 7).. "% each month. This chance increases each year you continue to live.",
		})
	end

	local min_food_satsfaction = 1

	for index = 1, MAX_NEED_SATISFACTION_POSITIONS_INDEX do
		local need = DATA.pop_get_need_satisfaction_need(character, index)
		if need ~= NEED.FOOD then
			break
		end

		local demanded = DATA.pop_get_need_satisfaction_demanded(character, index)
		local consumed = DATA.pop_get_need_satisfaction_consumed(character, index)

		local ratio = consumed / demanded

		if min_food_satsfaction > ratio then
			min_food_satsfaction = ratio
		end
	end

	if min_food_satsfaction < 0.2 then
		table.insert(alerts, {
			["icon"] = "sliced-bread.png",
			["tooltip"] = "You have not consumed enough food last month and survived a death roll of " .. math.max(1 /12 /7, (0.2 - min_food_satsfaction) / 0.2)
				.."%. Unless you consume at least 20% of each food need, you will make a death roll every month.",
		})
	end

	if province_utils.get_unemployment(POP_PROVINCE(character)) > 5 then
		table.insert(alerts, {
			["icon"] = "miner.png",
			["tooltip"] =
			"Unemployment is high. Consider construction of new buildings or investment into local economy.",
		})
	end

	if DATA.province_get_mood(POP_PROVINCE(character)) < 1 then
		table.insert(alerts, {
			["icon"] = "despair.png",
			["tooltip"] = "Our people are unhappy. Gift money to your population or raid other realms.",
		})
	end

	if DATA.pop_get_rank(character) == CHARACTER_RANK.CHIEF then
		if province_utils.get_infrastructure_efficiency(POP_TILE(character)) < 0.9 then
			table.insert(alerts, {
				["icon"] = "horizon-road.png",
				["tooltip"] =
				"Infrastructure efficiency is low. It might be a temporary effect or a sign of a low infrastructure budget.",
			})
		end

		if realm_utils.get_education_efficiency(REALM(character)) < 0.9 then
			table.insert(alerts, {
				["icon"] = "erlenmeyer.png",
				["tooltip"] =
				"Education efficiency is low. It might be a temporary effect or a sign of a low education budget.",
			})
		end
	end

	for _, alert in ipairs(alerts) do
		local rect = layout:next(uit.BASE_HEIGHT * 2, uit.BASE_HEIGHT * 2)

		local alert_rect = rect:copy():shrink(5)
		local old_style = ui.style.panel_outline
		ui.style.panel_outline = { ["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1 }
		ui.panel(alert_rect, uit.BASE_HEIGHT)
		ui.style.panel_outline = old_style
		love.graphics.setColor(0.8, 0, 0, 1)
		alert_rect:shrink(4)
		ui.image(ASSETS.icons[alert.icon], alert_rect)
		love.graphics.setColor(1, 1, 1, 1)
		ui.tooltip(alert.tooltip, rect)
	end

	alerts_amount = #alerts
end

return tb
