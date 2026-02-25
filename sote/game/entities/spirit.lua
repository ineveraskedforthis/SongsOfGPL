local spirit = {
    data = {},
    last_id = 0
}

---@class spirit_id
---@field id number

---@return spirit_id
function spirit.create_spirit()
    local new_id = spirit.last_id + 1
    spirit.last_id = new_id
    
    spirit.data[new_id] = {
        id = new_id,
        name = "",
        domain = "",
        rank = 0,
        culture = nil
    }
    
    return { id = new_id }
end

---@param spirit_id spirit_id
function spirit.delete_spirit(spirit_id)
    spirit.data[spirit_id.id] = nil
end

---@param spirit_id spirit_id
---@return string
function spirit.get_name(spirit_id)
    if spirit_id == nil or spirit_id.id == nil or spirit.data[spirit_id.id] == nil then
        return "Ninguno"
    end
    return spirit.data[spirit_id.id].name
end

---@param spirit_id spirit_id
---@param name string
function spirit.set_name(spirit_id, name)
    spirit.data[spirit_id.id].name = name
end

---@param spirit_id spirit_id
---@return string
function spirit.get_domain(spirit_id)
    if spirit_id == nil or spirit_id.id == nil or spirit.data[spirit_id.id] == nil then
        return "Desconocido"
    end
    return spirit.data[spirit_id.id].domain
end

---@param spirit_id spirit_id
---@param domain string
function spirit.set_domain(spirit_id, domain)
    spirit.data[spirit_id.id].domain = domain
end

---@param spirit_id spirit_id
---@return number|string
function spirit.get_rank(spirit_id)
    if spirit_id == nil or spirit_id.id == nil or spirit.data[spirit_id.id] == nil then
        return "N/A"
    end
    return spirit.data[spirit_id.id].rank
end

---@param spirit_id spirit_id
---@param rank number
function spirit.set_rank(spirit_id, rank)
    spirit.data[spirit_id.id].rank = rank
end

return spirit