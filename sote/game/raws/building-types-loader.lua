local d = {}

local COST_WORKSHOP = 80
local COST_AREA = 35
local COST_MINE = 70
local COST_FARM = 50

function d.load()
	local BuildingType = require "game.raws.building-types"
	local prod = require "game.raws.raws-utils".production_method
	local tec = require "game.raws.raws-utils".technology
	local good = require "game.raws.raws-utils".trade_good
	local res = require "game.raws.raws-utils".resource

	BuildingType:new {
		name = "witch-doctor-garden",
		description = "witch-doctor's garden",
		icon = "hut.png",
		r = 0,
		g = 1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('witch-doctor'),
		construction_cost = COST_AREA * 10,
		archetype = BUILDING_ARCHETYPE.FARM,
		needed_infrastructure = 1,
		ai_weight = 1,
		required_resource = {},
		required_biome = {},
	}
	-- FORAGE WATER
	BuildingType:new {
		name = "water-carrier",
		description = "water carrier",
		icon = 'full-wood-bucket.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('water-carrier'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}

	-- FORAGE PLANT
	BuildingType:new {
		name = "forage-plant-berries",
		description = "foraging berries",
		icon = 'berries-bowl.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-plant-berries'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}
	BuildingType:new {
		name = "forage-plant-grain",
		description = "foraging seeds",
		icon = 'wheat.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-plant-grain'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}
	BuildingType:new {
		name = "forage-plant-tubers",
		description = "foraging tubers",
		icon = 'potato.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-plant-tubers'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}

	-- FORAGE GAME
	BuildingType:new {
		name = "forage-game-trap",
		description = "trapping game",
		icon = 'wolf-trap.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-game-trap'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}
	BuildingType:new {
		name = "forage-game-spear",
		description = "hunting game with spears",
		icon = 'stone-spear.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-game-spear'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}
	BuildingType:new {
		name = "forage-game-bow",
		description = "hunting game with bows",
		icon = 'bow-arrow.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-game-bow'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}

	-- FORAGE FISH
	BuildingType:new {
		name = "forage-fish-seaweed",
		description = "foraging for seaweed",
		icon = 'algae.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-fish-seaweed'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}
	BuildingType:new {
		name = "forage-fish-shellfish",
		description = "foraging for shellfish",
		icon = 'oyster.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-fish-shellfish'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}
	BuildingType:new {
		name = "forage-fish-spear",
		description = "fishing with spears",
		icon = 'stone-spear.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-fish-spear'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}

	-- FORAGE WOOD
	BuildingType:new {
		name = "forage-wood-timber",
		description = "foraging timber",
		icon = 'stone-spear.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-wood-timber'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}
	BuildingType:new {
		name = "forage-wood-bark",
		description = "foraging bark",
		icon = 'stone-spear.png',
		r = 0.1,
		g = 0.1,
		b = 1,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('forage-wood-bark'),
		construction_cost = COST_AREA,
		upkeep = 0.01,
		needed_infrastructure = 1,
		ai_weight = 0.05,
		required_resource = {},
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.GROUNDS
	}

	BuildingType:new {
		name = "flint-extraction",
		description = "flint extraction",
		icon = 'stone-stack.png',
		r = 0.3,
		g = 1.0,
		b = 0.5,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('flint-extraction'),
		required_resource = { res('flint') },
		construction_cost = 15,
		needed_infrastructure = 1,
		ai_weight = 20,
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.MINE
	}
	BuildingType:new {
		name = "blanks-knapping",
		description = "tool knapping",
		icon = 'rock.png',
		r = 0.3,
		g = 1.0,
		b = 0.5,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('blanks-knapping'),
		required_resource = {},
		construction_cost = COST_WORKSHOP,
		needed_infrastructure = 1,
		ai_weight = 1,
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.WORKSHOP
	}
	BuildingType:new {
		name = "obsidian-extraction",
		description = "obsidian extraction",
		icon = 'stone-stack.png',
		r = 0.3,
		g = 1.0,
		b = 0.5,
		unlocked_by = tec('paleolithic-knowledge'),
		production_method = prod('obsidian-extraction'),
		required_resource = { res('obsidian') },
		construction_cost = 15,
		needed_infrastructure = 1,
		ai_weight = 20,
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.MINE
	}
	BuildingType:new {
		name = "stone-extraction",
		description = "stone extraction",
		icon = 'stone-block.png',
		r = 0.8,
		g = 0.8,
		b = 0.8,
		unlocked_by = tec('dedicated-stonecutters'),
		production_method = prod('stone-extraction'),
		required_resource = { res('stone') },
		construction_cost = 50,
		needed_infrastructure = 1,
		ai_weight = 20,
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.MINE
	}
	BuildingType:new {
		name = 'brewery-grain',
		description = 'beer brewery',
		icon = 'beer-stein.png',
		r = 0.75,
		g = 0.42,
		b = 0.86,
		unlocked_by = tec('basic-fermentation'),
		production_method = prod('brewing-grain'),
		construction_cost = COST_WORKSHOP,
		archetype = BUILDING_ARCHETYPE.WORKSHOP,
		needed_infrastructure = 15,
		ai_weight = 3.5,
		required_resource = {},
		required_biome = {},
	}
	BuildingType:new {
		name = 'brewery-fruit',
		description = 'cider brewery',
		icon = 'beer-stein.png',
		r = 0.75,
		g = 0.42,
		b = 0.86,
		unlocked_by = tec('basic-fermentation'),
		production_method = prod('brewing-fruit'),
		construction_cost = COST_WORKSHOP,
		archetype = BUILDING_ARCHETYPE.WORKSHOP,
		needed_infrastructure = 15,
		ai_weight = 3.5,
		required_biome = {},
		required_resource = {}
	}

	-- ###################
	-- #  COPPER CHAINS  #
	-- ###################

	-- MINING
	BuildingType:new {
		name = 'native-copper-gathering',
		description = 'native copper gathering',
		icon = 'gold-nuggets.png',
		r = 0.56,
		g = 0.33,
		b = 0.02,
		unlocked_by = tec('early-metal-working'),
		production_method = prod('native-copper-gathering'),
		required_resource = { res('native-copper') },
		needed_infrastructure = 10,
		construction_cost = COST_MINE,
		ai_weight = 10,
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.MINE
	}
	BuildingType:new {
		name = 'surface-copper-mining',
		description = 'copper mine',
		icon = 'ore.png',
		r = 0.56,
		g = 0.33,
		b = 0.02,
		unlocked_by = tec('surface-mining'),
		production_method = prod('surface-copper-mining'),
		required_resource = { res('copper') },
		needed_infrastructure = 30,
		construction_cost = COST_MINE,
		ai_weight = 10,
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.MINE
	}
	BuildingType:new {
		name = 'copper-mining',
		description = 'copper mine',
		icon = 'ore.png',
		r = 0.56,
		g = 0.33,
		b = 0.02,
		unlocked_by = tec('fire-setting-mining'),
		production_method = prod('fire-copper-mining'),
		required_resource = { res('copper') },
		needed_infrastructure = 30,
		construction_cost = COST_MINE,
		ai_weight = 10,
		required_biome = {},
		archetype = BUILDING_ARCHETYPE.MINE
	}

	-- SMELT ORE
	BuildingType:new {
		name = 'copper-smelting',
		description = 'copper smelting',
		icon = 'metal-bar.png',
		r = 0.56,
		g = 0.33,
		b = 0.02,
		unlocked_by = tec('surface-mining'),
		production_method = prod('copper-smelting'),
		needed_infrastructure = 10,
		construction_cost = COST_WORKSHOP,
		ai_weight = 10,
		required_biome = {},
		required_resource = {},
		archetype = BUILDING_ARCHETYPE.WORKSHOP
	}

	-- MAKING TOOLS
	BuildingType:new {
		name = 'smith-tools-copper-native',
		description = 'native copper smiths',
		icon = 'anvil.png',
		r = 0.56,
		g = 0.33,
		b = 0.02,
		unlocked_by = tec('early-metal-working'),
		production_method = prod('smith-tools-copper-native'),
		needed_infrastructure = 15,
		construction_cost = COST_WORKSHOP,
		ai_weight = 10,
		required_biome = {},
		required_resource = {},
		archetype = BUILDING_ARCHETYPE.WORKSHOP
	}
	BuildingType:new {
		name = 'copper-smith-tools',
		description = 'copper tools smiths',
		icon = 'anvil.png',
		r = 0.56,
		g = 0.33,
		b = 0.02,
		unlocked_by = tec('surface-mining'),
		production_method = prod('smith-tools-copper-cast'),
		needed_infrastructure = 15,
		construction_cost = COST_WORKSHOP,
		ai_weight = 10,
		required_biome = {},
		required_resource = {},
		archetype = BUILDING_ARCHETYPE.WORKSHOP
	}
	BuildingType:new {
		name = 'clay-pit',
		description = 'clay pit',
		icon = 'powder.png',
		r = 0.26,
		g = 0.23,
		b = 0.22,
		unlocked_by = tec('pottery'),
		production_method = prod('clay-extraction'),
		needed_infrastructure = 3.5,
		ai_weight = 50,
		construction_cost = COST_MINE,
		required_biome = {},
		required_resource = {},
		archetype = BUILDING_ARCHETYPE.MINE
	}
	BuildingType:new {
		name = 'potterer',
		description = 'potterer',
		icon = 'amphora.png',
		r = 0.56,
		g = 0.23,
		b = 0.22,
		unlocked_by = tec('pottery'),
		production_method = prod('pottery'),
		needed_infrastructure = 10,
		ai_weight = 70,
		construction_cost = COST_WORKSHOP,
		archetype = BUILDING_ARCHETYPE.WORKSHOP,
		required_biome = {},
		required_resource = {},
	}
	BuildingType:new {
		name = 'woodcutters',
		description = 'woodcutters',
		icon = 'stone-axe.png',
		r = 0.26,
		g = 0.23,
		b = 0.62,
		unlocked_by = tec('dedicated-woodcutters'),
		production_method = prod('woodcutting'),
		needed_infrastructure = 5,
		ai_weight = 20,
		construction_cost = COST_AREA,
		archetype = BUILDING_ARCHETYPE.GROUNDS,
		required_biome = {},
		required_resource = {},
	}
	BuildingType:new {
		name = 'furniture-crafters',
		description = 'furniture crafters',
		icon = 'wooden-chair.png',
		r = 0.26,
		g = 0.73,
		b = 0.62,
		unlocked_by = tec('wooden-furniture'),
		production_method = prod('furniture'),
		needed_infrastructure = 25,
		ai_weight = 50,
		construction_cost = COST_WORKSHOP,
		archetype = BUILDING_ARCHETYPE.WORKSHOP,
		required_biome = {},
		required_resource = {},
	}
	BuildingType:new {
		name = 'tanners',
		description = 'tanners',
		icon = 'animal-hide.png',
		r = 1,
		g = 0.33,
		b = 0.33,
		unlocked_by = tec('vegetable-tanning'),
		production_method = prod('tanning'),
		needed_infrastructure = 25,
		ai_weight = 35,
		construction_cost = COST_WORKSHOP,
		archetype = BUILDING_ARCHETYPE.WORKSHOP,
		required_biome = {},
		required_resource = {},
	}
	BuildingType:new {
		name = 'leather-workers',
		description = 'leather workers',
		icon = 'kimono.png',
		r = 1,
		g = 0.73,
		b = 0.42,
		unlocked_by = tec('vegetable-tanning'),
		production_method = prod('leather-clothing'),
		needed_infrastructure = 25,
		ai_weight = 50,
		construction_cost = COST_WORKSHOP,
		archetype = BUILDING_ARCHETYPE.WORKSHOP,
		required_biome = {},
		required_resource = {},
	}
	BuildingType:new {
		name = 'rye-farm',
		description = 'rye farm',
		icon = 'wheat.png',
		r = 0.16,
		g = 0.43,
		b = 0.02,
		unlocked_by = tec('agriculture'),
		production_method = prod('rye-farming'),
		required_resource = {},
		needed_infrastructure = 2.5,
		ai_weight = 50,
		construction_cost = COST_FARM,
		archetype = BUILDING_ARCHETYPE.FARM,
		required_biome = {},
	}
	BuildingType:new {
		name = 'beehive',
		description = 'beehive',
		icon = 'high-grass.png',
		r = 0.86,
		g = 0.83,
		b = 0.02,
		unlocked_by = tec('beekeeping'),
		production_method = prod('beekeeping'),
		required_resource = { res("bees") },
		needed_infrastructure = 0.5,
		ai_weight = 150,
		construction_cost = COST_FARM,
		archetype = BUILDING_ARCHETYPE.FARM,
		required_biome = {},
	}
end

return d
