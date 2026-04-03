local tabb = require "engine.table"
local ui = require "engine.ui"
local ut = require "game.ui-utils"
local pui = require "game.scenes.game.widgets.pop-ui-widgets"

local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"

---@type TableState
local state = nil

local function init_state(base_unit)
    if state == nil then
        state = {
            header_height = UI_STYLE.table_header_height,
            individual_height = UI_STYLE.scrollable_list_item_height,
            slider_level = 0,
            slider_width = UI_STYLE.slider_width,
            sorted_field = 1,
            sorting_order = true
        }
    else
        state.header_height = UI_STYLE.table_header_height
        state.individual_height = UI_STYLE.scrollable_list_item_height
        state.slider_width = UI_STYLE.slider_width
    end
end

local function render_name(rect, k, v)
    local fat = DATA.fatten_pop(v)
    local name = fat.name
    local children = 0
    DATA.for_each_parent_child_relation_from_parent(v, function (item)
        children = children + 1
    end)

    local has_parent = DATA.get_parent_child_relation_from_child(v)
    local parent = DATA.parent_child_relation_get_parent(has_parent)
    if parent ~= INVALID_ID then
        name = name .. " [" .. NAME(parent) .. "]"
    end
    if children > 0 then
        name = name .. " (" .. children .. ")"
    end
    ui.left_text(name, rect)
end

---@param rect Rect
---@param base_unit number
---@param province Province
return function(gam, rect, base_unit, province)
    return function()
        ---@type TableColumn[]
        local columns = {
            {
                header = "realm",
                render_closure = function(rect, k, v)
                    --ui.image(ASSETS.get_icon(v.race.icon)
                    ib.icon_button_to_realm(gam, REALM(v), rect, DATA.realm_get_name(REALM(v)))
                end,
                width = 1,
                value = function (k, v)
                    return DATA.realm_get_name(REALM(v))
                end
            },
            {
                header = ".",
                render_closure = function(rect, k, v)
                    --ui.image(ASSETS.get_icon(v.race.icon)
                    ib.icon_button_to_character(gam, v, rect, pui.pop_tooltip(v))
                end,
                width = 1,
                value = function (k, v)
                    return DATA.pop_get_rank(v)
                end
            },
            {
                header = "name",
                render_closure = render_name,
                width = 6,
                value = function (k, v)
                    return NAME(v)
                end
            },
            {
                header = "race",
                render_closure = function (rect, k, v)
                    ui.render_race_icon(rect, RACE(v), ui.race_tooltip(RACE(v)))
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return DATA.race_get_name(RACE(v))
                end
            },
            {
                header = "sex",
                render_closure = function (rect, k, v)
                    pui.render_female_icon(rect, v)
                end,
                width = 1,
                value = function(k, v)
                    return DATA.pop_get_female(v) and "f" or "m"
                end
            },
            {
                header = "age",
                render_closure = function (rect, k, v)
                    pui.render_age(rect, v, "right")
                end,
                width = 1,
                value = function(k, v)
                    return DCON.age_ticks(v)
                end
            },
            {
                header = "culture",
                render_closure = function (rect, k, v)
                    ui.render_culture_icon(rect, CULTURE(v), ui.culture_tooltip(CULTURE(v)))
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return DATA.culture_get_name(CULTURE(v))
                end
            },
            {
                header = "faith",
                render_closure = function (rect, k, v)
                    ui.render_faith_icon(rect,DATA.pop_get_faith(v), ui.faith_tooltip(DATA.pop_get_faith(v)))
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return DATA.faith_get_name(DATA.pop_get_faith(v))
                end
            },
            {
                header = "job",
                render_closure = function (rect, k, v)
                    pui.render_occupation_icon(rect, v, pui.occupation_tooltip(v))
                end,
                width = 1,
                value = function(k, v)
                    return pui.occupation_name(v)
                end
            },
            {
                header = "income",
                render_closure = function (rect, k, v)
                    pui.render_pending_income(rect, v)
                end,
                width = 2,
                value = function (k, v)
                    return DATA.pop_get_pending_economy_income(v)
                end
            },
            {
                header = "spending",
                render_closure = function (rect, k, v)
                    pui.render_spending_ratio(rect, v)
                end,
                width = 2,
                value = function (k, v)
                    return DATA.pop_get_spend_savings_ratio(v)
                end
            },
            {
                header = "savings",
                render_closure = function (rect, k, v)
                    pui.render_savings(rect, v)
                end,
                width = 4,
                value = function (k, v)
                    return DATA.pop_get_savings(v)
                end
            },
            {
                header = "inventory",
                render_closure = function (rect, k, v)
                    pui.render_inventory(rect, v)
                end,
                width = 2,
                value = function(k, v)
                    local inventory_size = 0
                    DATA.for_each_trade_good(function (item)
                        local amount = DATA.pop_get_inventory(v, item)
                        inventory_size = inventory_size + amount
                    end)
                    return inventory_size
                end
            },
            {
                header = "satisfac.",
                render_closure = function (rect, k, v)
                    pui.render_basic_needs_satsifaction(rect, v)
                end,
                width = 2,
                value = function (k, v)
                    return DATA.pop_get_basic_needs_satisfaction(v)
                end
            },
            {
                header = "life needs",
                render_closure = function (rect, k, v)
                    pui.render_life_needs_satsifaction(rect, v)
                end,
                width = 2,
                value = function (k, v)
                    return DATA.pop_get_life_needs_satisfaction(v)
                end
            },
        }
        init_state(base_unit)
        local top = rect:subrect(0, 0, rect.width, base_unit, "left", "up")
        local bottom = rect:subrect(0, base_unit, rect.width, rect.height - base_unit, "left", "up")
        ui.centered_text("Population", top)
        local pops = DATA.filter_pop(function (item)
            return POP_PROVINCE(item) == province
        end)

        ut.table(bottom,pops, columns, state)
    end
end