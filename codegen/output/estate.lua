local ffi = require("ffi")
----------estate----------


---estate: LSP types---

---Unique identificator for estate entity
---@class (exact) estate_id : table
---@field is_estate number
---@class (exact) fat_estate_id
---@field id estate_id Unique estate id
---@field name string 
---@field morale number 
---@field current_status ESTATE_STATUS 
---@field idle_stance ESTATE_STANCE 
---@field movement_progress number 
---@field current_path table<tile_id> 
---@field current_time_used_ratio number How much monthly time is actualy used by warband. Accumulated daily.
---@field savings number 
---@field balance_last_tick number 
---@field total_upkeep number 
---@field predicted_upkeep number 
---@field supplies number 
---@field supplies_target_days number 

---@class struct_estate
---@field morale number 
---@field current_status ESTATE_STATUS 
---@field idle_stance ESTATE_STANCE 
---@field current_time_used_ratio number How much monthly time is actualy used by warband. Accumulated daily.
---@field units_current table<unit_type_id, number> Current distribution of units in the warband
---@field units_target table<unit_type_id, number> Units to recruit
---@field savings number 
---@field balance_last_tick number 
---@field total_upkeep number 
---@field predicted_upkeep number 
---@field supplies number 
---@field supplies_target_days number 
---@field inventory table<trade_good_id, number> 
---@field inventory_sold_last_tick table<trade_good_id, number> 
---@field inventory_bought_last_tick table<trade_good_id, number> 
---@field inventory_demanded_last_tick table<trade_good_id, number> 
---@field technologies_present table<technology_id, number> 
---@field technologies_researchable table<technology_id, number> 
---@field technologies_throughput_boosts table<production_method_id, number> 
---@field technologies_output_boosts table<production_method_id, number> 
---@field technologies_input_boosts table<production_method_id, number> 
---@field buildable_buildings table<building_type_id, number> 


ffi.cdef[[
void dcon_estate_set_morale(int32_t, float);
float dcon_estate_get_morale(int32_t);
void dcon_estate_set_current_status(int32_t, uint8_t);
uint8_t dcon_estate_get_current_status(int32_t);
void dcon_estate_set_idle_stance(int32_t, uint8_t);
uint8_t dcon_estate_get_idle_stance(int32_t);
void dcon_estate_set_current_time_used_ratio(int32_t, float);
float dcon_estate_get_current_time_used_ratio(int32_t);
void dcon_estate_resize_units_current(uint32_t);
void dcon_estate_set_units_current(int32_t, int32_t, float);
float dcon_estate_get_units_current(int32_t, int32_t);
void dcon_estate_resize_units_target(uint32_t);
void dcon_estate_set_units_target(int32_t, int32_t, float);
float dcon_estate_get_units_target(int32_t, int32_t);
void dcon_estate_set_savings(int32_t, float);
float dcon_estate_get_savings(int32_t);
void dcon_estate_set_balance_last_tick(int32_t, float);
float dcon_estate_get_balance_last_tick(int32_t);
void dcon_estate_set_total_upkeep(int32_t, float);
float dcon_estate_get_total_upkeep(int32_t);
void dcon_estate_set_predicted_upkeep(int32_t, float);
float dcon_estate_get_predicted_upkeep(int32_t);
void dcon_estate_set_supplies(int32_t, float);
float dcon_estate_get_supplies(int32_t);
void dcon_estate_set_supplies_target_days(int32_t, float);
float dcon_estate_get_supplies_target_days(int32_t);
void dcon_estate_resize_inventory(uint32_t);
void dcon_estate_set_inventory(int32_t, int32_t, float);
float dcon_estate_get_inventory(int32_t, int32_t);
void dcon_estate_resize_inventory_sold_last_tick(uint32_t);
void dcon_estate_set_inventory_sold_last_tick(int32_t, int32_t, float);
float dcon_estate_get_inventory_sold_last_tick(int32_t, int32_t);
void dcon_estate_resize_inventory_bought_last_tick(uint32_t);
void dcon_estate_set_inventory_bought_last_tick(int32_t, int32_t, float);
float dcon_estate_get_inventory_bought_last_tick(int32_t, int32_t);
void dcon_estate_resize_inventory_demanded_last_tick(uint32_t);
void dcon_estate_set_inventory_demanded_last_tick(int32_t, int32_t, float);
float dcon_estate_get_inventory_demanded_last_tick(int32_t, int32_t);
void dcon_estate_resize_technologies_present(uint32_t);
void dcon_estate_set_technologies_present(int32_t, int32_t, uint8_t);
uint8_t dcon_estate_get_technologies_present(int32_t, int32_t);
void dcon_estate_resize_technologies_researchable(uint32_t);
void dcon_estate_set_technologies_researchable(int32_t, int32_t, uint8_t);
uint8_t dcon_estate_get_technologies_researchable(int32_t, int32_t);
void dcon_estate_resize_technologies_throughput_boosts(uint32_t);
void dcon_estate_set_technologies_throughput_boosts(int32_t, int32_t, float);
float dcon_estate_get_technologies_throughput_boosts(int32_t, int32_t);
void dcon_estate_resize_technologies_output_boosts(uint32_t);
void dcon_estate_set_technologies_output_boosts(int32_t, int32_t, float);
float dcon_estate_get_technologies_output_boosts(int32_t, int32_t);
void dcon_estate_resize_technologies_input_boosts(uint32_t);
void dcon_estate_set_technologies_input_boosts(int32_t, int32_t, float);
float dcon_estate_get_technologies_input_boosts(int32_t, int32_t);
void dcon_estate_resize_buildable_buildings(uint32_t);
void dcon_estate_set_buildable_buildings(int32_t, int32_t, uint8_t);
uint8_t dcon_estate_get_buildable_buildings(int32_t, int32_t);
void dcon_delete_estate(int32_t j);
int32_t dcon_create_estate();
bool dcon_estate_is_valid(int32_t);
void dcon_estate_resize(uint32_t sz);
uint32_t dcon_estate_size();
]]

---estate: FFI arrays---
---@type (string)[]
DATA.estate_name= {}
---@type (number)[]
DATA.estate_movement_progress= {}
---@type (table<tile_id>)[]
DATA.estate_current_path= {}

---estate: LUA bindings---

DATA.estate_size = 300000
DCON.dcon_estate_resize_units_current(6)
DCON.dcon_estate_resize_units_target(6)
DCON.dcon_estate_resize_inventory(101)
DCON.dcon_estate_resize_inventory_sold_last_tick(101)
DCON.dcon_estate_resize_inventory_bought_last_tick(101)
DCON.dcon_estate_resize_inventory_demanded_last_tick(101)
DCON.dcon_estate_resize_technologies_present(401)
DCON.dcon_estate_resize_technologies_researchable(401)
DCON.dcon_estate_resize_technologies_throughput_boosts(251)
DCON.dcon_estate_resize_technologies_output_boosts(251)
DCON.dcon_estate_resize_technologies_input_boosts(251)
DCON.dcon_estate_resize_buildable_buildings(251)
---@return estate_id
function DATA.create_estate()
    ---@type estate_id
    local i  = DCON.dcon_create_estate() + 1
    return i --[[@as estate_id]] 
end
---@param i estate_id
function DATA.delete_estate(i)
    assert(DCON.dcon_estate_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_estate(i - 1)
end
---@param func fun(item: estate_id) 
function DATA.for_each_estate(func)
    ---@type number
    local range = DCON.dcon_estate_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_is_valid(i) then func(i + 1 --[[@as estate_id]]) end
    end
end
---@param func fun(item: estate_id):boolean 
---@return table<estate_id, estate_id> 
function DATA.filter_estate(func)
    ---@type table<estate_id, estate_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_is_valid(i) and func(i + 1 --[[@as estate_id]]) then t[i + 1 --[[@as estate_id]]] = i + 1 --[[@as estate_id]] end
    end
    return t
end

---@param estate_id estate_id valid estate id
---@return string name 
function DATA.estate_get_name(estate_id)
    return DATA.estate_name[estate_id]
end
---@param estate_id estate_id valid estate id
---@param value string valid string
function DATA.estate_set_name(estate_id, value)
    DATA.estate_name[estate_id] = value
end
---@param estate_id estate_id valid estate id
---@return number morale 
function DATA.estate_get_morale(estate_id)
    return DCON.dcon_estate_get_morale(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_morale(estate_id, value)
    DCON.dcon_estate_set_morale(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_morale(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_morale(estate_id - 1)
    DCON.dcon_estate_set_morale(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return ESTATE_STATUS current_status 
function DATA.estate_get_current_status(estate_id)
    return DCON.dcon_estate_get_current_status(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value ESTATE_STATUS valid ESTATE_STATUS
function DATA.estate_set_current_status(estate_id, value)
    DCON.dcon_estate_set_current_status(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@return ESTATE_STANCE idle_stance 
function DATA.estate_get_idle_stance(estate_id)
    return DCON.dcon_estate_get_idle_stance(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value ESTATE_STANCE valid ESTATE_STANCE
function DATA.estate_set_idle_stance(estate_id, value)
    DCON.dcon_estate_set_idle_stance(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@return number movement_progress 
function DATA.estate_get_movement_progress(estate_id)
    return DATA.estate_movement_progress[estate_id]
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_movement_progress(estate_id, value)
    DATA.estate_movement_progress[estate_id] = value
end
---@param estate_id estate_id valid estate id
---@return table<tile_id> current_path 
function DATA.estate_get_current_path(estate_id)
    return DATA.estate_current_path[estate_id]
end
---@param estate_id estate_id valid estate id
---@param value table<tile_id> valid table<tile_id>
function DATA.estate_set_current_path(estate_id, value)
    DATA.estate_current_path[estate_id] = value
end
---@param estate_id estate_id valid estate id
---@return number current_time_used_ratio How much monthly time is actualy used by warband. Accumulated daily.
function DATA.estate_get_current_time_used_ratio(estate_id)
    return DCON.dcon_estate_get_current_time_used_ratio(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_current_time_used_ratio(estate_id, value)
    DCON.dcon_estate_set_current_time_used_ratio(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_current_time_used_ratio(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_current_time_used_ratio(estate_id - 1)
    DCON.dcon_estate_set_current_time_used_ratio(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index unit_type_id valid
---@return number units_current Current distribution of units in the warband
function DATA.estate_get_units_current(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_units_current(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.estate_set_units_current(estate_id, index, value)
    DCON.dcon_estate_set_units_current(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.estate_inc_units_current(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_units_current(estate_id - 1, index - 1)
    DCON.dcon_estate_set_units_current(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index unit_type_id valid
---@return number units_target Units to recruit
function DATA.estate_get_units_target(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_units_target(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.estate_set_units_target(estate_id, index, value)
    DCON.dcon_estate_set_units_target(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.estate_inc_units_target(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_units_target(estate_id - 1, index - 1)
    DCON.dcon_estate_set_units_target(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return number savings 
function DATA.estate_get_savings(estate_id)
    return DCON.dcon_estate_get_savings(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_savings(estate_id, value)
    DCON.dcon_estate_set_savings(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_savings(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_savings(estate_id - 1)
    DCON.dcon_estate_set_savings(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return number balance_last_tick 
function DATA.estate_get_balance_last_tick(estate_id)
    return DCON.dcon_estate_get_balance_last_tick(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_balance_last_tick(estate_id, value)
    DCON.dcon_estate_set_balance_last_tick(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_balance_last_tick(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_balance_last_tick(estate_id - 1)
    DCON.dcon_estate_set_balance_last_tick(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return number total_upkeep 
function DATA.estate_get_total_upkeep(estate_id)
    return DCON.dcon_estate_get_total_upkeep(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_total_upkeep(estate_id, value)
    DCON.dcon_estate_set_total_upkeep(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_total_upkeep(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_total_upkeep(estate_id - 1)
    DCON.dcon_estate_set_total_upkeep(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return number predicted_upkeep 
function DATA.estate_get_predicted_upkeep(estate_id)
    return DCON.dcon_estate_get_predicted_upkeep(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_predicted_upkeep(estate_id, value)
    DCON.dcon_estate_set_predicted_upkeep(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_predicted_upkeep(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_predicted_upkeep(estate_id - 1)
    DCON.dcon_estate_set_predicted_upkeep(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return number supplies 
function DATA.estate_get_supplies(estate_id)
    return DCON.dcon_estate_get_supplies(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_supplies(estate_id, value)
    DCON.dcon_estate_set_supplies(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_supplies(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_supplies(estate_id - 1)
    DCON.dcon_estate_set_supplies(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return number supplies_target_days 
function DATA.estate_get_supplies_target_days(estate_id)
    return DCON.dcon_estate_get_supplies_target_days(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_supplies_target_days(estate_id, value)
    DCON.dcon_estate_set_supplies_target_days(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_supplies_target_days(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_supplies_target_days(estate_id - 1)
    DCON.dcon_estate_set_supplies_target_days(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory 
function DATA.estate_get_inventory(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory(estate_id, index, value)
    DCON.dcon_estate_set_inventory(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory_sold_last_tick 
function DATA.estate_get_inventory_sold_last_tick(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory_sold_last_tick(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory_sold_last_tick(estate_id, index, value)
    DCON.dcon_estate_set_inventory_sold_last_tick(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory_sold_last_tick(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory_sold_last_tick(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory_sold_last_tick(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory_bought_last_tick 
function DATA.estate_get_inventory_bought_last_tick(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory_bought_last_tick(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory_bought_last_tick(estate_id, index, value)
    DCON.dcon_estate_set_inventory_bought_last_tick(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory_bought_last_tick(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory_bought_last_tick(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory_bought_last_tick(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory_demanded_last_tick 
function DATA.estate_get_inventory_demanded_last_tick(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory_demanded_last_tick(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory_demanded_last_tick(estate_id, index, value)
    DCON.dcon_estate_set_inventory_demanded_last_tick(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory_demanded_last_tick(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory_demanded_last_tick(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory_demanded_last_tick(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index technology_id valid
---@return number technologies_present 
function DATA.estate_get_technologies_present(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_technologies_present(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index technology_id valid index
---@param value number valid number
function DATA.estate_set_technologies_present(estate_id, index, value)
    DCON.dcon_estate_set_technologies_present(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index technology_id valid index
---@param value number valid number
function DATA.estate_inc_technologies_present(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_technologies_present(estate_id - 1, index - 1)
    DCON.dcon_estate_set_technologies_present(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index technology_id valid
---@return number technologies_researchable 
function DATA.estate_get_technologies_researchable(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_technologies_researchable(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index technology_id valid index
---@param value number valid number
function DATA.estate_set_technologies_researchable(estate_id, index, value)
    DCON.dcon_estate_set_technologies_researchable(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index technology_id valid index
---@param value number valid number
function DATA.estate_inc_technologies_researchable(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_technologies_researchable(estate_id - 1, index - 1)
    DCON.dcon_estate_set_technologies_researchable(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid
---@return number technologies_throughput_boosts 
function DATA.estate_get_technologies_throughput_boosts(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_technologies_throughput_boosts(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_set_technologies_throughput_boosts(estate_id, index, value)
    DCON.dcon_estate_set_technologies_throughput_boosts(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_inc_technologies_throughput_boosts(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_technologies_throughput_boosts(estate_id - 1, index - 1)
    DCON.dcon_estate_set_technologies_throughput_boosts(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid
---@return number technologies_output_boosts 
function DATA.estate_get_technologies_output_boosts(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_technologies_output_boosts(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_set_technologies_output_boosts(estate_id, index, value)
    DCON.dcon_estate_set_technologies_output_boosts(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_inc_technologies_output_boosts(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_technologies_output_boosts(estate_id - 1, index - 1)
    DCON.dcon_estate_set_technologies_output_boosts(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid
---@return number technologies_input_boosts 
function DATA.estate_get_technologies_input_boosts(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_technologies_input_boosts(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_set_technologies_input_boosts(estate_id, index, value)
    DCON.dcon_estate_set_technologies_input_boosts(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_inc_technologies_input_boosts(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_technologies_input_boosts(estate_id - 1, index - 1)
    DCON.dcon_estate_set_technologies_input_boosts(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index building_type_id valid
---@return number buildable_buildings 
function DATA.estate_get_buildable_buildings(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_buildable_buildings(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index building_type_id valid index
---@param value number valid number
function DATA.estate_set_buildable_buildings(estate_id, index, value)
    DCON.dcon_estate_set_buildable_buildings(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index building_type_id valid index
---@param value number valid number
function DATA.estate_inc_buildable_buildings(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_buildable_buildings(estate_id - 1, index - 1)
    DCON.dcon_estate_set_buildable_buildings(estate_id - 1, index - 1, current + value)
end

local fat_estate_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.estate_get_name(t.id) end
        if (k == "morale") then return DATA.estate_get_morale(t.id) end
        if (k == "current_status") then return DATA.estate_get_current_status(t.id) end
        if (k == "idle_stance") then return DATA.estate_get_idle_stance(t.id) end
        if (k == "movement_progress") then return DATA.estate_get_movement_progress(t.id) end
        if (k == "current_path") then return DATA.estate_get_current_path(t.id) end
        if (k == "current_time_used_ratio") then return DATA.estate_get_current_time_used_ratio(t.id) end
        if (k == "savings") then return DATA.estate_get_savings(t.id) end
        if (k == "balance_last_tick") then return DATA.estate_get_balance_last_tick(t.id) end
        if (k == "total_upkeep") then return DATA.estate_get_total_upkeep(t.id) end
        if (k == "predicted_upkeep") then return DATA.estate_get_predicted_upkeep(t.id) end
        if (k == "supplies") then return DATA.estate_get_supplies(t.id) end
        if (k == "supplies_target_days") then return DATA.estate_get_supplies_target_days(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.estate_set_name(t.id, v)
            return
        end
        if (k == "morale") then
            DATA.estate_set_morale(t.id, v)
            return
        end
        if (k == "current_status") then
            DATA.estate_set_current_status(t.id, v)
            return
        end
        if (k == "idle_stance") then
            DATA.estate_set_idle_stance(t.id, v)
            return
        end
        if (k == "movement_progress") then
            DATA.estate_set_movement_progress(t.id, v)
            return
        end
        if (k == "current_path") then
            DATA.estate_set_current_path(t.id, v)
            return
        end
        if (k == "current_time_used_ratio") then
            DATA.estate_set_current_time_used_ratio(t.id, v)
            return
        end
        if (k == "savings") then
            DATA.estate_set_savings(t.id, v)
            return
        end
        if (k == "balance_last_tick") then
            DATA.estate_set_balance_last_tick(t.id, v)
            return
        end
        if (k == "total_upkeep") then
            DATA.estate_set_total_upkeep(t.id, v)
            return
        end
        if (k == "predicted_upkeep") then
            DATA.estate_set_predicted_upkeep(t.id, v)
            return
        end
        if (k == "supplies") then
            DATA.estate_set_supplies(t.id, v)
            return
        end
        if (k == "supplies_target_days") then
            DATA.estate_set_supplies_target_days(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_id
---@return fat_estate_id fat_id
function DATA.fatten_estate(id)
    local result = {id = id}
    setmetatable(result, fat_estate_id_metatable)
    return result --[[@as fat_estate_id]]
end
