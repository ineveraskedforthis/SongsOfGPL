local car = {}

local dbm = require "game.economy.diet-breadth-model"

---Returns food carrying capacity for humans, for a tile
---@param tile_id tile_id
---@return number
function car.get_tile_carrying_capacity(tile_id)
	local _, primary_production, game_production, marine_production, _ = require "game.economy.diet-breadth-model".total_production(tile_id)
	local cc = primary_production + game_production + marine_production
	return cc
end

---Returns amount of forageable water, for a tile
---@param tile_id tile_id
---@return number
function car.get_tile_forage_water(tile_id)
	return DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.WATER)
end
---Returns amount of forageable plants, for a tile
---@param tile_id tile_id
---@return number
function car.get_tile_forage_plant(tile_id)
	return DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.PLANT)
end
---Returns amount of forageable game, for a tile
---@param tile_id tile_id
---@return number
function car.get_tile_forage_game(tile_id)
	return DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.GAME)
end
---Returns amount of forageable fish, for a tile
---@param tile_id tile_id
---@return number
function car.get_tile_forage_fish(tile_id)
	return DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.FISH)
end
---Returns amount of forageable wood, for a tile
---@param tile_id tile_id
---@return number
function car.get_tile_forage_wood(tile_id)
	return DATA.tile_get_foragers_targets_limit(tile_id,FORAGE_RESOURCE.WOOD)
end

function car.calculate()
	DCON.update_foraging_data(WORLD.world_size)
end

return car
