local tabb = require "engine.table"

local ut = require "game.ui-utils"

local ev = require "game.raws.values.economy"
local et = require "game.raws.triggers.economy"

local message_effects = require "game.raws.effects.messages"

local pop_utils = require "game.entities.pop".POP
local province_utils = require "game.entities.province".Province
local party_utils = require "game.entities.warband"

local EconomicEffects = {}

--- consumes `days` worth amount of supplies
--- returns ratio consumed / desired
---@param estate estate_id
---@param days number
---@return number
function EconomicEffects.consume_supplies(estate, days)
	local daily_consumption = party_utils.daily_supply_consumption(estate)
	local consumption = days * daily_consumption

	local consumed = EconomicEffects.consume_use_case_for_estate(estate, CALORIES_USE_CASE, consumption)

	-- give some wiggle room for floats
	if consumption == 0 then
		return 1
	end
	return consumed / consumption
end

---Change realm treasury and display effects to player
---@param realm Realm
---@param x number
---@param reason ECONOMY_REASON
function EconomicEffects.change_treasury(realm, x, reason)
	local fat_realm = DATA.fatten_realm(realm)
	fat_realm.budget_treasury = fat_realm.budget_treasury + x

	if reason == ECONOMY_REASON.TAX and x > 0 then
		fat_realm.budget_tax_collected_this_year = fat_realm.budget_tax_collected_this_year + x
	end

	DATA.realm_inc_budget_treasury_change_by_category(realm, reason, x)
	EconomicEffects.display_treasury_change(realm, x, reason)
end

---Register budget incomes and display them
---@param realm Realm
---@param x number
---@param reason ECONOMY_REASON
function EconomicEffects.register_income(realm, x, reason)
	local fat_realm = DATA.fatten_realm(realm)
	fat_realm.budget_change = fat_realm.budget_change + x

	if reason == ECONOMY_REASON.TAX and x > 0 then
		fat_realm.budget_tax_collected_this_year = fat_realm.budget_tax_collected_this_year + x
	end

	DATA.realm_inc_budget_income_by_category(realm, reason, x)
	EconomicEffects.display_treasury_change(realm, x, reason)
end

---Register budget spendings and display them
---DOES NOT ACTUALLY SPENDS MONEY
---@param realm Realm
---@param x number
---@param reason ECONOMY_REASON
function EconomicEffects.register_spendings(realm, x, reason)
	DATA.realm_inc_budget_spending_by_category(realm, reason, x)
	EconomicEffects.display_treasury_change(realm, -x, reason)
end

---Change pop savings and display effects to player
---@param pop pop_id
---@param x number
---@param reason ECONOMY_REASON
function EconomicEffects.add_pop_savings(pop, x, reason)
	local savings = DATA.pop_get_savings(pop)

	if DATA.pop_get_savings(pop) + x < 0 then
		print("Attempt to reduce savings below zero. Probably a rounding error? Preventing it anyway.", savings, x)
		-- print(debug.traceback())
		x = -savings
	end

	DATA.pop_inc_savings(pop, x)

	if DATA.pop_get_savings(pop) ~= DATA.pop_get_savings(pop) then
		error("BAD POP SAVINGS INCREASE: " .. tostring(x) .. " " .. reason)
	end

	if math.abs(x) > 0 then
		EconomicEffects.display_character_savings_change(pop, x, reason)
	end
end

---Change party savings
---@param party estate_id
---@param x number
---@param reason ECONOMY_REASON
function EconomicEffects.add_party_savings(party, x, reason)
	local savings = DATA.estate_get_savings(party)

	if savings + x < 0 then
		print("Attempt to reduce savings below zero. Probably a rounding error? Preventing it anyway.", savings, x)
		-- print(debug.traceback())
		x = -savings
	end

	DATA.estate_inc_savings(party, x)

	if DATA.estate_get_savings(party) ~= DATA.estate_get_savings(party) then
		error("BAD POP SAVINGS INCREASE: " .. tostring(x) .. " " .. reason)
	end
end

function EconomicEffects.display_character_savings_change(pop, x, reason)
	if WORLD.player_character == pop then
		WORLD:emit_treasury_change_effect(x, reason, true)
	end
end

function EconomicEffects.display_treasury_change(realm, x, reason)
	if WORLD:does_player_control_realm(realm) then
		WORLD:emit_treasury_change_effect(x, reason)
	end
end

---comment
---@param realm Realm
---@param x number
function EconomicEffects.set_education_budget(realm, x)
	DATA.realm_set_budget_ratio(realm, BUDGET_CATEGORY.EDUCATION, x)
end

---@param realm Realm
---@param x number
function EconomicEffects.set_court_budget(realm, x)
	DATA.realm_set_budget_ratio(realm, BUDGET_CATEGORY.COURT, x)
end

---@param realm Realm
---@param x number
function EconomicEffects.set_infrastructure_budget(realm, x)
	DATA.realm_set_budget_ratio(realm, BUDGET_CATEGORY.INFRASTRUCTURE, x)
end

---@param realm Realm
---@param x number
function EconomicEffects.set_military_budget(realm, x)
	DATA.realm_set_budget_ratio(realm, BUDGET_CATEGORY.MILITARY, x)
end

---comment
---@param realm realm_id
---@param category BUDGET_CATEGORY
---@param x number
function EconomicEffects.set_budget(realm, category, x)
	DATA.realm_set_budget_ratio(realm, category, x)
end

---Directly inject money from treasury to budget category
---@param realm Realm
---@param category BUDGET_CATEGORY
---@param x number
---@param reason ECONOMY_REASON
function EconomicEffects.direct_investment(realm, category, x, reason)
	EconomicEffects.change_treasury(realm, -x, reason)
	DATA.realm_inc_budget_budget(realm, category, x)
end

--- Directly injects money to province infrastructure
---@param realm Realm
---@param province province_id
---@param x number
function EconomicEffects.direct_investment_infrastructure(realm, province, x)
	EconomicEffects.change_treasury(realm, -x, ECONOMY_REASON.INFRASTRUCTURE)
	local current = DATA.province_get_infrastructure_investment(province)
	DATA.province_set_infrastructure_investment(province, current + x)
end

---commenting
---@param province province_id
---@param x number
---@param reason ECONOMY_REASON
function EconomicEffects.change_local_wealth(province, x, reason)
	local current = DATA.province_get_local_wealth(province)

	if current ~= current or x ~= x
	then
		error("NAN LOCAL WEALTH CHANGE"
			.. "\n province.name: "
			.. tostring(DATA.province_get_name(province))
			.. "\n x: "
			.. tostring(x)
			.. "\n reason: "
			.. tostring(reason)
			.. "\n province.local_wealth: "
			.. tostring(current)
		)
	end

	DATA.province_set_local_wealth(province, current + x)
end

---comment
---@param estate estate_id
---@param pop POP
function EconomicEffects.set_ownership(estate, pop)
	assert(pop ~= INVALID_ID)
	assert(estate ~= INVALID_ID)

	local owner = OWNER(estate)
	local province = ESTATE_PROVINCE(estate)

	local estate_found = false

	DATA.for_each_ownership_from_owner(pop, function (item)
		local owned_estate = DATA.ownership_get_estate(item)
		local location = ESTATE_PROVINCE(owned_estate)
		if location == province then
			--- merge estates:
			local to_move = {}
			DATA.for_each_building_estate_from_estate(estate, function (item)
				table.insert(to_move, item)
			end)
			for key, value in pairs(to_move) do
				DATA.building_estate_set_estate(value, owned_estate)
			end
			estate_found = true
		end
	end)

	if not estate_found then
		if owner == INVALID_ID then
			DATA.force_create_ownership(estate, pop)
		else
			DATA.ownership_set_owner(DATA.get_ownership_from_estate(estate), pop)
		end
	else
		DATA.delete_estate(estate)
	end

	if pop and WORLD:does_player_see_province_news(province) then
		if WORLD.player_character == pop then
			WORLD:emit_notification("Estates of " .. NAME(owner) .. " in " .. PROVINCE_NAME(province) .. " is now owned by me, " .. NAME(pop) .. ".")
		else
			WORLD:emit_notification("Estates of " .. NAME(owner) .. " in " .. PROVINCE_NAME(province) .. " is now owned by " .. NAME(pop) .. ".")
		end
	end
end

---@param estate estate_id
function EconomicEffects.unset_ownership(estate)
	local owner = DATA.ownership_get_owner(DATA.get_ownership_from_estate(estate))

	if owner == INVALID_ID then
		return
	end

	local province = ESTATE_PROVINCE(estate)

	DATA.delete_ownership(DATA.get_ownership_from_estate(estate))

	if WORLD:does_player_see_province_news(province) then
		local pop_name = DATA.pop_get_name(owner)
		if WORLD.player_character == owner then
			WORLD:emit_notification("Estates in " .. PROVINCE_NAME(province) .. " are no longer owned by me, " .. pop_name .. ".")
		else
			WORLD:emit_notification("Estates in " .. PROVINCE_NAME(province) .. " are no longer owned by " .. pop_name .. ".")
		end
	end
end

---comment
---@param building_type BuildingType
---@param province province_id
---@param owner POP
---@return Building
function EconomicEffects.construct_building(building_type, estate, owner)
	local tile = ESTATE_TILE(estate)

	if estate == INVALID_ID then
		estate = DATA.create_estate()
		DATA.force_create_estate_location(POP_TILE(owner), estate)
		if (owner ~= INVALID_ID) then
			DATA.force_create_ownership(estate, owner)
		end
	end

	local result_building = DATA.create_building()
	DATA.building_set_current_type(result_building, building_type)
	DATA.force_create_building_estate(estate, result_building)

	local name_building = DATA.building_type_get_name(building_type)
	local province = TILE_PROVINCE(ESTATE_TILE(estate))
	local province_name = DATA.province_get_name(province)

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(name_building .. " was constructed in " .. province_name .. ".")
	end

	for i = 1, MAX_REQUIREMENTS_BUILDING_TYPE do
		local resource = DATA.building_type_get_required_resource(building_type, i)
		if resource == INVALID_ID then
			break
		end
		DATA.province_inc_used_resources(province, resource, 1)
	end

	return result_building
end

---comment
---@param building Building
function EconomicEffects.destroy_building(building)
	local estate = DATA.building_estate_get_estate(DATA.get_building_estate_from_building(building))
	local province = DATA.estate_location_get_province(DATA.get_estate_location_from_estate(estate))

	local building_type = DATA.building_get_current_type(building)
	for i = 1, MAX_REQUIREMENTS_BUILDING_TYPE do
		local resource = DATA.building_type_get_required_resource(building_type, i)
		if resource == INVALID_ID then
			break
		end
		DATA.province_inc_used_resources(province, resource, -1)
	end

	DATA.delete_building(building)
end

---comment
---@param building_type BuildingType
---@param estate estate_id
---@param owner POP
---@param overseer POP
---@param public boolean
---@return Building
function EconomicEffects.construct_building_with_payment(building_type, estate, owner, overseer, public)
	local construction_cost = ev.building_cost(building_type, overseer, public)
	local building = EconomicEffects.construct_building(building_type, estate, owner)

	if public or (owner == nil) then
		EconomicEffects.change_treasury(PROVINCE_REALM(ESTATE_PROVINCE(estate)), -construction_cost, ECONOMY_REASON.BUILDING)
	else
		EconomicEffects.add_pop_savings(owner, -construction_cost, ECONOMY_REASON.BUILDING)
	end

	return building
end

---character collects tribute into his pocket and returns collected value
---@param collector Character
---@param realm Realm
---@return number
function EconomicEffects.collect_tribute(collector, realm)
	local hauling = pop_utils.get_supply_capacity(collector) * 2
	local max_tribute = DATA.realm_get_budget_budget(realm, BUDGET_CATEGORY.TRIBUTE)
	local tribute_amount = math.min(hauling, math.floor(max_tribute))

	if WORLD:does_player_see_realm_news(realm) then
		WORLD:emit_notification("Tribute collector had arrived. Another day of humiliation. " ..
			tribute_amount .. MONEY_SYMBOL .. " were collected.")
	end

	EconomicEffects.register_spendings(realm, tribute_amount, ECONOMY_REASON.TRIBUTE)
	DATA.realm_inc_budget_budget(realm, BUDGET_CATEGORY.TRIBUTE, -tribute_amount)
	EconomicEffects.add_pop_savings(collector, tribute_amount, ECONOMY_REASON.TRIBUTE)
	return tribute_amount
end

---@param collector Character
---@param realm Realm
---@param tribute number
function EconomicEffects.return_tribute_home(collector, realm, tribute)
	local payment_multiplier = 0.1

	for i = 1, MAX_TRAIT_INDEX do
		local trait = DATA.pop_get_traits(collector, i)
		if trait == TRAIT.GREEDY then
			payment_multiplier = payment_multiplier * 5
		end
	end

	local payment = tribute * payment_multiplier
	local to_treasury = tribute - payment

	if WORLD:does_player_see_realm_news(realm) then
		WORLD:emit_notification("Tribute collector had arrived back. He brought back " ..
			to_treasury .. MONEY_SYMBOL .. " wealth.")
	end

	EconomicEffects.register_income(realm, to_treasury, ECONOMY_REASON.TRIBUTE)
	EconomicEffects.add_pop_savings(collector, -to_treasury, ECONOMY_REASON.TRIBUTE)
end

---comment
---@param province province_id
---@param good trade_good_id
---@param x number
function EconomicEffects.change_local_price(province, good, x)
	local current_price = DATA.province_get_local_prices(province, good)
	DATA.province_set_local_prices(province, good, math.max(0.001, current_price + x))

	if current_price ~= current_price or current_price == math.huge or x ~= x then
		error(
			"INVALID PRICE CHANGE"
			.. "\n change = "
			.. tostring(x) .. " "
			.. tostring(current_price)
		)
	end
end

---comment
---@param province province_id
---@param good trade_good_id
---@param x number
function EconomicEffects.change_local_stockpile(province, good, x)
	local current_stockpile = DATA.province_get_local_storage(province, good)
	if x < 0 and current_stockpile + 0.01 < -x then
		error(
			"INVALID LOCAL STOCKPILE CHANGE"
			.. "\n change = "
			.. tostring(x)
			.. "\n province.local_storage ['" .. DATA.trade_good_get_name(good) .. "'] = "
			.. tostring(current_stockpile)
			.. "\n province.local_production ['" .. DATA.trade_good_get_name(good) .. "'] = "
			.. tostring(DATA.province_get_local_production(province, good))
			.. "\n province.local_demand ['" .. DATA.trade_good_get_name(good) .. "'] = "
			.. tostring(DATA.province_get_local_demand(province, good))
			.. "\n province.local_consumption ['" .. DATA.trade_good_get_name(good) .. "'] = "
			.. tostring(DATA.province_get_local_consumption(province, good))
		)
	end
	if x ~= x or current_stockpile ~= current_stockpile then
		error(
			"NAN IN LOCAL STOCKPILE CHANGE"
			.. "\n change = "
			.. tostring(x)
		)
	end

	DATA.province_set_local_storage(province, good, math.max(0, current_stockpile + x))

end

---comment
---@param province province_id
---@param good trade_good_id
function EconomicEffects.decay_local_stockpile(province, good)
	local current_stockpile = DATA.province_get_local_storage(province, good)
	DATA.province_set_local_storage(province, good, current_stockpile * 0.85)
end

---comment
---@param character Character
---@param good trade_good_id
---@param amount number
function EconomicEffects.buy(character, good, amount)
	local can_buy, _ = et.can_buy(character, good, amount)
	if not can_buy then
		return false
	end

	-- can_buy validates province

	local province = DATA.character_location_get_location(DATA.get_character_location_from_character(character))

	assert(DATA.province_get_local_storage(province, good) >= amount, "ATTEMPT TO BUY MORE GOODS THAN THERE IS IN A PROVINCE")

	local price = ev.get_local_price(province, good)

	local price_belief = DATA.pop_get_price_belief_buy(character, good)

	if price_belief == 0 then
		DATA.pop_set_price_belief_buy(character, good, price)
	else
		DATA.pop_set_price_belief_buy(character, good, price_belief * (3 / 4) + price * (1 / 4))
	end

	local cost = price * amount

	if cost ~= cost then
		error(
			"WRONG BUY OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	EconomicEffects.add_pop_savings(character, -cost, ECONOMY_REASON.TRADE)

	local trade_wealth = DATA.province_get_trade_wealth(province)
	DATA.province_set_trade_wealth(province, trade_wealth + cost)

	local inventory = DATA.pop_get_inventory(character, good)
	DATA.pop_set_inventory(character, good, inventory + amount)

	EconomicEffects.change_local_stockpile(province, good, -amount)

	local trade_volume =
		DATA.province_get_local_consumption(province, good)
		+ DATA.province_get_local_production(province, good)
		+ amount

	local price_change = amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * price

	EconomicEffects.change_local_price(province, good, price_change)

	-- print('!!! BUY')

	if WORLD:does_player_see_province_news(province) then
		local name = DATA.pop_get_name(character)
		WORLD:emit_notification(
			"Trader "
			.. name
			.. " bought "
			.. amount
			.. " "
			.. DATA.trade_good_get_name(good)
			.. " for "
			.. ut.to_fixed_point2(cost) .. MONEY_SYMBOL
		)
	end

	return true
end

--- Consumes up to amount of use case from inventory in equal parts to available.
--- Returns total amount able to be satisfied.
---@param pop pop_id
---@param use_case use_case_id
---@param amount number
---@return number consumed
function EconomicEffects.consume_use_case_from_inventory(pop, use_case, amount)
	local supply = ev.available_use_case_from_inventory(pop, use_case)
	if supply <= 0 then
		return 0
	end
	if supply < amount then
		amount = supply
	end
	local consumed = tabb.accumulate(DATA.get_use_weight_from_use_case(use_case), 0, function(a, _, weight_id)
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local good_in_inventory = DATA.pop_get_inventory(pop, good)
		if good_in_inventory > 0 then
			local available = good_in_inventory * weight
			local satisfied = available / supply * amount
			local used = satisfied / weight
			if satisfied > available + 0.01
				or used > good_in_inventory + 0.01
			then
				error("CONSUMED TOO MUCH FROM INVENTORY"
					.. "\n good_in_inventory = "
					.. tostring(good_in_inventory)
					.. "\n weight = "
					.. tostring(weight)
					.. "\n available = "
					.. tostring(available)
					.. "\n satisfied = "
					.. tostring(satisfied)
					.. "\n supply = "
					.. tostring(supply)
					.. "\n amount = "
					.. tostring(amount)
					.. "\n used = "
					.. tostring(used)
				)
			end
			DATA.pop_set_inventory(pop, good, math.max(0, DATA.pop_get_inventory(pop, good) - used))
			a = a + satisfied
		end
		return a
	end)

	if consumed > amount + 0.01 then
		error("CONSUMED TOO MUCH: "
			.. "\n consumed = "
			.. tostring(consumed)
			.. "\n amount = "
			.. tostring(amount))
	end

	return consumed
end

--- Consumes up to amount of use case from inventory in equal parts to available.
--- Returns total amount able to be satisfied.
---@param estate estate_id
---@param use_case use_case_id
---@param amount number
---@return number consumed
function EconomicEffects.consume_use_case_for_estate(estate, use_case, amount)
	local supply = ev.available_use_case_for_estate(estate, use_case)
	if supply <= 0 then
		return 0
	end
	if supply < amount then
		amount = supply
	end
	local consumed = tabb.accumulate(DATA.get_use_weight_from_use_case(use_case), 0, function(a, _, weight_id)
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local good_in_inventory = DATA.estate_get_inventory(estate, good)
		if good_in_inventory > 0 then
			local available = good_in_inventory * weight
			local satisfied = available / supply * amount
			local used = satisfied / weight
			if satisfied > available + 0.01
				or used > good_in_inventory + 0.01
			then
				error("CONSUMED TOO MUCH FROM INVENTORY"
					.. "\n good_in_inventory = "
					.. tostring(good_in_inventory)
					.. "\n weight = "
					.. tostring(weight)
					.. "\n available = "
					.. tostring(available)
					.. "\n satisfied = "
					.. tostring(satisfied)
					.. "\n supply = "
					.. tostring(supply)
					.. "\n amount = "
					.. tostring(amount)
					.. "\n used = "
					.. tostring(used)
				)
			end
			DATA.estate_set_inventory(estate, good, math.max(0, DATA.estate_get_inventory(estate, good) - used))
			a = a + satisfied
		end
		return a
	end)

	if consumed > amount + 0.01 then
		error("CONSUMED TOO MUCH: "
			.. "\n consumed = "
			.. tostring(consumed)
			.. "\n amount = "
			.. tostring(amount))
	end

	return consumed
end

---attempts to buy use case from market for characters
---@param character Character
---@param use use_case_id
---@param amount number
function EconomicEffects.character_buy_use(character, use, amount)
	local province = POP_PROVINCE(character)
	local savings = DATA.pop_get_savings(character)
	local can_buy, _ = et.can_buy_use(province, savings, use, amount)
	if not can_buy then
		return false
	end

	-- can_buy validates province

	local price = ev.get_local_price_of_use(province, use)

	local cost = price * amount

	if cost ~= cost then
		error(
			"WRONG BUY OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	local price_expectation = ev.get_local_price_of_use(province, use)
	local use_available = ev.get_local_amount_of_use(province, use)

	local total_bought = 0
	local spendings = 0
	local budget = DATA.pop_get_savings(character)

	---@type {good: trade_good_id, weight: number, price: number, available: number}[]
	local goods = {}
	DATA.for_each_use_weight_from_use_case(use, function (weight_id)
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local good_price = ev.get_local_price(province, good)
		local price_belief = DATA.pop_get_price_belief_buy(character, good)
		if price_belief == 0 then
			DATA.pop_set_price_belief_buy(character, good, good_price)
		else
			DATA.pop_set_price_belief_buy(character, good, price_belief * (3 / 4) + good_price * (1 / 4))
		end
		local goods_available = DATA.province_get_local_storage(province, good)
		if goods_available > 0 then
			goods[#goods + 1] = { good = good, weight = weight, price = good_price, available = goods_available }
		end
	end)
	for _, values in pairs(goods) do
		local good_use_amount = values.available * values.weight
		local goods_available_weight = math.max(good_use_amount / use_available, 0)
		local consumed_amount = amount / values.weight * goods_available_weight

		if goods_available_weight ~= goods_available_weight
			or consumed_amount ~= consumed_amount
		then
			error("CHARACTER BUY USE CALCULATED AMOUNT IS NAN"
				.. "\n use = "
				.. tostring(use)
				.. "\n use_available = "
				.. tostring(use_available)
				.. "\n good = "
				.. tostring(values.good)
				.. "\n good_price = "
				.. tostring(values.price)
				.. "\n goods_available = "
				.. tostring(values.available)
				.. "\n good_use_amount = "
				.. tostring(good_use_amount)
				.. "\n good use weight = "
				.. tostring(values.weight)
				.. "\n goods_available_weight = "
				.. tostring(goods_available_weight)
				.. "\n consumed_amount = "
				.. tostring(consumed_amount)
				.. "\n amount = "
				.. tostring(amount)
			)
		end

		local costs = consumed_amount * values.price

		if budget <= costs then
			consumed_amount = budget / values.price
			costs = budget
			budget = 0
		else
			budget = budget - costs
		end

		total_bought = total_bought + consumed_amount * values.weight

		-- we need to get back to use "units" so we multiply consumed amount back by weight

		spendings = spendings + costs

		--MAKE TRANSACTION
		DATA.province_inc_trade_wealth(province, costs)
		---pop's savings are reduced later

		DATA.pop_inc_inventory(character, values.good, consumed_amount)
		EconomicEffects.change_local_stockpile(province, values.good, -consumed_amount)

		local trade_volume =
			DATA.province_get_local_production(province, values.good)
			+ DATA.province_get_local_demand(province, values.good)
			+ DATA.province_get_local_storage(province, values.good)
			+ consumed_amount + 0.01
		local price_change = consumed_amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * values.price

		EconomicEffects.change_local_price(province, values.good, price_change)
	end
	if total_bought < amount * 0.7 or total_bought > amount * 1.3 then
		print("Potentially invalid attempt to buy use case for the character"
			.. "\n use = "
			.. tostring(use)
			.. "\n spendings = "
			.. tostring(spendings)
			.. "\n total_bought = "
			.. tostring(total_bought)
			.. "\n amount = "
			.. tostring(amount)
			.. "\n price_expectation = "
			.. tostring(price_expectation)
			.. "\n use_available = "
			.. tostring(use_available)
		)
	end

	EconomicEffects.add_pop_savings(character, -math.min(spendings, DATA.pop_get_savings(character)), ECONOMY_REASON.TRADE)

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(
			require "game.raws.ranks.localisation"(character) .. NAME(character)
			.. " bought " .. ut.to_fixed_point2(amount)	.. " " .. DATA.use_case_name(use)
			.. " for " .. ut.to_fixed_point2(spendings)
			.. MONEY_SYMBOL
		)
	end
end

---attempt to move a given amount of a trade good from pop to party
---, negative values attempt to transfer from party to pop
---@param pop_id pop_id
---@param party_id estate_id
---@param trade_good_id trade_good_id
---@param amount number
function EconomicEffects.pop_transfer_good_to_party(pop_id,party_id,trade_good_id,amount)
	-- can only transfer if at the same location, settlement or tile if outside settlement
	local party_tile = ESTATE_TILE(party_id)
	local party_province = TILE_PROVINCE(party_tile)
	local pop_province = POP_PROVINCE(pop_id)
	local in_settlement = IN_SETTLEMENT(party_id)
	if (in_settlement and pop_province ~= party_province)
		or (not in_settlement and pop_province == INVALID_ID and party_tile ~= ESTATE_TILE(UNIT_OF(pop_id)))
	then
		return false
	end

	-- limit transfer by pop and party inventories
	local pop_amount = DATA.pop_get_inventory(pop_id,trade_good_id)
	local party_amount = DATA.estate_get_inventory(party_id,trade_good_id)
	local consumed_amount = amount > 0 and math.min(amount, pop_amount)
		or math.max(amount, -party_amount)

	--MAKE TRANSACTION
	DATA.pop_inc_inventory(pop_id, trade_good_id, -consumed_amount)
	DATA.estate_inc_inventory(party_id, trade_good_id, consumed_amount)

	-- notify if not giving to own party
	if WORLD:does_player_see_province_news(pop_province) and UNIT_OF(pop_id) ~= party_id then
		WORLD:emit_notification(NAME(pop_id) .. " gave " .. ut.to_fixed_point2(consumed_amount)
			.. " " .. DATA.trade_good_get_name(trade_good_id) .. " to " .. ESTATE_NAME(party_id))
	end
end

---attempt to move a given amount of a use case from pop to party
---, negative values attempt to transfer from party to pop
---@param pop_id pop_id
---@param party_id estate_id
---@param use_case_id use_case_id
---@param amount number
function EconomicEffects.pop_transfer_use_to_party(pop_id,party_id,use_case_id,amount)
	local party_tile = ESTATE_TILE(party_id)
	local party_province = TILE_PROVINCE(party_tile)
	local pop_province = POP_PROVINCE(pop_id)
	local in_settlement = IN_SETTLEMENT(party_id)
	if (in_settlement and pop_province ~= party_province)
		or (not in_settlement and pop_province == INVALID_ID and party_tile ~= ESTATE_TILE(UNIT_OF(pop_id)))
	then
		return false
	end

	local use_available = amount > 0 and ev.available_use_case_from_inventory(pop_id, use_case_id)
		or ev.available_use_case_for_party(party_id, use_case_id)

	---@type {good: trade_good_id, weight: number, price: number, available: number}[]
	local goods = {}
	DATA.for_each_use_weight_from_use_case(use_case_id, function (weight_id)
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local goods_available = amount > 0 and DATA.pop_get_inventory(pop_id, good)
			or DATA.estate_get_inventory(party_id, good)
		if goods_available > 0 then
			goods[#goods + 1] = { good = good, weight = weight, available = goods_available }
		end
	end)
	local total_transfer = 0
	for _, values in pairs(goods) do
		local good_use_amount = values.available * values.weight
		local goods_available_weight = math.max(good_use_amount / use_available, 0)
		local consumed_amount = amount / values.weight * goods_available_weight
		if goods_available_weight ~= goods_available_weight
			or consumed_amount ~= consumed_amount
		then
			error("POP TO PARTY USE CALCULATED AMOUNT IS NAN"
				.. "\n use = "
				.. tostring(use_case_id)
				.. "\n use_available = "
				.. tostring(use_available)
				.. "\n good = "
				.. tostring(values.good)
				.. "\n goods_available = "
				.. tostring(values.available)
				.. "\n good_use_amount = "
				.. tostring(good_use_amount)
				.. "\n good use weight = "
				.. tostring(values.weight)
				.. "\n goods_available_weight = "
				.. tostring(goods_available_weight)
				.. "\n consumed_amount = "
				.. tostring(consumed_amount)
				.. "\n amount = "
				.. tostring(amount)
			)
		end

		total_transfer = total_transfer + consumed_amount * values.weight

		-- we need to get back to use "units" so we multiply consumed amount back by weight

		--MAKE TRANSACTION
		local party_inventory = DATA.estate_get_inventory(party_id,values.good)
		DATA.pop_set_inventory(pop_id, values.good, math.max(0,values.available - consumed_amount))
		DATA.estate_set_inventory(party_id, values.good, math.max(0,party_inventory + consumed_amount))
	end
	if total_transfer < amount * 0.7 or total_transfer > amount * 1.3 then
		print("Potentially invalid attempt to sell use case for the party"
			.. "\n use = "
			.. tostring(use_case_id)
			.. "\n total_transfer = "
			.. tostring(total_transfer)
			.. "\n amount = "
			.. tostring(amount)
			.. "\n use_available = "
			.. tostring(use_available)
		)
	end

	if WORLD:does_player_see_province_news(pop_province) and UNIT_OF(pop_id) ~= party_id then
		WORLD:emit_notification(
			NAME(pop_id) .. " gave " .. ut.to_fixed_point2(total_transfer) .. " " .. DATA.use_case_get_name(use_case_id)
			.. " to " .. ESTATE_NAME(party_id)
		)
	end
end

---attempts to buy trade good to market to party inventory
---@param party estate_id
---@param good trade_good_id
---@param amount number
function EconomicEffects.party_buy_good(party,good,amount)
	local leader = party_utils.active_leader(party)
	local province = TILE_PROVINCE(ESTATE_TILE(party))
	local savings = ESTATE_SAVINGS(party)
	local available = DATA.province_get_local_storage(province,good)
	if not IN_SETTLEMENT(party) or available <= 0 or savings <= 0 then
		return false
	end

	local price = ev.get_local_price(province,good)
	local cost = price * amount
	if cost ~= cost then
		error(
			"WRONG BUY OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	if leader ~= INVALID_ID then
		local price_belief = DATA.pop_get_price_belief_sell(leader, good)
		if price_belief == 0 then
			DATA.pop_set_price_belief_sell(leader, good, price)
		else
			DATA.pop_set_price_belief_sell(leader, good, price_belief * (3 / 4) + price * (1 / 4))
		end
	end

	-- limit 
	local consumed_amount = math.min(amount,available,savings/price)
	local income = consumed_amount * price

	--MAKE TRANSACTION
	DATA.province_inc_trade_wealth(province, income)
	EconomicEffects.add_party_savings(party, -income, ECONOMY_REASON.TRADE)

	DATA.estate_inc_inventory(party, good, consumed_amount)
	EconomicEffects.change_local_stockpile(province, good, -consumed_amount)

	local trade_volume =
		DATA.province_get_local_production(province, good)
		+ DATA.province_get_local_demand(province, good)
		+ DATA.province_get_local_storage(province, good)
		+ consumed_amount + 0.01
	local price_change = consumed_amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * price

	EconomicEffects.change_local_price(province, good, -price_change)

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(
			ESTATE_NAME(party)
			.. " bought " .. ut.to_fixed_point2(consumed_amount)	.. " " .. DATA.trade_good_get_name(good)
			.. " from the " .. PROVINCE_NAME(province)
			.. " market for " .. ut.to_fixed_point2(income)
			.. MONEY_SYMBOL
		)
	end
end

---attempts to sell trade good to market from party inventory
---@param party estate_id
---@param good trade_good_id
---@param amount number
function EconomicEffects.party_sell_good(party,good,amount)
	local leader = party_utils.active_leader(party)
	local province = TILE_PROVINCE(ESTATE_TILE(party))
	local trade_wealth = DATA.province_get_trade_wealth(province)
	local available = DATA.estate_get_inventory(party,good)
	if not IN_SETTLEMENT(party) or available <= 0 or trade_wealth <= 0 then
		return false
	end

	local price = ev.get_local_price(province,good)
	local cost = price * amount
	if cost ~= cost then
		error(
			"WRONG BUY OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	if leader ~= INVALID_ID then
		local price_belief = DATA.pop_get_price_belief_sell(leader, good)
		if price_belief == 0 then
			DATA.pop_set_price_belief_sell(leader, good, price)
		else
			DATA.pop_set_price_belief_sell(leader, good, price_belief * (3 / 4) + price * (1 / 4))
		end
	end

	-- limit 
	local consumed_amount = math.min(amount,available,trade_wealth/price)
	local income = consumed_amount * price

	--MAKE TRANSACTION
	DATA.province_inc_trade_wealth(province, -income)
	EconomicEffects.add_party_savings(party, income, ECONOMY_REASON.TRADE)

	DATA.estate_inc_inventory(party, good, -consumed_amount)
	EconomicEffects.change_local_stockpile(province, good, consumed_amount)

	local trade_volume =
		DATA.province_get_local_production(province, good)
		+ DATA.province_get_local_demand(province, good)
		+ DATA.province_get_local_storage(province, good)
		+ consumed_amount + 0.01
	local price_change = consumed_amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * price

	EconomicEffects.change_local_price(province, good, -price_change)

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(
			ESTATE_NAME(party)
			.. " sold " .. ut.to_fixed_point2(consumed_amount)	.. " " .. DATA.trade_good_get_name(good)
			.. " to the " .. PROVINCE_NAME(province)
			.. " market for " .. ut.to_fixed_point2(income)
			.. MONEY_SYMBOL
		)
	end
end

---attempts to buy use case from market for parties
---@param party estate_id
---@param use use_case_id
---@param amount number
function EconomicEffects.party_buy_use(party, use, amount)
	local leader = party_utils.active_leader(party)
	local province = POP_PROVINCE(leader)
	local savings = DATA.estate_get_savings(party)
	local can_buy, failure = et.can_buy_use(province, savings, use, amount)
	if not can_buy then
--		print(tabb.accumulate(failure,"Failed can_buy check",function(a,k,v)
--			return a .. "\n" .. k .. " " .. v
--		end))
		return false
	end

	-- can_buy validates province

	local price = ev.get_local_price_of_use(province, use)

	local cost = price * amount

	if cost ~= cost then
		error(
			"WRONG BUY OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	local price_expectation = ev.get_local_price_of_use(province, use)
	local use_available = ev.get_local_amount_of_use(province, use)

	local total_bought = 0
	local spendings = 0
	local budget = DATA.estate_get_savings(party)

	---@type {good: trade_good_id, weight: number, price: number, available: number}[]
	local goods = {}
	DATA.for_each_use_weight_from_use_case(use, function (weight_id)
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local good_price = ev.get_local_price(province, good)
		if leader ~= INVALID_ID then
			local price_belief = DATA.pop_get_price_belief_buy(leader, good)
			if price_belief == 0 then
				DATA.pop_set_price_belief_buy(leader, good, good_price)
			else
				DATA.pop_set_price_belief_buy(leader, good, price_belief * (3 / 4) + good_price * (1 / 4))
			end
		end
		local goods_available = DATA.province_get_local_storage(province, good)
		if goods_available > 0 then
			goods[#goods + 1] = { good = good, weight = weight, price = good_price, available = goods_available }
		end
	end)
	for _, values in pairs(goods) do
		local good_use_amount = values.available * values.weight
		local goods_available_weight = math.max(good_use_amount / use_available, 0)
		local consumed_amount = amount / values.weight * goods_available_weight

		if goods_available_weight ~= goods_available_weight
			or consumed_amount ~= consumed_amount
		then
			error("PARTY BUY USE CALCULATED AMOUNT IS NAN"
				.. "\n use = "
				.. tostring(use)
				.. "\n use_available = "
				.. tostring(use_available)
				.. "\n good = "
				.. tostring(values.good)
				.. "\n good_price = "
				.. tostring(values.price)
				.. "\n goods_available = "
				.. tostring(values.available)
				.. "\n good_use_amount = "
				.. tostring(good_use_amount)
				.. "\n good use weight = "
				.. tostring(values.weight)
				.. "\n goods_available_weight = "
				.. tostring(goods_available_weight)
				.. "\n consumed_amount = "
				.. tostring(consumed_amount)
				.. "\n amount = "
				.. tostring(amount)
			)
		end

		local costs = consumed_amount * values.price

		if budget <= costs then
			consumed_amount = budget / values.price
			costs = budget
			budget = 0
		else
			budget = budget - costs
		end

		total_bought = total_bought + consumed_amount * values.weight

		-- we need to get back to use "units" so we multiply consumed amount back by weight

		spendings = spendings + costs

		--MAKE TRANSACTION
		DATA.province_inc_trade_wealth(province, costs)
		---pop's savings are reduced later

		DATA.estate_inc_inventory(party, values.good, consumed_amount)
		EconomicEffects.change_local_stockpile(province, values.good, -consumed_amount)

		local trade_volume =
			DATA.province_get_local_production(province, values.good)
			+ DATA.province_get_local_demand(province, values.good)
			+ DATA.province_get_local_storage(province, values.good)
			+ consumed_amount + 0.01
		local price_change = consumed_amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * values.price

		EconomicEffects.change_local_price(province, values.good, price_change)
	end
	if total_bought < amount * 0.7 or total_bought > amount * 1.3 then
		print("Potentially invalid attempt to buy use case for the party"
			.. "\n use = "
			.. tostring(use)
			.. "\n spendings = "
			.. tostring(spendings)
			.. "\n total_bought = "
			.. tostring(total_bought)
			.. "\n amount = "
			.. tostring(amount)
			.. "\n price_expectation = "
			.. tostring(price_expectation)
			.. "\n use_available = "
			.. tostring(use_available)
		)
	end

	EconomicEffects.add_party_savings(party, -math.min(spendings, DATA.estate_get_treasury(party)), ECONOMY_REASON.TRADE)

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(
			ESTATE_NAME(party)
			.. " bought " .. ut.to_fixed_point2(amount)	.. " " .. DATA.use_case_get_name(use)
			.. " from the " .. PROVINCE_NAME(province)
			.. " market for " .. ut.to_fixed_point2(spendings)
			.. MONEY_SYMBOL
		)
	end
end

---attempts to sell use case to market from party inventory
---@param party estate_id
---@param use use_case_id
---@param amount number
function EconomicEffects.party_sell_use(party,use,amount)
	local leader = party_utils.active_leader(party)
	local province = TILE_PROVINCE(ESTATE_TILE(party))
	local trade_wealth = DATA.province_get_trade_wealth(province)
	local use_available = ev.available_use_case_for_party(party,use)
	if not IN_SETTLEMENT(party) or use_available <= 0 or trade_wealth <= 0 then
		return false
	end

	local price = ev.get_local_price_of_use(province, use)
	local cost = price * amount
	if cost ~= cost then
		error(
			"WRONG BUY OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	local price_expectation = ev.get_local_price_of_use(province, use)
	local use_available = ev.available_use_case_for_party(party, use)

	local total_sold = 0
	local total_income = 0
	local budget = DATA.province_get_trade_wealth(province)

	---@type {good: trade_good_id, weight: number, price: number, available: number}[]
	local goods = {}
	DATA.for_each_use_weight_from_use_case(use, function (weight_id)
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local good_price = ev.get_local_price(province, good)
		if leader ~= INVALID_ID then
			local price_belief = DATA.pop_get_price_belief_sell(leader, good)
			if price_belief == 0 then
				DATA.pop_set_price_belief_sell(leader, good, good_price)
			else
				DATA.pop_set_price_belief_sell(leader, good, price_belief * (3 / 4) + good_price * (1 / 4))
			end
		end
		local goods_available = DATA.estate_get_inventory(party, good)
		if goods_available > 0 then
			goods[#goods + 1] = { good = good, weight = weight, price = good_price, available = goods_available }
		end
	end)
	for _, values in pairs(goods) do
		local good_use_amount = values.available * values.weight
		local goods_available_weight = math.max(good_use_amount / use_available, 0)
		local consumed_amount = amount / values.weight * goods_available_weight
		if goods_available_weight ~= goods_available_weight
			or consumed_amount ~= consumed_amount
		then
			error("PARTY SELL USE CALCULATED AMOUNT IS NAN"
				.. "\n use = "
				.. tostring(use)
				.. "\n use_available = "
				.. tostring(use_available)
				.. "\n good = "
				.. tostring(values.good)
				.. "\n good_price = "
				.. tostring(values.price)
				.. "\n goods_available = "
				.. tostring(values.available)
				.. "\n good_use_amount = "
				.. tostring(good_use_amount)
				.. "\n good use weight = "
				.. tostring(values.weight)
				.. "\n goods_available_weight = "
				.. tostring(goods_available_weight)
				.. "\n consumed_amount = "
				.. tostring(consumed_amount)
				.. "\n amount = "
				.. tostring(amount)
			)
		end

		local income = consumed_amount * values.price

		if budget <= income then
			consumed_amount = budget / values.price
			income = budget
			budget = 0
		else
			budget = budget - income
		end

		total_sold = total_sold + consumed_amount * values.weight

		-- we need to get back to use "units" so we multiply consumed amount back by weight

		total_income = total_income + income

		--MAKE TRANSACTION
		DATA.province_inc_trade_wealth(province, -income)
		---pop's savings are reduced later

		DATA.estate_inc_inventory(party, values.good, -consumed_amount)
		EconomicEffects.change_local_stockpile(province, values.good, consumed_amount)

		local trade_volume =
			DATA.province_get_local_production(province, values.good)
			+ DATA.province_get_local_demand(province, values.good)
			+ DATA.province_get_local_storage(province, values.good)
			+ consumed_amount + 0.01
		local price_change = consumed_amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * values.price

		EconomicEffects.change_local_price(province, values.good, -price_change)
	end
	if total_sold < amount * 0.7 or total_sold > amount * 1.3 then
		print("Potentially invalid attempt to sell use case for the party"
			.. "\n use = "
			.. tostring(use)
			.. "\n trade_wealth = "
			.. tostring(trade_wealth)
			.. "\n total_income = "
			.. tostring(total_income)
			.. "\n total_sold = "
			.. tostring(total_sold)
			.. "\n amount = "
			.. tostring(amount)
			.. "\n price_expectation = "
			.. tostring(price_expectation)
			.. "\n use_available = "
			.. tostring(use_available)
		)
	end

	EconomicEffects.add_party_savings(party, total_income, ECONOMY_REASON.TRADE)

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(
			ESTATE_NAME(party)
			.. " sold " .. ut.to_fixed_point2(amount)	.. " " .. DATA.use_case_get_name(use)
			.. " to the " .. PROVINCE_NAME(province)
			.. " market for " .. ut.to_fixed_point2(total_income)
			.. MONEY_SYMBOL
		)
	end
end

--[[ unused code, rewrite on demand, but it would be better to purchase realms goods via some agent
---comment
---@param realm Realm
---@param use use_case_id
---@param amount number
function EconomicEffects.realm_buy_use(realm, use, amount)
	local can_buy, _ = et.can_buy_use(realm.capitol, realm.budget.treasury, use, amount)
	if not can_buy then
		return false
	end

	local use_case = require "game.raws.raws-utils".trade_good_use_case(use)

	-- can_buy validates province
	---@type province_id
	local province = realm.capitol
	local price = ev.get_local_price_of_use(province, use)

	local cost = price * amount

	if cost ~= cost then
		error(
			"WRONG BUY OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	local price_expectation = ev.get_local_price_of_use(province, use)
	local use_available = ev.get_local_amount_of_use(province, use)

	local total_bought = 0
	local spendings = 0

	---@type {good: trade_good_id, weight: number, price: number, available: number}[]
	local goods = {}
	for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local good_price = ev.get_local_price(province, good)
		local goods_available = province.local_storage[good] or 0
		if goods_available > 0 then
			goods[#goods + 1] = { good = good, weight = weight, price = good_price, available = goods_available }
		end
	end
	for _, values in pairs(goods) do
		local good_use_amount = values.available * values.weight
		local goods_available_weight = math.max(good_use_amount / use_available, 0)
		local consumed_amount = amount / values.weight * goods_available_weight

		if goods_available_weight ~= goods_available_weight
			or consumed_amount ~= consumed_amount
		then
			error("REALM BUY USE CALCULATED AMOUNT IS NAN"
				.. "\n use = "
				.. tostring(use)
				.. "\n use_available = "
				.. tostring(use_available)
				.. "\n good = "
				.. tostring(values.good)
				.. "\n good_price = "
				.. tostring(values.price)
				.. "\n goods_available = "
				.. tostring(values.available)
				.. "\n good_use_amount = "
				.. tostring(good_use_amount)
				.. "\n good use weight = "
				.. tostring(values.weight)
				.. "\n goods_available_weight = "
				.. tostring(goods_available_weight)
				.. "\n consumed_amount = "
				.. tostring(consumed_amount)
				.. "\n amount = "
				.. tostring(amount)
			)
		end

		-- we need to get back to use "units" so we multiplay consumed amount back by weight
		total_bought = total_bought + consumed_amount * values.weight

		local costs = consumed_amount * values.price
		spendings = spendings + costs

		--MAKE TRANSACTION
		province.trade_wealth = province.trade_wealth + costs
		realm.resources[values.good] = (realm.resources[values.good] or 0) + amount

		EconomicEffects.change_local_stockpile(province, values.good, -amount)

		local trade_volume = (province.local_consumption[values.good] or 0) +
			(province.local_production[values.good] or 0) + amount
		local price_change = amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * values.price

		EconomicEffects.change_local_price(province, values.good, price_change)
	end
	if total_bought < amount - 0.01
		or total_bought > amount + 0.01
	then
		error("INVALID REALM BUY USE ATTEMPT"
			.. "\n use = "
			.. tostring(use)
			.. "\n spendings = "
			.. tostring(spendings)
			.. "\n total_bought = "
			.. tostring(total_bought)
			.. "\n amount = "
			.. tostring(amount)
			.. "\n price_expectation = "
			.. tostring(price_expectation)
			.. "\n use_available = "
			.. tostring(use_available)
		)
	end

	EconomicEffects.change_treasury(realm, -spendings, ECONOMY_REASON.TRADE)

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(REALM_NAME(realm) .. " bought " .. amount .. " " .. use .. " for " .. ut.to_fixed_point2(spendings) .. MONEY_SYMBOL .. ".")
	end
end
--]]

---comment
---@param character Character
---@param good trade_good_id
---@param amount number
function EconomicEffects.sell(character, good, amount)
	local can_sell, _ = et.can_sell(character, good, amount)
	if not can_sell then
		return false
	end

	-- can_sell validates province
	---@type province_id
	local province = POP_PROVINCE(character)
	local price = ev.get_pessimistic_local_price(province, good, amount, true)

	local memory = DATA.pop_get_price_belief_sell(character, good)
	local new_memory = price
	if memory > 0 then
		new_memory = memory * (3 / 4) + price * (1 / 4)
	end

	DATA.pop_set_price_belief_sell(character, good, new_memory)

	local cost = price * amount

	if cost ~= cost then
		error(
			"WRONG SELL OPERATION "
			.. "\n price = "
			.. tostring(price)
			.. "\n amount = "
			.. tostring(amount)
		)
	end

	EconomicEffects.add_pop_savings(character, cost, ECONOMY_REASON.TRADE)
	DATA.province_inc_trade_wealth(province, -cost)

	DATA.pop_inc_inventory(character, good, -amount)
	EconomicEffects.change_local_stockpile(province, good, amount)

	local trade_volume =
			DATA.province_get_local_consumption(province, good)
			+ DATA.province_get_local_production(province, good)
			+ amount

	local price_change = amount / trade_volume * PRICE_SIGNAL_PER_STOCKPILED_UNIT * price
	EconomicEffects.change_local_price(province, good, -price_change)

	-- print('!!! SELL')

	if WORLD:does_player_see_province_news(province) then
		WORLD:emit_notification(
			"Trader " .. DATA.pop_get_name(character)
			.. " sold " .. amount .. " " .. good
			.. " for " .. ut.to_fixed_point2(cost) .. MONEY_SYMBOL
		)
	end
	return true
end

---comment
---@param character Character
---@param realm Realm
---@param amount number
function EconomicEffects.gift_to_tribe(character, realm, amount)
	if realm == INVALID_ID then
		return
	end
	local savings = DATA.pop_get_savings(character)
	if savings < amount then
		return
	end

	EconomicEffects.add_pop_savings(character, -amount, ECONOMY_REASON.DONATION)
	EconomicEffects.change_treasury(realm, amount, ECONOMY_REASON.DONATION)

	local capitol = DATA.realm_get_capitol(realm)

	local mood_change = amount / (province_utils.local_population(capitol) + 1) / 100

	DATA.province_inc_mood(capitol, mood_change)
	EconomicEffects.gain_popularity(character, realm, mood_change)

	message_effects.on_donation_to_realm(character, realm)
end

---comment
---@param character Character
---@param province Province
---@param amount number
function EconomicEffects.gift_to_province(character, province, amount)
	local savings = DATA.pop_get_savings(character)
	if savings < amount then
		return
	end

	EconomicEffects.add_pop_savings(character, -amount, ECONOMY_REASON.DONATION)
	EconomicEffects.change_local_wealth(province, amount, ECONOMY_REASON.DONATION)

	local mood_change = amount / (province_utils.local_population(province) + 1) / 100

	DATA.province_inc_mood(province, mood_change)
	EconomicEffects.gain_popularity(character, PROVINCE_REALM(province), mood_change)

	message_effects.on_donation_to_province(character, province)
end

---commenting
---@param character Character
---@param realm Realm
---@param amount number
function EconomicEffects.gain_popularity(character, realm, amount)
	local popularity = INVALID_ID
	DATA.for_each_popularity_from_who(character, function (item)
		local where = DATA.popularity_get_where(item)
		if where == realm then
			popularity = item
		end
	end)

	if popularity == INVALID_ID then
		local new = DATA.force_create_popularity(character, realm)
		DATA.popularity_set_value(new, amount)
	else
		DATA.popularity_inc_value(popularity, amount)
	end
end

---comment
---@param estate estate_id
---@param character Character
---@param amount number
function EconomicEffects.gift_to_estate(estate, character, amount)
	assert(estate ~= INVALID_ID)
	assert(character ~= INVALID_ID)

	EconomicEffects.add_pop_savings(character, -amount, ECONOMY_REASON.WARBAND)
	EconomicEffects.add_party_savings(estate,  amount, ECONOMY_REASON.DONATION)
end

---comment
---@param gifter Character
---@param receiver Character
---@param amount number
function EconomicEffects.gift_to_pop(gifter, receiver, amount)
	assert(gifter ~= INVALID_ID)
	assert(receiver ~= INVALID_ID)

	local savings_origin = DATA.pop_get_savings(gifter)
	local savings_target = DATA.pop_get_savings(receiver)

	if amount > 0 then
		if savings_origin < amount then
			amount = savings_origin
		end
	else
		if savings_target < -amount then
			amount = -savings_target
		end
	end

	EconomicEffects.add_pop_savings(gifter, -amount, ECONOMY_REASON.LOYALTY_GIFT)
	EconomicEffects.add_pop_savings(receiver, amount, ECONOMY_REASON.LOYALTY_GIFT)
end

---commenting
---@param character Character
---@return number
function EconomicEffects.collect_tax(character)
	local total_tax = 0
	local tax_collection_ability = 0.05

	for i = 1, MAX_TRAIT_INDEX do
		local trait = DATA.pop_get_traits(character, i)
		if trait == INVALID_ID then
			break
		end
		if trait == TRAIT.GREEDY then
			tax_collection_ability = tax_collection_ability + 0.03
		elseif trait == TRAIT.HARDWORKER then
			tax_collection_ability = tax_collection_ability + 0.01
		elseif trait == TRAIT.LAZY then
			tax_collection_ability = tax_collection_ability - 0.01
		end
	end

	DATA.for_each_estate_unit(function (item)
		local pop = DATA.estate_unit_get_pop(item)
		if POP_PROVINCE(character) ~= POP_PROVINCE(pop) then return end
		local savings = DATA.pop_get_savings(pop)
		if savings > 0 then
			total_tax = total_tax + savings * tax_collection_ability
			EconomicEffects.add_pop_savings(pop, -savings * tax_collection_ability, ECONOMY_REASON.TAX)
		end
	end)
	return total_tax
end

---Grants trading rights to character
---@param character Character
---@param realm Realm
function EconomicEffects.grant_trade_rights(character, realm)
	local rights = INVALID_ID
	DATA.for_each_personal_rights_from_person(character, function (item)
		local item_realm = DATA.personal_rights_get_realm(item)
		if item_realm == realm then
			rights = item
		end
	end)

	if rights == INVALID_ID then
		local new = DATA.fatten_personal_rights(DATA.force_create_personal_rights(character, realm))
		new.can_trade = true
	else
		DATA.personal_rights_set_can_trade(rights, true)
	end
end

---Grants trading rights to character
---@param character Character
---@param realm Realm
function EconomicEffects.grant_building_rights(character, realm)
	---@type personal_rights_id
	local rights = INVALID_ID
	DATA.for_each_personal_rights_from_person(character, function (item)
		local item_realm = DATA.personal_rights_get_realm(item)
		if item_realm == realm then
			rights = item
		end
	end)

	if rights == INVALID_ID then
		local new = DATA.fatten_personal_rights(DATA.force_create_personal_rights(character, realm))
		new.can_build = true
	else
		DATA.personal_rights_set_can_build(rights, true)
	end
end

---Clears all trading rights of character
---@param character Character
function EconomicEffects.abandon_personal_rights(character)
	local to_remove = DATA.filter_personal_rights_from_person(character, ACCEPT_ALL)
	for index, value in ipairs(to_remove) do
		DATA.delete_personal_rights(value)
	end
end




return EconomicEffects
