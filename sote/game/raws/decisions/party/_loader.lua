local utils = require "game.raws.raws-utils"
local Decision = require "game.raws.decisions"

local economic_values = require "game.raws.values.economy"

local military_effects = require "game.raws.effects.military"
local economic_effects = require "game.raws.effects.economy"

local demography_effects = require "game.raws.effects.demography"

local pretriggers = require "game.raws.triggers.tooltiped_triggers".Pretrigger

return function ()
	local base_gift_size = 20

	Decision.CharacterSelf:new_from_trigger_lists(
		'gather-party',
		"Gather a party",
		function(root)
			return "Gather my own party?"
		end,
		1/12, -- Once every year on average
		{
			pretriggers.not_busy, pretriggers.not_dependent,
			pretriggers.not_in_party
		},
		{
			pretriggers.not_in_party
		},
		function(root)
			military_effects.gather_warband(root)
		end,
		function(root)
			root = root
			if LEADER_OF_ESTATE(root) == INVALID_ID and HAS_TRAIT(root, TRAIT.WARLIKE) then
				return 1
			end

			if LEADER_OF_ESTATE(root) == INVALID_ID and HAS_TRAIT(root, TRAIT.TRADER) then
				return 1
			end

			if LEADER_OF_ESTATE(root) == INVALID_ID and RANK(root) == CHARACTER_RANK.CHIEF then
				return 1
			end

			return 0
		end
	)

	Decision.CharacterSelf:new_from_trigger_lists(
		'disband-party',
		"Disband my party",
		function(root)
			return "Disband my party?"
		end,
		0, -- AI never disbands
		{
			pretriggers.not_busy, pretriggers.leading_idle_party,
			pretriggers.leading_party
		},
		{
			pretriggers.leading_party
		},
		function(root)
			military_effects.dissolve_warband(root)
		end,
		function(root)
			return 0 -- AI never disbands
		end
	)

	Decision.CharacterSelf:new_from_trigger_lists(
		'leave-party',
		"Leave my current party",
		function(root)
			return "Leave " .. ESTATE_NAME(UNIT_OF(root)) .."?"
		end,
		1/12, -- Once every year on average
		{
			pretriggers.not_busy, pretriggers.not_dependent,
			pretriggers.is_in_party, pretriggers.not_leading_party
		},
		{
			pretriggers.is_in_party,pretriggers.not_leading_party
		},
		function(root)
			local warband = UNIT_OF(root)
			demography_effects.unrecruit(root)
			if WORLD:does_player_see_province_news(TILE_PROVINCE(ESTATE_TILE(warband))) then
				WORLD:emit_notification(NAME(root) .. " quit " .. DATA.warband_get_name(warband) .. ".")
			end
		end,
		function(root)
			-- follower only want to leave if in a settlement
			local province = POP_PROVINCE(root)
			if UNIT_TYPE_OF(root) == UNIT_TYPE.FOLLOWER and province ~= INVALID_ID then
				-- TODO get AI target province and leave if there?
				if province == HOME(root) then
					return 1
				end
			end
			return 0 -- AI only leaves with a reason
		end
	)

	Decision.CharacterSelf:new_from_trigger_lists(
		'change-unit-warrior',
		"Become a warrior in my party",
		function(root)
			return "Fight for " .. ESTATE_NAME(UNIT_OF(root))
		end,
		1/24, -- Once every 2 years on average
		{
			pretriggers.not_busy, pretriggers.not_unit_type(UNIT_TYPE.WARRIOR),
			pretriggers.is_in_party, pretriggers.not_unit_type(UNIT_TYPE.FOLLOWER)
		},
		{
			pretriggers.is_in_party, pretriggers.not_unit_type(UNIT_TYPE.FOLLOWER)
		},
		function(root)
			local warband = UNIT_OF(root)
			demography_effects.recruit(root, warband, UNIT_TYPE.WARRIOR)
		end,
		function(root)
			if HAS_TRAIT(root, TRAIT.WARLIKE)
				or HAS_TRAIT(root, TRAIT.AMBITIOUS)
				or HAS_TRAIT(root, TRAIT.HARDWORKER)
			then
				return 1
			end
			if HAS_TRAIT(root, TRAIT.CONTENT)
				or HAS_TRAIT(root, TRAIT.LAZY)
			then
				return 0
			end
			return 0.5
		end
	)

	Decision.CharacterSelf:new_from_trigger_lists(
		'change-unit-civilian',
		"Become a civilian in my party",
		function(root)
			return "Stop fighting with " .. ESTATE_NAME(UNIT_OF(root))
		end,
		1/24, -- Once every 2 years on average
		{
			pretriggers.not_busy, pretriggers.not_unit_type(UNIT_TYPE.CIVILIAN),
			pretriggers.is_in_party, pretriggers.not_unit_type(UNIT_TYPE.FOLLOWER)
		},
		{
			pretriggers.is_in_party, pretriggers.not_unit_type(UNIT_TYPE.FOLLOWER)
		},
		function(root)
			local warband = UNIT_OF(root)
			demography_effects.recruit(root, warband, UNIT_TYPE.CIVILIAN)
		end,
		function(root)
			if HAS_TRAIT(root, TRAIT.WARLIKE)
				or HAS_TRAIT(root, TRAIT.AMBITIOUS)
				or HAS_TRAIT(root, TRAIT.HARDWORKER)
			then
				return 1
			end
			if HAS_TRAIT(root, TRAIT.CONTENT)
				or HAS_TRAIT(root, TRAIT.LAZY)
			then
				return 0
			end
			return 0.5
		end
	)

	Decision.CharacterSelf:new_from_trigger_lists(
		'donate-wealth-party',
		"Donate wealth to your party.",
		function(root)
			return "Donate " .. require "game.ui-utils".to_fixed_point2(SAVINGS(root)/3) .. MONEY_SYMBOL .. " to " .. ESTATE_NAME(UNIT_OF(root))
		end,
		1/3, -- Once every 3 months on average
		{
			pretriggers.not_busy,
			pretriggers.is_in_party
		},
		{
			pretriggers.is_in_party
		},
		function(root)
			economic_effects.gift_to_warband(LEADER_OF_ESTATE(root), root, SAVINGS(root) / 3)
		end,
		function(root)
			if LEADER_OF_ESTATE(root) ~= INVALID_ID and DATA.warband_get_treasury(LEADER_OF_ESTATE(root)) < SAVINGS(root) / 2 then
				return 1
			end
			return 0
		end
	)

	Decision.CharacterSelf:new_from_trigger_lists(
		'buy-party-supplies',
		"Buy supplies",
		function(root)
			return "Try to buy a months worth of traveling supplies"
		end,
		1, -- Once every month on average
		{
			--tooltips
			pretriggers.not_busy, pretriggers.leading_idle_party, pretriggers.in_settlement,
			--visible
			pretriggers.leading_party
		},
		{
			--visible
			pretriggers.leading_party
		},
		function(root)
			--effect
			local party = UNIT_OF(root)
			local desire = require "game.entities.warband".daily_supply_consumption(party)*30
			local amount = economic_values.get_local_amount_of_use(POP_PROVINCE(root),CALORIES_USE_CASE)
			require "game.raws.effects.economy".party_buy_use(party, CALORIES_USE_CASE, math.min(amount,desire))
		end,
		function(root)
			-- ai
			if require "game.raws.values.economy".days_of_travel(UNIT_OF(root)) < DATA.warband_get_supplies_target_days(UNIT_OF(root)) then
				return 1
			end
			return 0
		end
	)

end
