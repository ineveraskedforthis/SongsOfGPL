local tabb = require "engine.table"
local province_utils = require "game.entities.province".Province

local retrieve_good = require "game.raws.raws-utils".trade_good

local dbm = {}

---@param culture culture_id
---@return string tooltip
function dbm.culture_target_tooltip(culture)
	local ut = require "game.ui-utils"
	local result = "\n · Gathering (in % of total foraging time): \n"

	DATA.for_each_production_method(function (item)
		local ratio = DATA.culture_get_traditional_forager_targets(culture, item)
		if ratio > 0.001 then
			result = result .. "\n    · "
				.. DATA.production_method_get_name(item)
				.. " (" .. ut.to_fixed_point2(ratio * 100) .. "%)"
		end
	end)

	return result
end

---@param carrying_capacity number
---@param foragers number
function dbm.foraging_efficiency(carrying_capacity, foragers)
	-- when over CC, divide available goods by foragers
	if foragers > carrying_capacity then
		return carrying_capacity / foragers
	else -- give a boost from being under CC to represent increasing in standing crop/stock
		return 2 - math.exp(-0.7*(carrying_capacity - foragers)/carrying_capacity)
	end
end

---@param tile_id tile_id
---@return number hydration
---@return number primary_production
---@return number game_production
---@return number marine_production
---@return number wood_production
function dbm.total_production(tile_id)
	return DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.WATER),
		DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.PLANT),
		DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.GAME),
		DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.FISH),
		DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.WOOD)
end

---@alias NeedUseCaseAmount {need: NEED, use_case: use_case_id, amount: number}

-- get average local needs and efficiencies of local culture
---@param tile_id tile_id
---@param culture_id culture_id
---@return NeedUseCaseAmount[] food_needs_by_use
---@return table<production_method_id,number> job_efficienceis
---@return number total_pop
function dbm.cultural_food_needs(tile_id, culture_id)
	---@type table<use_case_id, number>
	local food_needs, jobtype_skill, total_pop = {}, {}, 0

	DATA.for_each_estate_location_from_tile(tile_id, function (location)
		local estate = DATA.estate_location_get_estate(location)
		DATA.for_each_estate_unit_from_estate(estate, function (item)
			local pop_id = DATA.estate_unit_get_pop(item)
			if DATA.pop_get_culture(pop_id) == culture_id then
				total_pop = total_pop + 1
				-- food needs
				for i = 1, MAX_NEED_SATISFACTION_POSITIONS_INDEX do
					local need = DATA.pop_get_need_satisfaction_need(pop_id, i)
					if (need == NEED.FOOD) then
						local use_case = DATA.pop_get_need_satisfaction_use_case(pop_id, i)
						local amount = DATA.pop_get_need_satisfaction_demanded(pop_id, i)
						-- overestimate needed water:
						if use_case == WATER_USE_CASE then
							amount = amount * 1.5
						end
						food_needs[use_case] = (food_needs[use_case] or 0) + amount
					end
				end
				-- job efficiency
				DATA.for_each_jobtype(function (item)
					jobtype_skill[item] = (jobtype_skill[item] or 0) + JOB_EFFICIENCY(pop_id,item)
				end)
			end
		end)
	end)

	local food_needs_by_use = {}
	for i, j in pairs(food_needs) do
		table.insert(food_needs_by_use, {use_case = i, need = NEED.FOOD, amount = j/total_pop})
	end
	for i, j in pairs(jobtype_skill) do
		jobtype_skill[i] = j / total_pop
	end

	return food_needs_by_use, jobtype_skill, total_pop
end


---@class (exact) TargetResourceTable
---@field forage_resource FORAGE_RESOURCE
---@field search_time number
---@field handle_time number
---@field output number
---@field output_energy number
---@field energy_return_per_unit_of_time number

---@class (exact) TargetNeedsTable
---@field use_case use_case_id
---@field required_amount_of_use number
---@field total_search_time number
---@field total_handle_time number
---@field total_energy_output number
---@field average_energy_return_per_unit_of_time number
---@field data_per_forage_target table<production_method_id, TargetResourceTable>

---finds potential foraging targets for tile with efficiencies
---@param tile_id any
---@return table<production_method_id,number>
function dbm.local_foraging_methods(tile_id)
	local methods = {}
	DATA.for_each_production_method(
		function (production_method)
			local foraging = DATA.production_method_get_foraging(production_method)
			if foraging ~= FORAGE_RESOURCE.INVALID
				and DATA.tile_get_foragers_targets_limit(tile_id,foraging) > 0
			then
				methods[production_method] = DATA.tile_get_foragers_targets_limit(tile_id,foraging)
			end
		end)
	return methods
end

---commenting
---@param good trade_good_id
---@param use_case use_case_id
---@param amount number
---@return number
local function turn_output_to_energy(good, use_case, amount)
	local weight = USE_WEIGHT[good][use_case]
	-- print("  GOOD: " .. DATA.trade_good_get_name(good) .. ", AMOUNT: " .. amount .. ", WEIGHT: " .. weight .. ", ENERGY: " .. (weight * amount))
	return weight * amount
end

---commenting
---@param foraging_methods table<production_method_id,number>
---@param efficiencies table<production_method_id,number>
---@param tile_id tile_id
---@param use_case use_case_id
---@param needed number
---@return TargetNeedsTable
local function forage_targets_for_a_given_use_case(foraging_methods, efficiencies, tile_id, use_case, needed)
	-- print("USE: " .. DATA.use_case_get_name(use_case) .. ", NEEDED: " .. needed)
	-- have tile size variable, lat lon calculated?
	local tile_size = 10

	local total_search = 0
	local total_output = 0
	local total_handle = 0
	local total_energy_output = 0

	---@type table<production_method_id,TargetResourceTable>
	local data_per_forage_target = {}

	-- for each production method...
	for method, value in pairs(foraging_methods) do
		local forage_case = DATA.production_method_get_foraging(method)
		local required_job = DATA.production_method_get_job_type(method)
		-- get production output in use case
		local energy = 0
		for i = 1, MAX_SIZE_ARRAYS_PRODUCTION_METHOD do
			local output_good = DATA.production_method_get_outputs_good(method, i)
			local output_amount = DATA.production_method_get_outputs_amount(method, i)
			if output_good == INVALID_ID then
				break
			end
			-- get production output in use case
			energy = energy + turn_output_to_energy(output_good, use_case, output_amount) -- per collected unit
		end

		-- print("forage resource")

		---@type number
		-- calculate based on speed and/or terrain?
		local search_time = tile_size -- total searching time to find everything
		local efficiency = efficiencies[required_job] -- efficiency of actually collecting the thing
		local handle_time = value / efficiency -- time spent to collect everything
		local total_energy = energy * value -- total collected "energy"

		assert(handle_time == handle_time, tostring(handle_time))
		assert(efficiency > 0, tostring(efficiency) .. DATA.jobtype_get_name(required_job) .. efficiency)

		data_per_forage_target[method] = {
			forage_resource = forage_case,
			search_time = search_time,
			handle_time = handle_time,
			output = value,
			output_energy = total_energy,
			energy_return_per_unit_of_time = total_energy / (search_time + handle_time)
		}
		-- print(DATA.forage_resource_get_name(forage_case),search_time, handle_time, value, total_energy,total_energy / (search_time + handle_time))

		---@type number
		total_search = total_search + search_time
		---@type number
		total_handle = total_handle + handle_time
		---@type number
		total_output = total_output + value
		---@type number
		total_energy_output = total_energy_output + total_energy
	end

	---@type TargetNeedsTable
	local result = {
		use_case = use_case,
		required_amount_of_use = needed,
		total_handle_time = total_handle,
		total_search_time = total_search,
		total_energy_output = total_energy_output,
		average_energy_return_per_unit_of_time = total_energy_output / (total_handle + total_search),
		data_per_forage_target = data_per_forage_target
	}
	-- print("",DATA.use_case_get_name(use_case),total_search, total_handle, needed, total_energy_output, total_energy_output / (total_handle + total_search))

	return result
end


---Sets weights of targets below average return to 0
---Sets weights of other targets to their return
---@param forage_targets_data TargetNeedsTable
---@return number[]
local function use_case_data_to_weights(forage_targets_data)
	---@type number[]
	local weights = {}


	for i, data in pairs(forage_targets_data.data_per_forage_target) do
		local return_this = data.energy_return_per_unit_of_time
		if return_this < return_average * 0.5 then
			weights[i] = 0
		else
			weights[i] = return_this
		end

		-- if weights[i] ~= weights[i] then
		-- 	tabb.print(data)
		-- end

		assert(weights[i] == weights[i], "INVALID WEIGHT")
	end

	return weights
end

---@param use_cases_data TargetNeedsTable[]
---@return number[][] weights
local function calculate_weights(use_cases_data)
	---@type number[][]
	local weights = {}

	-- init weights with filtered returns + smoothing:
	local sum_of_weights = 0
	for i, targets_table in pairs(use_cases_data) do
		weights[i] = {}
		local return_average = targets_table.average_energy_return_per_unit_of_time
		for j, target_data in pairs(targets_table.data_per_forage_target) do
			local return_this = target_data.energy_return_per_unit_of_time
			-- if return_this < return_average * 0.5 then
			-- 	weights[i][j] = 0 + 0.01
			-- else
			-- 	weights[i][j] = return_this + 0.01
			-- end
			-- sum_of_weights = sum_of_weights + weights[i][j]
			weights[i][j] = 0
		end
	end

	local smoothing = 0.00001

	--- do several epochs to get close to solution: writing proper solver of such equations is out of question... for now
	local num_of_iterations = 100000
	LOGS:write("?????????????\n")
	for i, targets_table in pairs(use_cases_data) do
		LOGS:write(DATA.use_case_get_name(targets_table.use_case) .. "\n")
		local step = 0.1
		---@type nil|number
		local last = nil
		for iteration = 1, num_of_iterations do
			--- we want to maximize needs satisfaction and avoid overproduction
			--- so we use this pretty dumb "walk"
			--- decide if we want to reduce production or increase it:

			local required = targets_table.required_amount_of_use
			local provided = 0

			for j, target_data in pairs(targets_table.data_per_forage_target) do
				provided = provided
					+ weights[i][j]
					* (target_data.handle_time + target_data.search_time)
					* target_data.energy_return_per_unit_of_time
			end

			LOGS:write(tostring(iteration) .. "\t" .. tostring(required - provided) .. "\t" .. step .. "\t" .. tostring(provided) .. "/" .. tostring(required) .. "\n")
			--- next we reduce/increase weights depending on their efficiency
			--- obviously we want to get rid of weak sources and increase reliance on strong
			--- but without being overzealous
			local current_loss = required - provided
			if last == nil then
				last = current_loss
			else
				if math.abs(math.abs(current_loss) - math.abs(last)) < 0.001 then
					step = 2 * step
				elseif math.abs(math.abs(current_loss) - math.abs(last)) < 0.01 then
					step = 1.2 * step
				elseif math.abs(math.abs(current_loss) - math.abs(last)) / math.abs(current_loss) < 0.01 then
					step = step * 2
				elseif current_loss * last < 0 then
					step = step / 2
				end
			end

			last = current_loss

			if math.abs(current_loss) < 0.01 then
				break
			end

			if provided < required then
				for j, target_data in pairs(targets_table.data_per_forage_target) do
					weights[i][j] =
						weights[i][j]
						+ math.min(0.01, -- doesn't cut nans in min but would if max
							(required - provided)
							* step
							/ (target_data.handle_time + target_data.search_time + 1)
							/ (target_data.energy_return_per_unit_of_time + 1)
							* target_data.output_energy,
							0.01 -- cuts nans for min but not if max
						)
					-- assert(weights[i][j] == weights[i][j])
				end
			else
				for j, target_data in pairs(targets_table.data_per_forage_target) do
					weights[i][j] = math.max(
						0,
						weights[i][j]
						- math.min(0.01, -- doesn't cut nans in min but would if max
							(provided - required)
							* step
							/ (target_data.handle_time + target_data.search_time + 1)
							/ (target_data.energy_return_per_unit_of_time + 1)
							* math.exp(-target_data.output_energy / 1000),
							0.01 -- cuts nans for min but not if max
						)
					)
					-- assert(weights[i][j] == weights[i][j],
					-- 	"(provided - required) " .. tostring(provided - required) ..
					-- 	"\n* step " .. tostring(step) ..
					-- 	"\n/ (target_data.handle_time + target_data.search_time + 1)" .. tostring((target_data.handle_time + target_data.search_time + 1)) ..
					-- 	"\n/ (target_data.energy_return_per_unit_of_time + 1)" .. tostring(target_data.energy_return_per_unit_of_time + 1)..
					-- 	"\n* math.exp(-target_data.output_energy / 1000)" .. tostring(math.exp(-target_data.output_energy / 1000)).. "\n"
					-- )
				end
			end
		end
	end

	--- calculate norm: total time required to gather according to weights
	--- and then normalize out timetable
	--- spice up with smoothing so it's not too boring

	local norm = 0
	local smooth_sum = 0
	for i, targets_table in pairs(use_cases_data) do
		for j, target_data in pairs(targets_table.data_per_forage_target) do
			---@type number
			norm = norm + (weights[i][j] + smoothing) * (target_data.handle_time + target_data.search_time)
		end
	end

	-- tabb.deep_print(weights)
	if norm > 0 then
		sum_of_weights = 0
		for i, targets_table in pairs(use_cases_data) do
			for j, target_data in pairs(targets_table.data_per_forage_target) do
				---@type number
				weights[i][j] = (weights[i][j] + smoothing) / norm
				sum_of_weights = sum_of_weights + weights[i][j]
			end
		end
	end

	return weights
end

---@param use_cases_data TargetNeedsTable[]
---@param weights number[][]
---@return table<production_method_id, number>
local function weights_to_forage_time_distribution(use_cases_data, weights)
	---@type table<production_method_id, number>
	local distribution = {}

	for i, targets_table in pairs(use_cases_data) do
		for j, target_data in pairs(targets_table.data_per_forage_target) do
			distribution[j] = (distribution[j] or 0) + weights[i][j] * (target_data.handle_time + target_data.search_time)
		end
	end

	return distribution
end

---Use Diet-Breadth Model to weight, pick and normalize targets
--- and search times for when foraging for food and water
---@param tile_id tile_id
---@param culture_id culture_id
function dbm.cultural_foragable_targets(tile_id, culture_id)
	-- get average values from all pop of culture on tile
	local food_use_cases_needs, local_efficiencies, total_pop = dbm.cultural_food_needs(tile_id,culture_id)
	if total_pop == 0 then return {}, 0 end
	-- tabb.deep_print(food_use_cases_needs)
	-- tabb.deep_print(local_efficiencies)

	-- get available foraging methods for tile
	local foraging_methods = dbm.local_foraging_methods(tile_id)
	-- tabb.deep_print(foraging_methods)
	local food_use_cases_data = tabb.map_array(
		food_use_cases_needs,
		function (use_case_amount)
			return forage_targets_for_a_given_use_case(foraging_methods, local_efficiencies, tile_id, use_case_amount.use_case, use_case_amount.amount)
		end
	)
	-- tabb.deep_print(food_use_cases_data)
	local weights = calculate_weights(food_use_cases_data)
	-- tabb.deep_print(weights)
	return weights_to_forage_time_distribution(food_use_cases_data, weights), total_pop
end

return dbm