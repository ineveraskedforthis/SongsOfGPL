local ffi = require("ffi")
----------character_location----------


---character_location: LSP types---

---Unique identificator for character_location entity
---@class (exact) character_location_id : table
---@field is_character_location number
---@class (exact) fat_character_location_id
---@field id character_location_id Unique character_location id
---@field estate estate_id location of character
---@field character pop_id 

---@class struct_character_location


ffi.cdef[[
void dcon_delete_character_location(int32_t j);
int32_t dcon_force_create_character_location(int32_t estate, int32_t character);
void dcon_character_location_set_estate(int32_t, int32_t);
int32_t dcon_character_location_get_estate(int32_t);
int32_t dcon_estate_get_range_character_location_as_estate(int32_t);
int32_t dcon_estate_get_index_character_location_as_estate(int32_t, int32_t);
void dcon_character_location_set_character(int32_t, int32_t);
int32_t dcon_character_location_get_character(int32_t);
int32_t dcon_pop_get_character_location_as_character(int32_t);
bool dcon_character_location_is_valid(int32_t);
void dcon_character_location_resize(uint32_t sz);
uint32_t dcon_character_location_size();
]]

---character_location: FFI arrays---

---character_location: LUA bindings---

DATA.character_location_size = 100000
---@param estate estate_id
---@param character pop_id
---@return character_location_id
function DATA.force_create_character_location(estate, character)
    ---@type character_location_id
    local i = DCON.dcon_force_create_character_location(estate - 1, character - 1) + 1
    return i --[[@as character_location_id]] 
end
---@param i character_location_id
function DATA.delete_character_location(i)
    assert(DCON.dcon_character_location_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_character_location(i - 1)
end
---@param func fun(item: character_location_id) 
function DATA.for_each_character_location(func)
    ---@type number
    local range = DCON.dcon_character_location_size()
    for i = 0, range - 1 do
        if DCON.dcon_character_location_is_valid(i) then func(i + 1 --[[@as character_location_id]]) end
    end
end
---@param func fun(item: character_location_id):boolean 
---@return table<character_location_id, character_location_id> 
function DATA.filter_character_location(func)
    ---@type table<character_location_id, character_location_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_character_location_size()
    for i = 0, range - 1 do
        if DCON.dcon_character_location_is_valid(i) and func(i + 1 --[[@as character_location_id]]) then t[i + 1 --[[@as character_location_id]]] = i + 1 --[[@as character_location_id]] end
    end
    return t
end

---@param estate character_location_id valid estate_id
---@return estate_id Data retrieved from character_location 
function DATA.character_location_get_estate(estate)
    return DCON.dcon_character_location_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return character_location_id[] An array of character_location 
function DATA.get_character_location_from_estate(estate)
    local result = {}
    DATA.for_each_character_location_from_estate(estate, function(item) 
        table.insert(result, item)
    end)
    return result
end
---@param estate estate_id valid estate_id
---@param func fun(item: character_location_id) valid estate_id
function DATA.for_each_character_location_from_estate(estate, func)
    ---@type number
    local range = DCON.dcon_estate_get_range_character_location_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type character_location_id
        local accessed_element = DCON.dcon_estate_get_index_character_location_as_estate(estate - 1, i) + 1
        if DCON.dcon_character_location_is_valid(accessed_element - 1) then func(accessed_element) end
    end
end
---@param estate estate_id valid estate_id
---@param func fun(item: character_location_id):boolean 
---@return character_location_id[]
function DATA.filter_array_character_location_from_estate(estate, func)
    ---@type table<character_location_id, character_location_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_character_location_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type character_location_id
        local accessed_element = DCON.dcon_estate_get_index_character_location_as_estate(estate - 1, i) + 1
        if DCON.dcon_character_location_is_valid(accessed_element - 1) and func(accessed_element) then table.insert(t, accessed_element) end
    end
    return t
end
---@param estate estate_id valid estate_id
---@param func fun(item: character_location_id):boolean 
---@return table<character_location_id, character_location_id> 
function DATA.filter_character_location_from_estate(estate, func)
    ---@type table<character_location_id, character_location_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_get_range_character_location_as_estate(estate - 1)
    for i = 0, range - 1 do
        ---@type character_location_id
        local accessed_element = DCON.dcon_estate_get_index_character_location_as_estate(estate - 1, i) + 1
        if DCON.dcon_character_location_is_valid(accessed_element - 1) and func(accessed_element) then t[accessed_element] = accessed_element end
    end
    return t
end
---@param character_location_id character_location_id valid character_location id
---@param value estate_id valid estate_id
function DATA.character_location_set_estate(character_location_id, value)
    DCON.dcon_character_location_set_estate(character_location_id - 1, value - 1)
end
---@param character character_location_id valid pop_id
---@return pop_id Data retrieved from character_location 
function DATA.character_location_get_character(character)
    return DCON.dcon_character_location_get_character(character - 1) + 1
end
---@param character pop_id valid pop_id
---@return character_location_id character_location 
function DATA.get_character_location_from_character(character)
    return DCON.dcon_pop_get_character_location_as_character(character - 1) + 1
end
---@param character_location_id character_location_id valid character_location id
---@param value pop_id valid pop_id
function DATA.character_location_set_character(character_location_id, value)
    DCON.dcon_character_location_set_character(character_location_id - 1, value - 1)
end

local fat_character_location_id_metatable = {
    __index = function (t,k)
        if (k == "estate") then return DATA.character_location_get_estate(t.id) end
        if (k == "character") then return DATA.character_location_get_character(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "estate") then
            DATA.character_location_set_estate(t.id, v)
            return
        end
        if (k == "character") then
            DATA.character_location_set_character(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id character_location_id
---@return fat_character_location_id fat_id
function DATA.fatten_character_location(id)
    local result = {id = id}
    setmetatable(result, fat_character_location_id_metatable)
    return result --[[@as fat_character_location_id]]
end
