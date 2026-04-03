-- TODO: this file needs to be split up into smaller, more managable files.
-- Perhaps have a file per "tab"?

local re = {}
local ui = require "engine.ui"
local uit = require "game.ui-utils"
local tabb = require "engine.table"

local ef = require "game.raws.effects.economy"
local btb = require "game.scenes.game.widgets.building-type-buttons"

local dbm = require "game.economy.diet-breadth-model"

local tile_utils = require "game.entities.tile"
local province_utils = require "game.entities.province".Province
local warband_utils = require "game.entities.warband"
local building_type_tooltip = require "game.raws.building-types".get_tooltip
local economy_effects = require "game.raws.effects.economy"
local military_effects = require "game.raws.effects.military"

re.cached_scrollbar = 0
---@alias TileCharacterTab "LOCAL" | "HOME" | "CHAR" | "GUEST"
---@type TileCharacterTab
re.cached_character_tab = "LOCAL"
re.character_local_state = nil
re.character_guest_state = nil
re.character_home_state = nil

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	local panel = fs:subrect(uit.BASE_HEIGHT * 2, 0, uit.BASE_HEIGHT * 16, uit.BASE_HEIGHT * 25, "left", "down")
	return panel
end

---Returns whether or not clicks on the planet can be registered.
---@return boolean
function re.mask(gam)
	if ui.trigger(get_main_panel()) then
		return false
	else
		return true
	end
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function header_panel(gam, tile_id, panel)
	local base_unit = uit.BASE_HEIGHT

	local province_name_rect = panel:subrect(0, 0, panel.width / 2, base_unit, "left", "up")
	local province_id = tile_utils.province(tile_id)
	local province = DATA.fatten_province(province_id)

	uit.data_entry(
		"",
		province.name,
		province_name_rect
	)

	local infra_panel = panel:subrect(0, base_unit, base_unit * 3, base_unit, "left", "up")
	uit.generic_number_field(
		"horizon-road.png",
		province_utils.get_infrastructure_efficiency(tile_id),
		infra_panel,
		"Local infrastructure efficiency",
		uit.NUMBER_MODE.PERCENTAGE,
		uit.NAME_MODE.ICON
	)

	local mood_panel = infra_panel
	mood_panel.y = mood_panel.y + mood_panel.height
	uit.generic_number_field(
		"duality-mask.png",
		province.mood,
		infra_panel,
		"Local mood",
		uit.NUMBER_MODE.BALANCE,
		uit.NAME_MODE.ICON
	)

	local population_panel = mood_panel
	population_panel.y = population_panel.y - population_panel.height
	population_panel.x = population_panel.x + population_panel.width
	uit.generic_number_field(
		"minions.png",
		province_utils.local_population(province_id),
		population_panel,
		"Local population",
		uit.NUMBER_MODE.INTEGER,
		uit.NAME_MODE.ICON
	)

	local unemployed_panel = population_panel
	unemployed_panel.y = unemployed_panel.y + unemployed_panel.height
	uit.generic_number_field(
		"shrug.png",
		province_utils.get_unemployment(province_id),
		population_panel,
		"Local unemployed population",
		uit.NUMBER_MODE.INTEGER,
		uit.NAME_MODE.ICON
	)
	local character_panel = unemployed_panel
	character_panel.y = character_panel.y - character_panel.height
	character_panel.x = character_panel.x + character_panel.width

	local characters_count = province_utils.local_characters(province_id)

	uit.generic_number_field(
		"inner-self.png",
		characters_count,
		population_panel,
		"Local character count",
		uit.NUMBER_MODE.INTEGER,
		uit.NAME_MODE.ICON
	)

	local warrior_panel = character_panel
	warrior_panel.y = warrior_panel.y + warrior_panel.height
	uit.generic_number_field(
		"barbute.png",
		tabb.accumulate(
			DATA.filter_estate_location_from_tile(tile_id, function (item)
				return true
			end),
			0,
			function (a, k, v)
				local estate = DATA.estate_location_get_estate(v)
				return a + warband_utils.war_size(estate)
			end
		),
		population_panel,
		"Local warrior count",
		uit.NUMBER_MODE.INTEGER,
		uit.NAME_MODE.ICON
	)
end

local INVESTMENT_AMOUNT = 1

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function infrastructure_widget(gam, tile_id, panel)
	if ui.is_key_held("lshift") or ui.is_key_held("rshift") then
		INVESTMENT_AMOUNT = 5
	elseif ui.is_key_held("lctrl") or ui.is_key_held("rctrl") then
		INVESTMENT_AMOUNT = 50
	else
		INVESTMENT_AMOUNT = 1
	end

	panel:shrink(3)
	ui.panel(panel, 3)
	panel:shrink(3)

	local base_unit = uit.BASE_HEIGHT
	local realm_id = tile_utils.realm(tile_id)
	local province_id = tile_utils.province(tile_id)

	if realm_id == INVALID_ID then
		return
	end

	local province = DATA.fatten_province(province_id)
	local realm = DATA.fatten_realm(realm_id)

	---comment
	---@return fun(rect: Rect)
	local function invest_button()
		return function(rect)
			local potential = realm.budget_treasury > INVESTMENT_AMOUNT
			local tooltip =
				"Invest "
				.. tostring(INVESTMENT_AMOUNT)
				.. MONEY_SYMBOL
				.. ". Press Ctrl or Shift to modify invested amount."

			if uit.money_button(
					"Invest",
					INVESTMENT_AMOUNT,
					rect,
					tooltip,
					potential
				) then
				ef.direct_investment_infrastructure(realm_id, province_id, INVESTMENT_AMOUNT)
			end
		end
	end

	uit.rows(
		{
			function(rect)
				uit.money_entry(
					"Inf.: ",
					DATA.tile_get_infrastructure(tile_id),
					rect,
					"Local infrastructure"
				)
			end,
			function(rect)
				uit.money_entry(
					"Inf. inv: ",
					DATA.tile_get_infrastructure_investment(tile_id),
					rect,
					"Infrastructure investment"
				)
			end,
			function(rect)
				uit.money_entry(
					"Req inf.: ",
					DATA.tile_get_infrastructure_needed(tile_id),
					rect,
					"Required infrastructure"
				)
			end,
			function(rect)
				local sat = 0
				if DATA.tile_get_infrastructure_needed(tile_id) > 0 then
					sat = DATA.tile_get_infrastructure(tile_id) / DATA.tile_get_infrastructure_needed(tile_id)
				end
				uit.data_entry_percentage(
					"Inf. sat: ",
					sat,
					rect,
					"Infrastructure satisfaction"
				)
			end,

			function(rect)
				if WORLD:does_player_control_realm(realm_id) then
					invest_button()(rect)
				end
			end,
		},
		panel,
		base_unit
	)
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function demography_widget(gam, tile_id, panel)
	panel:shrink(3)
	ui.panel(panel, 3)
	panel:shrink(3)

	local base_unit = uit.BASE_HEIGHT
	local realm = tile_utils.realm(tile_id)
	local province = tile_utils.province(tile_id)

	require "game.scenes.game.widgets.demography" ({ province }, panel, true)()
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function realm_widget(gam, tile_id, panel)
	panel:shrink(3)
	ui.panel(panel, 3)
	panel:shrink(3)

	panel:shrink(5)

	local base_unit = uit.BASE_HEIGHT
	local realm = tile_utils.realm(tile_id)
	local province = tile_utils.province(tile_id)
	local player = WORLD.player_character

	if realm == nil then
		return
	end

	local base_unit = uit.BASE_HEIGHT

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(0)
		:vertical()
		:build()

	local buttons_grid_panel = layout:next(panel.width, base_unit * 3)

	local buttons_grid = ui.layout_builder()
		:position(buttons_grid_panel.x, buttons_grid_panel.y)
		:grid(2)
		:spacing(5)
		:build()

	if uit.icon_button(
			ASSETS.icons["frog-prince.png"],
			buttons_grid:next(UI_STYLE.square_button_large, UI_STYLE.square_button_large),
			"Take control over character from this country",
			player == INVALID_ID
		) then
		-- gam.refresh_map_mode()
		gam.inspector = "characters"
		gam.selected.province = tile_utils.province(tile_id)
	end
end

local function main_panel(gam, tile, panel)
	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(0)
		:horizontal()
		:build()

	infrastructure_widget(gam, tile, layout:next(uit.BASE_HEIGHT * 7, panel.height))
	demography_widget(gam, tile, layout:next(uit.BASE_HEIGHT * 4, panel.height))
	realm_widget(gam, tile, layout:next(uit.BASE_HEIGHT * 5, panel.height))
end

local function military_widget(gam, tile_id, panel)
	panel:shrink(3)
	ui.panel(panel, 3)
	panel:shrink(3)

	panel:shrink(5)

	local unit = uit.BASE_HEIGHT
	local province_id = tile_utils.province(tile_id)

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(0)
		:grid(3)
		:build()

	local visibility = WORLD:base_visibility(1)
	uit.data_entry_percentage(
		"Spot (1): ",
		province_utils.spot_chance(province_id, visibility),
		layout:next(unit * 5, unit * 1),
		"Chance to spot an army of 1 human raider."
	)
	local visibility = WORLD:base_visibility(10)
	uit.data_entry_percentage(
		"Spot (10): ",
		province_utils.spot_chance(province_id, visibility),
		layout:next(unit * 5, unit * 1),
		"Chance to spot an army of 10 human raiders."
	)
	local visibility = WORLD:base_visibility(50)
	uit.data_entry_percentage(
		"Spot (50): ",
		province_utils.spot_chance(province_id, visibility),
		layout:next(unit * 5, unit * 1),
		"Chance to spot an army of 50 human raiders."
	)
	uit.count_entry(
		"Hiding: ",
		province_utils.get_hiding(province_id),
		layout:next(unit * 5, unit * 1),
		"The weighted amount of land that can be hidden in. Expressed as an equivalent number of grassland tiles."
	)
	uit.count_entry(
		"Mov. cost: ",
		DATA.province_get_movement_cost(province_id),
		layout:next(unit * 5, unit * 1),
		"Movement cost, in hours"
	)
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function trade_widget(gam, tile_id, panel)
	panel:shrink(3)
	ui.panel(panel, 3)
	panel:shrink(3)

	panel:shrink(5)

	local unit = uit.BASE_HEIGHT

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(5)
		:grid(4)
		:build()

	local province_id = TILE_PROVINCE(tile_id)
	local province = DATA.fatten_province(province_id)

	uit.generic_number_field(
		"fruit-bowl.png",
		DATA.tile_get_foragers_limit(tile_id),
		layout:next(unit * 3.5, unit * 1),
		"The carrying capacity of this province is determined by the amount of energy foragable. The total calories avialable in this province can support about "
			.. uit.to_fixed_point2(DATA.tile_get_foragers_limit(tile_id)) .." adult humans from foraging this tile.",
		uit.NUMBER_MODE.BALANCE,
		uit.NAME_MODE.ICON
	)

	local pop_weight = province_utils.population_weight(province_id)
	uit.generic_number_field(
		"ages.png",
		pop_weight,
		layout:next(unit * 3.5, unit * 1),
		"This province is currently carrying the equivalent of " .. uit.to_fixed_point2(pop_weight)
			.. " adult humans.",
		uit.NUMBER_MODE.NUMBER,
		uit.NAME_MODE.ICON
	)

	local province_size = DATA.province_get_size(province_id)

	for _, i in pairs(FORAGE_RESOURCE) do
		if i ~= INVALID_ID then
			local resource = DATA.tile_get_foragers_targets_resource(tile_id, i)
			local amount = DATA.tile_get_foragers_targets_amount(tile_id, i)
			local limit = DATA.tile_get_foragers_targets_limit(tile_id, i)
			local efficiency = dbm.foraging_efficiency(limit,amount)
			local name = DATA.forage_resource_get_name(resource)
			local difference = math.max(0, limit - amount)
			local tooltip = limit > 0 and "A total of " .. uit.to_fixed_point2(difference) .. " " .. name
					.. " went unharvested last month from a total of " .. uit.to_fixed_point2(limit)
					.. " units being harvested by the equivalent of " .. uit.to_fixed_point2(amount)
					.. " adult human foragers"
					.. "\n - The average adult human can expect to collect from " .. name
					.. " at " .. uit.to_fixed_point2(efficiency*100) .. "% efficiency."
				or "There are no forageable " .. name .. " in this tile."
			uit.generic_number_field(
				DATA.forage_resource_get_icon(resource),
				difference,
				layout:next(unit * 3.5, unit * 1),
				tooltip,
				uit.NUMBER_MODE.BALANCE,
				uit.NAME_MODE.ICON
			)
		end

	end

	---@type string
	-- local resource_string = ""
	-- local resource_tooltip = "There is no special resource on this tile."
	-- local resource_icon = "uncertainty.png"
	-- local has_resource = false
	-- for i = 1, MAX_RESOURCES_IN_PROVINCE_INDEX - 1 do
	-- 	local resource = DATA.province_get_local_resources_resource(province_id, i)
	-- 	if resource == INVALID_ID then
	-- 		break
	-- 	end
	-- 	local name = DATA.resource_get_name(resource)
	-- 	has_resource = true

	-- 	---@type string
	-- 	resource_string = resource_string .. name .. ", "
	-- end

	-- if has_resource then
	-- 	-- resource_string = resource_string:sub(1, -3)
	-- 	resource_tooltip = "This tile has sources of " .. resource_string .. "."
	-- else
	-- 	resource_string = "n/a"
	-- end

	-- uit.generic_string_field(
	-- 	"Res.",
	-- 	resource_string,
	-- 	layout:next(unit * 3.5 * 4 + 15, unit * 1),
	-- 	resource_tooltip,
	-- 	uit.NAME_MODE.NAME
	-- )
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function separate_inspectors(gam, tile_id, panel)
	local layout = ui.layout_builder()
		:position(panel.x + 5, panel.y)
		:spacing(5)
		:horizontal()
		:build()

	if uit.icon_button(
			ASSETS.icons["scales.png"],
			layout:next(UI_STYLE.square_button_large, UI_STYLE.square_button_large),
			"Show market"
		) then
		gam.inspector = "market"
	end

	if uit.icon_button(
			ASSETS.icons["minions.png"],
			layout:next(UI_STYLE.square_button_large, UI_STYLE.square_button_large),
			"Show population"
		) then
		gam.inspector = "population"
	end

	if uit.icon_button(
		ASSETS.icons["guards.png"],
		layout:next(UI_STYLE.square_button_large, UI_STYLE.square_button_large),
		"Show local warriors"
	) then
		gam.inspector = "army"
	end
end

local function bottom_panel(gam, tile_id, panel)
	local unit = uit.BASE_HEIGHT

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(0)
		:vertical()
		:build()

	separate_inspectors(gam, tile_id, layout:next(panel.width, unit * 2))
	military_widget(gam, tile_id, layout:next(panel.width, unit * 3))
	trade_widget(gam, tile_id, layout:next(panel.width, unit * 6))
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function general_tab(gam, tile_id, panel)
	local unit = uit.BASE_HEIGHT

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(0)
		:vertical()
		:build()

	header_panel(gam, tile_id, layout:next(panel.width, unit * 4))
	main_panel(gam, tile_id, layout:next(panel.width, unit * 8))
	bottom_panel(gam, tile_id, layout:next(panel.width, unit * 12))
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function geography_tab(gam, tile_id, panel)
	local lat, lon = tile_utils.latlon(tile_id)
	local jan_r, jan_t, jul_r, jul_t = tile_utils.get_climate_data(tile_id)
	local tile = DATA.fatten_tile(tile_id)
	local province = tile_utils.province(tile_id)
	uit.columns(
		{
			function(rect)
				uit.rows({
					function(rect)
						uit.data_entry("Elevation:", tostring(math.floor(tile.elevation)), rect)
					end,
					function(rect)
						uit.data_entry("Latitude: ", tostring(math.floor(lat * 100) / 100), rect,
							"In radians")
					end,
					function(rect)
						uit.data_entry("Longitude: ", tostring(math.floor(lon * 100) / 100), rect,
							"In radians")
					end,
					function(rect)
						uit.data_entry("Size: ", tostring(DATA.province_get_size(province)), rect, "In tiles")
					end,
					function(rect)
						uit.data_entry("Bedrock:", DATA.bedrock_get_name(tile.bedrock), rect)
					end,
					function(rect)
						ui.centered_text("Soil texture", rect)
					end,
					function(rect)
						uit.graph({
							{
								weight = tile.sand,
								tooltip = "Sand (" .. math.floor(tile.sand * 100) .. "%)",
								r = 1,
								g = 0,
								b = 0,
							},
							{
								weight = tile.clay,
								tooltip = "Clay (" .. math.floor(tile.clay * 100) .. "%)",
								r = 0,
								g = 0,
								b = 1,
							},
							{
								weight = tile.silt,
								tooltip = "Silt (" .. math.floor(tile.silt * 100) .. "%)",
								r = 0,
								g = 1,
								b = 0,
							},
						}, rect)
					end,
					function(rect)
						uit.data_entry("Soil depth:", tostring(math.floor(tile_utils.soil_depth(tile_id) * 100) / 100), rect,
							"In meters")
					end,
					function(rect)
						uit.data_entry("Soil perm.:", tostring(math.floor(tile_utils.soil_permeability(tile_id) * 100) / 100), rect,
							"Soil permeability, abstract unit")
					end,
					function(rect)
						uit.data_entry("Soil minerals:", tostring(math.floor(tile.soil_minerals * 100) / 100), rect,
							"Fraction")
					end,
					function(rect)
						uit.data_entry("Soil organics:", tostring(math.floor(tile.soil_organics * 100) / 100), rect,
							"Fraction")
					end,
				}, rect)
			end,
			function(rect)
				uit.rows(
					{
						function(rect)
							ui.centered_text("Local plants", rect)
						end,
						function(rect)
							uit.graph({
								{
									weight = 1 - tile.grass - tile.shrub - tile.conifer - tile.broadleaf,
									tooltip = "Bare ground (" ..
										math.floor((1 - tile.grass - tile.shrub - tile.conifer - tile.broadleaf) * 100) ..
										"%)",
									r = 0.2,
									g = 0.1,
									b = 0.1
								},
								{
									weight = tile.grass,
									tooltip = "Grass (" .. math.floor(tile.grass * 100) .. "%)",
									r = 0,
									g = 1,
									b = 0
								},
								{
									weight = tile.shrub,
									tooltip = "Shrub (" .. math.floor(tile.shrub * 100) .. "%)",
									r = 1,
									g = 0,
									b = 0
								},
								{
									weight = tile.conifer,
									tooltip = "Conifer (" .. math.floor(tile.conifer * 100) .. "%)",
									r = 0,
									g = 1,
									b = 1
								},
								{
									weight = tile.broadleaf,
									tooltip = "Broadleaf (" .. math.floor(tile.broadleaf * 100) .. "%)",
									r = 0,
									g = 0,
									b = 1
								},
							}, rect)
						end,
						function(rect)
							uit.data_entry("", DATA.biome_get_name(tile.biome), rect, "Biome")
						end,
						function(rect)
							uit.count_entry(
								"LCC:",
								require "game.ecology.carrying-capacity".get_tile_carrying_capacity(tile_id),
								rect,
								"Local carrying capacity expressed in adult humans per tile."
							)
						end,

						function(rect)
							uit.data_entry("Jan. temp:", tostring(math.floor(jan_t)), rect, "January temperature")
						end,
						function(rect)
							uit.data_entry("Jan. rain:", tostring(math.floor(jan_r)), rect, "January rainfall")
						end,
						function(rect)
							uit.data_entry("Jan. flow:", tostring(math.floor(tile.january_waterflow)), rect,
								"January waterflow")
						end,
						function(rect)
							uit.data_entry("Ice:", tostring(math.floor(tile.ice)), rect, "Ice")
						end,
						function(rect)
							local kopp = require "game.climate.koppen"
							local k = kopp.get_koppen(jan_t, jul_t, jan_r, jul_r, DATA.tile_get_is_land(tile_id))
							uit.data_entry("Koppen:", k, rect, "Koppen climate classification")
						end,
						function(rect)
							uit.data_entry("Jul. temp:", tostring(math.floor(jul_t)), rect, "July temperature")
						end,
						function(rect)
							uit.data_entry("Jul. rain:", tostring(math.floor(jul_r)), rect, "July rainfall")
						end,
						function(rect)
							uit.data_entry("Jul. flow:", tostring(math.floor(tile.july_waterflow)), rect,
								"July waterflow")
						end,
						function(rect)
							uit.data_entry("Ice (ice age):", tostring(math.floor(tile.ice_age_ice)), rect,
								"Ice cover during the last glacial maximum")
						end,
					},
					rect
				)
			end
		},
		panel,
		panel.width / 2.1
	)
end

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function buildings_construction_tab(gam, tile_id, panel)
	local base_unit = uit.BASE_HEIGHT

	local rr = panel.height
	panel.height = base_unit
	ui.centered_text("Construction", panel)
	panel.height = rr - base_unit
	panel.y = panel.y + base_unit
	re.building_construction_scrollbar = re.building_construction_scrollbar or 0

	local province_id = tile_utils.province(tile_id)

	---@type building_type_id[]
	local building_types = {}
	local amount = 0

	DATA.for_each_building_type(function (item)
		DATA.for_each_estate_location_from_tile(tile_id,function (estate_location)
			local estate = DATA.estate_location_get_estate(estate_location)
			if not building_types[item] and DATA.estate_get_buildable_buildings(estate, item) == 1 then
				table.insert(building_types, item)
				amount = amount + 1
			end
		end)
	end)

	re.building_construction_scrollbar = uit.scrollview(
		panel,
		function(number, rect)
			if number > 0 then
				btb.building_type_buttons(
					gam,
					rect,
					building_types[number],
					tile_id
				)
			end
		end,
		UI_STYLE.scrollable_list_item_height,
		amount,
		UI_STYLE.slider_width,
		re.building_construction_scrollbar
	)
end


---comment
---@param gam GameScene
---@param tile_id tile_id
---@param rect Rect
local function buildings_view_tab(gam, tile_id, rect)
	local base_unit = uit.BASE_HEIGHT

	if re.building_stacks == nil then
		re.building_stacks = true
	end

	local province_id = tile_utils.province(tile_id)

	local rr = rect.height
	local rw = rect.width
	rect.height = base_unit
	ui.centered_text("Buildings", rect)
	rect.width = base_unit
	if re.building_stacks then
		if uit.icon_button(ASSETS.icons["cubes.png"], rect, "Show individual buildings") then
			re.building_stacks = not re.building_stacks
		end
	else
		if uit.icon_button(ASSETS.icons["cubeforce.png"], rect, "Show building types") then
			re.building_stacks = not re.building_stacks
		end
	end
	rect.width = rw

	rect.height = rr - base_unit
	rect.y = rect.y + base_unit

	if re.building_stacks then
		-- Show buildings as stacks
		---@type table<building_type_id, number>
		local stacks = {}
		local size = 0
		DATA.for_each_tile_province_membership_from_province(province_id, function (membership)
			local tile = DATA.tile_province_membership_get_tile(membership)
			DATA.for_each_estate_location_from_tile(tile, function (item)
				local estate = DATA.estate_location_get_estate(item)
				DATA.for_each_building_estate_from_estate(estate, function (building_estate)
					local building = DATA.building_estate_get_building(building_estate)
					local building_type = DATA.building_get_current_type(building)
					if stacks[building_type] == nil then
						stacks[building_type] = 1
						size = size + 1
					else
						stacks[building_type] = stacks[building_type] + 1
					end
				end)
			end)
		end)

		re.buildings_scrollbar = re.buildings_scrollbar or 0
		re.buildings_scrollbar = uit.scrollview(rect,
			function(number, rect)
				if number > 0 then
					---@type BuildingType
					local building_type, amount = tabb.nth(stacks, number)
					ui.tooltip(building_type_tooltip(building_type), rect)
					---@type Rect
					local r = rect
					local im = r:subrect(0, 0, base_unit, base_unit, "left", "up")
					ui.image(ASSETS.icons[DATA.building_type_get_icon(building_type)], im)
					rect.x = rect.x + base_unit
					rect.width = rect.width - base_unit

					uit.integer_entry(DATA.building_type_get_name(building_type), amount or 1, rect)
				end
			end,
			UI_STYLE.scrollable_list_item_height,
			size,
			UI_STYLE.slider_width,
			re.buildings_scrollbar
		)
	else
		-- Show individual buildings
		re.buildings_scrollbar = re.buildings_scrollbar or 0
		local amount = 0
		local estates = DATA.filter_estate_location(
			function (item)
				local location = DATA.estate_location_get_tile(item)
				if TILE_PROVINCE(location) == province_id then
					amount = amount + 1
					return true
				end
				return false
			end)

		re.buildings_scrollbar = uit.scrollview(rect, function(number, rect)
			if number > 0 and number <= amount then
				local estate = DATA.estate_location_get_estate(tabb.nth(estates, number))
				local owner = OWNER(estate)
				if owner == INVALID_ID then
					if uit.text_button("Public estate", rect) then
						gam.inspector = "building"
						gam.selected.estate = estate
						gam.selected.building = INVALID_ID
					end
				else
					if uit.text_button("Estates of " .. NAME(owner), rect) then
						gam.inspector = "building"
						gam.selected.estate = estate
						gam.selected.building = INVALID_ID
					end
				end
			end
		end, UI_STYLE.scrollable_list_item_height, amount, UI_STYLE.slider_width,
		re.buildings_scrollbar)
	end
end

local building_tab = "Construction"

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function buildings_tab(gam, tile_id, panel)
	local unit = uit.BASE_HEIGHT

	local tab_content = panel:subrect(0, unit, panel.width, panel.height - unit, "left", "up")

	building_tab = building_tab or "Construction"

	local tabs = {
		{
			text = "Construction",
			tooltip = "Construction",
			closure = function()
				buildings_construction_tab(gam, tile_id, tab_content)
			end
		},
		{
			text = "Buildings",
			tooltip = "Buildings",
			closure = function()
				buildings_view_tab(gam, tile_id, tab_content)
			end
		}
	}

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(2)
		:horizontal()
		:build()

	building_tab = uit.tabs(building_tab, layout, tabs, 1, unit * 5)
end

local function technology_tab(gam, tile_id, panel)
	local base_unit = uit.BASE_HEIGHT
	local province = TILE_PROVINCE(tile_id)

	---@type technology_id[]
	local technologies = {}
	local total = 0

	---@type technology_id[]
	local technologies_potential = {}
	local total_potential = 0

	DATA.for_each_technology(function (item)
		DATA.for_each_estate_location_from_tile(tile_id, function (location)
			local estate = DATA.estate_location_get_estate(location)
			if DATA.estate_get_technologies_present(estate, item) == 1 then
				table.insert(technologies, item)
				total = total + 1
			end
			if DATA.estate_get_technologies_researchable(estate, item) == 1 then
				table.insert(technologies_potential, item)
				total_potential = total_potential + 1
			end
		end)
	end)

	uit.rows(
		{
			---commenting
			---@param rect Rect
			function(rect)
				uit.rows({
					function(rect)
						ui.centered_text("Researched technologies", rect)
					end,
					function(_)
						rect.y = rect.y + UI_STYLE.table_header_height
						rect.height = rect.height - UI_STYLE.table_header_height
						re.researched_technologies_scrollbar = re.researched_technologies_scrollbar or 0
						re.researched_technologies_scrollbar = uit.scrollview(rect, function(number, rect)
								if number > 0 then
									---@type Technology
									local tech = technologies[number]
									require "game.scenes.game.widgets.technology" (tech, rect, gam)
								end
							end,
							UI_STYLE.scrollable_list_item_height,
							total,
							UI_STYLE.slider_width,
							re.researched_technologies_scrollbar
						)
					end
				}, rect, base_unit)
			end,
			---commenting
			---@param rect Rect
			function(rect)
				uit.rows({
					function(rect)
						ui.centered_text("Researchable technologies", rect)
					end,
					function(_)
						rect.y = rect.y + base_unit
						rect.height = rect.height - base_unit
						re.researchable_technologies_scrollbar = re.researchable_technologies_scrollbar or 0
						re.researchable_technologies_scrollbar = uit.scrollview(rect, function(number, rect)
								if number > 0 then
									local tech = technologies_potential[number]
									require "game.scenes.game.widgets.technology" (tech, rect, gam)
								end
							end,
							UI_STYLE.scrollable_list_item_height,
							total_potential,
							UI_STYLE.slider_width,
							re.researchable_technologies_scrollbar)
					end
				}, rect, base_unit)
			end
		},
		panel,
		panel.height / 2 - 5
	)
end

local decision_tab = "Province"

---comment
---@param gam GameScene
---@param tile_id tile_id
---@param panel Rect
local function decisions_tab(gam, tile_id, panel)
	local unit = uit.BASE_HEIGHT

	local tab_content = panel:subrect(0, unit, panel.width, panel.height - unit * 2, "left", "up")

	decision_tab = decision_tab or "Province"

	local tabs = {
		{
			text = "Tile",
			tooltip = "Tile decisions",

			on_select = function()
				gam.reset_decision_selection()
			end,
			closure = function()
				require "game.scenes.game.widgets.decision-tab" (
					tab_content,
					tile_id,
					"tile",
					gam
				)
			end
		},
		{
			text = "Province",
			tooltip = "Provincial decisions.",
			on_select = function()
				gam.reset_decision_selection()
			end,
			closure = function()
				require "game.scenes.game.widgets.decision-tab" (
					tab_content,
					tile_utils.province(tile_id),
					"province",
					gam
				)
			end
		}
	}

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(2)
		:horizontal()
		:build()

	decision_tab = uit.tabs(decision_tab, layout, tabs, 1, unit * 5)
end

---@param gam GameScene
function re.draw(gam)
	local unit = uit.BASE_HEIGHT

	local tile_id = gam.clicked_tile_id

	if tile_id == INVALID_ID then
		return
	end

	local panel = get_main_panel()
	ui.panel(panel)

	if tile_utils.realm(tile_id) then
		local header = panel:subrect(0, 0, panel.width, unit, "left", "up")
		header.width = header.width / 2
		-- COA
		require "game.scenes.game.widgets.realm-name" (
			gam,
			tile_utils.realm(tile_id),
			header,
			"immediate"
		)
	end

	if uit.icon_button(ASSETS.icons["cancel.png"], panel:subrect(0, 0, unit * 1, unit * 1, "right", "up")) then
		gam.click_tile(0)
		gam.inspector = nil
	end

	panel.y = panel.y + unit
	panel.height = panel.height - unit

	local tab_content = panel:subrect(0, unit, panel.width, panel.height - unit, "left", "up")

	gam.tile_inspector_tab = gam.tile_inspector_tab or "GEN"

	local province = tile_utils.province(tile_id)

	local tabs = {
		{
			text = "GEN",
			icon = ASSETS.icons["horizon-road.png"],
			tooltip = "General",
			closure = function()
				general_tab(gam, tile_id, tab_content)
			end
		},
		{
			text = "BLD",
			icon = ASSETS.icons["village.png"],
			tooltip = "Buildings",
			closure = function()
				buildings_tab(gam, tile_id, tab_content)
			end
		},
		{
			text = "TEC",
			icon = ASSETS.icons["bookmarklet.png"],
			tooltip = "Technology",
			closure = function()
				technology_tab(gam, tile_id, tab_content)
			end
		},
		{
			text = "CHR",
			icon = ASSETS.icons["inner-self.png"],
			tooltip = "List of notable characters",
			closure = function()
				local tab_layout = ui.layout_builder()
					:position(tab_content.x, tab_content.y)
					:spacing(2)
					:horizontal()
					:build()
				tab_content.y = tab_content.y + unit * 1.2
				tab_content.height = tab_content.height - unit * 1.2
				re.cached_character_tab = uit.tabs(re.cached_character_tab, tab_layout, {
					{
						text = "LOCAL",
						tooltip = "All pop currently in " .. PROVINCE_NAME(province),
						closure = function()
							re.cached_character_local_state = require "game.scenes.game.widgets.character-list" (
								gam,
								tab_content,
								tabb.map_array(
									DATA.filter_estate_unit(
										function (item)
											return province == ESTATE_PROVINCE(DATA.estate_unit_get_estate(item))
										end
									),
									DATA.estate_unit_get_pop
								),
								re.cached_character_local_state
							)()
						end
					},
					{
						text = "HOME",
						tooltip = "All pop that consider " .. PROVINCE_NAME(province) .. " home.",
						closure = function()
							re.cached_pop_home_state = require "game.scenes.game.widgets.character-list" (
								gam,
								tab_content,
								tabb.map_array(
									DATA.filter_home(
										function (item)
											return province == ESTATE_PROVINCE(DATA.home_get_estate(item))
										end
									),
									DATA.home_get_pop
								),
								re.cached_pop_home_state
							)()
						end
					},
					{
						text = "CHAR",
						tooltip = "Notable characters present in " .. PROVINCE_NAME(province) .. ".",
						closure = function()
							re.cached_pop_char_state = require "game.scenes.game.widgets.character-list" (
								gam,
								tab_content,
								tabb.map_array(
									DATA.filter_character_location(
										function (item)
											return province == ESTATE_PROVINCE(DATA.character_location_get_estate(item))
										end
									),
									DATA.character_location_get_character
								),
								re.cached_pop_char_state
							)()
						end
					},
					{
						text = "GUEST",
						tooltip = "Foreign pops present in " .. PROVINCE_NAME(province) .. ".",
						closure = function()
							re.cached_pop_guest_state = require "game.scenes.game.widgets.character-list" (
								gam,
								tab_content,
								tabb.map_array(
									DATA.filter_estate_unit(
										function (item)
											local pop = DATA.estate_unit_get_pop(item)
											return province ~= ESTATE_PROVINCE(HOME(pop))
												and province == POP_PROVINCE(pop)
										end
									),
									DATA.estate_unit_get_pop
								),
								re.cached_pop_guest_state
							)()
						end
					}
				}, 1, uit.BASE_HEIGHT*3)
			end
		},
		{
			text = "DCS",
			icon = ASSETS.icons["envelope.png"],
			tooltip = "Local decisions",
			on_select = function()
				gam.reset_decision_selection()
			end,
			closure = function()
				decisions_tab(gam, tile_id, tab_content)
			end,
			visible = WORLD.player_character ~= INVALID_ID
		},
		{
			text = "GEO",
			icon = ASSETS.icons["mountains.png"],
			tooltip = "Geography",
			closure = function()
				geography_tab(gam, tile_id, tab_content)
			end
		}
	}

	local layout = ui.layout_builder()
		:position(panel.x, panel.y)
		:spacing(2)
		:horizontal()
		:build()

	gam.tile_inspector_tab = uit.tabs(gam.tile_inspector_tab, layout, tabs, 1)
end

return re
