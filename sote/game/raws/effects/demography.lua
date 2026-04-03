local warband_effects = require "game.raws.effects.warband"
local demography_values = require "game.raws.values.demography"

local demo = {}

---Kills a single pop and removes it from all relevant references.
---@param pop pop_id
function demo.kill_pop(pop)
	-- print("kill " .. pop.name)
	DATA.pop_set_dead(pop,true)
	demo.fire_pop(pop)
	demo.unrecruit(pop)
	DATA.delete_pop(pop)
end

---Fires an employed pop and adds it to the unemployed pops list.
---It leaves the "job" set so that inference of social class can be performed.
---@param pop pop_id
function demo.fire_pop(pop)
	local employment = DATA.get_employment_from_worker(pop)
	if DATA.employment_get_building(employment) ~= INVALID_ID then
		DATA.delete_employment(employment)
	end
end

---recruitment logic
---@param pop pop_id
---@param estate estate_id
---@param unit_type UNIT_TYPE
function demo.recruit(pop, estate, unit_type)
	-- clean pop data
	demo.fire_pop(pop)
	warband_effects.set_as_unit(estate,pop,unit_type)
	-- recruit all dependents as followers
	DATA.for_each_parent_child_relation_from_parent(pop, function (item)
		local child = DATA.parent_child_relation_get_child(item)
		if IS_DEPENDENT_OF(child,pop) then
			demo.recruit(child,estate,UNIT_TYPE.FOLLOWER)
		end
	end)
end

---handles leaving warbands
---@param pop pop_id
function demo.unrecruit(pop)
	local warband = UNIT_OF(pop)
	local unit = UNIT_TYPE_OF(pop)
	if warband ~= INVALID_ID then
		-- demote to follower if not in settlement
		if unit == UNIT_TYPE.WARRIOR then
			warband_effects.set_as_unit(warband,pop,UNIT_TYPE.CIVILIAN)
		else
			warband_effects.fire_unit(warband, pop)
			if not DATA.pop_get_dead(pop) then
				-- unrecruit all dependent followers
				DATA.for_each_parent_child_relation_from_parent(pop, function (item)
					local child = DATA.parent_child_relation_get_child(item)
					if IS_DEPENDENT_OF(child,pop) then
						demo.unrecruit(child)
					end
				end)
			end
		end
	end
end

---Kills ratio of army
---@param estate estate_id
---@param ratio number
function demo.kill_off_warband(estate, ratio)
	local losses = 0
	---@type POP[]
	local pops_to_kill = {}

	for _, membership in ipairs(DATA.get_estate_unit_from_estate(estate)) do
		local pop = DATA.estate_unit_get_pop(membership)
		if not IS_CHARACTER(pop) and love.math.random() < ratio then
			table.insert(pops_to_kill, pop)
			losses = losses + 1
		end
	end

	for i, pop in ipairs(pops_to_kill) do
		demo.kill_pop(pop)
	end

	return losses
end

---kills of a ratio of army and returns the losses
---@param army warband_id[]
---@param ratio number
---@return number
function demo.kill_off_army(army, ratio)
	local losses = 0
	for _, warband in pairs(army) do
		losses = losses + demo.kill_off_warband(warband, ratio)
	end
	return losses
end

---Employs a pop and handles its removal from relevant data structures...
---@param pop pop_id
---@param building building_id
function demo.employ_pop(pop, building)
	local potential_job = demography_values.potential_job(building)
	if potential_job == nil then
		return
	end

	-- employment increases pop's perceived value of their work:
	local current_value = DATA.pop_get_expected_wage(pop)
	DATA.pop_set_expected_wage(pop, current_value + 0.5)

	-- Now that we know that the job is needed, employ the pop!

	DATA.pop_set_forage_ratio(pop, 0.5)
	DATA.pop_set_work_ratio(pop, 0.5)

	-- ... but fire them first to update the previous building if needed
	local employment = DATA.get_employment_from_worker(pop)
	if DATA.employment_get_building(employment) == INVALID_ID then
		-- no need to update stuff: just create new employment
		local new_employment = DATA.fatten_employment(DATA.force_create_employment(building, pop))
		new_employment.job = potential_job
		new_employment.start_date = WORLD.year * 30 * 12 + WORLD.day + WORLD.month * 30
	else
		local fat = DATA.fatten_employment(employment)
		fat.building = building
		fat.job = potential_job
		fat.start_date = WORLD.year * 30 * 12 + WORLD.day + WORLD.month * 30
	end
end

return demo