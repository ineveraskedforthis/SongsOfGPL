local ffi = require("ffi")
----------faith----------


---faith: LSP types---

---Unique identificator for faith entity
---@class (exact) faith_id : table
---@field is_faith number
---@class (exact) fat_faith_id
---@field id faith_id Unique faith id
---@field name string 
---@field r number 
---@field g number 
---@field b number 
---@field burial_rites BURIAL_RITES 

---@class struct_faith
---@field r number 
---@field g number 
---@field b number 


ffi.cdef[[
void dcon_faith_set_r(int32_t, float);
float dcon_faith_get_r(int32_t);
void dcon_faith_set_g(int32_t, float);
float dcon_faith_get_g(int32_t);
void dcon_faith_set_b(int32_t, float);
float dcon_faith_get_b(int32_t);
void dcon_delete_faith(int32_t j);
int32_t dcon_create_faith();
bool dcon_faith_is_valid(int32_t);
void dcon_faith_resize(uint32_t sz);
uint32_t dcon_faith_size();
]]

---faith: FFI arrays---
---@type (string)[]
DATA.faith_name= {}
---@type (BURIAL_RITES)[]
DATA.faith_burial_rites= {}

---@type (religion_id)[]  -- Línea añadida
DATA.faith_religion = {}  -- Almacena el religion_id de cada faith
---@type (rite_id)[]
DATA.faith_rite = {}
---faith: FFI arrays---
---@type (string)[]
DATA.faith_name = {}
---@type (BURIAL_RITES)[]
DATA.faith_burial_rites = {}
---@type (BIRTH_RITES)[]  -- Nuevo
DATA.faith_birth_rites = {}
---@type (PASSAGE_RITES)[]  -- Nuevo
DATA.faith_passage_rites = {}
---@type (DISEASE_RITES)[]  -- Nuevo
DATA.faith_disease_rites = {}
---@type (spirits)[]
DATA.faith_spirit = {}


---faith: LUA bindings---

DATA.faith_size = 10000
---@return faith_id
function DATA.create_faith()
    ---@type faith_id
    local i  = DCON.dcon_create_faith() + 1
    return i --[[@as faith_id]] 
end
---@param i faith_id
function DATA.delete_faith(i)
    assert(DCON.dcon_faith_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_faith(i - 1)
end
---@param func fun(item: faith_id) 
function DATA.for_each_faith(func)
    ---@type number
    local range = DCON.dcon_faith_size()
    for i = 0, range - 1 do
        if DCON.dcon_faith_is_valid(i) then func(i + 1 --[[@as faith_id]]) end
    end
end
---@param func fun(item: faith_id):boolean 
---@return table<faith_id, faith_id> 
function DATA.filter_faith(func)
    ---@type table<faith_id, faith_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_faith_size()
    for i = 0, range - 1 do
        if DCON.dcon_faith_is_valid(i) and func(i + 1 --[[@as faith_id]]) then t[i + 1 --[[@as faith_id]]] = i + 1 --[[@as faith_id]] end
    end
    return t
end

---@param faith_id faith_id valid faith id
---@return string name 
function DATA.faith_get_name(faith_id)
    return DATA.faith_name[faith_id]
end
---@param faith_id faith_id valid faith id
---@param value string valid string
function DATA.faith_set_name(faith_id, value)
    DATA.faith_name[faith_id] = value
end
---@param faith_id faith_id valid faith id
---@return number r 
function DATA.faith_get_r(faith_id)
    return DCON.dcon_faith_get_r(faith_id - 1)
end
---@param faith_id faith_id valid faith id
---@param value number valid number
function DATA.faith_set_r(faith_id, value)
    DCON.dcon_faith_set_r(faith_id - 1, value)
end
---@param faith_id faith_id valid faith id
---@param value number valid number
function DATA.faith_inc_r(faith_id, value)
    ---@type number
    local current = DCON.dcon_faith_get_r(faith_id - 1)
    DCON.dcon_faith_set_r(faith_id - 1, current + value)
end
---@param faith_id faith_id valid faith id
---@return number g 
function DATA.faith_get_g(faith_id)
    return DCON.dcon_faith_get_g(faith_id - 1)
end
---@param faith_id faith_id valid faith id
---@param value number valid number
function DATA.faith_set_g(faith_id, value)
    DCON.dcon_faith_set_g(faith_id - 1, value)
end
---@param faith_id faith_id valid faith id
---@param value number valid number
function DATA.faith_inc_g(faith_id, value)
    ---@type number
    local current = DCON.dcon_faith_get_g(faith_id - 1)
    DCON.dcon_faith_set_g(faith_id - 1, current + value)
end
---@param faith_id faith_id valid faith id
---@return number b 
function DATA.faith_get_b(faith_id)
    return DCON.dcon_faith_get_b(faith_id - 1)
end
---@param faith_id faith_id valid faith id
---@param value number valid number
function DATA.faith_set_b(faith_id, value)
    DCON.dcon_faith_set_b(faith_id - 1, value)
end
---@param faith_id faith_id valid faith id
---@param value number valid number
function DATA.faith_inc_b(faith_id, value)
    ---@type number
    local current = DCON.dcon_faith_get_b(faith_id - 1)
    DCON.dcon_faith_set_b(faith_id - 1, current + value)
end
---@param faith_id faith_id valid faith id
---@return BURIAL_RITES burial_rites 
function DATA.faith_get_burial_rites(faith_id)
    return DATA.faith_burial_rites[faith_id]
end
---@param faith_id faith_id valid faith id
---@param value BURIAL_RITES valid BURIAL_RITES
function DATA.faith_set_burial_rites(faith_id, value)
    DATA.faith_burial_rites[faith_id] = value
end

---@param faith_id faith_id valid faith id
---@return religion_id religion 
function DATA.faith_get_religion(faith_id)
    return DATA.faith_religion[faith_id]
end

---@param faith_id faith_id valid faith id
---@param value religion_id valid religion_id
function DATA.faith_set_religion(faith_id, value)
    DATA.faith_religion[faith_id] = value
end

---@param faith_id faith_id valid faith id
---@return rite_id rite
function DATA.faith_get_rite(faith_id)
    return DATA.faith_rite[faith_id]
end

---@param faith_id faith_id valid faith id
---@param value rite_id valid rite_id
function DATA.faith_set_rite(faith_id, value)
    DATA.faith_rite[faith_id] = value
end

-- Funciones para los nuevos ritos
function DATA.faith_get_birth_rites(faith_id)
    return DATA.faith_birth_rites[faith_id]
end

function DATA.faith_set_birth_rites(faith_id, value)
    DATA.faith_birth_rites[faith_id] = value
end

function DATA.faith_get_passage_rites(faith_id)
    return DATA.faith_passage_rites[faith_id]
end

function DATA.faith_set_passage_rites(faith_id, value)
    DATA.faith_passage_rites[faith_id] = value
end

function DATA.faith_get_disease_rites(faith_id)
    return DATA.faith_disease_rites[faith_id]
end

function DATA.faith_set_disease_rites(faith_id, value)
    DATA.faith_disease_rites[faith_id] = value
end

function DATA.faith_set_spirit(faith_id, spirit_id)
    DATA.faith_spirit[faith_id] = spirit_id
end

---@param faith_id faith_id
---@return spirit_id
function DATA.faith_get_spirit(faith_id)
    return DATA.faith_spirit[faith_id]
end

local fat_faith_id_metatable = {
    __index = function(t, k)
        -- Campos existentes
        if (k == "name") then return DATA.faith_get_name(t.id) end
        if (k == "r") then return DATA.faith_get_r(t.id) end
        if (k == "g") then return DATA.faith_get_g(t.id) end
        if (k == "b") then return DATA.faith_get_b(t.id) end
        if (k == "burial_rites") then return DATA.faith_get_burial_rites(t.id) end
        if (k == "religion") then return DATA.faith_get_religion(t.id) end
        if (k == "rite") then return DATA.faith_get_rite(t.id) end
        if (k == "birth_rites") then return DATA.faith_get_birth_rites(t.id) end
        if (k == "passage_rites") then return DATA.faith_get_passage_rites(t.id) end
        if (k == "disease_rites") then return DATA.faith_get_disease_rites(t.id) end
        if (k == "spirit") then return DATA.faith_get_spirit(t.id) end
        
        return rawget(t, k)
    end,
    __newindex = function(t, k, v)
        -- Campos existentes
        if (k == "name") then
            DATA.faith_set_name(t.id, v)
            return
        end
        if (k == "r") then
            DATA.faith_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.faith_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.faith_set_b(t.id, v)
            return
        end
        if (k == "burial_rites") then
            DATA.faith_set_burial_rites(t.id, v)
            return
        end
        if (k == "religion") then
            DATA.faith_set_religion(t.id, v)
            return
        end
        if (k == "rite") then
            DATA.faith_set_rite(t.id, v)
            return
        end
        if (k == "birth_rites") then
            DATA.faith_set_birth_rites(t.id, v)
            return
        end
        if (k == "passage_rites") then
            DATA.faith_set_passage_rites(t.id, v)
            return
        end
        if (k == "disease_rites") then
            DATA.faith_set_disease_rites(t.id, v)
            return
        end
        
        -- Nuevo setter para el espíritu
        if (k == "spirit") then
            DATA.faith_set_spirit(t.id, v)
            return
        end
        
        rawset(t, k, v)
    end
}
---@param id faith_id
---@return fat_faith_id fat_id
function DATA.fatten_faith(id)
    local result = {id = id}
    setmetatable(result, fat_faith_id_metatable)
    return result --[[@as fat_faith_id]]
end
