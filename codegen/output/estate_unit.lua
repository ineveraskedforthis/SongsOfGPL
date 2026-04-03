local ffi = require("ffi")
----------estate_unit----------


---estate_unit: LSP types---

---Unique identificator for estate_unit entity
---@class (exact) estate_unit_id : table
---@field is_estate_unit number
---@class (exact) fat_estate_unit_id
---@field id estate_unit_id Unique estate_unit id
---@field type unit_type_id Current unit type
---@field pop pop_id 
---@field estate estate_id 

---@class struct_estate_unit
---@field type unit_type_id Current unit type


ffi.cdef[[
void dcon_estate_unit_set_type(int32_t, int32_t);
int32_t dcon_estate_unit_get_type(int32_t);
void dcon_delete_estate_unit(int32_t j);
int32_t dcon_force_create_estate_unit(int32_t pop, int32_t estate);
void dcon_estate_unit_set_pop(int32_t, int32_t);
int32_t dcon_estate_unit_get_pop(int32_t);
int32_t dcon_pop_get_estate_unit_as_pop(int32_t);
void dcon_estate_unit_set_estate(int32_t, int32_t);
int32_t dcon_estate_unit_get_estate(int32_t);
int32_t dcon_estate_get_range_estate_unit_as_estate(int32_t);
int32_t dcon_estate_get_index_estate_unit_as_estate(int32_t, int32_t);
bool dcon_estate_unit_is_valid(int32_t);
void dcon_estate_unit_resize(uint32_t sz);
uint32_t dcon_estate_unit_size();
]]

---estate_unit: FFI arrays---

---estate_unit: LUA bindings---

DATA.estate_unit_size = 300000
---@param pop pop_id
---@param estate estate_id
---@return estate_unit_id
function DATA.force_create_estate_unit(pop, estate)
    ---@type estate_unit_id
    local i = DCON.dcon_force_create_estate_unit(pop - 1, estate - 1) + 1
    return i --[[@as estate_unit_id]] 
end
---@param i estate_unit_id
function DATA.delete_estate_unit(i)
    assert(DCON.dcon_estate_unit_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_estate_unit(i - 1)
end
---@param func fun(item: estate_unit_id) 
function DATA.for_each_estate_unit(func)
    ---@type number
    local range = DCON.dcon_estate_unit_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_unit_is_valid(i) then func(i + 1 --[[@as estate_unit_id]]) end
    end
end
---@param func fun(item: estate_unit_id):boolean 
---@return table<estate_unit_id, estate_unit_id> 
function DATA.filter_estate_unit(func)
    ---@type table<estate_unit_id, estate_unit_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_unit_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_unit_is_valid(i) and func(i + 1 --[[@as estate_unit_id]]) then t[i + 1 --[[@as estate_unit_id]]] = i + 1 --[[@as estate_unit_id]] end
    end
    return t
end

---@param estate_unit_id estate_unit_id valid estate_unit id
---@return unit_type_id type Current unit type
function DATA.estate_unit_get_type(estate_unit_id)
    return DCON.dcon_estate_unit_get_type(estate_unit_id - 1) + 1
end
---@param estate_unit_id estate_unit_id valid estate_unit id
---@param value unit_type_id valid unit_type_id
function DATA.estate_unit_set_type(estate_unit_id, value)
    DCON.dcon_estate_unit_set_type(estate_unit_id - 1, value - 1)
end
---@param pop estate_unit_id valid pop_id
---@return pop_id Data retrieved from estate_unit 
function DATA.estate_unit_get_pop(pop)
    return DCON.dcon_estate_unit_get_pop(pop - 1) + 1
end
---@param pop pop_id valid pop_id
---@return estate_unit_id estate_unit 
function DATA.get_estate_unit_from_pop(pop)
    return DCON.dcon_pop_get_estate_unit_as_pop(pop - 1) + 1
end
---@param estate_unit_id estate_unit_id valid estate_unit id
---@param value pop_id valid pop_id
function DATA.estate_unit_set_pop(estate_unit_id, value)
    DCON.dcon_estate_unit_set_pop(estate_unit_id - 1, value - 1)
end
---@param estate estate_unit_id valid estate_id
---@return estate_id Data retrieved from estate_unit 
function DATA.estate_unit_get_estate(estate)
    return DCON.dcon_estate_unit_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return estate_unit_id[] An array of estate_unit 
function DATA.get_estate_unit_from_estate(estate)
    local result = {}
    DATA.for_each_estate_unit_from_estate(estate, function(item) 
        table.insert(result, item)
    end)
    return result
end
---@param estate estate_id valid estate_id
---@param func fun(item: estate_unit_id) valid estate_id
function DATA.for_each_estate_unit_from_estate(estate, func)
    ---@type number
    local range = DCON.dcon_estate_get_range_estate_unit_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type estate_unit_id
        local accessed_element = DCON.dcon_estate_get_index_estate_unit_as_estate(estate - 1, i) + 1
        if DCON.dcon_estate_unit_is_valid(accessed_element - 1) then func(accessed_element) end
    end
end
---@param estate estate_id valid estate_id
---@param func fun(item: estate_unit_id):boolean 
---@return estate_unit_id[]
function DATA.filter_array_estate_unit_from_estate(estate, func)
    ---@type table<estate_unit_id, estate_unit_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_estate_unit_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type estate_unit_id
        local accessed_element = DCON.dcon_estate_get_index_estate_unit_as_estate(estate - 1, i) + 1
        if DCON.dcon_estate_unit_is_valid(accessed_element - 1) and func(accessed_element) then table.insert(t, accessed_element) end
    end
    return t
end
---@param estate estate_id valid estate_id
---@param func fun(item: estate_unit_id):boolean 
---@return table<estate_unit_id, estate_unit_id> 
function DATA.filter_estate_unit_from_estate(estate, func)
    ---@type table<estate_unit_id, estate_unit_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_estate_unit_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type estate_unit_id
        local accessed_element = DCON.dcon_estate_get_index_estate_unit_as_estate(estate - 1, i) + 1
        if DCON.dcon_estate_unit_is_valid(accessed_element - 1) and func(accessed_element) then t[accessed_element] = accessed_element end
    end
    return t
end
---@param estate_unit_id estate_unit_id valid estate_unit id
---@param value estate_id valid estate_id
function DATA.estate_unit_set_estate(estate_unit_id, value)
    DCON.dcon_estate_unit_set_estate(estate_unit_id - 1, value - 1)
end

local fat_estate_unit_id_metatable = {
    __index = function (t,k)
        if (k == "type") then return DATA.estate_unit_get_type(t.id) end
        if (k == "pop") then return DATA.estate_unit_get_pop(t.id) end
        if (k == "estate") then return DATA.estate_unit_get_estate(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "type") then
            DATA.estate_unit_set_type(t.id, v)
            return
        end
        if (k == "pop") then
            DATA.estate_unit_set_pop(t.id, v)
            return
        end
        if (k == "estate") then
            DATA.estate_unit_set_estate(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_unit_id
---@return fat_estate_unit_id fat_id
function DATA.fatten_estate_unit(id)
    local result = {id = id}
    setmetatable(result, fat_estate_unit_id_metatable)
    return result --[[@as fat_estate_unit_id]]
end
