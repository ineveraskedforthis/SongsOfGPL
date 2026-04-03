local ffi = require("ffi")
----------pop_location----------


---pop_location: LSP types---

---Unique identificator for pop_location entity
---@class (exact) pop_location_id : table
---@field is_pop_location number
---@class (exact) fat_pop_location_id
---@field id pop_location_id Unique pop_location id
---@field estate estate_id location of pop
---@field pop pop_id 

---@class struct_pop_location


ffi.cdef[[
void dcon_delete_pop_location(int32_t j);
int32_t dcon_force_create_pop_location(int32_t estate, int32_t pop);
void dcon_pop_location_set_estate(int32_t, int32_t);
int32_t dcon_pop_location_get_estate(int32_t);
int32_t dcon_estate_get_range_pop_location_as_estate(int32_t);
int32_t dcon_estate_get_index_pop_location_as_estate(int32_t, int32_t);
void dcon_pop_location_set_pop(int32_t, int32_t);
int32_t dcon_pop_location_get_pop(int32_t);
int32_t dcon_pop_get_pop_location_as_pop(int32_t);
bool dcon_pop_location_is_valid(int32_t);
void dcon_pop_location_resize(uint32_t sz);
uint32_t dcon_pop_location_size();
]]

---pop_location: FFI arrays---

---pop_location: LUA bindings---

DATA.pop_location_size = 300000
---@param estate estate_id
---@param pop pop_id
---@return pop_location_id
function DATA.force_create_pop_location(estate, pop)
    ---@type pop_location_id
    local i = DCON.dcon_force_create_pop_location(estate - 1, pop - 1) + 1
    return i --[[@as pop_location_id]] 
end
---@param i pop_location_id
function DATA.delete_pop_location(i)
    assert(DCON.dcon_pop_location_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_pop_location(i - 1)
end
---@param func fun(item: pop_location_id) 
function DATA.for_each_pop_location(func)
    ---@type number
    local range = DCON.dcon_pop_location_size()
    for i = 0, range - 1 do
        if DCON.dcon_pop_location_is_valid(i) then func(i + 1 --[[@as pop_location_id]]) end
    end
end
---@param func fun(item: pop_location_id):boolean 
---@return table<pop_location_id, pop_location_id> 
function DATA.filter_pop_location(func)
    ---@type table<pop_location_id, pop_location_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_pop_location_size()
    for i = 0, range - 1 do
        if DCON.dcon_pop_location_is_valid(i) and func(i + 1 --[[@as pop_location_id]]) then t[i + 1 --[[@as pop_location_id]]] = i + 1 --[[@as pop_location_id]] end
    end
    return t
end

---@param estate pop_location_id valid estate_id
---@return estate_id Data retrieved from pop_location 
function DATA.pop_location_get_estate(estate)
    return DCON.dcon_pop_location_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return pop_location_id[] An array of pop_location 
function DATA.get_pop_location_from_estate(estate)
    local result = {}
    DATA.for_each_pop_location_from_estate(estate, function(item) 
        table.insert(result, item)
    end)
    return result
end
---@param estate estate_id valid estate_id
---@param func fun(item: pop_location_id) valid estate_id
function DATA.for_each_pop_location_from_estate(estate, func)
    ---@type number
    local range = DCON.dcon_estate_get_range_pop_location_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type pop_location_id
        local accessed_element = DCON.dcon_estate_get_index_pop_location_as_estate(estate - 1, i) + 1
        if DCON.dcon_pop_location_is_valid(accessed_element - 1) then func(accessed_element) end
    end
end
---@param estate estate_id valid estate_id
---@param func fun(item: pop_location_id):boolean 
---@return pop_location_id[]
function DATA.filter_array_pop_location_from_estate(estate, func)
    ---@type table<pop_location_id, pop_location_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_pop_location_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type pop_location_id
        local accessed_element = DCON.dcon_estate_get_index_pop_location_as_estate(estate - 1, i) + 1
        if DCON.dcon_pop_location_is_valid(accessed_element - 1) and func(accessed_element) then table.insert(t, accessed_element) end
    end
    return t
end
---@param estate estate_id valid estate_id
---@param func fun(item: pop_location_id):boolean 
---@return table<pop_location_id, pop_location_id> 
function DATA.filter_pop_location_from_estate(estate, func)
    ---@type table<pop_location_id, pop_location_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_pop_location_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type pop_location_id
        local accessed_element = DCON.dcon_estate_get_index_pop_location_as_estate(estate - 1, i) + 1
        if DCON.dcon_pop_location_is_valid(accessed_element - 1) and func(accessed_element) then t[accessed_element] = accessed_element end
    end
    return t
end
---@param pop_location_id pop_location_id valid pop_location id
---@param value estate_id valid estate_id
function DATA.pop_location_set_estate(pop_location_id, value)
    DCON.dcon_pop_location_set_estate(pop_location_id - 1, value - 1)
end
---@param pop pop_location_id valid pop_id
---@return pop_id Data retrieved from pop_location 
function DATA.pop_location_get_pop(pop)
    return DCON.dcon_pop_location_get_pop(pop - 1) + 1
end
---@param pop pop_id valid pop_id
---@return pop_location_id pop_location 
function DATA.get_pop_location_from_pop(pop)
    return DCON.dcon_pop_get_pop_location_as_pop(pop - 1) + 1
end
---@param pop_location_id pop_location_id valid pop_location id
---@param value pop_id valid pop_id
function DATA.pop_location_set_pop(pop_location_id, value)
    DCON.dcon_pop_location_set_pop(pop_location_id - 1, value - 1)
end

local fat_pop_location_id_metatable = {
    __index = function (t,k)
        if (k == "estate") then return DATA.pop_location_get_estate(t.id) end
        if (k == "pop") then return DATA.pop_location_get_pop(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "estate") then
            DATA.pop_location_set_estate(t.id, v)
            return
        end
        if (k == "pop") then
            DATA.pop_location_set_pop(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id pop_location_id
---@return fat_pop_location_id fat_id
function DATA.fatten_pop_location(id)
    local result = {id = id}
    setmetatable(result, fat_pop_location_id_metatable)
    return result --[[@as fat_pop_location_id]]
end
