
local dbm = require "game.economy.diet-breadth-model"
local tile_utils = require "game.entities.tile"

local ProductionMethod = {}

---@class production_method_id_data_blob_definition_extended : production_method_id_data_blob_definition
---@field inputs table<use_case_id, number>
---@field outputs table<trade_good_id, number>
---@field job job_id

---Creates a new production method
---@param o production_method_id_data_blob_definition_extended
---@return production_method_id
function ProductionMethod:new(o)
	if RAWS_MANAGER.do_logging then
		print("ProductionMethod: " .. o.name)
	end

	local new_id = DATA.create_production_method()
	DATA.setup_production_method(new_id, o)

	local input_index = 1
	for use_case, amount in pairs(o.inputs) do
		DATA.production_method_set_inputs_amount(new_id, input_index, amount)
		DATA.production_method_set_inputs_use(new_id, input_index, use_case)
		input_index = input_index + 1
	end

	local output_index = 1
	for good, amount in pairs(o.outputs) do
		DATA.production_method_set_outputs_amount(new_id, output_index, amount)
		DATA.production_method_set_outputs_good(new_id, output_index, good)
		output_index = output_index + 1
	end

	if RAWS_MANAGER.production_methods_by_name[o.name] ~= nil then
		local msg = "Failed to load a production method (" .. tostring(o.name) .. ")"
		print(msg)
		error(msg)
	end
	RAWS_MANAGER.production_methods_by_name[o.name] = new_id
	return new_id
end

return ProductionMethod
