---@alias TradeGoodReference string

---@class (exact) TradeGood
---@field __index TradeGood
---@field name TradeGoodReference
---@field icon string
---@field description string
---@field r number
---@field g number
---@field b number
---@field category TradeGoodCategory
---@field base_price number
---@field use_cases table<TradeGoodUseCaseReference, number> Maps use cases to their weights

---@alias TradeGoodCategory "good" | "service" | "capacity"

---@class TradeGood
local TradeGood = {}
TradeGood.__index = TradeGood
---Creates a new trade good
---@param o TradeGood
---@return TradeGood
function TradeGood:new(o)
	if RAWS_MANAGER.do_logging then
		print("Trade Good: " .. tostring(o.name))
	end
	---@type TradeGood
	local r = {}

	r.name = "<trade good>"
	r.icon = "uncertainty.png"
	r.description = "<trade good description>"
	r.r = 0
	r.g = 0
	r.b = 0
	r.category = "good"
	r.base_price = 10
	r.use_cases = {}

	for k, v in pairs(o) do
		r[k] = v
	end
	setmetatable(r, TradeGood)
	if RAWS_MANAGER.trade_goods_by_name[r.name] ~= nil then
		local msg = "Failed to load a trade good (" .. tostring(r.name) .. ")"
		print(msg)
		error(msg)
	end

	RAWS_MANAGER.trade_goods_by_name[r.name] = r
	table.insert(RAWS_MANAGER.trade_goods_list, r.name)
	RAWS_MANAGER.trade_good_to_index[r.name] = #RAWS_MANAGER.trade_goods_list

	return o
end

return TradeGood
