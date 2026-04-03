local ui = require "engine.ui"
local ut = require "game.ui-utils"
local ev = require "game.raws.values.economy"
local ef = require "game.raws.effects.economy"
local et = require "game.raws.triggers.economy"


local inspector = {}

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	return fs:subrect(ut.BASE_HEIGHT * 2, 0, ut.BASE_HEIGHT * 16, ut.BASE_HEIGHT * 25, "left", "down")
end

---Returns whether or not clicks on the planet can be registered.
---@return boolean
function inspector.mask()
	if ui.trigger(get_main_panel()) then
		return false
	else
		return true
	end
end


local TRADE_AMOUNT = 1

---@type TableState
local state = nil

local function init_state(base_unit)
    if state == nil then
        state = {
            header_height = base_unit,
            individual_height = base_unit,
            slider_level = 0,
            slider_width = base_unit,
            sorted_field = 1,
            sorting_order = true
        }
    else
        state.header_height = base_unit
        state.individual_height = base_unit
        state.slider_width = base_unit
    end
end


---@class (exact) ItemDataCollapsed
---@field item trade_good_id
---@field name string
---@field r number
---@field g number
---@field b number
---@field icon string
---@field supply number
---@field demand number
---@field price number
---@field stockpile number
---@field inventory number

---comment
---@param province Province
---@param ui_panel Rect
---@param base_unit number
---@param gam GameScene
---@return function
local function draw_market_body (province, ui_panel, base_unit, gam)
	---@type pop_id
	local player = WORLD.player_character

    ---@type TableColumn<ItemDataCollapsed>[]
    local columns = {
        {
            header = ".",
			---commenting
			---@param rect Rect
			---@param v ItemDataCollapsed
            render_closure = function(rect, k, v)
                ut.render_icon(rect:copy():shrink(-1), v.icon, 1, 1, 1, 1)
                ut.render_icon(rect, v.icon, v.r, v.g, v.b, 1)
				ui.tooltip(v.name, rect)
            end,
            width = base_unit * 1,
			---@param v ItemDataCollapsed
            value = function(k, v)
                return v.name
            end
        },
        {
            header = "Balance",
			---@param v ItemDataCollapsed
            render_closure = function(rect, k, v)
                ut.balance_entry("", v.supply - v.demand, rect, "Supply:" .. tostring(v.supply) .. "\nDemand:" .. tostring(v.demand) .. "\nSatisfaction:" .. ut.to_fixed_point2(DATA.province_get_local_satisfaction(province, v.item) * 100) .. "%")
            end,
            width = base_unit * 3,
			---@param v ItemDataCollapsed
            value = function(k, v)
                return v.supply - v.demand
            end
        },
        {
            header = "Price",
			---@param v ItemDataCollapsed
            render_closure = function(rect, k, v)
                ut.money_entry("", v.price or 0, rect)
            end,
            width = base_unit * 3,
			---@param v ItemDataCollapsed
            value = function(k, v)
                return v.price or 0
            end
        },
        {
            header = "Difference",
			---@param v ItemDataCollapsed
            render_closure = function(rect, k, v)
                local tooltip = "Shows the diffence between buy price in your current position and sell price in selected one"
				local player_province = POP_PROVINCE(player)
				if province == INVALID_ID then
					ut.data_entry("", "???", rect, tooltip)
				end

				local price_at_player = ev.get_local_price(player_province, v.item)
				local price_to_compare_with = v.price

				local data = 1
				if price_at_player == 0 and price_to_compare_with == 0 then
					data = 0
				elseif price_at_player == 0 then
					data = 99.99
				elseif price_to_compare_with == 0 then
					data = 0
				else
					data = (price_to_compare_with - price_at_player) / price_at_player
				end
				ut.color_coded_percentage(
					data,
					rect,
					true,
					tooltip
				)
            end,
            width = base_unit * 3,
			---@param v ItemDataCollapsed
            value = function(k, v)
                local player_province = POP_PROVINCE(player)

				if player_province == INVALID_ID then
					return 0
				end

				local price_at_player = ev.get_local_price(player_province, v.item)
				local price_to_compare_with = v.price

				local data = 1
				if price_at_player == 0 and price_to_compare_with == 0 then
					data = 0
				elseif price_at_player == 0 then
					data = 99.99
				elseif price_to_compare_with == 0 then
					data = 0
				else
					data = (price_to_compare_with - price_at_player) / price_at_player
				end

				return data
            end
        },
        {
            header = "Stockpile",
			---@param v ItemDataCollapsed
            render_closure = function(rect, k, v)
                ut.sqrt_number_entry("", v.stockpile, rect)
            end,
            width = base_unit * 3,
			---@param v ItemDataCollapsed
            value = function(k, v)
                return v.stockpile
            end
        },
        {
            header = "Your",
            render_closure = function(rect, k, v)
                ---@type ItemData
                v = v
                ut.sqrt_number_entry("", v.inventory, rect)
            end,
            width = base_unit * 3,
            value = function(k, v)
                ---@type ItemData
                v = v
                return v.inventory
            end
        },
        {
            header = "Map",
            render_closure = function (rect, k, v)
                ---@type ItemData
                v = v

                if ut.icon_button(ASSETS.icons['mesh-ball.png'], rect, "Show price on map") then
                    HACKY_MAP_MODE_CONTEXT_TRADE_CATEGORY = v.item
                    gam.update_map_mode("prices")
                end
            end,
            width = base_unit * 2,
            value = function (k, v)
                return v.tag
            end,
            active = true
        }
    }


    return function()
        --- local economy data
        local uip = ui_panel:copy()
        init_state(base_unit)

        --- local market
        ---@type table<string, ItemDataCollapsed>
        local data_blob = {}

        if ui.is_key_held("lshift") or ui.is_key_held("rshift") then
            TRADE_AMOUNT = 5
        elseif ui.is_key_held("lctrl") or ui.is_key_held("rctrl") then
            TRADE_AMOUNT = 50
        else
            TRADE_AMOUNT = 1
        end

        for good_name, good_id in pairs(RAWS_MANAGER.trade_goods_by_name) do
            local good_supply = DATA.province_get_local_production(province, good_id)
            local good_demand = DATA.province_get_local_demand(province, good_id)
            local good_consumption = DATA.province_get_local_consumption(province, good_id)
            local inventory = 0
            if player ~= INVALID_ID then
                inventory =  DATA.pop_get_inventory(player, good_id)
            end
            local local_storage = DATA.province_get_local_storage(province, good_id)
            if
                inventory > 0
                or good_supply > 0
                or good_consumption > 0
                or local_storage > 0
                or good_demand > 0
            then
                local good = DATA.fatten_trade_good(good_id)
                data_blob[good_name] = {
                    name = good.description,
                    icon = good.icon,
                    item = good.id,
                    r = good.r,
                    g = good.g,
                    b = good.b,
                    supply = good_supply,
                    demand = good_demand,
                    consumption = good_consumption,
                    balance = good_supply - good_consumption,
                    stockpile = local_storage,
                    price = ev.get_local_price(province, good_id),
                    inventory = inventory
                }
            end
        end

        ut.table(uip, data_blob, columns, state)
    end
end

---comment
---@param gam GameScene
function inspector.draw(gam)
    local rect = get_main_panel()

    ui.panel(rect)

    if ut.icon_button(ASSETS.icons["cancel.png"], rect:subrect(0, 0, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "right", "up")) then
        gam.inspector = "tile"
    end

    local province = gam.selected.province

    if province == nil then
        return
    end

    local base_unit = ut.BASE_HEIGHT

    local wealth_data_rect = rect:subrect(0, 0, base_unit * 9, base_unit, "left", "up")

    local fat = DATA.fatten_province(province)
    ut.money_entry("Trade wealth:", fat.trade_wealth, wealth_data_rect)
    wealth_data_rect.x = wealth_data_rect.x + wealth_data_rect.width + base_unit

    rect.y = rect.y + base_unit
    rect.height = rect.height - base_unit

    draw_market_body(province, rect, base_unit, gam)()
end

return inspector