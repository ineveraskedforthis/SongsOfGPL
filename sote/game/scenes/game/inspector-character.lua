local tabb = require "engine.table"
local strings = require "engine.string"

local ui = require "engine.ui"
local ut = require "game.ui-utils"

local pui = require "game.scenes.game.widgets.pop-ui-widgets"
local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"

local character_name_widget = require "game.scenes.game.widgets.character-name"
local list_widget = require "game.scenes.game.widgets.list-widget"

local pop_utils = require "game.entities.pop".POP
local warband_utils = require "game.entities.warband"

local window = {}
local selected_decision = nil
local decision_target_primary = nil
local decision_target_secondary = nil

---@alias InspectorCharacterStatsTabs "TRT"|"ATR"|"EFF"
---@type InspectorCharacterStatsTabs
local stats_tab = "TRT"

---@alias InspectorCharacterInfoTabs "WRK"|"PRP"|"REL"|"DCN"
---@type InspectorCharacterInfoTabs
local character_tab = "REL"
local forage_table_state = nil

---@alias InspectorRelationshipTabs "FAMILY"|"LOYALTY"
---@type InspectorRelationshipTabs
local relations_tab = "FAMILY"
local relations_family_state = nil
local relations_loyalty_state = nil

---@alias InspectorInventoryTabs "INVENTORY"|"BUILDINGS"
---@type InspectorInventoryTabs
local property_tab = "INVENTORY"
local property_inventory_state = nil
local property_buildings_state  = nil

---family name stand in
---@param pop_id pop_id
---@return string
local function get_fullname(pop_id)
    local name = NAME(pop_id)
    local parent = PARENT(pop_id)
    if parent ~= INVALID_ID then
        if DATA.pop_get_female(pop_id) then
            name = name .. ", daughter of "
        else
            name = name .. ", son of "
        end
        name = name .. NAME(parent)
    end
    return name
end

---draws a ib overlay portrait to building owner/manager with title, location, and some basic info
---, rect.height should be a minimum 4 ut.BASE_HEIGHT!
---@param game GameScene
---@param rect Rect
---@param pop_id pop_id
---@param player_id pop_id
local function render_employer_overview(game,rect,pop_id,player_id)
    ui.panel(rect,2,true)

    local employer_id = pop_utils.get_employer_of(pop_id)

    local title_rect = rect:subrect(0,0,rect.width-ut.BASE_HEIGHT*4,ut.BASE_HEIGHT,"left","up")
    local icon_rect = rect:subrect(-ut.BASE_HEIGHT*3,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"right","up")
    local time_rect = rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"right","up")
    local portrait_size = rect.height-ut.BASE_HEIGHT
    local portrait_rect = rect:subrect(0,0,portrait_size,portrait_size,"left","down")

    if employer_id ~= INVALID_ID then
        local building_type_id = DATA.building_get_current_type(employer_id)
        local employer_name = strings.title(DATA.building_type_get_name(building_type_id))
        local owner_id = OWNER(BUILDING_ESTATE(employer_id))
        local employer_province = BUILDING_PROVINCE(employer_id)
        local estate_tooltip
        if owner_id ~= INVALID_ID then
            estate_tooltip = NAME(owner_id) .. "'s " .. employer_name .. " in " .. PROVINCE_NAME(employer_province) .. "."
            ib.render_portrait_with_overlay(game,portrait_rect,owner_id,pui.pop_tooltip(pop_id))
        else -- public buildings controlled by overseer?
            local realm_id = PROVINCE_REALM(employer_province)
            estate_tooltip = "Public estate of " .. REALM_NAME(realm_id) .. "."
            owner_id = require "game.raws.values.politics".overseer(realm_id)
            if owner_id ~= INVALID_ID then
                ib.render_portrait_with_overlay(game,portrait_rect,owner_id,pui.pop_tooltip(pop_id))
            else -- building in a realmless province
                ut.render_icon(portrait_rect,"horizon-road.png",.8,.8,.8,1,true)
                ui.tooltip("This building is unclaimed.", portrait_rect)
            end
        end

        local estate_id = DATA.building_estate_get_estate(DATA.get_building_estate_from_building(employer_id))
        local employer_tooltip = employer_name .. "\n " .. DATA.building_type_get_description(building_type_id)
        ui.tooltip(employer_tooltip,title_rect)
        ib.icon_button_to_building(game,employer_id,icon_rect,employer_tooltip)
        pui.render_work_time(time_rect,pop_id)
        ib.text_button_to_estate(game,estate_id,employer_id,title_rect,employer_name,estate_tooltip)

        local lines_rect = rect:subrect(0,0,rect.width-portrait_size,ut.BASE_HEIGHT*3,"right","down")
        local lines_layout = ui.layout_builder():position(lines_rect.x,lines_rect.y):vertical():build()

        -- basic info
        local line_rect = rect:subrect(0,0,rect.width-ut.BASE_HEIGHT*3,ut.BASE_HEIGHT*3,"right","down")
        local lines_layout = ui.layout_builder():position(line_rect.x,line_rect.y):vertical():build()
        local line_rect = lines_layout:next(line_rect.width,ut.BASE_HEIGHT)
        local line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
        local method = DATA.building_type_get_production_method(building_type_id)
        local job_type_id = DATA.production_method_get_job_type(method)
        local job_id = pop_utils.get_job_of(pop_id)
        local job_name = strings.title(DATA.job_get_name(job_id))
        local job_tooltip = job_name .. "\n " .. DATA.job_get_description(job_id)
        local job_name_rect = line_layout:next(line_rect.width-ut.BASE_HEIGHT*4,ut.BASE_HEIGHT)
        ui.tooltip(job_tooltip,job_name_rect)
        ui.text(job_name, job_name_rect)
        pui.render_job_icon(line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),pop_id, job_tooltip)
        pui.render_job_efficiency(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),pop_id,job_type_id)

        -- building location and owner local popularity
        line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)
        line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
        local tile_id = DATA.province_get_center(employer_province)
        ib.text_button_to_province_tile(game,tile_id,line_layout:next(line_rect.width-ut.BASE_HEIGHT*4,ut.BASE_HEIGHT))
        local realm_id = PROVINCE_REALM(employer_province)
        if realm_id ~= INVALID_ID then
            ib.icon_button_to_realm(game,realm_id,line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),employer_name .. " is in the capitol of " .. REALM_NAME(realm_id))
        else
            local biome = DATA.tile_get_biome(tile_id)
            ut.color_icon_button("horizon-road.png",DATA.biome_get_r(biome),DATA.biome_get_g(biome),DATA.biome_get_b(biome),1,
                line_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT),employer_name .. " is on unclaimed lands.", false)
        end
        if owner_id ~= INVALID_ID and realm_id ~= INVALID_ID then
            pui.render_realm_popularity(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),owner_id,PROVINCE_REALM(employer_province))
        end

        -- owner home populatiry
        line_rect = lines_layout:next(lines_rect.width,ut.BASE_HEIGHT)
        line_layout = ui.layout_builder():position(line_rect.x,line_rect.y):horizontal():build()
        local owner_pop_rect = line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT)
        if owner_id ~= INVALID_ID then
            pui.render_realm_popularity(owner_pop_rect,owner_id,REALM(pop_id))
        end
        -- building income and savings, pop income
        local last_income = DATA.estate_get_balance_last_tick(BUILDING_ESTATE(employer_id))
        ut.generic_number_field(
            "two-coins.png",
            last_income,
            line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),
            employer_name .. " gained " .. ut.to_fixed_point2(last_income) .. MONEY_SYMBOL .. " last month.",
            ut.NUMBER_MODE.BALANCE,
            ut.NAME_MODE.ICON)
        local savings = DATA.estate_get_savings(BUILDING_ESTATE(employer_id))
        ut.generic_number_field(
            "coins.png",
            savings,
            line_layout:next(line_rect.width-ut.BASE_HEIGHT*9,ut.BASE_HEIGHT),
            employer_name .. " has " .. ut.to_fixed_point2(savings) .. MONEY_SYMBOL .. " in savings.",
            ut.NUMBER_MODE.BALANCE,
            ut.NAME_MODE.ICON,
            true)
        pui.render_worker_income(line_layout:next(ut.BASE_HEIGHT*3,ut.BASE_HEIGHT),pop_id)
    else
    end
end

-- tab drawing calls

---draws efficiencies and employer link
---@param game GameScene
---@param rect Rect
---@param pop_id pop_id
local function draw_wrk_tab(game,rect,pop_id)
    local layout = ui.layout_builder():position(rect.x,rect.y):vertical():build()

    local party_id = UNIT_OF(pop_id)
    if party_id ~= INVALID_ID then
        require "game.scenes.game.widgets.party-ui-widgets".render_party_overview(
            game,layout:next(rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT*4),party_id,
            function(rect)
				local party_name = ESTATE_NAME(party_id)
                local party_status = DATA.estate_get_current_status(party_id)
                local action_word = party_status and DATA.estate_status_get_action_string(party_status) or "!"
				local party_tooltip = party_name .. " is currently " .. action_word
					.. " in " .. PROVINCE_NAME(TILE_PROVINCE(ESTATE_TILE(party_id))) .. "."
				ib.text_button_to_party(game,party_id,rect,party_tooltip)
            end)
    else
        local empty_rect = layout:next(rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT)
        ui.panel(empty_rect,2,true,true)
        local text_rect = empty_rect:subrect(0,0,empty_rect.width-ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"left","up")
        ui.text("Individual",text_rect,"left","up")
        ui.tooltip(NAME(pop_id) .. " is not in a party!",text_rect)
        pui.render_warband_time(empty_rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"right","up"),pop_id)
    end

    local employer_id = pop_utils.get_employer_of(pop_id)
    if employer_id ~= INVALID_ID then
        render_employer_overview(game,layout:next(rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT*4),pop_id)
    else
        local empty_rect = layout:next(rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT)
        local text_rect = empty_rect:subrect(0,0,empty_rect.width-ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"left","up")
        ui.panel(empty_rect,2,true,true)
        ui.text("Unemployed",text_rect,"left","up")
        ui.tooltip(NAME(pop_id) .. " is not employed!",text_rect)
        pui.render_work_time(empty_rect:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"right","up"),pop_id)
    end

    local forage_label = layout:next(rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT)
    ui.text("Foraging", forage_label:subrect(0,0,forage_label.width - ut.BASE_HEIGHT*4, ut.BASE_HEIGHT,"left", "down"),"left")
    pui.render_forage_time(forage_label:subrect(0,0,ut.BASE_HEIGHT*3,ut.BASE_HEIGHT,"right","down"),pop_id)

    -- build forager methods table for list call
	local forager_methods = {}
    DATA.for_each_production_method(function (item)
		local ratio = DATA.culture_get_traditional_forager_targets(CULTURE(pop_id), item)
        if ratio > 0.001 then
		    forager_methods[item] = ratio
        end
	end)

    -- build forager methods list columns
    local columns = {
        {
            header = ".",
            render_closure = function(rect, k, v)
                ut.render_icon(rect,DATA.production_method_get_icon(k),
                    DATA.production_method_get_r(k),
                    DATA.production_method_get_g(k),
                    DATA.production_method_get_b(k),
                    1,
                    true)
                ui.tooltip(strings.title(DATA.production_method_get_name(k)),rect)
            end,
            width = 1,
            value = function (k, v)
                return k
            end
        },
        {
            header = "name",
            render_closure = function(rect, k, v)
                local name = strings.title(DATA.production_method_get_name(k))
                ui.text(name,rect,"center","center")
                ui.tooltip(name,rect)
            end,
            width = 5,
            value = function (k, v)
                return DATA.production_method_get_name(k)
            end
        },
        {
            header = "plan",
            render_closure = function(rect, k, v)
                local culture_id = CULTURE(pop_id)
                ut.generic_number_field("chart.png",v,rect,DATA.culture_get_name(culture_id)
                    .. " plans to spend " .. ut.to_fixed_point2(v*100)
                    .. "% of foraging time " .. DATA.production_method_get_description(k) .. ".",
                    ut.NUMBER_MODE.PERCENTAGE,ut.NAME_MODE.ICON)
            end,
            width = 3,
            value = function (k, v)
                return v
            end
        },
        {
            header = "time",
            render_closure = function(rect, k, v)
                local hisher = "his"
                if DATA.pop_get_female(pop_id) then
                    hisher = "her"
                end
                local culture_id = CULTURE(pop_id)
                local  _, _, forage_time, _ = POP_TIME(pop_id)
                local composite_time = v * forage_time
                local composite_plan = v * DATA.pop_get_forage_ratio(pop_id)
                ut.generic_number_field("stopwatch.png",composite_time,rect,NAME(pop_id)
                    .. " actually spends " .. ut.to_fixed_point2(composite_time*100)
                    .. "% of " .. hisher .. " time " .. DATA.production_method_get_name(k) .. "."
                    .. "\n " .. NAME(pop_id) .. " desires to spend " .. ut.to_fixed_point2(composite_plan*100)
                    .. "% of " .. hisher .. " time " .. DATA.production_method_get_description(k) .. ".",
                    ut.NUMBER_MODE.PERCENTAGE,ut.NAME_MODE.ICON)
            end,
            width = 3,
            value = function (k, v)
                local _, _, forage_time, _ = POP_TIME(pop_id)
                return v * forage_time
            end
        },
    }
    -- draw foraging table with remaining space
    local list_panel = layout:next(rect.width,rect.height-layout._pivot_y)
    forage_table_state = list_widget(list_panel, forager_methods, columns, forage_table_state)()
end
---draws pop weight and inventory
---@param game GameScene
---@param rect Rect
---@param pop_id pop_id
local function draw_ast_tab(game,rect,pop_id)
    local layout = ui.layout_builder():position(rect.x,rect.y):vertical():build()
    local property_tabs_rect = layout:next(rect.width,ut.BASE_HEIGHT)
    local property_list_rect = layout:next(rect.width,rect.height-ut.BASE_HEIGHT)
    local property_layout = ui.layout_builder():position(property_tabs_rect.x,property_tabs_rect.y):horizontal():build()
    property_tab = ut.tabs(property_tab, property_layout, {
        {
            text = "INVENTORY",
            tooltip = NAME(pop_id) .. "'s inventory.'",
            closure = function()
                local inventory_list = {}
                DATA.for_each_trade_good(function (item)
                    local amount = DATA.pop_get_inventory(pop_id, item)
                    if amount > 0 then
                        inventory_list[item] = amount
                    end
                end)
                property_inventory_state = require "game.scenes.game.widgets.character-inventory-list" (
                    game,
                    property_list_rect,
                    pop_id,
                    inventory_list,
                    property_inventory_state
                )()
            end
        },
        {
            text = "ESTATES",
            tooltip = NAME(pop_id) .. "'s owned estates.",
            closure = function()
                property_buildings_state = require "game.scenes.game.widgets.estates-list" (
                    game,
                    property_list_rect,
                    tabb.map_array(
                        DATA.filter_array_ownership_from_owner(
                            pop_id,
                            function (item) return true end
                        ),
                        DATA.ownership_get_estate
                    ),
                    property_buildings_state
                )()
            end
        }
    }, 1, (rect.width-ut.BASE_HEIGHT)/2)

end
---draws successor and tabs for parent-children or loyal_to-loyalty
---@param game GameScene
---@param rect Rect
---@param pop_id pop_id
local function draw_rel_tab(game,rect,pop_id)
    local player_id = WORLD.player_character
    local layout = ui.layout_builder():position(rect.x,rect.y):vertical():build()
    local successor_id = pop_utils.get_successor_of(pop_id)
    if successor_id ~= INVALID_ID then
        pui.render_pop_overview(game,layout:next(rect.width,ut.BASE_HEIGHT*4),successor_id,"Successor: " .. get_fullname(successor_id))
    else
        local empty_rect = layout:next(rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT)
        ui.panel(empty_rect,2,true,true)
        ui.text("No successor",empty_rect,"left","up")
        ui.tooltip(NAME(pop_id) .. " has no successor designated!",empty_rect)
    end
    local relation_tabs_rect = layout:next(rect.width,ut.BASE_HEIGHT)
    local relation_list_rect = layout:next(rect.width,rect.height-layout._pivot_y)
    local relations_layout = ui.layout_builder():position(relation_tabs_rect.x,relation_tabs_rect.y):horizontal():build()
    relations_tab = ut.tabs(relations_tab, relations_layout, {
        {
            text = "FAMILY",
            tooltip = "Parent and children",
            closure = function()
                local parent = PARENT(pop_id)
                local list_rect
                if parent and parent ~= INVALID_ID then
                    list_rect = relation_list_rect:subrect(0,0,relation_list_rect.width,relation_list_rect.height-ut.BASE_HEIGHT*4,"left","down")
                    local parent_rect = relation_list_rect:subrect(0,0,relation_list_rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT*4,"left","up")
                    ui.panel(parent_rect,2,true)
                    pui.render_pop_overview(game,parent_rect,parent,"Parent: " .. get_fullname(parent))
                else
                    list_rect = relation_list_rect:subrect(0,0,relation_list_rect.width,relation_list_rect.height-ut.BASE_HEIGHT,"left","down")
                    local parent_rect = relation_list_rect:subrect(0,0,relation_list_rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT,"left","up")
                    ui.panel(parent_rect,2,true,true)
                    ui.text("No parent",parent_rect,"left","up")
                    ui.tooltip(NAME(pop_id) .. " has no living parent!",parent_rect)
                end
                relations_family_state = require "game.scenes.game.widgets.character-list" (
                    game,
                    list_rect,
                    tabb.map_array(
                        DATA.filter_array_parent_child_relation_from_parent(
                            pop_id,
                            function (item) return true end
                        ),
                        DATA.parent_child_relation_get_child
                    ),
                    relations_family_state
                )()
            end
        },
        {
            text = "LOYALTY",
            tooltip = "Loyalties to and from " .. NAME(pop_id),
            closure = function()
                local loyal_to = LOYAL_TO(pop_id)
                local list_rect
                if loyal_to and loyal_to ~= INVALID_ID then
                    list_rect = relation_list_rect:subrect(0,0,relation_list_rect.width,relation_list_rect.height-ut.BASE_HEIGHT*4,"left","down")
                    local loyal_rect = relation_list_rect:subrect(0,0,relation_list_rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT*4,"left","up")
                    ui.panel(loyal_rect,2,true)
                    pui.render_pop_overview(game,loyal_rect,loyal_to,"Liege: " .. get_fullname(loyal_to))
                else
                    list_rect = relation_list_rect:subrect(0,0,relation_list_rect.width,relation_list_rect.height-ut.BASE_HEIGHT,"left","down")
                    local loyal_rect = relation_list_rect:subrect(0,0,relation_list_rect.width-ut.BASE_HEIGHT,ut.BASE_HEIGHT,"left","up")
                    ui.panel(loyal_rect,2,true,true)
                    ui.text("No allegiance",loyal_rect,"left","up")
                    ui.tooltip(NAME(pop_id) .. " has not sworn loyalty to anyone!",loyal_rect)
                end
                relations_loyalty_state = require "game.scenes.game.widgets.character-list" (
                    game,
                    list_rect,
                    tabb.map_array(
                        DATA.filter_array_loyalty_from_top(
                            pop_id,
                            function (item) return true end
                        ),
                        DATA.loyalty_get_bottom
                    ),
                    relations_loyalty_state
                )()
            end
        }
    }, 1, (relation_list_rect.width-ut.BASE_HEIGHT)/2)
end
---draw actions/decisions panel tab
---@param game GameScene
---@param rect Rect
---@param pop_id pop_id
local function draw_dcs_tab(game, rect, pop_id)
    -- decision panel
    local decisions_layout = ui.layout_builder():position(rect.x,rect.y):vertical():build()
    local decisions_label_panel =           decisions_layout:next(rect.width, ut.BASE_HEIGHT * 1)
    local decisions_panel =                 decisions_layout:next(rect.width, rect.height-ut.BASE_HEIGHT*2)
    local decisions_confirmation_panel =    decisions_layout:next(rect.width, ut.BASE_HEIGHT * 1)
    ui.panel(decisions_confirmation_panel,2,true)

    -- decisions view

    -- First, we need to check if the player is controlling a realm
    local player_id = WORLD.player_character
    if player_id ~= INVALID_ID then
        ui.centered_text("Decisions:", decisions_label_panel)
        selected_decision, decision_target_primary, decision_target_secondary = require "game.scenes.game.widgets.decision-selection-character"(
            decisions_panel,
            "character",
            pop_id,
            selected_decision
        )
    else
        -- No player realm: no decisions to draw
    end
    local res = require "game.scenes.game.widgets.decision-desc"(
        decisions_confirmation_panel,
        player_id,
        selected_decision,
        decision_target_primary,
        decision_target_secondary
    )
    if res ~= "nothing" then
        selected_decision = nil
        decision_target_primary = nil
        decision_target_secondary = nil
    end
end

-- CHARACTER INSPECTOR LAYOUT

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	local panel = fs:subrect(ut.BASE_HEIGHT * 2, 0, ut.BASE_HEIGHT * 16, ut.BASE_HEIGHT * 25, "left", "down")
	return panel
end

function window.mask()
    if ui.trigger(get_main_panel()) then
		return false
	else
		return true
	end
end

---Draw character window
---@param game GameScene
function window.draw(game)
    local character_id = game.selected.character
    local player_id = WORLD.player_character


    --display at least that character inspector is open
    local ui_panel = get_main_panel()
    -- draw a panel
    ui.panel(ui_panel)

    -- validate player_id
    if not DCON.dcon_pop_is_valid(player_id-1) then
        player_id = INVALID_ID
    end

    -- validate character_id
    if character_id == INVALID_ID then
        return
    -- should have DATA validate calls for all objects
    elseif not DCON.dcon_pop_is_valid(character_id) then
        return
    end

    if DEAD(character_id) then
        return
    end

    local layout = ui.layout_builder():position(ui_panel.x, ui_panel.y):vertical():build()

    -- header : inspector name and close button
    ib.render_inspector_header(game,layout:next(ui_panel.width,ut.BASE_HEIGHT),"Character View")

--#region top
    -- top panel : portrait and general info
    local top_panel_rect = layout:next(ui_panel.width,ut.BASE_HEIGHT*5)

    pui.render_pop_overview(game,top_panel_rect,character_id,get_fullname(character_id))

    local title_panel = top_panel_rect:subrect(0,ut.BASE_HEIGHT,top_panel_rect.width-ut.BASE_HEIGHT*4,ut.BASE_HEIGHT,"right","up")
    ui.text(character_name_widget(character_id),title_panel,"left","center")
--#endregion top

--#region mid
    -- middle panel : statistics
    local stats_tab_panel = layout:next(ui_panel.width,ut.BASE_HEIGHT*3)
    local stats_tab_layout = ui.layout_builder():position(stats_tab_panel.x,stats_tab_panel.y):vertical():build()
    stats_tab_panel.x = stats_tab_panel.x + ut.BASE_HEIGHT*3
    stats_tab_panel.width = stats_tab_panel.width - ut.BASE_HEIGHT*3

    local spacing, draw_width = 5, ut.BASE_HEIGHT*3
    local border_panel = stats_tab_panel:subrect(0,spacing,stats_tab_panel.width-spacing,stats_tab_panel.height-spacing,"left","up")
    ui.panel(border_panel,2,true)

    stats_tab = ut.tabs(stats_tab, stats_tab_layout,{
		{
			text = "TRT",
			tooltip = "Traits",
			closure = function()
                -- trait panel : grid of trait icons with tooltips
                local line_count = math.floor((border_panel.width-spacing) / (ut.BASE_HEIGHT+spacing))
                local trait_layout = ui.layout_builder()
                    :position(border_panel.x+spacing,border_panel.y+spacing)
                    :spacing(spacing)
                    :grid(line_count)
                    :build()
                for i = 1, 22 do --MAX_TRAIT_INDEX do
                  local trait = DATA.pop_get_traits(character_id, i)
                    if trait == INVALID_ID then
                        break
                    end
                    local trait_rect = trait_layout:next(ut.BASE_HEIGHT,ut.BASE_HEIGHT)
                    ui.panel(trait_rect,2,true)
                    ut.render_icon(trait_rect,DATA.trait_get_icon(trait),1,1,1,1)
                    ui.tooltip(strings.title(DATA.trait_get_name(trait):lower()),trait_rect)
                end
			end
		},
		{
			text = "ATR",
			tooltip = "Attributes",
			closure = function()
                spacing = (border_panel.height-ut.BASE_HEIGHT*2)/2
                local offset = (border_panel.width-draw_width*4)/2
                local attrib_layout = ui.layout_builder()
                    :position(border_panel.x+offset,border_panel.y+spacing)
                    :grid(4)
                    :build()
                -- top row
                pui.render_size(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
                pui.render_spotting(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
                pui.render_visibility(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
                pui.render_supply_capacity(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
                -- bottom row
                pui.render_health(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
                pui.render_armor(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
                pui.render_attack(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
                pui.render_speed(attrib_layout:next(draw_width,ut.BASE_HEIGHT),character_id)
            end
        },
		{
			text = "EFF",
			tooltip = "Job efficiencies",
			closure = function()
                spacing = (border_panel.width-draw_width*4-10)/3
                local offset = (border_panel.height-ut.BASE_HEIGHT*2-spacing)/2
                local effic_layout = ui.layout_builder()
                    :position(border_panel.x+spacing,border_panel.y+offset)
                    :spacing(spacing)
                    :grid(4)
                    :build()
                for i=1, tabb.size(JOBTYPE)-1 do
                    pui.render_job_efficiency(effic_layout:next(draw_width,ut.BASE_HEIGHT),character_id,i)
                end
			end
		}
	}, 1, ut.BASE_HEIGHT * 3)
--#endregion mid

--#region bot
    -- bot panel : tabs to work/warband, inventory, relationships, decisions
    local tabs_layout_rect = layout:next(ui_panel.width,ut.BASE_HEIGHT)
    local tabs_layout = ui.layout_builder()
        :position(tabs_layout_rect.x+tabs_layout_rect.width,tabs_layout_rect.y)
            :horizontal(true)
            :build()
    local tabs_panel_rect = layout:next(ui_panel.width, ui_panel.height-layout._pivot_y)
    ui.panel(tabs_panel_rect,2,true)

    character_tab = ut.tabs(character_tab, tabs_layout,{
        {
			text = "DCS",
			tooltip = "Actions and decisions",
			closure = function()
				draw_dcs_tab(game,tabs_panel_rect,character_id)
			end
		},
		{
			text = "PRP",
			tooltip = "Property and inventory",
			closure = function()
				draw_ast_tab(game,tabs_panel_rect,character_id)
			end
		},
		{
			text = "WRK",
			tooltip = "Work and foraging",
			closure = function()
				draw_wrk_tab(game,tabs_panel_rect,character_id)
			end
		},
		{
			text = "REL",
			tooltip = "Family and loyalties",
			closure = function()
				draw_rel_tab(game,tabs_panel_rect,character_id)
			end
		},
	}, 1, ut.BASE_HEIGHT * 3)
--#endregion bot_panel
end

return window
