local ffi = require("ffi")
---@class struct_forage_container
---@field resource forage_resource_id 
---@field limit number 
---@field amount number 
---@field efficiency number 
ffi.cdef[[
    typedef struct {
        int32_t resource;
        float limit;
        float amount;
        float efficiency;
    } forage_container;
]]
