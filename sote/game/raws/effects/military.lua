local pathfinding = require "game.ai.pathfinding"

local warband_utils = require "game.entities.warband"
local province_utils = require "game.entities.province".Province
local realm_utils = require "game.entities.realm".Realm
local army_utils = require "game.entities.army"
local ut = require "game.ui-utils"

local economy_effects = require "game.raws.effects.economy"
local politics_effect = require "game.raws.effects.politics"
local warband_effects = require "game.raws.effects.warband"

local economy_values = require "game.raws.values.economy"
local military_values = require "game.raws.values.military"
local demography_effects = require "game.raws.effects.demography"

local MilitaryEffects = {}

---Gathers new warband in the name of *leader*
---@param leader Character
function MilitaryEffects.gather_warband(leader)
	local settlement = POP_PROVINCE(leader)
	local province = POP_PROVINCE(leader)
	if LEADER_OF_ESTATE(leader) ~= INVALID_ID then
		return
	end
	if RECRUITER_OF_ESTATE(leader) ~= INVALID_ID then
		return
	end
	if COMMANDER_OF_ESTATE(leader) ~= INVALID_ID then
		return
	end

	local warband = DATA.create_warband()
	if settlement ~= INVALID_ID then
		DATA.warband_set_in_settlement(warband,true)
		DATA.force_create_warband_location(DATA.province_get_center(province), warband)
	else -- otherwise pop is already in a warband and is starting one there
		DATA.force_create_warband_location(ESTATE_TILE(leader), warband)
	end
	DATA.warband_set_current_status(warband, ESTATE_STATUS.IDLE)
	DATA.warband_set_idle_stance(warband, WARBAND_STANCE.FORAGE)
	DATA.warband_set_name(warband, "Party of " .. NAME(leader))

	demography_effects.recruit(leader, warband, UNIT_TYPE.CIVILIAN)
	DATA.force_create_warband_leader(leader, warband)
	warband_effects.set_recruiter(warband, leader)

	if WORLD:does_player_see_realm_news(PROVINCE_REALM(province))
		or WORLD:does_player_see_province_news(province)
	then
		WORLD:emit_notification(NAME(leader) .. " is gathering his own party.")
	end
end

---Gathers new warband to guard the realm
---@param realm Realm
function MilitaryEffects.gather_guard(realm)
	local province = CAPITOL(realm)
	local warband = DATA.create_warband()
	DATA.force_create_warband_location(DATA.province_get_center(province), warband)
	DATA.warband_set_in_settlement(warband,true)
	DATA.warband_set_current_status(warband, ESTATE_STATUS.IDLE)
	DATA.warband_set_idle_stance(warband, WARBAND_STANCE.FORAGE)
	DATA.warband_set_name(warband, "Guard of " .. DATA.realm_get_name(realm))
	DATA.force_create_realm_guard(warband, realm)

	if WORLD:does_player_see_realm_news(PROVINCE_REALM(province))
		or WORLD:does_player_see_province_news(province)
	then
		WORLD:emit_notification(REALM_NAME(realm) .. " organised a new guard.")
	end
end

---Dissolve realm's guard
---@param realm Realm
function MilitaryEffects.dissolve_guard(realm)
	local guard = DATA.realm_guard_get_guard(DATA.get_realm_guard_from_realm(realm))

	if guard == INVALID_ID then
		return
	end
	local leader = LEADER(realm)
	DATA.for_each_trade_good(function (item)
		local amount = DATA.warband_get_inventory(guard,item)
		DATA.pop_inc_inventory(leader,item,amount)
	end)
	economy_effects.change_treasury(realm, -DATA.warband_get_treasury(guard), ECONOMY_REASON.WARBAND)
	-- place all pop into closest settlement
	DATA.for_each_warband_unit_from_warband(guard, function(item)
		local unit = DATA.warband_unit_get_unit(item)
		demography_effects.unrecruit(unit)
	end)
	DATA.delete_warband(guard)
	if WORLD:does_player_see_realm_news(realm) then
		WORLD:emit_notification("Realm's guard was dissolved.")
	end
end

---comment
---@param leader Character
function MilitaryEffects.dissolve_warband(leader)
	local warband = DATA.warband_leader_get_warband(DATA.get_warband_leader_from_leader(leader))
	if warband == INVALID_ID then
		return
	end
	local local_province = TILE_PROVINCE(ESTATE_TILE(warband))
	DATA.for_each_warband_unit_from_warband(warband, function (item)
		local unit = DATA.estate_unit_get_unit(item)
		DATA.force_create_estate_unit(local_province, unit)
		if (IS_CHARACTER(unit)) then
			DATA.force_create_character_location(local_province, unit)
		end
	end)
	DATA.for_each_trade_good(function (item)
		local amount = DATA.warband_get_inventory(warband,item)
		DATA.pop_inc_inventory(leader,item,amount)
	end)
	economy_effects.gift_to_warband(warband, leader, -DATA.warband_get_treasury(warband))
	DATA.delete_warband(warband)

	if WORLD:does_player_see_province_news(TILE_PROVINCE(ESTATE_TILE(warband))) then
		WORLD:emit_notification(NAME(leader) .. " dissolved his warband.")
	end
end

---Updates patrols and distributes patrol rewards across the entire realm
---@param root Realm
function MilitaryEffects.update_patrol(root)
	DATA.for_each_realm_provinces_from_realm(root, function (item)
		local province = DATA.realm_provinces_get_province(item)
		local total_patrol_size = 0
		DATA.for_each_warband_location_from_location(DATA.province_get_center(province), function (wloc)
			local warband = DATA.warband_location_get_warband(wloc)
			if (DATA.warband_get_current_status(warband) == ESTATE_STATUS.PATROL) then
				local size = warband_utils.size(warband)
				total_patrol_size = total_patrol_size + size
			end
		end)
		DATA.province_inc_mood(province, 0.001 * total_patrol_size)
		if total_patrol_size > 0 then
			local reward = 0
			local max_reward = DATA.realm_get_quests_patrol(root)[province]
			if max_reward then
				reward = math.min(max_reward, total_patrol_size)
				DATA.realm_get_quests_patrol(root)[province] = max_reward - reward
			end

			DATA.for_each_warband_location_from_location(DATA.province_get_center(province), function (wloc)
				local warband = DATA.warband_location_get_warband(wloc)
				local size = warband_utils.size(warband)
				DATA.warband_inc_treasury(warband, reward * size / total_patrol_size)
				assert(DATA.warband_get_treasury(warband) == DATA.warband_get_treasury(warband),
					"NAN TREASURY FROM PATROL SUCCESS"
					.. "\n reward: "
					.. tostring(reward)
					.. "\n size: "
					.. tostring(size)
					.. "\n total_patrol_size: "
					.. tostring(total_patrol_size)
				)
			end)
		end
	end)
end

---Raid on local settlement.
---If party doesn't try to hide, then battle is always initiated but rewards are as big as possible.
---If party tries to hide, then if party is spotted then it has to fight to get away and receives a battle penalty
---@param raider Character
---@param hide boolean
function MilitaryEffects.raid(raider, hide)
	local leadership = DATA.get_warband_leader_from_leader(raider)
	assert(leadership ~= INVALID_ID)
	local warband = DATA.warband_leader_get_warband(leadership)

	local tile = ESTATE_TILE(warband)
	local province = TILE_PROVINCE(tile)

	---print("center check")

	local center = DATA.province_get_center(province)
	if (center ~= tile) then
		return
	end

	---print("passed")

	if WORLD:does_player_see_realm_news(REALM(raider)) then
		WORLD:emit_notification(
			NAME(raider)
			.. " is raiding "
			.. DATA.province_get_name(province)
		)
	end

	local origin = REALM(raider)
	local retreat = false
	local success = false
	local losses = 0
	local realm = PROVINCE_REALM(province)
	local attacking_army = {warband}

	local spotted = false
	if hide and not province_utils.army_spot_test(province, attacking_army) and (province_utils.patrol_size(province) > 0) then
		spotted = true
	end
	if not hide then
		spotted = true
	end
	---print("spotted?:", spotted)
	if hide then
		if not spotted then
			success = true
		else
			success = false
			if realm and WORLD:does_player_see_realm_news(realm) then
				WORLD:emit_notification(NAME(raider)
				.. " attempted to raid us but they were spotted and backed down.")
			end
		end
	end


	if spotted then
		-- Battle time!
		-- First, raise the defending army.
		local def = realm_utils.available_defenders(realm, province)
		local attack_succeed, attack_losses, def_losses = MilitaryEffects.attack(attacking_army, def, true)
		losses = attack_losses
		if attack_succeed then
			success = true
			if WORLD:does_player_see_realm_news(realm) then
				WORLD:emit_notification("Our neighbor, " ..
					NAME(raider) ..
					", sent warriors to raid us. We lost " ..
					tostring(def_losses) ..
					" warriors and our enemies lost " ..
					tostring(attack_losses) .. " and our province was looted.")
			end
		else
			success = false
			if WORLD:does_player_see_realm_news(realm) then
				WORLD:emit_notification("Our neighbor, " ..
					NAME(raider) ..
					", sent warriors to raid us. We lost " ..
					tostring(def_losses) ..
					" warriors and our enemies lost " ..
					tostring(attack_losses) .. ". We managed to fight off the aggressors.")
			end
		end
	end

	---print("success: ", success)

	if success then
		-- Take their wealth, raid their stockpiles
		local max_loot = army_utils.loot_capacity(attacking_army)

		local real_loot = math.min(max_loot, DATA.province_get_local_wealth(province))
		economy_effects.change_local_wealth(province, -real_loot, ECONOMY_REASON.RAID)

		if realm ~= INVALID_ID and max_loot > real_loot then
			local leftover = max_loot - real_loot
			local potential_loot = economy_values.raidable_treasury(realm)
			local extra = math.min(potential_loot, leftover)
			economy_effects.change_treasury(realm, -extra, ECONOMY_REASON.RAID)
			real_loot = real_loot + extra
		end

		if real_loot ~= real_loot then
			error("NAN LOOT FROM RAID"
				.. "\n max_loot: "
				.. tostring(max_loot)
				.. "\n real_loot: "
				.. tostring(real_loot)
				.. "\n province.local_wealt: "
				.. tostring(DATA.province_get_local_wealth(province))
			)
		end

		---print(real_loot)

		politics_effect.mood_shift_from_wealth_shift(province, -real_loot)
		if realm ~= INVALID_ID then
			politics_effect.popularity_shift_scaled_with_wealth(raider, realm, -real_loot)
		end

		---@type RaidResultSuccess
		local success_data = {
			target = province,
			loot = real_loot,
			losses = losses,
			raider = raider,
			origin = origin
		}

		WORLD:emit_immediate_action(
			"covert-raid-success",
			raider,
			success_data
		)

		if WORLD:does_player_see_realm_news(realm) then
			WORLD:emit_notification("An unknown adversary raided our province " ..
				PROVINCE_NAME(province) ..
				" and stole " .. ut.to_fixed_point2(real_loot) .. MONEY_SYMBOL .. " worth of goods!")
		end
	else
		if retreat then
			---@type RaidResultRetreat
			local retreat_data = { target = province, raider = raider, origin = origin }
			WORLD:emit_immediate_action(
				"covert-raid-retreat",
				raider,
				retreat_data
			)
		else
			---@type RaidResultFail
			local retreat_data = {
				raider = raider,
				losses = losses,
				origin = origin
			}

			WORLD:emit_immediate_action(
				"covert-raid-fail",
				raider,
				retreat_data
			)
		end
	end
end

---Sends party toward target
---@param party estate_id
---@param target tile_id
function MilitaryEffects.send_party(party, target)
	local origin = DATA.warband_location_get_location(DATA.get_warband_location_from_warband(party))
	local _, path = pathfinding.pathfind(
		origin,
		target,
		military_values.estate_speed(party),
		DATA.realm_get_known_provinces(REALM(ESTATE_LEADER(party)))
	)
	if path then
		DATA.warband_set_current_path(party, path)
	end
end

---Fights a location, returns whether or not the attack was a success.
---@param attacker warband_id[]
---@param defender warband_id[]
---@param spotted boolean Set it to true if the army was spotted before battle, false otherwise.
---@return boolean success, number attacker_losses, number defender_losses
function MilitaryEffects.attack(attacker, defender, spotted)

	if #defender == 0 then
		return true, 0, 0
	end

	local atk_armor = 0
	local atk_speed = 0
	local atk_attack = 0
	local atk_hp = 0
	local atk_stack = 0
	for _, warband in pairs(attacker) do
		local health, attack, armor, speed, count = warband_utils.total_strength(warband)
		atk_armor = atk_armor + armor
		atk_attack = atk_attack + attack
		atk_speed = atk_speed + speed
		atk_hp = atk_hp + health
		atk_stack = atk_stack + count
	end
	if atk_stack == 0 then
		return false, 0, 0
	end
	atk_stack = math.max(1, atk_stack)

	atk_armor = atk_armor / atk_stack
	atk_speed = atk_speed / atk_stack
	atk_attack = atk_attack / atk_stack
	atk_hp = atk_hp / atk_stack

	local def_armor = 0
	local def_speed = 0
	local def_attack = 0
	local def_hp = 0
	local def_stack = 0
	for _, warband in pairs(defender) do
		local health, attack, armor, speed, count = warband_utils.total_strength(warband)
		def_armor = def_armor + armor
		def_attack = def_attack + attack
		def_speed = def_speed + speed
		def_hp = def_hp + health
		def_stack = def_stack + count
	end
	if def_stack == 0 then
		return true, 0, 0
	end
	def_stack = math.max(1, def_stack)

	def_armor = def_armor / def_stack
	def_speed = def_speed / def_stack
	def_attack = def_attack / def_stack
	def_hp = def_hp / def_stack

	local defender_advantage = 1.1
	if spotted then
		defender_advantage = defender_advantage + love.math.random() * 0.65
	end
	-- Expressed as fraction of the opposing army killed per "turn"
	local damage_attacker = math.max(1, atk_attack - def_armor) / math.max(1, def_hp * def_stack)
	local damage_defender = defender_advantage * math.max(1, def_attack - atk_armor) / math.max(1, atk_hp * atk_stack)

	-- The fraction of the army at which it will run away
	local stop_battle_threshold = 0.7
	-- 1 for square law, 0 for linear law
	local exponent = 0.1
	-- Forward Euler integration
	local power = 1
	local defpower = def_stack / atk_stack
	local victory = true
	-- print(power, defpower)
	while true do
		local dt = 0.5
		local p = power
		local dp = defpower
		power = power - damage_defender * dt * dp ^ exponent
		defpower = defpower - damage_attacker * dt * p ^ exponent

		-- print(power, defpower)

		if power < stop_battle_threshold then
			victory = false
			break
		end
		if defpower < stop_battle_threshold then
			break
		end
	end
	power = math.max(0, power)
	defpower = math.max(0, defpower)

	-- After the battle, kill people!
	--- fraction of people who survived
	local frac = power
	local def_frac = defpower / (def_stack / atk_stack)

	--- kill dead ones
	local losses = demography_effects.kill_off_army(attacker, 1 - frac)
	local def_losses = demography_effects.kill_off_army(defender, 1 - def_frac)
	return victory, losses, def_losses
end


return MilitaryEffects