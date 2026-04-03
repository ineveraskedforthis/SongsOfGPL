local ffi = require("ffi")
----------home----------


---home: LSP types---

---Unique identificator for home entity
---@class (exact) home_id : table
---@field is_home number
---@class (exact) fat_home_id
---@field id home_id Unique home id
---@field estate estate_id home of pop
---@field pop pop_id characters and pops which think of this estate as their home

---@class struct_home


ffi.cdef[[
void dcon_delete_home(int32_t j);
int32_t dcon_force_create_home(int32_t estate, int32_t pop);
void dcon_home_set_estate(int32_t, int32_t);
int32_t dcon_home_get_estate(int32_t);
int32_t dcon_estate_get_range_home_as_estate(int32_t);
int32_t dcon_estate_get_index_home_as_estate(int32_t, int32_t);
void dcon_home_set_pop(int32_t, int32_t);
int32_t dcon_home_get_pop(int32_t);
int32_t dcon_pop_get_home_as_pop(int32_t);
bool dcon_home_is_valid(int32_t);
void dcon_home_resize(uint32_t sz);
uint32_t dcon_home_size();
]]

---home: FFI arrays---

---home: LUA bindings---

DATA.home_size = 300000
---@param estate estate_id
---@param pop pop_id
---@return home_id
function DATA.force_create_home(estate, pop)
    ---@type home_id
    local i = DCON.dcon_force_create_home(estate - 1, pop - 1) + 1
    return i --[[@as home_id]] 
end
---@param i home_id
function DATA.delete_home(i)
    assert(DCON.dcon_home_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_home(i - 1)
end
---@param func fun(item: home_id) 
function DATA.for_each_home(func)
    ---@type number
    local range = DCON.dcon_home_size()
    for i = 0, range - 1 do
        if DCON.dcon_home_is_valid(i) then func(i + 1 --[[@as home_id]]) end
    end
end
---@param func fun(item: home_id):boolean 
---@return table<home_id, home_id> 
function DATA.filter_home(func)
    ---@type table<home_id, home_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_home_size()
    for i = 0, range - 1 do
        if DCON.dcon_home_is_valid(i) and func(i + 1 --[[@as home_id]]) then t[i + 1 --[[@as home_id]]] = i + 1 --[[@as home_id]] end
    end
    return t
end

---@param estate home_id valid estate_id
---@return estate_id Data retrieved from home 
function DATA.home_get_estate(estate)
    return DCON.dcon_home_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return home_id[] An array of home 
function DATA.get_home_from_estate(estate)
    local result = {}
    DATA.for_each_home_from_estate(estate, function(item) 
        table.insert(result, item)
    end)
    return result
end
---@param estate estate_id valid estate_id
---@param func fun(item: home_id) valid estate_id
function DATA.for_each_home_from_estate(estate, func)
    ---@type number
    local range = DCON.dcon_estate_get_range_home_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type home_id
        local accessed_element = DCON.dcon_estate_get_index_home_as_estate(estate - 1, i) + 1
        if DCON.dcon_home_is_valid(accessed_element - 1) then func(accessed_element) end
    end
end
---@param estate estate_id valid estate_id
---@param func fun(item: home_id):boolean 
---@return home_id[]
function DATA.filter_array_home_from_estate(estate, func)
    ---@type table<home_id, home_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_home_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type home_id
        local accessed_element = DCON.dcon_estate_get_index_home_as_estate(estate - 1, i) + 1
        if DCON.dcon_home_is_valid(accessed_element - 1) and func(accessed_element) then table.insert(t, accessed_element) end
    end
    return t
end
---@param estate estate_id valid estate_id
---@param func fun(item: home_id):boolean 
---@return table<home_id, home_id> 
function DATA.filter_home_from_estate(estate, func)
    ---@type table<home_id, home_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_home_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type home_id
        local accessed_element = DCON.dcon_estate_get_index_home_as_estate(estate - 1, i) + 1
        if DCON.dcon_home_is_valid(accessed_element - 1) and func(accessed_element) then t[accessed_element] = accessed_element end
    end
    return t
end
---@param home_id home_id valid home id
---@param value estate_id valid estate_id
function DATA.home_set_estate(home_id, value)
    DCON.dcon_home_set_estate(home_id - 1, value - 1)
end
---@param pop home_id valid pop_id
---@return pop_id Data retrieved from home 
function DATA.home_get_pop(pop)
    return DCON.dcon_home_get_pop(pop - 1) + 1
end
---@param pop pop_id valid pop_id
---@return home_id home 
function DATA.get_home_from_pop(pop)
    return DCON.dcon_pop_get_home_as_pop(pop - 1) + 1
end
---@param home_id home_id valid home id
---@param value pop_id valid pop_id
function DATA.home_set_pop(home_id, value)
    DCON.dcon_home_set_pop(home_id - 1, value - 1)
end

local fat_home_id_metatable = {
    __index = function (t,k)
        if (k == "estate") then return DATA.home_get_estate(t.id) end
        if (k == "pop") then return DATA.home_get_pop(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "estate") then
            DATA.home_set_estate(t.id, v)
            return
        end
        if (k == "pop") then
            DATA.home_set_pop(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id home_id
---@return fat_home_id fat_id
function DATA.fatten_home(id)
    local result = {id = id}
    setmetatable(result, fat_home_id_metatable)
    return result --[[@as fat_home_id]]
end
