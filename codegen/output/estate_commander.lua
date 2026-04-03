local ffi = require("ffi")
----------estate_commander----------


---estate_commander: LSP types---

---Unique identificator for estate_commander entity
---@class (exact) estate_commander_id : table
---@field is_estate_commander number
---@class (exact) fat_estate_commander_id
---@field id estate_commander_id Unique estate_commander id
---@field commander pop_id 
---@field estate estate_id 

---@class struct_estate_commander


ffi.cdef[[
void dcon_delete_estate_commander(int32_t j);
int32_t dcon_force_create_estate_commander(int32_t commander, int32_t estate);
void dcon_estate_commander_set_commander(int32_t, int32_t);
int32_t dcon_estate_commander_get_commander(int32_t);
int32_t dcon_pop_get_estate_commander_as_commander(int32_t);
void dcon_estate_commander_set_estate(int32_t, int32_t);
int32_t dcon_estate_commander_get_estate(int32_t);
int32_t dcon_estate_get_estate_commander_as_estate(int32_t);
bool dcon_estate_commander_is_valid(int32_t);
void dcon_estate_commander_resize(uint32_t sz);
uint32_t dcon_estate_commander_size();
]]

---estate_commander: FFI arrays---

---estate_commander: LUA bindings---

DATA.estate_commander_size = 50000
---@param commander pop_id
---@param estate estate_id
---@return estate_commander_id
function DATA.force_create_estate_commander(commander, estate)
    ---@type estate_commander_id
    local i = DCON.dcon_force_create_estate_commander(commander - 1, estate - 1) + 1
    return i --[[@as estate_commander_id]] 
end
---@param i estate_commander_id
function DATA.delete_estate_commander(i)
    assert(DCON.dcon_estate_commander_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_estate_commander(i - 1)
end
---@param func fun(item: estate_commander_id) 
function DATA.for_each_estate_commander(func)
    ---@type number
    local range = DCON.dcon_estate_commander_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_commander_is_valid(i) then func(i + 1 --[[@as estate_commander_id]]) end
    end
end
---@param func fun(item: estate_commander_id):boolean 
---@return table<estate_commander_id, estate_commander_id> 
function DATA.filter_estate_commander(func)
    ---@type table<estate_commander_id, estate_commander_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_commander_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_commander_is_valid(i) and func(i + 1 --[[@as estate_commander_id]]) then t[i + 1 --[[@as estate_commander_id]]] = i + 1 --[[@as estate_commander_id]] end
    end
    return t
end

---@param commander estate_commander_id valid pop_id
---@return pop_id Data retrieved from estate_commander 
function DATA.estate_commander_get_commander(commander)
    return DCON.dcon_estate_commander_get_commander(commander - 1) + 1
end
---@param commander pop_id valid pop_id
---@return estate_commander_id estate_commander 
function DATA.get_estate_commander_from_commander(commander)
    return DCON.dcon_pop_get_estate_commander_as_commander(commander - 1) + 1
end
---@param estate_commander_id estate_commander_id valid estate_commander id
---@param value pop_id valid pop_id
function DATA.estate_commander_set_commander(estate_commander_id, value)
    DCON.dcon_estate_commander_set_commander(estate_commander_id - 1, value - 1)
end
---@param estate estate_commander_id valid estate_id
---@return estate_id Data retrieved from estate_commander 
function DATA.estate_commander_get_estate(estate)
    return DCON.dcon_estate_commander_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return estate_commander_id estate_commander 
function DATA.get_estate_commander_from_estate(estate)
    return DCON.dcon_estate_get_estate_commander_as_estate(estate - 1) + 1
end
---@param estate_commander_id estate_commander_id valid estate_commander id
---@param value estate_id valid estate_id
function DATA.estate_commander_set_estate(estate_commander_id, value)
    DCON.dcon_estate_commander_set_estate(estate_commander_id - 1, value - 1)
end

local fat_estate_commander_id_metatable = {
    __index = function (t,k)
        if (k == "commander") then return DATA.estate_commander_get_commander(t.id) end
        if (k == "estate") then return DATA.estate_commander_get_estate(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "commander") then
            DATA.estate_commander_set_commander(t.id, v)
            return
        end
        if (k == "estate") then
            DATA.estate_commander_set_estate(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_commander_id
---@return fat_estate_commander_id fat_id
function DATA.fatten_estate_commander(id)
    local result = {id = id}
    setmetatable(result, fat_estate_commander_id_metatable)
    return result --[[@as fat_estate_commander_id]]
end
