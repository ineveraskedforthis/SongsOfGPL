local strings = require "engine.string"

local province_utils = require "game.entities.province".Province

local office_triggers = require "game.raws.triggers.offices"
local economy_triggers = require "game.raws.triggers.economy"
local diplomacy_trigger = require "game.raws.triggers.diplomacy"

local ut = require "game.ui-utils"

local Trigger = {}

Trigger.Pretrigger = {}
Trigger.Targeted = {}

CHECKBOX_POSITIVE = " v "
CHECKBOX_NEGATIVE = " x "

---@class (exact) Trigger
---@field tooltip_on_condition_failure fun(root: Character, primary_target:any): string[]
---@field condition fun(root: Character, primary_target:any): boolean

---@class (exact) Pretrigger : Trigger
---@field tooltip_on_condition_failure fun(root: Character, primary_target:any): string[]
---@field condition fun(root: Character): boolean

---@class (exact) TriggerCharacter : Trigger
---@field tooltip_on_condition_failure fun(root: Character, primary_target:Character): string[]
---@field condition fun(root: Character, primary_target:Character): boolean

---@class (exact) TriggerProvince : Trigger
---@field tooltip_on_condition_failure fun(root: Character, primary_target:Province): string[]
---@field condition fun(root: Character, primary_target:Province): boolean


---Prepares a trigger which is true if one of list_of_pretriggers is true
---@param list_of_pretriggers Pretrigger[]
---@return Pretrigger
function Trigger.Pretrigger.OR(list_of_pretriggers)
	return {
		tooltip_on_condition_failure = function(root, primary_target)
			local tooltip = { "You failed one of prerequisites:" }
			for _, trigger in ipairs(list_of_pretriggers) do
				if trigger.condition(root) then
					return {}
				else
					for _, current_tooltip in ipairs(trigger.tooltip_on_condition_failure(root, primary_target)) do
						table.insert(tooltip, " " .. CHECKBOX_NEGATIVE .. current_tooltip)
					end
				end
			end
			return tooltip
		end,
		condition = function(root)
			for _, trigger in ipairs(list_of_pretriggers) do
				if trigger.condition(root) then
					return true
				end
			end
		end
	}
end

-- SELF TRIGGERS (NO TARGET)

---@type Pretrigger
Trigger.Pretrigger.not_busy = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are too busy" }
	end,
	condition = function(root)
		return not BUSY(root)
	end
}

Trigger.Pretrigger.in_settlement = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not in a settlement!" }
	end,
	condition = function(root)
		return POP_PROVINCE(root) ~= INVALID_ID
	end
}

---@type Pretrigger
Trigger.Pretrigger.is_dependent = {
	tooltip_on_condition_failure = function(root, primary_target)
		local parent = PARENT(root)
		if parent ~= INVALID_ID then
			return { "You are not a dependent of " .. NAME(parent) .. "!"}
		end
		return { "You are not dependent on anyone!" }
	end,
	condition = function(root)
		return IS_DEPENDENT(root)
	end
}
---@type Pretrigger
Trigger.Pretrigger.not_dependent = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are a dependent of " .. NAME(PARENT(root)) }
	end,
	condition = function(root)
		return not IS_DEPENDENT(root)
	end
}

---@type Pretrigger
Trigger.Pretrigger.is_in_party = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not in a party!" }
	end,
	condition = function(root)
		return UNIT_OF(root) ~= INVALID_ID
	end
}
---@type Pretrigger
Trigger.Pretrigger.not_in_party = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are a " .. DATA.unit_type_name(UNIT_TYPE_OF(root))
			.. " of " .. ESTATE_NAME(UNIT_OF(root)) .. "!" }
	end,
	condition = function(root)
		return UNIT_OF(root) == INVALID_ID
	end
}

---@param unit_type unit_type_id
---@return Pretrigger
function Trigger.Pretrigger.is_unit_type(unit_type)
	local result = {
		tooltip_on_condition_failure = function(root, primary_target)
			local warband = UNIT_OF(root)
			if warband ~= INVALID_ID then
				return { "You are a " .. DATA.unit_type_name(UNIT_TYPE_OF(root))
				.. " of " .. ESTATE_NAME(warband) }
			end
			return { "You are not in a party!" }
		end,
		condition = function(root)
			return UNIT_OF(root) ~= nil and UNIT_TYPE_OF(root) == unit_type
		end
	}
	return result
end
---@param unit_type unit_type_id|integer
---@return Pretrigger
function Trigger.Pretrigger.not_unit_type(unit_type)
	local result = {
		tooltip_on_condition_failure = function(root, primary_target)
			local warband = UNIT_OF(root)
			if warband ~= INVALID_ID then
				return { "You are a " .. DATA.unit_type_get_name(UNIT_TYPE_OF(root))
				.. " of " .. ESTATE_NAME(warband) }
			end
			return { "You are not in a party!" }
		end,
		condition = function(root)
			return UNIT_OF(root) ~= nil and UNIT_TYPE_OF(root) ~= unit_type
		end
	}
	return result
end

---@type Pretrigger
Trigger.Pretrigger.during_migration = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not migrating currently" }
	end,
	condition = function(root)
		return CAPITOL(REALM(root)) == INVALID_ID
	end
}

Trigger.Pretrigger.at_province_center = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You have to settle at province center" }
	end,
	condition = function(root)
		return ESTATE_TILE(LEADER_OF_ESTATE(root)) == DATA.province_get_center(POP_PROVINCE(root))
	end
}

---@type Pretrigger
Trigger.Pretrigger.not_ai_or_is_trader = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "AI specific pretrigger" }
	end,
	condition = function(root)
		if root == WORLD.player_character then
			return true
		end
		return HAS_TRAIT(root, TRAIT.TRADER)
	end
}

---@type Pretrigger
Trigger.Pretrigger.is_tribute_collector = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not allowed to collect tribute" }
	end,
	condition = function(root)
		return office_triggers.tribute_collector(root, REALM(root))
	end
}

---@type Pretrigger
Trigger.Pretrigger.is_at_tributary_capital = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "Local province does not pay tribute to your realm" }
	end,
	condition = function(root)
		local province_in = POP_PROVINCE(root)
		if province_in == INVALID_ID then
			province_in = TILE_PROVINCE(ESTATE_TILE(LEADER_OF_ESTATE(root)))
		end

		return diplomacy_trigger.pays_tribute_to(PROVINCE_REALM(province_in), REALM(root))
	end
}

---@type Pretrigger
Trigger.Pretrigger.at_core_realm_province = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You have not entered a settlement you can collect taxes from" }
	end,
	condition = function(root)
		local province = POP_PROVINCE(root)
		if province == INVALID_ID then
			return false
		end
		local local_realm = PROVINCE_REALM(province)
		if local_realm == REALM(root) then
			return true
		end
		return false
	end
}

---@type Pretrigger
Trigger.Pretrigger.not_leading_party = {
	tooltip_on_condition_failure = function(root, primary_target)
		local warband = UNIT_OF(root)
		if warband ~= INVALID_ID then
			return { "You are leading " .. ESTATE_NAME(warband) }
		end
		return { "You are not in a party!"}
	end,
	condition = function(root)
		return UNIT_OF(root) ~= INVALID_ID and LEADER_OF_ESTATE(root) == INVALID_ID
	end
}
---@type Pretrigger
Trigger.Pretrigger.leading_party = {
	tooltip_on_condition_failure = function(root, primary_target)
		local warband = UNIT_OF(root)
		if warband ~= INVALID_ID then
			return { "You are not leading " .. ESTATE_NAME(warband) }
		end
		return { "You are not in a party!"}
	end,
	condition = function(root)
		return UNIT_OF(root) ~= INVALID_ID and LEADER_OF_ESTATE(root) ~= INVALID_ID
	end
}

---@type Pretrigger
Trigger.Pretrigger.leading_idle_party = {
	tooltip_on_condition_failure = function(root, primary_target)
		local warband = UNIT_OF(root)
		if warband ~= INVALID_ID then
			if ESTATE_LEADER(warband) ~= root then
				return { "You are not leading" .. ESTATE_NAME(warband) }
			end
			if DATA.warband_get_current_status(warband) ~= ESTATE_STATUS.IDLE then
				return { ESTATE_NAME(warband) .. " is not currently idle" }
			end
		end
		return { "You are not in a party!" }
	end,
	condition = function(root)
		local warband = LEADER_OF_ESTATE(root)
		if warband == INVALID_ID then
			return false
		end
		if DATA.warband_get_current_status(warband) ~= ESTATE_STATUS.IDLE then
			return false
		end
		return true
	end
}

---@type Pretrigger
Trigger.Pretrigger.leading_idle_guard = {
	tooltip_on_condition_failure = function(root, primary_target)
		local warband = UNIT_OF(root)
		if warband ~= INVALID_ID then
			if DATA.warband_get_guard_of(warband) == INVALID_ID then
				return { ESTATE_NAME(warband) .. " is not a realm guard" }
			end
			if ESTATE_RECRUITER(warband) ~= root then
				return { "You are not leading " .. ESTATE_NAME(warband) }
			end
			if DATA.warband_get_current_status(warband) ~= ESTATE_STATUS.IDLE then
				return { ESTATE_NAME(warband) .. " is not currently idle" }
			end
		end
		return { "You are not in a party!" }
	end,
	condition = function(root)
		local warband = RECRUITER_OF_ESTATE(root)
		if warband == INVALID_ID then
			return false
		end
		if DATA.warband_get_current_status(warband) ~= ESTATE_STATUS.IDLE then
			return false
		end
		if DATA.warband_get_guard_of(warband) == INVALID_ID then
			return false
		end
		return true
	end
}

---@type Pretrigger
Trigger.Pretrigger.leading_idle_warband_or_guard = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You do not lead any idle party or guard" }
	end,
	condition = function(root)
		return office_triggers.valid_patrol_participant(root, POP_PROVINCE(root))
	end
}

---@type Pretrigger
Trigger.Pretrigger.leader = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not a leader of the tribe" }
	end,
	condition = function(root)
		return office_triggers.is_ruler(root)
	end
}

---@type Pretrigger
Trigger.Pretrigger.no_guard_at_local_realm = {
	tooltip_on_condition_failure = function(root, primary_target)
		local realm = province_utils.realm(POP_PROVINCE(root))
		if realm ~= INVALID_ID then
			return { REALM_NAME(realm) .. " is defended by " .. ESTATE_NAME() }
		end
		return { "There is no settled realm!"}
	end,
	condition = function(root)
		local realm = province_utils.realm(POP_PROVINCE(root))
		if realm == INVALID_ID then
			return false
		end
		local guard = DATA.realm_guard_get_guard(DATA.get_realm_guard_from_realm(realm))
		return guard == INVALID_ID
	end
}

---@type Pretrigger
Trigger.Pretrigger.guard_at_local_realm = {
	tooltip_on_condition_failure = function(root, primary_target)
		local realm = province_utils.realm(POP_PROVINCE(root))
		if realm ~= INVALID_ID then
			return { REALM_NAME(realm) .. " has no guards!" }
		end
		return { "There is no settled realm!"}
	end,
	condition = function(root)
		local realm = province_utils.realm(POP_PROVINCE(root))
		if realm == INVALID_ID then
			return false
		end
		local guard = DATA.realm_guard_get_guard(DATA.get_realm_guard_from_realm(realm))
		return guard ~= INVALID_ID
	end
}

---@type Pretrigger
Trigger.Pretrigger.local_guard_exists_and_has_no_officer = {
	tooltip_on_condition_failure = function(root, primary_target)
		local realm = province_utils.realm(POP_PROVINCE(root))
		if realm ~= INVALID_ID then
			local guard = DATA.realm_guard_get_guard(DATA.get_realm_guard_from_realm(realm))
			if guard ~= INVALID_ID then
				return { ESTATE_NAME(guard) .. " is already being lead by " .. ESTATE_RECRUITER(guard) }
			end
			return { REALM_NAME(realm) .. " has no guards!" }
		end
		return { "There is no settled realm!"}
	end,
	condition = function(root)
		local realm = province_utils.realm(POP_PROVINCE(root))
		if realm == INVALID_ID then
			return false
		end
		local guard = DATA.realm_guard_get_guard(DATA.get_realm_guard_from_realm(realm))
		if guard == INVALID_ID then
			return false
		end
		local guard_leadership = DATA.warband_recruiter_get_recruiter(DATA.get_warband_recruiter_from_warband(guard))
		return guard_leadership == INVALID_ID
	end
}

---@type Pretrigger
Trigger.Pretrigger.at_capitol = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are too far away from your tribe" }
	end,
	condition = function(root)
		local location = DATA.get_character_location_from_character(root)
		local current = DATA.character_location_get_location(location)
		local required = DATA.realm_get_capitol(REALM(root))
		return current == required
	end
}

---@type Pretrigger
Trigger.Pretrigger.leader_of_local_territory = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not a leader of local tribe" }
	end,
	condition = function(root)
		local local_realm = province_utils.realm(POP_PROVINCE(root))
		assert(local_realm ~= INVALID_ID)
		return root == LEADER(local_realm)
	end
}

---@type Pretrigger
Trigger.Pretrigger.decision_maker_local = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not the one who makes decisions in the local tribe" }
	end,
	condition = function(root)

		local local_realm = LOCAL_REALM(root)

		if local_realm == INVALID_ID then
			return false
		end

		return LEADER(local_realm) == root
	end
}

---@type Pretrigger
Trigger.Pretrigger.foreign_policy_decision_maker = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not the one who decides foreign policy decisions in the your tribe" }
	end,
	condition = function(root)
		return office_triggers.decides_foreign_policy(root, REALM(root))
	end
}

---@type Pretrigger
Trigger.Pretrigger.designates_offices_local = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not allowed to manage local realm's offices" }
	end,
	condition = function(root)
		return office_triggers.designates_offices(root, POP_PROVINCE(root))
	end
}

---check that the pop's has at least x in savings
---@param x number
---@return Pretrigger
function Trigger.Pretrigger.savings_at_least(x)
	---@type Pretrigger
	local result = {
		tooltip_on_condition_failure = function(root, primary_target)
			return { "You don't have " .. ut.to_fixed_point2(x) .. MONEY_SYMBOL }
		end,
		condition = function(root)
			return SAVINGS(root) >= x
		end
	}
	return result
end

---check that the pop's party has at least x in treasury
---@param x number
---@return Pretrigger
function Trigger.Pretrigger.party_savings_at_least(x)
	---@type Pretrigger
	local result = {
		tooltip_on_condition_failure = function(root, primary_target)
			local warband = UNIT_OF(root)
			if warband ~= INVALID_ID then
				return { ESTATE_NAME(warband) .. " doesn't have " .. ut.to_fixed_point2(x) .. MONEY_SYMBOL }
			end
			return { "You are not in a party!" }
		end,
		condition = function(root)
			local warband = UNIT_OF(root)
			return warband ~= INVALID_ID and DATA.warband_get_treasury(warband) >= x
		end
	}
	return result
end

-- CHARACTER TRIGGERS

---@type TriggerCharacter
Trigger.Targeted.is_overlord_of_target = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "They are not your subject" }
	end,
	condition = function(root, primary_target)
		return false
	end
}

---@type TriggerCharacter
Trigger.Targeted.orders_can_reach_target = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You can manage the realm only from it's capitol" }
	end,
	condition = function(root, primary_target)
		return POP_PROVINCE(root) == CAPITOL(REALM(primary_target))
	end
}

---@type TriggerCharacter
Trigger.Targeted.target_is_tax_collector = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "Target is not a tax collector" }
	end,
	condition = function(root, primary_target)
		local collector_for = DATA.tax_collector_get_realm(DATA.get_tax_collector_from_collector(primary_target))
		return collector_for ~= INVALID_ID
	end
}

---@type TriggerCharacter
Trigger.Targeted.valid_overseer = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "They can't be an overseer in our realm" }
	end,
	condition = function(root, primary_target)
		return office_triggers.valid_overseer(primary_target, REALM(root))
	end
}

---@type TriggerCharacter
Trigger.Targeted.valid_guard_leader_local = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "They can't be a guard leader in our realm" }
	end,
	condition = function(root, primary_target)
		return office_triggers.valid_guard_leader(primary_target, province_utils.realm(POP_PROVINCE(root)))
	end
}

Trigger.Pretrigger.vacant_guard_leader_local = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "There is no vacant position for a guard leader" }
	end,
	condition = function(root, primary_target)
		return office_triggers.vacant_guard_leader(REALM(root))
	end
}

---@type TriggerCharacter
Trigger.Targeted.is_not_in_negotiations = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are already in negotiations with this target" }
	end,
	condition = function(root, primary_target)
		local result = false

		DATA.for_each_negotiation_from_initiator(root, function (item)
			local opponent = DATA.negotiation_get_target(item)
			if opponent == primary_target then
				result = true
			end
		end)

		DATA.for_each_negotiation_from_target(root, function (item)
			local opponent = DATA.negotiation_get_initiator(item)
			if opponent == primary_target then
				result = true
			end
		end)

		return result
	end
}

---@type TriggerProvince
Trigger.Targeted.settled = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "This province is not settled" }
	end,
	condition = function(root, primary_target)
		return province_utils.realm(primary_target) ~= INVALID_ID
	end
}

-- PROVINCE TRIGGERS

---@type TriggerProvince
Trigger.Targeted.not_settled = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "This province is settled" }
	end,
	condition = function(root, primary_target)
		return province_utils.realm(primary_target) == INVALID_ID
	end
}

---@type TriggerProvince
Trigger.Targeted.different_realm = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "This province belongs to us" }
	end,
	condition = function(root, primary_target)
		return not diplomacy_trigger.province_controlled_by(primary_target, REALM(root))
	end
}

---@type TriggerProvince
Trigger.Targeted.is_neigbor_to_capitol = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "This province is too far away" }
	end,
	condition = function(root, primary_target)
		local realm = REALM(root)
		local capitol = DATA.realm_get_capitol(realm)
		local is_neighbor = false
		DATA.for_each_province_neighborhood_from_origin(capitol, function (item)
			if DATA.province_neighborhood_get_target(item) == primary_target then
				is_neighbor = true
			end
		end)
		return is_neighbor
	end
}

---@type TriggerProvince
Trigger.Targeted.has_local_trade_permit = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are allowed to trade in this province" }
	end,
	condition = function(root, primary_target)
		if PROVINCE_REALM(primary_target) == INVALID_ID then return false end
		return economy_triggers.allowed_to_trade(root, PROVINCE_REALM(primary_target))
	end
}

---@type TriggerProvince
Trigger.Targeted.has_no_local_trade_permit = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not allowed to trade in this province" }
	end,
	condition = function(root, primary_target)
		if PROVINCE_REALM(primary_target) == INVALID_ID then return false end
		return not economy_triggers.allowed_to_trade(root, PROVINCE_REALM(primary_target))
	end
}

---@type TriggerProvince
Trigger.Targeted.has_no_local_building_permit = {
	tooltip_on_condition_failure = function(root, primary_target)
		return { "You are not allowed to build in this province" }
	end,
	condition = function(root, primary_target)
		if PROVINCE_REALM(primary_target) == INVALID_ID then return false end
		return not economy_triggers.allowed_to_build(root, PROVINCE_REALM(primary_target))
	end
}

return Trigger
