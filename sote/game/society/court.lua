local tabb = require "engine.table"

local values = require "game.raws.values.ai_preferences"
local ef = require "game.raws.effects.economic"
local co = {}

---@param realm Realm
function co.run(realm)
	-- First, calculate court needs
	---@type number
	local con = 0
	-- Your court is nobles of your capital
	for _, character in pairs(realm.capitol.characters) do
		con = con + values.money_utility(character)
	end

	con = con * 10
	realm.budget.court.target = con

	-- Once we know the needed investment, handle investments
	local inv = realm.budget.court.to_be_invested
	local spillover = 0
	if inv > con then
		spillover = inv - con
	end
	-- If we're overinvested, remove a fraction above the invested amount
	inv = inv - spillover * 0.85

	-- Lastly, invest a fraction of the investment into actual investment
	local invested = inv * (1 / (12 * 7.5)) -- 7.5 years to invest everything
	realm.budget.court.to_be_invested 	= inv - invested
	realm.budget.court.budget 			= realm.budget.court.budget + invested

	-- Nobles get their share of a court wealth
	-- At the very end, apply some decay to present investment to prevent runaway growth
	local wealth_decay_rate = 1 - 1 / (12 * 6) -- 6 years to decay everything
	if realm.budget.court.budget > con then
		wealth_decay_rate = 1 - 1 / (12 * 4) -- 4 years to decay the part above the needed amount
	end
	local total_decay = (1 - wealth_decay_rate) * realm.budget.court.budget

	local nobles_amount = tabb.size(realm.capitol.characters)
	local nobles_wage = total_decay / (nobles_amount + 1)

	for _, character in pairs(realm.capitol.characters) do
		ef.add_pop_savings(character, nobles_wage, ef.reasons.Court)
	end

	realm.budget.court.budget = realm.budget.court.budget - total_decay
end

return co
