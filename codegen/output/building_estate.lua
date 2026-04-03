local ffi = require("ffi")
----------building_estate----------


---building_estate: LSP types---

---Unique identificator for building_estate entity
---@class (exact) building_estate_id : table
---@field is_building_estate number
---@class (exact) fat_building_estate_id
---@field id building_estate_id Unique building_estate id
---@field estate estate_id location of the building
---@field building building_id 

---@class struct_building_estate


ffi.cdef[[
void dcon_delete_building_estate(int32_t j);
int32_t dcon_force_create_building_estate(int32_t estate, int32_t building);
void dcon_building_estate_set_estate(int32_t, int32_t);
int32_t dcon_building_estate_get_estate(int32_t);
int32_t dcon_estate_get_range_building_estate_as_estate(int32_t);
int32_t dcon_estate_get_index_building_estate_as_estate(int32_t, int32_t);
void dcon_building_estate_set_building(int32_t, int32_t);
int32_t dcon_building_estate_get_building(int32_t);
int32_t dcon_building_get_building_estate_as_building(int32_t);
bool dcon_building_estate_is_valid(int32_t);
void dcon_building_estate_resize(uint32_t sz);
uint32_t dcon_building_estate_size();
]]

---building_estate: FFI arrays---

---building_estate: LUA bindings---

DATA.building_estate_size = 6000000
---@param estate estate_id
---@param building building_id
---@return building_estate_id
function DATA.force_create_building_estate(estate, building)
    ---@type building_estate_id
    local i = DCON.dcon_force_create_building_estate(estate - 1, building - 1) + 1
    return i --[[@as building_estate_id]] 
end
---@param i building_estate_id
function DATA.delete_building_estate(i)
    assert(DCON.dcon_building_estate_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_building_estate(i - 1)
end
---@param func fun(item: building_estate_id) 
function DATA.for_each_building_estate(func)
    ---@type number
    local range = DCON.dcon_building_estate_size()
    for i = 0, range - 1 do
        if DCON.dcon_building_estate_is_valid(i) then func(i + 1 --[[@as building_estate_id]]) end
    end
end
---@param func fun(item: building_estate_id):boolean 
---@return table<building_estate_id, building_estate_id> 
function DATA.filter_building_estate(func)
    ---@type table<building_estate_id, building_estate_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_building_estate_size()
    for i = 0, range - 1 do
        if DCON.dcon_building_estate_is_valid(i) and func(i + 1 --[[@as building_estate_id]]) then t[i + 1 --[[@as building_estate_id]]] = i + 1 --[[@as building_estate_id]] end
    end
    return t
end

---@param estate building_estate_id valid estate_id
---@return estate_id Data retrieved from building_estate 
function DATA.building_estate_get_estate(estate)
    return DCON.dcon_building_estate_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return building_estate_id[] An array of building_estate 
function DATA.get_building_estate_from_estate(estate)
    local result = {}
    DATA.for_each_building_estate_from_estate(estate, function(item) 
        table.insert(result, item)
    end)
    return result
end
---@param estate estate_id valid estate_id
---@param func fun(item: building_estate_id) valid estate_id
function DATA.for_each_building_estate_from_estate(estate, func)
    ---@type number
    local range = DCON.dcon_estate_get_range_building_estate_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type building_estate_id
        local accessed_element = DCON.dcon_estate_get_index_building_estate_as_estate(estate - 1, i) + 1
        if DCON.dcon_building_estate_is_valid(accessed_element - 1) then func(accessed_element) end
    end
end
---@param estate estate_id valid estate_id
---@param func fun(item: building_estate_id):boolean 
---@return building_estate_id[]
function DATA.filter_array_building_estate_from_estate(estate, func)
    ---@type table<building_estate_id, building_estate_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_building_estate_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type building_estate_id
        local accessed_element = DCON.dcon_estate_get_index_building_estate_as_estate(estate - 1, i) + 1
        if DCON.dcon_building_estate_is_valid(accessed_element - 1) and func(accessed_element) then table.insert(t, accessed_element) end
    end
    return t
end
---@param estate estate_id valid estate_id
---@param func fun(item: building_estate_id):boolean 
---@return table<building_estate_id, building_estate_id> 
function DATA.filter_building_estate_from_estate(estate, func)
    ---@type table<building_estate_id, building_estate_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_building_estate_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type building_estate_id
        local accessed_element = DCON.dcon_estate_get_index_building_estate_as_estate(estate - 1, i) + 1
        if DCON.dcon_building_estate_is_valid(accessed_element - 1) and func(accessed_element) then t[accessed_element] = accessed_element end
    end
    return t
end
---@param building_estate_id building_estate_id valid building_estate id
---@param value estate_id valid estate_id
function DATA.building_estate_set_estate(building_estate_id, value)
    DCON.dcon_building_estate_set_estate(building_estate_id - 1, value - 1)
end
---@param building building_estate_id valid building_id
---@return building_id Data retrieved from building_estate 
function DATA.building_estate_get_building(building)
    return DCON.dcon_building_estate_get_building(building - 1) + 1
end
---@param building building_id valid building_id
---@return building_estate_id building_estate 
function DATA.get_building_estate_from_building(building)
    return DCON.dcon_building_get_building_estate_as_building(building - 1) + 1
end
---@param building_estate_id building_estate_id valid building_estate id
---@param value building_id valid building_id
function DATA.building_estate_set_building(building_estate_id, value)
    DCON.dcon_building_estate_set_building(building_estate_id - 1, value - 1)
end

local fat_building_estate_id_metatable = {
    __index = function (t,k)
        if (k == "estate") then return DATA.building_estate_get_estate(t.id) end
        if (k == "building") then return DATA.building_estate_get_building(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "estate") then
            DATA.building_estate_set_estate(t.id, v)
            return
        end
        if (k == "building") then
            DATA.building_estate_set_building(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id building_estate_id
---@return fat_building_estate_id fat_id
function DATA.fatten_building_estate(id)
    local result = {id = id}
    setmetatable(result, fat_building_estate_id_metatable)
    return result --[[@as fat_building_estate_id]]
end
