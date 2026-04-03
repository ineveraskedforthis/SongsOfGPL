local ffi = require("ffi")
----------estate_leader----------


---estate_leader: LSP types---

---Unique identificator for estate_leader entity
---@class (exact) estate_leader_id : table
---@field is_estate_leader number
---@class (exact) fat_estate_leader_id
---@field id estate_leader_id Unique estate_leader id
---@field leader pop_id 
---@field estate estate_id 

---@class struct_estate_leader


ffi.cdef[[
void dcon_delete_estate_leader(int32_t j);
int32_t dcon_force_create_estate_leader(int32_t leader, int32_t estate);
void dcon_estate_leader_set_leader(int32_t, int32_t);
int32_t dcon_estate_leader_get_leader(int32_t);
int32_t dcon_pop_get_estate_leader_as_leader(int32_t);
void dcon_estate_leader_set_estate(int32_t, int32_t);
int32_t dcon_estate_leader_get_estate(int32_t);
int32_t dcon_estate_get_estate_leader_as_estate(int32_t);
bool dcon_estate_leader_is_valid(int32_t);
void dcon_estate_leader_resize(uint32_t sz);
uint32_t dcon_estate_leader_size();
]]

---estate_leader: FFI arrays---

---estate_leader: LUA bindings---

DATA.estate_leader_size = 50000
---@param leader pop_id
---@param estate estate_id
---@return estate_leader_id
function DATA.force_create_estate_leader(leader, estate)
    ---@type estate_leader_id
    local i = DCON.dcon_force_create_estate_leader(leader - 1, estate - 1) + 1
    return i --[[@as estate_leader_id]] 
end
---@param i estate_leader_id
function DATA.delete_estate_leader(i)
    assert(DCON.dcon_estate_leader_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_estate_leader(i - 1)
end
---@param func fun(item: estate_leader_id) 
function DATA.for_each_estate_leader(func)
    ---@type number
    local range = DCON.dcon_estate_leader_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_leader_is_valid(i) then func(i + 1 --[[@as estate_leader_id]]) end
    end
end
---@param func fun(item: estate_leader_id):boolean 
---@return table<estate_leader_id, estate_leader_id> 
function DATA.filter_estate_leader(func)
    ---@type table<estate_leader_id, estate_leader_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_leader_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_leader_is_valid(i) and func(i + 1 --[[@as estate_leader_id]]) then t[i + 1 --[[@as estate_leader_id]]] = i + 1 --[[@as estate_leader_id]] end
    end
    return t
end

---@param leader estate_leader_id valid pop_id
---@return pop_id Data retrieved from estate_leader 
function DATA.estate_leader_get_leader(leader)
    return DCON.dcon_estate_leader_get_leader(leader - 1) + 1
end
---@param leader pop_id valid pop_id
---@return estate_leader_id estate_leader 
function DATA.get_estate_leader_from_leader(leader)
    return DCON.dcon_pop_get_estate_leader_as_leader(leader - 1) + 1
end
---@param estate_leader_id estate_leader_id valid estate_leader id
---@param value pop_id valid pop_id
function DATA.estate_leader_set_leader(estate_leader_id, value)
    DCON.dcon_estate_leader_set_leader(estate_leader_id - 1, value - 1)
end
---@param estate estate_leader_id valid estate_id
---@return estate_id Data retrieved from estate_leader 
function DATA.estate_leader_get_estate(estate)
    return DCON.dcon_estate_leader_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return estate_leader_id estate_leader 
function DATA.get_estate_leader_from_estate(estate)
    return DCON.dcon_estate_get_estate_leader_as_estate(estate - 1) + 1
end
---@param estate_leader_id estate_leader_id valid estate_leader id
---@param value estate_id valid estate_id
function DATA.estate_leader_set_estate(estate_leader_id, value)
    DCON.dcon_estate_leader_set_estate(estate_leader_id - 1, value - 1)
end

local fat_estate_leader_id_metatable = {
    __index = function (t,k)
        if (k == "leader") then return DATA.estate_leader_get_leader(t.id) end
        if (k == "estate") then return DATA.estate_leader_get_estate(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "leader") then
            DATA.estate_leader_set_leader(t.id, v)
            return
        end
        if (k == "estate") then
            DATA.estate_leader_set_estate(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_leader_id
---@return fat_estate_leader_id fat_id
function DATA.fatten_estate_leader(id)
    local result = {id = id}
    setmetatable(result, fat_estate_leader_id_metatable)
    return result --[[@as fat_estate_leader_id]]
end
