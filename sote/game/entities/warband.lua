local tabb = require "engine.table"
local pop_utils = require "game.entities.pop".POP

local party_utils = {}

-- values

---Returns a the highest ranking officer
---@param estate estate_id
---@return Character officer
function party_utils.active_leader(estate)
	local leader = DATA.estate_leader_get_leader(DATA.get_estate_leader_from_estate(estate))
	if leader ~= INVALID_ID then
		return leader
	end
	local recruiter = DATA.estate_recruiter_get_recruiter(DATA.get_estate_recruiter_from_estate(estate))
	if recruiter ~= INVALID_ID then
		return recruiter
	end
	local commander = DATA.estate_commander_get_commander(DATA.get_estate_commander_from_estate(estate))
	if commander ~= INVALID_ID then
		return commander
	end
	return INVALID_ID
end

---Returns a the lowest ranking officer
---@param estate estate_id
---@return Character officer
function party_utils.active_commander(estate)
	local commander = DATA.estate_commander_get_commander(DATA.get_estate_commander_from_estate(estate))
	if commander ~= INVALID_ID then
		return commander
	end
	local recruiter = DATA.estate_recruiter_get_recruiter(DATA.get_estate_recruiter_from_estate(estate))
	if recruiter ~= INVALID_ID then
		return recruiter
	end
	local leader = DATA.estate_leader_get_leader(DATA.get_estate_leader_from_estate(estate))
	if leader ~= INVALID_ID then
		return leader
	end
	return INVALID_ID
end

---@param estate estate_id
---@return number
function party_utils.loot_capacity(estate)
	return party_utils.total_hauling(estate)
end

---@param estate estate_id
---@return number
function party_utils.total_hauling(estate)
	local cap = 0
	DATA.for_each_estate_unit_from_estate(estate, function (item)
		local pop = DATA.estate_unit_get_pop(item)
		---@type number
		cap = cap + pop_utils.get_supply_capacity(pop)
	end)
	return cap
end

---@param estate estate_id
---@return number
function party_utils.current_hauling(estate)
	local total_weight = 0
	DATA.for_each_trade_good(function (item)
		-- TODO: implement weight of trade goods
		total_weight = total_weight + DATA.estate_get_inventory(estate, item)
	end)
	return total_weight
end

---Returns estates current spotting bonus
---@param estate estate_id
---@return number
function party_utils.spotting(estate)
	---@type number
	local result = 0

	for _, membership in ipairs(DATA.get_estate_unit_from_estate(estate)) do
		local pop = DATA.estate_unit_get_pop(membership)
		---@type number
		result = result + pop_utils.get_spotting(pop)
	end
	local status = DATA.estate_get_current_status(estate)
	-- patrolling increases spotting
	if status == ESTATE_STATUS.PREPARING_PATROL
		or status == ESTATE_STATUS.PATROL then
		result = result * 10
	-- not lollygagging
	elseif status ~= ESTATE_STATUS.OFF_DUTY
		and status ~= ESTATE_STATUS.IDLE
	then
		result = result * 5
	end
	return result
end

---Returns warbands current visibility
---@param estate estate_id
---@return number
function party_utils.visibility(estate)
	---@type number
	local result = 0
	for _, membership in ipairs(DATA.get_estate_unit_from_estate(estate)) do
		local pop = DATA.estate_unit_get_pop(membership)
		---@type number
		result = result + pop_utils.get_visibility(pop)
	end

	return result
end

---Returns the fighting sum of all units health, attack, armor, and speed along with count,
--- optionally include civilians as combatants
---@param estate estate_id
---@param civilian boolean?
---@return number total_health
---@return number total_attack
---@return number total_armor
---@return number total_speed
---@return number total_count
function party_utils.total_strength(estate, civilian)
	local total_health, total_attack, total_armor, total_speed, total_count = 0, 0, 0, 0 ,0
	for _, membership in ipairs(DATA.get_estate_unit_from_estate(estate)) do
		local pop = DATA.estate_unit_get_pop(membership)
		local unit_type = DATA.estate_unit_get_type(membership)
		if civilian or unit_type == UNIT_TYPE.WARRIOR then
			local health, attack, armor, speed = pop_utils.get_strength(pop)
			total_health = total_health + health
			total_attack = total_attack + attack
			total_armor = total_armor + armor
			total_speed = total_speed + speed
			total_count = total_count + 1
		end
	end
	return total_health, total_attack, total_armor, total_speed, total_count
end

---Total size of warband
---@param estate estate_id
---@return integer
function party_utils.size(estate)
	local result = tabb.size(DATA.get_estate_unit_from_estate(estate))
	return result
end

---Target size of warband
---@param estate estate_id
---@return integer
function party_utils.target_size(estate)
	local result = 0
	DATA.for_each_unit_type(function (item)
		result = result + DATA.estate_get_units_target(estate, item)
	end)

	return result
end

---Return the number of combat units
---@param estate estate_id
---@return integer
function party_utils.war_size(estate)
	return tabb.size(DATA.filter_estate_unit_from_estate(estate, function(item)
		local unit_type = DATA.estate_unit_get_type(item)
		return unit_type == UNIT_TYPE.WARRIOR
	end))
end

---Predicts upkeep given the current units target of warbands
---@param estate estate_id
---@return number
function party_utils.predict_upkeep(estate)
	local result = 0
	for _, membership in ipairs(DATA.get_estate_unit_from_estate(estate)) do
		local unit_type = DATA.estate_unit_get_type(membership)
		result = result + DATA.unit_type_get_base_cost(unit_type)
	end
	return result
end

---Returns monthly budget
---@param estate estate_id
---@return number
function party_utils.monthly_budget(estate)
	return DATA.state_get_treasury(estate) / 12
end

---Returs daily consumption of supplies.
---@param estate estate_id
---@return number
function party_utils.daily_supply_consumption(estate)
	local result = 0
	DATA.for_each_estate_unit_from_estate(estate, function(item)
		local pop = DATA.estate_unit_get_pop(item)
		---@type number
		result = result + pop_utils.get_supply_use(pop)
	end)

	return result * 0.25 --- made up value. raw value leads to VERY expensive trading
end

---@param estate estate_id
function party_utils.supplies_target(estate)
	return party_utils.daily_supply_consumption(estate) * DATA.estate_get_supplies_target_days(estate)
end

---Returns speed of exploration
---@param estate estate_id
---@return number
function party_utils.exploration_speed(estate)
	return party_utils.size(estate) * (1 - DATA.estate_get_current_time_used_ratio(estate))
end

return party_utils
