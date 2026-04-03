local demography_values = require "game.raws.values.demography"
local demography_effects = require "game.raws.effects.demography"

local ut = require "game.ui-utils"
local ui = require "engine.ui"
local pui = require "game.scenes.game.widgets.pop-ui-widgets"
local portrait_widget = require "game.scenes.game.widgets.portrait"
local pop_utils = require "game.entities.pop".POP
local province_utils = require "game.entities.province".Province
local production_method_utils = require "game.raws.production-methods"
local dbm = require "game.economy.diet-breadth-model"

---comment
---@param pop POP
---@return string
local function pop_display_occupation(pop)
	local display_name = "unemployed"
	local occupation = DATA.employment_get_job(DATA.get_employment_from_worker(pop))
	local warband = UNIT_OF(pop)
	if occupation ~= INVALID_ID then
		display_name = DATA.job_get_name(occupation)
	elseif AGE_YEARS(pop) < F_RACE(pop).teen_age then
		display_name = "child"
	elseif warband ~= INVALID_ID then
		display_name = "warrior"
	end
	return display_name
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
---@param building building_id
return function (rect, building)
	local estate = BUILDING_ESTATE(building)
	local owner = OWNER(estate)
	local province = ESTATE_PROVINCE(estate)
	local realm = PROVINCE_REALM(province)
	local building_type = DATA.building_get_current_type(building)
	local method = DATA.building_type_get_production_method(building_type)

	---@type pop_id
	local worker = DATA.employment_get_worker(DATA.get_employment_from_building(building))
	local worker_income = DATA.employment_get_worker_income(DATA.get_employment_from_building(building))
	if worker == INVALID_ID then
		return
	end

	local worker_rect_height = ut.BASE_HEIGHT * 2

	local inputs_rect = rect:subrect(0, 0, rect.width / 2, rect.height - worker_rect_height, "left", "up")
	local outputs_rect = inputs_rect:copy()
	outputs_rect.x = outputs_rect.x + outputs_rect.width

	local rows = 5
	if rect.height > rows * ut.BASE_HEIGHT then
		rows = math.floor(rect.height / ut.BASE_HEIGHT)
	end

	local rect_item = inputs_rect:copy()
	rect_item.height = rect_item.height / rows
	rect_item.width = rect_item.width

	local current_row = 0

	local column_input = 0
	local column_output = 0
	--- display inputs, outputs and employed worker

	for i = 1, MAX_SIZE_ARRAYS_PRODUCTION_METHOD do
		local use = DATA.building_get_amount_of_inputs_use(building, i)
		if use == INVALID_ID then
			break
		end
		local current_amount = DATA.building_get_amount_of_inputs_amount(building, i)
		local base_amount = DATA.production_method_get_inputs_amount(method, i)

		rect_item.x = inputs_rect.x + column_input * rect_item.width
		rect_item.y = inputs_rect.y + current_row * rect_item.height

		ui.panel(rect_item, 2)

		local icon_rect = rect_item:copy()
		icon_rect.width = icon_rect.height
		render_use_case_icon(icon_rect, use)

		local description_rect = rect_item:copy()
		description_rect.x = description_rect.x + icon_rect.width
		description_rect.width = (description_rect.width - icon_rect.width) / 2

		ut.render_number_with_external_ratio(description_rect, current_amount, current_amount / base_amount)
		description_rect.x = description_rect.x + description_rect.width
		ui.left_text("|" .. ut.to_fixed_point2(base_amount), description_rect)
		ui.tooltip("base production", description_rect)
		current_row = current_row + 1
		if current_row >= rows then
			current_row = 0
			column_input = column_input + 1
		end
	end

	current_row = 0
	for i = 1, MAX_SIZE_ARRAYS_PRODUCTION_METHOD do
		local good = DATA.building_get_amount_of_outputs_good(building, i)

		if good == INVALID_ID then
			break
		end

		local current_amount = DATA.building_get_amount_of_outputs_amount(building, i)
		local base_amount = DATA.production_method_get_outputs_amount(method, i)

		rect_item.x = outputs_rect.x + column_output * rect_item.width
		rect_item.y = outputs_rect.y + current_row * rect_item.height

		ui.panel(rect_item, 2)

		local icon_rect = rect_item:copy()
		icon_rect.width = icon_rect.height
		render_good_icon(icon_rect, good)

		local description_rect = rect_item:copy()
		description_rect.x = description_rect.x + icon_rect.width
		description_rect.width = (description_rect.width - icon_rect.width) / 2

		ut.render_number_with_external_ratio(description_rect, current_amount, current_amount / base_amount)
		description_rect.x = description_rect.x + description_rect.width
		ui.left_text("|" .. ut.to_fixed_point2(base_amount), description_rect)
		ui.tooltip("base production", description_rect)
		current_row = current_row + 1
		if current_row >= rows then
			current_row = 0
			column_output = column_output + 1
		end
	end

	local worker_rect = rect:subrect(0, rect.height - worker_rect_height, rect.width, worker_rect_height, "left", "up")

	local description_rect = worker_rect:copy()
	local portrait_rect = worker_rect:copy()
	portrait_rect.width = worker_rect.height
	portrait_widget(portrait_rect, worker)

	description_rect.x = worker_rect.x + portrait_rect.height
	description_rect.height = description_rect.height / 2
	description_rect.width = description_rect.width - portrait_rect.width

	local name_rect = description_rect:copy()
	name_rect.width = name_rect.width / 2
	local f = "m"
	if DATA.pop_get_female(worker) then
		f = "f"
	end
	ui.centered_text(NAME(worker) .. "(" .. tostring(AGE_YEARS(worker)) .. f .. ")", name_rect)
	name_rect.x = name_rect.x + name_rect.width
	ui.centered_text(pop_display_occupation(worker), name_rect)

	description_rect.y = description_rect.y + description_rect.height
	description_rect.width = description_rect.width / 6

	pui.render_basic_needs_satsifaction(description_rect, worker)
	description_rect.x = description_rect.x + description_rect.width

	ut.money_entry(
		"",
		SAVINGS(worker),
		description_rect,
		"Savings of this character. "
		.. "Characters spend them on buying food and other commodities."
	)
	description_rect.x = description_rect.x + description_rect.width
	pui.render_work_time(description_rect, worker)
	description_rect.x = description_rect.x + description_rect.width
	pui.render_job_efficiency(description_rect, worker, DATA.production_method_get_job_type(method))
	description_rect.x = description_rect.x + description_rect.width
	pui.render_worker_income(description_rect, worker)
	description_rect.x = description_rect.x + description_rect.width

	local icon = ASSETS.icons["cancel.png"]
	local character = WORLD.player_character
	if ut.icon_button(icon,
		description_rect,
		"Unemploy this character!?",
		(owner ~= INVALID_ID and owner == character)
		or
		(owner == INVALID_ID and character == LEADER(realm))
	) then
		demography_effects.fire_pop(worker)
	end
end