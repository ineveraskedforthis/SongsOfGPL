local ffi = require("ffi")
ffi.cdef[[
    void* calloc( size_t num, size_t size );
]]
local buffer = require("string.buffer")

DATA = {}
require "codegen.output.budget_per_category_data"
require "codegen.output.trade_good_container"
require "codegen.output.use_case_container"
require "codegen.output.forage_container"
require "codegen.output.resource_location"
require "codegen.output.need_satisfaction"
require "codegen.output.need_definition"
require "codegen.output.tile"
require "codegen.output.plate"
require "codegen.output.plate_tiles"
require "codegen.output.language"
require "codegen.output.culture"
require "codegen.output.culture_group"
require "codegen.output.cultural_union"
require "codegen.output.faith"
require "codegen.output.religion"
require "codegen.output.subreligion"
require "codegen.output.pop"
require "codegen.output.province"
require "codegen.output.realm"
require "codegen.output.negotiation"
require "codegen.output.building"
require "codegen.output.estate"
require "codegen.output.ownership"
require "codegen.output.employment"
require "codegen.output.estate_location"
require "codegen.output.building_estate"
require "codegen.output.estate_unit"
require "codegen.output.estate_leader"
require "codegen.output.estate_recruiter"
require "codegen.output.estate_commander"
require "codegen.output.character_location"
require "codegen.output.home"
require "codegen.output.outlaw_location"
require "codegen.output.tile_province_membership"
require "codegen.output.province_neighborhood"
require "codegen.output.parent_child_relation"
require "codegen.output.loyalty"
require "codegen.output.succession"
require "codegen.output.realm_guard"
require "codegen.output.realm_overseer"
require "codegen.output.realm_leadership"
require "codegen.output.realm_subject_relation"
require "codegen.output.tax_collector"
require "codegen.output.personal_rights"
require "codegen.output.realm_provinces"
require "codegen.output.popularity"
require "codegen.output.realm_pop"
require "codegen.output.jobtype"
require "codegen.output.need"
require "codegen.output.character_rank"
require "codegen.output.trait"
require "codegen.output.trade_good_category"
require "codegen.output.estate_status"
require "codegen.output.estate_stance"
require "codegen.output.building_archetype"
require "codegen.output.forage_resource"
require "codegen.output.budget_category"
require "codegen.output.economy_reason"
require "codegen.output.politics_reason"
require "codegen.output.unit_type"
require "codegen.output.law_trade"
require "codegen.output.law_building"
require "codegen.output.trade_good"
require "codegen.output.use_case"
require "codegen.output.use_weight"
require "codegen.output.biome"
require "codegen.output.bedrock"
require "codegen.output.resource"
require "codegen.output.job"
require "codegen.output.production_method"
require "codegen.output.technology"
require "codegen.output.technology_unlock"
require "codegen.output.building_type"
require "codegen.output.technology_building"
require "codegen.output.technology_unit"
require "codegen.output.race"

---@class LuaDataBlob
---@field plate_done_expanding (boolean)[]
---@field plate_current_tiles (table<number,tile_id>)[]
---@field plate_next_tiles (table<number,tile_id>)[]
---@field plate_plate_neighbors (table<number,plate_id>)[]
---@field plate_plate_edge (table<number,tile_id>)[]
---@field plate_plate_boundaries (table<number,tile_id>)[]
---@field language_syllables (table<number,string>)[]
---@field language_consonants (table<number,string>)[]
---@field language_vowels (table<number,string>)[]
---@field language_ending_province (table<number,string>)[]
---@field language_ending_realm (table<number,string>)[]
---@field language_ending_adj (table<number,string>)[]
---@field language_ranks (table<number,string>)[]
---@field culture_name (string)[]
---@field culture_group_name (string)[]
---@field culture_group_r (number)[]
---@field culture_group_g (number)[]
---@field culture_group_b (number)[]
---@field culture_group_view_on_treason (number)[]
---@field faith_name (string)[]
---@field faith_burial_rites (BURIAL_RITES)[]
---@field religion_name (string)[]
---@field religion_r (number)[]
---@field religion_g (number)[]
---@field religion_b (number)[]
---@field pop_name (string)[]
---@field pop_ai_data (AI_DATA)[]
---@field province_name (string)[]
---@field realm_exists (boolean)[]
---@field realm_name (string)[]
---@field realm_quests_raid (table<province_id,nil|number>)[]
---@field realm_quests_explore (table<province_id,nil|number>)[]
---@field realm_quests_patrol (table<province_id,nil|number>)[]
---@field realm_patrols (table<province_id,table<warband_id,warband_id>>)[]
---@field realm_known_provinces (table<province_id,province_id>)[]
---@field estate_name (string)[]
---@field estate_movement_progress (number)[]
---@field estate_current_path (table<tile_id>)[]

function DATA.save_state()
    local current_lua_state = {}
    current_lua_state.WORLD = WORLD
    current_lua_state.plate_done_expanding = DATA.plate_done_expanding
    current_lua_state.plate_current_tiles = DATA.plate_current_tiles
    current_lua_state.plate_next_tiles = DATA.plate_next_tiles
    current_lua_state.plate_plate_neighbors = DATA.plate_plate_neighbors
    current_lua_state.plate_plate_edge = DATA.plate_plate_edge
    current_lua_state.plate_plate_boundaries = DATA.plate_plate_boundaries
    current_lua_state.language_syllables = DATA.language_syllables
    current_lua_state.language_consonants = DATA.language_consonants
    current_lua_state.language_vowels = DATA.language_vowels
    current_lua_state.language_ending_province = DATA.language_ending_province
    current_lua_state.language_ending_realm = DATA.language_ending_realm
    current_lua_state.language_ending_adj = DATA.language_ending_adj
    current_lua_state.language_ranks = DATA.language_ranks
    current_lua_state.culture_name = DATA.culture_name
    current_lua_state.culture_group_name = DATA.culture_group_name
    current_lua_state.culture_group_r = DATA.culture_group_r
    current_lua_state.culture_group_g = DATA.culture_group_g
    current_lua_state.culture_group_b = DATA.culture_group_b
    current_lua_state.culture_group_view_on_treason = DATA.culture_group_view_on_treason
    current_lua_state.faith_name = DATA.faith_name
    current_lua_state.faith_burial_rites = DATA.faith_burial_rites
    current_lua_state.religion_name = DATA.religion_name
    current_lua_state.religion_r = DATA.religion_r
    current_lua_state.religion_g = DATA.religion_g
    current_lua_state.religion_b = DATA.religion_b
    current_lua_state.pop_name = DATA.pop_name
    current_lua_state.pop_ai_data = DATA.pop_ai_data
    current_lua_state.province_name = DATA.province_name
    current_lua_state.realm_exists = DATA.realm_exists
    current_lua_state.realm_name = DATA.realm_name
    current_lua_state.realm_quests_raid = DATA.realm_quests_raid
    current_lua_state.realm_quests_explore = DATA.realm_quests_explore
    current_lua_state.realm_quests_patrol = DATA.realm_quests_patrol
    current_lua_state.realm_patrols = DATA.realm_patrols
    current_lua_state.realm_known_provinces = DATA.realm_known_provinces
    current_lua_state.estate_name = DATA.estate_name
    current_lua_state.estate_movement_progress = DATA.estate_movement_progress
    current_lua_state.estate_current_path = DATA.estate_current_path
    current_lua_state.jobtype_name = DATA.jobtype_name
    current_lua_state.jobtype_action_word = DATA.jobtype_action_word
    current_lua_state.jobtype_icon = DATA.jobtype_icon
    current_lua_state.need_name = DATA.need_name
    current_lua_state.character_rank_name = DATA.character_rank_name
    current_lua_state.character_rank_localisation = DATA.character_rank_localisation
    current_lua_state.trait_name = DATA.trait_name
    current_lua_state.trait_short_description = DATA.trait_short_description
    current_lua_state.trait_full_description = DATA.trait_full_description
    current_lua_state.trait_icon = DATA.trait_icon
    current_lua_state.trade_good_category_name = DATA.trade_good_category_name
    current_lua_state.estate_status_name = DATA.estate_status_name
    current_lua_state.estate_status_action_string = DATA.estate_status_action_string
    current_lua_state.estate_status_icon = DATA.estate_status_icon
    current_lua_state.estate_stance_name = DATA.estate_stance_name
    current_lua_state.building_archetype_name = DATA.building_archetype_name
    current_lua_state.forage_resource_name = DATA.forage_resource_name
    current_lua_state.forage_resource_description = DATA.forage_resource_description
    current_lua_state.forage_resource_icon = DATA.forage_resource_icon
    current_lua_state.budget_category_name = DATA.budget_category_name
    current_lua_state.economy_reason_name = DATA.economy_reason_name
    current_lua_state.economy_reason_description = DATA.economy_reason_description
    current_lua_state.politics_reason_name = DATA.politics_reason_name
    current_lua_state.politics_reason_description = DATA.politics_reason_description
    current_lua_state.unit_type_name = DATA.unit_type_name
    current_lua_state.unit_type_description = DATA.unit_type_description
    current_lua_state.unit_type_icon = DATA.unit_type_icon
    current_lua_state.law_trade_name = DATA.law_trade_name
    current_lua_state.law_building_name = DATA.law_building_name
    current_lua_state.trade_good_name = DATA.trade_good_name
    current_lua_state.trade_good_icon = DATA.trade_good_icon
    current_lua_state.trade_good_description = DATA.trade_good_description
    current_lua_state.use_case_name = DATA.use_case_name
    current_lua_state.use_case_icon = DATA.use_case_icon
    current_lua_state.use_case_description = DATA.use_case_description
    current_lua_state.biome_name = DATA.biome_name
    current_lua_state.bedrock_name = DATA.bedrock_name
    current_lua_state.resource_name = DATA.resource_name
    current_lua_state.resource_icon = DATA.resource_icon
    current_lua_state.resource_description = DATA.resource_description
    current_lua_state.job_name = DATA.job_name
    current_lua_state.job_icon = DATA.job_icon
    current_lua_state.job_description = DATA.job_description
    current_lua_state.production_method_name = DATA.production_method_name
    current_lua_state.production_method_icon = DATA.production_method_icon
    current_lua_state.production_method_description = DATA.production_method_description
    current_lua_state.technology_name = DATA.technology_name
    current_lua_state.technology_icon = DATA.technology_icon
    current_lua_state.technology_description = DATA.technology_description
    current_lua_state.technology_required_race = DATA.technology_required_race
    current_lua_state.building_type_name = DATA.building_type_name
    current_lua_state.building_type_icon = DATA.building_type_icon
    current_lua_state.building_type_description = DATA.building_type_description
    current_lua_state.race_name = DATA.race_name
    current_lua_state.race_icon = DATA.race_icon
    current_lua_state.race_female_portrait = DATA.race_female_portrait
    current_lua_state.race_male_portrait = DATA.race_male_portrait
    current_lua_state.race_description = DATA.race_description

    local buf_enc = buffer.new()
love.filesystem.write("gamestatesave.bitserbeaver", buf_enc:reset():encode(current_lua_state):get())
end
function DATA.check_state()
    print(string.format("%.2f %%", DCON.dcon_tile_size() / 1500000 * 100), "tile", 1500000)
    print(string.format("%.2f %%", DCON.dcon_plate_size() / 50 * 100), "plate", 50)
    print(string.format("%.2f %%", DCON.dcon_plate_tiles_size() / 1500020 * 100), "plate_tiles", 1500020)
    print(string.format("%.2f %%", DCON.dcon_language_size() / 10000 * 100), "language", 10000)
    print(string.format("%.2f %%", DCON.dcon_culture_size() / 10000 * 100), "culture", 10000)
    print(string.format("%.2f %%", DCON.dcon_culture_group_size() / 10000 * 100), "culture_group", 10000)
    print(string.format("%.2f %%", DCON.dcon_cultural_union_size() / 10000 * 100), "cultural_union", 10000)
    print(string.format("%.2f %%", DCON.dcon_faith_size() / 10000 * 100), "faith", 10000)
    print(string.format("%.2f %%", DCON.dcon_religion_size() / 10000 * 100), "religion", 10000)
    print(string.format("%.2f %%", DCON.dcon_subreligion_size() / 10000 * 100), "subreligion", 10000)
    print(string.format("%.2f %%", DCON.dcon_pop_size() / 300000 * 100), "pop", 300000)
    print(string.format("%.2f %%", DCON.dcon_province_size() / 20000 * 100), "province", 20000)
    print(string.format("%.2f %%", DCON.dcon_realm_size() / 15000 * 100), "realm", 15000)
    print(string.format("%.2f %%", DCON.dcon_negotiation_size() / 45000 * 100), "negotiation", 45000)
    print(string.format("%.2f %%", DCON.dcon_building_size() / 6000000 * 100), "building", 6000000)
    print(string.format("%.2f %%", DCON.dcon_estate_size() / 300000 * 100), "estate", 300000)
    print(string.format("%.2f %%", DCON.dcon_ownership_size() / 300000 * 100), "ownership", 300000)
    print(string.format("%.2f %%", DCON.dcon_employment_size() / 600000 * 100), "employment", 600000)
    print(string.format("%.2f %%", DCON.dcon_estate_location_size() / 300000 * 100), "estate_location", 300000)
    print(string.format("%.2f %%", DCON.dcon_building_estate_size() / 6000000 * 100), "building_estate", 6000000)
    print(string.format("%.2f %%", DCON.dcon_estate_unit_size() / 300000 * 100), "estate_unit", 300000)
    print(string.format("%.2f %%", DCON.dcon_estate_leader_size() / 50000 * 100), "estate_leader", 50000)
    print(string.format("%.2f %%", DCON.dcon_estate_recruiter_size() / 50000 * 100), "estate_recruiter", 50000)
    print(string.format("%.2f %%", DCON.dcon_estate_commander_size() / 50000 * 100), "estate_commander", 50000)
    print(string.format("%.2f %%", DCON.dcon_character_location_size() / 100000 * 100), "character_location", 100000)
    print(string.format("%.2f %%", DCON.dcon_home_size() / 300000 * 100), "home", 300000)
    print(string.format("%.2f %%", DCON.dcon_outlaw_location_size() / 300000 * 100), "outlaw_location", 300000)
    print(string.format("%.2f %%", DCON.dcon_tile_province_membership_size() / 1500000 * 100), "tile_province_membership", 1500000)
    print(string.format("%.2f %%", DCON.dcon_province_neighborhood_size() / 250000 * 100), "province_neighborhood", 250000)
    print(string.format("%.2f %%", DCON.dcon_parent_child_relation_size() / 900000 * 100), "parent_child_relation", 900000)
    print(string.format("%.2f %%", DCON.dcon_loyalty_size() / 200000 * 100), "loyalty", 200000)
    print(string.format("%.2f %%", DCON.dcon_succession_size() / 200000 * 100), "succession", 200000)
    print(string.format("%.2f %%", DCON.dcon_realm_guard_size() / 15000 * 100), "realm_guard", 15000)
    print(string.format("%.2f %%", DCON.dcon_realm_overseer_size() / 15000 * 100), "realm_overseer", 15000)
    print(string.format("%.2f %%", DCON.dcon_realm_leadership_size() / 15000 * 100), "realm_leadership", 15000)
    print(string.format("%.2f %%", DCON.dcon_realm_subject_relation_size() / 15000 * 100), "realm_subject_relation", 15000)
    print(string.format("%.2f %%", DCON.dcon_tax_collector_size() / 45000 * 100), "tax_collector", 45000)
    print(string.format("%.2f %%", DCON.dcon_personal_rights_size() / 450000 * 100), "personal_rights", 450000)
    print(string.format("%.2f %%", DCON.dcon_realm_provinces_size() / 30000 * 100), "realm_provinces", 30000)
    print(string.format("%.2f %%", DCON.dcon_popularity_size() / 450000 * 100), "popularity", 450000)
    print(string.format("%.2f %%", DCON.dcon_realm_pop_size() / 300000 * 100), "realm_pop", 300000)
end
function DATA.load_state()
    local buf_dec = buffer.new()
    local serializedData, error = love.filesystem.newFileData("gamestatesave.bitserbeaver")
    assert(serializedData, error)
    ---@type LuaDataBlob|nil
    local loaded_lua_state = buf_dec:set(serializedData:getString()):decode()
    assert(loaded_lua_state)
    WORLD = loaded_lua_state.WORLD
    DATA.plate_done_expanding = loaded_lua_state.plate_done_expanding
    DATA.plate_current_tiles = loaded_lua_state.plate_current_tiles
    DATA.plate_next_tiles = loaded_lua_state.plate_next_tiles
    DATA.plate_plate_neighbors = loaded_lua_state.plate_plate_neighbors
    DATA.plate_plate_edge = loaded_lua_state.plate_plate_edge
    DATA.plate_plate_boundaries = loaded_lua_state.plate_plate_boundaries
    DATA.language_syllables = loaded_lua_state.language_syllables
    DATA.language_consonants = loaded_lua_state.language_consonants
    DATA.language_vowels = loaded_lua_state.language_vowels
    DATA.language_ending_province = loaded_lua_state.language_ending_province
    DATA.language_ending_realm = loaded_lua_state.language_ending_realm
    DATA.language_ending_adj = loaded_lua_state.language_ending_adj
    DATA.language_ranks = loaded_lua_state.language_ranks
    DATA.culture_name = loaded_lua_state.culture_name
    DATA.culture_group_name = loaded_lua_state.culture_group_name
    DATA.culture_group_r = loaded_lua_state.culture_group_r
    DATA.culture_group_g = loaded_lua_state.culture_group_g
    DATA.culture_group_b = loaded_lua_state.culture_group_b
    DATA.culture_group_view_on_treason = loaded_lua_state.culture_group_view_on_treason
    DATA.faith_name = loaded_lua_state.faith_name
    DATA.faith_burial_rites = loaded_lua_state.faith_burial_rites
    DATA.religion_name = loaded_lua_state.religion_name
    DATA.religion_r = loaded_lua_state.religion_r
    DATA.religion_g = loaded_lua_state.religion_g
    DATA.religion_b = loaded_lua_state.religion_b
    DATA.pop_name = loaded_lua_state.pop_name
    DATA.pop_ai_data = loaded_lua_state.pop_ai_data
    DATA.province_name = loaded_lua_state.province_name
    DATA.realm_exists = loaded_lua_state.realm_exists
    DATA.realm_name = loaded_lua_state.realm_name
    DATA.realm_quests_raid = loaded_lua_state.realm_quests_raid
    DATA.realm_quests_explore = loaded_lua_state.realm_quests_explore
    DATA.realm_quests_patrol = loaded_lua_state.realm_quests_patrol
    DATA.realm_patrols = loaded_lua_state.realm_patrols
    DATA.realm_known_provinces = loaded_lua_state.realm_known_provinces
    DATA.estate_name = loaded_lua_state.estate_name
    DATA.estate_movement_progress = loaded_lua_state.estate_movement_progress
    DATA.estate_current_path = loaded_lua_state.estate_current_path
    DATA.jobtype_name = loaded_lua_state.jobtype_name
    DATA.jobtype_action_word = loaded_lua_state.jobtype_action_word
    DATA.jobtype_icon = loaded_lua_state.jobtype_icon
    DATA.need_name = loaded_lua_state.need_name
    DATA.character_rank_name = loaded_lua_state.character_rank_name
    DATA.character_rank_localisation = loaded_lua_state.character_rank_localisation
    DATA.trait_name = loaded_lua_state.trait_name
    DATA.trait_short_description = loaded_lua_state.trait_short_description
    DATA.trait_full_description = loaded_lua_state.trait_full_description
    DATA.trait_icon = loaded_lua_state.trait_icon
    DATA.trade_good_category_name = loaded_lua_state.trade_good_category_name
    DATA.estate_status_name = loaded_lua_state.estate_status_name
    DATA.estate_status_action_string = loaded_lua_state.estate_status_action_string
    DATA.estate_status_icon = loaded_lua_state.estate_status_icon
    DATA.estate_stance_name = loaded_lua_state.estate_stance_name
    DATA.building_archetype_name = loaded_lua_state.building_archetype_name
    DATA.forage_resource_name = loaded_lua_state.forage_resource_name
    DATA.forage_resource_description = loaded_lua_state.forage_resource_description
    DATA.forage_resource_icon = loaded_lua_state.forage_resource_icon
    DATA.budget_category_name = loaded_lua_state.budget_category_name
    DATA.economy_reason_name = loaded_lua_state.economy_reason_name
    DATA.economy_reason_description = loaded_lua_state.economy_reason_description
    DATA.politics_reason_name = loaded_lua_state.politics_reason_name
    DATA.politics_reason_description = loaded_lua_state.politics_reason_description
    DATA.unit_type_name = loaded_lua_state.unit_type_name
    DATA.unit_type_description = loaded_lua_state.unit_type_description
    DATA.unit_type_icon = loaded_lua_state.unit_type_icon
    DATA.law_trade_name = loaded_lua_state.law_trade_name
    DATA.law_building_name = loaded_lua_state.law_building_name
    DATA.trade_good_name = loaded_lua_state.trade_good_name
    DATA.trade_good_icon = loaded_lua_state.trade_good_icon
    DATA.trade_good_description = loaded_lua_state.trade_good_description
    DATA.use_case_name = loaded_lua_state.use_case_name
    DATA.use_case_icon = loaded_lua_state.use_case_icon
    DATA.use_case_description = loaded_lua_state.use_case_description
    DATA.biome_name = loaded_lua_state.biome_name
    DATA.bedrock_name = loaded_lua_state.bedrock_name
    DATA.resource_name = loaded_lua_state.resource_name
    DATA.resource_icon = loaded_lua_state.resource_icon
    DATA.resource_description = loaded_lua_state.resource_description
    DATA.job_name = loaded_lua_state.job_name
    DATA.job_icon = loaded_lua_state.job_icon
    DATA.job_description = loaded_lua_state.job_description
    DATA.production_method_name = loaded_lua_state.production_method_name
    DATA.production_method_icon = loaded_lua_state.production_method_icon
    DATA.production_method_description = loaded_lua_state.production_method_description
    DATA.technology_name = loaded_lua_state.technology_name
    DATA.technology_icon = loaded_lua_state.technology_icon
    DATA.technology_description = loaded_lua_state.technology_description
    DATA.technology_required_race = loaded_lua_state.technology_required_race
    DATA.building_type_name = loaded_lua_state.building_type_name
    DATA.building_type_icon = loaded_lua_state.building_type_icon
    DATA.building_type_description = loaded_lua_state.building_type_description
    DATA.race_name = loaded_lua_state.race_name
    DATA.race_icon = loaded_lua_state.race_icon
    DATA.race_female_portrait = loaded_lua_state.race_female_portrait
    DATA.race_male_portrait = loaded_lua_state.race_male_portrait
    DATA.race_description = loaded_lua_state.race_description
end
function DATA.test_set_get_0()
    local id = DATA.create_tile()
    local fat_id = DATA.fatten_tile(id)
    fat_id.world_id = 12
    fat_id.is_land = false
    fat_id.is_fresh = true
    fat_id.is_border = false
    fat_id.is_coast = false
    fat_id.has_river = false
    fat_id.has_marsh = false
    fat_id.x = 10
    fat_id.y = 2
    fat_id.z = 17
    fat_id.elevation = -7
    fat_id.slope = 12
    fat_id.grass = -12
    fat_id.shrub = -2
    fat_id.conifer = -12
    fat_id.broadleaf = -14
    fat_id.ideal_grass = 19
    fat_id.ideal_shrub = -4
    fat_id.ideal_conifer = 14
    fat_id.ideal_broadleaf = 18
    fat_id.silt = -11
    fat_id.clay = -1
    fat_id.sand = -14
    fat_id.soil_minerals = -16
    fat_id.soil_organics = 1
    fat_id.january_waterflow = 10
    fat_id.january_rain = 15
    fat_id.january_temperature = -14
    fat_id.july_waterflow = 2
    fat_id.july_rain = 7
    fat_id.july_temperature = 0
    fat_id.waterlevel = 19
    fat_id.ice = 20
    fat_id.ice_age_ice = -7
    fat_id.debug_r = 15
    fat_id.debug_g = 10
    fat_id.debug_b = 8
    fat_id.real_r = 13
    fat_id.real_g = -4
    fat_id.real_b = -17
    fat_id.pathfinding_index = 17
    fat_id.resource = -20
    fat_id.bedrock = -15
    fat_id.biome = 5
    fat_id.foragers_limit = 20
    for j = 1, 7 do
        DATA.tile_set_foragers_targets_resource(id, j, -20)
    end
    for j = 1, 7 do
        DATA.tile_set_foragers_targets_limit(id, j, 19)
    end
    for j = 1, 7 do
        DATA.tile_set_foragers_targets_amount(id, j, 11)
    end
    for j = 1, 7 do
        DATA.tile_set_foragers_targets_efficiency(id, j, 1)
    end
    fat_id.infrastructure_needed = -5
    fat_id.infrastructure = 0
    fat_id.infrastructure_investment = -16
    fat_id.infrastructure_efficiency = -8
    local test_passed = true
    test_passed = test_passed and fat_id.world_id == 12
    if not test_passed then print("world_id", 12, fat_id.world_id) end
    test_passed = test_passed and fat_id.is_land == false
    if not test_passed then print("is_land", false, fat_id.is_land) end
    test_passed = test_passed and fat_id.is_fresh == true
    if not test_passed then print("is_fresh", true, fat_id.is_fresh) end
    test_passed = test_passed and fat_id.is_border == false
    if not test_passed then print("is_border", false, fat_id.is_border) end
    test_passed = test_passed and fat_id.is_coast == false
    if not test_passed then print("is_coast", false, fat_id.is_coast) end
    test_passed = test_passed and fat_id.has_river == false
    if not test_passed then print("has_river", false, fat_id.has_river) end
    test_passed = test_passed and fat_id.has_marsh == false
    if not test_passed then print("has_marsh", false, fat_id.has_marsh) end
    test_passed = test_passed and fat_id.x == 10
    if not test_passed then print("x", 10, fat_id.x) end
    test_passed = test_passed and fat_id.y == 2
    if not test_passed then print("y", 2, fat_id.y) end
    test_passed = test_passed and fat_id.z == 17
    if not test_passed then print("z", 17, fat_id.z) end
    test_passed = test_passed and fat_id.elevation == -7
    if not test_passed then print("elevation", -7, fat_id.elevation) end
    test_passed = test_passed and fat_id.slope == 12
    if not test_passed then print("slope", 12, fat_id.slope) end
    test_passed = test_passed and fat_id.grass == -12
    if not test_passed then print("grass", -12, fat_id.grass) end
    test_passed = test_passed and fat_id.shrub == -2
    if not test_passed then print("shrub", -2, fat_id.shrub) end
    test_passed = test_passed and fat_id.conifer == -12
    if not test_passed then print("conifer", -12, fat_id.conifer) end
    test_passed = test_passed and fat_id.broadleaf == -14
    if not test_passed then print("broadleaf", -14, fat_id.broadleaf) end
    test_passed = test_passed and fat_id.ideal_grass == 19
    if not test_passed then print("ideal_grass", 19, fat_id.ideal_grass) end
    test_passed = test_passed and fat_id.ideal_shrub == -4
    if not test_passed then print("ideal_shrub", -4, fat_id.ideal_shrub) end
    test_passed = test_passed and fat_id.ideal_conifer == 14
    if not test_passed then print("ideal_conifer", 14, fat_id.ideal_conifer) end
    test_passed = test_passed and fat_id.ideal_broadleaf == 18
    if not test_passed then print("ideal_broadleaf", 18, fat_id.ideal_broadleaf) end
    test_passed = test_passed and fat_id.silt == -11
    if not test_passed then print("silt", -11, fat_id.silt) end
    test_passed = test_passed and fat_id.clay == -1
    if not test_passed then print("clay", -1, fat_id.clay) end
    test_passed = test_passed and fat_id.sand == -14
    if not test_passed then print("sand", -14, fat_id.sand) end
    test_passed = test_passed and fat_id.soil_minerals == -16
    if not test_passed then print("soil_minerals", -16, fat_id.soil_minerals) end
    test_passed = test_passed and fat_id.soil_organics == 1
    if not test_passed then print("soil_organics", 1, fat_id.soil_organics) end
    test_passed = test_passed and fat_id.january_waterflow == 10
    if not test_passed then print("january_waterflow", 10, fat_id.january_waterflow) end
    test_passed = test_passed and fat_id.january_rain == 15
    if not test_passed then print("january_rain", 15, fat_id.january_rain) end
    test_passed = test_passed and fat_id.january_temperature == -14
    if not test_passed then print("january_temperature", -14, fat_id.january_temperature) end
    test_passed = test_passed and fat_id.july_waterflow == 2
    if not test_passed then print("july_waterflow", 2, fat_id.july_waterflow) end
    test_passed = test_passed and fat_id.july_rain == 7
    if not test_passed then print("july_rain", 7, fat_id.july_rain) end
    test_passed = test_passed and fat_id.july_temperature == 0
    if not test_passed then print("july_temperature", 0, fat_id.july_temperature) end
    test_passed = test_passed and fat_id.waterlevel == 19
    if not test_passed then print("waterlevel", 19, fat_id.waterlevel) end
    test_passed = test_passed and fat_id.ice == 20
    if not test_passed then print("ice", 20, fat_id.ice) end
    test_passed = test_passed and fat_id.ice_age_ice == -7
    if not test_passed then print("ice_age_ice", -7, fat_id.ice_age_ice) end
    test_passed = test_passed and fat_id.debug_r == 15
    if not test_passed then print("debug_r", 15, fat_id.debug_r) end
    test_passed = test_passed and fat_id.debug_g == 10
    if not test_passed then print("debug_g", 10, fat_id.debug_g) end
    test_passed = test_passed and fat_id.debug_b == 8
    if not test_passed then print("debug_b", 8, fat_id.debug_b) end
    test_passed = test_passed and fat_id.real_r == 13
    if not test_passed then print("real_r", 13, fat_id.real_r) end
    test_passed = test_passed and fat_id.real_g == -4
    if not test_passed then print("real_g", -4, fat_id.real_g) end
    test_passed = test_passed and fat_id.real_b == -17
    if not test_passed then print("real_b", -17, fat_id.real_b) end
    test_passed = test_passed and fat_id.pathfinding_index == 17
    if not test_passed then print("pathfinding_index", 17, fat_id.pathfinding_index) end
    test_passed = test_passed and fat_id.resource == -20
    if not test_passed then print("resource", -20, fat_id.resource) end
    test_passed = test_passed and fat_id.bedrock == -15
    if not test_passed then print("bedrock", -15, fat_id.bedrock) end
    test_passed = test_passed and fat_id.biome == 5
    if not test_passed then print("biome", 5, fat_id.biome) end
    test_passed = test_passed and fat_id.foragers_limit == 20
    if not test_passed then print("foragers_limit", 20, fat_id.foragers_limit) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.tile_get_foragers_targets_resource(id, j) == -20
    end
    if not test_passed then print("foragers_targets.resource", -20, DATA.tile[id].foragers_targets[0].resource) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.tile_get_foragers_targets_limit(id, j) == 19
    end
    if not test_passed then print("foragers_targets.limit", 19, DATA.tile[id].foragers_targets[0].limit) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.tile_get_foragers_targets_amount(id, j) == 11
    end
    if not test_passed then print("foragers_targets.amount", 11, DATA.tile[id].foragers_targets[0].amount) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.tile_get_foragers_targets_efficiency(id, j) == 1
    end
    if not test_passed then print("foragers_targets.efficiency", 1, DATA.tile[id].foragers_targets[0].efficiency) end
    test_passed = test_passed and fat_id.infrastructure_needed == -5
    if not test_passed then print("infrastructure_needed", -5, fat_id.infrastructure_needed) end
    test_passed = test_passed and fat_id.infrastructure == 0
    if not test_passed then print("infrastructure", 0, fat_id.infrastructure) end
    test_passed = test_passed and fat_id.infrastructure_investment == -16
    if not test_passed then print("infrastructure_investment", -16, fat_id.infrastructure_investment) end
    test_passed = test_passed and fat_id.infrastructure_efficiency == -8
    if not test_passed then print("infrastructure_efficiency", -8, fat_id.infrastructure_efficiency) end
    print("SET_GET_TEST_0_tile:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_plate()
    local fat_id = DATA.fatten_plate(id)
    fat_id.r = 4
    fat_id.g = 6
    fat_id.b = -18
    fat_id.speed = -4
    fat_id.direction = 12
    fat_id.expansion_rate = 11
    local test_passed = true
    test_passed = test_passed and fat_id.r == 4
    if not test_passed then print("r", 4, fat_id.r) end
    test_passed = test_passed and fat_id.g == 6
    if not test_passed then print("g", 6, fat_id.g) end
    test_passed = test_passed and fat_id.b == -18
    if not test_passed then print("b", -18, fat_id.b) end
    test_passed = test_passed and fat_id.speed == -4
    if not test_passed then print("speed", -4, fat_id.speed) end
    test_passed = test_passed and fat_id.direction == 12
    if not test_passed then print("direction", 12, fat_id.direction) end
    test_passed = test_passed and fat_id.expansion_rate == 11
    if not test_passed then print("expansion_rate", 11, fat_id.expansion_rate) end
    print("SET_GET_TEST_0_plate:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_language()
    local fat_id = DATA.fatten_language(id)
    local test_passed = true
    print("SET_GET_TEST_0_language:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_culture()
    local fat_id = DATA.fatten_culture(id)
    fat_id.r = 4
    fat_id.g = 6
    fat_id.b = -18
    fat_id.language = -4
    for j = 1, 5 do
        DATA.culture_set_traditional_units(id, j --[[@as unit_type_id]],  12)    end
    fat_id.traditional_militarization = 11
    for j = 1, 250 do
        DATA.culture_set_traditional_forager_targets(id, j --[[@as production_method_id]],  5)    end
    local test_passed = true
    test_passed = test_passed and fat_id.r == 4
    if not test_passed then print("r", 4, fat_id.r) end
    test_passed = test_passed and fat_id.g == 6
    if not test_passed then print("g", 6, fat_id.g) end
    test_passed = test_passed and fat_id.b == -18
    if not test_passed then print("b", -18, fat_id.b) end
    test_passed = test_passed and fat_id.language == -4
    if not test_passed then print("language", -4, fat_id.language) end
    for j = 1, 5 do
        test_passed = test_passed and DATA.culture_get_traditional_units(id, j --[[@as unit_type_id]]) == 12
    end
    if not test_passed then print("traditional_units", 12, DATA.culture[id].traditional_units[0]) end
    test_passed = test_passed and fat_id.traditional_militarization == 11
    if not test_passed then print("traditional_militarization", 11, fat_id.traditional_militarization) end
    for j = 1, 250 do
        test_passed = test_passed and DATA.culture_get_traditional_forager_targets(id, j --[[@as production_method_id]]) == 5
    end
    if not test_passed then print("traditional_forager_targets", 5, DATA.culture[id].traditional_forager_targets[0]) end
    print("SET_GET_TEST_0_culture:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_culture_group()
    local fat_id = DATA.fatten_culture_group(id)
    fat_id.language = 4
    local test_passed = true
    test_passed = test_passed and fat_id.language == 4
    if not test_passed then print("language", 4, fat_id.language) end
    print("SET_GET_TEST_0_culture_group:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_faith()
    local fat_id = DATA.fatten_faith(id)
    fat_id.r = 4
    fat_id.g = 6
    fat_id.b = -18
    local test_passed = true
    test_passed = test_passed and fat_id.r == 4
    if not test_passed then print("r", 4, fat_id.r) end
    test_passed = test_passed and fat_id.g == 6
    if not test_passed then print("g", 6, fat_id.g) end
    test_passed = test_passed and fat_id.b == -18
    if not test_passed then print("b", -18, fat_id.b) end
    print("SET_GET_TEST_0_faith:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_religion()
    local fat_id = DATA.fatten_religion(id)
    local test_passed = true
    print("SET_GET_TEST_0_religion:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_pop()
    local fat_id = DATA.fatten_pop(id)
    fat_id.unique_id = 12
    fat_id.race = 6
    fat_id.faith = -18
    fat_id.culture = -4
    fat_id.birth_year = 12
    fat_id.birth_tick = 15
    for j = 1, 10 do
        DATA.pop_set_traits(id, j --[[@as number]],  6)    end
    for j = 1, 20 do
        DATA.pop_set_need_satisfaction_need(id, j, 4)
    end
    for j = 1, 20 do
        DATA.pop_set_need_satisfaction_use_case(id, j, 10)
    end
    for j = 1, 20 do
        DATA.pop_set_need_satisfaction_consumed(id, j, 2)
    end
    for j = 1, 20 do
        DATA.pop_set_need_satisfaction_demanded(id, j, 17)
    end
    for j = 1, 100 do
        DATA.pop_set_inventory(id, j --[[@as trade_good_id]],  -7)    end
    for j = 1, 100 do
        DATA.pop_set_price_belief_sell(id, j --[[@as trade_good_id]],  12)    end
    for j = 1, 100 do
        DATA.pop_set_price_belief_buy(id, j --[[@as trade_good_id]],  -12)    end
    fat_id.savings = -2
    fat_id.expected_wage = -12
    fat_id.life_needs_satisfaction = -14
    fat_id.basic_needs_satisfaction = 19
    fat_id.pending_economy_income = -4
    fat_id.forage_ratio = 14
    fat_id.work_ratio = 18
    fat_id.spend_savings_ratio = -11
    fat_id.female = false
    fat_id.busy = true
    fat_id.former_pop = true
    fat_id.dead = false
    fat_id.free_will = false
    fat_id.is_player = true
    fat_id.rank = 2
    for j = 1, 20 do
        DATA.pop_set_dna(id, j --[[@as number]],  7)    end
    local test_passed = true
    test_passed = test_passed and fat_id.unique_id == 12
    if not test_passed then print("unique_id", 12, fat_id.unique_id) end
    test_passed = test_passed and fat_id.race == 6
    if not test_passed then print("race", 6, fat_id.race) end
    test_passed = test_passed and fat_id.faith == -18
    if not test_passed then print("faith", -18, fat_id.faith) end
    test_passed = test_passed and fat_id.culture == -4
    if not test_passed then print("culture", -4, fat_id.culture) end
    test_passed = test_passed and fat_id.birth_year == 12
    if not test_passed then print("birth_year", 12, fat_id.birth_year) end
    test_passed = test_passed and fat_id.birth_tick == 15
    if not test_passed then print("birth_tick", 15, fat_id.birth_tick) end
    for j = 1, 10 do
        test_passed = test_passed and DATA.pop_get_traits(id, j --[[@as number]]) == 6
    end
    if not test_passed then print("traits", 6, DATA.pop[id].traits[0]) end
    for j = 1, 20 do
        test_passed = test_passed and DATA.pop_get_need_satisfaction_need(id, j) == 4
    end
    if not test_passed then print("need_satisfaction.need", 4, DATA.pop[id].need_satisfaction[0].need) end
    for j = 1, 20 do
        test_passed = test_passed and DATA.pop_get_need_satisfaction_use_case(id, j) == 10
    end
    if not test_passed then print("need_satisfaction.use_case", 10, DATA.pop[id].need_satisfaction[0].use_case) end
    for j = 1, 20 do
        test_passed = test_passed and DATA.pop_get_need_satisfaction_consumed(id, j) == 2
    end
    if not test_passed then print("need_satisfaction.consumed", 2, DATA.pop[id].need_satisfaction[0].consumed) end
    for j = 1, 20 do
        test_passed = test_passed and DATA.pop_get_need_satisfaction_demanded(id, j) == 17
    end
    if not test_passed then print("need_satisfaction.demanded", 17, DATA.pop[id].need_satisfaction[0].demanded) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.pop_get_inventory(id, j --[[@as trade_good_id]]) == -7
    end
    if not test_passed then print("inventory", -7, DATA.pop[id].inventory[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.pop_get_price_belief_sell(id, j --[[@as trade_good_id]]) == 12
    end
    if not test_passed then print("price_belief_sell", 12, DATA.pop[id].price_belief_sell[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.pop_get_price_belief_buy(id, j --[[@as trade_good_id]]) == -12
    end
    if not test_passed then print("price_belief_buy", -12, DATA.pop[id].price_belief_buy[0]) end
    test_passed = test_passed and fat_id.savings == -2
    if not test_passed then print("savings", -2, fat_id.savings) end
    test_passed = test_passed and fat_id.expected_wage == -12
    if not test_passed then print("expected_wage", -12, fat_id.expected_wage) end
    test_passed = test_passed and fat_id.life_needs_satisfaction == -14
    if not test_passed then print("life_needs_satisfaction", -14, fat_id.life_needs_satisfaction) end
    test_passed = test_passed and fat_id.basic_needs_satisfaction == 19
    if not test_passed then print("basic_needs_satisfaction", 19, fat_id.basic_needs_satisfaction) end
    test_passed = test_passed and fat_id.pending_economy_income == -4
    if not test_passed then print("pending_economy_income", -4, fat_id.pending_economy_income) end
    test_passed = test_passed and fat_id.forage_ratio == 14
    if not test_passed then print("forage_ratio", 14, fat_id.forage_ratio) end
    test_passed = test_passed and fat_id.work_ratio == 18
    if not test_passed then print("work_ratio", 18, fat_id.work_ratio) end
    test_passed = test_passed and fat_id.spend_savings_ratio == -11
    if not test_passed then print("spend_savings_ratio", -11, fat_id.spend_savings_ratio) end
    test_passed = test_passed and fat_id.female == false
    if not test_passed then print("female", false, fat_id.female) end
    test_passed = test_passed and fat_id.busy == true
    if not test_passed then print("busy", true, fat_id.busy) end
    test_passed = test_passed and fat_id.former_pop == true
    if not test_passed then print("former_pop", true, fat_id.former_pop) end
    test_passed = test_passed and fat_id.dead == false
    if not test_passed then print("dead", false, fat_id.dead) end
    test_passed = test_passed and fat_id.free_will == false
    if not test_passed then print("free_will", false, fat_id.free_will) end
    test_passed = test_passed and fat_id.is_player == true
    if not test_passed then print("is_player", true, fat_id.is_player) end
    test_passed = test_passed and fat_id.rank == 2
    if not test_passed then print("rank", 2, fat_id.rank) end
    for j = 1, 20 do
        test_passed = test_passed and DATA.pop_get_dna(id, j --[[@as number]]) == 7
    end
    if not test_passed then print("dna", 7, DATA.pop[id].dna[0]) end
    print("SET_GET_TEST_0_pop:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_province()
    local fat_id = DATA.fatten_province(id)
    fat_id.r = 4
    fat_id.g = 6
    fat_id.b = -18
    fat_id.is_land = false
    fat_id.province_id = 12
    fat_id.size = 11
    fat_id.movement_cost = 5
    fat_id.center = -1
    for j = 1, 100 do
        DATA.province_set_local_production(id, j --[[@as trade_good_id]],  10)    end
    for j = 1, 100 do
        DATA.province_set_temp_buffer_0(id, j --[[@as trade_good_id]],  2)    end
    for j = 1, 100 do
        DATA.province_set_local_consumption(id, j --[[@as trade_good_id]],  17)    end
    for j = 1, 100 do
        DATA.province_set_local_demand(id, j --[[@as trade_good_id]],  -7)    end
    for j = 1, 100 do
        DATA.province_set_local_satisfaction(id, j --[[@as trade_good_id]],  12)    end
    for j = 1, 100 do
        DATA.province_set_temp_buffer_use_0(id, j --[[@as use_case_id]],  -12)    end
    for j = 1, 100 do
        DATA.province_set_temp_buffer_use_grad(id, j --[[@as use_case_id]],  -2)    end
    for j = 1, 100 do
        DATA.province_set_local_use_satisfaction(id, j --[[@as use_case_id]],  -12)    end
    for j = 1, 100 do
        DATA.province_set_local_use_buffer_demand(id, j --[[@as use_case_id]],  -14)    end
    for j = 1, 100 do
        DATA.province_set_local_use_buffer_supply(id, j --[[@as use_case_id]],  19)    end
    for j = 1, 100 do
        DATA.province_set_local_use_buffer_cost(id, j --[[@as use_case_id]],  -4)    end
    for j = 1, 100 do
        DATA.province_set_local_storage(id, j --[[@as trade_good_id]],  14)    end
    for j = 1, 100 do
        DATA.province_set_local_merchants_demand(id, j --[[@as trade_good_id]],  18)    end
    for j = 1, 100 do
        DATA.province_set_local_prices(id, j --[[@as trade_good_id]],  -11)    end
    fat_id.local_wealth = -1
    fat_id.trade_wealth = -14
    fat_id.local_income = -16
    fat_id.local_building_upkeep = 1
    for j = 1, 25 do
        DATA.province_set_local_resources_resource(id, j, 10)
    end
    for j = 1, 25 do
        DATA.province_set_local_resources_location(id, j, 15)
    end
    for j = 1, 300 do
        DATA.province_set_total_resources(id, j --[[@as resource_id]],  3)    end
    for j = 1, 300 do
        DATA.province_set_used_resources(id, j --[[@as resource_id]],  11)    end
    fat_id.mood = 7
    for j = 1, 5 do
        DATA.province_set_unit_types(id, j --[[@as unit_type_id]],  10)    end
    fat_id.on_a_river = true
    fat_id.on_a_forest = false
    local test_passed = true
    test_passed = test_passed and fat_id.r == 4
    if not test_passed then print("r", 4, fat_id.r) end
    test_passed = test_passed and fat_id.g == 6
    if not test_passed then print("g", 6, fat_id.g) end
    test_passed = test_passed and fat_id.b == -18
    if not test_passed then print("b", -18, fat_id.b) end
    test_passed = test_passed and fat_id.is_land == false
    if not test_passed then print("is_land", false, fat_id.is_land) end
    test_passed = test_passed and fat_id.province_id == 12
    if not test_passed then print("province_id", 12, fat_id.province_id) end
    test_passed = test_passed and fat_id.size == 11
    if not test_passed then print("size", 11, fat_id.size) end
    test_passed = test_passed and fat_id.movement_cost == 5
    if not test_passed then print("movement_cost", 5, fat_id.movement_cost) end
    test_passed = test_passed and fat_id.center == -1
    if not test_passed then print("center", -1, fat_id.center) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_production(id, j --[[@as trade_good_id]]) == 10
    end
    if not test_passed then print("local_production", 10, DATA.province[id].local_production[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_temp_buffer_0(id, j --[[@as trade_good_id]]) == 2
    end
    if not test_passed then print("temp_buffer_0", 2, DATA.province[id].temp_buffer_0[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_consumption(id, j --[[@as trade_good_id]]) == 17
    end
    if not test_passed then print("local_consumption", 17, DATA.province[id].local_consumption[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_demand(id, j --[[@as trade_good_id]]) == -7
    end
    if not test_passed then print("local_demand", -7, DATA.province[id].local_demand[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_satisfaction(id, j --[[@as trade_good_id]]) == 12
    end
    if not test_passed then print("local_satisfaction", 12, DATA.province[id].local_satisfaction[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_temp_buffer_use_0(id, j --[[@as use_case_id]]) == -12
    end
    if not test_passed then print("temp_buffer_use_0", -12, DATA.province[id].temp_buffer_use_0[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_temp_buffer_use_grad(id, j --[[@as use_case_id]]) == -2
    end
    if not test_passed then print("temp_buffer_use_grad", -2, DATA.province[id].temp_buffer_use_grad[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_use_satisfaction(id, j --[[@as use_case_id]]) == -12
    end
    if not test_passed then print("local_use_satisfaction", -12, DATA.province[id].local_use_satisfaction[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_use_buffer_demand(id, j --[[@as use_case_id]]) == -14
    end
    if not test_passed then print("local_use_buffer_demand", -14, DATA.province[id].local_use_buffer_demand[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_use_buffer_supply(id, j --[[@as use_case_id]]) == 19
    end
    if not test_passed then print("local_use_buffer_supply", 19, DATA.province[id].local_use_buffer_supply[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_use_buffer_cost(id, j --[[@as use_case_id]]) == -4
    end
    if not test_passed then print("local_use_buffer_cost", -4, DATA.province[id].local_use_buffer_cost[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_storage(id, j --[[@as trade_good_id]]) == 14
    end
    if not test_passed then print("local_storage", 14, DATA.province[id].local_storage[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_merchants_demand(id, j --[[@as trade_good_id]]) == 18
    end
    if not test_passed then print("local_merchants_demand", 18, DATA.province[id].local_merchants_demand[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.province_get_local_prices(id, j --[[@as trade_good_id]]) == -11
    end
    if not test_passed then print("local_prices", -11, DATA.province[id].local_prices[0]) end
    test_passed = test_passed and fat_id.local_wealth == -1
    if not test_passed then print("local_wealth", -1, fat_id.local_wealth) end
    test_passed = test_passed and fat_id.trade_wealth == -14
    if not test_passed then print("trade_wealth", -14, fat_id.trade_wealth) end
    test_passed = test_passed and fat_id.local_income == -16
    if not test_passed then print("local_income", -16, fat_id.local_income) end
    test_passed = test_passed and fat_id.local_building_upkeep == 1
    if not test_passed then print("local_building_upkeep", 1, fat_id.local_building_upkeep) end
    for j = 1, 25 do
        test_passed = test_passed and DATA.province_get_local_resources_resource(id, j) == 10
    end
    if not test_passed then print("local_resources.resource", 10, DATA.province[id].local_resources[0].resource) end
    for j = 1, 25 do
        test_passed = test_passed and DATA.province_get_local_resources_location(id, j) == 15
    end
    if not test_passed then print("local_resources.location", 15, DATA.province[id].local_resources[0].location) end
    for j = 1, 300 do
        test_passed = test_passed and DATA.province_get_total_resources(id, j --[[@as resource_id]]) == 3
    end
    if not test_passed then print("total_resources", 3, DATA.province[id].total_resources[0]) end
    for j = 1, 300 do
        test_passed = test_passed and DATA.province_get_used_resources(id, j --[[@as resource_id]]) == 11
    end
    if not test_passed then print("used_resources", 11, DATA.province[id].used_resources[0]) end
    test_passed = test_passed and fat_id.mood == 7
    if not test_passed then print("mood", 7, fat_id.mood) end
    for j = 1, 5 do
        test_passed = test_passed and DATA.province_get_unit_types(id, j --[[@as unit_type_id]]) == 10
    end
    if not test_passed then print("unit_types", 10, DATA.province[id].unit_types[0]) end
    test_passed = test_passed and fat_id.on_a_river == true
    if not test_passed then print("on_a_river", true, fat_id.on_a_river) end
    test_passed = test_passed and fat_id.on_a_forest == false
    if not test_passed then print("on_a_forest", false, fat_id.on_a_forest) end
    print("SET_GET_TEST_0_province:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm()
    local fat_id = DATA.fatten_realm(id)
    fat_id.budget_change = 4
    fat_id.budget_saved_change = 6
    for j = 1, 38 do
        DATA.realm_set_budget_spending_by_category(id, j --[[@as ECONOMY_REASON]],  -18)    end
    for j = 1, 38 do
        DATA.realm_set_budget_income_by_category(id, j --[[@as ECONOMY_REASON]],  -4)    end
    for j = 1, 38 do
        DATA.realm_set_budget_treasury_change_by_category(id, j --[[@as ECONOMY_REASON]],  12)    end
    fat_id.budget_treasury = 11
    fat_id.budget_treasury_target = 5
    for j = 1, 7 do
        DATA.realm_set_budget_ratio(id, j, -1)
    end
    for j = 1, 7 do
        DATA.realm_set_budget_budget(id, j, 10)
    end
    for j = 1, 7 do
        DATA.realm_set_budget_to_be_invested(id, j, 2)
    end
    for j = 1, 7 do
        DATA.realm_set_budget_target(id, j, 17)
    end
    fat_id.budget_tax_target = -7
    fat_id.budget_tax_collected_this_year = 12
    fat_id.r = -12
    fat_id.g = -2
    fat_id.b = -12
    fat_id.primary_race = -14
    fat_id.primary_culture = 19
    fat_id.primary_faith = -4
    fat_id.capitol = 14
    fat_id.trading_right_cost = 18
    fat_id.building_right_cost = -11
    fat_id.law_trade = 2
    fat_id.law_building = 0
    fat_id.prepare_attack_flag = true
    fat_id.coa_base_r = 1
    fat_id.coa_base_g = 10
    fat_id.coa_base_b = 15
    fat_id.coa_background_r = -14
    fat_id.coa_background_g = 2
    fat_id.coa_background_b = 7
    fat_id.coa_foreground_r = 0
    fat_id.coa_foreground_g = 19
    fat_id.coa_foreground_b = 20
    fat_id.coa_emblem_r = -7
    fat_id.coa_emblem_g = 15
    fat_id.coa_emblem_b = 10
    fat_id.coa_background_image = 14
    fat_id.coa_foreground_image = 16
    fat_id.coa_emblem_image = 8
    for j = 1, 100 do
        DATA.realm_set_resources(id, j --[[@as trade_good_id]],  -17)    end
    for j = 1, 100 do
        DATA.realm_set_production(id, j --[[@as trade_good_id]],  15)    end
    for j = 1, 100 do
        DATA.realm_set_bought(id, j --[[@as trade_good_id]],  -20)    end
    for j = 1, 100 do
        DATA.realm_set_sold(id, j --[[@as trade_good_id]],  -15)    end
    fat_id.expected_food_consumption = 5
    local test_passed = true
    test_passed = test_passed and fat_id.budget_change == 4
    if not test_passed then print("budget_change", 4, fat_id.budget_change) end
    test_passed = test_passed and fat_id.budget_saved_change == 6
    if not test_passed then print("budget_saved_change", 6, fat_id.budget_saved_change) end
    for j = 1, 38 do
        test_passed = test_passed and DATA.realm_get_budget_spending_by_category(id, j --[[@as ECONOMY_REASON]]) == -18
    end
    if not test_passed then print("budget_spending_by_category", -18, DATA.realm[id].budget_spending_by_category[0]) end
    for j = 1, 38 do
        test_passed = test_passed and DATA.realm_get_budget_income_by_category(id, j --[[@as ECONOMY_REASON]]) == -4
    end
    if not test_passed then print("budget_income_by_category", -4, DATA.realm[id].budget_income_by_category[0]) end
    for j = 1, 38 do
        test_passed = test_passed and DATA.realm_get_budget_treasury_change_by_category(id, j --[[@as ECONOMY_REASON]]) == 12
    end
    if not test_passed then print("budget_treasury_change_by_category", 12, DATA.realm[id].budget_treasury_change_by_category[0]) end
    test_passed = test_passed and fat_id.budget_treasury == 11
    if not test_passed then print("budget_treasury", 11, fat_id.budget_treasury) end
    test_passed = test_passed and fat_id.budget_treasury_target == 5
    if not test_passed then print("budget_treasury_target", 5, fat_id.budget_treasury_target) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.realm_get_budget_ratio(id, j) == -1
    end
    if not test_passed then print("budget.ratio", -1, DATA.realm[id].budget[0].ratio) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.realm_get_budget_budget(id, j) == 10
    end
    if not test_passed then print("budget.budget", 10, DATA.realm[id].budget[0].budget) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.realm_get_budget_to_be_invested(id, j) == 2
    end
    if not test_passed then print("budget.to_be_invested", 2, DATA.realm[id].budget[0].to_be_invested) end
    for j = 1, 7 do
        test_passed = test_passed and DATA.realm_get_budget_target(id, j) == 17
    end
    if not test_passed then print("budget.target", 17, DATA.realm[id].budget[0].target) end
    test_passed = test_passed and fat_id.budget_tax_target == -7
    if not test_passed then print("budget_tax_target", -7, fat_id.budget_tax_target) end
    test_passed = test_passed and fat_id.budget_tax_collected_this_year == 12
    if not test_passed then print("budget_tax_collected_this_year", 12, fat_id.budget_tax_collected_this_year) end
    test_passed = test_passed and fat_id.r == -12
    if not test_passed then print("r", -12, fat_id.r) end
    test_passed = test_passed and fat_id.g == -2
    if not test_passed then print("g", -2, fat_id.g) end
    test_passed = test_passed and fat_id.b == -12
    if not test_passed then print("b", -12, fat_id.b) end
    test_passed = test_passed and fat_id.primary_race == -14
    if not test_passed then print("primary_race", -14, fat_id.primary_race) end
    test_passed = test_passed and fat_id.primary_culture == 19
    if not test_passed then print("primary_culture", 19, fat_id.primary_culture) end
    test_passed = test_passed and fat_id.primary_faith == -4
    if not test_passed then print("primary_faith", -4, fat_id.primary_faith) end
    test_passed = test_passed and fat_id.capitol == 14
    if not test_passed then print("capitol", 14, fat_id.capitol) end
    test_passed = test_passed and fat_id.trading_right_cost == 18
    if not test_passed then print("trading_right_cost", 18, fat_id.trading_right_cost) end
    test_passed = test_passed and fat_id.building_right_cost == -11
    if not test_passed then print("building_right_cost", -11, fat_id.building_right_cost) end
    test_passed = test_passed and fat_id.law_trade == 2
    if not test_passed then print("law_trade", 2, fat_id.law_trade) end
    test_passed = test_passed and fat_id.law_building == 0
    if not test_passed then print("law_building", 0, fat_id.law_building) end
    test_passed = test_passed and fat_id.prepare_attack_flag == true
    if not test_passed then print("prepare_attack_flag", true, fat_id.prepare_attack_flag) end
    test_passed = test_passed and fat_id.coa_base_r == 1
    if not test_passed then print("coa_base_r", 1, fat_id.coa_base_r) end
    test_passed = test_passed and fat_id.coa_base_g == 10
    if not test_passed then print("coa_base_g", 10, fat_id.coa_base_g) end
    test_passed = test_passed and fat_id.coa_base_b == 15
    if not test_passed then print("coa_base_b", 15, fat_id.coa_base_b) end
    test_passed = test_passed and fat_id.coa_background_r == -14
    if not test_passed then print("coa_background_r", -14, fat_id.coa_background_r) end
    test_passed = test_passed and fat_id.coa_background_g == 2
    if not test_passed then print("coa_background_g", 2, fat_id.coa_background_g) end
    test_passed = test_passed and fat_id.coa_background_b == 7
    if not test_passed then print("coa_background_b", 7, fat_id.coa_background_b) end
    test_passed = test_passed and fat_id.coa_foreground_r == 0
    if not test_passed then print("coa_foreground_r", 0, fat_id.coa_foreground_r) end
    test_passed = test_passed and fat_id.coa_foreground_g == 19
    if not test_passed then print("coa_foreground_g", 19, fat_id.coa_foreground_g) end
    test_passed = test_passed and fat_id.coa_foreground_b == 20
    if not test_passed then print("coa_foreground_b", 20, fat_id.coa_foreground_b) end
    test_passed = test_passed and fat_id.coa_emblem_r == -7
    if not test_passed then print("coa_emblem_r", -7, fat_id.coa_emblem_r) end
    test_passed = test_passed and fat_id.coa_emblem_g == 15
    if not test_passed then print("coa_emblem_g", 15, fat_id.coa_emblem_g) end
    test_passed = test_passed and fat_id.coa_emblem_b == 10
    if not test_passed then print("coa_emblem_b", 10, fat_id.coa_emblem_b) end
    test_passed = test_passed and fat_id.coa_background_image == 14
    if not test_passed then print("coa_background_image", 14, fat_id.coa_background_image) end
    test_passed = test_passed and fat_id.coa_foreground_image == 16
    if not test_passed then print("coa_foreground_image", 16, fat_id.coa_foreground_image) end
    test_passed = test_passed and fat_id.coa_emblem_image == 8
    if not test_passed then print("coa_emblem_image", 8, fat_id.coa_emblem_image) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.realm_get_resources(id, j --[[@as trade_good_id]]) == -17
    end
    if not test_passed then print("resources", -17, DATA.realm[id].resources[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.realm_get_production(id, j --[[@as trade_good_id]]) == 15
    end
    if not test_passed then print("production", 15, DATA.realm[id].production[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.realm_get_bought(id, j --[[@as trade_good_id]]) == -20
    end
    if not test_passed then print("bought", -20, DATA.realm[id].bought[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.realm_get_sold(id, j --[[@as trade_good_id]]) == -15
    end
    if not test_passed then print("sold", -15, DATA.realm[id].sold[0]) end
    test_passed = test_passed and fat_id.expected_food_consumption == 5
    if not test_passed then print("expected_food_consumption", 5, fat_id.expected_food_consumption) end
    print("SET_GET_TEST_0_realm:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_building()
    local fat_id = DATA.fatten_building(id)
    fat_id.current_type = 4
    fat_id.work_ratio = 6
    fat_id.input_scale = -18
    fat_id.production_scale = -4
    fat_id.output_scale = 12
    for j = 1, 8 do
        DATA.building_set_amount_of_inputs_use(id, j, 11)
    end
    for j = 1, 8 do
        DATA.building_set_amount_of_inputs_amount(id, j, 5)
    end
    for j = 1, 8 do
        DATA.building_set_amount_of_outputs_good(id, j, -1)
    end
    for j = 1, 8 do
        DATA.building_set_amount_of_outputs_amount(id, j, 10)
    end
    local test_passed = true
    test_passed = test_passed and fat_id.current_type == 4
    if not test_passed then print("current_type", 4, fat_id.current_type) end
    test_passed = test_passed and fat_id.work_ratio == 6
    if not test_passed then print("work_ratio", 6, fat_id.work_ratio) end
    test_passed = test_passed and fat_id.input_scale == -18
    if not test_passed then print("input_scale", -18, fat_id.input_scale) end
    test_passed = test_passed and fat_id.production_scale == -4
    if not test_passed then print("production_scale", -4, fat_id.production_scale) end
    test_passed = test_passed and fat_id.output_scale == 12
    if not test_passed then print("output_scale", 12, fat_id.output_scale) end
    for j = 1, 8 do
        test_passed = test_passed and DATA.building_get_amount_of_inputs_use(id, j) == 11
    end
    if not test_passed then print("amount_of_inputs.use", 11, DATA.building[id].amount_of_inputs[0].use) end
    for j = 1, 8 do
        test_passed = test_passed and DATA.building_get_amount_of_inputs_amount(id, j) == 5
    end
    if not test_passed then print("amount_of_inputs.amount", 5, DATA.building[id].amount_of_inputs[0].amount) end
    for j = 1, 8 do
        test_passed = test_passed and DATA.building_get_amount_of_outputs_good(id, j) == -1
    end
    if not test_passed then print("amount_of_outputs.good", -1, DATA.building[id].amount_of_outputs[0].good) end
    for j = 1, 8 do
        test_passed = test_passed and DATA.building_get_amount_of_outputs_amount(id, j) == 10
    end
    if not test_passed then print("amount_of_outputs.amount", 10, DATA.building[id].amount_of_outputs[0].amount) end
    print("SET_GET_TEST_0_building:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_estate()
    local fat_id = DATA.fatten_estate(id)
    fat_id.morale = 4
    fat_id.current_status = 6
    fat_id.idle_stance = 0
    fat_id.current_time_used_ratio = -4
    for j = 1, 5 do
        DATA.estate_set_units_current(id, j --[[@as unit_type_id]],  12)    end
    for j = 1, 5 do
        DATA.estate_set_units_target(id, j --[[@as unit_type_id]],  11)    end
    fat_id.savings = 5
    fat_id.balance_last_tick = -1
    fat_id.total_upkeep = 10
    fat_id.predicted_upkeep = 2
    fat_id.supplies = 17
    fat_id.supplies_target_days = -7
    for j = 1, 100 do
        DATA.estate_set_inventory(id, j --[[@as trade_good_id]],  12)    end
    for j = 1, 100 do
        DATA.estate_set_inventory_sold_last_tick(id, j --[[@as trade_good_id]],  -12)    end
    for j = 1, 100 do
        DATA.estate_set_inventory_bought_last_tick(id, j --[[@as trade_good_id]],  -2)    end
    for j = 1, 100 do
        DATA.estate_set_inventory_demanded_last_tick(id, j --[[@as trade_good_id]],  -12)    end
    for j = 1, 400 do
        DATA.estate_set_technologies_present(id, j --[[@as technology_id]],  3)    end
    for j = 1, 400 do
        DATA.estate_set_technologies_researchable(id, j --[[@as technology_id]],  19)    end
    for j = 1, 250 do
        DATA.estate_set_technologies_throughput_boosts(id, j --[[@as production_method_id]],  -4)    end
    for j = 1, 250 do
        DATA.estate_set_technologies_output_boosts(id, j --[[@as production_method_id]],  14)    end
    for j = 1, 250 do
        DATA.estate_set_technologies_input_boosts(id, j --[[@as production_method_id]],  18)    end
    for j = 1, 250 do
        DATA.estate_set_buildable_buildings(id, j --[[@as building_type_id]],  4)    end
    local test_passed = true
    test_passed = test_passed and fat_id.morale == 4
    if not test_passed then print("morale", 4, fat_id.morale) end
    test_passed = test_passed and fat_id.current_status == 6
    if not test_passed then print("current_status", 6, fat_id.current_status) end
    test_passed = test_passed and fat_id.idle_stance == 0
    if not test_passed then print("idle_stance", 0, fat_id.idle_stance) end
    test_passed = test_passed and fat_id.current_time_used_ratio == -4
    if not test_passed then print("current_time_used_ratio", -4, fat_id.current_time_used_ratio) end
    for j = 1, 5 do
        test_passed = test_passed and DATA.estate_get_units_current(id, j --[[@as unit_type_id]]) == 12
    end
    if not test_passed then print("units_current", 12, DATA.estate[id].units_current[0]) end
    for j = 1, 5 do
        test_passed = test_passed and DATA.estate_get_units_target(id, j --[[@as unit_type_id]]) == 11
    end
    if not test_passed then print("units_target", 11, DATA.estate[id].units_target[0]) end
    test_passed = test_passed and fat_id.savings == 5
    if not test_passed then print("savings", 5, fat_id.savings) end
    test_passed = test_passed and fat_id.balance_last_tick == -1
    if not test_passed then print("balance_last_tick", -1, fat_id.balance_last_tick) end
    test_passed = test_passed and fat_id.total_upkeep == 10
    if not test_passed then print("total_upkeep", 10, fat_id.total_upkeep) end
    test_passed = test_passed and fat_id.predicted_upkeep == 2
    if not test_passed then print("predicted_upkeep", 2, fat_id.predicted_upkeep) end
    test_passed = test_passed and fat_id.supplies == 17
    if not test_passed then print("supplies", 17, fat_id.supplies) end
    test_passed = test_passed and fat_id.supplies_target_days == -7
    if not test_passed then print("supplies_target_days", -7, fat_id.supplies_target_days) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.estate_get_inventory(id, j --[[@as trade_good_id]]) == 12
    end
    if not test_passed then print("inventory", 12, DATA.estate[id].inventory[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.estate_get_inventory_sold_last_tick(id, j --[[@as trade_good_id]]) == -12
    end
    if not test_passed then print("inventory_sold_last_tick", -12, DATA.estate[id].inventory_sold_last_tick[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.estate_get_inventory_bought_last_tick(id, j --[[@as trade_good_id]]) == -2
    end
    if not test_passed then print("inventory_bought_last_tick", -2, DATA.estate[id].inventory_bought_last_tick[0]) end
    for j = 1, 100 do
        test_passed = test_passed and DATA.estate_get_inventory_demanded_last_tick(id, j --[[@as trade_good_id]]) == -12
    end
    if not test_passed then print("inventory_demanded_last_tick", -12, DATA.estate[id].inventory_demanded_last_tick[0]) end
    for j = 1, 400 do
        test_passed = test_passed and DATA.estate_get_technologies_present(id, j --[[@as technology_id]]) == 3
    end
    if not test_passed then print("technologies_present", 3, DATA.estate[id].technologies_present[0]) end
    for j = 1, 400 do
        test_passed = test_passed and DATA.estate_get_technologies_researchable(id, j --[[@as technology_id]]) == 19
    end
    if not test_passed then print("technologies_researchable", 19, DATA.estate[id].technologies_researchable[0]) end
    for j = 1, 250 do
        test_passed = test_passed and DATA.estate_get_technologies_throughput_boosts(id, j --[[@as production_method_id]]) == -4
    end
    if not test_passed then print("technologies_throughput_boosts", -4, DATA.estate[id].technologies_throughput_boosts[0]) end
    for j = 1, 250 do
        test_passed = test_passed and DATA.estate_get_technologies_output_boosts(id, j --[[@as production_method_id]]) == 14
    end
    if not test_passed then print("technologies_output_boosts", 14, DATA.estate[id].technologies_output_boosts[0]) end
    for j = 1, 250 do
        test_passed = test_passed and DATA.estate_get_technologies_input_boosts(id, j --[[@as production_method_id]]) == 18
    end
    if not test_passed then print("technologies_input_boosts", 18, DATA.estate[id].technologies_input_boosts[0]) end
    for j = 1, 250 do
        test_passed = test_passed and DATA.estate_get_buildable_buildings(id, j --[[@as building_type_id]]) == 4
    end
    if not test_passed then print("buildable_buildings", 4, DATA.estate[id].buildable_buildings[0]) end
    print("SET_GET_TEST_0_estate:")
    if test_passed then print("PASSED") else print("ERROR") end
end
return DATA
