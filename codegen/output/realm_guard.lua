local ffi = require("ffi")
----------realm_guard----------


---realm_guard: LSP types---

---Unique identificator for realm_guard entity
---@class (exact) realm_guard_id : table
---@field is_realm_guard number
---@class (exact) fat_realm_guard_id
---@field id realm_guard_id Unique realm_guard id
---@field guard estate_id 
---@field realm realm_id 

---@class struct_realm_guard


ffi.cdef[[
void dcon_delete_realm_guard(int32_t j);
int32_t dcon_force_create_realm_guard(int32_t guard, int32_t realm);
void dcon_realm_guard_set_guard(int32_t, int32_t);
int32_t dcon_realm_guard_get_guard(int32_t);
int32_t dcon_estate_get_realm_guard_as_guard(int32_t);
void dcon_realm_guard_set_realm(int32_t, int32_t);
int32_t dcon_realm_guard_get_realm(int32_t);
int32_t dcon_realm_get_realm_guard_as_realm(int32_t);
bool dcon_realm_guard_is_valid(int32_t);
void dcon_realm_guard_resize(uint32_t sz);
uint32_t dcon_realm_guard_size();
]]

---realm_guard: FFI arrays---

---realm_guard: LUA bindings---

DATA.realm_guard_size = 15000
---@param guard estate_id
---@param realm realm_id
---@return realm_guard_id
function DATA.force_create_realm_guard(guard, realm)
    ---@type realm_guard_id
    local i = DCON.dcon_force_create_realm_guard(guard - 1, realm - 1) + 1
    return i --[[@as realm_guard_id]] 
end
---@param i realm_guard_id
function DATA.delete_realm_guard(i)
    assert(DCON.dcon_realm_guard_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_realm_guard(i - 1)
end
---@param func fun(item: realm_guard_id) 
function DATA.for_each_realm_guard(func)
    ---@type number
    local range = DCON.dcon_realm_guard_size()
    for i = 0, range - 1 do
        if DCON.dcon_realm_guard_is_valid(i) then func(i + 1 --[[@as realm_guard_id]]) end
    end
end
---@param func fun(item: realm_guard_id):boolean 
---@return table<realm_guard_id, realm_guard_id> 
function DATA.filter_realm_guard(func)
    ---@type table<realm_guard_id, realm_guard_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_realm_guard_size()
    for i = 0, range - 1 do
        if DCON.dcon_realm_guard_is_valid(i) and func(i + 1 --[[@as realm_guard_id]]) then t[i + 1 --[[@as realm_guard_id]]] = i + 1 --[[@as realm_guard_id]] end
    end
    return t
end

---@param guard realm_guard_id valid estate_id
---@return estate_id Data retrieved from realm_guard 
function DATA.realm_guard_get_guard(guard)
    return DCON.dcon_realm_guard_get_guard(guard - 1) + 1
end
---@param guard estate_id valid estate_id
---@return realm_guard_id realm_guard 
function DATA.get_realm_guard_from_guard(guard)
    return DCON.dcon_estate_get_realm_guard_as_guard(guard - 1) + 1
end
---@param realm_guard_id realm_guard_id valid realm_guard id
---@param value estate_id valid estate_id
function DATA.realm_guard_set_guard(realm_guard_id, value)
    DCON.dcon_realm_guard_set_guard(realm_guard_id - 1, value - 1)
end
---@param realm realm_guard_id valid realm_id
---@return realm_id Data retrieved from realm_guard 
function DATA.realm_guard_get_realm(realm)
    return DCON.dcon_realm_guard_get_realm(realm - 1) + 1
end
---@param realm realm_id valid realm_id
---@return realm_guard_id realm_guard 
function DATA.get_realm_guard_from_realm(realm)
    return DCON.dcon_realm_get_realm_guard_as_realm(realm - 1) + 1
end
---@param realm_guard_id realm_guard_id valid realm_guard id
---@param value realm_id valid realm_id
function DATA.realm_guard_set_realm(realm_guard_id, value)
    DCON.dcon_realm_guard_set_realm(realm_guard_id - 1, value - 1)
end

local fat_realm_guard_id_metatable = {
    __index = function (t,k)
        if (k == "guard") then return DATA.realm_guard_get_guard(t.id) end
        if (k == "realm") then return DATA.realm_guard_get_realm(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "guard") then
            DATA.realm_guard_set_guard(t.id, v)
            return
        end
        if (k == "realm") then
            DATA.realm_guard_set_realm(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id realm_guard_id
---@return fat_realm_guard_id fat_id
function DATA.fatten_realm_guard(id)
    local result = {id = id}
    setmetatable(result, fat_realm_guard_id_metatable)
    return result --[[@as fat_realm_guard_id]]
end
