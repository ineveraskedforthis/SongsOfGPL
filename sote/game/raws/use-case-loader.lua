local d = {}

function d.load()
	local UseCase = require "game.raws.use-case"

	---commenting
	---@param name string
	---@param description string
	---@param icon string
	---@param r number
	---@param g number
	---@param b number
	local function make_use_case(name, description, icon, consumption, r, g, b)
		return UseCase:new {
			name = name,
			description = description,
			icon = icon,
			good_consumption = consumption,
			r = r,
			g = g,
			b = b,
		}
	end

	make_use_case("administration", "administration", "bookmarklet.png", 1, 0.32, 0.42, 0.92)
	make_use_case("amenities", "amenities", "star-swirl.png", 1, 0.32, 0.838, 0.38)
	-- NEED.FOOD
	WATER_USE_CASE = make_use_case("water", "water", "droplets.png", 1, 0.12, 1, 1)
	CALORIES_USE_CASE = make_use_case("calories", "calories", "potato.png", 1, 0.71, 0.57, 0.14)
	make_use_case("cambium", "cambium", "birch-trees.png", 1, 0.22, 0.19, 0.13)
	make_use_case("meat", "meat", "meat.png", 1, 1, 0.1, 0.1)
	make_use_case("fruit", "fruit", "fruit-bowl.png", 1, 0.82, 0.88, 19)
	make_use_case("grain", "grains", "wheat.png", 1, 0.91, 0, 0.7)
	-- NEED.CLOTHING
	make_use_case("clothes", "clothes", "kimono.png", 0.05, 1, 0.6, 0.7)
	make_use_case("hide", "hide", "animal-hide.png", 1, 1, 0.3, 0.3)
	make_use_case("leather", "leather", "animal-hide.png", 1, 1, 0.65, 0.65)
	make_use_case("tannin", "tannins", "powder.png", 1, 0.72, 0.41, 0.22)
	-- NEED.TOOLS
	CONTAINERS_USE_CASE = make_use_case("containers", "containers", "amphora.png", 0.05, 0.34, 0.212, 1)
	TOOLS_LIKE_USE_CASE = make_use_case("tools-like", "tools-like", "stone-axe.png", 0.1, 0.162, 0.141, 0.422)
	make_use_case("tools", "tools", "stone-axe.png", 0.05, 0.162, 0.141, 0.422)
	make_use_case("tools-advanced", "tools", "stone-axe.png", 0.01, 0.162, 0.141, 0.422)
	-- NEED.FURNITURE
	make_use_case("furniture", "furniture", "wooden-chair.png", 0.05, 0.5, 0.4, 0.1)
	-- NEED.HEALTHCARE
	make_use_case("healthcare", "healthcare", "health-normal.png", 1, 0.683, 0.128, 0.974)

	make_use_case("timber", "timber", "wood-pile.png", 1, 0.72, 0.41, 0.22)
	make_use_case("fuel", "fuel", "celebration-fire.png", 1, 0.94, 0.25, 0.12)

	-- alcohol use cases
	make_use_case("liquors", "liquors", "beer-stein.png", 1, 0.7, 1, 0.3)
	make_use_case("mead-substrate", "ingredients in mead production", "high-grass.png", 1, 0.32, 0.42, 0.92)

	-- stone materials
	make_use_case("blanks-core", "knapping blanks", "rock.png", 1, 0.162, 0.141, 0.422)
	make_use_case("stone", "stone", "stone-block.png", 1, 0.262, 0.241, 0.222)

	-- copper chain materials
	make_use_case("copper-bars", "copper", "metal-bar.png", 1, 0.71, 0.25, 0.05)
	make_use_case("copper-source", "copper-source", "ore.png", 1, 0.71, 0.25, 0.05)
	make_use_case("copper-native", "copper-native", "ore.png", 1, 0.71, 0.25, 0.05)

	-- iron
	make_use_case("meteoric-iron", "meteoric iron", "ore.png", 1, 0.2, 0.2, 0.3)

	-- luxury
	make_use_case("jewelry", "jewelry", "tribal-pendant.png", 0, 1, 1, 1)

	-- structural materials
	make_use_case("structural-material", "structural-material", "stone-block.png", 1, 0.262, 0.241, 0.222)

	make_use_case("clay", "clay", "powder.png", 1, 0.262, 0.241, 0.222)
end

return d
