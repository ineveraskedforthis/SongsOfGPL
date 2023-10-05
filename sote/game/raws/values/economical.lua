local ai_pref = require "game.raws.values.ai_preferences"
local traits = require "game.raws.traits.generic"

local eco_values = {}

---comment
---@param building_type BuildingType
---@param public boolean
---@param overseer Character?
---@return number
function eco_values.building_cost(building_type, overseer, public)
    local cost_multiplier = 1

    -- overseer effect
    if overseer == nil then
        cost_multiplier = 2
    else
        if overseer.traits[traits.BAD_ORGANISER] then
            cost_multiplier = cost_multiplier * 1.5
        end
        if overseer.traits[traits.GOOD_ORGANISER] then
            cost_multiplier = cost_multiplier * 0.5
        end
    end

    if public then
        cost_multiplier = cost_multiplier * 0.8
    end

    return building_type.construction_cost * cost_multiplier
end

return eco_values