local emp = {}
local demography_effects = require "game.raws.effects.demography"

---Update pops employment for all buildings.
function emp.run()
	--- check if some contracts are expired
	---@type pop_id[]
	local fire_list = {}
	DATA.for_each_building(function (building)
		local employment = DATA.get_employment_from_building(building)
		local start = DATA.employment_get_start_date(employment)
		local now = WORLD.day + WORLD.month * 30 + WORLD.year * 12 * 30
		if now - start > 12 * 30 * EMPLOYMENT_YEARS then
			table.insert(fire_list, DATA.employment_get_worker(employment))
		end
	end)

	for _, value in ipairs(fire_list) do
		demography_effects.fire_pop(value)
	end
end

return emp
