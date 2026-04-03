local ffi = require("ffi")
----------estate_recruiter----------


---estate_recruiter: LSP types---

---Unique identificator for estate_recruiter entity
---@class (exact) estate_recruiter_id : table
---@field is_estate_recruiter number
---@class (exact) fat_estate_recruiter_id
---@field id estate_recruiter_id Unique estate_recruiter id
---@field recruiter pop_id 
---@field estate estate_id 

---@class struct_estate_recruiter


ffi.cdef[[
void dcon_delete_estate_recruiter(int32_t j);
int32_t dcon_force_create_estate_recruiter(int32_t recruiter, int32_t estate);
void dcon_estate_recruiter_set_recruiter(int32_t, int32_t);
int32_t dcon_estate_recruiter_get_recruiter(int32_t);
int32_t dcon_pop_get_estate_recruiter_as_recruiter(int32_t);
void dcon_estate_recruiter_set_estate(int32_t, int32_t);
int32_t dcon_estate_recruiter_get_estate(int32_t);
int32_t dcon_estate_get_estate_recruiter_as_estate(int32_t);
bool dcon_estate_recruiter_is_valid(int32_t);
void dcon_estate_recruiter_resize(uint32_t sz);
uint32_t dcon_estate_recruiter_size();
]]

---estate_recruiter: FFI arrays---

---estate_recruiter: LUA bindings---

DATA.estate_recruiter_size = 50000
---@param recruiter pop_id
---@param estate estate_id
---@return estate_recruiter_id
function DATA.force_create_estate_recruiter(recruiter, estate)
    ---@type estate_recruiter_id
    local i = DCON.dcon_force_create_estate_recruiter(recruiter - 1, estate - 1) + 1
    return i --[[@as estate_recruiter_id]] 
end
---@param i estate_recruiter_id
function DATA.delete_estate_recruiter(i)
    assert(DCON.dcon_estate_recruiter_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_estate_recruiter(i - 1)
end
---@param func fun(item: estate_recruiter_id) 
function DATA.for_each_estate_recruiter(func)
    ---@type number
    local range = DCON.dcon_estate_recruiter_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_recruiter_is_valid(i) then func(i + 1 --[[@as estate_recruiter_id]]) end
    end
end
---@param func fun(item: estate_recruiter_id):boolean 
---@return table<estate_recruiter_id, estate_recruiter_id> 
function DATA.filter_estate_recruiter(func)
    ---@type table<estate_recruiter_id, estate_recruiter_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_recruiter_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_recruiter_is_valid(i) and func(i + 1 --[[@as estate_recruiter_id]]) then t[i + 1 --[[@as estate_recruiter_id]]] = i + 1 --[[@as estate_recruiter_id]] end
    end
    return t
end

---@param recruiter estate_recruiter_id valid pop_id
---@return pop_id Data retrieved from estate_recruiter 
function DATA.estate_recruiter_get_recruiter(recruiter)
    return DCON.dcon_estate_recruiter_get_recruiter(recruiter - 1) + 1
end
---@param recruiter pop_id valid pop_id
---@return estate_recruiter_id estate_recruiter 
function DATA.get_estate_recruiter_from_recruiter(recruiter)
    return DCON.dcon_pop_get_estate_recruiter_as_recruiter(recruiter - 1) + 1
end
---@param estate_recruiter_id estate_recruiter_id valid estate_recruiter id
---@param value pop_id valid pop_id
function DATA.estate_recruiter_set_recruiter(estate_recruiter_id, value)
    DCON.dcon_estate_recruiter_set_recruiter(estate_recruiter_id - 1, value - 1)
end
---@param estate estate_recruiter_id valid estate_id
---@return estate_id Data retrieved from estate_recruiter 
function DATA.estate_recruiter_get_estate(estate)
    return DCON.dcon_estate_recruiter_get_estate(estate - 1) + 1
end
---@param estate estate_id valid estate_id
---@return estate_recruiter_id estate_recruiter 
function DATA.get_estate_recruiter_from_estate(estate)
    return DCON.dcon_estate_get_estate_recruiter_as_estate(estate - 1) + 1
end
---@param estate_recruiter_id estate_recruiter_id valid estate_recruiter id
---@param value estate_id valid estate_id
function DATA.estate_recruiter_set_estate(estate_recruiter_id, value)
    DCON.dcon_estate_recruiter_set_estate(estate_recruiter_id - 1, value - 1)
end

local fat_estate_recruiter_id_metatable = {
    __index = function (t,k)
        if (k == "recruiter") then return DATA.estate_recruiter_get_recruiter(t.id) end
        if (k == "estate") then return DATA.estate_recruiter_get_estate(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "recruiter") then
            DATA.estate_recruiter_set_recruiter(t.id, v)
            return
        end
        if (k == "estate") then
            DATA.estate_recruiter_set_estate(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_recruiter_id
---@return fat_estate_recruiter_id fat_id
function DATA.fatten_estate_recruiter(id)
    local result = {id = id}
    setmetatable(result, fat_estate_recruiter_id_metatable)
    return result --[[@as fat_estate_recruiter_id]]
end
