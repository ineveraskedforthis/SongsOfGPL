local Decision = require "game.raws.decisions"
local pretriggers = require "game.raws.triggers.tooltiped_triggers".Pretrigger

return function ()
	Decision.CharacterSelf:new_from_trigger_lists (
		"collect-tribute", "Collect tribute",
		function(root, primary_target)
			return "Request payment from the local tributary."
		end,
		1/25,
		{
			pretriggers.not_busy, pretriggers.is_tribute_collector, pretriggers.is_at_tributary_capital
		},
		{},
		function(root)
			---@type TributeCollection
			local associated_data = {
				origin = REALM(root),
				target = PROVINCE_REALM(POP_PROVINCE(root)),
				tribute = 0,
				trade_goods_tribute = {}
			}

			WORLD:emit_immediate_action(
				'tribute-collection-1',
				root,
				associated_data
			)
		end,
		function(root)
			return DATA.realm_get_budget_budget(PROVINCE_REALM(POP_PROVINCE(root)), BUDGET_CATEGORY.TRIBUTE) / 20
		end
	)

	Decision.CharacterSelf:new_from_trigger_lists (
		"collect-tax", "Collect tax",
		function(root, primary_target)
			return "Collect taxes from local population."
		end,
		1/25,
		{
			pretriggers.not_busy, pretriggers.is_tribute_collector, pretriggers.at_core_realm_province
		},
		{},
		function(root)
			WORLD:emit_immediate_event(
				'tax-collection-1',
				root,
				{}
			)
		end,
		function(root)
			local tax_target = DATA.realm_get_budget_tax_target(REALM(root))
			local tax_collected = DATA.realm_get_budget_tax_collected_this_year(REALM(root))
			return tax_target - tax_collected
		end
	)
end