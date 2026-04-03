local tabb = require "engine.table"

local ui = require "engine.ui";
local ut = require "game.ui-utils"

local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"
local pui = require "game.scenes.game.widgets.pop-ui-widgets"
local list_widget = require "game.scenes.game.widgets.list-widget"

local pop_utils = require "game.entities.pop".POP
local warband_utils = require "game.entities.warband"

local pop_values = require "game.raws.values.pop"
local economy_values = require "game.raws.values.economy"

local economic_effects = require "game.raws.effects.economy"

local demography_values = require "game.raws.values.demography"
local demography_effects = require "game.raws.effects.demography"

local portrait = require "game.scenes.game.widgets.portrait"

local window = {}

---@type "RECRUIT" | "WARRIOR"
local unit_panel_tab = "RECRUIT"
local type_list_state = nil
local unit_list_state = nil

---@param rect Rect
---@param icon string
---@param r number
---@param g number
---@param b number
---@param a number
local function render_icon_panel(rect, icon, r , g, b , a)
	ui.panel(rect)
	ut.render_icon(rect, icon, 1, 1, 1, 1)
	rect:shrink(1)
	ut.render_icon(rect, icon, r, g, b, 1)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_health (rect, k, v)
	local stat = pop_utils.get_health(k)
	local female, her = "male", "his"
	if DATA.pop_get_female(k) then
		female, her = "female", "her"
	end
	ut.generic_number_field(
		"plus.png",
		stat,
		rect,
		NAME(k)
		.. " has "
		.. ut.to_fixed_point2(stat)
		.. " health."
		.. "\n - As a "  ..  DATA.unit_type_get_name(v) .. ", "
		.. NAME(k) .. " has a base health of " .. ut.to_fixed_point2(stat) .. "."
		.. "\n - Being a " .. female.. " " .. DATA.race_get_name(RACE(k))
		.. " modifies this by " .. her .." size of " .. ut.to_fixed_point2(pop_utils.size(k)) .. ".",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_attack (rect, k, v)
	local stat = pop_utils.get_attack(k)
	local job = JOB_EFFICIENCY(k, JOBTYPE.WARRIOR)
	local female, her = "male", "his"
	if DATA.pop_get_female(k) then
		female, her = "female", "her"
	end
	ut.generic_number_field(
		"stone-axe.png",
		stat,
		rect,
		NAME(k) .. " has " .. ut.to_fixed_point2(stat) .. " attack."
			.. "\n - As a " ..  DATA.unit_type_get_name(v) .. ", " .. NAME(k) .. " has a base attack of " .. ut.to_fixed_point2(stat) .. "."
			.. "\n - Being a " .. female.. " " .. DATA.race_get_name(RACE(k)) .. " modifies this by " .. her .." racial warrior efficiency of " .. ut.to_fixed_point2(job * 100) .. "%.",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_armor (rect, k, v)
	local base = pop_utils.get_armor(k)
	local female, her = "male", "his"
	if DATA.pop_get_female(k) then
		female, her = "female", "her"
	end
	ut.generic_number_field(
		"round-shield.png",
		base,
		rect,
		NAME(k) .. " has " .. ut.to_fixed_point2(base) .. " armor."
			.. "\n - As a " ..  DATA.unit_type_get_name(v) .. ", " .. NAME(k) .. " has a base armor of " .. ut.to_fixed_point2(base) .. ".",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_speed (rect, k, v)
	local base = pop_utils.get_speed(k).base
	ut.generic_number_field(
		"fast-forward-button.png",
		base,
		rect,
		NAME(k) .. " has a speed of " .. ut.to_fixed_point2(base) .. "."
		.. "\n - As a " ..  ((v ~= INVALID_ID) and DATA.unit_type_get_name(v) or "noncombatant") .. ", " .. NAME(k) .. " has a base speed of " .. ut.to_fixed_point2(base) .. ".",
		ut.NUMBER_MODE.PERCENTAGE,
		ut.NAME_MODE.ICON)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_spotting (rect, k, v)
	local base = pop_utils.get_spotting(k)
	local female, her = "male", "his"
	if DATA.pop_get_female(k) then
		female, her = "female", "her"
	end
	ut.generic_number_field(
		"magnifying-glass.png",
		base,
		rect,
		NAME(k) .. " has a spotting bonus of " .. ut.to_fixed_point2(base) .. "."
			.. "\n - As a " .. ((v ~= INVALID_ID) and DATA.unit_type_get_name(v) or "noncombatant") .. ", " .. NAME(k) .. " has a base spotting bonus of " .. ut.to_fixed_point2(base) .. "."
			.. "\n - Being a " .. female.. " " .. DATA.race_get_name(RACE(k)) .. " modifies this by " .. her .." racial spotting of " .. ut.to_fixed_point2(F_RACE(k).spotting * 100)
			.. "%.",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_visibility (rect, k, v)
	local base = pop_utils.get_visibility(k, v)
	local female, her = "male", "his"
	if DATA.pop_get_female(k) then
		female, her = "female", "her"
	end
	ut.generic_number_field(
		"high-grass.png",
		base,
		rect,
		NAME(k) .. " has a visibility of " .. ut.to_fixed_point2(base) .. "."
			.. "\n - As a " ..  ((v ~= INVALID_ID) and DATA.unit_type_get_name(v) or "noncombatant") .. ", " .. NAME(k) .. " has a base visibility of " .. ut.to_fixed_point2(base) .. "."
			.. "\n - Being a " .. female.. " " .. DATA.race_get_name(RACE(k)) .. " modifies this by " .. her .." racial visibility of " .. ut.to_fixed_point2(F_RACE(k).visibility * 100)
			.. "% and a size of " .. ut.to_fixed_point2(pop_utils.size(k)) ..".",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_supply_use (rect, k, v)
	local base = pop_utils.get_supply_use(k)
	local food_need = pop_values.calories_food_need(k)
	local female, her = "male", "his"
	if DATA.pop_get_female(k) then
		female, her = "female", "her"
	end
	ut.generic_number_field(
		"sliced-bread.png",
		base,
		rect,
		NAME(k) .. " uses " .. ut.to_fixed_point2(base) .. " units of food per day of traveling."
			.. "\n - As a " ..  ((v ~= INVALID_ID) and DATA.unit_type_get_name(v) or "noncombatant") .. ", " .. NAME(k) .. " has a base daily supply use of " .. ut.to_fixed_point2(base) .. "."
			.. "\n - Being a " .. female.. " " .. DATA.race_get_name(RACE(k)) .. " adds " .. her .. " daily racial food consumption of "
			.. ut.to_fixed_point2(food_need / 30).. " units per day.",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
end

---@param rect Rect
---@param k POP
---@param v unit_type_id
local function render_unit_hauling (rect, k, v)
	local base = pop_utils.get_supply_capacity(k)
	local job = JOB_EFFICIENCY(k, JOBTYPE.HAULING)
	local female, her = "male", "his"
	if DATA.pop_get_female(k) then
		female, her = "female", "her"
	end
	ut.generic_number_field(
		"cardboard-box.png",
		base,
		rect,
		NAME(k) .. " has a hauling capacity of " .. ut.to_fixed_point2(base) .. "."
			.. "\n - As a " ..  ((v ~= INVALID_ID) and DATA.unit_type_get_name(v) or "noncombatant") .. ", " .. NAME(k) .. " has a base of " .. ut.to_fixed_point2(base) .. "."
			.. "\n - Being a " .. female.. " " .. DATA.race_get_name(RACE(k)) .. " adds " .. her .." racial hauling job efficiency of " .. ut.to_fixed_point2(job) .. ".",
		ut.NUMBER_MODE.NUMBER,
		ut.NAME_MODE.ICON)
end


---@return Rect
function window.rect()
    local fs = ui.fullscreen()
    return fs:subrect(ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 45, fs.height / 2, "left", "up")
end

---Returns whether or not clicks on the planet can be registered.
---@return boolean
function window.mask()
	if ui.trigger(window.rect()) then
		return false
	else
		return true
	end
end

local WARBAND_SIPHON_AMOUNT = 1;
local spacing = 5

---actually draw the inspector panel
---@param gamescene GameScene
function window.draw(gamescene)
	---@type pop_id
	local player_character = WORLD.player_character

	--- combining key presses for increments of 1, 5, 10, and 50
	WARBAND_SIPHON_AMOUNT = 1
	if ui.is_key_held("lshift") or ui.is_key_held("rshift") then
		WARBAND_SIPHON_AMOUNT = WARBAND_SIPHON_AMOUNT * 5
	end
	if ui.is_key_held("lctrl") or ui.is_key_held("rctrl") then
		WARBAND_SIPHON_AMOUNT = WARBAND_SIPHON_AMOUNT * 10
	end

	local panel = window.rect()

	local warband = gamescene.selected.warband
	if (player_character  ~= INVALID_ID) and not warband then
		if LEADER_OF_ESTATE(player_character) ~= INVALID_ID then
			warband = LEADER_OF_ESTATE(player_character)
		elseif RECRUITER_OF_ESTATE(player_character) ~= INVALID_ID then
			warband = RECRUITER_OF_ESTATE(player_character)
		elseif UNIT_OF(player_character) ~= INVALID_ID then
			warband = UNIT_OF(player_character)
		end
	end
	if not warband then
		gamescene.inspector = nil
		return
	end

	--- TOP BAR: REALM BUTTON, NAME TEXT, CLOSE WINDOW BUTTON
	---@param rect Rect
	local function draw_top_panel(rect)
		local top_bar_layout = ui.layout_builder()
			:horizontal()
			:position(rect.x, rect.y)
			:spacing(spacing)
			:build()

		local realm = warband_utils.realm(warband)
		local desc = "warriors from " .. REALM_NAME(realm)
		local realm_rect = top_bar_layout:next(ut.BASE_HEIGHT, ut.BASE_HEIGHT)
		ui.panel(realm_rect)
		-- warband realm inspector button
		ib.icon_button_to_realm(gamescene, realm, realm_rect)
		-- warband name
		ui.centered_text(ESTATE_NAME(warband) .. ", " .. desc, top_bar_layout:next(rect.width - (ut.BASE_HEIGHT + spacing) * 2, ut.BASE_HEIGHT))
		-- close button
		ib.icon_button_to_close(gamescene, top_bar_layout:next(ut.BASE_HEIGHT, ut.BASE_HEIGHT))
	end

	ui.panel(panel)
	local top_panel = panel:subrect(
		0,
		0,
		panel.width,
		ut.BASE_HEIGHT,
		"left",
		'up'
	)
	draw_top_panel(top_panel)

	--- utitlity to draw characters with portrait and realm buttons
	---@param gam GameScene
	---@param rect Rect
	---@param office_title string
	---@param office_action string
	---@param character Character?
	---@param middle_rect_space fun(rect:Rect, character:Character?)?
	---@param bottom_rect_space fun(rect:Rect, character:Character?)?
	local function draw_office_panel(gam, rect, office_title, office_action, character, middle_rect_space, bottom_rect_space)
		ui.panel(rect)
		rect:shrink(spacing)
		ui.text(office_title, rect:subrect(ut.BASE_HEIGHT * 2, 0, rect.width - ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT, "left", "up"), "center", "center")
		local portrait_rect = rect:subrect(0, 0, ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 2, "left", "up")
		local realm_rect = rect:subrect(ut.BASE_HEIGHT * 2, 0, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "left", "center")
		local button_rect = rect:subrect(ut.BASE_HEIGHT * 3, 0, ut.BASE_HEIGHT * 6, ut.BASE_HEIGHT, "left", "center")
		local middle_rect = rect:subrect(0, 0, rect.width - ut.BASE_HEIGHT * 9, ut.BASE_HEIGHT, "right", "center")
		local bottom_rect = rect:subrect(0, 0, rect.width, ut.BASE_HEIGHT, "center", "down")
		if middle_rect_space then
			middle_rect_space(middle_rect, character)
		else
			ui.panel(middle_rect, 1, true)
		end
		if bottom_rect_space then
			bottom_rect_space(bottom_rect, character)
		else
			ui.panel(bottom_rect, 1, true)
		end
		if character ~= INVALID_ID and character ~= nil then
			ib.icon_button_to_realm(gam, REALM(character), realm_rect)
			ib.icon_button_to_character(gam, character, portrait_rect)
			ui.text(NAME(character),button_rect)
			ui.tooltip(NAME(character) .. " is currently " .. office_action .. " this warband.",button_rect)

		else
			ut.render_icon(portrait_rect, "uncertainty.png",.8,.8,.8,1,true)
			ut.text_button("empty", button_rect, nil, false)
		end
	end

	---commenting
	---@param rect Rect
	---@param character Character
	local function render_character_unit_name(rect, character)
		if character ~= INVALID_ID then
			local unit_name = "officer"
			local icon_rect = rect:subrect(0, 0, rect.height, rect.height, "left", "center")
			local text_rect = rect:subrect(0, 0, rect.width - rect.height, rect.height, "right", "center")
			local race = F_RACE(character)
			render_icon_panel(icon_rect, race.icon, race.r, race.g, race.b, 1)
			ui.text_panel(unit_name, text_rect)
		else
			ui.panel(rect, 1, true)
		end
	end

	---@param rect Rect
	---@param character Character
	local function render_character_unit_stat(rect, character)
		if character ~= INVALID_ID then
			local width_fraction = rect.width / 5
			local layout = ui.layout_builder()
				:horizontal()
				:position(rect.x, rect.y)
				:build()
			-- draw using functions if a unit
			-- declare variables and intialize as a male noncombatant character
			pui.render_speed(layout:next(width_fraction, rect.height), character)
			pui.render_spotting(layout:next(width_fraction, rect.height), character)
			pui.render_visibility(layout:next(width_fraction, rect.height), character)
			pui.render_supply_use(layout:next(width_fraction, rect.height), character)
			pui.render_supply_capacity(layout:next(width_fraction, rect.height), character)
			-- actually draw stats in rect
		else
			ui.panel(rect)
			ut.render_icon(rect:subrect(ut.BASE_HEIGHT * 2, -ut.BASE_HEIGHT, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "left", "up"), "cancel.png", 1, 1, 1, 1)
		end
	end

	local panel_width = panel.width - spacing * 2
	local panel_layout = ui.layout_builder()
		:vertical()
		:position(panel.x + spacing, top_panel.x + top_panel.height + spacing)
		:spacing(spacing)
		:build()

	local leader_supply_panels = panel_layout:next(panel_width, ut.BASE_HEIGHT * 3 + spacing * 2)
	local leader_layout = ui.layout_builder()
		:horizontal()
		:position(leader_supply_panels.x, leader_supply_panels.y)
		:spacing(spacing)
		:build()

	-- leader officer panel
	local leader_rect = leader_layout:next(ut.BASE_HEIGHT * 14 + spacing * 2, ut.BASE_HEIGHT * 3 + spacing * 2)
	local leader = ESTATE_LEADER(warband)
	local guarding_realm = DATA.realm_guard_get_realm(DATA.get_realm_guard_from_guard(warband))
	local leader_of_guarded_realm = LEADER(guarding_realm)
	local recruiter = ESTATE_RECRUITER(warband)
	local commander = ESTATE_COMMANDER(warband)
	local upkeep = DATA.warband_get_total_upkeep(warband)

	local recruiter_title = "Recruiter"
	local recruiter_adjective = "recruiting"
	if leader ~= INVALID_ID then
		draw_office_panel(gamescene, leader_rect, "Leader", "leading", leader, render_character_unit_name, render_character_unit_stat)
	elseif guarding_realm ~= INVALID_ID then -- if no leader then guard, draw realm icon and name
		local province = CAPITOL(guarding_realm)
		recruiter_title = "Captain"
		recruiter_adjective = "leading"
		ui.panel(leader_rect)
		leader_rect:shrink(spacing)
		ui.text("Capitol Guard", leader_rect:subrect(0, 0, leader_rect.width, ut.BASE_HEIGHT, "left", "up"), "center", "center")
		ib.icon_button_to_realm(gamescene, guarding_realm, leader_rect:subrect(0, 0, ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 2, "left", "down"))
		local realm_rect = leader_rect:subrect(ut.BASE_HEIGHT*2,0,leader_rect.width-ut.BASE_HEIGHT*2,ut.BASE_HEIGHT,"left","center")
		ui.text(REALM_NAME(guarding_realm),realm_rect)
		ui.tooltip("This warband is the capitol guard of " .. REALM_NAME(guarding_realm) .. ".",realm_rect)
		ib.text_button_to_province_tile(gamescene, ESTATE_TILE(warband), leader_rect:subrect(ut.BASE_HEIGHT * 2, 0,leader_rect.width - ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT, "left", "down"),
			"This warband guards the province of " .. PROVINCE_NAME(province) .. ".")
	end

	-- SUPPLIES AND TREASURY PANELS

	--- draws treasury info panel with +/- buttons
	---@param rect Rect
	local function draw_treasury_panel(rect)
		-- leaders can take and give, other warband characters can only give
		local can_take_money, can_gift_money = false, false
		if player_character ~= INVALID_ID then
			-- leaders can give and take
			if leader == player_character then
				can_take_money, can_gift_money = true, true
			-- other members of warbands can gift
			elseif (leader_of_guarded_realm == player_character)
				or (recruiter == player_character)
				or (warband == UNIT_OF(player_character))
			then
				can_gift_money = true
			end
		end

		ui.panel(rect)
		rect:shrink(spacing)
		local rect_height = rect.height / 3
		local half_width = rect.width / 2
		local third_width = rect.width / 3
		local fourth_width = half_width / 2

		ui.text("Treasury", rect:subrect(0, 0, rect.width, ut.BASE_HEIGHT, "center", "up"), "center", "up")

		---@param x number
		local function gift_to_treasury_target(rect, x)
			local preposition = 'from'
			local tooltip = "Take "

			local amount = x * WARBAND_SIPHON_AMOUNT

			if x > 0 then
				tooltip = "Give "
				preposition = 'to'
				amount = math.min(amount, ((player_character  ~= INVALID_ID) and SAVINGS(player_character)) or 0)
			elseif x < 0 then
				amount = math.max(amount, -DATA.warband_get_treasury(warband))
			end

			if can_take_money or can_gift_money and x > 0 then
				tooltip = tooltip
				.. ut.to_fixed_point2(math.abs(amount))
				.. MONEY_SYMBOL
				.. " of wealth "
				.. preposition
				.. " warband's treasury."
				.. "\nPress Ctrl and/or Shift to modify amount."
			elseif can_gift_money then
				tooltip = "You do not have permission to take funds from this warband treasury!"
			else
				tooltip = "You do not have permission to transfer funds " .. preposition .. " this warband treasury!"
			end

			if ut.money_button(
				"",
				amount,
				rect,
				tooltip,
				(x < 0 and can_take_money) or (x > 0 and can_gift_money)
			) then
				if player_character then
					economic_effects.gift_to_warband(warband, player_character, amount)
				end
			end
		end

		local treasury = DATA.warband_get_treasury(warband)
		local upkeep = warband_utils.predict_upkeep(warband)

		local months_of_upkeep = 9999
		if upkeep > 0 then
			months_of_upkeep = math.ceil(treasury / upkeep)
		end

		ut.money_entry_icon(DATA.warband_get_treasury(warband), rect:subrect(0, 0, half_width, rect_height, "center", "center"),
			"This warband currently has " .. ut.to_fixed_point2(DATA.warband_get_treasury(warband)) .. MONEY_SYMBOL .. " in its treasury.")
		gift_to_treasury_target(rect:subrect(0, 0, fourth_width, rect_height, "left", "center"), -1)
		gift_to_treasury_target(rect:subrect(0, 0, fourth_width, rect_height, "right", "center"), 1)

		ut.generic_number_field(
			"two-coins.png",
			upkeep,
			rect:subrect(0, 0, third_width, rect_height, "left", "down"),
			"The warband currently to costs " .. ut.to_fixed_point2(-upkeep) .. MONEY_SYMBOL .. " each month.",
			ut.NUMBER_MODE.BALANCE,
			ut.NAME_MODE.ICON,
			true,
			true
		)
		ut.generic_number_field(
			"receive-money.png",
			upkeep,
			rect:subrect(0, 0, third_width, rect_height, "center", "down"),
			"The warband at target size is predicted to costs " .. ut.to_fixed_point2(-upkeep) .. MONEY_SYMBOL .. " each month.",
			ut.NUMBER_MODE.BALANCE,
			ut.NAME_MODE.ICON,
			true,
			true
		)
		ut.generic_number_field(
			"receive-money.png",
			months_of_upkeep,
			rect:subrect(0, 0, third_width, rect_height, "right", "down"),
			"The warbands treasury can afford the target size for ".. months_of_upkeep .. " months of upkeep.",
			ut.NUMBER_MODE.INTEGER,
			ut.NAME_MODE.ICON
		)
	end

	local treasury_rect = leader_layout:next(ut.BASE_HEIGHT * 12, ut.BASE_HEIGHT * 3 + spacing * 2)
	draw_treasury_panel(treasury_rect)

	--- draws supplies info panel with stance buttons
	---@param rect Rect
	local function draw_supplies_panel(rect)

		ui.panel(rect)
		rect:shrink(spacing)

		local rect_width = rect.width
		local rect_height = rect.height
		ui.text("Supplies", rect:subrect(0, 0, rect_width, rect_height / 3, "center", "up"), "center", "up")

		local permission = false
		if ((player_character  ~= INVALID_ID) and player_character == leader)
			or ((player_character  ~= INVALID_ID) and player_character == recruiter)
		then
			permission = true
		end


		---@param x WARBAND_STANCE
		local function set_stance(rect, x)
			local text = "Order your party to " .. DATA.warband_stance_get_name(x) .. "."
			if permission == false then
				text = "You do not control this warband!"
			end
			if ut.text_button(
				DATA.warband_stance_get_name(x),
				rect,
				text,
				permission,
				DATA.warband_get_idle_stance(warband) == x
			) then
				DATA.warband_set_idle_stance(warband, x)
			end
		end

		-- supplies / day
		local daily_supply_consumption = warband_utils.daily_supply_consumption(warband)
		ut.generic_number_field(
			"sliced-bread.png",
			daily_supply_consumption,
			rect:subrect(0, 0, rect_width / 2, rect_height / 3, "left", "center"),
			"This warband cosumes " .. ut.to_fixed_point2(daily_supply_consumption) .. " units of food per day of traveling.",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON
		)
		-- days of travel time
		local days_of_supply_consumption = economy_values.days_of_travel(warband)
		ut.generic_number_field(
			"horizon-road.png",
			days_of_supply_consumption,
			rect:subrect(0, 0, rect_width / 2, rect_height / 3, "left", "down"),
			"With " .. ut.to_fixed_point2(economy_values.get_supply_available(warband)) .. " units of food available,"
				.. " this warband has enough supplies for " .. ut.to_fixed_point2(days_of_supply_consumption) .. " days of travel"
				.. " while using " .. ut.to_fixed_point2(daily_supply_consumption) .. " units each day.",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON
		)
		-- work button
		set_stance(rect:subrect(0, 0, rect_width / 2, rect_height / 3, "right", "center"), ESTATE_STANCE.WORK)
		-- forage button
		set_stance(rect:subrect(0, 0, rect_width / 2, rect_height / 3, "right", "down"), ESTATE_STANCE.FORAGE)
	end
	local supplies_rect = leader_layout:next(ut.BASE_HEIGHT * 9 + spacing, ut.BASE_HEIGHT * 3 + spacing * 2)
	draw_supplies_panel(supplies_rect)

	local location = warband_utils.location(warband)

	---@param rect Rect
	local function draw_location_panel(rect)
		ui.panel(rect)
		rect:shrink(spacing)
		ui.text("Location", rect:subrect(0, 0, rect.width, ut.BASE_HEIGHT, "right", "up"), "center", "up")
		local realm_icon_rect = rect:subrect(0, 0, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "left", "center")
		local realm_text_rect = rect:subrect(0, 0, rect.width - ut.BASE_HEIGHT, ut.BASE_HEIGHT, "right", "center")
		local province_name_rect = rect:subrect(0, 0, rect.width, ut.BASE_HEIGHT, "right", "down")
		local province_realm = nil

		local province = TILE_PROVINCE(location)

		ib.text_button_to_province_tile(gamescene, location, province_name_rect,
			"The warband is currently in the province of " .. PROVINCE_NAME(province) .. ".")
		province_realm = PROVINCE_REALM(province)
		if province_realm ~= INVALID_ID then
			ib.icon_button_to_realm(gamescene, province_realm, realm_icon_rect)
			ui.text(REALM_NAME(province_realm), realm_text_rect)
			ui.tooltip("The warband is currently in a province belonging " .. REALM_NAME(province_realm) .. ".",realm_text_rect)
		else
			ut.render_icon(realm_icon_rect, "uncertainty.png", 1, 1, 1, 1)
			ut.text_button("no realm", realm_text_rect, "The province the warband is currently in is claimed by no one.")
		end
	end

	--TODO FIGURE OUT WHAT TO DO ABOUT THIS BUTTON WHEN RAIDING, TRAVELING, ETC...
	local location_rect = leader_layout:next(ut.BASE_HEIGHT * 8, ut.BASE_HEIGHT * 3 + spacing * 2)
	draw_location_panel(location_rect)

	-- STRENGTH PANEL

	local recruiter_panel = panel_layout:next(panel_width, ut.BASE_HEIGHT * 3 + spacing * 2)
	local recruiter_layout = ui.layout_builder()
		:horizontal()
		:position(recruiter_panel.x, recruiter_panel.y)
		:spacing(spacing)
		:build()

	local recruiter_rect = recruiter_layout:next(ut.BASE_HEIGHT * 14 + spacing * 2, ut.BASE_HEIGHT * 3 + spacing * 2)
	draw_office_panel(gamescene, recruiter_rect, recruiter_title, recruiter_adjective .. " for", recruiter, render_character_unit_name, render_character_unit_stat)

	--- draws row with comander and stats (if there is one)
	---@param rect Rect
	local function draw_commander_panel(rect)

		-- draw commander name and portrait and stats
		draw_office_panel(gamescene, rect, "Commander", "commanding", commander, render_character_unit_name,
		function (rect, character)
			if character ~= INVALID_ID then
				local layout_width = rect.width / 8
				local unit = DATA.warband_unit_get_type(DATA.get_warband_unit_from_unit(character))
				local strength_layout = ui.layout_builder()
					:horizontal()
					:position(rect.x, rect.y)
					:spacing(0)
					:build()

				pui.render_health(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)
				pui.render_attack(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)
				pui.render_armor(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)
				pui.render_speed(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)
				pui.render_spotting(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)
				pui.render_visibility(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)
				pui.render_supply_use(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)
				pui.render_hauling(strength_layout:next(layout_width, ut.BASE_HEIGHT), character)

				-- check if player is eligable to control the warband and draw button to fire
				local control_warband = false
				local text = "Fire commander of this warband."
				if player_character ~= INVALID_ID then
					if player_character == commander then
						text = "Step down from commanding this warband."
					end
					if player_character == leader then
						control_warband = true
					elseif player_character == recruiter then
						if leader ~= INVALID_ID then
							text = "You need to ask permission from the warband leader!"
						else
							control_warband = true
						end
					else
						text = "You do not control this warband!"
					end
					if ut.icon_button(ASSETS.icons["cancel.png"],
						rect:subrect(0, -ut.BASE_HEIGHT, ut.BASE_HEIGHT , ut.BASE_HEIGHT, "right", "up"),
						text, control_warband
					) then
						demography_effects.unset_commander(warband)
					end
				else
					ut.render_icon(rect:subrect(ut.BASE_HEIGHT * 2, -ut.BASE_HEIGHT, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "left", "up"), "cancel.png", 1, 1, 1, 1)
				end
			else
				ui.panel(rect, 1, true)
				-- check if player is eligable to be commander and draw button to take over
				local control_warband = false
				local text = "Take command of this warband."
				if player_character ~= INVALID_ID then
					if player_character == leader then
						control_warband = true
					elseif player_character == recruiter then
						if leader ~= INVALID_ID then
							text = "You need to ask permission from the warband leader!"
						else
							control_warband = true
						end
					else
						text = "You do not control this warband!"
					end
					if ut.icon_button(ASSETS.icons["frog-prince.png"],
						rect:subrect(ut.BASE_HEIGHT * 2, -ut.BASE_HEIGHT, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "left", "up"),
						text, control_warband
					) then
						demography_effects.set_commander(warband, player_character)
					end
				else
					ut.render_icon(rect:subrect(ut.BASE_HEIGHT * 2, -ut.BASE_HEIGHT, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "left", "up"), "cancel.png", 1, 1, 1, 1)
				end
			end
		end)
	end
	local commander_rect = recruiter_layout:next(ut.BASE_HEIGHT * 24 + spacing * 2, ut.BASE_HEIGHT * 3 + spacing * 2)
	draw_commander_panel(commander_rect)

	local left_rect = recruiter_layout:next(ut.BASE_HEIGHT * 5, ut.BASE_HEIGHT * 5)
	ui.panel(left_rect)
	left_rect:shrink(spacing)

	local status_rect = left_rect:subrect(0,0, left_rect.width, ut.BASE_HEIGHT * 3, "left", "up")
	local count_rect = left_rect:subrect(0, 0, left_rect.width, ut.BASE_HEIGHT, "left", "down")

	-- warband status
	ut.generic_string_field(
		"shrug.png",
		DATA.warband_status_get_name(DATA.warband_get_current_status(warband)),
		status_rect:subrect(0, 0, status_rect.width, ut.BASE_HEIGHT, "left", "up"),
		"This warband is currently " .. DATA.warband_status_get_name(DATA.warband_get_current_status(warband)) ..  ".",
		ut.NAME_MODE.ICON,
		true)

	-- work time ratio
	ut.generic_number_field(
		"chart.png",
		DATA.warband_get_current_time_used_ratio(warband),
		status_rect:subrect(0, 0, status_rect.width, ut.BASE_HEIGHT, "left", "center"),
		"Warriors in this warband are free for " .. ut.to_fixed_point2(DATA.warband_get_current_time_used_ratio(warband) * 100) .. "% of their time.",
		ut.NUMBER_MODE.PERCENTAGE,
		ut.NAME_MODE.ICON
	)

	-- warband morale
	ut.generic_number_field(
		"musical-notes.png",
		DATA.warband_get_morale(warband),
		status_rect:subrect(0, 0, status_rect.width, ut.BASE_HEIGHT, "left", "down"),
		"This warband is currently at " .. ut.to_fixed_point2(DATA.warband_get_morale(warband) * 100) .. "% morale.",
		ut.NUMBER_MODE.PERCENTAGE,
		ut.NAME_MODE.ICON)

	-- warband count and target
	local count = warband_utils.war_size(warband)
	local total_count = warband_utils.size(warband)
	local target_count = warband_utils.target_size(warband)
	local warband_count = count .. " / " .. target_count
	local target_plural = "s"
	if target_count == 1 then
		target_plural = ""
	end
	ut.generic_string_field(
		"minions.png",
		warband_count,
		count_rect:subrect(0, 0, status_rect.width, ut.BASE_HEIGHT, "left", "down"),
		"This warband is currently at " .. warband_count .. " warrior" .. target_plural ..".",
		ut.NAME_MODE.ICON,
		true)

	--- draws total strength values for warband based on warriors and officers
	---@param rect Rect
	local function draw_strength_panel(rect)
		-- warband count and target and strength calculations
		local total_health, total_attack, total_armor, _, count = warband_utils.total_strength(warband)
		local plural = "s"
		if count == 1 then
			plural = ""
		end

		local noncombatants = total_count - count
		local non_plural = "s"
		if noncombatants == 1 then
			non_plural = ""
		end

		-- WARBAND STRENGTH
		local avg_health, avg_armor, avg_attack  = math.max(total_health / count, 0), math.max(total_armor / count, 0), math.max(total_attack / count, 0)

		local strength_width = ut.BASE_HEIGHT * 3
		local strength_height = ut.BASE_HEIGHT
		local strength_layout = ui.layout_builder()
			:horizontal()
			:position(rect.x, rect.y)
			:spacing(0)
			:build()

		ui.text("Warband strength", strength_layout:next(ut.BASE_HEIGHT * 14 - spacing, strength_height), "right", "center")
		strength_layout:next(21, strength_height)

		-- total health
		ut.generic_number_field(
			"plus.png",
			total_health,
			strength_layout:next(strength_width, strength_height),
			"Each unit has an average of " .. ut.to_fixed_point2(avg_health)
				.. " from a total of " .. ut.to_fixed_point2(total_health)
				.. " from " .. count .. " warrior" .. plural .. ".",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON)
		-- total attack
		ut.generic_number_field(
			"stone-axe.png",
			total_attack,
			strength_layout:next(strength_width, strength_height),
			"Each unit has an average of " .. ut.to_fixed_point2(avg_attack)
				.. " from a total of " .. ut.to_fixed_point2(total_attack)
				.. " from " .. count .. " warrior" .. plural .. ".",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON)
		-- total armor
		ut.generic_number_field(
			"round-shield.png",
			total_armor,
			strength_layout:next(strength_width, strength_height),
			"Each unit has an average of " .. ut.to_fixed_point2(avg_armor)
				.. " from a total of " .. ut.to_fixed_point2(total_armor)
				.. " from " .. count .. " warrior" .. plural .. ".",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON)
		-- mean speed
		ut.generic_number_field(
			"fast-forward-button.png",
			avg_speed,
			strength_layout:next(strength_width, strength_height),
			"This warband has an speed of " .. ut.to_fixed_point2(avg_speed)
				.. ". This is a calculated average from a total of " .. ut.to_fixed_point2(total_speed)
				.. " from " .. count .. " warrior" .. plural .. " and " .. noncombatants .. " noncombatant" .. non_plural .. ".",
			ut.NUMBER_MODE.PERCENTAGE,
			ut.NAME_MODE.ICON)

		-- spotting and visibility
		local status = ""
		if DATA.warband_get_current_status(warband) == ESTATE_STATUS.IDLE then
			status = "\n - While the warband is idle, this bonus is multiplied by 5."
		end
		if DATA.warband_get_current_status(warband) ==  ESTATE_STATUS.PATROL then
			status = "\n - While the warband is on patrol, this bonus is multiplied by 10."
		end
		local unit_spotting = 0
		DATA.for_each_warband_unit_from_warband(warband, function (item)
			local unit_type = DATA.warband_unit_get_type(item)
			local pop = DATA.warband_unit_get_unit(item)
			unit_spotting = unit_spotting + pop_utils.get_spotting(pop)
		end)
		if recruiter ~= INVALID_ID and recruiter ~= commander then
			unit_spotting = unit_spotting + F_RACE(recruiter).spotting
		end
		if leader ~= INVALID_ID and leader ~= recruiter and leader ~= commander then
			unit_spotting = unit_spotting + F_RACE(leader).spotting
		end
		ut.generic_number_field(
			"magnifying-glass.png",
			warband_utils.spotting(warband),
			strength_layout:next(strength_width, strength_height),
			"This warband has normal spotting bonus of " .. ut.to_fixed_point2(unit_spotting)
				.. " from " .. count .. " warrior" .. plural .. " and " .. noncombatants .. " noncombatant" .. non_plural .. "."
				.. " This is weighted against opposing visibility for spotting other warbands and armies." .. status,
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON)
		local visibility = warband_utils.visibility(warband)
		ut.generic_number_field(
			"high-grass.png",
			visibility,
			strength_layout:next(strength_width, strength_height),
			"This warband has visibility of " .. ut.to_fixed_point2(visibility)
				.. " from " .. count .. " warrior" .. plural .. " and " .. noncombatants .. " noncombatant" .. non_plural .. "."
				.. " This is weighted against an opposing spotting bonus to avoid being spotted by other warbands and armies.",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON)

		-- supply cost and loot capacity
		local supply_use = warband_utils.daily_supply_consumption(warband)
		ut.generic_number_field(
			"sliced-bread.png",
			supply_use,
			strength_layout:next(strength_width, strength_height),
			"This warband uses " .. ut.to_fixed_point2(supply_use)
				.. " units of food per day of travel from " .. count .. " warrior" .. plural .. " and " .. noncombatants .. " noncombatant" .. non_plural .. ".",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON
		)
		local loot_capacity = warband_utils.loot_capacity(warband)
		ut.generic_number_field(
			"cardboard-box.png",
			loot_capacity,
			strength_layout:next(strength_width, strength_height),
			"This warband can haul up to " .. ut.to_fixed_point2(loot_capacity)
				.. " units of goods from " .. count .. " warrior" .. plural .. " and " .. noncombatants .. " noncombatant" .. non_plural .. ".",
			ut.NUMBER_MODE.NUMBER,
			ut.NAME_MODE.ICON
		)
	end

	local strength_panel = panel_layout:next(panel_width, ut.BASE_HEIGHT)
	draw_strength_panel(strength_panel)

	-- WARRIORS AND UNIT TYPES

	local icon_width = 20 -- for square item, aligns with icon
	local stat_width = 60 -- base height * 3, aligns with strenght stat render
	local name_width = 295 -- magic number for fixing cetner stat alignment
	local end_width = 90 -- magic number for fixing cetner stat alignment

	--- draws list of all warriors in warband
	---@param rect Rect
	local function draw_warrior_panel(rect)

		---@type table<POP, unit_type_id>
		local units = {}

		DATA.for_each_warband_unit_from_warband(warband, function (item)
			local unit_type = DATA.warband_unit_get_type(item)
			local pop = DATA.warband_unit_get_unit(item)
			units[pop] = unit_type
		end)

		-- CURRENT WARRIORS PANEL
		type_list_state = list_widget(
			rect,
			units,
			{
				{
					header = ".",
					---@param k POP
					---@param v unit_type_id
					render_closure = function (rect, k, v)
						if IS_CHARACTER(k) then
							ib.icon_button_to_character(gamescene, k, rect)
						else
							require "game.scenes.game.widgets.portrait"(rect, k)
						end
					end,
					width = icon_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return DATA.race_get_name(RACE(k))
					end
				},
				{
					header = "name",
					---@param k POP
					---@param v unit_type_id
					render_closure = function (rect, k, v)
						ui.text(NAME(k), rect, "center", "center")
					end,
					width = name_width - stat_width - icon_width * 5.5,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return NAME(k)
					end
				},
				{
					header = "sex",
					---@param k POP
					---@param v unit_type_id
					render_closure = function (rect, k, v)
						local f = "m"
						if DATA.pop_get_female(k) then
							f = "f"
						end
						ui.text(f, rect, "center", "center")
					end,
					width = icon_width * 1.5,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return tostring(DATA.pop_get_female(k))
					end
				},
				{
					header = "age",
					---@param k POP
					---@param v unit_type_id
					render_closure = function (rect, k, v)
						ui.text(tostring(AGE_YEARS(k)), rect, "center", "center")
					end,
					width = icon_width * 2,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return AGE_TICKS(k)
					end
				},
				{
					header = "savings",
					---@param k POP
					---@param v unit_type_id
					render_closure = function (rect, k, v)
						ut.money_entry(
							"",
							SAVINGS(k),
							rect,
							"Savings of this character. "
							.. "Characters spend them on buying food and other commodities."
						)
					end,
					width = stat_width,
					---@param v unit_type_id
					---@param k POP
					value = function (k, v)
						return SAVINGS(k)
					end
				},
				{
					header = "health",
					render_closure = pui.render_health,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return pop_utils.get_health(k)
					end
				},
				{
					header = "attack",
					render_closure = pui.render_attack,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return pop_utils.get_attack(k)
					end
				},
				{
					header = "armor",
					render_closure = pui.render_armor,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return pop_utils.get_armor(k)
					end
				},
				{
					header = "speed",
					render_closure = pui.render_speed,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return pop_utils.get_speed(k).base
					end
				},
				{
					header = "spotting",
					render_closure = pui.render_spotting,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return pop_utils.get_spotting(k)
					end
				},
				{
					header = "visibility",
					render_closure = pui.render_visibility,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return pop_utils.get_visibility(k)
					end
				},
				{
					header = "supply",
					render_closure = pui.render_supply_use,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return pop_utils.get_supply_use(k) / 30
					end
				},
				{
					header = "hauling",
					render_closure = pui.render_supply_capacity,
					width = stat_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return  pop_utils.get_supply_capacity(k)
					end
				},
				{
					header = "satisfac.",
					render_closure = pui.render_basic_needs_satsifaction,
					width = end_width - icon_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return DATA.pop_get_basic_needs_satisfaction(k)
					end
				},
				{
					header = "X",
					---@param k POP
					---@param v unit_type_id
					render_closure = function (rect, k, v)
						local icon = ASSETS.icons["cancel.png"]
						local text = "You do not have any control over this warband."
						local can_recruit = false
						if (player_character == INVALID_ID) then

						elseif warband == LEADER_OF_ESTATE(player_character) then
							can_recruit = true
						elseif warband == RECRUITER_OF_ESTATE(player_character) then
							can_recruit = true
						end

						if can_recruit then
							text = "Unrecruit this warrior!?"
						end
						if player_character ~= INVALID_ID then
							if ut.icon_button(icon, rect, text, can_recruit) then
								-- check if trying to fire commander first
								if commander ~= INVALID_ID and commander == k then
									demography_effects.unset_commander(warband)
								else
									demography_effects.unrecruit(warband, k)
								end
							end
						end
					end,
					width = icon_width,
					---@param k POP
					---@param v unit_type_id
					value = function (k, v)
						return NAME(k)
					end
				},
			},
			type_list_state, nil, true
		)()
	end
	local unit_panel = panel_layout:next(panel_width, panel.height - (ut.BASE_HEIGHT * 8 + spacing * 9))
	local unit_panel_layout = ui.layout_builder()
		:horizontal()
		:position(strength_panel.x, strength_panel.y)
		:build()
	unit_panel = unit_panel:subrect(0, 0, unit_panel.width, unit_panel.height, "left", "down")
	ui.panel(unit_panel)
	unit_panel:shrink(spacing)
	unit_panel_tab = ut.tabs(unit_panel_tab, unit_panel_layout, {
		{
			text = "WARRIOR",
			tooltip = "Show all warriors in this warband.",
			closure = function ()
				draw_warrior_panel(unit_panel)
			end
		},
		{
			text = "HIRE",
			tooltip = "Hire local warriors",
			closure = function ()
				if recruiter ~= player_character or recruiter == INVALID_ID then
					ui.text("No permission to hire units for this warband", unit_panel, "center", "center")
					return
				end
				local province = POP_PROVINCE(ESTATE_RECRUITER(warband))
				if province == INVALID_ID then
					ui.text("Can't hire units outside of settlement", unit_panel, "center", "center")
					return
				end
				local unemployed_pops = demography_values.unemployed_pops(POP_TILE(recruiter))
				local rows = 4
				local columns = math.floor((#unemployed_pops - 1) / rows + 1)
				local width = unit_panel.width / columns
				local height = unit_panel.height / rows
				local rect_for_item = ui.rect(0, 0, width, height)

				local index = 1

				for column = 1, columns do
					if unemployed_pops[index] == nil then
						break
					end
					for row = 1, rows do
						if unemployed_pops[index] == nil then
							break
						end
						rect_for_item.x = unit_panel.x + (column - 1) * width
						rect_for_item.y = unit_panel.y + (row - 1) * height
						ui.panel(rect_for_item)
						local portrait_rect = rect_for_item:copy():shrink(2)
						portrait_rect.width = portrait_rect.height
						portrait(portrait_rect, unemployed_pops[index])

						local info_rect = rect_for_item:copy():shrink(2)
						info_rect.x = portrait_rect.x + portrait_rect.width
						info_rect.width = info_rect.width - portrait_rect.width
						info_rect.height = info_rect.height / 2

						if ut.text_button(
							tostring(warband_utils.base_unit_price) .. MONEY_SYMBOL,
							info_rect,
							"Cost: " .. tostring(warband_utils.base_unit_price),
							SAVINGS(player_character) > warband_utils.base_unit_price
						) then
							demography_effects.recruit(unemployed_pops[index], warband, UNIT_TYPE.WARRIOR)
							economic_effects.gift_to_pop(
								player_character,
								unemployed_pops[index],
								warband_utils.base_unit_price
							)
						end

						info_rect.y = info_rect.y + info_rect.height

						ui.text_panel("W", info_rect)

						index = index + 1
					end
				end
			end
		}
	}, 1.25, ut.BASE_HEIGHT * 3)
end


return window