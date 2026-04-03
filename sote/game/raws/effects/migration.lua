local demography_effects = require "game.raws.effects.demography"
local economy_effects = require "game.raws.effects.economy"
local realm_utils = require "game.entities.realm".Realm
local military_effects = require "game.raws.effects.military"
local diplomacy_effects = require "game.raws.effects.diplomacy"
local travel_effects = require "game.raws.effects.travel"
local language_utils = require "game.entities.language".Language

local MigrationEffects = {}

---commenting
---@param character Character
function MigrationEffects.start_migration(character)
	local province = POP_PROVINCE(character)
	local realm = REALM(character)

	military_effects.gather_warband(character)
	military_effects.dissolve_guard(realm)

	--- move all available pops to the leader's warband as units
	---@type estate_unit_id[]
	local estate_units = {}
	DATA.for_each_estate_unit_from_location(province, function (item)
		table.insert(estate_units, item)
	end)

	---@type home_id[]
	local homes = {}
	DATA.for_each_home_from_home(province, function (item)
		table.insert(homes, item)
	end)

	---@type character_location_id[]
	local character_locations = {}
	DATA.for_each_character_location_from_location(province, function (item)
		table.insert(character_locations, item)
	end)

	for _, item in pairs(homes) do
		DATA.delete_home(item)
	end
	for _, item in pairs(estate_units) do
		local pop = DATA.estate_unit_get_pop(item)
		demography_effects.recruit(pop, LEADER_OF_ESTATE(character), UNIT_TYPE.CIVILIAN)
	end
	for _, item in pairs(character_locations) do
		local pop = DATA.character_location_get_character(item)
		demography_effects.recruit(pop, LEADER_OF_ESTATE(character), UNIT_TYPE.CIVILIAN)
	end

	---allow to move buildings and techs with warbands later

	realm_utils.remove_province(realm, province)
	DATA.realm_set_capitol(realm, INVALID_ID)
	WORLD:unset_settled_province(province)

	travel_effects.exit_settlement(character)
end

---settle down with warband in a given province
---@param character Character
function MigrationEffects.settle_down(character, become_owner)
	local migrating_realm = REALM(character)
	local migrating_host = LEADER_OF_ESTATE(character)

	local target = POP_PROVINCE(character)
	local target_realm = PROVINCE_REALM(target)

	if target_realm ~= INVALID_ID then
		-- merge all local characters to this realm
		if become_owner then
			-- if it was an invasion, turn local nobles into nobles of invading realm
			---@type realm_pop_id[]
			local temp = {}
			DATA.for_each_realm_pop_from_realm(target_realm, function (item)
				table.insert(temp, item)
			end)
			for _, item in pairs(temp) do
				DATA.realm_pop_set_realm(item, migrating_realm)
				local pop = DATA.realm_pop_get_pop(item)
				if DATA.pop_get_rank(pop) == CHARACTER_RANK.CHIEF then
					DATA.pop_set_rank(pop, CHARACTER_RANK.NOBLE)
				end
			end
			-- destroy invaded realm
			diplomacy_effects.dissolve_realm_and_clear_diplomacy(target_realm)
		else
			---@type realm_pop_id[]
			local temp = {}
			DATA.for_each_realm_pop_from_realm(migrating_realm, function (item)
				table.insert(temp, item)
			end)
			for _, item in pairs(temp) do
				DATA.realm_pop_set_realm(item, target_realm)
				local pop = DATA.realm_pop_get_pop(item)
				if DATA.pop_get_rank(pop) == CHARACTER_RANK.CHIEF then
					DATA.pop_set_rank(pop, CHARACTER_RANK.NOBLE)
				end
			end
			-- destroy merged realm
			diplomacy_effects.dissolve_realm_and_clear_diplomacy(migrating_realm)
		end
	end

	if PROVINCE_NAME(target) == "<uninhabited>" then
		DATA.province_set_name(target, language_utils.get_random_culture_name(DATA.culture_get_language(DATA.pop_get_culture(character))))
	end

	if become_owner then
		realm_utils.add_province(migrating_realm, target)
		DATA.realm_set_capitol(migrating_realm, target)
		WORLD:set_settled_province(target)
		realm_utils.explore(migrating_realm, target)
	end

	--- proceed to transfer all pops and characters from the host
	---@type pop_id[]
	local migrating_pops = {}
	---@type pop_id[]
	local migrating_characters = {}
	DATA.for_each_warband_unit_from_warband(migrating_host, function (item)
		local unit_type = DATA.warband_unit_get_type(item)
		if unit_type == UNIT_TYPE.CIVILIAN then
			local pop = DATA.warband_unit_get_unit(item)
			if IS_CHARACTER(pop) then
				table.insert(migrating_characters, pop)
			else
				table.insert(migrating_pops, pop)
			end
		end
	end)

	for _, migrating_character in pairs(migrating_characters) do
		demography_effects.unrecruit(migrating_character)
		DATA.force_create_home(target, migrating_character)
	end
	for _, migrating_pop in pairs(migrating_pops) do
		demography_effects.unrecruit(migrating_pop)
		DATA.force_create_home(target, migrating_pop)
	end
end

return MigrationEffects