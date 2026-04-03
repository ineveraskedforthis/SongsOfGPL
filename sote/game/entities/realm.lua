local realm_utils = {}
local tabb = require "engine.table"

local province_utils = require "game.entities.province".Province
local army_utils = require "game.entities.army"
local warband_utils = require "game.entities.warband"

realm_utils.Realm = {}

function realm_utils.Realm.new()
	local realm_id = DATA.create_realm()
	local o = DATA.fatten_realm(realm_id)

	DATA.realm_set_quests_explore(realm_id, {})
	DATA.realm_set_quests_patrol(realm_id, {})
	DATA.realm_set_quests_raid(realm_id, {})
	DATA.realm_set_patrols(realm_id, {})

	-- print("new realm")

	o.name = "<realm>"
	o.r = love.math.random()
	o.g = love.math.random()
	o.b = love.math.random()
	o.trading_right_cost = 10
	o.law_trade = LAW_TRADE.LOCALS_ONLY
	o.building_right_cost = 50
	o.law_building = LAW_BUILDING.LOCALS_ONLY
	o.known_provinces = {}
	o.coa_base_r = love.math.random()
	o.coa_base_g = love.math.random()
	o.coa_base_b = love.math.random()
	o.coa_background_r = love.math.random()
	o.coa_background_g = love.math.random()
	o.coa_background_b = love.math.random()
	o.coa_foreground_r = love.math.random()
	o.coa_foreground_g = love.math.random()
	o.coa_foreground_b = love.math.random()
	o.coa_emblem_r = love.math.random()
	o.coa_emblem_g = love.math.random()
	o.coa_emblem_b = love.math.random()
	-- print("bbb")
	o.coa_background_image = love.math.random(#ASSETS.coas)
	o.coa_foreground_image = love.math.random(#ASSETS.coas)
	o.patrols = {}

	o.quests_explore = {}
	o.quests_patrol = {}
	o.quests_raid = {}

	o.exists = true

	-- print("bb")
	if love.math.random() < 0.6 then
		o.coa_emblem_image = love.math.random(#ASSETS.emblems)
	else
		o.coa_emblem_image = 0 -- have a lot of "empty" emblems so that not everything is a frog
	end

	return realm_id
end

function realm_utils.Realm.size(realm)
	local result = 0
	DATA.for_each_realm_provinces_from_realm(realm, function (item)
		result = result + 1
	end)

	return result
end

---Adds a province to the realm. Handles removal of the province from the previous owner.
---@param realm Realm
---@param prov Province
function realm_utils.Realm.add_province(realm, prov)
	local membership = DATA.get_realm_provinces_from_province(prov)
	if membership ~= INVALID_ID then
		DATA.realm_provinces_set_realm(membership, realm)
	else
		DATA.force_create_realm_provinces(prov, realm)
	end
end

---Removes province from realm. Does not handle any additional logic!
---@param realm Realm
---@param prov Province
function realm_utils.Realm.remove_province(realm, prov)
	local membeship = DATA.get_realm_provinces_from_province(prov)
	if membeship ~= INVALID_ID then
		DATA.delete_realm_provinces(membeship)
	end
end


---@param realm Realm
---@return province_id
function realm_utils.Realm.get_random_province(realm)
	local n = #DATA.get_realm_provinces_from_realm(realm)
	local membership = DATA.get_realm_provinces_from_realm(realm)[love.math.random(n)]
	if membership then
		return DATA.realm_provinces_get_province(membership)
	else
		return INVALID_ID
	end
end

---Removes warband as potential patrol of province
---@param realm Realm
---@param prov Province
---@param warband Warband
function realm_utils.Realm.remove_patrol(realm, prov, warband)
	if DATA.realm_get_patrols(realm)[prov] then
		DATA.realm_get_patrols(realm)[prov][warband] = nil
		DATA.warband_set_current_status(warband, ESTATE_STATUS.IDLE)
	end
end

---Adds a province to the explored provinces list.
---@param realm Realm
---@param province Province
function realm_utils.Realm.explore(realm, province)
	DATA.realm_get_known_provinces(realm)[province] = province
	DATA.for_each_province_neighborhood_from_origin(province, function (item)
		local n = DATA.province_neighborhood_get_target(item)
		DATA.realm_get_known_provinces(realm)[n] = n
	end)
end

---Returns a percentage describing the education investments
---@param realm Realm
---@return number
function realm_utils.Realm.get_education_efficiency(realm)
	local result = 0
	local target = DATA.realm_get_budget_target(realm, BUDGET_CATEGORY.EDUCATION)
	if target > 0 then
		local budget = DATA.realm_get_budget_budget(realm, BUDGET_CATEGORY.EDUCATION)
		result = budget / target
	end
	return result
end

---@param realm Realm
---@return number
function realm_utils.Realm.get_court_efficiency(realm)
	local result = 0
	local target = DATA.realm_get_budget_target(realm, BUDGET_CATEGORY.COURT)
	if target > 0 then
		local budget = DATA.realm_get_budget_budget(realm, BUDGET_CATEGORY.COURT)
		result = budget / target
	end
	return result
end

---@param realm Realm
---@return number
function realm_utils.Realm.get_speechcraft_efficiency(realm)
	local cc = 0.5 + realm_utils.Realm.get_court_efficiency(realm)
	return cc
end

---@param realm Realm
---@return number
function realm_utils.Realm.get_average_mood(realm)
	local mood = 0
	local pop = 0
	DATA.for_each_realm_provinces_from_realm(realm, function (item)
		local province = DATA.realm_provinces_get_province(item)
		local po = province_utils.local_population(province)
		mood = mood + DATA.province_get_mood(province) * po
		pop = pop + po
	end)
	return mood / pop
end

---@param realm Realm
---@return number
function realm_utils.Realm.get_average_needs_satisfaction(realm)
	local sum = 0
	local total_population = 1
	DATA.for_each_realm_provinces_from_realm(realm, function (provinces)
		local province = DATA.realm_provinces_get_province(provinces)
		DATA.for_each_tile_province_membership_from_province(province, function (membership)
			local tile = DATA.tile_province_membership_get_tile(membership)
			DATA.for_each_estate_location_from_tile(tile, function (location)
				local estate = DATA.estate_location_get_estate(location)
				DATA.for_each_estate_unit_from_estate(estate, function (item)
					local pop = DATA.estate_unit_get_pop(item)
					local fat = DATA.fatten_pop(pop)
					sum = sum + fat.basic_needs_satisfaction + fat.life_needs_satisfaction
					total_population = total_population + 1
				end)
			end)
		end)
	end)
	return sum / total_population
end

---@param realm Realm
---@return number
function realm_utils.Realm.get_realm_population(realm)
	local total = 0
	DATA.for_each_realm_provinces_from_realm(realm, function (location)
		local province = DATA.realm_provinces_get_province(location)
		total = total + province_utils.all_home_population(province)
	end)
	return total
end

---@param realm Realm
---@return number
function realm_utils.Realm.get_realm_ready_military(realm)
	local total = 0
	DATA.for_each_realm_provinces_from_realm(realm, function (location)
		local province = DATA.realm_provinces_get_province(location)
		total = total + province_utils.military(province)
	end)
	return total
end

---Checks is this realm is a subject
---@param realm Realm
---@return boolean
function realm_utils.Realm.is_subject(realm)
	local pays_tribute = false
	DATA.for_each_realm_subject_relation_from_subject(realm, function (item)
		pays_tribute = true
	end)
	return pays_tribute
end

---@param realm Realm
---@param sources? table<Realm, Realm>
---@param depth? number
function realm_utils.Realm.get_top_realm(realm, sources, depth)
	local depth = depth or 0
	---@type table<Realm, Realm>
	local sources = sources or {}

	if tabb.size(sources) == 0 then sources[realm] = realm end

	---@type table<Realm, Realm>
	local result = {}

	local pays_tribute = realm_utils.Realm.is_subject(realm)

	if not pays_tribute or (sources[realm] and depth > 0) then
		result[realm] = realm
		return result
	else
		sources[realm] = realm
		DATA.for_each_realm_subject_relation_from_subject(realm, function (item)
			local top_dog = DATA.realm_subject_relation_get_overlord(item)
			local top_dogs = realm_utils.Realm.get_top_realm(top_dog, sources, depth + 1)
			for k, v in pairs(top_dogs) do
				result[k] = v
			end
		end)
		return result
	end
end

---@param realm Realm
---@param realm_to_check_for Realm
---@param sources? table<Realm, Realm>
---@param depth? number
function realm_utils.Realm.is_realm_in_hierarchy(realm, realm_to_check_for, sources, depth)
	if realm == realm_to_check_for then
		return true
	end

	local depth = depth or 0
	local sources = sources or {}
	if tabb.size(sources) == 0 then sources[realm] = realm end

	local pays_tribute = realm_utils.Realm.is_subject(realm)

	if not pays_tribute or (sources[realm] and depth > 0) then
		return false
	else
		sources[realm] = realm

		local result = false

		DATA.for_each_realm_subject_relation_from_subject(realm, function (item)
			local top_dog = DATA.realm_subject_relation_get_overlord(item)
			result = result or realm_utils.Realm.is_realm_in_hierarchy(top_dog, realm_to_check_for, sources, depth + 1)
		end)

		return result
	end
end


---Raise local army
---@param realm Realm
---@param province Province
---@return warband_id[]
function realm_utils.Realm.available_defenders(realm, province)
	local result = {}

	if realm_utils.Realm.size(realm) == 0 then
		return result
	end

	DATA.for_each_warband_location_from_location(DATA.province_get_center(province), function (item)
		local warband = DATA.warband_location_get_warband(item)
		local status = DATA.warband_get_current_status(warband)
		if status == ESTATE_STATUS.PATROL then
			table.insert(result, warband)
		end
	end)
	return result
end

---@param realm Realm
---@return number
function realm_utils.Realm.get_total_population(realm)
	return realm_utils.Realm.get_realm_population(realm) + realm_utils.Realm.get_realm_ready_military(realm)
end

---@param realm Realm
---@return Warband[]
function realm_utils.Realm.get_warbands(realm)
	local res = {}

	DATA.for_each_realm_provinces_from_realm(realm, function (item)
		local part_of_the_realm = DATA.realm_provinces_get_province(item)
		DATA.for_each_warband_location_from_location(DATA.province_get_center(part_of_the_realm), function (location)
			table.insert(res, DATA.warband_location_get_warband(location))
		end)
	end)

	return res
end

---Returns true if the realm neighbors other
---@param realm Realm
---@param other Realm
---@return boolean
function realm_utils.Realm.neighbors_realm(realm, other)
	local check = false
	DATA.for_each_realm_provinces_from_realm(realm, function (item)
		local part_of_the_realm = DATA.realm_provinces_get_province(item)
		if province_utils.neighbors_realm(part_of_the_realm, other) then
			check = true
		end
	end)
	return check
end

---Returns whether or not a province borders a given realm
---@param province province_id
---@param realm Realm
---@return boolean
function realm_utils.Realm.neighbors_realm_tributary(province, realm)
	for _, n in pairs(DATA.get_province_neighborhood_from_origin(province)) do
		local neighbor = DATA.province_neighborhood_get_target(n)
		local neighbor_realm = province_utils.realm(neighbor)

		if neighbor_realm and realm_utils.Realm.is_realm_in_hierarchy(neighbor_realm, realm) then
			return true
		end
	end
	return false
end

---Returns whether or not a realm is at war with another.
---@param realm Realm
---@param other Realm
---@return boolean
function realm_utils.Realm.at_war_with(realm, other)
	return false
	-- for war, _ in pairs(self.wars) do
	-- 	-- Find if we're attacking or defending
	-- 	local attacking = false
	-- 	for r, _ in pairs(war.attackers) do
	-- 		if r == self then
	-- 			attacking = true
	-- 			break
	-- 		end
	-- 	end
	-- 	if attacking then
	-- 		for r, _ in pairs(war.defenders) do
	-- 			if r == other then
	-- 				return true
	-- 			end
	-- 		end
	-- 	else
	-- 		for r, _ in pairs(war.attackers) do
	-- 			if r == other then
	-- 				return true
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- return false
end

return realm_utils
