local ffi = require("ffi")
----------pop----------


---pop: LSP types---

---Unique identificator for pop entity
---@class (exact) pop_id : table
---@field is_pop number
---@class (exact) fat_pop_id
---@field id pop_id Unique pop id
---@field unique_id number 
---@field race race_id 
---@field faith faith_id 
---@field rite rite_id
---@field culture culture_id 
---@field birth_year number 
---@field birth_tick number 
---@field name string 
---@field savings number 
---@field expected_wage number 
---@field life_needs_satisfaction number from 0 to 1
---@field basic_needs_satisfaction number from 0 to 1
---@field pending_economy_income number 
---@field forage_ratio number a number in (0, 1) interval representing a ratio of time pop spends to forage
---@field work_ratio number a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
---@field spend_savings_ratio number a number in (0, 1) interval representing a ratio of savings pop spends on satisfaction of needs
---@field female boolean 
---@field busy boolean 
---@field former_pop boolean 
---@field dead boolean 
---@field free_will boolean 
---@field is_player boolean 
---@field rank CHARACTER_RANK 
---@field ai_data AI_DATA 

---@class struct_pop
---@field unique_id number 
---@field race race_id 
---@field faith faith_id 
---@field rite rite_id
---@field culture culture_id 
---@field birth_year number 
---@field birth_tick number 
---@field traits table<number, TRAIT> 
---@field need_satisfaction table<number, struct_need_satisfaction> 
---@field inventory table<trade_good_id, number> 
---@field price_belief_sell table<trade_good_id, number> 
---@field price_belief_buy table<trade_good_id, number> 
---@field savings number 
---@field expected_wage number 
---@field life_needs_satisfaction number from 0 to 1
---@field basic_needs_satisfaction number from 0 to 1
---@field pending_economy_income number 
---@field forage_ratio number a number in (0, 1) interval representing a ratio of time pop spends to forage
---@field work_ratio number a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
---@field spend_savings_ratio number a number in (0, 1) interval representing a ratio of savings pop spends on satisfaction of needs
---@field female boolean 
---@field busy boolean 
---@field former_pop boolean 
---@field dead boolean 
---@field free_will boolean 
---@field is_player boolean 
---@field rank CHARACTER_RANK 
---@field dna table<number, number> 


ffi.cdef[[
void dcon_pop_set_unique_id(int32_t, uint32_t);
uint32_t dcon_pop_get_unique_id(int32_t);
void dcon_pop_set_race(int32_t, int32_t);
int32_t dcon_pop_get_race(int32_t);
void dcon_pop_set_faith(int32_t, int32_t);
int32_t dcon_pop_get_faith(int32_t);
void dcon_pop_set_culture(int32_t, int32_t);
int32_t dcon_pop_get_culture(int32_t);
void dcon_pop_set_birth_year(int32_t, int32_t);
int32_t dcon_pop_get_birth_year(int32_t);
void dcon_pop_set_birth_tick(int32_t, uint32_t);
uint32_t dcon_pop_get_birth_tick(int32_t);
void dcon_pop_resize_traits(uint32_t);
void dcon_pop_set_traits(int32_t, int32_t, uint8_t);
uint8_t dcon_pop_get_traits(int32_t, int32_t);
void dcon_pop_resize_need_satisfaction(uint32_t);
need_satisfaction* dcon_pop_get_need_satisfaction(int32_t, int32_t);
void dcon_pop_resize_inventory(uint32_t);
void dcon_pop_set_inventory(int32_t, int32_t, float);
float dcon_pop_get_inventory(int32_t, int32_t);
void dcon_pop_resize_price_belief_sell(uint32_t);
void dcon_pop_set_price_belief_sell(int32_t, int32_t, float);
float dcon_pop_get_price_belief_sell(int32_t, int32_t);
void dcon_pop_resize_price_belief_buy(uint32_t);
void dcon_pop_set_price_belief_buy(int32_t, int32_t, float);
float dcon_pop_get_price_belief_buy(int32_t, int32_t);
void dcon_pop_set_savings(int32_t, float);
float dcon_pop_get_savings(int32_t);
void dcon_pop_set_expected_wage(int32_t, float);
float dcon_pop_get_expected_wage(int32_t);
void dcon_pop_set_life_needs_satisfaction(int32_t, float);
float dcon_pop_get_life_needs_satisfaction(int32_t);
void dcon_pop_set_basic_needs_satisfaction(int32_t, float);
float dcon_pop_get_basic_needs_satisfaction(int32_t);
void dcon_pop_set_pending_economy_income(int32_t, float);
float dcon_pop_get_pending_economy_income(int32_t);
void dcon_pop_set_forage_ratio(int32_t, float);
float dcon_pop_get_forage_ratio(int32_t);
void dcon_pop_set_work_ratio(int32_t, float);
float dcon_pop_get_work_ratio(int32_t);
void dcon_pop_set_spend_savings_ratio(int32_t, float);
float dcon_pop_get_spend_savings_ratio(int32_t);
void dcon_pop_set_female(int32_t, bool);
bool dcon_pop_get_female(int32_t);
void dcon_pop_set_busy(int32_t, bool);
bool dcon_pop_get_busy(int32_t);
void dcon_pop_set_former_pop(int32_t, bool);
bool dcon_pop_get_former_pop(int32_t);
void dcon_pop_set_dead(int32_t, bool);
bool dcon_pop_get_dead(int32_t);
void dcon_pop_set_free_will(int32_t, bool);
bool dcon_pop_get_free_will(int32_t);
void dcon_pop_set_is_player(int32_t, bool);
bool dcon_pop_get_is_player(int32_t);
void dcon_pop_set_rank(int32_t, uint8_t);
uint8_t dcon_pop_get_rank(int32_t);
void dcon_pop_resize_dna(uint32_t);
void dcon_pop_set_dna(int32_t, int32_t, float);
float dcon_pop_get_dna(int32_t, int32_t);
void dcon_delete_pop(int32_t j);
int32_t dcon_create_pop();
bool dcon_pop_is_valid(int32_t);
void dcon_pop_resize(uint32_t sz);
uint32_t dcon_pop_size();
]]

---pop: FFI arrays---
---@type (string)[]
DATA.pop_name= {}
---@type (AI_DATA)[]
DATA.pop_ai_data= {}
---@type (rite_id)[]
DATA.pop_rite= {}

---pop: LUA bindings---

DATA.pop_size = 300000
DCON.dcon_pop_resize_traits(11)
DCON.dcon_pop_resize_need_satisfaction(21)
DCON.dcon_pop_resize_inventory(101)
DCON.dcon_pop_resize_price_belief_sell(101)
DCON.dcon_pop_resize_price_belief_buy(101)
DCON.dcon_pop_resize_dna(21)
---@return pop_id
function DATA.create_pop()
    ---@type pop_id
    local i  = DCON.dcon_create_pop() + 1
    return i --[[@as pop_id]] 
end
---@param i pop_id
function DATA.delete_pop(i)
    assert(DCON.dcon_pop_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_pop(i - 1)
end
---@param func fun(item: pop_id) 
function DATA.for_each_pop(func)
    ---@type number
    local range = DCON.dcon_pop_size()
    for i = 0, range - 1 do
        if DCON.dcon_pop_is_valid(i) then func(i + 1 --[[@as pop_id]]) end
    end
end
---@param func fun(item: pop_id):boolean 
---@return table<pop_id, pop_id> 
function DATA.filter_pop(func)
    ---@type table<pop_id, pop_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_pop_size()
    for i = 0, range - 1 do
        if DCON.dcon_pop_is_valid(i) and func(i + 1 --[[@as pop_id]]) then t[i + 1 --[[@as pop_id]]] = i + 1 --[[@as pop_id]] end
    end
    return t
end

---@param pop_id pop_id valid pop id
---@return number unique_id 
function DATA.pop_get_unique_id(pop_id)
    return DCON.dcon_pop_get_unique_id(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_unique_id(pop_id, value)
    DCON.dcon_pop_set_unique_id(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_unique_id(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_unique_id(pop_id - 1)
    DCON.dcon_pop_set_unique_id(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return race_id race 
function DATA.pop_get_race(pop_id)
    return DCON.dcon_pop_get_race(pop_id - 1) + 1
end
---@param pop_id pop_id valid pop id
---@param value race_id valid race_id
function DATA.pop_set_race(pop_id, value)
    DCON.dcon_pop_set_race(pop_id - 1, value - 1)
end
---@param pop_id pop_id valid pop id
---@return faith_id faith 
function DATA.pop_get_faith(pop_id)
    return DCON.dcon_pop_get_faith(pop_id - 1) + 1
end
---@param pop_id pop_id valid pop id
---@param value faith_id valid faith_id
function DATA.pop_set_faith(pop_id, value)
    DCON.dcon_pop_set_faith(pop_id - 1, value - 1)
end
---@param pop_id pop_id valid pop id
---@return rite_id rite
function DATA.pop_get_rite(pop_id)
    return DATA.pop_rite[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value rite_id valid rite_id
function DATA.pop_set_rite(pop_id, value)
    DATA.pop_rite[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@return culture_id culture 
function DATA.pop_get_culture(pop_id)
    return DCON.dcon_pop_get_culture(pop_id - 1) + 1
end
---@param pop_id pop_id valid pop id
---@param value culture_id valid culture_id
function DATA.pop_set_culture(pop_id, value)
    DCON.dcon_pop_set_culture(pop_id - 1, value - 1)
end
---@param pop_id pop_id valid pop id
---@return number birth_year 
function DATA.pop_get_birth_year(pop_id)
    return DCON.dcon_pop_get_birth_year(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_birth_year(pop_id, value)
    DCON.dcon_pop_set_birth_year(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_birth_year(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_birth_year(pop_id - 1)
    DCON.dcon_pop_set_birth_year(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number birth_tick 
function DATA.pop_get_birth_tick(pop_id)
    return DCON.dcon_pop_get_birth_tick(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_birth_tick(pop_id, value)
    DCON.dcon_pop_set_birth_tick(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_birth_tick(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_birth_tick(pop_id - 1)
    DCON.dcon_pop_set_birth_tick(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return string name 
function DATA.pop_get_name(pop_id)
    return DATA.pop_name[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value string valid string
function DATA.pop_set_name(pop_id, value)
    DATA.pop_name[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return TRAIT traits 
function DATA.pop_get_traits(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_traits(pop_id - 1, index - 1)
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value TRAIT valid TRAIT
function DATA.pop_set_traits(pop_id, index, value)
    DCON.dcon_pop_set_traits(pop_id - 1, index - 1, value)
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return NEED need_satisfaction 
function DATA.pop_get_need_satisfaction_need(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].need
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return use_case_id need_satisfaction 
function DATA.pop_get_need_satisfaction_use_case(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].use_case
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return number need_satisfaction 
function DATA.pop_get_need_satisfaction_consumed(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].consumed
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return number need_satisfaction 
function DATA.pop_get_need_satisfaction_demanded(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].demanded
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value NEED valid NEED
function DATA.pop_set_need_satisfaction_need(pop_id, index, value)
    DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].need = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value use_case_id valid use_case_id
function DATA.pop_set_need_satisfaction_use_case(pop_id, index, value)
    DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].use_case = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_set_need_satisfaction_consumed(pop_id, index, value)
    DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].consumed = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_inc_need_satisfaction_consumed(pop_id, index, value)
    ---@type number
    local current = DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].consumed
    DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].consumed = current + value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_set_need_satisfaction_demanded(pop_id, index, value)
    DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].demanded = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_inc_need_satisfaction_demanded(pop_id, index, value)
    ---@type number
    local current = DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].demanded
    DCON.dcon_pop_get_need_satisfaction(pop_id - 1, index - 1)[0].demanded = current + value
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid
---@return number inventory 
function DATA.pop_get_inventory(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_inventory(pop_id - 1, index - 1)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_set_inventory(pop_id, index, value)
    DCON.dcon_pop_set_inventory(pop_id - 1, index - 1, value)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_inc_inventory(pop_id, index, value)
    ---@type number
    local current = DCON.dcon_pop_get_inventory(pop_id - 1, index - 1)
    DCON.dcon_pop_set_inventory(pop_id - 1, index - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid
---@return number price_belief_sell 
function DATA.pop_get_price_belief_sell(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_price_belief_sell(pop_id - 1, index - 1)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_set_price_belief_sell(pop_id, index, value)
    DCON.dcon_pop_set_price_belief_sell(pop_id - 1, index - 1, value)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_inc_price_belief_sell(pop_id, index, value)
    ---@type number
    local current = DCON.dcon_pop_get_price_belief_sell(pop_id - 1, index - 1)
    DCON.dcon_pop_set_price_belief_sell(pop_id - 1, index - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid
---@return number price_belief_buy 
function DATA.pop_get_price_belief_buy(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_price_belief_buy(pop_id - 1, index - 1)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_set_price_belief_buy(pop_id, index, value)
    DCON.dcon_pop_set_price_belief_buy(pop_id - 1, index - 1, value)
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_inc_price_belief_buy(pop_id, index, value)
    ---@type number
    local current = DCON.dcon_pop_get_price_belief_buy(pop_id - 1, index - 1)
    DCON.dcon_pop_set_price_belief_buy(pop_id - 1, index - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number savings 
function DATA.pop_get_savings(pop_id)
    return DCON.dcon_pop_get_savings(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_savings(pop_id, value)
    DCON.dcon_pop_set_savings(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_savings(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_savings(pop_id - 1)
    DCON.dcon_pop_set_savings(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number expected_wage 
function DATA.pop_get_expected_wage(pop_id)
    return DCON.dcon_pop_get_expected_wage(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_expected_wage(pop_id, value)
    DCON.dcon_pop_set_expected_wage(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_expected_wage(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_expected_wage(pop_id - 1)
    DCON.dcon_pop_set_expected_wage(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number life_needs_satisfaction from 0 to 1
function DATA.pop_get_life_needs_satisfaction(pop_id)
    return DCON.dcon_pop_get_life_needs_satisfaction(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_life_needs_satisfaction(pop_id, value)
    DCON.dcon_pop_set_life_needs_satisfaction(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_life_needs_satisfaction(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_life_needs_satisfaction(pop_id - 1)
    DCON.dcon_pop_set_life_needs_satisfaction(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number basic_needs_satisfaction from 0 to 1
function DATA.pop_get_basic_needs_satisfaction(pop_id)
    return DCON.dcon_pop_get_basic_needs_satisfaction(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_basic_needs_satisfaction(pop_id, value)
    DCON.dcon_pop_set_basic_needs_satisfaction(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_basic_needs_satisfaction(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_basic_needs_satisfaction(pop_id - 1)
    DCON.dcon_pop_set_basic_needs_satisfaction(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number pending_economy_income 
function DATA.pop_get_pending_economy_income(pop_id)
    return DCON.dcon_pop_get_pending_economy_income(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_pending_economy_income(pop_id, value)
    DCON.dcon_pop_set_pending_economy_income(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_pending_economy_income(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_pending_economy_income(pop_id - 1)
    DCON.dcon_pop_set_pending_economy_income(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number forage_ratio a number in (0, 1) interval representing a ratio of time pop spends to forage
function DATA.pop_get_forage_ratio(pop_id)
    return DCON.dcon_pop_get_forage_ratio(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_forage_ratio(pop_id, value)
    DCON.dcon_pop_set_forage_ratio(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_forage_ratio(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_forage_ratio(pop_id - 1)
    DCON.dcon_pop_set_forage_ratio(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number work_ratio a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
function DATA.pop_get_work_ratio(pop_id)
    return DCON.dcon_pop_get_work_ratio(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_work_ratio(pop_id, value)
    DCON.dcon_pop_set_work_ratio(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_work_ratio(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_work_ratio(pop_id - 1)
    DCON.dcon_pop_set_work_ratio(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return number spend_savings_ratio a number in (0, 1) interval representing a ratio of savings pop spends on satisfaction of needs
function DATA.pop_get_spend_savings_ratio(pop_id)
    return DCON.dcon_pop_get_spend_savings_ratio(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_spend_savings_ratio(pop_id, value)
    DCON.dcon_pop_set_spend_savings_ratio(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_spend_savings_ratio(pop_id, value)
    ---@type number
    local current = DCON.dcon_pop_get_spend_savings_ratio(pop_id - 1)
    DCON.dcon_pop_set_spend_savings_ratio(pop_id - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return boolean female 
function DATA.pop_get_female(pop_id)
    return DCON.dcon_pop_get_female(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_female(pop_id, value)
    DCON.dcon_pop_set_female(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@return boolean busy 
function DATA.pop_get_busy(pop_id)
    return DCON.dcon_pop_get_busy(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_busy(pop_id, value)
    DCON.dcon_pop_set_busy(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@return boolean former_pop 
function DATA.pop_get_former_pop(pop_id)
    return DCON.dcon_pop_get_former_pop(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_former_pop(pop_id, value)
    DCON.dcon_pop_set_former_pop(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@return boolean dead 
function DATA.pop_get_dead(pop_id)
    return DCON.dcon_pop_get_dead(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_dead(pop_id, value)
    DCON.dcon_pop_set_dead(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@return boolean free_will 
function DATA.pop_get_free_will(pop_id)
    return DCON.dcon_pop_get_free_will(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_free_will(pop_id, value)
    DCON.dcon_pop_set_free_will(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@return boolean is_player 
function DATA.pop_get_is_player(pop_id)
    return DCON.dcon_pop_get_is_player(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_is_player(pop_id, value)
    DCON.dcon_pop_set_is_player(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@return CHARACTER_RANK rank 
function DATA.pop_get_rank(pop_id)
    return DCON.dcon_pop_get_rank(pop_id - 1)
end
---@param pop_id pop_id valid pop id
---@param value CHARACTER_RANK valid CHARACTER_RANK
function DATA.pop_set_rank(pop_id, value)
    DCON.dcon_pop_set_rank(pop_id - 1, value)
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return number dna 
function DATA.pop_get_dna(pop_id, index)
    assert(index ~= 0)
    return DCON.dcon_pop_get_dna(pop_id - 1, index - 1)
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_set_dna(pop_id, index, value)
    DCON.dcon_pop_set_dna(pop_id - 1, index - 1, value)
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_inc_dna(pop_id, index, value)
    ---@type number
    local current = DCON.dcon_pop_get_dna(pop_id - 1, index - 1)
    DCON.dcon_pop_set_dna(pop_id - 1, index - 1, current + value)
end
---@param pop_id pop_id valid pop id
---@return AI_DATA ai_data 
function DATA.pop_get_ai_data(pop_id)
    return DATA.pop_ai_data[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value AI_DATA valid AI_DATA
function DATA.pop_set_ai_data(pop_id, value)
    DATA.pop_ai_data[pop_id] = value
end

local fat_pop_id_metatable = {
    __index = function (t,k)
        if (k == "unique_id") then return DATA.pop_get_unique_id(t.id) end
        if (k == "race") then return DATA.pop_get_race(t.id) end
        if (k == "faith") then return DATA.pop_get_faith(t.id) end
        if (k == "rite") then return DATA.pop_get_rite(t.id) end
        if (k == "culture") then return DATA.pop_get_culture(t.id) end
        if (k == "birth_year") then return DATA.pop_get_birth_year(t.id) end
        if (k == "birth_tick") then return DATA.pop_get_birth_tick(t.id) end
        if (k == "name") then return DATA.pop_get_name(t.id) end
        if (k == "savings") then return DATA.pop_get_savings(t.id) end
        if (k == "expected_wage") then return DATA.pop_get_expected_wage(t.id) end
        if (k == "life_needs_satisfaction") then return DATA.pop_get_life_needs_satisfaction(t.id) end
        if (k == "basic_needs_satisfaction") then return DATA.pop_get_basic_needs_satisfaction(t.id) end
        if (k == "pending_economy_income") then return DATA.pop_get_pending_economy_income(t.id) end
        if (k == "forage_ratio") then return DATA.pop_get_forage_ratio(t.id) end
        if (k == "work_ratio") then return DATA.pop_get_work_ratio(t.id) end
        if (k == "spend_savings_ratio") then return DATA.pop_get_spend_savings_ratio(t.id) end
        if (k == "female") then return DATA.pop_get_female(t.id) end
        if (k == "busy") then return DATA.pop_get_busy(t.id) end
        if (k == "former_pop") then return DATA.pop_get_former_pop(t.id) end
        if (k == "dead") then return DATA.pop_get_dead(t.id) end
        if (k == "free_will") then return DATA.pop_get_free_will(t.id) end
        if (k == "is_player") then return DATA.pop_get_is_player(t.id) end
        if (k == "rank") then return DATA.pop_get_rank(t.id) end
        if (k == "ai_data") then return DATA.pop_get_ai_data(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "unique_id") then
            DATA.pop_set_unique_id(t.id, v)
            return
        end
        if (k == "race") then
            DATA.pop_set_race(t.id, v)
            return
        end
        if (k == "faith") then
            DATA.pop_set_faith(t.id, v)
            return
        end
        if (k == "rite") then
            DATA.pop_set_rite(t.id, v)
            return
        end
        if (k == "culture") then
            DATA.pop_set_culture(t.id, v)
            return
        end
        if (k == "birth_year") then
            DATA.pop_set_birth_year(t.id, v)
            return
        end
        if (k == "birth_tick") then
            DATA.pop_set_birth_tick(t.id, v)
            return
        end
        if (k == "name") then
            DATA.pop_set_name(t.id, v)
            return
        end
        if (k == "savings") then
            DATA.pop_set_savings(t.id, v)
            return
        end
        if (k == "expected_wage") then
            DATA.pop_set_expected_wage(t.id, v)
            return
        end
        if (k == "life_needs_satisfaction") then
            DATA.pop_set_life_needs_satisfaction(t.id, v)
            return
        end
        if (k == "basic_needs_satisfaction") then
            DATA.pop_set_basic_needs_satisfaction(t.id, v)
            return
        end
        if (k == "pending_economy_income") then
            DATA.pop_set_pending_economy_income(t.id, v)
            return
        end
        if (k == "forage_ratio") then
            DATA.pop_set_forage_ratio(t.id, v)
            return
        end
        if (k == "work_ratio") then
            DATA.pop_set_work_ratio(t.id, v)
            return
        end
        if (k == "spend_savings_ratio") then
            DATA.pop_set_spend_savings_ratio(t.id, v)
            return
        end
        if (k == "female") then
            DATA.pop_set_female(t.id, v)
            return
        end
        if (k == "busy") then
            DATA.pop_set_busy(t.id, v)
            return
        end
        if (k == "former_pop") then
            DATA.pop_set_former_pop(t.id, v)
            return
        end
        if (k == "dead") then
            DATA.pop_set_dead(t.id, v)
            return
        end
        if (k == "free_will") then
            DATA.pop_set_free_will(t.id, v)
            return
        end
        if (k == "is_player") then
            DATA.pop_set_is_player(t.id, v)
            return
        end
        if (k == "rank") then
            DATA.pop_set_rank(t.id, v)
            return
        end
        if (k == "ai_data") then
            DATA.pop_set_ai_data(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id pop_id
---@return fat_pop_id fat_id
function DATA.fatten_pop(id)
    local result = {id = id}
    setmetatable(result, fat_pop_id_metatable)
    return result --[[@as fat_pop_id]]
end
