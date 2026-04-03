local realm_utils     = require "game.entities.realm".Realm
local cult            = require "game.entities.culture"
local rel             = require "game.entities.religion"
local pop_utils       = require "game.entities.pop".POP
local language_utils  = require "game.entities.language".Language
local tabb            = require "engine.table"
local tile_util       = require "game.entities.tile"

local tec             = require "game.raws.raws-utils".technology

local politics_values = require "game.raws.values.politics"

local province_utils  = require "game.entities.province".Province
local pe              = require "game.raws.effects.politics"

local st              = {}

---Makes a new realm, one province large.
---@param capitol_id Province
---@param center_id tile_id
---@param race_id race_id
---@param culture culture_id
---@param faith faith_id
---@param rite rite_id
local function make_new_realm(capitol_id, race_id, center_id, culture, faith, rite)
	-- print("new realm " .. DATA.race_get_name(race_id) .. " " .. DATA.culture_get_name(culture))

	local r = realm_utils.new()

	local fat = DATA.fatten_realm(r)
	fat.capitol = capitol_id
	realm_utils.add_province(r, capitol_id)
	realm_utils.explore(r, capitol_id)
	fat.primary_race = race_id

	local capitol = DATA.fatten_province(capitol_id)
	local race = DATA.fatten_race(race_id)

	fat.primary_culture = culture
	fat.primary_faith = faith

	-- Initialize realm colors
	fat.r = math.max(0, math.min(1, (DATA.culture_get_r(culture) + (love.math.random() * 0.4 - 0.2))))
	fat.g = math.max(0, math.min(1, (DATA.culture_get_g(culture) + (love.math.random() * 0.4 - 0.2))))
	fat.b = math.max(0, math.min(1, (DATA.culture_get_b(culture) + (love.math.random() * 0.4 - 0.2))))

	fat.name = language_utils.get_random_realm_name(DATA.culture_get_language(culture))

	-- set neighboring provinces to explored
	DATA.for_each_province_neighborhood_from_origin(capitol_id, function (item)
		realm_utils.explore(r, DATA.province_neighborhood_get_target(item))
	end)

	-- Mark the province as settled for processing...
	WORLD:set_settled_province(capitol_id)

	--calculate average racial foraging_efficiency from males per 100 females
	local male_percentage = race.males_per_hundred_females / (100 + race.males_per_hundred_females)

	-- create initial estate
	local estate = DATA.create_estate()
	DATA.force_create_estate_location(center_id, estate)
	DATA.estate_set_name(estate, language_utils.get_random_province_name(DATA.culture_get_language(culture)))
	DATA.estate_set_current_status(estate, ESTATE_STATUS.IDLE)
	DATA.tile_set_infrastructure(center_id, (love.math.random() * 0.5 + 0.25) -- 25-75% infrastructure on tile
		* ((1-male_percentage) * race.female_infrastructure_needs + male_percentage * race.male_infrastructure_needs))
	province_utils.research(estate, tec('paleolithic-knowledge'))

	-- spawn leader
	local elite_character = pe.generate_new_noble(r, estate, race_id, faith, culture, rite)
	local popularity = DATA.force_create_popularity(elite_character, r)
	local fat_popularity = DATA.fatten_popularity(popularity)
	fat_popularity.value = AGE_YEARS(elite_character) / 10
	pe.transfer_power(r, elite_character, POLITICS_REASON.INITIALRULER)
	DATA.force_create_ownership(estate, elite_character)
	require "game.raws.effects.warband".set_leader(estate, elite_character)

	-- -- We also need to spawn in some population...
	local pop_to_spawn = math.max(5,
		DATA.tile_get_foragers_limit(center_id) / race.carrying_capacity_weight)

	-- spawn some other nobles
	for i = 1, pop_to_spawn / 5 do
		local contender = pe.generate_new_noble(r, estate, race_id, faith, culture, rite)
		local popularity = DATA.force_create_popularity(contender, r)
		local fat_popularity = DATA.fatten_popularity(popularity)
		fat_popularity.value = AGE_YEARS(contender) / 15
	end

	-- spawn some base pop
	for _ = 1, pop_to_spawn do
		local age = math.floor(math.abs(love.math.randomNormal(race.adult_age, race.adult_age)) + 1)
		local new_pop = pop_utils.new(
			race_id,
			faith,
			rite,
			culture,
			love.math.random() > male_percentage,
			-age,
			love.math.random(1, WORLD.ticks_per_year)
		)
		require "game.raws.effects.warband".set_as_unit(estate, new_pop, UNIT_TYPE.CIVILIAN)
		province_utils.set_home(estate, new_pop)
	end

	-- to to find parents for children and babies
	DATA.for_each_estate_unit_from_estate(estate, function(item)
		local child = DATA.estate_unit_get_pop(item)
		local child_age = AGE_YEARS(child)
		if child_age > race.teen_age then
			return
		end
		local child_rank = IS_CHARACTER(child)
		---@type pop_id[]
		local parents = {}
		DATA.for_each_estate_unit_from_estate(estate, function(parent_location)
			local potential_parent_id = DATA.estate_unit_get_pop(parent_location)
			local age = AGE_YEARS(potential_parent_id)
			local rank = IS_CHARACTER(potential_parent_id)
			-- keep characters and pop families seperate
			if rank ~= child_rank then
				return
				-- make sure parent is old enough to have had this child
			elseif age <= child_age + race.teen_age then
				return
				-- make sure parent isn't too old to have had this child
			elseif age >= child_age + race.elder_age then
				return
			end
			table.insert(parents, potential_parent_id)
		end)
		local parent = tabb.random_select_from_array(parents)
		if parent then
			DATA.force_create_parent_child_relation(parent, child)
		end
	end)

	-- give some stuff to capitol
	capitol.local_wealth = love.math.random() * 10 + 10
	capitol.trade_wealth = love.math.random() * 10 + 10
	-- give initial research budget
	DATA.realm_set_budget_budget(r, BUDGET_CATEGORY.EDUCATION, 1)
	-- starting treasury
	fat.budget_treasury = love.math.random() * 20 + 20 --* pop_to_spawn

--[[
	-- give some realms early tech advantage to reduce waiting:
	for i = 0, 2 do
		---@type technology_id[]
		local to_research = {}
		DATA.for_each_technology(function(item)
			if DATA.province_get_technologies_researchable(capitol_id, item) == 1 then
				if love.math.random() < 0.1 then
					DATA.realm_inc_budget_budget(r, BUDGET_CATEGORY.EDUCATION, 1)
					table.insert(to_research, item)
				end
			end
		end)

		for _, item in pairs(to_research) do
			province_utils.research(capitol_id, item)
		end
	end
--]]

	-- capitol:validate_population()

	-- print("test battle")
	-- local size_1, size_2 = love.math.random(50) + 10, love.math.random(50) + 10
	-- local army_1 = generate_test_army(size_1, race, faith, culture, capitol)
	-- local army_2 = generate_test_army(size_2, race, faith, culture, capitol)

	-- print(size_2, size_1)
	-- local victory, losses, def_losses = army_2:attack(capitol, true, army_1)
	-- print(victory, losses, def_losses)
end

---checks if a given tile is habitable for a given race
---@param race_id race_id
---@param foragers_limit number
---@param ja_t number
---@param ju_t number
---@param elevation number
---@param has_forest boolean
---@param has_river boolean
---@return boolean
local function check_tile(race_id,foragers_limit,ja_t,ju_t,elevation,has_forest,has_river)
	if foragers_limit < 5 * DATA.race_get_carrying_capacity_weight(race_id) then return false end
	if DATA.race_get_requires_large_forest(race_id) and not has_forest then return false end
	if DATA.race_get_requires_large_river(race_id) and not has_river then return false end
	local min_elevation = DATA.race_get_minimum_comfortable_elevation(race_id)
	if (min_elevation > 0) and (min_elevation > elevation) then return false end
	if DATA.race_get_minimum_absolute_temperature(race_id) > math.min(ja_t, ju_t) then return false end
	if DATA.race_get_minimum_comfortable_temperature(race_id) > (ja_t + ju_t) / 2 then return false end
	return true
end

---picks tile with highest foragers_limit that is habitable by a given race
---@param province_id province_id
---@param race_id race_id
---@return tile_id
local function best_tile(province_id,race_id)
	local best,value = INVALID_ID, 0
	DATA.for_each_tile_province_membership_from_province(province_id, function (item)
		local tile_id = DATA.tile_province_membership_get_tile(item)
		local foragers_limit = DATA.tile_get_foragers_limit(tile_id)
		if foragers_limit > value then
			local has_forest = (DATA.tile_get_broadleaf(tile_id) + DATA.tile_get_conifer(tile_id)) > 0.5
			local has_river = DATA.tile_get_has_river(tile_id) or DATA.tile_get_has_marsh(tile_id)
			local ja_t,ju_t,elevation = DATA.tile_get_january_temperature(tile_id),
				DATA.tile_get_july_temperature(tile_id), DATA.tile_get_elevation(tile_id)
			if check_tile(race_id, foragers_limit, ja_t,ju_t,elevation,has_forest,has_river) then
				best = tile_id
				value = foragers_limit
			end
		end
	end)
	return best
end

---Spawns initial tribes and initializes their data (such as characters, cultures, religions, races, etc)
function st.run()
	---@type Queue<Province>
	local queue = require "engine.queue":new()

	-- order:
	-- river specialists races first
	-- forest specialists races second
	-- rest races at the end

	-- print("Decide spawn order for races")

	---@type table<race_id, table<tile_id, number>>
	local spawns_by_race = {}

	---@type Race[]
	local order = {}

	for _, r in pairs(RAWS_MANAGER.races_by_name) do
		if DATA.race_get_requires_large_river(r) then
			table.insert(order, r)
			spawns_by_race[r] = {}
		end
	end
	for _, r in pairs(RAWS_MANAGER.races_by_name) do
		if DATA.race_get_requires_large_forest(r) and not DATA.race_get_requires_large_river(r) then
			table.insert(order, r)
			spawns_by_race[r] = {}
		end
	end

	for _, r in pairs(RAWS_MANAGER.races_by_name) do
		if (not DATA.race_get_requires_large_forest(r)) and (not DATA.race_get_requires_large_river(r)) then
			table.insert(order, r)
			spawns_by_race[r] = {}
		end
	end

	-- local r = RAWS_MANAGER.races_by_name['high beaver']
	-- table.insert(order, r)
	-- spawns_by_race[r] = {}
	local civs = 500 / tabb.size(order) -- one per race...

	-- go through tiles and find possible tile spawns by race
	-- local total_tiles, land_tiles, forageable_tiles, forest_tiles, river_tiles, river_forest, tiles_alt, tiles_alto = 0, 0, 0, 0, 0, 0, 0, 0
	DATA.for_each_tile(function (tile_id)
		local foragers_limit = DATA.tile_get_is_land(tile_id) and DATA.tile_get_foragers_limit(tile_id) or 0
		-- total_tiles = total_tiles + 1
		if DATA.tile_get_is_land(tile_id) then
			-- land_tiles = land_tiles + 1
			if foragers_limit > 0 then
				local has_forest = (DATA.tile_get_broadleaf(tile_id) + DATA.tile_get_conifer(tile_id)) > 0.5
				local has_river = DATA.tile_get_has_river(tile_id) or DATA.tile_get_has_marsh(tile_id)
				local ja_t,ju_t,elevation = DATA.tile_get_january_temperature(tile_id),
					DATA.tile_get_july_temperature(tile_id), DATA.tile_get_elevation(tile_id)
				for _, r in ipairs(order) do
					if check_tile(r,foragers_limit,ja_t,ju_t,elevation,has_forest,has_river) then
						-- TODO build weight based on race
						spawns_by_race[r][tile_id] = foragers_limit
					end
				end
				-- forageable_tiles = forageable_tiles + 1
				-- if has_forest then
				-- 	forest_tiles = forest_tiles + 1
				-- 	if has_river then
				-- 		river_forest = river_forest + 1
				-- 		river_tiles = river_tiles + 1
				-- 	end
				-- elseif has_river then
				-- 	river_tiles = river_tiles + 1
				-- end
				-- if elevation >= 400 then
				-- 	tiles_alt = tiles_alt + 1
				-- 	if elevation >= 800 then
				-- 		tiles_alto = tiles_alto + 1
				-- 	end
				-- end
			end
		end
	end)
	-- print("Land tiles: " .. land_tiles .. " / " .. total_tiles)
	-- print("Forageable Tiles: " .. forageable_tiles .. " / " .. land_tiles)
	-- print("Forest Tiles: " .. forest_tiles .. " / " .. forageable_tiles)
	-- print("River Tiles: " .. river_tiles .. " / " .. forageable_tiles)
	-- print("River Forests: " .. river_forest .. " / " .. forageable_tiles)
	-- print("400+ Altitude: " .. tiles_alt .. " / " .. forageable_tiles)
	-- print("800+ Altitude: " .. tiles_alto .. " / " .. forageable_tiles)
	-- for r, l in pairs(spawns_by_race) do
	-- 	print(DATA.race_get_name(r) .. " " .. tabb.size(l))
	-- end

	---@type table<culture_id, province_id[]>
	local provinces_per_cultures = {}

	-- print("Spawn starting races")

	---comment
	---@param province_id province_id
	---@return boolean
	local function check_for_realms(province_id)
		if PROVINCE_REALM(province_id) ~= INVALID_ID then return true end
		local neighbors = false
		DATA.for_each_province_neighborhood_from_origin(province_id, function (item)
			local neighbor_id = DATA.province_neighborhood_get_target(item)
			local neighbor_realm = PROVINCE_REALM(neighbor_id)
			if neighbor_realm ~= INVALID_ID then neighbors = true end
		end)
		return neighbors
	end

	-- print(civs)
	for _i = 1, civs do
		for _, r in ipairs(order) do
			-- print("spawn " .. DATA.race_get_name(r))
			-- First, check if any possible tiles left
			if tabb.size(spawns_by_race[r]) > 0 then
				-- find a land tile that isn't owned by any realm...
				local sampled_tile = tabb.random_select(spawns_by_race[r])
				local prov = TILE_PROVINCE(sampled_tile)
				-- make sure each neighbor is free
				while prov and check_for_realms(prov) do
					-- no longer valid spawn because of neighboring realms
					for race, list in pairs(spawns_by_race) do
						if list[sampled_tile] then
							list[sampled_tile] = nil
						end
					end
					if tabb.size(spawns_by_race[r]) > 0
					then
						sampled_tile = tabb.random_select(spawns_by_race[r])
						prov = TILE_PROVINCE(sampled_tile)
					else
						prov = nil
					end
				end
				-- check if actually found valid tile
				if prov then
					-- remove province tiles from all tile lists to prevent looping
					DATA.for_each_tile_province_membership_from_province(prov, function (membership)
						local tile_id = DATA.tile_province_membership_get_tile(membership)
						for race, list in pairs(spawns_by_race) do
							if list[tile_id] then
								list[tile_id] = nil
							end
						end
					end)
					-- create new culture
					local cg = cult.CultureGroup:new()
					local culture = cult.Culture:new(cg)
					DATA.culture_set_traditional_militarization(culture, 0.05 + 0.1 * love.math.random())
					provinces_per_cultures[culture] = {}
					table.insert(provinces_per_cultures[culture], prov)
					-- create new faith
					local rg = rel.Religion:new(culture)
					local faith = rel.Faith:new(rg, culture)
					local rite = rel.Rite:new(faith, culture)
					DATA.faith_set_burial_rites(faith, tabb.select_one(love.math.random(), {
						{
							weight = 1,
							entry = BURIAL_RIGHTS.BURIAL
						},
						{
							weight = 0.8,
							entry = BURIAL_RIGHTS.CREMATION
						},
						{
							weight = 0.2,
							entry = BURIAL_RIGHTS.NONE
						}
					}))
					make_new_realm(prov, r, best_tile(prov, r), culture, faith, rite)
					-- give first spawn dibs an all favorable neighbors to soften possible clustering
					DATA.for_each_province_neighborhood_from_origin(prov, function (item)
						local neighbor_id = DATA.province_neighborhood_get_target(item)
						if DATA.tile_get_is_land(DATA.province_get_center(neighbor_id)) then
							local neighbor_center = best_tile(neighbor_id,r)
							if neighbor_center ~= INVALID_ID then
								make_new_realm(neighbor_id, r, neighbor_center, culture, faith, rite)
								table.insert(provinces_per_cultures[culture], neighbor_id)
								-- remove province tiles from all race tile lists to prevent looping
								DATA.for_each_tile_province_membership_from_province(neighbor_id, function (membership)
									local tile_id = DATA.tile_province_membership_get_tile(membership)
									for race, list in pairs(spawns_by_race) do
										if list[tile_id] then
											list[tile_id] = nil
										end
									end
								end)
								queue:enqueue(neighbor_id)
							end
						end
					end)
				end
			end
		end
	end

	print("Flood fill the rest of the world")
	-- Loop through all entries in the queue and flood fill out
	while queue:length() > 0 do
		---@type Province
		local prov = queue:dequeue()
		local fat_prov = DATA.fatten_province(prov)
		local realm = province_utils.realm(prov)
		local culture = DATA.realm_get_primary_culture(realm)
		local race = DATA.realm_get_primary_race(realm)
		local faith = DATA.realm_get_primary_faith(realm)
		local rite = DATA.faith_get_rite(faith)
		if rite == nil then
			rite = rel.Rite:new(faith, culture)
		end


		-- First, check for rng based on movement cost.
		-- This will make it so culture "expand" slowly through mountains and such.
		if (love.math.random() > 0.001 + fat_prov.movement_cost / 1000.0) or fat_prov.on_a_river then
			DATA.for_each_province_neighborhood_from_origin(prov, function(item)
				local neigh = DATA.province_neighborhood_get_target(item)
				local fat_neigh = DATA.fatten_province(neigh)
				-- must be land
				if not DATA.tile_get_is_land(fat_neigh.center) then return end
				local neigh_realm = PROVINCE_REALM(neigh)
				-- must have no realm
				if neigh_realm ~= INVALID_ID then return end
				-- must have a valid spawn tile
				local neigh_best = best_tile(neigh,race)
				if neigh_best == INVALID_ID then return end
				-- TODO use travel stats or mechanics
				-- local river_bonus = 1
				-- if fat_prov.on_a_river and fat_neigh.on_a_river then
				-- 	river_bonus = 0.25
				-- end
				-- if DATA.race_get_requires_large_river(race) then
				-- 	if fat_neigh.on_a_river then
				-- 		river_bonus = 0.001
				-- 	else
				-- 		river_bonus = 1000
				-- 	end
				-- end
				-- if (love.math.random() > 0.001 + fat_neigh.movement_cost / 1000.0 * river_bonus) then
				--	if DATA.tile_get_is_land(fat_neigh.center) == DATA.tile_get_is_land(fat_prov.center)
				--	then
						-- We can spawn a new realm in this province! It's unused!
						make_new_realm(
							neigh,
							race,
							neigh_best,
							culture,
							faith,
							rite
						)
						table.insert(provinces_per_cultures[culture], neigh)
						queue:enqueue(neigh)
				--	end
				-- end
			end)
		else
			-- queue:enqueue(prov)
		end
	end


	--- recalculate dbm weights
	for culture, provs in pairs(provinces_per_cultures) do
		---@type table<production_method_id, number>
		local total_weights = {}
		local total_population = 0

		for _, prov in ipairs(provs) do
			DATA.for_each_tile_province_membership_from_province(prov, function (membership)
				local tile_id = DATA.tile_province_membership_get_tile(membership)
				local dbm_weights, local_population = require "game.economy.diet-breadth-model".cultural_foragable_targets(tile_id, culture)
				for i, j in pairs(dbm_weights) do
					total_weights[i] = (total_weights[i] or 0) + dbm_weights[i] * local_population
				end
				total_population = total_population + local_population
			end)
		end

		for i, j in pairs(total_weights) do
			total_weights[i] = total_weights[i] / total_population
			DATA.culture_set_traditional_forager_targets(culture, i, total_weights[i])
		end
	end

	local realms = 0
	DATA.for_each_realm(function(item)
		realms = realms + 1
	end)

	-- At the end, print the amount of spawned tribes
	print("Spawned tribes:", realms)
	local pops = 0
	local characters = 0
	DATA.for_each_province(function(item)
		pops = pops + province_utils.local_population(item)
		characters = characters + province_utils.local_characters(item)
	end)
	print("Spawned population: " .. tostring(pops))
	print("Spawned characters: " .. tostring(characters))
end

return st
