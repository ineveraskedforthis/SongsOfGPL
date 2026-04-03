local strings = require "engine.string"
local ui = require "engine.ui"
local ut = require "game.ui-utils"

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

---@class PartyInventoryEntry
---@field id trade_good_id
---@field calories number
---@field amount number

---@param game GameScene
---@param rect Rect
---@param party warband_id
---@param state TableState?
---@param title string?
---@param compact boolean?
return function(game, rect, party, state, title, compact)
    if compact == nil then
        compact = false
    end

    ---@type PartyInventoryEntry[]
    local inventory = {}
    local province = TILE_PROVINCE(ESTATE_TILE(party))
    DATA.for_each_trade_good(function (item)
        ---@type PartyInventoryEntry
        local inventory_item = {
            id = item,
            price = DATA.province_get_local_prices(province, item),
            amount = DATA.warband_get_inventory(party, item),
        }

        table.insert(inventory, inventory_item)
    end)

    return function()
        ---@type TableColumn<PartyInventoryEntry>[]
        local columns = {
            {
                header = ".",
                ---commenting
                ---@param rect Rect
                ---@param _ any
                ---@param v PartyInventoryEntry
                render_closure = function(rect, _, v)
                    ut.render_icon(rect,
                        DATA.trade_good_get_icon(v.id),
                        DATA.trade_good_get_r(v.id),
                        DATA.trade_good_get_g(v.id),
                        DATA.trade_good_get_b(v.id),
                        1, true)
                    ui.tooltip(strings.title(DATA.trade_good_get_name(v.id)),rect)
                end,
                width = 1,
                ---@param v PartyInventoryEntry
                value = function(k, v)
                    return k
                end
            },
            {
                header = "price",
                ---@param v PartyInventoryEntry
                render_closure = function (rect, _, v)
                    ut.generic_number_field(
                        "",
                        v.price,
                        rect,
                        nil,
                        ut.NUMBER_MODE.MONEY,
                        ut.NAME_MODE.NAME,
                        true)
                end,
                width = 2,
                ---@param v PartyInventoryEntry
                value = function(k, v)
                    return v.price
                end
            },
            {
                header = "amount",
                ---@param v PartyInventoryEntry
                render_closure = function (rect, _, v)
                    ut.generic_number_field(
                        "",
                        v.amount,
                        rect,
                        ut.to_fixed_point2(v.amount) .. " " .. DATA.trade_good_get_name(v.id) .. " in inventory.",
                        ut.NUMBER_MODE.NUMBER,
                        ut.NAME_MODE.NAME,
                        true)
                end,
                width = 2,
                ---@param v PartyInventoryEntry
                value = function(k, v)
                    return v.amount
                end
            },
            {
                header = "buy/sell",
                ---@param v PartyInventoryEntry
                render_closure = function (rect, _, v)
                    ut.render_icon(rect:subrect(0,0,rect.width/2,rect.height,"right","up"),"plus.png",1,1,1,1)
                    ut.render_icon(rect:subrect(0,0,rect.width/2,rect.height,"left","up"),"minus.png",1,1,1,1)
                end,
                width = 2,
                ---@param v PartyInventoryEntry
                value = function(k, v)
                    return v.price
                end
            },
            {
                header = "transfer",
                ---@param v PartyInventoryEntry
                render_closure = function (rect, _, v)
                    ut.render_icon(rect:subrect(0,0,rect.width/2,rect.height,"right","up"),"plus.png",1,1,1,1)
                    ut.render_icon(rect:subrect(0,0,rect.width/2,rect.height,"left","up"),"minus.png",1,1,1,1)
                end,
                width = 2,
                ---@param v PartyInventoryEntry
                value = function(k, v)
                    return v.amount
                end
            }
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
        ut.table(bottom, inventory, columns, state)
        return state
    end
end