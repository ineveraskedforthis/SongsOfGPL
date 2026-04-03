local tabb = require "engine.table"
local ui = require "engine.ui";
local ut = require "game.ui-utils"
local province_utils = require "game.entities.province".Province
local pv = require "game.raws.values.politics"
local ev = require "game.raws.values.economy"

local economy_effects = require "game.raws.effects.economy"

---@class potential_construction_data
---@field id building_type_id
---@field cost number
---@field profit number
---@field can_build boolean

---@type TableState
local table_state = {
	header_height = UI_STYLE.table_header_height,
	individual_height = UI_STYLE.scrollable_list_small_item_height,
	slider_level = 0,
	slider_width = UI_STYLE.slider_width,
	sorted_field = 1,
	sorting_order = true
}
local function update_state()
	table_state.header_height = UI_STYLE.table_header_height
	table_state.individual_height = UI_STYLE.scrollable_list_small_item_height
	table_state.slider_width = UI_STYLE.slider_width
end

---@param k trade_good_id
local function render_good_icon(rect, k)
	local good = DATA.fatten_trade_good(k)
	ut.render_icon(rect:copy():shrink(-1), good.icon, 1, 1, 1, 1)
	ut.render_icon(rect, good.icon, good.r, good.g, good.b, 1)
end

---@param k use_case_id
local function render_use_case_icon(rect, k)
	local case = DATA.fatten_use_case(k)
	ut.render_icon(rect:copy():shrink(-1), case.icon, 1, 1, 1, 1)
	ut.render_icon(rect, case.icon, case.r, case.g, case.b, 1)
end

---@param rect Rect
---@param estate estate_id
return function (rect, estate)
	local base_unit = UI_STYLE.scrollable_list_item_height
	ui.panel(rect)
	---@type pop_id
	local character = WORLD.player_character
	if character == INVALID_ID then
		ui.text("Can't construct buildings as an observer", rect, "center", "center")
		return
	end

	---@type pop_id
	local owner = WORLD.player_character
	local location = ESTATE_TILE(owner)

	if estate ~= INVALID_ID then
		owner = OWNER(estate)
		location = POP_TILE(owner)
	end

	local realm = PROVINCE_REALM(TILE_PROVINCE(location))
	local overseer = pv.overseer(realm)

	local is_public_estate = false
	if owner == INVALID_ID then
		is_public_estate = true
	end
	local can_build = false
	if owner == character then
		can_build = true
	end
	if is_public_estate and LEADER(realm) == character then
		can_build = true
	end
	if is_public_estate and overseer == character then
		can_build = true
	end

	local funds = SAVINGS(character)
	if estate ~= INVALID_ID then
		funds = funds + DATA.estate_get_savings(estate)
	else
		estate = POP_ESTATE(character)
	end

	local actual_manager = character
	if is_public_estate then
		actual_manager = overseer
	end

	---@type potential_construction_data[]
	local table_data = {}

	DATA.for_each_building_type(function (item)
		local buildable = DATA.estate_get_buildable_buildings(estate, item) == 1
		if not buildable then
			return
		end

		---@type potential_construction_data
		local entry = {
			id = item,
			can_build = province_utils.can_build(location, funds, item, actual_manager, is_public_estate),
			cost = ev.building_cost(item, actual_manager, is_public_estate),
			profit = 0 -- ev.projected_income_building_type(estate, item, HUMAN, false)
		}

		table.insert(table_data, entry)
	end)

	---@type TableColumn<potential_construction_data>
	local name_column = {
		header = "name",
		width = base_unit * 8,
		render_closure = function (rect, k, v)
			ut.data_entry("", DATA.building_type_get_name(v.id), rect, nil, true, "left")
		end,
		value = function (k, v)
			return DATA.building_type_get_name(v.id)
		end
	}

	---@type TableColumn<potential_construction_data>
	local price_column = {
		header = "price",
		width = base_unit * 3,
		active = true,
		render_closure = function (rect, k, v)
			if ut.money_button("", v.cost, rect, nil, v.can_build and can_build) then
				economy_effects.construct_building_with_payment(v.id, estate, owner, actual_manager, is_public_estate)
			end
		end,
		value = function (k, v)
			return v.cost
		end
	}

	---@type TableColumn<potential_construction_data>
	local profit_column = {
		header = "profit",
		width = base_unit * 3,
		render_closure =  function (rect, k, v)
			ut.money_entry("", v.profit, rect)
		end,
		value = function (k, v)
			return v.profit
		end
	}

	---@type TableColumn<potential_construction_data>
	local inputs_column = {
		header = "inputs",
		width = base_unit * 4,
		render_closure =  function (rect, k, v)
			local method = DATA.building_type_get_production_method(v.id)
			local inputs = 0
			local tooltip = ""
			for i = 1, MAX_SIZE_ARRAYS_PRODUCTION_METHOD do
				local use = DATA.production_method_get_inputs_use(method, i)
				if use == INVALID_ID then
					break
				end
				inputs = inputs + 1
				local amount = DATA.production_method_get_inputs_amount(method, i)
				---@type string
				tooltip = tooltip .. DATA.use_case_get_description(use) .. " (" .. ut.to_fixed_point2(amount) .. "), "
			end

			local sub_rect = rect:copy()
			sub_rect.width = rect.width / inputs

			for i = 1, MAX_SIZE_ARRAYS_PRODUCTION_METHOD do
				local use = DATA.production_method_get_inputs_use(method, i)
				if use == INVALID_ID then
					break
				end
				render_use_case_icon(sub_rect, use)
				sub_rect.x = sub_rect.x + sub_rect.width
			end

			ui.tooltip(tooltip, rect)
		end,
		value = function (k, v)
			return v.profit
		end
	}

	---@type TableColumn<potential_construction_data>
	local outputs_column = {
		header = "outputs",
		width = base_unit * 4,
		render_closure =  function (rect, k, v)
			local method = DATA.building_type_get_production_method(v.id)
			local outputs = 0
			local tooltip = ""
			for i = 1, MAX_SIZE_ARRAYS_PRODUCTION_METHOD do
				local output = DATA.production_method_get_outputs_good(method, i)
				if output == INVALID_ID then
					break
				end
				outputs = outputs + 1
				local amount = DATA.production_method_get_outputs_amount(method, i)
				---@type string
				tooltip = tooltip .. DATA.trade_good_get_description(output) .. " (" .. ut.to_fixed_point2(amount) .. "), "
			end

			local sub_rect = rect:copy()
			sub_rect.width = rect.width / outputs

			for i = 1, MAX_SIZE_ARRAYS_PRODUCTION_METHOD do
				local output = DATA.production_method_get_outputs_good(method, i)
				if output == INVALID_ID then
					break
				end
				render_good_icon(sub_rect, output)
				sub_rect.x = sub_rect.x + sub_rect.width
			end

			ui.tooltip(tooltip, rect)
		end,
		value = function (k, v)
			return v.profit
		end
	}

	update_state()
	ut.table(rect, table_data, {name_column, price_column, profit_column, inputs_column, outputs_column}, table_state)
end
