local tabb = require "engine.table"
local strings = require "engine.string"

local ui = require "engine.ui"
local ut = require "game.ui-utils"

local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"

local pop_utils = require "game.entities.pop".POP
local warband_utils = require "game.entities.warband"

local rank_name = require "game.raws.ranks.localisation"

local pui = {}

---comment
---@param rect Rect
---@param pop_id pop_id
---@param alignment "left" | "right" | nil
function pui.render_age(rect, pop_id, alignment)
	local age_years = AGE_YEARS(pop_id)
	local age_months = AGE_MONTHS(pop_id) - age_years * 12
	local birth_year, birth_month, birth_day, birth_hour, birth_minute
		= BIRTHDATE(pop_id)
	local birth_minute_string = tostring(birth_minute)
	if string.len(birth_minute_string) < 2 then
		birth_minute_string = "0" .. birth_minute_string
	end

	ui.centered_text(
		tostring(age_years),
		rect)
	ui.tooltip(
		NAME(pop_id) .. " is " .. age_years .. " years and " .. age_months .. " months old. "
			.. strings.title(HESHE(pop_id)) .. " was born " .. birth_hour .. ":" .. birth_minute_string
			.. " " .. ut.months[birth_month+1] .. " " .. birth_day
			.. ", " .. birth_year,
		rect)
end

---comment
---@param rect Rect
---@param pop_id pop_id
function pui.render_female_icon(rect, pop_id)
	local centered_square = rect:centered_square()
	if FEMALE(pop_id) then
		ut.render_icon(centered_square,"female.png",1, 0, 1, 0.5, true)
		ui.tooltip(NAME(pop_id) .. " is female.",rect)
	else
		ut.render_icon(centered_square,"male.png",0, 1, 1, 0.5)
		ui.tooltip(NAME(pop_id) .. " is male.",rect)
	end
end

---@param rect Rect
---@param pop_id pop_id
---@param realm_id realm_id
function pui.render_realm_popularity(rect, pop_id, realm_id)
	if realm_id ~= INVALID_ID then
		local realm_popularity = require "game.raws.values.politics".popularity(pop_id, realm_id)
		ut.balance_entry_icon("duality-mask.png", realm_popularity, rect, NAME(pop_id) .. "'s popularity in " .. DATA.realm_get_name(realm_id) .. ".")
	else
		ut.generic_string_field("duality-mask.png","n/a",rect,"Unknown",ut.NAME_MODE.ICON,true,"left")
	end
end

---draw projected time spent foraging with target in tooltip
---@param rect Rect
---@param pop_id pop_id
function pui.render_forage_time(rect,pop_id)
	local pop_name = NAME(pop_id)
	local free_time, warband_time, forage_time, _ = POP_TIME(pop_id)
	local tooltip = pop_name .. " expects to be able to use " .. ut.to_fixed_point2(forage_time*100) .."% of it's time foraging. "
		.. strings.title(HESHE(pop_id)) .. " desires to spend " .. ut.to_fixed_point2(DATA.pop_get_forage_ratio(pop_id)*100) .. "% of it's time foraging"
	if free_time < 1 then
		tooltip = tooltip .. " but " .. ut.to_fixed_point2((1-free_time)*100) .. "% of its time is spent learning."
	elseif warband_time > 0 then
		tooltip = tooltip .. " but " .. ut.to_fixed_point2(warband_time*100)
			.. "% of its time is used by " .. ESTATE_NAME(UNIT_OF(pop_id)) .. "."
	else
		tooltip = tooltip .. "."
	end
	ut.generic_number_field("basket.png", forage_time, rect, tooltip, ut.NUMBER_MODE.PERCENTAGE, ut.NAME_MODE.ICON,true)
end

---draw projected time spent for party with tooltip of party status
---@param rect Rect
---@param pop_id pop_id
function pui.render_warband_time(rect,pop_id)
	local pop_name = NAME(pop_id)
	local party_id = UNIT_OF(pop_id)
	if party_id ~= INVALID_ID then
		local _, warband_time, _, _ = POP_TIME(pop_id)
		local status = DATA.warband_get_current_status(party_id)
		local tooltip = pop_name .. " has spent " .. ut.to_fixed_point2(warband_time*100)
			.. "% of " .. HISHER(pop_id) .. " time with " .. ESTATE_NAME(party_id) .. " this month. "
			.. strings.title(HESHE(pop_id)) ..  " is currently " .. DATA.warband_status_get_action_string(status)
			.. ", increasing this month's party time towards " .. ut.to_fixed_point2(DATA.warband_status_get_time_used(status)*100) .. "%."
		ut.generic_number_field("guards.png", warband_time, rect, tooltip, ut.NUMBER_MODE.PERCENTAGE, ut.NAME_MODE.ICON,true)
	else
		local tooltip = pop_name .. " is not part of a party."
		ut.generic_number_field("guards.png", 0, rect, tooltip, ut.NUMBER_MODE.PERCENTAGE, ut.NAME_MODE.ICON,true)
	end
end

---draw projected time spent working with target in tooltip
---@param rect Rect
---@param pop_id pop_id
function pui.render_work_time(rect,pop_id)
	local pop_name, hisher = NAME(pop_id), HISHER(pop_id)
	local _, _, _, work_time = POP_TIME(pop_id)
	local occupation = DATA.get_employment_from_worker(pop_id)
    local employer_id = DATA.employment_get_building(occupation)
	if employer_id then
		local tooltip = pop_name .. " expects to use " .. ut.to_fixed_point2(work_time*100) .. "% of " .. hisher .. " time working this month."
			.. "\n " .. strings.title(HESHE(pop_id)) .. " spent " .. ut.to_fixed_point2(DATA.pop_get_work_ratio(pop_id)*100) .. "% of "
			.. hisher .. " time working last month."
		ut.generic_number_field("miner.png", work_time, rect, tooltip, ut.NUMBER_MODE.PERCENTAGE, ut.NAME_MODE.ICON)
	else
		local tooltip = pop_name .. " is not employed!"
		ut.generic_number_field("miner.png", 0, rect, tooltip, ut.NUMBER_MODE.PERCENTAGE, ut.NAME_MODE.ICON)
	end
end

---@param pop_id pop_id
---@return string
function pui.occupation_name(pop_id)
	local age = AGE_YEARS(pop_id)
	local teen_age = DATA.race_get_teen_age(DATA.pop_get_race(pop_id))
	local occupation_id = DATA.get_employment_from_worker(pop_id)
    local employer = DATA.employment_get_building(occupation_id)
	local unit_type_id = UNIT_TYPE_OF(pop_id)
	if age < teen_age then
		return pop_utils.get_age_string(pop_id)
	elseif unit_type_id ~= INVALID_ID then
		return DATA.unit_type_get_name(unit_type_id)
	elseif employer ~= INVALID_ID then
		local job = DATA.employment_get_job(occupation_id)
		return DATA.job_get_name(job)
	elseif RANK(pop_id) > 1 then
		return rank_name(pop_id)
	else
		return "unemployed"
	end
end
---@param pop_id pop_id
---@return string
function pui.job_text(pop_id)
	local job_id = pop_utils.get_job_of(pop_id)
	if job_id ~= INVALID_ID then
		return DATA.job_get_name(job_id)
	end
	return "unemployed"
end
---@param rect Rect
---@param pop_id pop_id
---@param tooltip string?
function pui.render_job_icon(rect,pop_id,tooltip)
	local job_id = pop_utils.get_job_of(pop_id)
	if job_id ~= INVALID_ID then
		local job_name = DATA.job_get_name(job_id)
		ut.render_icon(rect,
			DATA.job_get_icon(job_id),
			DATA.job_get_r(job_id),
			DATA.job_get_g(job_id),
			DATA.job_get_b(job_id),
			1,
			true)
		if tooltip then
			ui.tooltip(tooltip,rect)
		end
	end
end
---@param rect Rect
---@param pop_id pop_id
---@param tooltip string?
function pui.render_job_text(rect,pop_id,tooltip)
	local job_id = pop_utils.get_job_of(pop_id)
	if job_id ~= INVALID_ID then
		local job_name = DATA.job_get_name(job_id)
		ui.text(strings.title(job_name),rect,"center","center")
		if tooltip then
			ui.tooltip(tooltip,rect)
		end
	end
end

---returns pop adjusted unit stats tooltip
---@param pop_id pop_id
---@return string
function pui.unit_tooltip(pop_id)
	local unit = UNIT_TYPE_OF(pop_id)
	if unit ~= INVALID_ID then
		return strings.title(DATA.unit_type_get_name(unit))
			.. "\n\t" .. DATA.unit_type_get_description(unit)
	else
		return strings.title(DATA.language_get_ranks(DATA.culture_get_language(CULTURE(pop_id)))[RANK(pop_id)])
			.. "\n\t" .. strings.title(HESHE(pop_id)) .. " is not in any party."
	end
end

---@param rect Rect
---@param pop_id pop_id
---@param tooltip string?
function pui.render_unit_icon(rect, pop_id, tooltip)
	local center_square = rect:centered_square()
	local party_id = UNIT_OF(pop_id)
	if party_id~=INVALID_ID then
		ut.render_icon(center_square, DATA.unit_type_get_icon(UNIT_TYPE_OF(pop_id)), .8, .8, .8, 1, true)
	else
		ut.render_icon(center_square,"inner-self.png", .8, .8, .8, 1, true)
	end
	if tooltip then
		ui.tooltip(tooltip, rect)
	end
end

---draws unit name with tooltip
---@param rect Rect
---@param pop_id pop_id
---@param horizontal_align love.AlignMode
---@param vertical_algin VerticalAlignMode
---@param tooltip string?
function pui.render_unit_text(rect, pop_id, horizontal_align, vertical_algin, tooltip)
	local unit_type_id = UNIT_TYPE_OF(pop_id)
	if unit_type_id ~= INVALID_ID then
		ui.text(
			strings.title(DATA.unit_type_get_name(unit_type_id)),
			rect,
			horizontal_align,
			vertical_algin)
	else
		ui.text(
			strings.title(DATA.language_get_ranks(DATA.culture_get_language(CULTURE(pop_id)))[RANK(pop_id)]),
			rect,
			horizontal_align,
			vertical_algin)
	end
	if tooltip then
		ui.tooltip(tooltip, rect)
	end
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_worker_income(rect, pop_id)
	local employer_id = pop_utils.get_employer_of(pop_id)
	if employer_id ~= INVALID_ID then
		local employment = DATA.get_employment_from_worker(pop_id)
		local wage = DATA.employment_get_worker_income(employment)
		ut.generic_number_field(
			"receive-money.png",
			wage,
			rect,
				NAME(pop_id) .. " made " .. MONEY_SYMBOL .. ut.to_fixed_point2(wage) .. " working.",
			ut.NUMBER_MODE.MONEY,
			ut.NAME_MODE.ICON,
			false,
			true)
	else
		ut.generic_string_field("uncertainty.png","n/a",rect,"None",ut.NAME_MODE.ICON,true,"right")
		ui.tooltip(NAME(pop_id) .. " is not a em,ployed!", rect)
	end
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_warband_income(rect, pop_id)
	if UNIT_OF(pop_id) ~= INVALID_ID then
		local unit_type_id = UNIT_TYPE_OF(pop_id)
		local wage, unit = 0, "noncombatant"
		if unit_type_id ~= INVALID_ID then
			wage = DATA.unit_type_get_base_cost(UNIT_TYPE_OF(pop_id))
			unit = strings.title(DATA.unit_type_get_name(unit_type_id))
		end
		ut.generic_number_field(
			"receive-money.png",
			wage,
			rect,
			"As a " .. unit .. ", " .. NAME(pop_id) .. " is payed "
				.. MONEY_SYMBOL .. ut.to_fixed_point2(wage) .. " monthly.",
			ut.NUMBER_MODE.MONEY,
			ut.NAME_MODE.ICON,
			false,
			true)
	else
		ut.generic_string_field("receive-money.png","n/a",rect,"Unknown",ut.NAME_MODE.ICON,true,"right")
		ui.tooltip(NAME(pop_id) .. " is not in a party!", rect)
	end
end

---@param pop_id pop_id
---@return string
function pui.occupation_tooltip(pop_id)
	local age = AGE_YEARS(pop_id)
	local teen_age = DATA.race_get_teen_age(DATA.pop_get_race(pop_id))
	local occupation = DATA.get_employment_from_worker(pop_id)
    local employer_id = DATA.employment_get_building(occupation)
	local party_id = UNIT_OF(pop_id)
	local unit_type_id = UNIT_TYPE_OF(pop_id)

	-- first spend party time, then attempt to forage, finally use remaining time to work
	local free_time,travel_time,forage_time,work_time  = POP_TIME(pop_id)

	-- all pops potentially forage
	local tooltip = "Foraging\t" .. ut.to_fixed_point2(forage_time*100)
		.."%\t(" .. ut.to_fixed_point2(DATA.pop_get_forage_ratio(pop_id)*100) .. "%)"

	-- all pops are part of an estate and can possibly have some time taken
	if party_id ~= INVALID_ID then
		local unit_name = DATA.unit_type_get_name(unit_type_id)
		local estate_status = DATA.estate_get_current_status(party_id)
		tooltip = ESTATE_NAME(party_id) .. " " .. strings.title(unit_name)
			.. "\t" .. ut.to_fixed_point2(travel_time*100) .. "% (" .. DATA.estate_status_get_name(estate_status) .. ")"
			.. "\n\t" .. tooltip
	end
	-- children and babies cant work and spend some time learning
	if age < teen_age then
		tooltip =  strings.title(pop_utils.get_age_string(pop_id))
			.. "\n\tLearning\t" .. ut.to_fixed_point2((1-free_time)*100) .. "%"
			.. "\t(" .. ut.to_fixed_point2(free_time*100) .. "%)"
			.. "\n\t" .. tooltip
	else -- check for employment
		if employer_id ~= INVALID_ID then
			local employer_name = DATA.building_type_get_name(DATA.building_get_current_type(employer_id))
			tooltip = tooltip .. "\n\t" .. strings.title(employer_name) .. "\t" .. ut.to_fixed_point2(work_time*100) .. "%"
		end
		-- choose most appropriate title 
		if unit_type_id ~= UNIT_TYPE.WARRIOR then
			local unit_name = DATA.unit_type_get_name(unit_type_id)
			tooltip = strings.title(unit_name) .. "\t(" .. ut.to_fixed_point2(free_time*100) .. "%)"
				.. "\n\t" .. tooltip
		elseif employer_id ~= INVALID_ID then
			local job_id = DATA.employment_get_job(occupation)
			tooltip = strings.title(DATA.job_get_name(job_id)) .. "\t(" .. ut.to_fixed_point2(free_time*100) .. "%)"
				.. "\n\t" .. tooltip
		else
			tooltip = "Unemployed\t(" .. ut.to_fixed_point2(free_time*100) .. "%)"
				.. "\n\t" .. tooltip
		end
	end
	return tooltip
end

---draws occupation icon with tooltip
---@param rect Rect
---@param pop_id pop_id
---@param tooltip string?
function pui.render_occupation_icon(rect, pop_id, tooltip)
    local center_square = rect:centered_square()

	-- fetching data
	local age = AGE_YEARS(pop_id)
	local teen_age = DATA.race_get_teen_age(DATA.pop_get_race(pop_id))
	local occupation = DATA.get_employment_from_worker(pop_id)
    local employer_id = DATA.employment_get_building(occupation)
	local unit_of = UNIT_TYPE_OF(pop_id)

	if age < teen_age then
		ut.render_icon(center_square, "ages.png", 0.8, 0.8, 0.8, 1, true)
	else
		if unit_of == UNIT_TYPE.WARRIOR then
			pui.render_unit_icon(center_square, pop_id)
		elseif employer_id ~= INVALID_ID then
			local job_id = DATA.employment_get_job(occupation)
			ut.render_icon(center_square,
				DATA.job_get_icon(job_id),
				DATA.job_get_r(job_id),
				DATA.job_get_g(job_id),
				DATA.job_get_b(job_id),
				1,
				true)
		else
			ut.render_icon(center_square, "shrug.png", 0.9, 0.9, 0.9, 1, true)
		end
	end
	if tooltip then
    	ui.tooltip(tooltip, rect)
	end
end

---Draw a generic percentage for a pop life sasifcation with a details in tooltip
---@param rect Rect
---@param pop POP
function pui.render_life_needs_satsifaction(rect, pop)
	local needs_tooltip = ""

	for index = 1, MAX_NEED_SATISFACTION_POSITIONS_INDEX do
		local use_case = DATA.pop_get_need_satisfaction_use_case(pop, index)
		if use_case == 0 then
			break
		end
		local need = DATA.pop_get_need_satisfaction_need(pop, index)
        if DATA.need_get_life_need(need) then
            local demanded = DATA.pop_get_need_satisfaction_demanded(pop, index)
            local consumed = DATA.pop_get_need_satisfaction_consumed(pop, index)
            ---@type string
            needs_tooltip = needs_tooltip
				.. "\n\t" .. DATA.need_get_name(need) .. " - " .. DATA.use_case_get_name(use_case)
				.. "\t" .. ut.to_fixed_point2(consumed) .. " / " .. ut.to_fixed_point2(demanded)
				.. "\t(" .. ut.to_fixed_point2(consumed / demanded * 100) .. "%)"
        end
	end

	ut.generic_number_field(
		"self-love.png",
		DATA.pop_get_life_needs_satisfaction(pop),
		rect,
		"Satisfaction of needs of this character. \n" .. needs_tooltip,
		ut.NUMBER_MODE.PERCENTAGE,
		ut.NAME_MODE.ICON
	)
end

---Draw a generic percentage for a pop basic sasifcation with a details in tooltip
---@param rect Rect
---@param pop POP
function pui.render_basic_needs_satsifaction(rect, pop)
	local needs_tooltip = ""

	for index = 1, MAX_NEED_SATISFACTION_POSITIONS_INDEX do
		local use_case = DATA.pop_get_need_satisfaction_use_case(pop, index)
		if use_case == 0 then
			break
		end
		local need = DATA.pop_get_need_satisfaction_need(pop, index)
		local demanded = DATA.pop_get_need_satisfaction_demanded(pop, index)
		local consumed = DATA.pop_get_need_satisfaction_consumed(pop, index)
		---@type string
		needs_tooltip = needs_tooltip
			.. "\n\t" .. DATA.need_get_name(need) .. " - " .. DATA.use_case_get_name(use_case)
			.. "\t" .. ut.to_fixed_point2(consumed) .. " / " .. ut.to_fixed_point2(demanded)
			.. "\t(" .. ut.to_fixed_point2(consumed / demanded * 100) .. "%)"
	end

	ut.generic_number_field(
		"inner-self.png",
		DATA.pop_get_basic_needs_satisfaction(pop),
		rect,
		"Satisfaction of needs of this character. \n" .. needs_tooltip,
		ut.NUMBER_MODE.PERCENTAGE,
		ut.NAME_MODE.ICON
	)
end

---Draw a money panel of a pop's savings
---@param rect Rect
---@param pop_id pop_id
function pui.render_savings(rect, pop_id)
	local savings = DATA.pop_get_savings(pop_id)
    ut.generic_number_field(
        "coins.png",
        savings,
        rect,
        NAME(pop_id) .. " has " .. MONEY_SYMBOL .. ut.to_fixed_point2(savings) .. " in savings.",
        ut.NUMBER_MODE.MONEY,
        ut.NAME_MODE.ICON,
        false,
        true)
end

---Draw a balance panel of a pop's pending economy income
---@param rect Rect
---@param pop_id pop_id
function pui.render_pending_income(rect, pop_id)
	local income = DATA.pop_get_pending_economy_income(pop_id)
    ut.generic_number_field(
        "receive-money.png",
        income,
        rect,
        NAME(pop_id) .. " gained " .. MONEY_SYMBOL .. ut.to_fixed_point2(income) .. " last month.",
        ut.NUMBER_MODE.MONEY,
        ut.NAME_MODE.ICON,
        false,
        true)
end

---Draw a percentage panel of spendings fraction
---@param rect Rect
---@param pop_id pop_id
function pui.render_spending_ratio(rect, pop_id)
	local spending_ratio = DATA.pop_get_spend_savings_ratio(pop_id)
    ut.generic_number_field(
		"two-coins.png",
		spending_ratio,
		rect,
		NAME(pop_id) .. " spends up to " .. ut.to_fixed_point2(spending_ratio*100) .. "% of its savings satisfying its needs each month.",
		ut.NUMBER_MODE.PERCENTAGE,
		ut.NAME_MODE.ICON,
		true,
        true)
end

---Draw an number panel of inventory size with goods breakdown in tooltip
---@param rect Rect
---@param pop_id pop_id
function pui.render_inventory(rect, pop_id)
	local inventory_size = 0

	local inventory_tooltip = ""
	DATA.for_each_trade_good(function (item)
		local amount = DATA.pop_get_inventory(pop_id, item)
		inventory_size = inventory_size + amount
		if amount > 0 then
			inventory_tooltip =
				inventory_tooltip
				.. "\n - " .. DATA.trade_good_get_name(item)
				.. " " .. ut.to_fixed_point2(amount)
		end
	end)
	inventory_tooltip = NAME(pop_id) .. "'s inventory: (" .. ut.to_fixed_point2(inventory_size) .. ")" .. inventory_tooltip

	ut.generic_number_field(
		"cardboard-box.png",
		inventory_size,
		rect,
		inventory_tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON,
		false,
		true)
end

---returns a tooltip string with some details on a specific pop
---@param pop_id pop_id
---@return string
function pui.pop_tooltip(pop_id)
	if pop_id ~= INVALID_ID then
		local unit_type_id = UNIT_TYPE_OF(pop_id)
		local unit_type = unit_type_id ~= INVALID_ID and DATA.unit_type_get_name(unit_type_id) or strings.title(rank_name(pop_id))
		local tooltip = NAME(pop_id)
			.. "\n " .. AGE_YEARS(pop_id) .. " y.o." .. (FEMALE(pop_id) and " female " or " male ")
				.. DATA.race_get_name(RACE(pop_id)) .. " " .. pop_utils.get_age_string(pop_id)
			.. "\n  Member of " .. strings.title(DATA.culture_get_name(CULTURE(pop_id))) .. " culture"
			.. "\n  Follower of " .. strings.title(DATA.faith_get_name(DATA.pop_get_faith(pop_id))) .. " faith"
		return tooltip
	else
		return "unknown"
	end
end


---@param rect Rect
---@param pop_id pop_id
---@param job_type_id jobtype_id
function pui.render_job_efficiency(rect, pop_id, job_type_id)
	local race_id = RACE(pop_id)
	local race_efficiency
	if FEMALE(pop_id) then
		race_efficiency = DATA.race_get_female_efficiency(race_id,job_type_id)
	else
		race_efficiency = DATA.race_get_male_efficiency(race_id,job_type_id)
	end
	local age, teen_age, middle_age =
		AGE_YEARS(pop_id),
		DATA.race_get_teen_age(race_id),
		DATA.race_get_middle_age(race_id)
	local efficiency = JOB_EFFICIENCY(pop_id,job_type_id)
	local tooltip = strings.title(DATA.jobtype_get_action_word(job_type_id))
		.. " efficiency is " .. ut.to_fixed_point2(efficiency*100) .. "%"
		.. "\n\t" .. ut.to_fixed_point2(race_efficiency*100).. "% (" .. strings.title(DATA.race_get_name(race_id)) .. ")"
	if (age < teen_age) or (age >= middle_age) then
		local age_multiplier = AGE_MULTIPLIER(pop_id)
		tooltip = tooltip
			.. "\n\t × " .. ut.to_fixed_point2(age_multiplier*100) .. "% (" .. pop_utils.get_age_string(pop_id) .. ")"
	end
	ut.generic_number_field(
		DATA.jobtype_get_icon(job_type_id),
		efficiency,
		rect,
		tooltip,
		ut.NUMBER_MODE.PERCENTAGE,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_size(rect,pop_id)
	local value = pop_utils.get_size(pop_id)
	local race_id = RACE(pop_id)
	local race_base
	if FEMALE(pop_id) then
		race_base = DATA.race_get_female_body_size(race_id)
	else
		race_base = DATA.race_get_male_body_size(race_id)
	end
	local tooltip = "Body Size"
		.. "\n\t" .. ut.to_fixed_point2(race_base).. " (" .. strings.title(DATA.race_get_name(race_id)) .. ")"

	local age, teen_age, middle_age =
		AGE_YEARS(pop_id),
		DATA.race_get_teen_age(race_id),
		DATA.race_get_middle_age(race_id)
	if (age < teen_age) or (age >= middle_age) then
		local age_multiplier = AGE_MULTIPLIER(pop_id)
		tooltip = tooltip
			.. "\n\t × " .. ut.to_fixed_point2(age_multiplier*100) .. "% (" .. pop_utils.get_age_string(pop_id) .. ")"
	end
	ut.generic_number_field(
		"inner-self.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_spotting(rect,pop_id)
	local value = pop_utils.get_spotting(pop_id)
	local race_id = RACE(pop_id)
	local race_mod = DATA.race_get_spotting(race_id)
	local tooltip = "Spotting"
		.. "\n\t" .. ut.to_fixed_point2(race_mod).. " (" .. strings.title(DATA.race_get_name(race_id)) .. ")"

	local age, teen_age, middle_age =
		AGE_YEARS(pop_id),
		DATA.race_get_teen_age(race_id),
		DATA.race_get_middle_age(race_id)
	if (age < teen_age) or (age >= middle_age) then
		local age_multiplier = AGE_MULTIPLIER(pop_id)
		tooltip = tooltip
			.. "\n\t × " .. ut.to_fixed_point2(age_multiplier*100) .. "% (" .. pop_utils.get_age_string(pop_id) .. ")"
	end
	ut.generic_number_field(
		"magnifying-glass.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_visibility(rect,pop_id)
	local value = pop_utils.get_visibility(pop_id)
	local race_id = RACE(pop_id)
	local race_mod = DATA.race_get_visibility(race_id)
	local size = pop_utils.get_size(pop_id)
	local tooltip = "Visibilty"
		.. "\n\t" .. ut.to_fixed_point2(race_mod).. " (" .. strings.title(DATA.race_get_name(race_id)) .. ")"
		.. "\n\t × " .. ut.to_fixed_point2(size) .. " (Size)"

	ut.generic_number_field(
		"high-grass.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_health(rect,pop_id)
	local value = pop_utils.get_health(pop_id)
	local base = pop_utils.get_size(pop_id)
	local tooltip = "Max Health"
		.. "\n\t" .. ut.to_fixed_point2(base) .. " (Size)"
	ut.generic_number_field(
		"health-normal.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_attack(rect,pop_id)
	local value = pop_utils.get_attack(pop_id)
	local base = JOB_EFFICIENCY(pop_id,JOBTYPE.WARRIOR)
	local tooltip = "Attack"
		.. "\n\t" .. ut.to_fixed_point2(base) .. " (Warrior)"
	ut.generic_number_field(
		"stone-spear.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_armor(rect,pop_id)
	local value = pop_utils.get_armor(pop_id)
	local tooltip = "Armor"
		.. "\n\t" .. ut.to_fixed_point2(0) .. " (Base)"
	ut.generic_number_field(
		"round-shield.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_speed(rect,pop_id)
	local value = pop_utils.get_speed(pop_id).base

	local tooltip = "Speed"
		.. "\n\t" .. ut.to_fixed_point2(1) .. " (Base)"

	local race_id = RACE(pop_id)
	local age, teen_age, middle_age =
		AGE_YEARS(pop_id),
		DATA.race_get_teen_age(race_id),
		DATA.race_get_middle_age(race_id)
	if (age < teen_age) or (age >= middle_age) then
		local age_multiplier = AGE_MULTIPLIER(pop_id)
		tooltip = tooltip
			.. "\n\t × " .. ut.to_fixed_point2(age_multiplier*100) .. "% (" .. pop_utils.get_age_string(pop_id) .. ")"
	end

	ut.generic_number_field(
		"fast-forward-button.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_supply_capacity(rect,pop_id)
	local value = pop_utils.get_supply_capacity(pop_id)
	local base = pop_utils.get_size(pop_id)
	local mod = JOB_EFFICIENCY(pop_id, JOBTYPE.HAULING)
	local tooltip = "Supply Capacity"
		.. "\n\t" .. ut.to_fixed_point2(base) .. " (Size)"
		.. "\n\t × " .. ut.to_fixed_point2(base) .. " (Hauling)"
	ut.generic_number_field(
		"cardboard-box.png",
		value,
		rect,
		tooltip,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_supply_use(rect,pop_id)
	local value = pop_utils.get_supply_use(pop_id)
	ut.generic_number_field(
		"noodles.png",
		value,
		rect,
		nil,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_carrying_capacity_weight(rect,pop_id)
	local value = pop_utils.get_carry_capacity_weight(pop_id)
	ut.generic_number_field(
		"ages.png",
		value,
		rect,
		nil,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

---@param rect Rect
---@param pop_id pop_id
function pui.render_infrastructure_needs(rect,pop_id)
	local value = pop_utils.get_infrastructure_need(pop_id)
	ut.generic_number_field(
		"village.png",
		value,
		rect,
		nil,
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON
	)
end

function pui.render_location_buttons(game,rect,pop_id)
	local name = NAME(pop_id)
	local province_id = POP_PROVINCE(pop_id)
	local realm_id = PROVINCE_REALM(province_id)
	local icon_size = math.max(ut.BASE_HEIGHT,rect.height)
	local icon_rect = rect:subrect(-rect.height*3,0,icon_size,icon_size,"right","up")
	local info_rect = rect:subrect(0,0,icon_size*3,rect.height,"right","up")
	local tile_id
	-- in a settlement that has a realm
	if POP_PROVINCE(pop_id) == province_id then
		tile_id = DATA.province_get_center(province_id)
		ib.icon_button_to_realm(game,realm_id,icon_rect,
			name .. " is currently in the capitol of " .. (realm_id ~= INVALID_ID and DATA.realm_get_name(realm_id) or " unclaimed wildlands."))
		pui.render_realm_popularity(info_rect,pop_id,realm_id)
	else -- has a party location and speed
		local party_id = UNIT_OF(pop_id)
		tile_id = ESTATE_TILE(party_id)
		local biome = DATA.tile_get_biome(tile_id)
		local biome_tooltip = name .. " is currently roaming " .. DATA.biome_get_name(biome) .. "."
		ui.panel(icon_rect,2,true)
		ut.render_icon(icon_rect,"horizon-road.png",DATA.biome_get_r(biome),DATA.biome_get_g(biome),DATA.biome_get_b(biome),1,true)
		ui.tooltip(biome_tooltip,icon_rect)
		require "game.scenes.game.widgets.party-ui-widgets".render_travel_speed(info_rect,party_id)
	end
	ib.text_button_to_province_tile(game,tile_id,rect:subrect(0,0,rect.width-icon_size*4,rect.height,"left","up"),
		NAME(pop_id) .. " is currently in the province of " .. PROVINCE_NAME(province_id) .. ".")
end


---draws a ib overlay portrait with title, location, and some basic info
---, rect.height should be a minimum 4 ut.BASE_HEIGHT!
---@param game GameScene
---@param rect Rect
---@param pop_id pop_id
---@param title string
function pui.render_pop_overview(game,rect,pop_id,title)
	local player_id = WORLD.player_character
    ui.panel(rect,nil,nil,true)
    local title_rect = rect:subrect(0,0,rect.width,ut.BASE_HEIGHT,"left","up")
    ui.text(title,title_rect,"left","center")

    local portrait_size = rect.height-ut.BASE_HEIGHT
    local portrait_rect = rect:subrect(0,0,portrait_size,portrait_size,"left","down")
    ib.render_portrait_with_overlay(game,portrait_rect,pop_id,pui.pop_tooltip(pop_id))
    local lines_rect = rect:subrect(0,0,rect.width-portrait_size,ut.BASE_HEIGHT*3,"right","down")
    local lines_layout = ui.layout_builder():position(lines_rect.x,lines_rect.y):vertical():build()

    -- basic info
    local line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)
    local line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
    pui.render_age(line_layout:next(line_rect.width-ut.BASE_HEIGHT*10,ut.BASE_HEIGHT),pop_id,"right")
    pui.render_female_icon(line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),pop_id)
    ui.render_race_icon(line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),RACE(pop_id),ui.race_tooltip(RACE(pop_id)))
    ui.render_culture_icon(line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),CULTURE(pop_id),ui.culture_tooltip(CULTURE(pop_id)))
    ui.render_faith_icon(line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),DATA.pop_get_faith(pop_id),ui.faith_tooltip(DATA.pop_get_faith(pop_id)))
    pui.render_basic_needs_satsifaction(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),pop_id)
    pui.render_life_needs_satsifaction(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),pop_id)

    -- location and popularity
    line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)
    line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
    pui.render_location_buttons(game,line_layout:next(line_rect.width,ut.BASE_HEIGHT),pop_id)

    -- home populatiry
    line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)
    line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
    pui.render_realm_popularity(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),pop_id,REALM(pop_id))
    -- occupation, savings, income
    pui.render_occupation_icon(line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),pop_id,pui.occupation_tooltip(pop_id))
    pui.render_savings(line_layout:next(line_rect.width-ut.BASE_HEIGHT*7,ut.BASE_HEIGHT),pop_id)
    pui.render_pending_income(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),pop_id)

end

return pui