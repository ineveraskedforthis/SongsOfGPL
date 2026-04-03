local Event = require "game.raws.events"
local event_utils = require "game.raws.events._utils"
local ut = require "game.ui-utils"
local economic_effects = require "game.raws.effects.economy"
local pe = require "game.raws.effects.politics"

---@class (exact) PatrolData
---@field defender Character
---@field origin Realm
---@field patrol table<Warband, Warband>

---@class (exact) RaidData
---@field raider Character
---@field origin Realm

---@class (exact) AttackData
---@field raider Character

---@class (exact) RaidResultSuccess
---@field raider Character
---@field origin Realm
---@field losses number
---@field loot number

---@class (exact) RaidResultFail
---@field raider Character
---@field origin Realm
---@field losses number

---@class (exact) RaidResultRetreat
---@field raider Character
---@field origin Realm


local function load()
	event_utils.notification_event(
		"request-tribute-army-returns-success-notification",
		function(self, character, associated_data)
			return "We succeeded in enforcing tribute on " .. REALM_NAME(PROVINCE_REALM(TILE_PROVINCE(ESTATE_TILE(LEADER_OF_ESTATE(character)))))
		end,
		function(root, associated_data)
			return "Great!"
		end,
		function(root, associated_data)
			return ""
		end
	)

	event_utils.notification_event(
		"request-tribute-army-returns-fail-notification",
		function(self, character, associated_data)
			return "We failed to enforce tribute on " .. REALM_NAME(PROVINCE_REALM(TILE_PROVINCE(ESTATE_TILE(LEADER_OF_ESTATE(character)))))
		end,
		function(root, associated_data)
			return "Whatever. We will succeed next time"
		end,
		function(root, associated_data)
			return ""
		end
	)

	Event:new {
		name = "covert-raid-fail",
		event_background_path = "data/gfx/backgrounds/background.png",
		automatic = false,
		base_probability = 0,
		fallback = function (self, associated_data)
        end,
		on_trigger = function(self, root, associated_data)
			---@type RaidResultFail
			associated_data = associated_data
			local raider = associated_data.raider
			local realm = associated_data.origin
			local losses = associated_data.losses

			if WORLD:does_player_see_realm_news(realm) then
				WORLD:emit_notification("Raid attempt of " .. NAME(raider) .. " in " ..
					PROVINCE_NAME(TILE_PROVINCE(ESTATE_TILE(LEADER_OF_ESTATE(raider)))) .. " failed. " .. tostring(losses) .. " warriors died. People are upset.")
			end
		end,
	}
	Event:new {
		name = "covert-raid-success",
		event_background_path = "data/gfx/backgrounds/background.png",
		automatic = false,
		base_probability = 0,
		fallback = function (self, associated_data)
        end,
		trigger = function(self, root) return false end,
		on_trigger = function(self, root, associated_data)
			---@type RaidResultSuccess
			associated_data = associated_data
			local realm = associated_data.origin
			local loot = associated_data.loot
			local losses = associated_data.losses
			local raider = associated_data.raider
			local target = TILE_PROVINCE(ESTATE_TILE(LEADER_OF_ESTATE(raider)))

			if loot ~= loot then
				error("NAN TREASURY FROM RAID SUCCESS"
				.. "\n realm: "
				.. tostring(REALM_NAME(realm))
				.. "\n loot: "
				.. tostring(loot)
				.. "\n losses: "
				.. tostring(losses)
			)
			end

			local max_reward = DATA.realm_get_quests_raid(realm)[target] or 0
			local quest_reward = math.min(loot * 0.5, max_reward)
			DATA.realm_get_quests_raid(realm)[target] = max_reward - quest_reward

			-- save total loot for future
			local total_loot = loot

			-- pay quest rewards to warband leaders
			economic_effects.add_pop_savings(
				raider,
				quest_reward,
				ECONOMY_REASON.QUEST
			)

			local w = LEADER_OF_ESTATE(raider)

			-- half of loot goes to warbands
			DATA.warband_inc_treasury(w, loot * 0.5)
			if DATA.warband_get_treasury(w) ~= DATA.warband_get_treasury(w) then
				error("NAN TREASURY FROM RAID SUCCESS"
				.. "\n loot: "
				.. tostring(loot)
				)
			end
			-- half goes directly to leader
			economic_effects.add_pop_savings(
				raider,
				loot * 0.5,
				ECONOMY_REASON.RAID
			)

			if WORLD:does_player_see_realm_news(realm) then
				WORLD:emit_notification("Our raid in " .. PROVINCE_NAME(target) .. " succeeded. Raiders stole " ..
					ut.to_fixed_point2(total_loot) .. MONEY_SYMBOL .. " worth of loot. " ..
					' Warband leaders were additionally rewarded with ' ..
					ut.to_fixed_point2(quest_reward) .. MONEY_SYMBOL .. '. '
					.. tostring(losses) .. " warriors died.")
			end
		end,
	}

	Event:new {
		name = "covert-raid-retreat",
		event_background_path = "data/gfx/backgrounds/background.png",
		automatic = false,
		base_probability = 0,
		fallback = function (self, associated_data)
        end,
		on_trigger = function(self, root, associated_data)
			---@type RaidResultRetreat
			associated_data = associated_data
			local realm = associated_data.origin

			if WORLD:does_player_see_realm_news(realm) then
				WORLD:emit_notification("Our raid attempt in " ..
					PROVINCE_NAME(TILE_PROVINCE(ESTATE_TILE(LEADER_OF_ESTATE(associated_data.raider)))) .. " failed. We were spotted but our warriors are safe")
			end
		end,
	}
end

return load
