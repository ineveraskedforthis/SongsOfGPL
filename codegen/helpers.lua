--- Helper functions to reduce key presses to type names of common wrappers

CLICK_STRING = "\nClick here to open inspector view!"
OBSERVER_BUTTON_TOOLTIP = "Observers cannot interact with the world!"

---@enum AI_GOAL
AI_GOAL = {
	RAID = 0,
	TRADE = 1,
	ENFORCE_TRIBUTE = 2,
	COLLECT_TRIBUTE = 3,
	COLLECT_TAX = 4,
	EXPLORE = 5,
	PATROL = 6,
	IDLE = 7,
}

---@class AI_DATA
---@field target_province province_id
---@field current_goal AI_GOAL

---@type table<world_tile_id, tile_id>
TILE_FROM_WORLD_ID = {}

TRAVEL_DAY_HOURS = 12

function MONTH_WEIGHTED_JAN_JUL(jan_value,jul_value,month)
	local jan_weight = math.cos(5/3 * month / math.pi) / 2 + .5
	local jul_weight = math.cos(5/3 * (month + 6) / math.pi) / 2 + .5
	return jan_weight * jan_value + jul_weight * jul_value
end

function REGENERATE_RAWS()
	local w = {}

	---@type table<string, building_type_id>
	w.building_types_by_name = {}
	DATA.for_each_building_type(function (item)
		print(item, DATA.building_type_get_name(item))
		w.building_types_by_name[DATA.building_type_get_name(item)] = item
	end)

	---@type table<string, biome_id>
	w.biomes_by_name = {}
	DATA.for_each_biome(function (item)
		w.biomes_by_name[DATA.biome_get_name(item)] = item
	end)

	w.biomes_load_order = {
		w.biomes_by_name["rocky-wasteland"],
		w.biomes_by_name["tundra"],
		w.biomes_by_name["abyssal-plains"],
		w.biomes_by_name["continental-shelf"],
		w.biomes_by_name["trench"],
		w.biomes_by_name["glacier"],
		w.biomes_by_name["glaciated-sea"],
		w.biomes_by_name["coniferous-forest"],
		w.biomes_by_name["broadleaf-forest"],
		w.biomes_by_name["warm-dry-broadleaf-forest"],
		w.biomes_by_name["mixed-forest"],
		w.biomes_by_name["wet-jungle"],
		w.biomes_by_name["jungle"],
		w.biomes_by_name["dry-jungle"],
		w.biomes_by_name["taiga"],
		w.biomes_by_name["coniferous-woodland"],
		w.biomes_by_name["broadleaf-woodland"],
		w.biomes_by_name["warm-wet-broadleaf-woodland"],
		w.biomes_by_name["warm-dry-broadleaf-woodland"],
		w.biomes_by_name["mixed-woodland"],
		w.biomes_by_name["woodland-taiga"],
		w.biomes_by_name["savanna"],
		w.biomes_by_name["shrubland"],
		w.biomes_by_name["woody-scrubland"],
		w.biomes_by_name["grassy-scrubland"],
		w.biomes_by_name["mixed-scrubland"],
		w.biomes_by_name["grassland"],
		w.biomes_by_name["barren-mountainside"],
		w.biomes_by_name["barren-mountainside-low-altitude"],
		w.biomes_by_name["barren-mountainside-high-altitude"],
		w.biomes_by_name["barren-desert"],
		w.biomes_by_name["sand-dunes"],
		w.biomes_by_name["badlands"],
		w.biomes_by_name["xeric-desert"],
		w.biomes_by_name["xeric-shrubland"],
		w.biomes_by_name["rugged-mountainside"],
		w.biomes_by_name["rugged-mountainside-low-altitude"],
		w.biomes_by_name["mountainside-scrub"],
		w.biomes_by_name["mountainside-scrub-low-altitude"],
		w.biomes_by_name["bog"],
		w.biomes_by_name["marsh"],
		w.biomes_by_name["swamp"],
	}

	---@type table<string, bedrock_id>
	w.bedrocks_by_name = {}
	DATA.for_each_bedrock(function (item)
		w.bedrocks_by_name[DATA.bedrock_get_name(item)] = item
	end)

	---@type table<number, bedrock_id>
	w.bedrocks_by_color_id = {}
	DATA.for_each_bedrock(function (item)
		w.bedrocks_by_color_id[DATA.bedrock_get_color_id(item)] = item
	end)

	-- not in datacontainer currently

	w.biogeographic_realms_by_name = {}
	w.biogeographic_realms_by_color = {}

	---@type table<string, race_id>
	w.races_by_name = {}
	DATA.for_each_race(function (item)
		w.races_by_name[DATA.race_get_name(item)] = item
	end)

	HUMAN = w.races_by_name["human"]

	---@type table<string, trade_good_id>
	w.trade_goods_by_name = {}
	DATA.for_each_trade_good(function (item)
		w.trade_goods_by_name[DATA.trade_good_get_name(item)] = item
	end)

	---@type table<string, use_case_id>
	w.use_cases_by_name = {}
	DATA.for_each_use_case(function (item)
		w.use_cases_by_name[DATA.use_case_get_name(item)] = item
	end)

	WATER_USE_CASE = w.use_cases_by_name["water"]
	CALORIES_USE_CASE = w.use_cases_by_name["calories"]
	CONTAINERS_USE_CASE = w.use_cases_by_name["containers"]
	TOOLS_LIKE_USE_CASE = w.use_cases_by_name["tools-like"]

	---@type table<string, job_id>
	w.jobs_by_name = {}
	DATA.for_each_job(function (item)
		w.jobs_by_name[DATA.job_get_name(item)] = item
	end)

	UNEMPLOYED = w.jobs_by_name["Unemployed"]
	WARRIORS = w.jobs_by_name["Warriors"]
	CHILDREN = w.jobs_by_name["Children"]

	---@type table<string, technology_id>
	w.technologies_by_name = {}
	DATA.for_each_technology(function (item)
		w.technologies_by_name[DATA.technology_get_name(item)] = item
	end)

	---@type table<string, production_method_id>
	w.production_methods_by_name = {}
	DATA.for_each_production_method(function (item)
		w.production_methods_by_name[DATA.production_method_get_name(item)] = item
	end)

	---@type table<string, resource_id>
	w.resources_by_name = {}
	DATA.for_each_resource(function (item)
		w.resources_by_name[DATA.resource_get_name(item)] = item
	end)

	---@type table<string, unit_type_id>
	w.unit_types_by_name = {}
	DATA.for_each_unit_type(function (item)
		w.unit_types_by_name[DATA.unit_type_get_name(item)] = item
	end)

	--- loaded separately

	w.decisions_by_name = {}
	w.decisions_characters_by_name = {}
	w.events_by_name = {}

	---@type RawsManager
	RAWS_MANAGER = w
end

function RESTORE_UNSAVED_TILES_DATA()
	DATA.for_each_tile(function (item)
		TILE_FROM_WORLD_ID[DATA.tile_get_world_id(item) --[[@as world_tile_id]]] = item
	end)
end

---Returns true if pop is a character
---@param pop_id pop_id
function IS_CHARACTER(pop_id)
	return DATA.pop_get_rank(pop_id) ~= CHARACTER_RANK.POP
end

---@param pop_id pop_id
function DEAD(pop_id)
	if not DCON.dcon_pop_is_valid(pop_id) then
		return true
	end
	return DATA.pop_get_dead(pop_id)
end

---@alias world_tile_id tile_id

-- -@class world_tile_id : number
-- -@field is_world_tile_id nil


---Returns age adjust racial efficiency
---@param pop pop_id
---@param jobtype jobtype_id
---@return number
function JOB_EFFICIENCY(pop, jobtype)
	return DCON.job_efficiency(pop,jobtype)
end

---Returns estate of a pop
---@param pop_id pop_id
---@return estate_id
function POP_ESTATE(pop_id)
	return DATA.estate_unit_get_estate(DATA.get_estate_unit_from_pop(pop_id))
end

---Returns current tile of a pop
---@param pop_id pop_id
---@return province_id
function POP_TILE(pop_id)
	return ESTATE_TILE(POP_ESTATE(pop_id))
end

---Returns current province of a pop
---@param pop_id pop_id
---@return province_id
function POP_PROVINCE(pop_id)
	return TILE_PROVINCE(POP_TILE(pop_id))
end

---returns current tile of estate
---@param estate_id estate_id
---@return tile_id
function ESTATE_TILE(estate_id)
	return DATA.estate_location_get_tile(DATA.get_estate_location_from_estate(estate_id))
end

---returns current province of estate
---@param estate_id estate_id
---@return province_id
function ESTATE_PROVINCE(estate_id)
	return TILE_PROVINCE(ESTATE_TILE(estate_id))
end

---commenting
---@param building_id building_id
---@return estate_id
function BUILDING_ESTATE(building_id)
	return DATA.building_estate_get_estate(DATA.get_building_estate_from_building(building_id))
end

---commenting
---@param building_id building_id
---@return province_id
function BUILDING_PROVINCE(building_id)
	return ESTATE_PROVINCE(BUILDING_ESTATE(building_id))
end

---commenting
---@param province province_id
---@return realm_id
function PROVINCE_REALM(province)
	local realm_membership = DATA.get_realm_provinces_from_province(province)
	return DATA.realm_provinces_get_realm(realm_membership)
end

---commenting
---@param pop_id pop_id|`INVALID_ID`
---@return number
function SAVINGS(pop_id)
	return DATA.pop_get_savings(pop_id)
end

---commenting
---@param estate_id estate_id|`INVALID_ID`
---@return number
function ESTATE_SAVINGS(estate_id)
	return DATA.estate_get_savings(estate_id)
end

---commenting
---@param pop_id pop_id
---@param trade_good trade_good_id
---@return number
function INVENTORY(pop_id, trade_good)
	return DATA.pop_get_inventory(pop_id, trade_good)
end

---commenting
---@param pop_id Character
---@return Character
function LOYAL_TO(pop_id)
	local loyalty = DATA.get_loyalty_from_bottom(pop_id)
	return DATA.loyalty_get_top(loyalty)
end


---Returns province of a pop
---@param pop_id pop_id
---@return estate_id
function HOME(pop_id)
	-- assume that pop has location?
	local location_pop = DATA.get_home_from_pop(pop_id)
	return DATA.home_get_estate(location_pop)
end

---Returns parent of a pop
---@param pop_id pop_id
---@return pop_id
function PARENT(pop_id)
	local parenthood = DATA.get_parent_child_relation_from_child(pop_id)
	return DATA.parent_child_relation_get_parent(parenthood)
end

---commenting
---@param estate_id estate_id
function OWNER(estate_id)
	return DATA.ownership_get_owner(DATA.get_ownership_from_estate(estate_id))
end

function ACCEPT_ALL (item)
	return true
end

---Returns realm of a pop
---@param pop_id pop_id
function REALM(pop_id)
	local pop_realm = DATA.get_realm_pop_from_pop(pop_id)
	return DATA.realm_pop_get_realm(pop_realm)
end

---Returns local realm of a pop
---@param pop_id pop_id
function LOCAL_REALM(pop_id)
	local province = POP_PROVINCE(pop_id)
	local realm_membership = DATA.get_realm_provinces_from_province(province)
	return DATA.realm_provinces_get_realm(realm_membership)
end

---Returns realm of a pop
---@param pop_id pop_id
---@return boolean
function BUSY(pop_id)
	return DATA.pop_get_busy(pop_id)
end


---@param pop_id pop_id
---@return boolean
function FEMALE(pop_id)
	return DATA.pop_get_female(pop_id)
end

---@param pop_id pop_id
---@return string
function HESHE(pop_id)
	if FEMALE(pop_id) then
		return "she"
	else
		return "he"
	end
end
---@param pop_id pop_id
---@return string
function HIMHER(pop_id)
	if FEMALE(pop_id) then
		return "her"
	else
		return "him"
	end
end
---@param pop_id pop_id
---@return string
function HISHER(pop_id)
	if FEMALE(pop_id) then
		return "her"
	else
		return "his"
	end
end
---@param pop_id pop_id
---@return string
function HISHERS(pop_id)
	if FEMALE(pop_id) then
		return "hers"
	else
		return "his"
	end
end

---@param pop_id pop_id
---@return number
function AGE_YEARS(pop_id)
	return DCON.age_years(pop_id)
end

---@param pop_id pop_id
---@return number
function AGE_MONTHS(pop_id)
	return DCON.age_months(pop_id)
end

---@param pop_id pop_id
---@return number
function AGE_TICKS(pop_id)
	return DCON.age_ticks(pop_id)
end

---@param pop_id pop_id
---@return number
function AGE_MULTIPLIER(pop_id)
	return DCON.age_multiplier(pop_id)
end

---@param pop_id pop_id
---@return number year
---@return number month
---@return number day
---@return number hour
---@return number minute
function BIRTHDATE(pop_id)
	return
		DATA.pop_get_birth_year(pop_id),
		DCON.birth_month(pop_id),
		DCON.birth_day(pop_id),
		DCON.birth_hour(pop_id),
		DCON.birth_minute(pop_id)
end

---@param pop_id pop_id
---@return number free_time
---@return number warband_time
---@return number forage_time
---@return number work_time
function POP_TIME(pop_id)
	local free_time = DCON.pop_free_time(pop_id)
	local travel_time = DCON.pop_travel_time(pop_id,free_time)
	local forage_time = DCON.pop_forage_time(pop_id,free_time,travel_time)
	local work_time = DCON.pop_work_time(pop_id,free_time,travel_time,forage_time)
	return free_time,travel_time,forage_time,work_time
end

---@param pop_id pop_id
---@return boolean
function IS_DEPENDENT(pop_id)
	return DCON.is_dependent(pop_id)
end
---@param pop_id pop_id
---@param parent pop_id
---@return boolean
function IS_DEPENDENT_OF(pop_id,parent)
	return DCON.is_dependent_of(pop_id,parent)
end

---@param pop_id pop_id
function SET_BUSY(pop_id)
	DATA.pop_set_busy(pop_id, true)
end

---@param pop_id pop_id
function UNSET_BUSY(pop_id)
	DATA.pop_set_busy(pop_id, false)
end

---@param pop_id pop_id
---@param realm realm_id
function SET_REALM(pop_id, realm)
	local pop_realm = DATA.get_realm_pop_from_pop(pop_id)
	if pop_realm == INVALID_ID then
		DATA.force_create_realm_pop(realm, pop_id)
	else
		DATA.realm_pop_set_realm(pop_realm, realm)
	end
end

---commenting
---@param realm realm_id
---@return pop_id
function LEADER(realm)
	local leadership = DATA.get_realm_leadership_from_realm(realm)
	return DATA.realm_leadership_get_leader(leadership)
end

---commenting
---@param estate estate_id
---@return pop_id
function ESTATE_LEADER(estate)
	local leadership = DATA.get_estate_leader_from_estate(estate)
	return DATA.estate_leader_get_leader(leadership)
end

---@param estate estate_id
---@return pop_id
function ESTATE_RECRUITER(estate)
	local leadership = DATA.get_estate_recruiter_from_estate(etsate)
	return DATA.estate_recruiter_get_recruiter(leadership)
end

---commenting
---@param estate estate_id
---@return pop_id
function ESTATE_COMMANDER(estate)
	local leadership = DATA.get_estate_commander_from_estate(estate)
	return DATA.estate_commander_get_commander(leadership)
end

---commenting
---@param leader pop_id
---@return estate_id
function LEADER_OF_ESTATE(leader)
	if leader == INVALID_ID then
		return INVALID_ID
	end
	local leadership = DATA.get_estate_leader_from_leader(leader)
	return DATA.estate_leader_get_estate(leadership)
end


---@param party warband_id
---@return boolean
function IN_SETTLEMENT(party)
	return DATA.warband_get_in_settlement(party)
end

---@param tile tile_id
function TILE_PROVINCE(tile)
	return DATA.tile_province_membership_get_province(DATA.get_tile_province_membership_from_tile(tile))
end

---commenting
---@param leader pop_id
---@return estate_id
function RECRUITER_OF_ESTATE(leader)
	local leadership = DATA.get_estate_recruiter_from_recruiter(leader)
	return DATA.estate_recruiter_get_estate(leadership)
end

---@param leader pop_id
---@return estate_id
function COMMANDER_OF_ESTATE(leader)
	local leadership = DATA.get_estate_commander_from_commander(leader)
	return DATA.estate_commander_get_estate(leadership)
end

---commenting
---@param unit pop_id
---@return estate_id
function UNIT_OF(unit)
	local unitship = DATA.get_estate_unit_from_pop(unit)
	return DATA.estate_unit_get_estate(unitship)
end

---commenting
---@param unit pop_id
---@return unit_type_id
function UNIT_TYPE_OF(unit)
	local unitship = DATA.get_estate_unit_from_pop(unit)
	return DATA.estate_unit_get_type(unitship)
end

---@param pop_id pop_id
---@return CHARACTER_RANK
function RANK(pop_id)
	return DATA.pop_get_rank(pop_id)
end

---commenting
---@param realm realm_id
---@return province_id
function CAPITOL(realm)
	return DATA.realm_get_capitol(realm)
end

---commenting
---@param realm realm_id
---@return race_id
function MAIN_RACE(realm)
	return DATA.realm_get_primary_race(realm)
end

---commenting
---@param pop_id pop_id
---@return string
function NAME(pop_id)
	return DATA.pop_get_name(pop_id)
end

---commenting
---@param province_id province_id
---@return string
function PROVINCE_NAME(province_id)
	return DATA.province_get_name(province_id)
end

---commenting
---@param estate_id estate_id
---@return string
function ESTATE_NAME(estate_id)
	return DATA.estate_get_name(estate_id)
end

---commenting
---@param realm_id realm_id
---@return string
function REALM_NAME(realm_id)
	return DATA.realm_get_name(realm_id)
end

---commenting
---@param pop_id pop_id
---@return race_id
function RACE(pop_id)
	return DATA.pop_get_race(pop_id)
end

---commenting
---@param pop_id pop_id
---@return culture_id
function CULTURE(pop_id)
	return DATA.pop_get_culture(pop_id)
end

---@param pop_id pop_id
---@return fat_race_id
function F_RACE(pop_id)
	return DATA.fatten_race(RACE(pop_id))
end

---checks trait of character
---@param pop pop_id
---@param trait TRAIT
function HAS_TRAIT(pop, trait)
	for i = 1, MAX_TRAIT_INDEX  do
		if DATA.pop_get_traits(pop, i) == trait then
			return true
		end
	end
	return false
end

--- update these values when you change description in according generator descriptors

MAX_TRAIT_INDEX = 10
MAX_NEED_SATISFACTION_POSITIONS_INDEX = 19
MAX_RESOURCES_IN_PROVINCE_INDEX = 24
MAX_REQUIREMENTS_TECHNOLOGY = 20
MAX_REQUIREMENTS_BUILDING_TYPE = 20
MAX_REQUIREMENTS_RESOURCE = 20
MAX_SIZE_ARRAYS_PRODUCTION_METHOD = 8
INVALID_ID = 0

---@alias Character pop_id
---@alias POP pop_id
---@alias Province province_id
---@alias BuildingType building_type_id
---@alias Technology technology_id
---@alias Building building_id
---@alias Race race_id
---@alias Realm realm_id
---@alias Warband warband_id
---@alias Army warband_id[]

---@type table<trade_good_id, table<use_case_id, number>>
USE_WEIGHT = {}

function RECALCULATE_WEIGHTS_TABLE()
	DATA.for_each_trade_good(function (trade_good)
		USE_WEIGHT[trade_good] = {}
		DATA.for_each_use_case(function (use_case)
			USE_WEIGHT[trade_good][use_case] = 0
		end)
	end)

	DATA.for_each_use_weight(function (use_weight)
		local fat = DATA.fatten_use_weight(use_weight)
		assert(
			fat.trade_good ~= INVALID_ID,
			tostring(use_weight).. " " ..tostring(fat.trade_good).." " ..tostring( DATA.use_weight_get_trade_good(use_weight))
		)
		assert(
			fat.use_case ~= INVALID_ID,
			tostring(use_weight).." " ..tostring(fat.use_case).." " ..tostring(DATA.use_weight_get_use_case(use_weight))
		)
		USE_WEIGHT[fat.trade_good][fat.use_case] = fat.weight
	end)
end