local ffi = require("ffi")
----------culture----------


---culture: LSP types---

---Unique identificator for culture entity
---@class (exact) culture_id : table
---@field is_culture number
---@class (exact) fat_culture_id
---@field id culture_id Unique culture id
---@field name string 
---@field r number 
---@field g number 
---@field b number 
---@field language language_id 
---@field traditional_militarization number A fraction of the society that cultures will try to put in military

---@class struct_culture
---@field r number 
---@field g number 
---@field b number 
---@field language language_id 
---@field traditional_units table<unit_type_id, number> -- Defines "traditional" ratios for units recruited from this culture.
---@field traditional_militarization number A fraction of the society that cultures will try to put in military
---@field traditional_forager_targets table<production_method_id, number> a culture's prefered foraging targets


ffi.cdef[[
void dcon_culture_set_r(int32_t, float);
float dcon_culture_get_r(int32_t);
void dcon_culture_set_g(int32_t, float);
float dcon_culture_get_g(int32_t);
void dcon_culture_set_b(int32_t, float);
float dcon_culture_get_b(int32_t);
void dcon_culture_set_language(int32_t, int32_t);
int32_t dcon_culture_get_language(int32_t);
void dcon_culture_resize_traditional_units(uint32_t);
void dcon_culture_set_traditional_units(int32_t, int32_t, float);
float dcon_culture_get_traditional_units(int32_t, int32_t);
void dcon_culture_set_traditional_militarization(int32_t, float);
float dcon_culture_get_traditional_militarization(int32_t);
void dcon_culture_resize_traditional_forager_targets(uint32_t);
void dcon_culture_set_traditional_forager_targets(int32_t, int32_t, float);
float dcon_culture_get_traditional_forager_targets(int32_t, int32_t);
void dcon_delete_culture(int32_t j);
int32_t dcon_create_culture();
bool dcon_culture_is_valid(int32_t);
void dcon_culture_resize(uint32_t sz);
uint32_t dcon_culture_size();
]]

---culture: FFI arrays---
---@type (string)[]
DATA.culture_name= {}

---culture: LUA bindings---

DATA.culture_size = 10000
DCON.dcon_culture_resize_traditional_units(6)
DCON.dcon_culture_resize_traditional_forager_targets(251)
---@return culture_id
function DATA.create_culture()
    ---@type culture_id
    local i  = DCON.dcon_create_culture() + 1
    return i --[[@as culture_id]] 
end
---@param i culture_id
function DATA.delete_culture(i)
    assert(DCON.dcon_culture_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_culture(i - 1)
end
---@param func fun(item: culture_id) 
function DATA.for_each_culture(func)
    ---@type number
    local range = DCON.dcon_culture_size()
    for i = 0, range - 1 do
        if DCON.dcon_culture_is_valid(i) then func(i + 1 --[[@as culture_id]]) end
    end
end
---@param func fun(item: culture_id):boolean 
---@return table<culture_id, culture_id> 
function DATA.filter_culture(func)
    ---@type table<culture_id, culture_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_culture_size()
    for i = 0, range - 1 do
        if DCON.dcon_culture_is_valid(i) and func(i + 1 --[[@as culture_id]]) then t[i + 1 --[[@as culture_id]]] = i + 1 --[[@as culture_id]] end
    end
    return t
end

---@param culture_id culture_id valid culture id
---@return string name 
function DATA.culture_get_name(culture_id)
    return DATA.culture_name[culture_id]
end
---@param culture_id culture_id valid culture id
---@param value string valid string
function DATA.culture_set_name(culture_id, value)
    DATA.culture_name[culture_id] = value
end
---@param culture_id culture_id valid culture id
---@return number r 
function DATA.culture_get_r(culture_id)
    return DCON.dcon_culture_get_r(culture_id - 1)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_set_r(culture_id, value)
    DCON.dcon_culture_set_r(culture_id - 1, value)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_inc_r(culture_id, value)
    ---@type number
    local current = DCON.dcon_culture_get_r(culture_id - 1)
    DCON.dcon_culture_set_r(culture_id - 1, current + value)
end
---@param culture_id culture_id valid culture id
---@return number g 
function DATA.culture_get_g(culture_id)
    return DCON.dcon_culture_get_g(culture_id - 1)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_set_g(culture_id, value)
    DCON.dcon_culture_set_g(culture_id - 1, value)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_inc_g(culture_id, value)
    ---@type number
    local current = DCON.dcon_culture_get_g(culture_id - 1)
    DCON.dcon_culture_set_g(culture_id - 1, current + value)
end
---@param culture_id culture_id valid culture id
---@return number b 
function DATA.culture_get_b(culture_id)
    return DCON.dcon_culture_get_b(culture_id - 1)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_set_b(culture_id, value)
    DCON.dcon_culture_set_b(culture_id - 1, value)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_inc_b(culture_id, value)
    ---@type number
    local current = DCON.dcon_culture_get_b(culture_id - 1)
    DCON.dcon_culture_set_b(culture_id - 1, current + value)
end
---@param culture_id culture_id valid culture id
---@return language_id language 
function DATA.culture_get_language(culture_id)
    return DCON.dcon_culture_get_language(culture_id - 1) + 1
end
---@param culture_id culture_id valid culture id
---@param value language_id valid language_id
function DATA.culture_set_language(culture_id, value)
    DCON.dcon_culture_set_language(culture_id - 1, value - 1)
end
---@param culture_id culture_id valid culture id
---@param index unit_type_id valid
---@return number traditional_units -- Defines "traditional" ratios for units recruited from this culture.
function DATA.culture_get_traditional_units(culture_id, index)
    assert(index ~= 0)
    return DCON.dcon_culture_get_traditional_units(culture_id - 1, index - 1)
end
---@param culture_id culture_id valid culture id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.culture_set_traditional_units(culture_id, index, value)
    DCON.dcon_culture_set_traditional_units(culture_id - 1, index - 1, value)
end
---@param culture_id culture_id valid culture id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.culture_inc_traditional_units(culture_id, index, value)
    ---@type number
    local current = DCON.dcon_culture_get_traditional_units(culture_id - 1, index - 1)
    DCON.dcon_culture_set_traditional_units(culture_id - 1, index - 1, current + value)
end
---@param culture_id culture_id valid culture id
---@return number traditional_militarization A fraction of the society that cultures will try to put in military
function DATA.culture_get_traditional_militarization(culture_id)
    return DCON.dcon_culture_get_traditional_militarization(culture_id - 1)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_set_traditional_militarization(culture_id, value)
    DCON.dcon_culture_set_traditional_militarization(culture_id - 1, value)
end
---@param culture_id culture_id valid culture id
---@param value number valid number
function DATA.culture_inc_traditional_militarization(culture_id, value)
    ---@type number
    local current = DCON.dcon_culture_get_traditional_militarization(culture_id - 1)
    DCON.dcon_culture_set_traditional_militarization(culture_id - 1, current + value)
end
---@param culture_id culture_id valid culture id
---@param index production_method_id valid
---@return number traditional_forager_targets a culture's prefered foraging targets
function DATA.culture_get_traditional_forager_targets(culture_id, index)
    assert(index ~= 0)
    return DCON.dcon_culture_get_traditional_forager_targets(culture_id - 1, index - 1)
end
---@param culture_id culture_id valid culture id
---@param index production_method_id valid index
---@param value number valid number
function DATA.culture_set_traditional_forager_targets(culture_id, index, value)
    DCON.dcon_culture_set_traditional_forager_targets(culture_id - 1, index - 1, value)
end
---@param culture_id culture_id valid culture id
---@param index production_method_id valid index
---@param value number valid number
function DATA.culture_inc_traditional_forager_targets(culture_id, index, value)
    ---@type number
    local current = DCON.dcon_culture_get_traditional_forager_targets(culture_id - 1, index - 1)
    DCON.dcon_culture_set_traditional_forager_targets(culture_id - 1, index - 1, current + value)
end

local fat_culture_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.culture_get_name(t.id) end
        if (k == "r") then return DATA.culture_get_r(t.id) end
        if (k == "g") then return DATA.culture_get_g(t.id) end
        if (k == "b") then return DATA.culture_get_b(t.id) end
        if (k == "language") then return DATA.culture_get_language(t.id) end
        if (k == "traditional_militarization") then return DATA.culture_get_traditional_militarization(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.culture_set_name(t.id, v)
            return
        end
        if (k == "r") then
            DATA.culture_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.culture_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.culture_set_b(t.id, v)
            return
        end
        if (k == "language") then
            DATA.culture_set_language(t.id, v)
            return
        end
        if (k == "traditional_militarization") then
            DATA.culture_set_traditional_militarization(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id culture_id
---@return fat_culture_id fat_id
function DATA.fatten_culture(id)
    local result = {id = id}
    setmetatable(result, fat_culture_id_metatable)
    return result --[[@as fat_culture_id]]
end
