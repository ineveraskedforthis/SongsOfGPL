local ffi = require("ffi")
----------estate_status----------


---estate_status: LSP types---

---Unique identificator for estate_status entity
---@class (exact) estate_status_id : table
---@field is_estate_status number
---@class (exact) fat_estate_status_id
---@field id estate_status_id Unique estate_status id
---@field name string 
---@field action_string string 
---@field time_used number 
---@field icon string 

---@class struct_estate_status
---@field time_used number 

---@class (exact) estate_status_id_data_blob_definition
---@field name string 
---@field action_string string 
---@field time_used number 
---@field icon string 
---Sets values of estate_status for given id
---@param id estate_status_id
---@param data estate_status_id_data_blob_definition
function DATA.setup_estate_status(id, data)
    DATA.estate_status_set_name(id, data.name)
    DATA.estate_status_set_action_string(id, data.action_string)
    DATA.estate_status_set_time_used(id, data.time_used)
    DATA.estate_status_set_icon(id, data.icon)
end

ffi.cdef[[
void dcon_estate_status_set_time_used(int32_t, float);
float dcon_estate_status_get_time_used(int32_t);
int32_t dcon_create_estate_status();
bool dcon_estate_status_is_valid(int32_t);
void dcon_estate_status_resize(uint32_t sz);
uint32_t dcon_estate_status_size();
]]

---estate_status: FFI arrays---
---@type (string)[]
DATA.estate_status_name= {}
---@type (string)[]
DATA.estate_status_action_string= {}
---@type (string)[]
DATA.estate_status_icon= {}

---estate_status: LUA bindings---

DATA.estate_status_size = 11
---@return estate_status_id
function DATA.create_estate_status()
    ---@type estate_status_id
    local i  = DCON.dcon_create_estate_status() + 1
    return i --[[@as estate_status_id]] 
end
---@param func fun(item: estate_status_id) 
function DATA.for_each_estate_status(func)
    ---@type number
    local range = DCON.dcon_estate_status_size()
    for i = 0, range - 1 do
        func(i + 1 --[[@as estate_status_id]])
    end
end
---@param func fun(item: estate_status_id):boolean 
---@return table<estate_status_id, estate_status_id> 
function DATA.filter_estate_status(func)
    ---@type table<estate_status_id, estate_status_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_status_size()
    for i = 0, range - 1 do
        if func(i + 1 --[[@as estate_status_id]]) then t[i + 1 --[[@as estate_status_id]]] = t[i + 1 --[[@as estate_status_id]]] end
    end
    return t
end

---@param estate_status_id estate_status_id valid estate_status id
---@return string name 
function DATA.estate_status_get_name(estate_status_id)
    return DATA.estate_status_name[estate_status_id]
end
---@param estate_status_id estate_status_id valid estate_status id
---@param value string valid string
function DATA.estate_status_set_name(estate_status_id, value)
    DATA.estate_status_name[estate_status_id] = value
end
---@param estate_status_id estate_status_id valid estate_status id
---@return string action_string 
function DATA.estate_status_get_action_string(estate_status_id)
    return DATA.estate_status_action_string[estate_status_id]
end
---@param estate_status_id estate_status_id valid estate_status id
---@param value string valid string
function DATA.estate_status_set_action_string(estate_status_id, value)
    DATA.estate_status_action_string[estate_status_id] = value
end
---@param estate_status_id estate_status_id valid estate_status id
---@return number time_used 
function DATA.estate_status_get_time_used(estate_status_id)
    return DCON.dcon_estate_status_get_time_used(estate_status_id - 1)
end
---@param estate_status_id estate_status_id valid estate_status id
---@param value number valid number
function DATA.estate_status_set_time_used(estate_status_id, value)
    DCON.dcon_estate_status_set_time_used(estate_status_id - 1, value)
end
---@param estate_status_id estate_status_id valid estate_status id
---@param value number valid number
function DATA.estate_status_inc_time_used(estate_status_id, value)
    ---@type number
    local current = DCON.dcon_estate_status_get_time_used(estate_status_id - 1)
    DCON.dcon_estate_status_set_time_used(estate_status_id - 1, current + value)
end
---@param estate_status_id estate_status_id valid estate_status id
---@return string icon 
function DATA.estate_status_get_icon(estate_status_id)
    return DATA.estate_status_icon[estate_status_id]
end
---@param estate_status_id estate_status_id valid estate_status id
---@param value string valid string
function DATA.estate_status_set_icon(estate_status_id, value)
    DATA.estate_status_icon[estate_status_id] = value
end

local fat_estate_status_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.estate_status_get_name(t.id) end
        if (k == "action_string") then return DATA.estate_status_get_action_string(t.id) end
        if (k == "time_used") then return DATA.estate_status_get_time_used(t.id) end
        if (k == "icon") then return DATA.estate_status_get_icon(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.estate_status_set_name(t.id, v)
            return
        end
        if (k == "action_string") then
            DATA.estate_status_set_action_string(t.id, v)
            return
        end
        if (k == "time_used") then
            DATA.estate_status_set_time_used(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.estate_status_set_icon(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_status_id
---@return fat_estate_status_id fat_id
function DATA.fatten_estate_status(id)
    local result = {id = id}
    setmetatable(result, fat_estate_status_id_metatable)
    return result --[[@as fat_estate_status_id]]
end
---@enum ESTATE_STATUS
ESTATE_STATUS = {
    INVALID = 0,
    IDLE = 1,
    RAIDING = 2,
    PREPARING_RAID = 3,
    PREPARING_PATROL = 4,
    PATROL = 5,
    ATTACKING = 6,
    TRAVELING = 7,
    OFF_DUTY = 8,
    FORAGE = 9,
}
local index_estate_status
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "idle")
DATA.estate_status_set_action_string(index_estate_status, "idle")
DATA.estate_status_set_time_used(index_estate_status, 0.0)
DATA.estate_status_set_icon(index_estate_status, "guards.png")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "raiding")
DATA.estate_status_set_action_string(index_estate_status, "raiding")
DATA.estate_status_set_time_used(index_estate_status, 0.5)
DATA.estate_status_set_icon(index_estate_status, "stone-spear.png")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "preparing_raid")
DATA.estate_status_set_action_string(index_estate_status, "preparing a raid")
DATA.estate_status_set_time_used(index_estate_status, 0.25)
DATA.estate_status_set_icon(index_estate_status, "minions.png")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "preparing_patrol")
DATA.estate_status_set_action_string(index_estate_status, "preparing to patrol")
DATA.estate_status_set_time_used(index_estate_status, 0.25)
DATA.estate_status_set_icon(index_estate_status, "ages.png")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "patrol")
DATA.estate_status_set_action_string(index_estate_status, "patrolling")
DATA.estate_status_set_time_used(index_estate_status, 0.5)
DATA.estate_status_set_icon(index_estate_status, "round-shield.png")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "attacking")
DATA.estate_status_set_action_string(index_estate_status, "attacking")
DATA.estate_status_set_time_used(index_estate_status, 0.5)
DATA.estate_status_set_icon(index_estate_status, "hammer-drop.pngs")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "traveling")
DATA.estate_status_set_action_string(index_estate_status, "traveling")
DATA.estate_status_set_time_used(index_estate_status, 0.5)
DATA.estate_status_set_icon(index_estate_status, "horizon-road.png")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "off_duty")
DATA.estate_status_set_action_string(index_estate_status, "off duty")
DATA.estate_status_set_time_used(index_estate_status, 0.0)
DATA.estate_status_set_icon(index_estate_status, "shrug.png")
index_estate_status = DATA.create_estate_status()
DATA.estate_status_set_name(index_estate_status, "forage")
DATA.estate_status_set_action_string(index_estate_status, "foraging")
DATA.estate_status_set_time_used(index_estate_status, 0.25)
DATA.estate_status_set_icon(index_estate_status, "basket.png")
