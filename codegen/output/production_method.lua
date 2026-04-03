local ffi = require("ffi")
----------production_method----------


---production_method: LSP types---

---Unique identificator for production_method entity
---@class (exact) production_method_id : table
---@field is_production_method number
---@class (exact) fat_production_method_id
---@field id production_method_id Unique production_method id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field job_type JOBTYPE 
---@field job job_id 
---@field self_sourcing_fraction number percentage of work done without input goods
---@field foraging FORAGE_RESOURCE If not invalid, pulls from tile forage_resource
---@field nature_yield_dependence number How much does the local flora and fauna impact this buildings yield? Defaults to 0
---@field forest_dependence number Consumes local forests at this rate
---@field crop boolean If true, the building will periodically change its yield for a season.
---@field temperature_ideal_min number 
---@field temperature_ideal_max number 
---@field temperature_extreme_min number 
---@field temperature_extreme_max number 
---@field rainfall_ideal_min number 
---@field rainfall_ideal_max number 
---@field rainfall_extreme_min number 
---@field rainfall_extreme_max number 
---@field clay_ideal_min number 
---@field clay_ideal_max number 
---@field clay_extreme_min number 
---@field clay_extreme_max number 

---@class struct_production_method
---@field r number 
---@field g number 
---@field b number 
---@field job_type JOBTYPE 
---@field job job_id 
---@field inputs table<number, struct_use_case_container> 
---@field outputs table<number, struct_trade_good_container> 
---@field self_sourcing_fraction number percentage of work done without input goods
---@field foraging FORAGE_RESOURCE If not invalid, pulls from tile forage_resource
---@field nature_yield_dependence number How much does the local flora and fauna impact this buildings yield? Defaults to 0
---@field forest_dependence number Consumes local forests at this rate
---@field crop boolean If true, the building will periodically change its yield for a season.
---@field temperature_ideal_min number 
---@field temperature_ideal_max number 
---@field temperature_extreme_min number 
---@field temperature_extreme_max number 
---@field rainfall_ideal_min number 
---@field rainfall_ideal_max number 
---@field rainfall_extreme_min number 
---@field rainfall_extreme_max number 
---@field clay_ideal_min number 
---@field clay_ideal_max number 
---@field clay_extreme_min number 
---@field clay_extreme_max number 

---@class (exact) production_method_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field job_type JOBTYPE 
---@field job job_id 
---@field self_sourcing_fraction number? percentage of work done without input goods
---@field foraging FORAGE_RESOURCE? If not invalid, pulls from tile forage_resource
---@field nature_yield_dependence number? How much does the local flora and fauna impact this buildings yield? Defaults to 0
---@field forest_dependence number? Consumes local forests at this rate
---@field crop boolean? If true, the building will periodically change its yield for a season.
---@field temperature_ideal_min number? 
---@field temperature_ideal_max number? 
---@field temperature_extreme_min number? 
---@field temperature_extreme_max number? 
---@field rainfall_ideal_min number? 
---@field rainfall_ideal_max number? 
---@field rainfall_extreme_min number? 
---@field rainfall_extreme_max number? 
---@field clay_ideal_min number? 
---@field clay_ideal_max number? 
---@field clay_extreme_min number? 
---@field clay_extreme_max number? 
---Sets values of production_method for given id
---@param id production_method_id
---@param data production_method_id_data_blob_definition
function DATA.setup_production_method(id, data)
    DATA.production_method_set_self_sourcing_fraction(id, 0)
    DATA.production_method_set_foraging(id, 0)
    DATA.production_method_set_nature_yield_dependence(id, 0)
    DATA.production_method_set_forest_dependence(id, 0)
    DATA.production_method_set_crop(id, false)
    DATA.production_method_set_temperature_ideal_min(id, 10)
    DATA.production_method_set_temperature_ideal_max(id, 30)
    DATA.production_method_set_temperature_extreme_min(id, 0)
    DATA.production_method_set_temperature_extreme_max(id, 50)
    DATA.production_method_set_rainfall_ideal_min(id, 50)
    DATA.production_method_set_rainfall_ideal_max(id, 100)
    DATA.production_method_set_rainfall_extreme_min(id, 5)
    DATA.production_method_set_rainfall_extreme_max(id, 350)
    DATA.production_method_set_clay_ideal_min(id, 0)
    DATA.production_method_set_clay_ideal_max(id, 1)
    DATA.production_method_set_clay_extreme_min(id, 0)
    DATA.production_method_set_clay_extreme_max(id, 1)
    DATA.production_method_set_name(id, data.name)
    DATA.production_method_set_icon(id, data.icon)
    DATA.production_method_set_description(id, data.description)
    DATA.production_method_set_r(id, data.r)
    DATA.production_method_set_g(id, data.g)
    DATA.production_method_set_b(id, data.b)
    DATA.production_method_set_job_type(id, data.job_type)
    DATA.production_method_set_job(id, data.job)
    if data.self_sourcing_fraction ~= nil then
        DATA.production_method_set_self_sourcing_fraction(id, data.self_sourcing_fraction)
    end
    if data.foraging ~= nil then
        DATA.production_method_set_foraging(id, data.foraging)
    end
    if data.nature_yield_dependence ~= nil then
        DATA.production_method_set_nature_yield_dependence(id, data.nature_yield_dependence)
    end
    if data.forest_dependence ~= nil then
        DATA.production_method_set_forest_dependence(id, data.forest_dependence)
    end
    if data.crop ~= nil then
        DATA.production_method_set_crop(id, data.crop)
    end
    if data.temperature_ideal_min ~= nil then
        DATA.production_method_set_temperature_ideal_min(id, data.temperature_ideal_min)
    end
    if data.temperature_ideal_max ~= nil then
        DATA.production_method_set_temperature_ideal_max(id, data.temperature_ideal_max)
    end
    if data.temperature_extreme_min ~= nil then
        DATA.production_method_set_temperature_extreme_min(id, data.temperature_extreme_min)
    end
    if data.temperature_extreme_max ~= nil then
        DATA.production_method_set_temperature_extreme_max(id, data.temperature_extreme_max)
    end
    if data.rainfall_ideal_min ~= nil then
        DATA.production_method_set_rainfall_ideal_min(id, data.rainfall_ideal_min)
    end
    if data.rainfall_ideal_max ~= nil then
        DATA.production_method_set_rainfall_ideal_max(id, data.rainfall_ideal_max)
    end
    if data.rainfall_extreme_min ~= nil then
        DATA.production_method_set_rainfall_extreme_min(id, data.rainfall_extreme_min)
    end
    if data.rainfall_extreme_max ~= nil then
        DATA.production_method_set_rainfall_extreme_max(id, data.rainfall_extreme_max)
    end
    if data.clay_ideal_min ~= nil then
        DATA.production_method_set_clay_ideal_min(id, data.clay_ideal_min)
    end
    if data.clay_ideal_max ~= nil then
        DATA.production_method_set_clay_ideal_max(id, data.clay_ideal_max)
    end
    if data.clay_extreme_min ~= nil then
        DATA.production_method_set_clay_extreme_min(id, data.clay_extreme_min)
    end
    if data.clay_extreme_max ~= nil then
        DATA.production_method_set_clay_extreme_max(id, data.clay_extreme_max)
    end
end

ffi.cdef[[
void dcon_production_method_set_r(int32_t, float);
float dcon_production_method_get_r(int32_t);
void dcon_production_method_set_g(int32_t, float);
float dcon_production_method_get_g(int32_t);
void dcon_production_method_set_b(int32_t, float);
float dcon_production_method_get_b(int32_t);
void dcon_production_method_set_job_type(int32_t, uint8_t);
uint8_t dcon_production_method_get_job_type(int32_t);
void dcon_production_method_set_job(int32_t, int32_t);
int32_t dcon_production_method_get_job(int32_t);
void dcon_production_method_resize_inputs(uint32_t);
use_case_container* dcon_production_method_get_inputs(int32_t, int32_t);
void dcon_production_method_resize_outputs(uint32_t);
trade_good_container* dcon_production_method_get_outputs(int32_t, int32_t);
void dcon_production_method_set_self_sourcing_fraction(int32_t, float);
float dcon_production_method_get_self_sourcing_fraction(int32_t);
void dcon_production_method_set_foraging(int32_t, uint8_t);
uint8_t dcon_production_method_get_foraging(int32_t);
void dcon_production_method_set_nature_yield_dependence(int32_t, float);
float dcon_production_method_get_nature_yield_dependence(int32_t);
void dcon_production_method_set_forest_dependence(int32_t, float);
float dcon_production_method_get_forest_dependence(int32_t);
void dcon_production_method_set_crop(int32_t, bool);
bool dcon_production_method_get_crop(int32_t);
void dcon_production_method_set_temperature_ideal_min(int32_t, float);
float dcon_production_method_get_temperature_ideal_min(int32_t);
void dcon_production_method_set_temperature_ideal_max(int32_t, float);
float dcon_production_method_get_temperature_ideal_max(int32_t);
void dcon_production_method_set_temperature_extreme_min(int32_t, float);
float dcon_production_method_get_temperature_extreme_min(int32_t);
void dcon_production_method_set_temperature_extreme_max(int32_t, float);
float dcon_production_method_get_temperature_extreme_max(int32_t);
void dcon_production_method_set_rainfall_ideal_min(int32_t, float);
float dcon_production_method_get_rainfall_ideal_min(int32_t);
void dcon_production_method_set_rainfall_ideal_max(int32_t, float);
float dcon_production_method_get_rainfall_ideal_max(int32_t);
void dcon_production_method_set_rainfall_extreme_min(int32_t, float);
float dcon_production_method_get_rainfall_extreme_min(int32_t);
void dcon_production_method_set_rainfall_extreme_max(int32_t, float);
float dcon_production_method_get_rainfall_extreme_max(int32_t);
void dcon_production_method_set_clay_ideal_min(int32_t, float);
float dcon_production_method_get_clay_ideal_min(int32_t);
void dcon_production_method_set_clay_ideal_max(int32_t, float);
float dcon_production_method_get_clay_ideal_max(int32_t);
void dcon_production_method_set_clay_extreme_min(int32_t, float);
float dcon_production_method_get_clay_extreme_min(int32_t);
void dcon_production_method_set_clay_extreme_max(int32_t, float);
float dcon_production_method_get_clay_extreme_max(int32_t);
int32_t dcon_create_production_method();
bool dcon_production_method_is_valid(int32_t);
void dcon_production_method_resize(uint32_t sz);
uint32_t dcon_production_method_size();
]]

---production_method: FFI arrays---
---@type (string)[]
DATA.production_method_name= {}
---@type (string)[]
DATA.production_method_icon= {}
---@type (string)[]
DATA.production_method_description= {}

---production_method: LUA bindings---

DATA.production_method_size = 250
DCON.dcon_production_method_resize_inputs(9)
DCON.dcon_production_method_resize_outputs(9)
---@return production_method_id
function DATA.create_production_method()
    ---@type production_method_id
    local i  = DCON.dcon_create_production_method() + 1
    return i --[[@as production_method_id]] 
end
---@param func fun(item: production_method_id) 
function DATA.for_each_production_method(func)
    ---@type number
    local range = DCON.dcon_production_method_size()
    for i = 0, range - 1 do
        func(i + 1 --[[@as production_method_id]])
    end
end
---@param func fun(item: production_method_id):boolean 
---@return table<production_method_id, production_method_id> 
function DATA.filter_production_method(func)
    ---@type table<production_method_id, production_method_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_production_method_size()
    for i = 0, range - 1 do
        if func(i + 1 --[[@as production_method_id]]) then t[i + 1 --[[@as production_method_id]]] = t[i + 1 --[[@as production_method_id]]] end
    end
    return t
end

---@param production_method_id production_method_id valid production_method id
---@return string name 
function DATA.production_method_get_name(production_method_id)
    return DATA.production_method_name[production_method_id]
end
---@param production_method_id production_method_id valid production_method id
---@param value string valid string
function DATA.production_method_set_name(production_method_id, value)
    DATA.production_method_name[production_method_id] = value
end
---@param production_method_id production_method_id valid production_method id
---@return string icon 
function DATA.production_method_get_icon(production_method_id)
    return DATA.production_method_icon[production_method_id]
end
---@param production_method_id production_method_id valid production_method id
---@param value string valid string
function DATA.production_method_set_icon(production_method_id, value)
    DATA.production_method_icon[production_method_id] = value
end
---@param production_method_id production_method_id valid production_method id
---@return string description 
function DATA.production_method_get_description(production_method_id)
    return DATA.production_method_description[production_method_id]
end
---@param production_method_id production_method_id valid production_method id
---@param value string valid string
function DATA.production_method_set_description(production_method_id, value)
    DATA.production_method_description[production_method_id] = value
end
---@param production_method_id production_method_id valid production_method id
---@return number r 
function DATA.production_method_get_r(production_method_id)
    return DCON.dcon_production_method_get_r(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_r(production_method_id, value)
    DCON.dcon_production_method_set_r(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_r(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_r(production_method_id - 1)
    DCON.dcon_production_method_set_r(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number g 
function DATA.production_method_get_g(production_method_id)
    return DCON.dcon_production_method_get_g(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_g(production_method_id, value)
    DCON.dcon_production_method_set_g(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_g(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_g(production_method_id - 1)
    DCON.dcon_production_method_set_g(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number b 
function DATA.production_method_get_b(production_method_id)
    return DCON.dcon_production_method_get_b(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_b(production_method_id, value)
    DCON.dcon_production_method_set_b(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_b(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_b(production_method_id - 1)
    DCON.dcon_production_method_set_b(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return JOBTYPE job_type 
function DATA.production_method_get_job_type(production_method_id)
    return DCON.dcon_production_method_get_job_type(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value JOBTYPE valid JOBTYPE
function DATA.production_method_set_job_type(production_method_id, value)
    DCON.dcon_production_method_set_job_type(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@return job_id job 
function DATA.production_method_get_job(production_method_id)
    return DCON.dcon_production_method_get_job(production_method_id - 1) + 1
end
---@param production_method_id production_method_id valid production_method id
---@param value job_id valid job_id
function DATA.production_method_set_job(production_method_id, value)
    DCON.dcon_production_method_set_job(production_method_id - 1, value - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return use_case_id inputs 
function DATA.production_method_get_inputs_use(production_method_id, index)
    assert(index ~= 0)
    return DCON.dcon_production_method_get_inputs(production_method_id - 1, index - 1)[0].use
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return number inputs 
function DATA.production_method_get_inputs_amount(production_method_id, index)
    assert(index ~= 0)
    return DCON.dcon_production_method_get_inputs(production_method_id - 1, index - 1)[0].amount
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value use_case_id valid use_case_id
function DATA.production_method_set_inputs_use(production_method_id, index, value)
    DCON.dcon_production_method_get_inputs(production_method_id - 1, index - 1)[0].use = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_set_inputs_amount(production_method_id, index, value)
    DCON.dcon_production_method_get_inputs(production_method_id - 1, index - 1)[0].amount = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_inc_inputs_amount(production_method_id, index, value)
    ---@type number
    local current = DCON.dcon_production_method_get_inputs(production_method_id - 1, index - 1)[0].amount
    DCON.dcon_production_method_get_inputs(production_method_id - 1, index - 1)[0].amount = current + value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return trade_good_id outputs 
function DATA.production_method_get_outputs_good(production_method_id, index)
    assert(index ~= 0)
    return DCON.dcon_production_method_get_outputs(production_method_id - 1, index - 1)[0].good
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return number outputs 
function DATA.production_method_get_outputs_amount(production_method_id, index)
    assert(index ~= 0)
    return DCON.dcon_production_method_get_outputs(production_method_id - 1, index - 1)[0].amount
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.production_method_set_outputs_good(production_method_id, index, value)
    DCON.dcon_production_method_get_outputs(production_method_id - 1, index - 1)[0].good = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_set_outputs_amount(production_method_id, index, value)
    DCON.dcon_production_method_get_outputs(production_method_id - 1, index - 1)[0].amount = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_inc_outputs_amount(production_method_id, index, value)
    ---@type number
    local current = DCON.dcon_production_method_get_outputs(production_method_id - 1, index - 1)[0].amount
    DCON.dcon_production_method_get_outputs(production_method_id - 1, index - 1)[0].amount = current + value
end
---@param production_method_id production_method_id valid production_method id
---@return number self_sourcing_fraction percentage of work done without input goods
function DATA.production_method_get_self_sourcing_fraction(production_method_id)
    return DCON.dcon_production_method_get_self_sourcing_fraction(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_self_sourcing_fraction(production_method_id, value)
    DCON.dcon_production_method_set_self_sourcing_fraction(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_self_sourcing_fraction(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_self_sourcing_fraction(production_method_id - 1)
    DCON.dcon_production_method_set_self_sourcing_fraction(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return FORAGE_RESOURCE foraging If not invalid, pulls from tile forage_resource
function DATA.production_method_get_foraging(production_method_id)
    return DCON.dcon_production_method_get_foraging(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value FORAGE_RESOURCE valid FORAGE_RESOURCE
function DATA.production_method_set_foraging(production_method_id, value)
    DCON.dcon_production_method_set_foraging(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@return number nature_yield_dependence How much does the local flora and fauna impact this buildings yield? Defaults to 0
function DATA.production_method_get_nature_yield_dependence(production_method_id)
    return DCON.dcon_production_method_get_nature_yield_dependence(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_nature_yield_dependence(production_method_id, value)
    DCON.dcon_production_method_set_nature_yield_dependence(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_nature_yield_dependence(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_nature_yield_dependence(production_method_id - 1)
    DCON.dcon_production_method_set_nature_yield_dependence(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number forest_dependence Consumes local forests at this rate
function DATA.production_method_get_forest_dependence(production_method_id)
    return DCON.dcon_production_method_get_forest_dependence(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_forest_dependence(production_method_id, value)
    DCON.dcon_production_method_set_forest_dependence(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_forest_dependence(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_forest_dependence(production_method_id - 1)
    DCON.dcon_production_method_set_forest_dependence(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return boolean crop If true, the building will periodically change its yield for a season.
function DATA.production_method_get_crop(production_method_id)
    return DCON.dcon_production_method_get_crop(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value boolean valid boolean
function DATA.production_method_set_crop(production_method_id, value)
    DCON.dcon_production_method_set_crop(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_ideal_min 
function DATA.production_method_get_temperature_ideal_min(production_method_id)
    return DCON.dcon_production_method_get_temperature_ideal_min(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_ideal_min(production_method_id, value)
    DCON.dcon_production_method_set_temperature_ideal_min(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_ideal_min(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_temperature_ideal_min(production_method_id - 1)
    DCON.dcon_production_method_set_temperature_ideal_min(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_ideal_max 
function DATA.production_method_get_temperature_ideal_max(production_method_id)
    return DCON.dcon_production_method_get_temperature_ideal_max(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_ideal_max(production_method_id, value)
    DCON.dcon_production_method_set_temperature_ideal_max(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_ideal_max(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_temperature_ideal_max(production_method_id - 1)
    DCON.dcon_production_method_set_temperature_ideal_max(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_extreme_min 
function DATA.production_method_get_temperature_extreme_min(production_method_id)
    return DCON.dcon_production_method_get_temperature_extreme_min(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_extreme_min(production_method_id, value)
    DCON.dcon_production_method_set_temperature_extreme_min(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_extreme_min(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_temperature_extreme_min(production_method_id - 1)
    DCON.dcon_production_method_set_temperature_extreme_min(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_extreme_max 
function DATA.production_method_get_temperature_extreme_max(production_method_id)
    return DCON.dcon_production_method_get_temperature_extreme_max(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_extreme_max(production_method_id, value)
    DCON.dcon_production_method_set_temperature_extreme_max(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_extreme_max(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_temperature_extreme_max(production_method_id - 1)
    DCON.dcon_production_method_set_temperature_extreme_max(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_ideal_min 
function DATA.production_method_get_rainfall_ideal_min(production_method_id)
    return DCON.dcon_production_method_get_rainfall_ideal_min(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_ideal_min(production_method_id, value)
    DCON.dcon_production_method_set_rainfall_ideal_min(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_ideal_min(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_rainfall_ideal_min(production_method_id - 1)
    DCON.dcon_production_method_set_rainfall_ideal_min(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_ideal_max 
function DATA.production_method_get_rainfall_ideal_max(production_method_id)
    return DCON.dcon_production_method_get_rainfall_ideal_max(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_ideal_max(production_method_id, value)
    DCON.dcon_production_method_set_rainfall_ideal_max(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_ideal_max(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_rainfall_ideal_max(production_method_id - 1)
    DCON.dcon_production_method_set_rainfall_ideal_max(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_extreme_min 
function DATA.production_method_get_rainfall_extreme_min(production_method_id)
    return DCON.dcon_production_method_get_rainfall_extreme_min(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_extreme_min(production_method_id, value)
    DCON.dcon_production_method_set_rainfall_extreme_min(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_extreme_min(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_rainfall_extreme_min(production_method_id - 1)
    DCON.dcon_production_method_set_rainfall_extreme_min(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_extreme_max 
function DATA.production_method_get_rainfall_extreme_max(production_method_id)
    return DCON.dcon_production_method_get_rainfall_extreme_max(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_extreme_max(production_method_id, value)
    DCON.dcon_production_method_set_rainfall_extreme_max(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_extreme_max(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_rainfall_extreme_max(production_method_id - 1)
    DCON.dcon_production_method_set_rainfall_extreme_max(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_ideal_min 
function DATA.production_method_get_clay_ideal_min(production_method_id)
    return DCON.dcon_production_method_get_clay_ideal_min(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_ideal_min(production_method_id, value)
    DCON.dcon_production_method_set_clay_ideal_min(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_ideal_min(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_clay_ideal_min(production_method_id - 1)
    DCON.dcon_production_method_set_clay_ideal_min(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_ideal_max 
function DATA.production_method_get_clay_ideal_max(production_method_id)
    return DCON.dcon_production_method_get_clay_ideal_max(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_ideal_max(production_method_id, value)
    DCON.dcon_production_method_set_clay_ideal_max(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_ideal_max(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_clay_ideal_max(production_method_id - 1)
    DCON.dcon_production_method_set_clay_ideal_max(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_extreme_min 
function DATA.production_method_get_clay_extreme_min(production_method_id)
    return DCON.dcon_production_method_get_clay_extreme_min(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_extreme_min(production_method_id, value)
    DCON.dcon_production_method_set_clay_extreme_min(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_extreme_min(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_clay_extreme_min(production_method_id - 1)
    DCON.dcon_production_method_set_clay_extreme_min(production_method_id - 1, current + value)
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_extreme_max 
function DATA.production_method_get_clay_extreme_max(production_method_id)
    return DCON.dcon_production_method_get_clay_extreme_max(production_method_id - 1)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_extreme_max(production_method_id, value)
    DCON.dcon_production_method_set_clay_extreme_max(production_method_id - 1, value)
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_extreme_max(production_method_id, value)
    ---@type number
    local current = DCON.dcon_production_method_get_clay_extreme_max(production_method_id - 1)
    DCON.dcon_production_method_set_clay_extreme_max(production_method_id - 1, current + value)
end

local fat_production_method_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.production_method_get_name(t.id) end
        if (k == "icon") then return DATA.production_method_get_icon(t.id) end
        if (k == "description") then return DATA.production_method_get_description(t.id) end
        if (k == "r") then return DATA.production_method_get_r(t.id) end
        if (k == "g") then return DATA.production_method_get_g(t.id) end
        if (k == "b") then return DATA.production_method_get_b(t.id) end
        if (k == "job_type") then return DATA.production_method_get_job_type(t.id) end
        if (k == "job") then return DATA.production_method_get_job(t.id) end
        if (k == "self_sourcing_fraction") then return DATA.production_method_get_self_sourcing_fraction(t.id) end
        if (k == "foraging") then return DATA.production_method_get_foraging(t.id) end
        if (k == "nature_yield_dependence") then return DATA.production_method_get_nature_yield_dependence(t.id) end
        if (k == "forest_dependence") then return DATA.production_method_get_forest_dependence(t.id) end
        if (k == "crop") then return DATA.production_method_get_crop(t.id) end
        if (k == "temperature_ideal_min") then return DATA.production_method_get_temperature_ideal_min(t.id) end
        if (k == "temperature_ideal_max") then return DATA.production_method_get_temperature_ideal_max(t.id) end
        if (k == "temperature_extreme_min") then return DATA.production_method_get_temperature_extreme_min(t.id) end
        if (k == "temperature_extreme_max") then return DATA.production_method_get_temperature_extreme_max(t.id) end
        if (k == "rainfall_ideal_min") then return DATA.production_method_get_rainfall_ideal_min(t.id) end
        if (k == "rainfall_ideal_max") then return DATA.production_method_get_rainfall_ideal_max(t.id) end
        if (k == "rainfall_extreme_min") then return DATA.production_method_get_rainfall_extreme_min(t.id) end
        if (k == "rainfall_extreme_max") then return DATA.production_method_get_rainfall_extreme_max(t.id) end
        if (k == "clay_ideal_min") then return DATA.production_method_get_clay_ideal_min(t.id) end
        if (k == "clay_ideal_max") then return DATA.production_method_get_clay_ideal_max(t.id) end
        if (k == "clay_extreme_min") then return DATA.production_method_get_clay_extreme_min(t.id) end
        if (k == "clay_extreme_max") then return DATA.production_method_get_clay_extreme_max(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.production_method_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.production_method_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.production_method_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.production_method_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.production_method_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.production_method_set_b(t.id, v)
            return
        end
        if (k == "job_type") then
            DATA.production_method_set_job_type(t.id, v)
            return
        end
        if (k == "job") then
            DATA.production_method_set_job(t.id, v)
            return
        end
        if (k == "self_sourcing_fraction") then
            DATA.production_method_set_self_sourcing_fraction(t.id, v)
            return
        end
        if (k == "foraging") then
            DATA.production_method_set_foraging(t.id, v)
            return
        end
        if (k == "nature_yield_dependence") then
            DATA.production_method_set_nature_yield_dependence(t.id, v)
            return
        end
        if (k == "forest_dependence") then
            DATA.production_method_set_forest_dependence(t.id, v)
            return
        end
        if (k == "crop") then
            DATA.production_method_set_crop(t.id, v)
            return
        end
        if (k == "temperature_ideal_min") then
            DATA.production_method_set_temperature_ideal_min(t.id, v)
            return
        end
        if (k == "temperature_ideal_max") then
            DATA.production_method_set_temperature_ideal_max(t.id, v)
            return
        end
        if (k == "temperature_extreme_min") then
            DATA.production_method_set_temperature_extreme_min(t.id, v)
            return
        end
        if (k == "temperature_extreme_max") then
            DATA.production_method_set_temperature_extreme_max(t.id, v)
            return
        end
        if (k == "rainfall_ideal_min") then
            DATA.production_method_set_rainfall_ideal_min(t.id, v)
            return
        end
        if (k == "rainfall_ideal_max") then
            DATA.production_method_set_rainfall_ideal_max(t.id, v)
            return
        end
        if (k == "rainfall_extreme_min") then
            DATA.production_method_set_rainfall_extreme_min(t.id, v)
            return
        end
        if (k == "rainfall_extreme_max") then
            DATA.production_method_set_rainfall_extreme_max(t.id, v)
            return
        end
        if (k == "clay_ideal_min") then
            DATA.production_method_set_clay_ideal_min(t.id, v)
            return
        end
        if (k == "clay_ideal_max") then
            DATA.production_method_set_clay_ideal_max(t.id, v)
            return
        end
        if (k == "clay_extreme_min") then
            DATA.production_method_set_clay_extreme_min(t.id, v)
            return
        end
        if (k == "clay_extreme_max") then
            DATA.production_method_set_clay_extreme_max(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id production_method_id
---@return fat_production_method_id fat_id
function DATA.fatten_production_method(id)
    local result = {id = id}
    setmetatable(result, fat_production_method_id_metatable)
    return result --[[@as fat_production_method_id]]
end
