local tabb = require "engine.table"

local economy_triggers = require "game.raws.triggers.economy"
local diplomacy_triggers =  require "game.raws.triggers.diplomacy"
local pathfinding = require "game.ai.pathfinding"
local military_values = require "game.raws.values.military"
local diplomacy_values = require "game.raws.values.diplomacy"
local politics_values = require "game.raws.values.politics"
local ai_values = require "game.raws.values.ai"
local realm_utils = require "game.entities.realm".Realm
local province_utils = require "game.entities.province".Province
local travel_effects = require "game.raws.effects.travel"
local economy_effects = require "game.raws.effects.economy"

local traveling = {}

function traveling.run()
	--- ai merchants travel around to sell and buy at good prices
	local index = WORLD.current_tick_in_month
	while index < DATA.estate_size do
		if DCON.dcon_estate_is_valid(index) then
			---@type estate_id
			local estate = index + 1
			local leader = ESTATE_LEADER(estate)
			if DATA.pop_get_is_player(leader) then
				goto continue
			end
			if DATA.estate_get_current_path(estate) ~= nil then
				goto continue
			end
			--- update them with a certain probability
			if (love.math.random() > 1 / 15) then
				goto continue
			end

			if DATA.pop_get_ai_data(leader) == nil then
				DATA.pop_set_ai_data(leader, {
					target_province = INVALID_ID,
					current_goal = AI_GOAL.IDLE
				})
			end

			local data = DATA.pop_get_ai_data(leader)

			---@type province_id
			local final_target = INVALID_ID

			if LEADER(REALM(leader)) == leader then
				--- try to subjugate someone
				if HAS_TRAIT(leader, TRAIT.AMBITIOUS) or HAS_TRAIT(leader, TRAIT.WARLIKE) then
					---@type Realm
					local realm = REALM(leader)

					local our_province = realm_utils.get_random_province(realm)

					if our_province ~= INVALID_ID then
						-- Once you target a province, try selecting a random neighbor
						local neighbor_province = province_utils.get_random_neighbor(our_province)
						if neighbor_province ~= nil then
							if PROVINCE_REALM(neighbor_province) ~= INVALID_ID then
								if not diplomacy_triggers.province_controlled_by(neighbor_province, realm) then
									final_target = neighbor_province
								end
							end
						end
					end

					-- if that still fails, try targetting a random tributaries neighbor
					if final_target == INVALID_ID then
						local random_tributary = diplomacy_values.sample_tributary(realm)
						if random_tributary ~= nil then
							local random_tributary_province = DATA.realm_get_capitol(random_tributary)
							local neighbor_province = province_utils.get_random_neighbor(random_tributary_province)
							if neighbor_province ~= nil and PROVINCE_REALM(neighbor_province) ~= INVALID_ID then
								if not diplomacy_triggers.province_controlled_by(neighbor_province, realm) then
									return politics_values.province_leader(neighbor_province), true
								end
							end
						end
					end
				end
			elseif HAS_TRAIT(leader, TRAIT.TRADER) then
				data.current_goal = AI_GOAL.TRADE

				--- find a good target to buy goods:
				---@type table<Province, Province>
				local targets = {}

				if CAPITOL(REALM(leader)) ~= INVALID_ID then
					targets[CAPITOL(REALM(leader))] = CAPITOL(REALM(leader))
				end

				DATA.for_each_province_neighborhood_from_origin(CAPITOL(REALM(leader)), function (item)
					local province = DATA.province_neighborhood_get_target(item)
					local realm = PROVINCE_REALM(province)
					if realm ~= INVALID_ID and economy_triggers.allowed_to_trade(leader, realm) then
						targets[province] = province
					end
				end)

				DATA.for_each_realm_subject_relation_from_subject(REALM(leader), function (item)
					local overlord = DATA.realm_subject_relation_get_overlord(item)
					if economy_triggers.allowed_to_trade(leader, overlord) then
						targets[CAPITOL(overlord)] = CAPITOL(overlord)
					end
				end)

				DATA.for_each_realm_subject_relation_from_overlord(REALM(leader), function (item)
					local subject = DATA.realm_subject_relation_get_subject(item)
					if economy_triggers.allowed_to_trade(leader, subject) then
						targets[CAPITOL(subject)] = CAPITOL(subject)
					end
				end)

				for _, reward in pairs(DATA.realm_get_quests_explore(REALM(leader))) do
					targets[_] = _
				end

				-- TODO: ADD TRADE AGREEMENTS AND ADD CAPITOLS OF REALMS WITH TRADE AGREEMENTS SIGNED AS POTENTIAL TARGETS HERE

				-- choose random target
				local target = tabb.random_select_from_set(targets)

				data.target_province = target
				final_target = target
			elseif HAS_TRAIT(leader, TRAIT.WARLIKE) then
				local target = ai_values.sample_raiding_target(leader)
				if target then
					data.target_province = target
					data.current_goal = AI_GOAL.RAID
					final_target = target
				else
					data.target_province = INVALID_ID
					data.current_goal = AI_GOAL.IDLE
				end
			end

			--- find path and start following it
			if final_target ~= INVALID_ID and final_target ~= nil then
				travel_effects.exit_settlement(leader)

				local hours, path = pathfinding.pathfind(
					ESTATE_TILE(estate),
					DATA.province_get_center(final_target),
					military_values.estate_speed(estate),
					DATA.realm_get_known_provinces(REALM(leader))
				)
				if path then
					table.insert(path, ESTATE_TILE(estate))
					DATA.estate_set_current_path(estate, path)
					DATA.estate_set_movement_progress(
						estate,
						pathfinding.tile_distance(ESTATE_TILE(estate), path[#path], military_values.estate_speed(estate))
					)
				end
			end

			::continue::
		end
		index = index + WORLD.ticks_per_month
	end
end

return traveling
