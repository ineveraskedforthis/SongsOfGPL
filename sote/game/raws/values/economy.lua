local tabb = require "engine.table"
local warband_utils = require "game.entities.warband"

local eco_values = {}

---comment
---@param realm Realm
function eco_values.potential_monthly_tribute_size(realm)
    return DATA.realm_get_budget_saved_change(realm) * 0.1
end



---Returns amount of wealth character would want in exchange for paying tribute \
---It's calculated as a part of savings of pops of his tribe which somewhat represents wellbeing of it
---@param realm Realm
function eco_values.realm_independence_price(realm)
    local total = 0
    local capitol = DATA.realm_get_capitol(realm)
    for _, pop_location in pairs(DATA.get_pop_location_from_location(capitol)) do
        local pop = DATA.pop_location_get_pop(pop_location)
        total = total + DATA.pop_get_savings(pop)
    end
    return total * 0.5 + 50
end

---comment
---@param realm Realm
function eco_values.raidable_treasury(realm)
    if realm == INVALID_ID then return 0 end
    local treasury = DATA.realm_get_budget_treasury(realm)
    return math.max(0, treasury * 0.1)
end

---comment
---@param building_type BuildingType
---@param public boolean
---@param overseer Character
---@return number
function eco_values.building_cost(building_type, overseer, public)
    local cost_multiplier = 1

    -- overseer effect
    if overseer == INVALID_ID then
        cost_multiplier = 2
    else
        for i = 0, MAX_TRAIT_INDEX do
            local trait = DATA.pop_get_traits(overseer, i)

            if trait == 0 then
                break
            end

            if trait == TRAIT.BAD_ORGANISER then
                cost_multiplier = cost_multiplier * 1.5
            elseif trait == TRAIT.GOOD_ORGANISER then
                cost_multiplier = cost_multiplier * 0.5
            end
        end
    end

    if public then
        cost_multiplier = cost_multiplier * 0.8
    end

    local base_cost = DATA.building_type_get_construction_cost(building_type)
    return base_cost * cost_multiplier
end

---comment
---@param province province_id
---@param trade_good trade_good_id
---@return number price
function eco_values.get_local_price(province, trade_good)
    return DATA.province_get_local_prices(province, trade_good)
end

---commenting
---@param province province_id
---@param use use_case_id
---@return number sum_of_exponents
---@return number min_price
local function soft_max_data_for_use(province, use)
    local min_price = nil
    for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local price = eco_values.get_local_price(province, trade_good)
        if min_price == nil then
            min_price = price
        elseif min_price > price then
            min_price = price
        end
    end

    local sum = 0
    for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local price = eco_values.get_local_price(province, trade_good)
        sum = sum + math.exp(-price + min_price)
    end

    return sum, min_price
end

---calculates price estimation of unit of use
---@param province province_id
---@param use use_case_id
---@return number price
function eco_values.get_local_price_of_use(province, use)
    -- local sold = (province.local_production[trade_good] or 0) + (province.local_storage[trade_good] or 0) / 12
    -- local bought = province.local_consumption[trade_good] or 0

    local sum_of_exponents, min_price = soft_max_data_for_use(province, use)

    -- calculate cost
    local total_cost = 0
    for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local weight = DATA.use_weight_get_weight(weight_id)
        local price = eco_values.get_local_price(province, trade_good)
        local prob_density = math.exp(-price + min_price) / sum_of_exponents
        local bought = 1 / weight * prob_density
        total_cost = total_cost + bought * price
    end

    return total_cost
end

---calculates price estimation of unit of use given a price table
---@param province province_id
---@param use use_case_id
---@param prices table<trade_good_id, number>
---@return number price
function eco_values.get_local_price_of_use_with_prices(province, use, prices)
    -- calculate min of prices:
    local min_price = nil

    for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local price = prices[trade_good]
        if min_price == nil then
            min_price = price
        else
            min_price = math.min(prices[trade_good], min_price)
        end
    end

    -- calculate sum of exponents
    local sum_of_exponents = 0
    for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local price = prices[trade_good]
        sum_of_exponents = sum_of_exponents + math.exp(
            -price + min_price
        )
    end

    sum_of_exponents = sum_of_exponents

    -- calculate cost
    local total_cost = 0
    for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local price = prices[trade_good]
        local weight = DATA.use_weight_get_weight(weight_id)
        local prob_density = math.exp(-price + min_price) / sum_of_exponents
        local bought = 1 / weight * prob_density
        total_cost = total_cost + bought * price
    end

    return total_cost
end

---comment
---@param province province_id
---@param trade_good trade_good_id
---@param amount number
---@param stockpile boolean
---@return number price
function eco_values.get_pessimistic_local_price(province, trade_good, amount, stockpile)
    local sold = DATA.province_get_local_production(province, trade_good)
    local bought = DATA.province_get_local_consumption(province, trade_good)
    local trade_volume = sold + bought + 0.001 + amount

    local sale_price_decrease = PRICE_SIGNAL_PER_STOCKPILED_UNIT * amount / trade_volume
    if not stockpile then
        sale_price_decrease = PRICE_SIGNAL_PER_UNIT * amount / (trade_volume + amount)
    end

    local pessimistic_price = math.max(0, (eco_values.get_local_price(province, trade_good) - sale_price_decrease))
    local optimistic_price = eco_values.get_local_price(province, trade_good)

    -- We need to take an average because otherwise selling by one will be far
    -- more profitable. Which rewards boring micromanagement.
    return (optimistic_price + pessimistic_price) / 2
end

---@param race race_id
---@param female boolean
---@param building_type BuildingType
function eco_values.race_throughput_multiplier(race, female, building_type)
    local method = DATA.building_type_get_production_method(building_type)
    local jobtype = DATA.production_method_get_job_type(method)
    if female then
        return DATA.race_get_female_efficiency(race, jobtype)
    end
    return DATA.race_get_male_efficiency(race, jobtype)
end

---@param race race_id
---@param female boolean
---@param building_type BuildingType
function eco_values.race_output_multiplier(race, female, building_type)
    local method = DATA.building_type_get_production_method(building_type)
    local jobtype = DATA.production_method_get_job_type(method)
    if female then
        return DATA.race_get_female_efficiency(race, jobtype)
    end
    return DATA.race_get_male_efficiency(race, jobtype)
end

---@param province province_id
---@param building_type BuildingType
function eco_values.projected_income_building_type_unknown_pop(province, building_type)
    local method = DATA.building_type_get_production_method(building_type)
    local shortage_modifier = eco_values.estimate_shortage(province, method)
    local income = 0
    for i = 0, MAX_SIZE_ARRAYS_PRODUCTION_METHOD - 1 do
        local input = DATA.production_method_get_inputs_use(method, i)
        if input == INVALID_ID then
            break
        end
        local amount = DATA.production_method_get_inputs_amount(method, i)
        local price = eco_values.get_local_price_of_use(province, input)
        ---@type number
        income = income - amount * price
    end

    for i = 0, MAX_SIZE_ARRAYS_PRODUCTION_METHOD - 1 do
        local output = DATA.production_method_get_outputs_good(method, i)
        if output == INVALID_ID then
            break
        end
        local amount = DATA.production_method_get_outputs_amount(method, i)
        local price = eco_values.get_local_price(province, output)
        ---@type number
        income = income + amount * price
    end

    return income * shortage_modifier
end

---@param province province_id
---@param building_type BuildingType
---@param race race_id
---@param female boolean
function eco_values.projected_income_building_type(province, building_type, race, female)
    local method = DATA.building_type_get_production_method(building_type)
    local shortage_modifier = eco_values.estimate_shortage(province, method)

    local throughput_boost =
        (1 + DATA.province_get_throughput_boosts(province, method))
        * eco_values.race_throughput_multiplier(race, female, building_type)

    local input_boost =
        math.max(0, 1 - DATA.province_get_input_efficiency_boosts(province, method))

    local output_boost =
        (1 + DATA.province_get_output_efficiency_boosts(province, method))
        * eco_values.race_output_multiplier(race, female, building_type)

    local income = 0
    for i = 0, MAX_SIZE_ARRAYS_PRODUCTION_METHOD - 1 do
        local input = DATA.production_method_get_inputs_use(method, i)
        if input == INVALID_ID then
            break
        end
        local amount = DATA.production_method_get_inputs_amount(method, i) * input_boost
        local price = eco_values.get_local_price_of_use(province, input)
        ---@type number
        income = income - amount * price
    end

    for i = 0, MAX_SIZE_ARRAYS_PRODUCTION_METHOD - 1 do
        local output = DATA.production_method_get_outputs_good(method, i)
        if output == INVALID_ID then
            break
        end
        local amount = DATA.production_method_get_outputs_amount(method, i)
        amount = amount * output_boost
        local price = eco_values.get_local_price(province, output)
        ---@type number
        income = income + amount * price
    end

    return income * shortage_modifier * throughput_boost
end


---Does not account for shortages: displays info based only on prices
---@param building Building
---@param race race_id
---@param female boolean
---@param prices table<trade_good_id, number>
---@param throughput_multiplier number
---@return number income, number input_boost, number output_boost, number throughput_boost
function eco_values.projected_income(building, race, female, prices, throughput_multiplier)
    local province = DATA.building_location_get_location(DATA.get_building_location_from_building(building))
    local building_type = DATA.building_get_type(building)
    local method = DATA.building_type_get_production_method(building_type)

    local throughput_boost =
        (1 + DATA.province_get_throughput_boosts(province, method))
        * eco_values.race_throughput_multiplier(race, female, building_type)
    local input_boost =
        math.max(0, 1 - DATA.province_get_input_efficiency_boosts(province, method))
    local output_boost =
        (1 + DATA.province_get_output_efficiency_boosts(province, method))
        * eco_values.race_output_multiplier(race, female, building_type)

    local income = 0
    for i = 0, MAX_SIZE_ARRAYS_PRODUCTION_METHOD - 1 do
        local input = DATA.production_method_get_inputs_use(method, i)
        if input == INVALID_ID then
            break
        end
        local amount = DATA.production_method_get_inputs_amount(method, i)
        amount = amount * throughput_multiplier * throughput_boost * input_boost
        local price = eco_values.get_local_price_of_use(province, input)
        ---@type number
        income = income - amount * price
    end

    for i = 0, MAX_SIZE_ARRAYS_PRODUCTION_METHOD - 1 do
        local output = DATA.production_method_get_outputs_good(method, i)
        if output == INVALID_ID then
            break
        end
        local amount = DATA.production_method_get_outputs_amount(method, i)
        amount = amount * throughput_multiplier * throughput_boost * output_boost
        local price = eco_values.get_local_price(province, output)
        ---@type number
        income = income + amount * price
    end

    return income, input_boost, output_boost, throughput_boost
end

---commenting
---@param province province_id
---@param use use_case_id
---@return number
function eco_values.available_use(province, use)
    -- calculate min of prices:
    local sum_of_exponents, min_price = soft_max_data_for_use(province, use)

    -- calculate total amount available for this distribution
    local available_use = 0
    -- use is divided between
    for _, weight_id in pairs(DATA.use_weight_from_use_case[use]) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local weight = DATA.use_weight_get_weight(weight_id)

        local price = eco_values.get_local_price(province, trade_good)
        local ratio_of_good = math.exp(-price + min_price) / sum_of_exponents
        local available = (DATA.province_get_local_production(province, trade_good))
                        - (DATA.province_get_local_consumption(province, trade_good))
                        + (DATA.province_get_local_storage(province, trade_good))

        local upped_bound = available * weight / ratio_of_good


        available_use = available_use + upped_bound
    end

    return available_use
end

---returns total amount of unit of use in local stockpile
---@param province province_id
---@param use use_case_id
---@return number total_amount
function eco_values.get_local_amount_of_use(province, use)
    local total_amount = 0
    for _, weight_id in pairs(DATA.get_use_weight_from_use_case(use)) do
        local trade_good = DATA.use_weight_get_trade_good(weight_id)
        local weight = DATA.use_weight_get_weight(weight_id)
        total_amount = total_amount + DATA.province_get_local_storage(province, trade_good) * weight
    end

    return total_amount
end

---Estimates shortage_modifier
---@param method production_method_id
function eco_values.estimate_shortage(province, method)
    local input_satisfaction = 1
    for i = 0, MAX_SIZE_ARRAYS_PRODUCTION_METHOD - 1 do
        local input = DATA.production_method_get_inputs_use(method, i)
        if input == INVALID_ID then
            break
        end
        local required_input = DATA.production_method_get_inputs_amount(method, i)
        local available = eco_values.available_use(province, input)
        local ratio = math.max(0, available) / required_input
        input_satisfaction = math.min(input_satisfaction, ratio)
    end

    return math.min(1, input_satisfaction)
end

---Returns total food supply from warband
---@param warband warband_id
---@return number
function eco_values.get_supply_available(warband)
	local leader = DATA.get_warband_leader_from_warband(warband)
	if leader == INVALID_ID then
		return 0
	end
	local pop = DATA.warband_leader_get_leader(leader)
	return eco_values.available_use_case_from_inventory(pop, CALORIES_USE_CASE)
end

---Returns available units for satisfying a use case from pop inventory
---@param pop pop_id
---@param use_case use_case_id
---@return number
function eco_values.available_use_case_from_inventory(pop, use_case)
	local supply = tabb.accumulate(DATA.use_weight_from_use_case[use_case], 0, function(a, _, weight_id)
		local good = DATA.use_weight_get_trade_good(weight_id)
		local weight = DATA.use_weight_get_weight(weight_id)
		local good_in_inventory = DATA.pop_get_inventory(pop, good)
		if good_in_inventory > 0 then
			a = a + good_in_inventory * weight
		end
		return a
	end)
	return supply
end

---Returns amount of days warband can travel depending on collected supplies
---@param warband warband_id
---@return number
function eco_values.days_of_travel(warband)
	local supplies = eco_values.get_supply_available(warband)
	local per_day = warband_utils.daily_supply_consumption(warband)

	if per_day == 0 then
		return 9999
	end

	return supplies / per_day
end

return eco_values