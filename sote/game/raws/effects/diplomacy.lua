local economy_effects = require "game.raws.effects.economy"
local politics_effects = require "game.raws.effects.politics"
local realm_utils = require "game.entities.realm".Realm
local province_utils = require "game.entities.province".Province
local military_effects = require "game.raws.effects.military"
local message_effects = require "game.raws.effects.messages"

local effects = {}

---Sets the tributary relationship and explores provinces for the overlord
---@param overlord Realm
---@param tributary Realm
function effects.set_tributary(overlord, tributary)
	---print("set tributary", overlord, tributary)

	local tributary_is_overlord_of_overlord = false

	---@type realm_subject_relation_id
	local to_delete = INVALID_ID

	DATA.for_each_realm_subject_relation_from_subject(overlord, function (item)
		local overlord_of_overlord = DATA.realm_subject_relation_get_overlord(item)

		if overlord_of_overlord == tributary then
			to_delete = item
		end
	end)

	if to_delete ~= INVALID_ID then
		DATA.delete_realm_subject_relation(to_delete)
	end

	local new_rel = DATA.force_create_realm_subject_relation(overlord, tributary)
	DATA.realm_subject_relation_set_wealth_transfer(new_rel, true)

	realm_utils.explore(overlord, CAPITOL(tributary))

	DATA.province_inc_mood(CAPITOL(tributary), -0.05)
	DATA.province_inc_mood(CAPITOL(overlord), -0.05)


	if WORLD:does_player_see_realm_news(overlord) then
		WORLD:emit_notification(REALM_NAME(tributary) .. " now pays tribute to our tribe! Our people are rejoicing!")
	end

	if WORLD:does_player_see_realm_news(tributary) then
		WORLD:emit_notification("Our tribe now pays tribute to " .. REALM_NAME(overlord) .. ". Outrageous!")
	end

	-- clean up raiding rewards



	local old_reward_raid_overlord = DATA.realm_get_quests_raid(overlord)[CAPITOL(tributary)] or 0
	local old_patrol_reward_overlord = DATA.realm_get_quests_patrol(overlord)[CAPITOL(tributary)] or 0
	DATA.realm_get_quests_raid(overlord)[CAPITOL(tributary)] = 0
	DATA.realm_get_quests_patrol(overlord)[CAPITOL(tributary)] = old_patrol_reward_overlord + old_reward_raid_overlord

	local old_reward_raid_tributary = DATA.realm_get_quests_raid(tributary)[CAPITOL(overlord)] or 0
	local old_patrol_reward_tributary = DATA.realm_get_quests_patrol(overlord)[CAPITOL(tributary)] or 0
	DATA.realm_get_quests_raid(tributary)[CAPITOL(overlord)] = 0
	DATA.realm_get_quests_patrol(overlord)[CAPITOL(overlord)] = old_patrol_reward_tributary + old_reward_raid_tributary

	for _, item in pairs(DATA.realm_get_known_provinces(overlord)) do
		WORLD.provinces_to_update_on_map[item] = item
	end
	WORLD.realms_changed = true
end

---Removes the tributary relationship and explores provinces for the overlord
---@param overlord Realm
---@param tributary Realm
function effects.unset_tributary(overlord, tributary)
	---@type realm_subject_relation_id
	local to_delete = INVALID_ID

	DATA.for_each_realm_subject_relation_from_subject(tributary, function (item)
		local overlord_of_tributary = DATA.realm_subject_relation_get_overlord(item)

		if overlord_of_tributary == overlord then
			to_delete = item
		end
	end)

	if to_delete ~= INVALID_ID then
		DATA.delete_realm_subject_relation(to_delete)
	end

	for _, item in pairs(DATA.realm_get_known_provinces(overlord)) do
		WORLD.provinces_to_update_on_map[item] = item
	end
	WORLD.realms_changed = true
end

---Clears realm and its diplomatic status.
---Does not handle characters because it's very context-dependent
---and it's better to do it separately
---@param realm Realm
function effects.dissolve_realm_and_clear_diplomacy(realm)
	for _, item in pairs(DATA.realm_get_known_provinces(realm)) do
		WORLD.provinces_to_update_on_map[item] = item
	end
	WORLD.realms_changed = true

	politics_effects.dissolve_realm(realm)
end

---commenting
---@param character pop_id
function effects.enforce_tributary(character)
	local warband = LEADER_OF_ESTATE(character)
	if (warband == INVALID_ID) then
		print("effects.enforce_tributary invalid warband")
		return
	end
	local tile = ESTATE_TILE(warband)
	local province = TILE_PROVINCE(tile)
	local realm = PROVINCE_REALM(province)
	if realm == INVALID_ID then
		print("effects.enforce_tributary invalid local realm")
		-- The province doesn't have a realm
		return
	end
	if DATA.province_get_center(province) ~= ESTATE_TILE(warband) then
		return
	end

	-- Battle time!

	-- spot test
	-- it's an open attack, so our visibility is multiplied by 100
	local spot_test = province_utils.army_spot_test(province, {warband}, 100)

	-- First, raise the defending army.
	local def = realm_utils.available_defenders(realm, province)
	local attack_succeed, attack_losses, def_losses = military_effects.attack({warband}, def, spot_test)

	-- Message handling
	message_effects.tribute_raid(character, PROVINCE_REALM(province), attack_succeed, attack_losses, def_losses)

	-- setting tributary
	if attack_succeed then
		message_effects.tribute_raid_success(REALM(character), realm)
		effects.set_tributary(REALM(character), realm)
		DATA.province_inc_mood(CAPITOL(realm), 0.05)
		politics_effects.small_popularity_boost(character, REALM(character))
		WORLD:emit_immediate_event('request-tribute-army-returns-success-notification', character, {})
	else
		message_effects.tribute_raid_fail(REALM(character), realm)
		local mood = DATA.province_get_mood(CAPITOL(realm))
		DATA.province_set_mood(CAPITOL(realm), math.max(0, mood - 0.05))
		politics_effects.small_popularity_decrease(character, REALM(character))
		WORLD:emit_immediate_event("request-tribute-army-returns-fail-notification", character, {})
	end
end

return effects
