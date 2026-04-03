local ut = require "game.map-modes.utils"
local tile = require "game.entities.tile"

local ec = {}

function ec.carrying_capacity()
	ut.provincial_hue_map_mode(function(prov)
		return (DATA.province_get_foragers_limit(prov) - 5) / 50
	end)
end

function ec.tile_carrying_capacity()
	local cc = require "game.ecology.carrying-capacity".get_tile_carrying_capacity
	ut.simple_hue_map_mode(function(tile_id)
		return cc(tile_id) / 100
	end)
end

function ec.tile_forage_water()
	local forage_water = require "game.ecology.carrying-capacity".get_tile_forage_water
	ut.simple_hue_map_mode(function(tile_id)
		return forage_water(tile_id) / 30
	end)
end
function ec.tile_forage_plant()
	local forage_plant = require "game.ecology.carrying-capacity".get_tile_forage_plant
	ut.simple_hue_map_mode(function(tile_id)
		return forage_plant(tile_id) / 10
	end)
end
function ec.tile_forage_game()
	local forage_game = require "game.ecology.carrying-capacity".get_tile_forage_game
	ut.simple_hue_map_mode(function(tile_id)
		return forage_game(tile_id) / 10
	end)
end
function ec.tile_forage_fish()
	local forage_fish = require "game.ecology.carrying-capacity".get_tile_forage_fish
	ut.simple_hue_map_mode(function(tile_id)
		return forage_fish(tile_id) / 10
	end)
end
function ec.tile_forage_wood()
	local forage_wood = require "game.ecology.carrying-capacity".get_tile_forage_wood
	ut.simple_hue_map_mode(function(tile_id)
		return forage_wood(tile_id) / 10
	end)
end

function ec.plants()
	DATA.for_each_tile(function (tile_id)
		if DATA.tile_get_is_land(tile_id) then
			tile.set_real_color(
				tile_id,
				DATA.tile_get_shrub(tile_id),
				DATA.tile_get_grass(tile_id),
				DATA.tile_get_conifer(tile_id) + DATA.tile_get_broadleaf(tile_id)
			)
		else
			ut.set_default_color(tile_id)
		end
	end)
end

function ec.biomes()
	DATA.for_each_tile(function (tile_id)
		local biome = DATA.tile_get_biome(tile_id)
		if biome ~= INVALID_ID then
			local fat = DATA.fatten_biome(biome)
			tile.set_real_color(tile_id, fat.r, fat.g, fat.b)
		else
			ut.set_default_color(tile_id)
		end
	end)
end

return ec
