local ui = require "engine.ui"
local strings = require "engine.string"
local rank_name = require "game.raws.ranks.localisation"
local pop_utils = require "game.entities.pop"
local warband_utils = require "game.entities.warband"

---comment
---@param character_id Character
---@return string name
local function name(character_id)
    if character_id == INVALID_ID then
        return "Invalid character"
    end

    -- rect = rect:shrink(5)
    local realm = REALM(character_id)
    local leader = LEADER(realm)
    local collector_of = DATA.tax_collector_get_realm(DATA.get_tax_collector_from_collector(character_id))
    local title
    -- realm office
    if leader ~= INVALID_ID then
        return strings.title(rank_name(character_id)) .. " of " .. REALM_NAME(REALM(character_id))
    end
    local overseer_of = DATA.realm_overseer_get_realm(DATA.get_realm_overseer_from_overseer(character_id))
    if overseer_of and overseer_of ~= INVALID_ID then
        return "Overseer of " .. REALM_NAME(REALM(character_id))
    end
    if collector_of ~= INVALID_ID then
        return "Tribute Collector of " .. REALM_NAME(REALM(character_id))
    end
    -- warband or guard
    local in_warband
    local warband_leader = warband_utils.active_leader(character_id)
    if warband_leader and warband_leader ~= INVALID_ID then
            title = title .. "Leader"
    else
        local warband_commander = warband_utils.active_commander(character_id)
        if warband_commander and warband_commander ~= INVALID_ID then
            in_warband = warband_commander
            title = title .. "Commander"
        else
            local warband_recruiter = pop_utils.get_warband_of_recruiter(character_id)
            if warband_recruiter and warband_recruiter ~= INVALID_ID then
                in_warband = warband_recruiter
                title = title .. "Recruiter"
            else
                local unit = UNIT_TYPE_OF(character_id)
                if unit ~= INVALID_ID then
                    local warband_unit = UNIT_TYPE_OF(character_id)
                    title = strings.title(DATA.unit_type_get_name(warband_unit))
                end
            end
        end
    end
    if in_warband and in_warband ~= INVALID_ID then
        if guard and guard == in_warband then
            return title .. " of " .. REALM_NAME(guard)
        else
            return title .. " of " .. ESTATE_NAME(character_id)
        end
    elseif realm ~= INVALID_ID then
        return strings.title(rank_name(character_id)) .. " of " .. DATA.realm_get_name(realm)
    end

    return "outlaw"
end

return name