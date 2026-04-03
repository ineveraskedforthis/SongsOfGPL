local pg = {}

local pop_utils = require "game.entities.pop".POP
local province_utils = require "game.entities.province".Province
local tabb = require "engine.table"
local economy_values = require "game.raws.values.economy"
local economic_effects = require "game.raws.effects.economy"
local demography_effects = require "game.raws.effects.demography"


local min_life_need = 0.2
local death_rate = 0.04/12 -- 4% per year
local birth_rate = 0.07/12 -- 7% per year

---Runs natural growth and decay on all pops.
function pg.run()
	---#logging LOGS:write("province growth " .. tostring(province_id).."\n")
	---#logging LOGS:flush()

	-- Mark pops for removal...
	---@type POP[]
	local to_remove = {}
	---@type POP[]
	local to_add = {}

	-- local pops and characters
	---@type pop_id[]
	local pops_and_characters = {}
	DATA.for_each_pop(function (item)
		pg.check(item,to_add,to_remove)
	end)

	pg.add_remove(to_add,to_remove)
end

-- remove starving and old pops and add newborns
function pg.add_remove(to_add,to_remove)
	-- Kill old pops...
	for _, pp in pairs(to_remove) do
		-- there might be some repeats?
		-- do not delete pop twice
		if DCON.dcon_pop_is_valid(pp - 1) then
			if IS_CHARACTER(pp) then
				WORLD:emit_immediate_event("death", pp, POP_PROVINCE(pp))
			else
				demography_effects.kill_pop(pp)
			end
		end
	end

	-- Add new pops...
	for _, pp in pairs(to_add) do
		local character = IS_CHARACTER(pp)

		local race = DATA.pop_get_race(pp)
		local faith = DATA.pop_get_faith(pp)
		local rite = DATA.pop_get_rite(pp)
		local culture = DATA.pop_get_culture(pp)
		local fat_race = DATA.fatten_race(race)

		-- TODO figure out beter way to keep character count lower

		local newborn = INVALID_ID
		local birth_year = WORLD.year
		-- pop is born sometime between monthly ticks
		local birthtick = WORLD.current_tick_in_year -1-- math.random(0,WORLD.ticks_per_month)
		-- case where pop was calculated to have been born late december but spawns in january
		if birthtick < 0 then
			birthtick = birthtick + WORLD.ticks_per_year
			birth_year = birth_year - 1
		end

		local newborn = pop_utils.new(
			race,
			faith,
			rite,
			culture,
			love.math.random() > fat_race.males_per_hundred_females / (100 + fat_race.males_per_hundred_females),
			WORLD.year,
			birthtick
		)
--[[
		local year,month,day,hour,minute = BIRTHDATE(newborn)
		assert(year==WORLD.year,"FAILED TO STORE YEAR ".. year .. " ~= " .. WORLD.year .. " ( " .. birthtick .. " )")
		assert(month==WORLD.month,"FAILED TO STORE MONTH ".. month .. " ~= " .. WORLD.month .. " ( " .. birthtick .. " )")
		assert(day==WORLD.day,"FAILED TO STORE DAY ".. day .. " ~= " .. WORLD.day .. " ( " .. birthtick .. " )")
		assert(hour==WORLD.hour,"FAILED TO STORE HOUR " .. hour .. " ~= " .. WORLD.hour .. " ( " .. birthtick .. " )")
--]]

		local parent_home = HOME(pp)
		if parent_home ~= INVALID_ID then
			province_utils.set_home(parent_home, newborn)
		else -- if no home province, check for realm to asign
			local parent_realm = DATA.realm_pop_get_realm(DATA.get_realm_pop_from_pop(pp))
			if parent_realm ~= INVALID_ID then
				SET_REALM(newborn,parent_realm)
			end
		end
		local parent_location = POP_ESTATE(pp)
		local child_unit_type = parent_home == parent_location and UNIT_TYPE.CIVILIAN or UNIT_TYPE.FOLLOWER
		if parent_location ~= INVALID_ID then
			if character then
				province_utils.add_character(parent_location, newborn, child_unit_type)
			else
				require "game.raws.effects.warband".set_as_unit(parent_location, newborn, child_unit_type)
			end
		end

		DATA.force_create_parent_child_relation(pp, newborn)

		-- TODO move into new pop?
		-- set newborn to parents satisfaction
		for index = 1, MAX_NEED_SATISFACTION_POSITIONS_INDEX do
			local use_case = DATA.pop_get_need_satisfaction_use_case(pp, index)
			if use_case == 0 then
				break
			end
			local demanded = DATA.pop_get_need_satisfaction_demanded(pp, index)
			local consumed = DATA.pop_get_need_satisfaction_consumed(pp, index)
			local satisfaction_ratio = consumed / demanded
			local demanded_by_newborn = DATA.pop_get_need_satisfaction_demanded(newborn, index)

			DATA.pop_set_need_satisfaction_consumed(newborn, index, demanded_by_newborn * satisfaction_ratio)
		end

		if character then
			DATA.pop_set_rank(newborn, CHARACTER_RANK.NOBLE)
			WORLD:emit_immediate_event('character-child-birth-notification', pp, newborn)
		end
	end
end

---TODO add pregnancy flag and gestation length
---check pop for birth or death
function pg.check(pop,to_add,to_remove)
	assert(DCON.dcon_pop_is_valid(pop - 1), tostring(pop))
	local min_life_satisfaction = DATA.pop_get_life_needs_satisfaction(pop)
--[[
	for index = 1, MAX_NEED_SATISFACTION_POSITIONS_INDEX do
		local use_case = DATA.pop_get_need_satisfaction_use_case(pop, index)
		if use_case == 0 then
			break
		end
		local need = DATA.pop_get_need_satisfaction_need(pop, index)
		if DATA.need_get_life_need(need) then
			local demanded = DATA.pop_get_need_satisfaction_demanded(pop, index)
			local consumed = DATA.pop_get_need_satisfaction_consumed(pop, index)
			local ratio = consumed / demanded
			if min_life_satisfaction > ratio then
				min_life_satisfaction = ratio
			end
		end
	end
--]]
	local race = DATA.pop_get_race(pop)
	local age = AGE_YEARS(pop)
	local max_age = DATA.race_get_max_age(race)
	local teen_age = DATA.race_get_teen_age(race)
	local elder_age = DATA.race_get_elder_age(race)

	-- first remove all pop that reach max age
	if age > max_age then
		table.insert(to_remove, pop)
	-- next check for starvation
	elseif min_life_satisfaction < min_life_need then -- prevent births if not at least min life needs
		if (min_life_need - min_life_satisfaction) / min_life_need * love.math.random() < death_rate then
			table.insert(to_remove, pop)
		end
	elseif age >= elder_age then
		if love.math.random() < (max_age - age) / (max_age - elder_age) * death_rate then
			table.insert(to_remove, pop)
		end
	-- finally, pop is eligable to breed if old enough
	elseif age >= teen_age then
		-- teens and older adults have reduced chance to conceive
		local middle_age = DATA.race_get_middle_age(race)
		local adult_age = DATA.race_get_adult_age(race)
		local base = 1
		if age < adult_age then
			base = base * (age - teen_age) / (adult_age - teen_age)
		elseif age >= middle_age then
			base = base * (1 - (age - middle_age) / (elder_age - middle_age))
		end
		local fecundity = DATA.race_get_fecundity(race)
		if love.math.random() < base * birth_rate * fecundity * min_life_satisfaction then
			-- yay! spawn a new pop!
			table.insert(to_add, pop)
		end
	end

	-- province:validate_population()
end

return pg