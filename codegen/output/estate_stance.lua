local ffi = require("ffi")
----------estate_stance----------


---estate_stance: LSP types---

---Unique identificator for estate_stance entity
---@class (exact) estate_stance_id : table
---@field is_estate_stance number
---@class (exact) fat_estate_stance_id
---@field id estate_stance_id Unique estate_stance id
---@field name string 

---@class struct_estate_stance

---@class (exact) estate_stance_id_data_blob_definition
---@field name string 
---Sets values of estate_stance for given id
---@param id estate_stance_id
---@param data estate_stance_id_data_blob_definition
function DATA.setup_estate_stance(id, data)
    DATA.estate_stance_set_name(id, data.name)
end

ffi.cdef[[
int32_t dcon_create_estate_stance();
bool dcon_estate_stance_is_valid(int32_t);
void dcon_estate_stance_resize(uint32_t sz);
uint32_t dcon_estate_stance_size();
]]

---estate_stance: FFI arrays---
---@type (string)[]
DATA.estate_stance_name= {}

---estate_stance: LUA bindings---

DATA.estate_stance_size = 4
---@return estate_stance_id
function DATA.create_estate_stance()
    ---@type estate_stance_id
    local i  = DCON.dcon_create_estate_stance() + 1
    return i --[[@as estate_stance_id]] 
end
---@param func fun(item: estate_stance_id) 
function DATA.for_each_estate_stance(func)
    ---@type number
    local range = DCON.dcon_estate_stance_size()
    for i = 0, range - 1 do
        func(i + 1 --[[@as estate_stance_id]])
    end
end
---@param func fun(item: estate_stance_id):boolean 
---@return table<estate_stance_id, estate_stance_id> 
function DATA.filter_estate_stance(func)
    ---@type table<estate_stance_id, estate_stance_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_stance_size()
    for i = 0, range - 1 do
        if func(i + 1 --[[@as estate_stance_id]]) then t[i + 1 --[[@as estate_stance_id]]] = t[i + 1 --[[@as estate_stance_id]]] end
    end
    return t
end

---@param estate_stance_id estate_stance_id valid estate_stance id
---@return string name 
function DATA.estate_stance_get_name(estate_stance_id)
    return DATA.estate_stance_name[estate_stance_id]
end
---@param estate_stance_id estate_stance_id valid estate_stance id
---@param value string valid string
function DATA.estate_stance_set_name(estate_stance_id, value)
    DATA.estate_stance_name[estate_stance_id] = value
end

local fat_estate_stance_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.estate_stance_get_name(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.estate_stance_set_name(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_stance_id
---@return fat_estate_stance_id fat_id
function DATA.fatten_estate_stance(id)
    local result = {id = id}
    setmetatable(result, fat_estate_stance_id_metatable)
    return result --[[@as fat_estate_stance_id]]
end
---@enum ESTATE_STANCE
ESTATE_STANCE = {
    INVALID = 0,
    WORK = 1,
    FORAGE = 2,
}
local index_estate_stance
index_estate_stance = DATA.create_estate_stance()
DATA.estate_stance_set_name(index_estate_stance, "work")
index_estate_stance = DATA.create_estate_stance()
DATA.estate_stance_set_name(index_estate_stance, "forage")
