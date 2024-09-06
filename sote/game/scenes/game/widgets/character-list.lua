local tabb = require "engine.table"
local ui = require "engine.ui"
local ut = require "game.ui-utils"

local portrait = require "game.scenes.game.widgets.portrait"

---@type TableState
local state = nil

---comment
---@param compact boolean
local function init_state(compact)
    local entry_height = UI_STYLE.scrollable_list_item_height
    if compact then
        entry_height = UI_STYLE.scrollable_list_small_item_height
    end

    if state == nil then
        state = {
            header_height = UI_STYLE.table_header_height,
            individual_height = entry_height,
            slider_level = 0,
            slider_width = UI_STYLE.slider_width,
            sorted_field = 1,
            sorting_order = true
        }
    else
        state.header_height = UI_STYLE.table_header_height
        state.individual_height = entry_height
        state.slider_width = UI_STYLE.slider_width
    end
end

local function render_name(rect, k, v)
    if ut.text_button(DATA.pop_get_name(v), rect) then
        return v
    end
end

local function render_race(rect, k, v)
    ui.centered_text(v.race.name, rect)
end

---commenting
---@param pop pop_id
---@return string
local function pop_sex(pop)
    local f = "m"
    if DATA.pop_get_female(pop) then f = "f" end
    return f
end

---@param rect Rect
---@param table POP[]
---@param title string?
---@param compact boolean?
return function(rect, table, title, compact)
    if compact == nil then
        compact = false
    end

    local portrait_width = UI_STYLE.scrollable_list_item_height
    if compact then
        portrait_width = UI_STYLE.scrollable_list_small_item_height
    end

    local rest_width = rect.width - portrait_width
    local width_unit = rest_width / 12
    return function()
        ---@type TableColumn<pop_id>[]
        local columns = {
            {
                header = ".",
                render_closure = function(rect, k, v)
                    portrait(rect, v)
                end,
                width = portrait_width,
                value = function(k, v)
                    ---@type POP
                    v = v
                    local race = DATA.pop_get_race(v)
                    return DATA.race_get_name(race)
                end
            },
            {
                header = "name",
                render_closure = render_name,
                width = width_unit * 7,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return DATA.pop_get_name(v)
                end,
                active = true
            },
            {
                header = "age",
                render_closure = function (rect, k, v)
                    ui.right_text(tostring(DATA.pop_get_age(v)), rect)
                end,
                width = width_unit * 3,
                value = function(k, v)
                    return DATA.pop_get_age(v)
                end
            },
            {
                header = "sex",
                render_closure = function (rect, k, v)
                    ui.centered_text(pop_sex(v), rect)
                end,
                width = width_unit * 1,
                value = function(k, v)
                    return pop_sex(v)
                end
            }
        }
        init_state(compact)
        local bottom_height = rect.height
        local bottom_y = 0
        if title then
            bottom_height = bottom_height - UI_STYLE.table_header_height
            bottom_y = UI_STYLE.table_header_height
            local top = rect:subrect(0, 0, rect.width, UI_STYLE.table_header_height, "left", "up")
            ui.centered_text(title, top)
        end
        local bottom = rect:subrect(0, bottom_y, rect.width, bottom_height, "left", "up")
        return ut.table(bottom, table, columns, state)
    end
end