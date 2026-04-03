

local d = {}

function d.load()
	local ProductionMethod = require "game.raws.production-methods"
	local job = require "game.raws.raws-utils".job
	local good = require "game.raws.raws-utils".trade_good
	local retrieve_good = require "game.raws.raws-utils".trade_good
	local retrieve_use_case = require "game.raws.raws-utils".trade_good_use_case

	-- Keep in mind that outputs are per worker already!
	ProductionMethod:new {
		name = "witch-doctor",
		description = "witch doctor",
		icon = "hut.png",
		r = 0,
		g = 1,
		b = 1,
		inputs = { },
		outputs = { [retrieve_good("healthcare")] = 1 },
		job = job("shamans"),
		job_type = JOBTYPE.CLERK,
		self_sourcing_fraction = 0.25,
		nature_yield_dependence = 1,
	}

	-- FORAGING METHODS
	-- WATER
	ProductionMethod:new {
		name = "water-carrier",
		description = "water carrier",
		icon = "droplets.png",
		r = 0.1,
		g = 0.1,
		b = 1,
		inputs = { [retrieve_use_case("containers")] = 1 },
		outputs = { [retrieve_good("water")] = 1 },
		job = job("water-carriers"),
		job_type = JOBTYPE.HAULING,
		foraging = FORAGE_RESOURCE.WATER,
		self_sourcing_fraction = 0.25,
	}
	-- PLANT
	ProductionMethod:new {
		name = "forage-plant-berries",
		description = "foraging wild fruit",
		icon = "berries-bowl.png",
		r = 0.1,
		g = 1,
		b = 0.1,
		inputs = { },
		outputs = { [retrieve_good("berries")] = 1 },
		job = job("gatherers"),
		job_type = JOBTYPE.FORAGER,
		foraging = FORAGE_RESOURCE.PLANT,
	}
	ProductionMethod:new {
		name = "forage-plant-tubers",
		description = "digging for edible roots",
		icon = "potato.png",
		r = 0.1,
		g = 1,
		b = 0.1,
		inputs = { [retrieve_use_case("tools-like")] = 0.5 },
		outputs = { [retrieve_good("tubers")] = 1 },
		job = job("gatherers"),
		job_type = JOBTYPE.LABOURER,
		self_sourcing_fraction = 0.5,
		foraging = FORAGE_RESOURCE.PLANT,
	}
	ProductionMethod:new {
		name = "forage-plant-grain",
		description = "foraging wild seeds",
		icon = "wheat.png",
		r = 0.1,
		g = 1,
		b = 0.1,
		inputs = { [retrieve_use_case("containers")] = 1 },
		outputs = { [retrieve_good("grain")] = 1 },
		job = job("gatherers"),
		job_type = JOBTYPE.FARMER,
		self_sourcing_fraction = 0.25,
		foraging = FORAGE_RESOURCE.PLANT,
	}
	-- GAME
	ProductionMethod:new {
		name = "forage-game-spear",
		description = "hunting with spears",
		icon = "stone-spear.png",
		r = 1,
		g = 0.2,
		b = 0.3,
		inputs = { [retrieve_use_case("tools-like")] = 0.5 },
		outputs = { [retrieve_good("meat")] = 1, [retrieve_good("hide")] = 0.5 },
		job = job("hunters"),
		job_type = JOBTYPE.HUNTING,
		self_sourcing_fraction = 0.5,
		foraging = FORAGE_RESOURCE.GAME,
	}
	ProductionMethod:new {
		name = "forage-game-trap",
		description = "trapping game",
		icon = "wolf-trap.png",
		r = 1,
		g = 0.2,
		b = 0.3,
		inputs = { [retrieve_use_case("structural-material")] = 0.5 },
		outputs = { [retrieve_good("meat")] = 1, [retrieve_good("hide")] = 1 },
		job = job("hunters"),
		job_type = JOBTYPE.ARTISAN,
		self_sourcing_fraction = 0.25,
		foraging = FORAGE_RESOURCE.GAME,
	}
	ProductionMethod:new {
		name = "forage-game-bow",
		description = "hunting with bows",
		icon = "bow-arrow.png",
		r = 1,
		g = 0.2,
		b = 0.3,
		inputs = { [retrieve_use_case("tools")] = 0.25 },
		outputs = { [retrieve_good("meat")] = 1, [retrieve_good("hide")] = 1 },
		job = job("hunters"),
		job_type = JOBTYPE.WARRIOR,
		self_sourcing_fraction = 0.25,
		foraging = FORAGE_RESOURCE.GAME,
	}
	-- FISH
	ProductionMethod:new {
		name = "forage-fish-seaweed",
		description = "foraging seaweed",
		icon = "algae.png",
		r = 0.1,
		g = 0.1,
		b = 1,
		inputs = { },
		outputs = { [retrieve_good("seaweed")] = 1 },
		job = job("fishers"),
		job_type = JOBTYPE.LABOURER,
		foraging = FORAGE_RESOURCE.FISH,
	}
	ProductionMethod:new {
		name = "forage-fish-shellfish",
		description = "shucking shellfish",
		icon = "oyster.png",
		r = 0.1,
		g = 0.1,
		b = 1,
		inputs = { [retrieve_use_case("tools-like")] = 0.5 },
		outputs = { [retrieve_good("shellfish")] = 1, [retrieve_good("shells")] = 1 },
		job = job("fishers"),
		job_type = JOBTYPE.LABOURER,
		self_sourcing_fraction = 0.5,
		foraging = FORAGE_RESOURCE.FISH,
	}
	ProductionMethod:new {
		name = "forage-fish-spear",
		description = "spear fishing",
		icon = "stone-spear.png",
		r = 0.1,
		g = 0.1,
		b = 1,
		inputs = { [retrieve_use_case("tools")] = 0.25 },
		outputs = { [retrieve_good("fish")] = 1 },
		job = job("fishers"),
		job_type = JOBTYPE.HUNTING,
		self_sourcing_fraction = 0.25,
		foraging = FORAGE_RESOURCE.FISH,
	}
	-- WOOD
	ProductionMethod:new {
		name = "forage-wood-timber",
		description = "foraging for timber",
		icon = "wood-pile.png",
		r = 1,
		g = 0.2,
		b = 0.3,
		inputs = { },
		outputs = { [retrieve_good("timber")] = 1 },
		job = job("woodcutters"),
		job_type = JOBTYPE.LABOURER,
		foraging = FORAGE_RESOURCE.WOOD,
	}
	ProductionMethod:new {
		name = "forage-wood-bark",
		description = "forage for edible bark",
		icon = "birch-trees.png",
		r = 1,
		g = 0.2,
		b = 0.3,
		inputs = { [retrieve_use_case("tools-like")] = 0.5 },
		outputs = { [retrieve_good("bark")] = 1 },
		job = job("woodcutters"),
		job_type = JOBTYPE.ARTISAN,
		self_sourcing_fraction = 0.25,
		foraging = FORAGE_RESOURCE.WOOD,
	}

	-- STONE TOOL CHAIN
	ProductionMethod:new {
		name = "flint-extraction",
		description = "flint extraction",
		icon = "stone-stack.png",
		r = 0.1,
		g = 1,
		b = 0.1,
		inputs = {},
		outputs = { [retrieve_good("blanks-flint")] = 4 },
		job = job("knappers"),
		job_type = JOBTYPE.LABOURER,
	}
	ProductionMethod:new {
		name = "blanks-knapping",
		description = "flint knapping",
		icon = "rock.png",
		r = 0.1,
		g = 1,
		b = 0.1,
		inputs = { [retrieve_use_case("blanks-core")] = 0.5 }, -- one blank can make 8 tools - made up value
		outputs = { [retrieve_good("tools-blanks")] = 4 },
		job = job("knappers"),
		job_type = JOBTYPE.ARTISAN,
		self_sourcing_fraction = 0.125,
	}
	ProductionMethod:new {
		name = "obsidian-extraction",
		description = "obsidian extraction",
		icon = "stone-stack.png",
		r = 0.1,
		g = 1,
		b = 0.1,
		inputs = {},
		outputs = { [retrieve_good("blanks-obsidian")] = 4 },
		job = job("knappers"),
		job_type = JOBTYPE.LABOURER,
	}

	-- LIQUOR
	ProductionMethod:new {
		name = "brewing-grain",
		description = "ale, beer made with hops or rarer ingredients",
		icon = "beer-stein.png",
		r = 0.7,
		g = 0.36,
		b = 0.9,
		inputs = { [retrieve_use_case("grain")] = 4, [retrieve_use_case("water")] = 2 },
		outputs = { [retrieve_good("liquors")] = 4 },
		job = job("brewers"),
		job_type = JOBTYPE.ARTISAN,
	}
	ProductionMethod:new {
		name = "brewing-fruit",
		description = "cider or wine made with fermented fruits",
		icon = "beer-stein.png",
		r = 0.7,
		g = 0.36,
		b = 0.9,
		inputs = { [retrieve_use_case("fruit")] = 4 },
		outputs = { [retrieve_good("liquors")] = 4 },
		job = job("brewers"),
		job_type = JOBTYPE.ARTISAN,
	}

	-- COPPER PRODUCTION CHAIN

	ProductionMethod:new {
		name = "native-copper-gathering",
		description = "mining native ore close to the surface",
		icon = "gold-nuggets.png",
		r = 0.65,
		g = 0.65,
		b = 0.65,
		inputs = { [retrieve_use_case("tools")] = 0.25 },
		outputs = { [retrieve_good("copper-native")] = 2 },
		job = job("miners"),
		job_type = JOBTYPE.LABOURER,
	}
	ProductionMethod:new {
		name = "surface-copper-mining",
		description = "mining ore close to the surface",
		icon = "ore.png",
		r = 0.65,
		g = 0.65,
		b = 0.65,
		inputs = { [retrieve_use_case("tools")] = 0.25 },
		outputs = { [retrieve_good("copper-ore")] = 2 },
		job = job("miners"),
		job_type = JOBTYPE.LABOURER,
	}
	ProductionMethod:new {
		name = "fire-copper-mining",
		description = "mining ore with help of fire",
		icon = "ore.png",
		r = 0.65,
		g = 0.65,
		b = 0.65,
		inputs = { [retrieve_use_case("tools")] = 0.25, [retrieve_use_case("fuel")] = 1 },
		outputs = { [retrieve_good("copper-ore")] = 5 },
		job = job("miners"),
		job_type = JOBTYPE.LABOURER,
	}
	ProductionMethod:new {
		name = "copper-smelting",
		description = "smelting copper ore",
		icon = "metal-bars.png",
		r = 0.65,
		g = 0.65,
		b = 0.65,
		inputs = { [retrieve_use_case("copper-source")] = 5, [retrieve_use_case("fuel")] = 4, [retrieve_use_case("structural-material")] = 1 },
		outputs = { [retrieve_good("copper-bars")] = 5 },
		job = job("smelters"),
		job_type = JOBTYPE.ARTISAN,
	}
	ProductionMethod:new {
		name = "smith-tools-copper-native",
		description = "forming native copper into tools",
		icon = "anvil.png",
		r = 0.65,
		g = 0.65,
		b = 0.65,
		inputs = { [retrieve_use_case("copper-native")] = 1, [retrieve_use_case("tools")] = 1 },
		outputs = { [retrieve_good("tools-copper-native")] = 1 },
		job = job("blacksmiths"),
		job_type = JOBTYPE.ARTISAN,
	}
	ProductionMethod:new {
		name = "smith-tools-copper-cast",
		description = "smithing copper into tools",
		icon = "anvil.png",
		r = 0.65,
		g = 0.65,
		b = 0.65,
		inputs = { [retrieve_use_case("copper-bars")] = 5, [retrieve_use_case("fuel")] = 4, [retrieve_use_case("tools")] = 1 },
		outputs = { [retrieve_good("tools-copper-cast")] = 5 },
		job = job("blacksmiths"),
		job_type = JOBTYPE.ARTISAN,
	}
	ProductionMethod:new {
		name = "clay-extraction",
		description = "clay extraction",
		icon = "powder.png",
		r = 0.25,
		g = 0.25,
		b = 0.25,
		inputs = { [retrieve_use_case("containers")] = 1 },
		outputs = { [retrieve_good("clay")] = 1 },
		job = job("gatherers"),
		job_type = JOBTYPE.LABOURER,
		self_sourcing_fraction = 0.5,
		clay_extreme_max = 1,
		clay_ideal_max = 1,
		clay_ideal_min = 0.65,
		clay_extreme_min = 0.5,
	}

	ProductionMethod:new {
		name = "pottery",
		description = "pottery",
		icon = "amphora.png",
		r = 0.55,
		g = 0.25,
		b = 0.25,
		inputs = { [retrieve_use_case("clay")] = 1 },
		outputs = { [retrieve_good("containers")] = 1 },
		job = job("potterers"),
		job_type = JOBTYPE.ARTISAN,
	}

	ProductionMethod:new {
		name = "woodcutting",
		description = "woodcutting",
		icon = "stone-axe.png",
		r = 0.35,
		g = 0.25,
		b = 0.65,
		inputs = { [retrieve_use_case("tools-advanced")] = 1 },
		outputs = { [retrieve_good("timber")] = 4 },
		job = job("woodcutters"),
		job_type = JOBTYPE.LABOURER,
		forest_dependence = 1,
	}

	ProductionMethod:new {
		name = "stone-extraction",
		description = "stone-extraction",
		icon = "stone-block.png",
		r = 0.8,
		g = 0.8,
		b = 0.8,
		inputs = { [retrieve_use_case("tools-advanced")] = 1 },
		outputs = { [retrieve_good("stone")] = 4 },
		job = job("quarrymen"),
		job_type = JOBTYPE.LABOURER,
		self_sourcing_fraction = 0.125,
	}

	ProductionMethod:new {
		name = "tanning",
		description = "tanning",
		icon = "animal-hide.png",
		r = 1,
		g = 0.55,
		b = 0.55,
		inputs = { [retrieve_use_case("hide")] = 5, [retrieve_use_case("water")] = 4, [retrieve_use_case("tannin")] = 1 },
		outputs = { [retrieve_good("leather")] = 5 },
		job = job("tanners"),
		job_type = JOBTYPE.ARTISAN,
	}

	ProductionMethod:new {
		name = "leather-clothing",
		description = "leather clothing",
		icon = "kimono.png",
		r = 1,
		g = 0.75,
		b = 0.45,
		inputs = { [retrieve_use_case("leather")] = 2, [retrieve_use_case("tools")] = 1 },
		outputs = { [retrieve_good("clothes")] = 4 },
		job = job("artisans"),
		job_type = JOBTYPE.ARTISAN,
	}

	ProductionMethod:new {
		name = "furniture",
		description = "furniture",
		icon = "wooden-chair.png",
		r = 1,
		g = 0.55,
		b = 0.65,
		inputs = { [retrieve_use_case("timber")] = 2, [retrieve_use_case("tools")] = 1 },
		outputs = { [retrieve_good("furniture")] = 4 },
		job = job("artisans"),
		job_type = JOBTYPE.ARTISAN,
	}

	ProductionMethod:new {
		name = "rye-farming",
		description = "Rye",
		icon = "wheat.png",
		r = 0.2,
		g = 0.65,
		b = 0,
		inputs = { [retrieve_use_case("tools")] = 1 },
		outputs = { [retrieve_good("grain")] = 4 },
		job = job("farmers"),
		job_type = JOBTYPE.FARMER,
		self_sourcing_fraction = 0.25,
		crop = true,
		temperature_ideal_min = 11,
		temperature_ideal_max = 13,
		temperature_extreme_min = 3,
		temperature_extreme_max = 30,
		rainfall_ideal_min = 40,
		rainfall_ideal_max = 70,
		rainfall_extreme_min = 5,
		rainfall_extreme_max = 200,
	}

	ProductionMethod:new {
		name = "beekeeping",
		description = "Beekeeping",
		icon = "high-grass.png",
		r = 0.2,
		g = 0.65,
		b = 0,
		inputs = { [retrieve_use_case("tools")] = 1 },
		outputs = { [retrieve_good("honey")] = 4 },
		job = job("farmers"),
		job_type = JOBTYPE.FARMER,
		self_sourcing_fraction = 0.25,
		crop = true,
		temperature_ideal_min = 11,
		temperature_ideal_max = 20,
		temperature_extreme_min = 5,
		temperature_extreme_max = 30,
		rainfall_ideal_min = 40,
		rainfall_ideal_max = 70,
		rainfall_extreme_min = 5,
		rainfall_extreme_max = 200,
	}
end

return d
