
local WarbandEffects = {}

---Sets character as a recruiter of estate
---@param character Character
---@param estate estate_id
function WarbandEffects.set_leader(estate, character)
	local leader = DATA.get_estate_leader_from_estate(estate)
	if leader ~= INVALID_ID then
		DATA.estate_recruiter_set_leader(recruiter_warband, character)
	else
		DATA.force_create_estate_leader(character, estate)
	end
end

---unsets character as a recruiter of estate
---@param estate estate_id
function WarbandEffects.unset_leader(estate)
	local leader = DATA.get_estate_leader_from_estate(estate)
	if leader ~= INVALID_ID then
		DATA.delete_estate_leader(leader)
	end
end

---Sets character as a recruiter of estate
---@param character Character
---@param estate estate_id
function WarbandEffects.set_recruiter(estate, character)
	local recruiter = DATA.get_estate_recruiter_from_estate(estate)
	if recruiter ~= INVALID_ID then
		DATA.estate_recruiter_set_recruiter(recruiter, character)
	else
		DATA.force_create_estate_recruiter(character, estate)
	end
end

---unsets character as a recruiter of estate
---@param estate estate_id
function WarbandEffects.unset_recruiter(estate)
	local recruiter = DATA.get_estate_recruiter_from_estate(estate)
	if recruiter ~= INVALID_ID then
		DATA.delete_estate_recruiter(recruiter)
	end
end

---Sets character as a recruiter of estate
---@param character Character
---@param estate estate_id
function WarbandEffects.set_commander(estate, character)
	local commander = DATA.get_estate_commander_from_estate(estate)
	if commander ~= INVALID_ID then
		DATA.estate_commander_set_commander(commander, character)
	else
		DATA.force_create_estate_commander(character, estate)
	end
end

---unsets character as a recruiter of estate
---@param estate estate_id
function WarbandEffects.unset_commander(estate)
	local commander = DATA.get_estate_recruiter_from_estate(estate)
	if commander ~= INVALID_ID then
		DATA.delete_estate_commander(commander)
	end
end

---@param estate estate_id
---@param character Character
---@param unit UNIT_TYPE
function WarbandEffects.set_as_unit(estate, character, unit)
	---#logging LOGS:write("set character as a unit \n")
	---#logging LOGS:flush()
	local current_unit = DATA.get_estate_unit_from_pop(character)
	local current_type = DATA.estate_unit_get_type(current_unit)
	local current_estate = DATA.estate_unit_get_estate(current_unit)

	local new_upkeep = DATA.unit_type_get_base_cost(unit)

	if current_estate == INVALID_ID then
		---#logging LOGS:write("no current warband\n")
		---#logging LOGS:flush()

		local new_membership = DATA.force_create_estate_unit(character, estate)
		DATA.estate_unit_set_type(new_membership, unit)
	elseif current_estate ~= estate then
		---#logging LOGS:write("there is current warband but it's different\n")
		---#logging LOGS:flush()

		local current_upkeep = DATA.unit_type_get_base_cost(current_type)

		DATA.estate_inc_units_current(current_estate, current_type, -1)
		DATA.estate_inc_total_upkeep(current_estate, -current_upkeep)

		DATA.estate_unit_set_warband(current_unit, estate)
		DATA.estate_unit_set_type(current_unit, unit)
	else
		---#logging LOGS:write("there is current warband and it's the same\n")
		---#logging LOGS:flush()

		local current_upkeep = DATA.unit_type_get_base_cost(current_type)

		DATA.estate_inc_units_current(current_estate, current_type, -1)
		DATA.estate_inc_total_upkeep(current_estate, -current_upkeep)

		DATA.estate_unit_set_type(current_unit, unit)
	end

	DATA.estate_inc_total_upkeep(estate, new_upkeep)
	DATA.estate_inc_units_current(estate, unit, 1)

	---#logging LOGS:write("taking up command was successful\n")
	---#logging LOGS:flush()
end


---Handles pop firing logic on estate's side
---@param estate estate_id
---@param pop pop_id
function WarbandEffects.fire_unit(estate, pop)
	-- print(pop.name, "leaves warband")
	local membership = DATA.get_estate_unit_from_pop(pop)
	local fat_membership = DATA.fatten_estate_unit(membership)

	assert(estate == fat_membership.estate, "INVALID OPERATION: POP WAS IN A WRONG ESTATE")

	-- downgrade warrior to civilian
	if fat_membership.type == UNIT_TYPE.WARRIOR then
		WarbandEffects.set_as_unit(estate,pop,UNIT_TYPE.CIVILIAN)
	else -- remove from office
		local lead = DATA.get_estate_leader_from_estate(estate)
		if lead ~= INVALID_ID then
			local leader = DATA.estate_leader_get_leader(lead)
			if pop == leader then
				WarbandEffects.unset_leader(estate)
			end
		end
		local recruit = DATA.get_estate_recruiter_from_estate(estate)
		if recruit ~= INVALID_ID then
			local recruiter = DATA.warband_recruiter_get_recruiter(recruit)
			if pop == recruiter then
				WarbandEffects.unset_recruiter(estate)
			end
		end
		local command = DATA.get_estate_commander_from_estate(estate)
		if command ~= INVALID_ID then
			local commander = DATA.estate_commander_get_commander(command)
			if pop == commander then
				WarbandEffects.unset_commander(estate)
			end
		end
		-- remove if dead
		if DATA.pop_get_dead(pop) then
			DATA.delete_estate_unit(membership)
		else -- set to follower
			WarbandEffects.set_as_unit(estate,pop,UNIT_TYPE.FOLLOWER)
		end
	end
end

---@param estate estate_id
function WarbandEffects.decimate(estate)
	local pops_to_delete = require "engine.table".map_array(DATA.get_estate_unit_from_estate(estate), DATA.estate_unit_get_pop)
	for _, pop in ipairs(pops_to_delete) do
		DATA.delete_pop(pop)
	end
end

return WarbandEffects