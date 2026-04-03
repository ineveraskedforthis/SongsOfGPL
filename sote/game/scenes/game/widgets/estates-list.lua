local tabb = require "engine.table"
local strings = require "engine.string"
local ui = require "engine.ui"
local ut = require "game.ui-utils"
local ib = require "game.scenes.game.widgets.inspector-redirect-buttons"
local pui = require "game.scenes.game.widgets.pop-ui-widgets"
local portrait = require "game.scenes.game.widgets.portrait"

---comment
---@param state TableState?
---@param compact boolean
---@return TableState
local function init_state(state, compact)
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
    return state
end

---@param rect Rect
---@param table estate_id[]
---@param state TableState?
---@param title string?
---@param compact boolean?
return function(game, rect, table, state, title, compact)
    if compact == nil then
        compact = false
    end

    return function()
        ---@type TableColumn<estate_id>[]
        local columns = {
            {
                header = ".",
                render_closure = function(rect, k, v)
                    local owner = OWNER(v)
                    ib.icon_button_to_estate(game,v,INVALID_ID,rect, owner == INVALID_ID and ("Public estate in " .. PROVINCE_NAME(ESTATE_PROVINCE(v)))
                        or ("Estate of " .. NAME(owner) .. "."))

                end,
                width = 1,
                value = function(k, v)
                    return DATA.estate_get_balance_last_tick(v)
                end,
            },
            {
                header = "profit",
                render_closure = function(rect, k, v)
                    ut.generic_number_field(
                        "receive-money.png",
                        DATA.estate_get_balance_last_tick(v),
                        rect,
                        "This build gained " .. ut.to_fixed_point2(DATA.estate_get_balance_last_tick(v)) .. MONEY_SYMBOL .. " last month.",
                        ut.NUMBER_MODE.BALANCE,
                        ut.NAME_MODE.ICON,
                        true)

                end,
                width = 3,
                value = function(k, v)
                    return DATA.estate_get_balance_last_tick(v)
                end,
            },
            {
                header = "savings",
                render_closure = function(rect, k, v)
                    ut.generic_number_field(
                        "coins.png",
                        DATA.estate_get_savings(v),
                        rect,
                        "This build has " .. ut.to_fixed_point2(DATA.estate_get_savings(v)) .. MONEY_SYMBOL .. " in savings.",
                        ut.NUMBER_MODE.BALANCE,
                        ut.NAME_MODE.ICON,
                        true)

                end,
                width = 3,
                value = function(k, v)
                    return DATA.estate_get_savings(v)
                end,
            },
            {
                header = "location",
                render_closure = function(rect, k, v)
                    local province_id = ESTATE_PROVINCE(v)
                    ib.text_button_to_province_tile(game,DATA.province_get_center(province_id),rect,
                        "Estate in is in the province of " .. PROVINCE_NAME(province_id) .. ".")
                end,
                width = 4,
                value = function(k, v)
                    return PROVINCE_NAME(ESTATE_PROVINCE(v))
                end,
            },
            {
                header = "rlm",
                render_closure = function(rect, k, v)
                    local realm_id = PROVINCE_REALM(ESTATE_PROVINCE(v))
                    ib.icon_button_to_realm(game,realm_id,rect,
                        "Estate in is in the realm of " .. REALM_NAME(realm_id) .. ".")
                end,
                width = 1,
                value = function(k, v)
                    return PROVINCE_REALM(ESTATE_PROVINCE(v))
                end,
            },
        }
        state = init_state(state, compact)
        local bottom_height = rect.height
        local bottom_y = 0
        if title then
            bottom_height = bottom_height - UI_STYLE.table_header_height
            bottom_y = UI_STYLE.table_header_height
            local top = rect:subrect(0, 0, rect.width, UI_STYLE.table_header_height, "left", "up")
            ui.centered_text(title, top)
        end
        local bottom = rect:subrect(0, bottom_y, rect.width, bottom_height, "left", "up")
        ut.table(bottom, table, columns, state)
        return state
    end
end