local tabb = require "engine.table"
local strings = require "engine.string"

local ui = require "engine.ui"
local ut = require "game.ui-utils"

local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"

local party_utils = require "game.entities.warband"

local pui = require "game.scenes.game.widgets.pop-ui-widgets"

local rank_name = require "game.raws.ranks.localisation"

local party_ui = {}

---draws a party's current time ratio
---@param rect Rect
---@param party_id estate_id
function party_ui.render_current_time_ratio(rect,party_id)
    local tooltip, value = "INVALID_ID", -.99
    if party_id ~= INVALID_ID then
        value = DATA.estate_get_current_time_used_ratio(party_id)
        local status = DATA.estate_get_current_status(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has spent " .. ut.to_fixed_point2(value*100)
            .. "% of  this month active and is currently " .. DATA.estate_status_get_action_string(status)
            .. ", increasing this month's party time towards " .. ut.to_fixed_point2(DATA.estate_status_get_time_used(status)*100) .. "%."
    end
    ut.generic_number_field("chart.png",value,rect,tooltip,ut.NUMBER_MODE.PERCENTAGE,ut.NAME_MODE.ICON,true)
end

---@param rect Rect
---@param party_id estate_id
function party_ui.render_travel_speed(rect,party_id)
    local tooltip, value = "INVALID_ID", -.99
	if party_id ~= INVALID_ID then
        local speed, weight_mod = require "game.raws.values.military".estate_speed(party_id)
        value = speed.base
		tooltip = ESTATE_NAME(party_id) .. " has a minimum base speed of " .. ut.to_fixed_point2(value/weight_mod)
            .. " modified by a carrying weight of " .. ut.to_fixed_point2(party_utils.current_hauling(party_id))
            .. " / " .. ut.to_fixed_point2(party_utils.total_hauling(party_id))
            .. ", reducing speed to " .. ut.to_fixed_point2(weight_mod*100) .. "%"
        if speed.can_fly then
			tooltip = tooltip .. "\n - Can fly"
        end
        if speed.river_fast then
			tooltip = tooltip .. "\n - Strong swimmers"
        end
        if speed.can_fly then
			tooltip = tooltip .. "\n - Forestwalking"
        end
	end
    ut.generic_number_field(
        "fast-forward-button.png",
        value,
        rect,
        tooltip,
        ut.NUMBER_MODE.PERCENTAGE,
        ut.NAME_MODE.ICON
    )
end


---traverses path and collects the total tile distance with the progress cost and estimated travel time
--- with the party's current speed
---@param rect Rect
---@param party_id estate_id
function party_ui.render_travel_estimate(rect,party_id)
    local tooltip, estimate_days, progress_total, tile_count = ESTATE_NAME(party_id) .. " is not currently traveling anywhere", 0, 0, 0
    local current_path = DATA.estate_get_current_path(party_id)
    if current_path and #current_path > 0 then
        local speed = require "game.raws.values.military".estate_speed(party_id)
        local movement_progress = DATA.estate_get_movement_progress(party_id)
        local last_tile = ESTATE_TILE(party_id)
        local this_tile = current_path[#current_path]
        tooltip = ESTATE_NAME(party_id)
            .. "\n movement progress " .. ut.to_fixed_point2(movement_progress) .. " remaining in current tile"
            .. "\n this tile " .. last_tile .. ", speed " .. ut.to_fixed_point2(require "game.ai.pathfinding".tile_speed(last_tile,speed))
            .. "\n next tile " .. this_tile .. ", speed " .. ut.to_fixed_point2(require "game.ai.pathfinding".tile_speed(this_tile,speed))
        for i=#current_path,2,-1 do
            local this = current_path[i]
            local next = current_path[i-1]
            local progress_cost = require "game.ai.pathfinding".tile_distance(this, next, speed)
            progress_total = progress_total + progress_cost
            tooltip = tooltip .. "\n - " .. this .. " -> " .. next .. " : " .. ut.to_fixed_point2(progress_cost)
        end
        local estimate_hours = progress_total + movement_progress
        estimate_days = estimate_hours / TRAVEL_DAY_HOURS
        tooltip = tooltip
            .. "\n estimated " .. ut.to_fixed_point2(estimate_hours) .. " hours of movement"
            .. " totaling " .. math.ceil(estimate_days) .. " days of traveling"
    end
    ut.generic_number_field("stopwatch.png",estimate_days,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end

---draws a party's total size
---@param rect Rect
---@param party_id estate_id
function party_ui.render_size(rect,party_id)
    local tooltip, value = "INVALID_ID", 0
    if party_id ~= INVALID_ID then
        value = party_utils.size(party_id)
        local warriors = party_utils.war_size(party_id)
        local noncombatant = value - warriors
        tooltip = ESTATE_NAME(party_id) .. " has size of  " .. value .. " units, including " .. warriors
            .. " warriors and " .. noncombatant .. " noncombatants"
    end
    ut.generic_number_field("minions.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end
---draws a party's total size
---@param rect Rect
---@param party_id estate_id
function party_ui.render_warsize(rect,party_id)
    local tooltip, value = "INVALID_ID", 0
    if party_id ~= INVALID_ID then
        value = party_utils.war_size(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has " .. value .. " warriors"
    end
    ut.generic_number_field("guards.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end

---draws a party's war size
---@param rect Rect
---@param party_id estate_id
function party_ui.render_war_size(rect,party_id)
    local tooltip, value = "INVALID_ID", 0
    if party_id ~= INVALID_ID then
        value = party_utils.war_size(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has a war size of  " .. value .. " warriors willing to fight"
    end
    ut.generic_number_field("minions.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end

---draws a party's visibility
---@param rect Rect
---@param party_id estate_id
function party_ui.render_visibility(rect,party_id,tooltip)
    local tooltip, value, count = "INVALID_ID", -1, tabb.size(DATA.get_estate_unit_from_estate(party_id))
    if party_id ~= INVALID_ID then
        value = party_utils.visibility(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has a total visibility of " .. ut.to_fixed_point2(value)
            .. " from " .. count .. " units"
    end
    ut.generic_number_field("high-grass.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end

---draws a party's spotting
---@param rect Rect
---@param party_id estate_id
---@param civilian boolean
function party_ui.render_spotting(rect,party_id,civilian)
    local tooltip, value, count = "INVALID_ID", -1, tabb.size(DATA.get_estate_unit_from_estate(party_id))
    if party_id ~= INVALID_ID then
        value = party_utils.spotting(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has a total spotting of " .. ut.to_fixed_point2(value)
            .. " from " .. count .. " units"
    end
    ut.generic_number_field("magnifying-glass.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end

---draws a party's total health
---@param rect Rect
---@param party_id estate_id
function party_ui.render_daily_supply_consumption(rect,party_id)
    local tooltip, value, count = "INVALID_ID", 0, tabb.size(DATA.get_estate_unit_from_estate(party_id))
    if party_id ~= INVALID_ID then
        value = party_utils.daily_supply_consumption(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has a daily supply consumption of " .. ut.to_fixed_point2(value)
            .. " while traveling from " .. count .. " units"
    end
    ut.generic_number_field("sliced-bread.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end
---draws a party's total health
---@param rect Rect
---@param party_id estate_id
function party_ui.render_days_of_travel(rect,party_id)
    local tooltip, value = "INVALID_ID", -1
    if party_id ~= INVALID_ID then
        local consumption = party_utils.daily_supply_consumption(party_id)
        local supplies = require "game.raws.values.economy".get_supply_available(party_id)
        value = require "game.raws.values.economy".days_of_travel(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has " .. ut.to_fixed_point2(value) .. " days of traveling supplies from a cost of "
            .. ut.to_fixed_point2(consumption) .. " calories per day and "
            .. ut.to_fixed_point2(supplies) .. " calories in inventory"
    end
    ut.generic_number_field("horizon-road.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end
---draws a party's total health
---@param rect Rect
---@param party_id estate_id
function party_ui.render_supply_available(rect,party_id)
    local tooltip, value = "INVALID_ID", -1
    if party_id ~= INVALID_ID then
        value = require "game.raws.values.economy".get_supply_available(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has " .. ut.to_fixed_point2(value)
            .. " calories in it's inventory"
    end
    ut.generic_number_field("noodles.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end
---draws a party's total health
---@param rect Rect
---@param party_id estate_id
function party_ui.render_supply_capacity(rect,party_id)
    local tooltip, value = "INVALID_ID", 0
    if party_id ~= INVALID_ID then
        local capacity = party_utils.total_hauling(party_id)
        local current = party_utils.current_hauling(party_id)
        local diff = capacity - current
        value = current/capacity
        tooltip = ESTATE_NAME(party_id) .. " is currently carrying " .. ut.to_fixed_point2(current)
            .. " weight units worth of goods with a total hauling capacity of " .. ut.to_fixed_point2(capacity)
        if diff < 0 then
            tooltip = tooltip .. "\n" .. ESTATE_NAME(party_id) .. " in over it's hauling capacity by " .. ut.to_fixed_point2(-diff) .. "!"
        end
    end
    ut.generic_number_field("cardboard-box.png",value,rect,
        tooltip,
        ut.NUMBER_MODE.PERCENTAGE,ut.NAME_MODE.ICON,true)
end
---draws a party's monthly upkeep for units
---@param rect Rect
---@param party_id estate_id
function party_ui.render_upkeep(rect,party_id)
    local tooltip, value = "INVALID_ID", -1
    if party_id ~= INVALID_ID then
        value = DATA.estate_get_total_upkeep(party_id)
        tooltip = ESTATE_NAME(party_id) .. " expects to pay " .. ut.to_fixed_point2(value)
            .. MONEY_SYMBOL .. " to its " .. party_utils.size(party_id) .. " units"
    end
    ut.generic_number_field("receive-money.png",value,rect,tooltip,ut.NUMBER_MODE.MONEY,ut.NAME_MODE.ICON)
end
---draws a party's treasury
---@param rect Rect
---@param party_id estate_id
function party_ui.render_savings(rect,party_id)
    local value = -1
    if party_id ~= INVALID_ID then
        value = DATA.estate_get_savings(party_id)
    end
    ut.generic_number_field("coins.png",value,rect,
    ESTATE_NAME(party_id) .. " has " .. ut.to_fixed_point2(value)
            .. MONEY_SYMBOL .. " in savings",
        ut.NUMBER_MODE.MONEY,ut.NAME_MODE.ICON)
end

---draws a party's morale
---@param rect Rect
---@param party_id estate_id
function party_ui.render_morale(rect,party_id)
    local tooltip, value, count = "INVALID_ID", -1, -1
    if party_id ~= INVALID_ID then
        value = DATA.estate_get_morale(party_id)
        tooltip = ESTATE_NAME(party_id) .. "'s current morale is at " .. ut.to_fixed_point2(value*100) .. "%"
    end
    ut.generic_number_field("musical-notes.png",value,rect,tooltip,ut.NUMBER_MODE.PERCENTAGE,ut.NAME_MODE.ICON)
end
---draws a party's total health
---@param rect Rect
---@param party_id estate_id
---@param civilian boolean?
function party_ui.render_health(rect,party_id,civilian)
    local tooltip, value, count = "INVALID_ID", -1, -1
    if party_id ~= INVALID_ID then
        value, _, _, _, count = party_utils.total_strength(party_id,civilian)
        tooltip = ESTATE_NAME(party_id) .. " has a total health of " .. ut.to_fixed_point2(value)
            .. " from " .. count .. (civilian and " units" or " warriors")
    end
    ut.generic_number_field("health-normal.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end
---draws a party's armor
---@param rect Rect
---@param party_id estate_id
---@param civilian boolean?
function party_ui.render_armor(rect,party_id,civilian)
    local tooltip, value, count = "INVALID_ID", 0, 0
    if party_id ~= INVALID_ID then
        _, _, value, _, count = party_utils.total_strength(party_id,civilian)
        tooltip = ESTATE_NAME(party_id) .. " has a total armor of " .. ut.to_fixed_point2(value)
            .. " from " .. count .. (civilian and " units" or " warriors")
    end
    ut.generic_number_field("round-shield.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end
---draws a party's total attack
---@param rect Rect
---@param party_id estate_id
---@param civilian boolean?
function party_ui.render_attack(rect,party_id,civilian)
    local tooltip, value, count = "INVALID_ID", 0, 0
    if party_id ~= INVALID_ID then
        _, value, _, _, count = party_utils.total_strength(party_id)
        tooltip = ESTATE_NAME(party_id) .. " has a total attack of " .. ut.to_fixed_point2(value)
            .. " from " .. count .. (civilian and " units" or " warriors")
    end
    ut.generic_number_field("stone-spear.png",value,rect,tooltip,ut.NUMBER_MODE.NUMBER,ut.NAME_MODE.ICON)
end

---renders location text button with realm coa or biome data
---@param game GameScene
---@param rect Rect
---@param party estate_id
function party_ui.render_location_buttons(game,rect,party)
    local tile = ESTATE_TILE(party)
    local province = TILE_PROVINCE(tile)
    local realm = PROVINCE_REALM(province)
    ib.text_button_to_province_tile(game,tile,rect:subrect(0,0,rect.width-ut.BASE_HEIGHT*4,rect.height,"left","up"),
    ESTATE_NAME(party) .. " is currently in the province of " .. PROVINCE_NAME(province))
    local icon_rect = rect:subrect(-ut.BASE_HEIGHT*3,0,ut.BASE_HEIGHT,rect.height,"right","up")
    if realm ~= INVALID_ID and tile == DATA.province_get_center(province) then
        ib.icon_button_to_realm(game,PROVINCE_REALM(province),icon_rect,
        ESTATE_NAME(party) .. " is currently in the realm of " .. REALM_NAME(realm))
        local leader = party_utils.active_leader(party)
        if leader ~= INVALID_ID then
            pui.render_realm_popularity(rect:subrect(0,0,ut.BASE_HEIGHT*3,rect.height,"right","up"),leader,realm)
        end
    else
        ui.panel(icon_rect,2,true)
        local biome = DATA.tile_get_biome(tile)
        local biome_tooltip = ESTATE_NAME(party) .. " is currently "
            .. DATA.estate_status_get_action_string(DATA.estate_get_current_status(party))
            .. " in unclaimed " .. DATA.biome_get_name(biome)
        ut.render_icon(icon_rect,"horizon-road.png",DATA.biome_get_r(biome),DATA.biome_get_g(biome),DATA.biome_get_b(biome),1,true)
        ui.tooltip(biome_tooltip,icon_rect)
    end
end

---comment
---@param game GameScene
---@param rect Rect
---@param party estate_id
function party_ui.render_target_buttons(game,rect,party)
    local path = DATA.estate_get_current_path(party)
    local tile = path and path[1] or INVALID_ID
    local province = TILE_PROVINCE(tile)
    local button_rect = rect:subrect(0,0,rect.width-ut.BASE_HEIGHT*4,rect.height,"left","up")
    if tile ~= INVALID_ID then
        ib.text_button_to_province_tile(game,tile,button_rect,
        ESTATE_NAME(party) .. " is currently traveling to the province of " .. PROVINCE_NAME(province))
    else
        ut.text_button("No target",button_rect,ESTATE_NAME(party) .. " is not currently traveling anywhere",false)
    end
    local realm = PROVINCE_REALM(province)
    local icon_rect = rect:subrect(-ut.BASE_HEIGHT*3,0,ut.BASE_HEIGHT,rect.height,"right","up")
    if realm ~= INVALID_ID and tile == DATA.province_get_center(province) then
        ib.icon_button_to_realm(game,PROVINCE_REALM(province),icon_rect,
        ESTATE_NAME(party) .. " is currently traveling to the capitol of " .. REALM_NAME(realm))
    elseif tile ~= INVALID_ID then
        ui.panel(icon_rect,2,true)
        local biome = DATA.tile_get_biome(tile)
        local biome_tooltip = ESTATE_NAME(party) .. " is currently "
            .. DATA.estate_status_get_action_string(DATA.estate_get_current_status(party))
            .. " traveling to " .. DATA.biome_get_name(biome)
        ut.render_icon(icon_rect,"horizon-road.png",DATA.biome_get_r(biome),DATA.biome_get_g(biome),DATA.biome_get_b(biome),1,true)
        ui.tooltip(biome_tooltip,icon_rect)
    else
        ut.render_icon(icon_rect,"uncertainty.png",.8,.8,.8,1,true)
        ui.tooltip(ESTATE_NAME(party) .. " is not currently traveling anywhere",icon_rect)
    end
    party_ui.render_travel_estimate(rect:subrect(0,0,ut.BASE_HEIGHT*3,rect.height,"right","up"),party)
end

---draws a ib overlay portrait to party leader with title, location, and some basic info
---, rect.height should be a minimum 4 ut.BASE_HEIGHT!
---@param game GameScene
---@param rect Rect
---@param party_id estate_id
---@param title fun(rect:Rect)
function party_ui.render_party_overview(game,rect,party_id,title)
    ui.panel(rect,2,true)

    local player_id = WORLD.player_character

    local title_rect = rect:subrect(0,0,rect.width,ut.BASE_HEIGHT,"left","up")
    title(title_rect)
    local portrait_size = rect.height-ut.BASE_HEIGHT
    local portrait_rect = rect:subrect(0,0,portrait_size,portrait_size,"left","down")

    if party_id ~= INVALID_ID then
        local estate_status = DATA.estate_get_current_status(party_id)
        local status_name = DATA.estate_status_get_name(estate_status) or "!"

        local leader_id = party_utils.active_leader(party_id)
        if leader_id ~= INVALID_ID then
            ib.render_portrait_with_overlay(game,portrait_rect,leader_id,"Leader " .. pui.pop_tooltip(leader_id))
        else -- if no active leader than is guard?
            local realm_id = party_utils.realm(party_id)
            if realm_id ~= INVALID_ID then
                ib.icon_button_to_realm(game,realm_id,portrait_rect,"Local guards of " .. REALM_NAME(realm_id))
            else -- party has no leader or realm
                ut.render_icon(portrait_rect,"uncertainty.png",.8,.8,.8,1,true)
                ui.tooltip("Vagabonds", portrait_rect)
            end
        end

        local lines_rect = rect:subrect(0,0,rect.width-portrait_size,ut.BASE_HEIGHT*3,"right","down")
        local lines_layout = ui.layout_builder():position(lines_rect.x,lines_rect.y):vertical():build()
        local line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)

        -- top line
        local line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
        party_ui.render_size(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)
        party_ui.render_spotting(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)
        party_ui.render_visibility(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)
        -- TODO? something? anything?


        -- middle line
        line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)
        line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
        party_ui.render_warsize(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)
        party_ui.render_health(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)
        party_ui.render_armor(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)
        party_ui.render_attack(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)

        -- bottom line
        line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)
        line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
        -- leader home populatiry
        local status_rect
        if leader_id ~= INVALID_ID then
            pui.render_realm_popularity(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),leader_id,REALM(leader_id))
            status_rect = line_layout:next(line_rect.width-ut.BASE_HEIGHT*6,ut.BASE_HEIGHT)
        else
            status_rect = line_layout:next(line_rect.width-ut.BASE_HEIGHT*3,ut.BASE_HEIGHT)
        end
        -- party status and party time
        ui.text_panel(strings.title(status_name),status_rect)

        local status_action = DATA.estate_status_get_action_string(estate_status) or "!"
        ui.tooltip(ESTATE_NAME(party_id) .. " is currently " .. status_action, status_rect)
        party_ui.render_current_time_ratio(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),party_id)
    end
end

function party_ui.render_hire_size(rect,pop_id)
    local tooltip, value = "INVALID_ID", 0
    if pop_id then
        local dependents = DATA.filter_array_parent_child_relation_from_parent(pop_id, function (item)
            local child_id = DATA.parent_child_relation_get_child(item)
            return IS_DEPENDENT_OF(child_id,pop_id)
        end)
        value = #dependents + 1
        if value > 1 then
            tooltip = NAME(pop_id) .. " has " .. (value-1) .. " dependents that will also follow the party"
            for _, child_id in pairs(dependents) do
                tooltip = tooltip .. "\n " .. NAME(child_id) .. " " .. math.floor(AGE_YEARS(child_id))
                    .. " (" .. require "game.entities.pop".POP.get_age_string(child_id) .. ")"
            end
        else
            tooltip =  NAME(pop_id) .. " has no dependents"
        end
    end
    ut.generic_number_field(
        "minions.png",
        value,
        rect,
        tooltip,
        ut.NUMBER_MODE.INTEGER,
        ut.NAME_MODE.ICON)
end

function party_ui.render_hire_spotting(rect,pop_id)
    local tooltip, value = "INVALID_ID", 0
    if pop_id then
        local dependents = DATA.filter_array_parent_child_relation_from_parent(pop_id, function (item)
            local child_id = DATA.parent_child_relation_get_child(item)
            return IS_DEPENDENT_OF(child_id,pop_id)
        end)
        value = require "game.entities.pop".POP.get_spotting(pop_id)
        tooltip = NAME(pop_id) .. " has " .. ut.to_fixed_point2(value) .. " spotting"
        for _, child_id in pairs(dependents) do
            local spot = require "game.entities.pop".POP.get_spotting(child_id)
            value = value + spot
            tooltip = tooltip .. "\n " .. NAME(child_id) .. " adds " .. ut.to_fixed_point2(spot)
        end
    end
    ut.generic_number_field(
        "magnifying-glass.png",
        value,
        rect,
        tooltip,
        ut.NUMBER_MODE.NUMBER,
        ut.NAME_MODE.ICON)
end

function party_ui.render_hire_visibility(rect,pop_id)
    local tooltip, value = "INVALID_ID", 0
    if pop_id then
        local dependents = DATA.filter_array_parent_child_relation_from_parent(pop_id, function (item)
            local child_id = DATA.parent_child_relation_get_child(item)
            return IS_DEPENDENT_OF(child_id,pop_id)
        end)
        value = require "game.entities.pop".POP.get_visibility(pop_id)
        tooltip = NAME(pop_id) .. " has " .. ut.to_fixed_point2(value) .. " visibility"
        for _, child_id in pairs(dependents) do
            local vis = require "game.entities.pop".POP.get_visibility(child_id)
            value = value + vis
            tooltip = tooltip .. "\n " .. NAME(child_id) .. " adds " .. ut.to_fixed_point2(vis)
        end
    end
    ut.generic_number_field(
        "high-grass.png",
        value,
        rect,
        tooltip,
        ut.NUMBER_MODE.NUMBER,
        ut.NAME_MODE.ICON)
end

function party_ui.render_hire_hauling(rect,pop_id)
    local tooltip, value = "INVALID_ID", 0
    if pop_id then
        local dependents = DATA.filter_array_parent_child_relation_from_parent(pop_id, function (item)
            local child_id = DATA.parent_child_relation_get_child(item)
            return IS_DEPENDENT_OF(child_id,pop_id)
        end)
        value = require "game.entities.pop".POP.get_supply_capacity(pop_id)
        tooltip = NAME(pop_id) .. " can haul " .. ut.to_fixed_point2(value) .. " weight units"
        for _, child_id in pairs(dependents) do
            local haul = require "game.entities.pop".POP.get_supply_capacity(child_id)
            value = value + haul
            tooltip = tooltip .. "\n " .. NAME(child_id) .. " adds " .. ut.to_fixed_point2(haul)
        end
    end
    ut.generic_number_field(
        "cardboard-box.png",
        value,
        rect,
        tooltip,
        ut.NUMBER_MODE.NUMBER,
        ut.NAME_MODE.ICON)
end

function party_ui.render_hire_speed(rect,pop_id)
    local tooltip, value = "INVALID_ID", 0
    if pop_id then
        local dependents = DATA.filter_array_parent_child_relation_from_parent(pop_id, function (item)
            local child_id = DATA.parent_child_relation_get_child(item)
            return IS_DEPENDENT_OF(child_id,pop_id)
        end)
        value = require "game.entities.pop".POP.get_speed(pop_id).base
        tooltip = NAME(pop_id) .. " max speed is " .. ut.to_fixed_point2(value)
        for _, child_id in pairs(dependents) do
            local speed = require "game.entities.pop".POP.get_speed(child_id).base
            value = math.min(value,speed)
            tooltip = tooltip .. "\n " .. NAME(child_id) .. " max is " .. ut.to_fixed_point2(speed)
        end
    end
    ut.generic_number_field(
        "fast-forward-button.png",
        value,
        rect,
        tooltip,
        ut.NUMBER_MODE.NUMBER,
        ut.NAME_MODE.ICON)
end

return party_ui