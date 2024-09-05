local ffi = require("ffi")
ffi.cdef[[
    void* calloc( size_t num, size_t size );
]]
local bitser = require("engine.bitser")

DATA = {}
---@class struct_budget_per_category_data
---@field ratio number 
---@field budget number 
---@field to_be_invested number 
---@field target number 
ffi.cdef[[
    typedef struct {
        float ratio;
        float budget;
        float to_be_invested;
        float target;
    } budget_per_category_data;
]]
---@class struct_trade_good_container
---@field good trade_good_id 
---@field amount number 
ffi.cdef[[
    typedef struct {
        uint32_t good;
        float amount;
    } trade_good_container;
]]
---@class struct_use_case_container
---@field use use_case_id 
---@field amount number 
ffi.cdef[[
    typedef struct {
        uint32_t use;
        float amount;
    } use_case_container;
]]
---@class struct_forage_container
---@field output_good trade_good_id 
---@field output_value number 
---@field amount number 
---@field forage FORAGE_RESOURCE 
ffi.cdef[[
    typedef struct {
        uint32_t output_good;
        float output_value;
        float amount;
        uint8_t forage;
    } forage_container;
]]
---@class struct_resource_location
---@field resource resource_id 
---@field location tile_id 
ffi.cdef[[
    typedef struct {
        uint32_t resource;
        uint32_t location;
    } resource_location;
]]
---@class struct_need_satisfaction
---@field need NEED 
---@field use_case use_case_id 
---@field consumed number 
---@field demanded number 
ffi.cdef[[
    typedef struct {
        uint8_t need;
        uint32_t use_case;
        float consumed;
        float demanded;
    } need_satisfaction;
]]
---@class struct_need_definition
---@field need NEED 
---@field use_case use_case_id 
---@field required number 
ffi.cdef[[
    typedef struct {
        uint8_t need;
        uint32_t use_case;
        float required;
    } need_definition;
]]
---@class struct_job_container
---@field job job_id 
---@field amount number 
ffi.cdef[[
    typedef struct {
        uint32_t job;
        uint32_t amount;
    } job_container;
]]
----------tile----------


---tile: LSP types---

---Unique identificator for tile entity
---@alias tile_id number

---@class (exact) fat_tile_id
---@field id tile_id Unique tile id
---@field world_id number 
---@field is_land boolean 
---@field is_fresh boolean 
---@field elevation number 
---@field grass number 
---@field shrub number 
---@field conifer number 
---@field broadleaf number 
---@field ideal_grass number 
---@field ideal_shrub number 
---@field ideal_conifer number 
---@field ideal_broadleaf number 
---@field silt number 
---@field clay number 
---@field sand number 
---@field soil_minerals number 
---@field soil_organics number 
---@field january_waterflow number 
---@field july_waterflow number 
---@field waterlevel number 
---@field has_river boolean 
---@field has_marsh boolean 
---@field ice number 
---@field ice_age_ice number 
---@field debug_r number between 0 and 1, as per Love2Ds convention...
---@field debug_g number between 0 and 1, as per Love2Ds convention...
---@field debug_b number between 0 and 1, as per Love2Ds convention...
---@field real_r number between 0 and 1, as per Love2Ds convention...
---@field real_g number between 0 and 1, as per Love2Ds convention...
---@field real_b number between 0 and 1, as per Love2Ds convention...
---@field pathfinding_index number 
---@field resource resource_id 
---@field bedrock bedrock_id 
---@field biome biome_id 

---@class struct_tile
---@field world_id number 
---@field is_land boolean 
---@field is_fresh boolean 
---@field elevation number 
---@field grass number 
---@field shrub number 
---@field conifer number 
---@field broadleaf number 
---@field ideal_grass number 
---@field ideal_shrub number 
---@field ideal_conifer number 
---@field ideal_broadleaf number 
---@field silt number 
---@field clay number 
---@field sand number 
---@field soil_minerals number 
---@field soil_organics number 
---@field january_waterflow number 
---@field july_waterflow number 
---@field waterlevel number 
---@field has_river boolean 
---@field has_marsh boolean 
---@field ice number 
---@field ice_age_ice number 
---@field debug_r number between 0 and 1, as per Love2Ds convention...
---@field debug_g number between 0 and 1, as per Love2Ds convention...
---@field debug_b number between 0 and 1, as per Love2Ds convention...
---@field real_r number between 0 and 1, as per Love2Ds convention...
---@field real_g number between 0 and 1, as per Love2Ds convention...
---@field real_b number between 0 and 1, as per Love2Ds convention...
---@field pathfinding_index number 
---@field resource resource_id 
---@field bedrock bedrock_id 
---@field biome biome_id 


ffi.cdef[[
    typedef struct {
        uint32_t world_id;
        bool is_land;
        bool is_fresh;
        float elevation;
        float grass;
        float shrub;
        float conifer;
        float broadleaf;
        float ideal_grass;
        float ideal_shrub;
        float ideal_conifer;
        float ideal_broadleaf;
        float silt;
        float clay;
        float sand;
        float soil_minerals;
        float soil_organics;
        float january_waterflow;
        float july_waterflow;
        float waterlevel;
        bool has_river;
        bool has_marsh;
        float ice;
        float ice_age_ice;
        float debug_r;
        float debug_g;
        float debug_b;
        float real_r;
        float real_g;
        float real_b;
        uint32_t pathfinding_index;
        uint32_t resource;
        uint32_t bedrock;
        uint32_t biome;
    } tile;
int32_t dcon_create_tile();
void dcon_tile_resize(uint32_t sz);
]]

---tile: FFI arrays---
---@type nil
DATA.tile_calloc = ffi.C.calloc(1, ffi.sizeof("tile") * 1500001)
---@type table<tile_id, struct_tile>
DATA.tile = ffi.cast("tile*", DATA.tile_calloc)

---tile: LUA bindings---

DATA.tile_size = 1500000
---@type table<tile_id, boolean>
local tile_indices_pool = ffi.new("bool[?]", 1500000)
for i = 1, 1499999 do
    tile_indices_pool[i] = true 
end
---@type table<tile_id, tile_id>
DATA.tile_indices_set = {}
function DATA.create_tile()
    ---@type number
    local i = DCON.dcon_create_tile() + 1
            DATA.tile_indices_set[i] = i
    return i
end
---@param func fun(item: tile_id) 
function DATA.for_each_tile(func)
    for _, item in pairs(DATA.tile_indices_set) do
        func(item)
    end
end
---@param func fun(item: tile_id):boolean 
---@return table<tile_id, tile_id> 
function DATA.filter_tile(func)
    ---@type table<tile_id, tile_id> 
    local t = {}
    for _, item in pairs(DATA.tile_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param tile_id tile_id valid tile id
---@return number world_id 
function DATA.tile_get_world_id(tile_id)
    return DATA.tile[tile_id].world_id
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_world_id(tile_id, value)
    DATA.tile[tile_id].world_id = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_world_id(tile_id, value)
    DATA.tile[tile_id].world_id = DATA.tile[tile_id].world_id + value
end
---@param tile_id tile_id valid tile id
---@return boolean is_land 
function DATA.tile_get_is_land(tile_id)
    return DATA.tile[tile_id].is_land
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_is_land(tile_id, value)
    DATA.tile[tile_id].is_land = value
end
---@param tile_id tile_id valid tile id
---@return boolean is_fresh 
function DATA.tile_get_is_fresh(tile_id)
    return DATA.tile[tile_id].is_fresh
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_is_fresh(tile_id, value)
    DATA.tile[tile_id].is_fresh = value
end
---@param tile_id tile_id valid tile id
---@return number elevation 
function DATA.tile_get_elevation(tile_id)
    return DATA.tile[tile_id].elevation
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_elevation(tile_id, value)
    DATA.tile[tile_id].elevation = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_elevation(tile_id, value)
    DATA.tile[tile_id].elevation = DATA.tile[tile_id].elevation + value
end
---@param tile_id tile_id valid tile id
---@return number grass 
function DATA.tile_get_grass(tile_id)
    return DATA.tile[tile_id].grass
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_grass(tile_id, value)
    DATA.tile[tile_id].grass = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_grass(tile_id, value)
    DATA.tile[tile_id].grass = DATA.tile[tile_id].grass + value
end
---@param tile_id tile_id valid tile id
---@return number shrub 
function DATA.tile_get_shrub(tile_id)
    return DATA.tile[tile_id].shrub
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_shrub(tile_id, value)
    DATA.tile[tile_id].shrub = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_shrub(tile_id, value)
    DATA.tile[tile_id].shrub = DATA.tile[tile_id].shrub + value
end
---@param tile_id tile_id valid tile id
---@return number conifer 
function DATA.tile_get_conifer(tile_id)
    return DATA.tile[tile_id].conifer
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_conifer(tile_id, value)
    DATA.tile[tile_id].conifer = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_conifer(tile_id, value)
    DATA.tile[tile_id].conifer = DATA.tile[tile_id].conifer + value
end
---@param tile_id tile_id valid tile id
---@return number broadleaf 
function DATA.tile_get_broadleaf(tile_id)
    return DATA.tile[tile_id].broadleaf
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_broadleaf(tile_id, value)
    DATA.tile[tile_id].broadleaf = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_broadleaf(tile_id, value)
    DATA.tile[tile_id].broadleaf = DATA.tile[tile_id].broadleaf + value
end
---@param tile_id tile_id valid tile id
---@return number ideal_grass 
function DATA.tile_get_ideal_grass(tile_id)
    return DATA.tile[tile_id].ideal_grass
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_grass(tile_id, value)
    DATA.tile[tile_id].ideal_grass = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_grass(tile_id, value)
    DATA.tile[tile_id].ideal_grass = DATA.tile[tile_id].ideal_grass + value
end
---@param tile_id tile_id valid tile id
---@return number ideal_shrub 
function DATA.tile_get_ideal_shrub(tile_id)
    return DATA.tile[tile_id].ideal_shrub
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_shrub(tile_id, value)
    DATA.tile[tile_id].ideal_shrub = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_shrub(tile_id, value)
    DATA.tile[tile_id].ideal_shrub = DATA.tile[tile_id].ideal_shrub + value
end
---@param tile_id tile_id valid tile id
---@return number ideal_conifer 
function DATA.tile_get_ideal_conifer(tile_id)
    return DATA.tile[tile_id].ideal_conifer
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_conifer(tile_id, value)
    DATA.tile[tile_id].ideal_conifer = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_conifer(tile_id, value)
    DATA.tile[tile_id].ideal_conifer = DATA.tile[tile_id].ideal_conifer + value
end
---@param tile_id tile_id valid tile id
---@return number ideal_broadleaf 
function DATA.tile_get_ideal_broadleaf(tile_id)
    return DATA.tile[tile_id].ideal_broadleaf
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_broadleaf(tile_id, value)
    DATA.tile[tile_id].ideal_broadleaf = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_broadleaf(tile_id, value)
    DATA.tile[tile_id].ideal_broadleaf = DATA.tile[tile_id].ideal_broadleaf + value
end
---@param tile_id tile_id valid tile id
---@return number silt 
function DATA.tile_get_silt(tile_id)
    return DATA.tile[tile_id].silt
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_silt(tile_id, value)
    DATA.tile[tile_id].silt = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_silt(tile_id, value)
    DATA.tile[tile_id].silt = DATA.tile[tile_id].silt + value
end
---@param tile_id tile_id valid tile id
---@return number clay 
function DATA.tile_get_clay(tile_id)
    return DATA.tile[tile_id].clay
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_clay(tile_id, value)
    DATA.tile[tile_id].clay = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_clay(tile_id, value)
    DATA.tile[tile_id].clay = DATA.tile[tile_id].clay + value
end
---@param tile_id tile_id valid tile id
---@return number sand 
function DATA.tile_get_sand(tile_id)
    return DATA.tile[tile_id].sand
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_sand(tile_id, value)
    DATA.tile[tile_id].sand = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_sand(tile_id, value)
    DATA.tile[tile_id].sand = DATA.tile[tile_id].sand + value
end
---@param tile_id tile_id valid tile id
---@return number soil_minerals 
function DATA.tile_get_soil_minerals(tile_id)
    return DATA.tile[tile_id].soil_minerals
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_soil_minerals(tile_id, value)
    DATA.tile[tile_id].soil_minerals = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_soil_minerals(tile_id, value)
    DATA.tile[tile_id].soil_minerals = DATA.tile[tile_id].soil_minerals + value
end
---@param tile_id tile_id valid tile id
---@return number soil_organics 
function DATA.tile_get_soil_organics(tile_id)
    return DATA.tile[tile_id].soil_organics
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_soil_organics(tile_id, value)
    DATA.tile[tile_id].soil_organics = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_soil_organics(tile_id, value)
    DATA.tile[tile_id].soil_organics = DATA.tile[tile_id].soil_organics + value
end
---@param tile_id tile_id valid tile id
---@return number january_waterflow 
function DATA.tile_get_january_waterflow(tile_id)
    return DATA.tile[tile_id].january_waterflow
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_january_waterflow(tile_id, value)
    DATA.tile[tile_id].january_waterflow = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_january_waterflow(tile_id, value)
    DATA.tile[tile_id].january_waterflow = DATA.tile[tile_id].january_waterflow + value
end
---@param tile_id tile_id valid tile id
---@return number july_waterflow 
function DATA.tile_get_july_waterflow(tile_id)
    return DATA.tile[tile_id].july_waterflow
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_july_waterflow(tile_id, value)
    DATA.tile[tile_id].july_waterflow = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_july_waterflow(tile_id, value)
    DATA.tile[tile_id].july_waterflow = DATA.tile[tile_id].july_waterflow + value
end
---@param tile_id tile_id valid tile id
---@return number waterlevel 
function DATA.tile_get_waterlevel(tile_id)
    return DATA.tile[tile_id].waterlevel
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_waterlevel(tile_id, value)
    DATA.tile[tile_id].waterlevel = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_waterlevel(tile_id, value)
    DATA.tile[tile_id].waterlevel = DATA.tile[tile_id].waterlevel + value
end
---@param tile_id tile_id valid tile id
---@return boolean has_river 
function DATA.tile_get_has_river(tile_id)
    return DATA.tile[tile_id].has_river
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_has_river(tile_id, value)
    DATA.tile[tile_id].has_river = value
end
---@param tile_id tile_id valid tile id
---@return boolean has_marsh 
function DATA.tile_get_has_marsh(tile_id)
    return DATA.tile[tile_id].has_marsh
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_has_marsh(tile_id, value)
    DATA.tile[tile_id].has_marsh = value
end
---@param tile_id tile_id valid tile id
---@return number ice 
function DATA.tile_get_ice(tile_id)
    return DATA.tile[tile_id].ice
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ice(tile_id, value)
    DATA.tile[tile_id].ice = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ice(tile_id, value)
    DATA.tile[tile_id].ice = DATA.tile[tile_id].ice + value
end
---@param tile_id tile_id valid tile id
---@return number ice_age_ice 
function DATA.tile_get_ice_age_ice(tile_id)
    return DATA.tile[tile_id].ice_age_ice
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ice_age_ice(tile_id, value)
    DATA.tile[tile_id].ice_age_ice = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ice_age_ice(tile_id, value)
    DATA.tile[tile_id].ice_age_ice = DATA.tile[tile_id].ice_age_ice + value
end
---@param tile_id tile_id valid tile id
---@return number debug_r between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_debug_r(tile_id)
    return DATA.tile[tile_id].debug_r
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_debug_r(tile_id, value)
    DATA.tile[tile_id].debug_r = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_debug_r(tile_id, value)
    DATA.tile[tile_id].debug_r = DATA.tile[tile_id].debug_r + value
end
---@param tile_id tile_id valid tile id
---@return number debug_g between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_debug_g(tile_id)
    return DATA.tile[tile_id].debug_g
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_debug_g(tile_id, value)
    DATA.tile[tile_id].debug_g = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_debug_g(tile_id, value)
    DATA.tile[tile_id].debug_g = DATA.tile[tile_id].debug_g + value
end
---@param tile_id tile_id valid tile id
---@return number debug_b between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_debug_b(tile_id)
    return DATA.tile[tile_id].debug_b
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_debug_b(tile_id, value)
    DATA.tile[tile_id].debug_b = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_debug_b(tile_id, value)
    DATA.tile[tile_id].debug_b = DATA.tile[tile_id].debug_b + value
end
---@param tile_id tile_id valid tile id
---@return number real_r between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_real_r(tile_id)
    return DATA.tile[tile_id].real_r
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_real_r(tile_id, value)
    DATA.tile[tile_id].real_r = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_real_r(tile_id, value)
    DATA.tile[tile_id].real_r = DATA.tile[tile_id].real_r + value
end
---@param tile_id tile_id valid tile id
---@return number real_g between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_real_g(tile_id)
    return DATA.tile[tile_id].real_g
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_real_g(tile_id, value)
    DATA.tile[tile_id].real_g = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_real_g(tile_id, value)
    DATA.tile[tile_id].real_g = DATA.tile[tile_id].real_g + value
end
---@param tile_id tile_id valid tile id
---@return number real_b between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_real_b(tile_id)
    return DATA.tile[tile_id].real_b
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_real_b(tile_id, value)
    DATA.tile[tile_id].real_b = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_real_b(tile_id, value)
    DATA.tile[tile_id].real_b = DATA.tile[tile_id].real_b + value
end
---@param tile_id tile_id valid tile id
---@return number pathfinding_index 
function DATA.tile_get_pathfinding_index(tile_id)
    return DATA.tile[tile_id].pathfinding_index
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_pathfinding_index(tile_id, value)
    DATA.tile[tile_id].pathfinding_index = value
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_pathfinding_index(tile_id, value)
    DATA.tile[tile_id].pathfinding_index = DATA.tile[tile_id].pathfinding_index + value
end
---@param tile_id tile_id valid tile id
---@return resource_id resource 
function DATA.tile_get_resource(tile_id)
    return DATA.tile[tile_id].resource
end
---@param tile_id tile_id valid tile id
---@param value resource_id valid resource_id
function DATA.tile_set_resource(tile_id, value)
    DATA.tile[tile_id].resource = value
end
---@param tile_id tile_id valid tile id
---@return bedrock_id bedrock 
function DATA.tile_get_bedrock(tile_id)
    return DATA.tile[tile_id].bedrock
end
---@param tile_id tile_id valid tile id
---@param value bedrock_id valid bedrock_id
function DATA.tile_set_bedrock(tile_id, value)
    DATA.tile[tile_id].bedrock = value
end
---@param tile_id tile_id valid tile id
---@return biome_id biome 
function DATA.tile_get_biome(tile_id)
    return DATA.tile[tile_id].biome
end
---@param tile_id tile_id valid tile id
---@param value biome_id valid biome_id
function DATA.tile_set_biome(tile_id, value)
    DATA.tile[tile_id].biome = value
end


local fat_tile_id_metatable = {
    __index = function (t,k)
        if (k == "world_id") then return DATA.tile_get_world_id(t.id) end
        if (k == "is_land") then return DATA.tile_get_is_land(t.id) end
        if (k == "is_fresh") then return DATA.tile_get_is_fresh(t.id) end
        if (k == "elevation") then return DATA.tile_get_elevation(t.id) end
        if (k == "grass") then return DATA.tile_get_grass(t.id) end
        if (k == "shrub") then return DATA.tile_get_shrub(t.id) end
        if (k == "conifer") then return DATA.tile_get_conifer(t.id) end
        if (k == "broadleaf") then return DATA.tile_get_broadleaf(t.id) end
        if (k == "ideal_grass") then return DATA.tile_get_ideal_grass(t.id) end
        if (k == "ideal_shrub") then return DATA.tile_get_ideal_shrub(t.id) end
        if (k == "ideal_conifer") then return DATA.tile_get_ideal_conifer(t.id) end
        if (k == "ideal_broadleaf") then return DATA.tile_get_ideal_broadleaf(t.id) end
        if (k == "silt") then return DATA.tile_get_silt(t.id) end
        if (k == "clay") then return DATA.tile_get_clay(t.id) end
        if (k == "sand") then return DATA.tile_get_sand(t.id) end
        if (k == "soil_minerals") then return DATA.tile_get_soil_minerals(t.id) end
        if (k == "soil_organics") then return DATA.tile_get_soil_organics(t.id) end
        if (k == "january_waterflow") then return DATA.tile_get_january_waterflow(t.id) end
        if (k == "july_waterflow") then return DATA.tile_get_july_waterflow(t.id) end
        if (k == "waterlevel") then return DATA.tile_get_waterlevel(t.id) end
        if (k == "has_river") then return DATA.tile_get_has_river(t.id) end
        if (k == "has_marsh") then return DATA.tile_get_has_marsh(t.id) end
        if (k == "ice") then return DATA.tile_get_ice(t.id) end
        if (k == "ice_age_ice") then return DATA.tile_get_ice_age_ice(t.id) end
        if (k == "debug_r") then return DATA.tile_get_debug_r(t.id) end
        if (k == "debug_g") then return DATA.tile_get_debug_g(t.id) end
        if (k == "debug_b") then return DATA.tile_get_debug_b(t.id) end
        if (k == "real_r") then return DATA.tile_get_real_r(t.id) end
        if (k == "real_g") then return DATA.tile_get_real_g(t.id) end
        if (k == "real_b") then return DATA.tile_get_real_b(t.id) end
        if (k == "pathfinding_index") then return DATA.tile_get_pathfinding_index(t.id) end
        if (k == "resource") then return DATA.tile_get_resource(t.id) end
        if (k == "bedrock") then return DATA.tile_get_bedrock(t.id) end
        if (k == "biome") then return DATA.tile_get_biome(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "world_id") then
            DATA.tile_set_world_id(t.id, v)
            return
        end
        if (k == "is_land") then
            DATA.tile_set_is_land(t.id, v)
            return
        end
        if (k == "is_fresh") then
            DATA.tile_set_is_fresh(t.id, v)
            return
        end
        if (k == "elevation") then
            DATA.tile_set_elevation(t.id, v)
            return
        end
        if (k == "grass") then
            DATA.tile_set_grass(t.id, v)
            return
        end
        if (k == "shrub") then
            DATA.tile_set_shrub(t.id, v)
            return
        end
        if (k == "conifer") then
            DATA.tile_set_conifer(t.id, v)
            return
        end
        if (k == "broadleaf") then
            DATA.tile_set_broadleaf(t.id, v)
            return
        end
        if (k == "ideal_grass") then
            DATA.tile_set_ideal_grass(t.id, v)
            return
        end
        if (k == "ideal_shrub") then
            DATA.tile_set_ideal_shrub(t.id, v)
            return
        end
        if (k == "ideal_conifer") then
            DATA.tile_set_ideal_conifer(t.id, v)
            return
        end
        if (k == "ideal_broadleaf") then
            DATA.tile_set_ideal_broadleaf(t.id, v)
            return
        end
        if (k == "silt") then
            DATA.tile_set_silt(t.id, v)
            return
        end
        if (k == "clay") then
            DATA.tile_set_clay(t.id, v)
            return
        end
        if (k == "sand") then
            DATA.tile_set_sand(t.id, v)
            return
        end
        if (k == "soil_minerals") then
            DATA.tile_set_soil_minerals(t.id, v)
            return
        end
        if (k == "soil_organics") then
            DATA.tile_set_soil_organics(t.id, v)
            return
        end
        if (k == "january_waterflow") then
            DATA.tile_set_january_waterflow(t.id, v)
            return
        end
        if (k == "july_waterflow") then
            DATA.tile_set_july_waterflow(t.id, v)
            return
        end
        if (k == "waterlevel") then
            DATA.tile_set_waterlevel(t.id, v)
            return
        end
        if (k == "has_river") then
            DATA.tile_set_has_river(t.id, v)
            return
        end
        if (k == "has_marsh") then
            DATA.tile_set_has_marsh(t.id, v)
            return
        end
        if (k == "ice") then
            DATA.tile_set_ice(t.id, v)
            return
        end
        if (k == "ice_age_ice") then
            DATA.tile_set_ice_age_ice(t.id, v)
            return
        end
        if (k == "debug_r") then
            DATA.tile_set_debug_r(t.id, v)
            return
        end
        if (k == "debug_g") then
            DATA.tile_set_debug_g(t.id, v)
            return
        end
        if (k == "debug_b") then
            DATA.tile_set_debug_b(t.id, v)
            return
        end
        if (k == "real_r") then
            DATA.tile_set_real_r(t.id, v)
            return
        end
        if (k == "real_g") then
            DATA.tile_set_real_g(t.id, v)
            return
        end
        if (k == "real_b") then
            DATA.tile_set_real_b(t.id, v)
            return
        end
        if (k == "pathfinding_index") then
            DATA.tile_set_pathfinding_index(t.id, v)
            return
        end
        if (k == "resource") then
            DATA.tile_set_resource(t.id, v)
            return
        end
        if (k == "bedrock") then
            DATA.tile_set_bedrock(t.id, v)
            return
        end
        if (k == "biome") then
            DATA.tile_set_biome(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id tile_id
---@return fat_tile_id fat_id
function DATA.fatten_tile(id)
    local result = {id = id}
    setmetatable(result, fat_tile_id_metatable)    return result
end
----------pop----------


---pop: LSP types---

---Unique identificator for pop entity
---@alias pop_id number

---@class (exact) fat_pop_id
---@field id pop_id Unique pop id
---@field race race_id 
---@field faith Faith 
---@field culture Culture 
---@field female boolean 
---@field age number 
---@field name string 
---@field savings number 
---@field parent pop_id 
---@field loyalty pop_id 
---@field life_needs_satisfaction number from 0 to 1
---@field basic_needs_satisfaction number from 0 to 1
---@field successor pop_id 
---@field forage_ratio number a number in (0, 1) interval representing a ratio of time pop spends to forage
---@field work_ratio number a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
---@field busy boolean 
---@field dead boolean 
---@field realm Realm Represents the home realm of the character
---@field rank CHARACTER_RANK 
---@field former_pop boolean 

---@class struct_pop
---@field race race_id 
---@field female boolean 
---@field age number 
---@field savings number 
---@field parent pop_id 
---@field loyalty pop_id 
---@field life_needs_satisfaction number from 0 to 1
---@field basic_needs_satisfaction number from 0 to 1
---@field need_satisfaction table<number, struct_need_satisfaction> 
---@field traits table<number, TRAIT> 
---@field successor pop_id 
---@field inventory table<trade_good_id, number> 
---@field price_memory table<trade_good_id, number> 
---@field forage_ratio number a number in (0, 1) interval representing a ratio of time pop spends to forage
---@field work_ratio number a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
---@field rank CHARACTER_RANK 
---@field dna table<number, number> 


ffi.cdef[[
    typedef struct {
        uint32_t race;
        bool female;
        uint32_t age;
        float savings;
        uint32_t parent;
        uint32_t loyalty;
        float life_needs_satisfaction;
        float basic_needs_satisfaction;
        need_satisfaction need_satisfaction[20];
        uint8_t traits[10];
        uint32_t successor;
        float inventory[100];
        float price_memory[100];
        float forage_ratio;
        float work_ratio;
        uint8_t rank;
        float dna[20];
    } pop;
void dcon_delete_pop(int32_t j);
int32_t dcon_create_pop();
void dcon_pop_resize(uint32_t sz);
]]

---pop: FFI arrays---
---@type (Faith)[]
DATA.pop_faith= {}
---@type (Culture)[]
DATA.pop_culture= {}
---@type (string)[]
DATA.pop_name= {}
---@type (boolean)[]
DATA.pop_busy= {}
---@type (boolean)[]
DATA.pop_dead= {}
---@type (Realm)[]
DATA.pop_realm= {}
---@type (boolean)[]
DATA.pop_former_pop= {}
---@type nil
DATA.pop_calloc = ffi.C.calloc(1, ffi.sizeof("pop") * 300001)
---@type table<pop_id, struct_pop>
DATA.pop = ffi.cast("pop*", DATA.pop_calloc)

---pop: LUA bindings---

DATA.pop_size = 300000
---@type table<pop_id, boolean>
local pop_indices_pool = ffi.new("bool[?]", 300000)
for i = 1, 299999 do
    pop_indices_pool[i] = true 
end
---@type table<pop_id, pop_id>
DATA.pop_indices_set = {}
function DATA.create_pop()
    ---@type number
    local i = DCON.dcon_create_pop() + 1
            DATA.pop_indices_set[i] = i
    return i
end
function DATA.delete_pop(i)
    do
        ---@type negotiation_id[]
        local to_delete = {}
        if DATA.get_negotiation_from_initiator(i) ~= nil then
            for _, value in ipairs(DATA.get_negotiation_from_initiator(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_negotiation(value)
        end
    end
    do
        ---@type negotiation_id[]
        local to_delete = {}
        if DATA.get_negotiation_from_target(i) ~= nil then
            for _, value in ipairs(DATA.get_negotiation_from_target(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_negotiation(value)
        end
    end
    do
        ---@type ownership_id[]
        local to_delete = {}
        if DATA.get_ownership_from_owner(i) ~= nil then
            for _, value in ipairs(DATA.get_ownership_from_owner(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_ownership(value)
        end
    end
    do
        local to_delete = DATA.get_employment_from_worker(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_employment(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_leader_from_leader(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_leader(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_recruiter_from_recruiter(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_recruiter(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_commander_from_commander(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_commander(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_unit_from_unit(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_unit(to_delete)
        end
    end
    do
        local to_delete = DATA.get_character_location_from_character(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_character_location(to_delete)
        end
    end
    do
        local to_delete = DATA.get_home_from_pop(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_home(to_delete)
        end
    end
    do
        local to_delete = DATA.get_pop_location_from_pop(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_pop_location(to_delete)
        end
    end
    do
        local to_delete = DATA.get_outlaw_location_from_outlaw(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_outlaw_location(to_delete)
        end
    end
    do
        ---@type parent_child_relation_id[]
        local to_delete = {}
        if DATA.get_parent_child_relation_from_parent(i) ~= nil then
            for _, value in ipairs(DATA.get_parent_child_relation_from_parent(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_parent_child_relation(value)
        end
    end
    do
        local to_delete = DATA.get_parent_child_relation_from_child(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_parent_child_relation(to_delete)
        end
    end
    do
        ---@type loyalty_id[]
        local to_delete = {}
        if DATA.get_loyalty_from_top(i) ~= nil then
            for _, value in ipairs(DATA.get_loyalty_from_top(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_loyalty(value)
        end
    end
    do
        local to_delete = DATA.get_loyalty_from_bottom(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_loyalty(to_delete)
        end
    end
    do
        local to_delete = DATA.get_succession_from_successor_of(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_succession(to_delete)
        end
    end
    do
        ---@type succession_id[]
        local to_delete = {}
        if DATA.get_succession_from_successor(i) ~= nil then
            for _, value in ipairs(DATA.get_succession_from_successor(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_succession(value)
        end
    end
    do
        local to_delete = DATA.get_realm_overseer_from_overseer(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_realm_overseer(to_delete)
        end
    end
    do
        ---@type realm_leadership_id[]
        local to_delete = {}
        if DATA.get_realm_leadership_from_leader(i) ~= nil then
            for _, value in ipairs(DATA.get_realm_leadership_from_leader(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_realm_leadership(value)
        end
    end
    do
        local to_delete = DATA.get_tax_collector_from_collector(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_tax_collector(to_delete)
        end
    end
    do
        ---@type personal_rights_id[]
        local to_delete = {}
        if DATA.get_personal_rights_from_person(i) ~= nil then
            for _, value in ipairs(DATA.get_personal_rights_from_person(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_personal_rights(value)
        end
    end
    do
        ---@type popularity_id[]
        local to_delete = {}
        if DATA.get_popularity_from_who(i) ~= nil then
            for _, value in ipairs(DATA.get_popularity_from_who(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_popularity(value)
        end
    end
    DATA.pop_indices_set[i] = nil
    return DCON.dcon_delete_pop(i - 1)
end
---@param func fun(item: pop_id) 
function DATA.for_each_pop(func)
    for _, item in pairs(DATA.pop_indices_set) do
        func(item)
    end
end
---@param func fun(item: pop_id):boolean 
---@return table<pop_id, pop_id> 
function DATA.filter_pop(func)
    ---@type table<pop_id, pop_id> 
    local t = {}
    for _, item in pairs(DATA.pop_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param pop_id pop_id valid pop id
---@return race_id race 
function DATA.pop_get_race(pop_id)
    return DATA.pop[pop_id].race
end
---@param pop_id pop_id valid pop id
---@param value race_id valid race_id
function DATA.pop_set_race(pop_id, value)
    DATA.pop[pop_id].race = value
end
---@param pop_id pop_id valid pop id
---@return Faith faith 
function DATA.pop_get_faith(pop_id)
    return DATA.pop_faith[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value Faith valid Faith
function DATA.pop_set_faith(pop_id, value)
    DATA.pop_faith[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@return Culture culture 
function DATA.pop_get_culture(pop_id)
    return DATA.pop_culture[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value Culture valid Culture
function DATA.pop_set_culture(pop_id, value)
    DATA.pop_culture[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@return boolean female 
function DATA.pop_get_female(pop_id)
    return DATA.pop[pop_id].female
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_female(pop_id, value)
    DATA.pop[pop_id].female = value
end
---@param pop_id pop_id valid pop id
---@return number age 
function DATA.pop_get_age(pop_id)
    return DATA.pop[pop_id].age
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_age(pop_id, value)
    DATA.pop[pop_id].age = value
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_age(pop_id, value)
    DATA.pop[pop_id].age = DATA.pop[pop_id].age + value
end
---@param pop_id pop_id valid pop id
---@return string name 
function DATA.pop_get_name(pop_id)
    return DATA.pop_name[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value string valid string
function DATA.pop_set_name(pop_id, value)
    DATA.pop_name[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@return number savings 
function DATA.pop_get_savings(pop_id)
    return DATA.pop[pop_id].savings
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_savings(pop_id, value)
    DATA.pop[pop_id].savings = value
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_savings(pop_id, value)
    DATA.pop[pop_id].savings = DATA.pop[pop_id].savings + value
end
---@param pop_id pop_id valid pop id
---@return pop_id parent 
function DATA.pop_get_parent(pop_id)
    return DATA.pop[pop_id].parent
end
---@param pop_id pop_id valid pop id
---@param value pop_id valid pop_id
function DATA.pop_set_parent(pop_id, value)
    DATA.pop[pop_id].parent = value
end
---@param pop_id pop_id valid pop id
---@return pop_id loyalty 
function DATA.pop_get_loyalty(pop_id)
    return DATA.pop[pop_id].loyalty
end
---@param pop_id pop_id valid pop id
---@param value pop_id valid pop_id
function DATA.pop_set_loyalty(pop_id, value)
    DATA.pop[pop_id].loyalty = value
end
---@param pop_id pop_id valid pop id
---@return number life_needs_satisfaction from 0 to 1
function DATA.pop_get_life_needs_satisfaction(pop_id)
    return DATA.pop[pop_id].life_needs_satisfaction
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_life_needs_satisfaction(pop_id, value)
    DATA.pop[pop_id].life_needs_satisfaction = value
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_life_needs_satisfaction(pop_id, value)
    DATA.pop[pop_id].life_needs_satisfaction = DATA.pop[pop_id].life_needs_satisfaction + value
end
---@param pop_id pop_id valid pop id
---@return number basic_needs_satisfaction from 0 to 1
function DATA.pop_get_basic_needs_satisfaction(pop_id)
    return DATA.pop[pop_id].basic_needs_satisfaction
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_basic_needs_satisfaction(pop_id, value)
    DATA.pop[pop_id].basic_needs_satisfaction = value
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_basic_needs_satisfaction(pop_id, value)
    DATA.pop[pop_id].basic_needs_satisfaction = DATA.pop[pop_id].basic_needs_satisfaction + value
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return NEED need_satisfaction 
function DATA.pop_get_need_satisfaction_need(pop_id, index)
    return DATA.pop[pop_id].need_satisfaction[index].need
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return use_case_id need_satisfaction 
function DATA.pop_get_need_satisfaction_use_case(pop_id, index)
    return DATA.pop[pop_id].need_satisfaction[index].use_case
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return number need_satisfaction 
function DATA.pop_get_need_satisfaction_consumed(pop_id, index)
    return DATA.pop[pop_id].need_satisfaction[index].consumed
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return number need_satisfaction 
function DATA.pop_get_need_satisfaction_demanded(pop_id, index)
    return DATA.pop[pop_id].need_satisfaction[index].demanded
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value NEED valid NEED
function DATA.pop_set_need_satisfaction_need(pop_id, index, value)
    DATA.pop[pop_id].need_satisfaction[index].need = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value use_case_id valid use_case_id
function DATA.pop_set_need_satisfaction_use_case(pop_id, index, value)
    DATA.pop[pop_id].need_satisfaction[index].use_case = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_set_need_satisfaction_consumed(pop_id, index, value)
    DATA.pop[pop_id].need_satisfaction[index].consumed = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_inc_need_satisfaction_consumed(pop_id, index, value)
    DATA.pop[pop_id].need_satisfaction[index].consumed = DATA.pop[pop_id].need_satisfaction[index].consumed + value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_set_need_satisfaction_demanded(pop_id, index, value)
    DATA.pop[pop_id].need_satisfaction[index].demanded = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_inc_need_satisfaction_demanded(pop_id, index, value)
    DATA.pop[pop_id].need_satisfaction[index].demanded = DATA.pop[pop_id].need_satisfaction[index].demanded + value
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return TRAIT traits 
function DATA.pop_get_traits(pop_id, index)
    return DATA.pop[pop_id].traits[index]
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value TRAIT valid TRAIT
function DATA.pop_set_traits(pop_id, index, value)
    DATA.pop[pop_id].traits[index] = value
end
---@param pop_id pop_id valid pop id
---@return pop_id successor 
function DATA.pop_get_successor(pop_id)
    return DATA.pop[pop_id].successor
end
---@param pop_id pop_id valid pop id
---@param value pop_id valid pop_id
function DATA.pop_set_successor(pop_id, value)
    DATA.pop[pop_id].successor = value
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid
---@return number inventory 
function DATA.pop_get_inventory(pop_id, index)
    return DATA.pop[pop_id].inventory[index]
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_set_inventory(pop_id, index, value)
    DATA.pop[pop_id].inventory[index] = value
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_inc_inventory(pop_id, index, value)
    DATA.pop[pop_id].inventory[index] = DATA.pop[pop_id].inventory[index] + value
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid
---@return number price_memory 
function DATA.pop_get_price_memory(pop_id, index)
    return DATA.pop[pop_id].price_memory[index]
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_set_price_memory(pop_id, index, value)
    DATA.pop[pop_id].price_memory[index] = value
end
---@param pop_id pop_id valid pop id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.pop_inc_price_memory(pop_id, index, value)
    DATA.pop[pop_id].price_memory[index] = DATA.pop[pop_id].price_memory[index] + value
end
---@param pop_id pop_id valid pop id
---@return number forage_ratio a number in (0, 1) interval representing a ratio of time pop spends to forage
function DATA.pop_get_forage_ratio(pop_id)
    return DATA.pop[pop_id].forage_ratio
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_forage_ratio(pop_id, value)
    DATA.pop[pop_id].forage_ratio = value
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_forage_ratio(pop_id, value)
    DATA.pop[pop_id].forage_ratio = DATA.pop[pop_id].forage_ratio + value
end
---@param pop_id pop_id valid pop id
---@return number work_ratio a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
function DATA.pop_get_work_ratio(pop_id)
    return DATA.pop[pop_id].work_ratio
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_set_work_ratio(pop_id, value)
    DATA.pop[pop_id].work_ratio = value
end
---@param pop_id pop_id valid pop id
---@param value number valid number
function DATA.pop_inc_work_ratio(pop_id, value)
    DATA.pop[pop_id].work_ratio = DATA.pop[pop_id].work_ratio + value
end
---@param pop_id pop_id valid pop id
---@return boolean busy 
function DATA.pop_get_busy(pop_id)
    return DATA.pop_busy[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_busy(pop_id, value)
    DATA.pop_busy[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@return boolean dead 
function DATA.pop_get_dead(pop_id)
    return DATA.pop_dead[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_dead(pop_id, value)
    DATA.pop_dead[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@return Realm realm Represents the home realm of the character
function DATA.pop_get_realm(pop_id)
    return DATA.pop_realm[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value Realm valid Realm
function DATA.pop_set_realm(pop_id, value)
    DATA.pop_realm[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@return CHARACTER_RANK rank 
function DATA.pop_get_rank(pop_id)
    return DATA.pop[pop_id].rank
end
---@param pop_id pop_id valid pop id
---@param value CHARACTER_RANK valid CHARACTER_RANK
function DATA.pop_set_rank(pop_id, value)
    DATA.pop[pop_id].rank = value
end
---@param pop_id pop_id valid pop id
---@return boolean former_pop 
function DATA.pop_get_former_pop(pop_id)
    return DATA.pop_former_pop[pop_id]
end
---@param pop_id pop_id valid pop id
---@param value boolean valid boolean
function DATA.pop_set_former_pop(pop_id, value)
    DATA.pop_former_pop[pop_id] = value
end
---@param pop_id pop_id valid pop id
---@param index number valid
---@return number dna 
function DATA.pop_get_dna(pop_id, index)
    return DATA.pop[pop_id].dna[index]
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_set_dna(pop_id, index, value)
    DATA.pop[pop_id].dna[index] = value
end
---@param pop_id pop_id valid pop id
---@param index number valid index
---@param value number valid number
function DATA.pop_inc_dna(pop_id, index, value)
    DATA.pop[pop_id].dna[index] = DATA.pop[pop_id].dna[index] + value
end


local fat_pop_id_metatable = {
    __index = function (t,k)
        if (k == "race") then return DATA.pop_get_race(t.id) end
        if (k == "faith") then return DATA.pop_get_faith(t.id) end
        if (k == "culture") then return DATA.pop_get_culture(t.id) end
        if (k == "female") then return DATA.pop_get_female(t.id) end
        if (k == "age") then return DATA.pop_get_age(t.id) end
        if (k == "name") then return DATA.pop_get_name(t.id) end
        if (k == "savings") then return DATA.pop_get_savings(t.id) end
        if (k == "parent") then return DATA.pop_get_parent(t.id) end
        if (k == "loyalty") then return DATA.pop_get_loyalty(t.id) end
        if (k == "life_needs_satisfaction") then return DATA.pop_get_life_needs_satisfaction(t.id) end
        if (k == "basic_needs_satisfaction") then return DATA.pop_get_basic_needs_satisfaction(t.id) end
        if (k == "successor") then return DATA.pop_get_successor(t.id) end
        if (k == "forage_ratio") then return DATA.pop_get_forage_ratio(t.id) end
        if (k == "work_ratio") then return DATA.pop_get_work_ratio(t.id) end
        if (k == "busy") then return DATA.pop_get_busy(t.id) end
        if (k == "dead") then return DATA.pop_get_dead(t.id) end
        if (k == "realm") then return DATA.pop_get_realm(t.id) end
        if (k == "rank") then return DATA.pop_get_rank(t.id) end
        if (k == "former_pop") then return DATA.pop_get_former_pop(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "race") then
            DATA.pop_set_race(t.id, v)
            return
        end
        if (k == "faith") then
            DATA.pop_set_faith(t.id, v)
            return
        end
        if (k == "culture") then
            DATA.pop_set_culture(t.id, v)
            return
        end
        if (k == "female") then
            DATA.pop_set_female(t.id, v)
            return
        end
        if (k == "age") then
            DATA.pop_set_age(t.id, v)
            return
        end
        if (k == "name") then
            DATA.pop_set_name(t.id, v)
            return
        end
        if (k == "savings") then
            DATA.pop_set_savings(t.id, v)
            return
        end
        if (k == "parent") then
            DATA.pop_set_parent(t.id, v)
            return
        end
        if (k == "loyalty") then
            DATA.pop_set_loyalty(t.id, v)
            return
        end
        if (k == "life_needs_satisfaction") then
            DATA.pop_set_life_needs_satisfaction(t.id, v)
            return
        end
        if (k == "basic_needs_satisfaction") then
            DATA.pop_set_basic_needs_satisfaction(t.id, v)
            return
        end
        if (k == "successor") then
            DATA.pop_set_successor(t.id, v)
            return
        end
        if (k == "forage_ratio") then
            DATA.pop_set_forage_ratio(t.id, v)
            return
        end
        if (k == "work_ratio") then
            DATA.pop_set_work_ratio(t.id, v)
            return
        end
        if (k == "busy") then
            DATA.pop_set_busy(t.id, v)
            return
        end
        if (k == "dead") then
            DATA.pop_set_dead(t.id, v)
            return
        end
        if (k == "realm") then
            DATA.pop_set_realm(t.id, v)
            return
        end
        if (k == "rank") then
            DATA.pop_set_rank(t.id, v)
            return
        end
        if (k == "former_pop") then
            DATA.pop_set_former_pop(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id pop_id
---@return fat_pop_id fat_id
function DATA.fatten_pop(id)
    local result = {id = id}
    setmetatable(result, fat_pop_id_metatable)    return result
end
----------province----------


---province: LSP types---

---Unique identificator for province entity
---@alias province_id number

---@class (exact) fat_province_id
---@field id province_id Unique province id
---@field name string 
---@field r number 
---@field g number 
---@field b number 
---@field is_land boolean 
---@field province_id number 
---@field size number 
---@field hydration number Number of humans that can live of off this provinces innate water
---@field movement_cost number 
---@field center tile_id The tile which contains this province's settlement, if there is any.
---@field infrastructure_needed number 
---@field infrastructure number 
---@field infrastructure_investment number 
---@field local_wealth number 
---@field trade_wealth number 
---@field local_income number 
---@field local_building_upkeep number 
---@field foragers number Keeps track of the number of foragers in the province. Used to calculate yields of independent foraging.
---@field foragers_water number amount foraged by pops and characters
---@field foragers_limit number amount of calories foraged by pops and characters
---@field mood number how local population thinks about the state
---@field on_a_river boolean 
---@field on_a_forest boolean 

---@class struct_province
---@field r number 
---@field g number 
---@field b number 
---@field is_land boolean 
---@field province_id number 
---@field size number 
---@field hydration number Number of humans that can live of off this provinces innate water
---@field movement_cost number 
---@field center tile_id The tile which contains this province's settlement, if there is any.
---@field infrastructure_needed number 
---@field infrastructure number 
---@field infrastructure_investment number 
---@field technologies_present table<technology_id, number> 
---@field technologies_researchable table<technology_id, number> 
---@field buildable_buildings table<building_type_id, number> 
---@field local_production table<trade_good_id, number> 
---@field local_consumption table<trade_good_id, number> 
---@field local_demand table<trade_good_id, number> 
---@field local_storage table<trade_good_id, number> 
---@field local_prices table<trade_good_id, number> 
---@field local_wealth number 
---@field trade_wealth number 
---@field local_income number 
---@field local_building_upkeep number 
---@field foragers number Keeps track of the number of foragers in the province. Used to calculate yields of independent foraging.
---@field foragers_water number amount foraged by pops and characters
---@field foragers_limit number amount of calories foraged by pops and characters
---@field foragers_targets table<number, struct_forage_container> 
---@field local_resources table<number, struct_resource_location> An array of local resources and their positions
---@field mood number how local population thinks about the state
---@field unit_types table<unit_type_id, number> 
---@field throughput_boosts table<production_method_id, number> 
---@field input_efficiency_boosts table<production_method_id, number> 
---@field output_efficiency_boosts table<production_method_id, number> 
---@field on_a_river boolean 
---@field on_a_forest boolean 


ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        bool is_land;
        float province_id;
        float size;
        float hydration;
        float movement_cost;
        uint32_t center;
        float infrastructure_needed;
        float infrastructure;
        float infrastructure_investment;
        uint8_t technologies_present[400];
        uint8_t technologies_researchable[400];
        uint8_t buildable_buildings[250];
        float local_production[100];
        float local_consumption[100];
        float local_demand[100];
        float local_storage[100];
        float local_prices[100];
        float local_wealth;
        float trade_wealth;
        float local_income;
        float local_building_upkeep;
        float foragers;
        float foragers_water;
        float foragers_limit;
        forage_container foragers_targets[25];
        resource_location local_resources[25];
        float mood;
        uint8_t unit_types[20];
        float throughput_boosts[250];
        float input_efficiency_boosts[250];
        float output_efficiency_boosts[250];
        bool on_a_river;
        bool on_a_forest;
    } province;
void dcon_delete_province(int32_t j);
int32_t dcon_create_province();
void dcon_province_resize(uint32_t sz);
]]

---province: FFI arrays---
---@type (string)[]
DATA.province_name= {}
---@type nil
DATA.province_calloc = ffi.C.calloc(1, ffi.sizeof("province") * 20001)
---@type table<province_id, struct_province>
DATA.province = ffi.cast("province*", DATA.province_calloc)

---province: LUA bindings---

DATA.province_size = 20000
---@type table<province_id, boolean>
local province_indices_pool = ffi.new("bool[?]", 20000)
for i = 1, 19999 do
    province_indices_pool[i] = true 
end
---@type table<province_id, province_id>
DATA.province_indices_set = {}
function DATA.create_province()
    ---@type number
    local i = DCON.dcon_create_province() + 1
            DATA.province_indices_set[i] = i
    return i
end
function DATA.delete_province(i)
    do
        ---@type building_location_id[]
        local to_delete = {}
        if DATA.get_building_location_from_location(i) ~= nil then
            for _, value in ipairs(DATA.get_building_location_from_location(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_building_location(value)
        end
    end
    do
        ---@type warband_location_id[]
        local to_delete = {}
        if DATA.get_warband_location_from_location(i) ~= nil then
            for _, value in ipairs(DATA.get_warband_location_from_location(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_warband_location(value)
        end
    end
    do
        ---@type character_location_id[]
        local to_delete = {}
        if DATA.get_character_location_from_location(i) ~= nil then
            for _, value in ipairs(DATA.get_character_location_from_location(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_character_location(value)
        end
    end
    do
        ---@type home_id[]
        local to_delete = {}
        if DATA.get_home_from_home(i) ~= nil then
            for _, value in ipairs(DATA.get_home_from_home(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_home(value)
        end
    end
    do
        ---@type pop_location_id[]
        local to_delete = {}
        if DATA.get_pop_location_from_location(i) ~= nil then
            for _, value in ipairs(DATA.get_pop_location_from_location(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_pop_location(value)
        end
    end
    do
        ---@type outlaw_location_id[]
        local to_delete = {}
        if DATA.get_outlaw_location_from_location(i) ~= nil then
            for _, value in ipairs(DATA.get_outlaw_location_from_location(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_outlaw_location(value)
        end
    end
    do
        ---@type tile_province_membership_id[]
        local to_delete = {}
        if DATA.get_tile_province_membership_from_province(i) ~= nil then
            for _, value in ipairs(DATA.get_tile_province_membership_from_province(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_tile_province_membership(value)
        end
    end
    do
        ---@type province_neighborhood_id[]
        local to_delete = {}
        if DATA.get_province_neighborhood_from_origin(i) ~= nil then
            for _, value in ipairs(DATA.get_province_neighborhood_from_origin(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_province_neighborhood(value)
        end
    end
    do
        ---@type province_neighborhood_id[]
        local to_delete = {}
        if DATA.get_province_neighborhood_from_target(i) ~= nil then
            for _, value in ipairs(DATA.get_province_neighborhood_from_target(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_province_neighborhood(value)
        end
    end
    do
        local to_delete = DATA.get_realm_provinces_from_province(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_realm_provinces(to_delete)
        end
    end
    DATA.province_indices_set[i] = nil
    return DCON.dcon_delete_province(i - 1)
end
---@param func fun(item: province_id) 
function DATA.for_each_province(func)
    for _, item in pairs(DATA.province_indices_set) do
        func(item)
    end
end
---@param func fun(item: province_id):boolean 
---@return table<province_id, province_id> 
function DATA.filter_province(func)
    ---@type table<province_id, province_id> 
    local t = {}
    for _, item in pairs(DATA.province_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param province_id province_id valid province id
---@return string name 
function DATA.province_get_name(province_id)
    return DATA.province_name[province_id]
end
---@param province_id province_id valid province id
---@param value string valid string
function DATA.province_set_name(province_id, value)
    DATA.province_name[province_id] = value
end
---@param province_id province_id valid province id
---@return number r 
function DATA.province_get_r(province_id)
    return DATA.province[province_id].r
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_r(province_id, value)
    DATA.province[province_id].r = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_r(province_id, value)
    DATA.province[province_id].r = DATA.province[province_id].r + value
end
---@param province_id province_id valid province id
---@return number g 
function DATA.province_get_g(province_id)
    return DATA.province[province_id].g
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_g(province_id, value)
    DATA.province[province_id].g = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_g(province_id, value)
    DATA.province[province_id].g = DATA.province[province_id].g + value
end
---@param province_id province_id valid province id
---@return number b 
function DATA.province_get_b(province_id)
    return DATA.province[province_id].b
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_b(province_id, value)
    DATA.province[province_id].b = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_b(province_id, value)
    DATA.province[province_id].b = DATA.province[province_id].b + value
end
---@param province_id province_id valid province id
---@return boolean is_land 
function DATA.province_get_is_land(province_id)
    return DATA.province[province_id].is_land
end
---@param province_id province_id valid province id
---@param value boolean valid boolean
function DATA.province_set_is_land(province_id, value)
    DATA.province[province_id].is_land = value
end
---@param province_id province_id valid province id
---@return number province_id 
function DATA.province_get_province_id(province_id)
    return DATA.province[province_id].province_id
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_province_id(province_id, value)
    DATA.province[province_id].province_id = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_province_id(province_id, value)
    DATA.province[province_id].province_id = DATA.province[province_id].province_id + value
end
---@param province_id province_id valid province id
---@return number size 
function DATA.province_get_size(province_id)
    return DATA.province[province_id].size
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_size(province_id, value)
    DATA.province[province_id].size = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_size(province_id, value)
    DATA.province[province_id].size = DATA.province[province_id].size + value
end
---@param province_id province_id valid province id
---@return number hydration Number of humans that can live of off this provinces innate water
function DATA.province_get_hydration(province_id)
    return DATA.province[province_id].hydration
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_hydration(province_id, value)
    DATA.province[province_id].hydration = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_hydration(province_id, value)
    DATA.province[province_id].hydration = DATA.province[province_id].hydration + value
end
---@param province_id province_id valid province id
---@return number movement_cost 
function DATA.province_get_movement_cost(province_id)
    return DATA.province[province_id].movement_cost
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_movement_cost(province_id, value)
    DATA.province[province_id].movement_cost = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_movement_cost(province_id, value)
    DATA.province[province_id].movement_cost = DATA.province[province_id].movement_cost + value
end
---@param province_id province_id valid province id
---@return tile_id center The tile which contains this province's settlement, if there is any.
function DATA.province_get_center(province_id)
    return DATA.province[province_id].center
end
---@param province_id province_id valid province id
---@param value tile_id valid tile_id
function DATA.province_set_center(province_id, value)
    DATA.province[province_id].center = value
end
---@param province_id province_id valid province id
---@return number infrastructure_needed 
function DATA.province_get_infrastructure_needed(province_id)
    return DATA.province[province_id].infrastructure_needed
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_infrastructure_needed(province_id, value)
    DATA.province[province_id].infrastructure_needed = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_infrastructure_needed(province_id, value)
    DATA.province[province_id].infrastructure_needed = DATA.province[province_id].infrastructure_needed + value
end
---@param province_id province_id valid province id
---@return number infrastructure 
function DATA.province_get_infrastructure(province_id)
    return DATA.province[province_id].infrastructure
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_infrastructure(province_id, value)
    DATA.province[province_id].infrastructure = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_infrastructure(province_id, value)
    DATA.province[province_id].infrastructure = DATA.province[province_id].infrastructure + value
end
---@param province_id province_id valid province id
---@return number infrastructure_investment 
function DATA.province_get_infrastructure_investment(province_id)
    return DATA.province[province_id].infrastructure_investment
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_infrastructure_investment(province_id, value)
    DATA.province[province_id].infrastructure_investment = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_infrastructure_investment(province_id, value)
    DATA.province[province_id].infrastructure_investment = DATA.province[province_id].infrastructure_investment + value
end
---@param province_id province_id valid province id
---@param index technology_id valid
---@return number technologies_present 
function DATA.province_get_technologies_present(province_id, index)
    return DATA.province[province_id].technologies_present[index]
end
---@param province_id province_id valid province id
---@param index technology_id valid index
---@param value number valid number
function DATA.province_set_technologies_present(province_id, index, value)
    DATA.province[province_id].technologies_present[index] = value
end
---@param province_id province_id valid province id
---@param index technology_id valid index
---@param value number valid number
function DATA.province_inc_technologies_present(province_id, index, value)
    DATA.province[province_id].technologies_present[index] = DATA.province[province_id].technologies_present[index] + value
end
---@param province_id province_id valid province id
---@param index technology_id valid
---@return number technologies_researchable 
function DATA.province_get_technologies_researchable(province_id, index)
    return DATA.province[province_id].technologies_researchable[index]
end
---@param province_id province_id valid province id
---@param index technology_id valid index
---@param value number valid number
function DATA.province_set_technologies_researchable(province_id, index, value)
    DATA.province[province_id].technologies_researchable[index] = value
end
---@param province_id province_id valid province id
---@param index technology_id valid index
---@param value number valid number
function DATA.province_inc_technologies_researchable(province_id, index, value)
    DATA.province[province_id].technologies_researchable[index] = DATA.province[province_id].technologies_researchable[index] + value
end
---@param province_id province_id valid province id
---@param index building_type_id valid
---@return number buildable_buildings 
function DATA.province_get_buildable_buildings(province_id, index)
    return DATA.province[province_id].buildable_buildings[index]
end
---@param province_id province_id valid province id
---@param index building_type_id valid index
---@param value number valid number
function DATA.province_set_buildable_buildings(province_id, index, value)
    DATA.province[province_id].buildable_buildings[index] = value
end
---@param province_id province_id valid province id
---@param index building_type_id valid index
---@param value number valid number
function DATA.province_inc_buildable_buildings(province_id, index, value)
    DATA.province[province_id].buildable_buildings[index] = DATA.province[province_id].buildable_buildings[index] + value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid
---@return number local_production 
function DATA.province_get_local_production(province_id, index)
    return DATA.province[province_id].local_production[index]
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_set_local_production(province_id, index, value)
    DATA.province[province_id].local_production[index] = value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_inc_local_production(province_id, index, value)
    DATA.province[province_id].local_production[index] = DATA.province[province_id].local_production[index] + value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid
---@return number local_consumption 
function DATA.province_get_local_consumption(province_id, index)
    return DATA.province[province_id].local_consumption[index]
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_set_local_consumption(province_id, index, value)
    DATA.province[province_id].local_consumption[index] = value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_inc_local_consumption(province_id, index, value)
    DATA.province[province_id].local_consumption[index] = DATA.province[province_id].local_consumption[index] + value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid
---@return number local_demand 
function DATA.province_get_local_demand(province_id, index)
    return DATA.province[province_id].local_demand[index]
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_set_local_demand(province_id, index, value)
    DATA.province[province_id].local_demand[index] = value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_inc_local_demand(province_id, index, value)
    DATA.province[province_id].local_demand[index] = DATA.province[province_id].local_demand[index] + value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid
---@return number local_storage 
function DATA.province_get_local_storage(province_id, index)
    return DATA.province[province_id].local_storage[index]
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_set_local_storage(province_id, index, value)
    DATA.province[province_id].local_storage[index] = value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_inc_local_storage(province_id, index, value)
    DATA.province[province_id].local_storage[index] = DATA.province[province_id].local_storage[index] + value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid
---@return number local_prices 
function DATA.province_get_local_prices(province_id, index)
    return DATA.province[province_id].local_prices[index]
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_set_local_prices(province_id, index, value)
    DATA.province[province_id].local_prices[index] = value
end
---@param province_id province_id valid province id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.province_inc_local_prices(province_id, index, value)
    DATA.province[province_id].local_prices[index] = DATA.province[province_id].local_prices[index] + value
end
---@param province_id province_id valid province id
---@return number local_wealth 
function DATA.province_get_local_wealth(province_id)
    return DATA.province[province_id].local_wealth
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_local_wealth(province_id, value)
    DATA.province[province_id].local_wealth = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_local_wealth(province_id, value)
    DATA.province[province_id].local_wealth = DATA.province[province_id].local_wealth + value
end
---@param province_id province_id valid province id
---@return number trade_wealth 
function DATA.province_get_trade_wealth(province_id)
    return DATA.province[province_id].trade_wealth
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_trade_wealth(province_id, value)
    DATA.province[province_id].trade_wealth = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_trade_wealth(province_id, value)
    DATA.province[province_id].trade_wealth = DATA.province[province_id].trade_wealth + value
end
---@param province_id province_id valid province id
---@return number local_income 
function DATA.province_get_local_income(province_id)
    return DATA.province[province_id].local_income
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_local_income(province_id, value)
    DATA.province[province_id].local_income = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_local_income(province_id, value)
    DATA.province[province_id].local_income = DATA.province[province_id].local_income + value
end
---@param province_id province_id valid province id
---@return number local_building_upkeep 
function DATA.province_get_local_building_upkeep(province_id)
    return DATA.province[province_id].local_building_upkeep
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_local_building_upkeep(province_id, value)
    DATA.province[province_id].local_building_upkeep = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_local_building_upkeep(province_id, value)
    DATA.province[province_id].local_building_upkeep = DATA.province[province_id].local_building_upkeep + value
end
---@param province_id province_id valid province id
---@return number foragers Keeps track of the number of foragers in the province. Used to calculate yields of independent foraging.
function DATA.province_get_foragers(province_id)
    return DATA.province[province_id].foragers
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_foragers(province_id, value)
    DATA.province[province_id].foragers = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_foragers(province_id, value)
    DATA.province[province_id].foragers = DATA.province[province_id].foragers + value
end
---@param province_id province_id valid province id
---@return number foragers_water amount foraged by pops and characters
function DATA.province_get_foragers_water(province_id)
    return DATA.province[province_id].foragers_water
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_foragers_water(province_id, value)
    DATA.province[province_id].foragers_water = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_foragers_water(province_id, value)
    DATA.province[province_id].foragers_water = DATA.province[province_id].foragers_water + value
end
---@param province_id province_id valid province id
---@return number foragers_limit amount of calories foraged by pops and characters
function DATA.province_get_foragers_limit(province_id)
    return DATA.province[province_id].foragers_limit
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_foragers_limit(province_id, value)
    DATA.province[province_id].foragers_limit = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_foragers_limit(province_id, value)
    DATA.province[province_id].foragers_limit = DATA.province[province_id].foragers_limit + value
end
---@param province_id province_id valid province id
---@param index number valid
---@return trade_good_id foragers_targets 
function DATA.province_get_foragers_targets_output_good(province_id, index)
    return DATA.province[province_id].foragers_targets[index].output_good
end
---@param province_id province_id valid province id
---@param index number valid
---@return number foragers_targets 
function DATA.province_get_foragers_targets_output_value(province_id, index)
    return DATA.province[province_id].foragers_targets[index].output_value
end
---@param province_id province_id valid province id
---@param index number valid
---@return number foragers_targets 
function DATA.province_get_foragers_targets_amount(province_id, index)
    return DATA.province[province_id].foragers_targets[index].amount
end
---@param province_id province_id valid province id
---@param index number valid
---@return FORAGE_RESOURCE foragers_targets 
function DATA.province_get_foragers_targets_forage(province_id, index)
    return DATA.province[province_id].foragers_targets[index].forage
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.province_set_foragers_targets_output_good(province_id, index, value)
    DATA.province[province_id].foragers_targets[index].output_good = value
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value number valid number
function DATA.province_set_foragers_targets_output_value(province_id, index, value)
    DATA.province[province_id].foragers_targets[index].output_value = value
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value number valid number
function DATA.province_inc_foragers_targets_output_value(province_id, index, value)
    DATA.province[province_id].foragers_targets[index].output_value = DATA.province[province_id].foragers_targets[index].output_value + value
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value number valid number
function DATA.province_set_foragers_targets_amount(province_id, index, value)
    DATA.province[province_id].foragers_targets[index].amount = value
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value number valid number
function DATA.province_inc_foragers_targets_amount(province_id, index, value)
    DATA.province[province_id].foragers_targets[index].amount = DATA.province[province_id].foragers_targets[index].amount + value
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value FORAGE_RESOURCE valid FORAGE_RESOURCE
function DATA.province_set_foragers_targets_forage(province_id, index, value)
    DATA.province[province_id].foragers_targets[index].forage = value
end
---@param province_id province_id valid province id
---@param index number valid
---@return resource_id local_resources An array of local resources and their positions
function DATA.province_get_local_resources_resource(province_id, index)
    return DATA.province[province_id].local_resources[index].resource
end
---@param province_id province_id valid province id
---@param index number valid
---@return tile_id local_resources An array of local resources and their positions
function DATA.province_get_local_resources_location(province_id, index)
    return DATA.province[province_id].local_resources[index].location
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value resource_id valid resource_id
function DATA.province_set_local_resources_resource(province_id, index, value)
    DATA.province[province_id].local_resources[index].resource = value
end
---@param province_id province_id valid province id
---@param index number valid index
---@param value tile_id valid tile_id
function DATA.province_set_local_resources_location(province_id, index, value)
    DATA.province[province_id].local_resources[index].location = value
end
---@param province_id province_id valid province id
---@return number mood how local population thinks about the state
function DATA.province_get_mood(province_id)
    return DATA.province[province_id].mood
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_set_mood(province_id, value)
    DATA.province[province_id].mood = value
end
---@param province_id province_id valid province id
---@param value number valid number
function DATA.province_inc_mood(province_id, value)
    DATA.province[province_id].mood = DATA.province[province_id].mood + value
end
---@param province_id province_id valid province id
---@param index unit_type_id valid
---@return number unit_types 
function DATA.province_get_unit_types(province_id, index)
    return DATA.province[province_id].unit_types[index]
end
---@param province_id province_id valid province id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.province_set_unit_types(province_id, index, value)
    DATA.province[province_id].unit_types[index] = value
end
---@param province_id province_id valid province id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.province_inc_unit_types(province_id, index, value)
    DATA.province[province_id].unit_types[index] = DATA.province[province_id].unit_types[index] + value
end
---@param province_id province_id valid province id
---@param index production_method_id valid
---@return number throughput_boosts 
function DATA.province_get_throughput_boosts(province_id, index)
    return DATA.province[province_id].throughput_boosts[index]
end
---@param province_id province_id valid province id
---@param index production_method_id valid index
---@param value number valid number
function DATA.province_set_throughput_boosts(province_id, index, value)
    DATA.province[province_id].throughput_boosts[index] = value
end
---@param province_id province_id valid province id
---@param index production_method_id valid index
---@param value number valid number
function DATA.province_inc_throughput_boosts(province_id, index, value)
    DATA.province[province_id].throughput_boosts[index] = DATA.province[province_id].throughput_boosts[index] + value
end
---@param province_id province_id valid province id
---@param index production_method_id valid
---@return number input_efficiency_boosts 
function DATA.province_get_input_efficiency_boosts(province_id, index)
    return DATA.province[province_id].input_efficiency_boosts[index]
end
---@param province_id province_id valid province id
---@param index production_method_id valid index
---@param value number valid number
function DATA.province_set_input_efficiency_boosts(province_id, index, value)
    DATA.province[province_id].input_efficiency_boosts[index] = value
end
---@param province_id province_id valid province id
---@param index production_method_id valid index
---@param value number valid number
function DATA.province_inc_input_efficiency_boosts(province_id, index, value)
    DATA.province[province_id].input_efficiency_boosts[index] = DATA.province[province_id].input_efficiency_boosts[index] + value
end
---@param province_id province_id valid province id
---@param index production_method_id valid
---@return number output_efficiency_boosts 
function DATA.province_get_output_efficiency_boosts(province_id, index)
    return DATA.province[province_id].output_efficiency_boosts[index]
end
---@param province_id province_id valid province id
---@param index production_method_id valid index
---@param value number valid number
function DATA.province_set_output_efficiency_boosts(province_id, index, value)
    DATA.province[province_id].output_efficiency_boosts[index] = value
end
---@param province_id province_id valid province id
---@param index production_method_id valid index
---@param value number valid number
function DATA.province_inc_output_efficiency_boosts(province_id, index, value)
    DATA.province[province_id].output_efficiency_boosts[index] = DATA.province[province_id].output_efficiency_boosts[index] + value
end
---@param province_id province_id valid province id
---@return boolean on_a_river 
function DATA.province_get_on_a_river(province_id)
    return DATA.province[province_id].on_a_river
end
---@param province_id province_id valid province id
---@param value boolean valid boolean
function DATA.province_set_on_a_river(province_id, value)
    DATA.province[province_id].on_a_river = value
end
---@param province_id province_id valid province id
---@return boolean on_a_forest 
function DATA.province_get_on_a_forest(province_id)
    return DATA.province[province_id].on_a_forest
end
---@param province_id province_id valid province id
---@param value boolean valid boolean
function DATA.province_set_on_a_forest(province_id, value)
    DATA.province[province_id].on_a_forest = value
end


local fat_province_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.province_get_name(t.id) end
        if (k == "r") then return DATA.province_get_r(t.id) end
        if (k == "g") then return DATA.province_get_g(t.id) end
        if (k == "b") then return DATA.province_get_b(t.id) end
        if (k == "is_land") then return DATA.province_get_is_land(t.id) end
        if (k == "province_id") then return DATA.province_get_province_id(t.id) end
        if (k == "size") then return DATA.province_get_size(t.id) end
        if (k == "hydration") then return DATA.province_get_hydration(t.id) end
        if (k == "movement_cost") then return DATA.province_get_movement_cost(t.id) end
        if (k == "center") then return DATA.province_get_center(t.id) end
        if (k == "infrastructure_needed") then return DATA.province_get_infrastructure_needed(t.id) end
        if (k == "infrastructure") then return DATA.province_get_infrastructure(t.id) end
        if (k == "infrastructure_investment") then return DATA.province_get_infrastructure_investment(t.id) end
        if (k == "local_wealth") then return DATA.province_get_local_wealth(t.id) end
        if (k == "trade_wealth") then return DATA.province_get_trade_wealth(t.id) end
        if (k == "local_income") then return DATA.province_get_local_income(t.id) end
        if (k == "local_building_upkeep") then return DATA.province_get_local_building_upkeep(t.id) end
        if (k == "foragers") then return DATA.province_get_foragers(t.id) end
        if (k == "foragers_water") then return DATA.province_get_foragers_water(t.id) end
        if (k == "foragers_limit") then return DATA.province_get_foragers_limit(t.id) end
        if (k == "mood") then return DATA.province_get_mood(t.id) end
        if (k == "on_a_river") then return DATA.province_get_on_a_river(t.id) end
        if (k == "on_a_forest") then return DATA.province_get_on_a_forest(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.province_set_name(t.id, v)
            return
        end
        if (k == "r") then
            DATA.province_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.province_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.province_set_b(t.id, v)
            return
        end
        if (k == "is_land") then
            DATA.province_set_is_land(t.id, v)
            return
        end
        if (k == "province_id") then
            DATA.province_set_province_id(t.id, v)
            return
        end
        if (k == "size") then
            DATA.province_set_size(t.id, v)
            return
        end
        if (k == "hydration") then
            DATA.province_set_hydration(t.id, v)
            return
        end
        if (k == "movement_cost") then
            DATA.province_set_movement_cost(t.id, v)
            return
        end
        if (k == "center") then
            DATA.province_set_center(t.id, v)
            return
        end
        if (k == "infrastructure_needed") then
            DATA.province_set_infrastructure_needed(t.id, v)
            return
        end
        if (k == "infrastructure") then
            DATA.province_set_infrastructure(t.id, v)
            return
        end
        if (k == "infrastructure_investment") then
            DATA.province_set_infrastructure_investment(t.id, v)
            return
        end
        if (k == "local_wealth") then
            DATA.province_set_local_wealth(t.id, v)
            return
        end
        if (k == "trade_wealth") then
            DATA.province_set_trade_wealth(t.id, v)
            return
        end
        if (k == "local_income") then
            DATA.province_set_local_income(t.id, v)
            return
        end
        if (k == "local_building_upkeep") then
            DATA.province_set_local_building_upkeep(t.id, v)
            return
        end
        if (k == "foragers") then
            DATA.province_set_foragers(t.id, v)
            return
        end
        if (k == "foragers_water") then
            DATA.province_set_foragers_water(t.id, v)
            return
        end
        if (k == "foragers_limit") then
            DATA.province_set_foragers_limit(t.id, v)
            return
        end
        if (k == "mood") then
            DATA.province_set_mood(t.id, v)
            return
        end
        if (k == "on_a_river") then
            DATA.province_set_on_a_river(t.id, v)
            return
        end
        if (k == "on_a_forest") then
            DATA.province_set_on_a_forest(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id province_id
---@return fat_province_id fat_id
function DATA.fatten_province(id)
    local result = {id = id}
    setmetatable(result, fat_province_id_metatable)    return result
end
----------army----------


---army: LSP types---

---Unique identificator for army entity
---@alias army_id number

---@class (exact) fat_army_id
---@field id army_id Unique army id
---@field destination province_id 

---@class struct_army
---@field destination province_id 


ffi.cdef[[
    typedef struct {
        uint32_t destination;
    } army;
void dcon_delete_army(int32_t j);
int32_t dcon_create_army();
void dcon_army_resize(uint32_t sz);
]]

---army: FFI arrays---
---@type nil
DATA.army_calloc = ffi.C.calloc(1, ffi.sizeof("army") * 5001)
---@type table<army_id, struct_army>
DATA.army = ffi.cast("army*", DATA.army_calloc)

---army: LUA bindings---

DATA.army_size = 5000
---@type table<army_id, boolean>
local army_indices_pool = ffi.new("bool[?]", 5000)
for i = 1, 4999 do
    army_indices_pool[i] = true 
end
---@type table<army_id, army_id>
DATA.army_indices_set = {}
function DATA.create_army()
    ---@type number
    local i = DCON.dcon_create_army() + 1
            DATA.army_indices_set[i] = i
    return i
end
function DATA.delete_army(i)
    do
        ---@type army_membership_id[]
        local to_delete = {}
        if DATA.get_army_membership_from_army(i) ~= nil then
            for _, value in ipairs(DATA.get_army_membership_from_army(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_army_membership(value)
        end
    end
    do
        local to_delete = DATA.get_realm_armies_from_army(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_realm_armies(to_delete)
        end
    end
    DATA.army_indices_set[i] = nil
    return DCON.dcon_delete_army(i - 1)
end
---@param func fun(item: army_id) 
function DATA.for_each_army(func)
    for _, item in pairs(DATA.army_indices_set) do
        func(item)
    end
end
---@param func fun(item: army_id):boolean 
---@return table<army_id, army_id> 
function DATA.filter_army(func)
    ---@type table<army_id, army_id> 
    local t = {}
    for _, item in pairs(DATA.army_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param army_id army_id valid army id
---@return province_id destination 
function DATA.army_get_destination(army_id)
    return DATA.army[army_id].destination
end
---@param army_id army_id valid army id
---@param value province_id valid province_id
function DATA.army_set_destination(army_id, value)
    DATA.army[army_id].destination = value
end


local fat_army_id_metatable = {
    __index = function (t,k)
        if (k == "destination") then return DATA.army_get_destination(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "destination") then
            DATA.army_set_destination(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id army_id
---@return fat_army_id fat_id
function DATA.fatten_army(id)
    local result = {id = id}
    setmetatable(result, fat_army_id_metatable)    return result
end
----------warband----------


---warband: LSP types---

---Unique identificator for warband entity
---@alias warband_id number

---@class (exact) fat_warband_id
---@field id warband_id Unique warband id
---@field name string 
---@field guard_of Realm? 
---@field status WARBAND_STATUS 
---@field idle_stance WARBAND_STANCE 
---@field current_free_time_ratio number How much of "idle" free time they are actually idle. Set by events.
---@field treasury number 
---@field total_upkeep number 
---@field predicted_upkeep number 
---@field supplies number 
---@field supplies_target_days number 
---@field morale number 

---@class struct_warband
---@field units_current table<unit_type_id, number> Current distribution of units in the warband
---@field units_target table<unit_type_id, number> Units to recruit
---@field status WARBAND_STATUS 
---@field idle_stance WARBAND_STANCE 
---@field current_free_time_ratio number How much of "idle" free time they are actually idle. Set by events.
---@field treasury number 
---@field total_upkeep number 
---@field predicted_upkeep number 
---@field supplies number 
---@field supplies_target_days number 
---@field morale number 


ffi.cdef[[
    typedef struct {
        float units_current[20];
        float units_target[20];
        uint8_t status;
        uint8_t idle_stance;
        float current_free_time_ratio;
        float treasury;
        float total_upkeep;
        float predicted_upkeep;
        float supplies;
        float supplies_target_days;
        float morale;
    } warband;
void dcon_delete_warband(int32_t j);
int32_t dcon_create_warband();
void dcon_warband_resize(uint32_t sz);
]]

---warband: FFI arrays---
---@type (string)[]
DATA.warband_name= {}
---@type (Realm?)[]
DATA.warband_guard_of= {}
---@type nil
DATA.warband_calloc = ffi.C.calloc(1, ffi.sizeof("warband") * 20001)
---@type table<warband_id, struct_warband>
DATA.warband = ffi.cast("warband*", DATA.warband_calloc)

---warband: LUA bindings---

DATA.warband_size = 20000
---@type table<warband_id, boolean>
local warband_indices_pool = ffi.new("bool[?]", 20000)
for i = 1, 19999 do
    warband_indices_pool[i] = true 
end
---@type table<warband_id, warband_id>
DATA.warband_indices_set = {}
function DATA.create_warband()
    ---@type number
    local i = DCON.dcon_create_warband() + 1
            DATA.warband_indices_set[i] = i
    return i
end
function DATA.delete_warband(i)
    do
        local to_delete = DATA.get_army_membership_from_member(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_army_membership(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_leader_from_warband(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_leader(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_recruiter_from_warband(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_recruiter(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_commander_from_warband(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_commander(to_delete)
        end
    end
    do
        local to_delete = DATA.get_warband_location_from_warband(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_warband_location(to_delete)
        end
    end
    do
        ---@type warband_unit_id[]
        local to_delete = {}
        if DATA.get_warband_unit_from_warband(i) ~= nil then
            for _, value in ipairs(DATA.get_warband_unit_from_warband(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_warband_unit(value)
        end
    end
    do
        local to_delete = DATA.get_realm_guard_from_guard(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_realm_guard(to_delete)
        end
    end
    DATA.warband_indices_set[i] = nil
    return DCON.dcon_delete_warband(i - 1)
end
---@param func fun(item: warband_id) 
function DATA.for_each_warband(func)
    for _, item in pairs(DATA.warband_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_id):boolean 
---@return table<warband_id, warband_id> 
function DATA.filter_warband(func)
    ---@type table<warband_id, warband_id> 
    local t = {}
    for _, item in pairs(DATA.warband_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_id warband_id valid warband id
---@return string name 
function DATA.warband_get_name(warband_id)
    return DATA.warband_name[warband_id]
end
---@param warband_id warband_id valid warband id
---@param value string valid string
function DATA.warband_set_name(warband_id, value)
    DATA.warband_name[warband_id] = value
end
---@param warband_id warband_id valid warband id
---@return Realm? guard_of 
function DATA.warband_get_guard_of(warband_id)
    return DATA.warband_guard_of[warband_id]
end
---@param warband_id warband_id valid warband id
---@param value Realm? valid Realm?
function DATA.warband_set_guard_of(warband_id, value)
    DATA.warband_guard_of[warband_id] = value
end
---@param warband_id warband_id valid warband id
---@param index unit_type_id valid
---@return number units_current Current distribution of units in the warband
function DATA.warband_get_units_current(warband_id, index)
    return DATA.warband[warband_id].units_current[index]
end
---@param warband_id warband_id valid warband id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.warband_set_units_current(warband_id, index, value)
    DATA.warband[warband_id].units_current[index] = value
end
---@param warband_id warband_id valid warband id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.warband_inc_units_current(warband_id, index, value)
    DATA.warband[warband_id].units_current[index] = DATA.warband[warband_id].units_current[index] + value
end
---@param warband_id warband_id valid warband id
---@param index unit_type_id valid
---@return number units_target Units to recruit
function DATA.warband_get_units_target(warband_id, index)
    return DATA.warband[warband_id].units_target[index]
end
---@param warband_id warband_id valid warband id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.warband_set_units_target(warband_id, index, value)
    DATA.warband[warband_id].units_target[index] = value
end
---@param warband_id warband_id valid warband id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.warband_inc_units_target(warband_id, index, value)
    DATA.warband[warband_id].units_target[index] = DATA.warband[warband_id].units_target[index] + value
end
---@param warband_id warband_id valid warband id
---@return WARBAND_STATUS status 
function DATA.warband_get_status(warband_id)
    return DATA.warband[warband_id].status
end
---@param warband_id warband_id valid warband id
---@param value WARBAND_STATUS valid WARBAND_STATUS
function DATA.warband_set_status(warband_id, value)
    DATA.warband[warband_id].status = value
end
---@param warband_id warband_id valid warband id
---@return WARBAND_STANCE idle_stance 
function DATA.warband_get_idle_stance(warband_id)
    return DATA.warband[warband_id].idle_stance
end
---@param warband_id warband_id valid warband id
---@param value WARBAND_STANCE valid WARBAND_STANCE
function DATA.warband_set_idle_stance(warband_id, value)
    DATA.warband[warband_id].idle_stance = value
end
---@param warband_id warband_id valid warband id
---@return number current_free_time_ratio How much of "idle" free time they are actually idle. Set by events.
function DATA.warband_get_current_free_time_ratio(warband_id)
    return DATA.warband[warband_id].current_free_time_ratio
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_set_current_free_time_ratio(warband_id, value)
    DATA.warband[warband_id].current_free_time_ratio = value
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_inc_current_free_time_ratio(warband_id, value)
    DATA.warband[warband_id].current_free_time_ratio = DATA.warband[warband_id].current_free_time_ratio + value
end
---@param warband_id warband_id valid warband id
---@return number treasury 
function DATA.warband_get_treasury(warband_id)
    return DATA.warband[warband_id].treasury
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_set_treasury(warband_id, value)
    DATA.warband[warband_id].treasury = value
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_inc_treasury(warband_id, value)
    DATA.warband[warband_id].treasury = DATA.warband[warband_id].treasury + value
end
---@param warband_id warband_id valid warband id
---@return number total_upkeep 
function DATA.warband_get_total_upkeep(warband_id)
    return DATA.warband[warband_id].total_upkeep
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_set_total_upkeep(warband_id, value)
    DATA.warband[warband_id].total_upkeep = value
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_inc_total_upkeep(warband_id, value)
    DATA.warband[warband_id].total_upkeep = DATA.warband[warband_id].total_upkeep + value
end
---@param warband_id warband_id valid warband id
---@return number predicted_upkeep 
function DATA.warband_get_predicted_upkeep(warband_id)
    return DATA.warband[warband_id].predicted_upkeep
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_set_predicted_upkeep(warband_id, value)
    DATA.warband[warband_id].predicted_upkeep = value
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_inc_predicted_upkeep(warband_id, value)
    DATA.warband[warband_id].predicted_upkeep = DATA.warband[warband_id].predicted_upkeep + value
end
---@param warband_id warband_id valid warband id
---@return number supplies 
function DATA.warband_get_supplies(warband_id)
    return DATA.warband[warband_id].supplies
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_set_supplies(warband_id, value)
    DATA.warband[warband_id].supplies = value
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_inc_supplies(warband_id, value)
    DATA.warband[warband_id].supplies = DATA.warband[warband_id].supplies + value
end
---@param warband_id warband_id valid warband id
---@return number supplies_target_days 
function DATA.warband_get_supplies_target_days(warband_id)
    return DATA.warband[warband_id].supplies_target_days
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_set_supplies_target_days(warband_id, value)
    DATA.warband[warband_id].supplies_target_days = value
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_inc_supplies_target_days(warband_id, value)
    DATA.warband[warband_id].supplies_target_days = DATA.warband[warband_id].supplies_target_days + value
end
---@param warband_id warband_id valid warband id
---@return number morale 
function DATA.warband_get_morale(warband_id)
    return DATA.warband[warband_id].morale
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_set_morale(warband_id, value)
    DATA.warband[warband_id].morale = value
end
---@param warband_id warband_id valid warband id
---@param value number valid number
function DATA.warband_inc_morale(warband_id, value)
    DATA.warband[warband_id].morale = DATA.warband[warband_id].morale + value
end


local fat_warband_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.warband_get_name(t.id) end
        if (k == "guard_of") then return DATA.warband_get_guard_of(t.id) end
        if (k == "status") then return DATA.warband_get_status(t.id) end
        if (k == "idle_stance") then return DATA.warband_get_idle_stance(t.id) end
        if (k == "current_free_time_ratio") then return DATA.warband_get_current_free_time_ratio(t.id) end
        if (k == "treasury") then return DATA.warband_get_treasury(t.id) end
        if (k == "total_upkeep") then return DATA.warband_get_total_upkeep(t.id) end
        if (k == "predicted_upkeep") then return DATA.warband_get_predicted_upkeep(t.id) end
        if (k == "supplies") then return DATA.warband_get_supplies(t.id) end
        if (k == "supplies_target_days") then return DATA.warband_get_supplies_target_days(t.id) end
        if (k == "morale") then return DATA.warband_get_morale(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.warband_set_name(t.id, v)
            return
        end
        if (k == "guard_of") then
            DATA.warband_set_guard_of(t.id, v)
            return
        end
        if (k == "status") then
            DATA.warband_set_status(t.id, v)
            return
        end
        if (k == "idle_stance") then
            DATA.warband_set_idle_stance(t.id, v)
            return
        end
        if (k == "current_free_time_ratio") then
            DATA.warband_set_current_free_time_ratio(t.id, v)
            return
        end
        if (k == "treasury") then
            DATA.warband_set_treasury(t.id, v)
            return
        end
        if (k == "total_upkeep") then
            DATA.warband_set_total_upkeep(t.id, v)
            return
        end
        if (k == "predicted_upkeep") then
            DATA.warband_set_predicted_upkeep(t.id, v)
            return
        end
        if (k == "supplies") then
            DATA.warband_set_supplies(t.id, v)
            return
        end
        if (k == "supplies_target_days") then
            DATA.warband_set_supplies_target_days(t.id, v)
            return
        end
        if (k == "morale") then
            DATA.warband_set_morale(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_id
---@return fat_warband_id fat_id
function DATA.fatten_warband(id)
    local result = {id = id}
    setmetatable(result, fat_warband_id_metatable)    return result
end
----------realm----------


---realm: LSP types---

---Unique identificator for realm entity
---@alias realm_id number

---@class (exact) fat_realm_id
---@field id realm_id Unique realm id
---@field exists boolean 
---@field name string 
---@field budget_change number 
---@field budget_saved_change number 
---@field budget_treasury number 
---@field budget_treasury_target number 
---@field budget_tax_target number 
---@field budget_tax_collected_this_year number 
---@field r number 
---@field g number 
---@field b number 
---@field primary_race race_id 
---@field primary_culture Culture 
---@field primary_faith Faith 
---@field capitol province_id 
---@field trading_right_cost number 
---@field building_right_cost number 
---@field trading_right_law TradingRightLaw 
---@field building_right_law BuildingRightLaw 
---@field quests_raid table<province_id,nil|number> reward for raid
---@field quests_explore table<province_id,nil|number> reward for exploration
---@field quests_patrol table<province_id,nil|number> reward for patrol
---@field patrols table<province_id,table<warband_id,warband_id>> 
---@field prepare_attack_flag boolean 
---@field known_provinces table<province_id,province_id> For terra incognita.
---@field coa_base_r number 
---@field coa_base_g number 
---@field coa_base_b number 
---@field coa_background_r number 
---@field coa_background_g number 
---@field coa_background_b number 
---@field coa_foreground_r number 
---@field coa_foreground_g number 
---@field coa_foreground_b number 
---@field coa_emblem_r number 
---@field coa_emblem_g number 
---@field coa_emblem_b number 
---@field coa_background_image number 
---@field coa_foreground_image number 
---@field coa_emblem_image number 
---@field expected_food_consumption number 

---@class struct_realm
---@field budget_change number 
---@field budget_saved_change number 
---@field budget_spending_by_category table<ECONOMY_REASON, number> 
---@field budget_income_by_category table<ECONOMY_REASON, number> 
---@field budget_treasury_change_by_category table<ECONOMY_REASON, number> 
---@field budget_treasury number 
---@field budget_treasury_target number 
---@field budget table<BUDGET_CATEGORY, struct_budget_per_category_data> 
---@field budget_tax_target number 
---@field budget_tax_collected_this_year number 
---@field r number 
---@field g number 
---@field b number 
---@field primary_race race_id 
---@field capitol province_id 
---@field trading_right_cost number 
---@field building_right_cost number 
---@field prepare_attack_flag boolean 
---@field coa_base_r number 
---@field coa_base_g number 
---@field coa_base_b number 
---@field coa_background_r number 
---@field coa_background_g number 
---@field coa_background_b number 
---@field coa_foreground_r number 
---@field coa_foreground_g number 
---@field coa_foreground_b number 
---@field coa_emblem_r number 
---@field coa_emblem_g number 
---@field coa_emblem_b number 
---@field coa_background_image number 
---@field coa_foreground_image number 
---@field coa_emblem_image number 
---@field resources table<trade_good_id, number> Currently stockpiled resources
---@field production table<trade_good_id, number> A "balance" of resource creation
---@field bought table<trade_good_id, number> 
---@field sold table<trade_good_id, number> 
---@field expected_food_consumption number 


ffi.cdef[[
    typedef struct {
        float budget_change;
        float budget_saved_change;
        float budget_spending_by_category[38];
        float budget_income_by_category[38];
        float budget_treasury_change_by_category[38];
        float budget_treasury;
        float budget_treasury_target;
        budget_per_category_data budget[7];
        float budget_tax_target;
        float budget_tax_collected_this_year;
        float r;
        float g;
        float b;
        uint32_t primary_race;
        uint32_t capitol;
        float trading_right_cost;
        float building_right_cost;
        bool prepare_attack_flag;
        float coa_base_r;
        float coa_base_g;
        float coa_base_b;
        float coa_background_r;
        float coa_background_g;
        float coa_background_b;
        float coa_foreground_r;
        float coa_foreground_g;
        float coa_foreground_b;
        float coa_emblem_r;
        float coa_emblem_g;
        float coa_emblem_b;
        uint32_t coa_background_image;
        uint32_t coa_foreground_image;
        uint32_t coa_emblem_image;
        float resources[100];
        float production[100];
        float bought[100];
        float sold[100];
        float expected_food_consumption;
    } realm;
void dcon_delete_realm(int32_t j);
int32_t dcon_create_realm();
void dcon_realm_resize(uint32_t sz);
]]

---realm: FFI arrays---
---@type (boolean)[]
DATA.realm_exists= {}
---@type (string)[]
DATA.realm_name= {}
---@type (Culture)[]
DATA.realm_primary_culture= {}
---@type (Faith)[]
DATA.realm_primary_faith= {}
---@type (TradingRightLaw)[]
DATA.realm_trading_right_law= {}
---@type (BuildingRightLaw)[]
DATA.realm_building_right_law= {}
---@type (table<province_id,nil|number>)[]
DATA.realm_quests_raid= {}
---@type (table<province_id,nil|number>)[]
DATA.realm_quests_explore= {}
---@type (table<province_id,nil|number>)[]
DATA.realm_quests_patrol= {}
---@type (table<province_id,table<warband_id,warband_id>>)[]
DATA.realm_patrols= {}
---@type (table<province_id,province_id>)[]
DATA.realm_known_provinces= {}
---@type nil
DATA.realm_calloc = ffi.C.calloc(1, ffi.sizeof("realm") * 15001)
---@type table<realm_id, struct_realm>
DATA.realm = ffi.cast("realm*", DATA.realm_calloc)

---realm: LUA bindings---

DATA.realm_size = 15000
---@type table<realm_id, boolean>
local realm_indices_pool = ffi.new("bool[?]", 15000)
for i = 1, 14999 do
    realm_indices_pool[i] = true 
end
---@type table<realm_id, realm_id>
DATA.realm_indices_set = {}
function DATA.create_realm()
    ---@type number
    local i = DCON.dcon_create_realm() + 1
            DATA.realm_indices_set[i] = i
    return i
end
function DATA.delete_realm(i)
    do
        ---@type realm_armies_id[]
        local to_delete = {}
        if DATA.get_realm_armies_from_realm(i) ~= nil then
            for _, value in ipairs(DATA.get_realm_armies_from_realm(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_realm_armies(value)
        end
    end
    do
        local to_delete = DATA.get_realm_guard_from_realm(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_realm_guard(to_delete)
        end
    end
    do
        local to_delete = DATA.get_realm_overseer_from_realm(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_realm_overseer(to_delete)
        end
    end
    do
        local to_delete = DATA.get_realm_leadership_from_realm(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_realm_leadership(to_delete)
        end
    end
    do
        ---@type realm_subject_relation_id[]
        local to_delete = {}
        if DATA.get_realm_subject_relation_from_overlord(i) ~= nil then
            for _, value in ipairs(DATA.get_realm_subject_relation_from_overlord(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_realm_subject_relation(value)
        end
    end
    do
        ---@type realm_subject_relation_id[]
        local to_delete = {}
        if DATA.get_realm_subject_relation_from_subject(i) ~= nil then
            for _, value in ipairs(DATA.get_realm_subject_relation_from_subject(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_realm_subject_relation(value)
        end
    end
    do
        ---@type tax_collector_id[]
        local to_delete = {}
        if DATA.get_tax_collector_from_realm(i) ~= nil then
            for _, value in ipairs(DATA.get_tax_collector_from_realm(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_tax_collector(value)
        end
    end
    do
        ---@type personal_rights_id[]
        local to_delete = {}
        if DATA.get_personal_rights_from_realm(i) ~= nil then
            for _, value in ipairs(DATA.get_personal_rights_from_realm(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_personal_rights(value)
        end
    end
    do
        ---@type realm_provinces_id[]
        local to_delete = {}
        if DATA.get_realm_provinces_from_realm(i) ~= nil then
            for _, value in ipairs(DATA.get_realm_provinces_from_realm(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_realm_provinces(value)
        end
    end
    do
        ---@type popularity_id[]
        local to_delete = {}
        if DATA.get_popularity_from_where(i) ~= nil then
            for _, value in ipairs(DATA.get_popularity_from_where(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_popularity(value)
        end
    end
    DATA.realm_indices_set[i] = nil
    return DCON.dcon_delete_realm(i - 1)
end
---@param func fun(item: realm_id) 
function DATA.for_each_realm(func)
    for _, item in pairs(DATA.realm_indices_set) do
        func(item)
    end
end
---@param func fun(item: realm_id):boolean 
---@return table<realm_id, realm_id> 
function DATA.filter_realm(func)
    ---@type table<realm_id, realm_id> 
    local t = {}
    for _, item in pairs(DATA.realm_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param realm_id realm_id valid realm id
---@return boolean exists 
function DATA.realm_get_exists(realm_id)
    return DATA.realm_exists[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value boolean valid boolean
function DATA.realm_set_exists(realm_id, value)
    DATA.realm_exists[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return string name 
function DATA.realm_get_name(realm_id)
    return DATA.realm_name[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value string valid string
function DATA.realm_set_name(realm_id, value)
    DATA.realm_name[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return number budget_change 
function DATA.realm_get_budget_change(realm_id)
    return DATA.realm[realm_id].budget_change
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_budget_change(realm_id, value)
    DATA.realm[realm_id].budget_change = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_budget_change(realm_id, value)
    DATA.realm[realm_id].budget_change = DATA.realm[realm_id].budget_change + value
end
---@param realm_id realm_id valid realm id
---@return number budget_saved_change 
function DATA.realm_get_budget_saved_change(realm_id)
    return DATA.realm[realm_id].budget_saved_change
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_budget_saved_change(realm_id, value)
    DATA.realm[realm_id].budget_saved_change = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_budget_saved_change(realm_id, value)
    DATA.realm[realm_id].budget_saved_change = DATA.realm[realm_id].budget_saved_change + value
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid
---@return number budget_spending_by_category 
function DATA.realm_get_budget_spending_by_category(realm_id, index)
    return DATA.realm[realm_id].budget_spending_by_category[index]
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid index
---@param value number valid number
function DATA.realm_set_budget_spending_by_category(realm_id, index, value)
    DATA.realm[realm_id].budget_spending_by_category[index] = value
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid index
---@param value number valid number
function DATA.realm_inc_budget_spending_by_category(realm_id, index, value)
    DATA.realm[realm_id].budget_spending_by_category[index] = DATA.realm[realm_id].budget_spending_by_category[index] + value
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid
---@return number budget_income_by_category 
function DATA.realm_get_budget_income_by_category(realm_id, index)
    return DATA.realm[realm_id].budget_income_by_category[index]
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid index
---@param value number valid number
function DATA.realm_set_budget_income_by_category(realm_id, index, value)
    DATA.realm[realm_id].budget_income_by_category[index] = value
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid index
---@param value number valid number
function DATA.realm_inc_budget_income_by_category(realm_id, index, value)
    DATA.realm[realm_id].budget_income_by_category[index] = DATA.realm[realm_id].budget_income_by_category[index] + value
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid
---@return number budget_treasury_change_by_category 
function DATA.realm_get_budget_treasury_change_by_category(realm_id, index)
    return DATA.realm[realm_id].budget_treasury_change_by_category[index]
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid index
---@param value number valid number
function DATA.realm_set_budget_treasury_change_by_category(realm_id, index, value)
    DATA.realm[realm_id].budget_treasury_change_by_category[index] = value
end
---@param realm_id realm_id valid realm id
---@param index ECONOMY_REASON valid index
---@param value number valid number
function DATA.realm_inc_budget_treasury_change_by_category(realm_id, index, value)
    DATA.realm[realm_id].budget_treasury_change_by_category[index] = DATA.realm[realm_id].budget_treasury_change_by_category[index] + value
end
---@param realm_id realm_id valid realm id
---@return number budget_treasury 
function DATA.realm_get_budget_treasury(realm_id)
    return DATA.realm[realm_id].budget_treasury
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_budget_treasury(realm_id, value)
    DATA.realm[realm_id].budget_treasury = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_budget_treasury(realm_id, value)
    DATA.realm[realm_id].budget_treasury = DATA.realm[realm_id].budget_treasury + value
end
---@param realm_id realm_id valid realm id
---@return number budget_treasury_target 
function DATA.realm_get_budget_treasury_target(realm_id)
    return DATA.realm[realm_id].budget_treasury_target
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_budget_treasury_target(realm_id, value)
    DATA.realm[realm_id].budget_treasury_target = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_budget_treasury_target(realm_id, value)
    DATA.realm[realm_id].budget_treasury_target = DATA.realm[realm_id].budget_treasury_target + value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid
---@return number budget 
function DATA.realm_get_budget_ratio(realm_id, index)
    return DATA.realm[realm_id].budget[index].ratio
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid
---@return number budget 
function DATA.realm_get_budget_budget(realm_id, index)
    return DATA.realm[realm_id].budget[index].budget
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid
---@return number budget 
function DATA.realm_get_budget_to_be_invested(realm_id, index)
    return DATA.realm[realm_id].budget[index].to_be_invested
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid
---@return number budget 
function DATA.realm_get_budget_target(realm_id, index)
    return DATA.realm[realm_id].budget[index].target
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_set_budget_ratio(realm_id, index, value)
    DATA.realm[realm_id].budget[index].ratio = value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_inc_budget_ratio(realm_id, index, value)
    DATA.realm[realm_id].budget[index].ratio = DATA.realm[realm_id].budget[index].ratio + value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_set_budget_budget(realm_id, index, value)
    DATA.realm[realm_id].budget[index].budget = value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_inc_budget_budget(realm_id, index, value)
    DATA.realm[realm_id].budget[index].budget = DATA.realm[realm_id].budget[index].budget + value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_set_budget_to_be_invested(realm_id, index, value)
    DATA.realm[realm_id].budget[index].to_be_invested = value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_inc_budget_to_be_invested(realm_id, index, value)
    DATA.realm[realm_id].budget[index].to_be_invested = DATA.realm[realm_id].budget[index].to_be_invested + value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_set_budget_target(realm_id, index, value)
    DATA.realm[realm_id].budget[index].target = value
end
---@param realm_id realm_id valid realm id
---@param index BUDGET_CATEGORY valid index
---@param value number valid number
function DATA.realm_inc_budget_target(realm_id, index, value)
    DATA.realm[realm_id].budget[index].target = DATA.realm[realm_id].budget[index].target + value
end
---@param realm_id realm_id valid realm id
---@return number budget_tax_target 
function DATA.realm_get_budget_tax_target(realm_id)
    return DATA.realm[realm_id].budget_tax_target
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_budget_tax_target(realm_id, value)
    DATA.realm[realm_id].budget_tax_target = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_budget_tax_target(realm_id, value)
    DATA.realm[realm_id].budget_tax_target = DATA.realm[realm_id].budget_tax_target + value
end
---@param realm_id realm_id valid realm id
---@return number budget_tax_collected_this_year 
function DATA.realm_get_budget_tax_collected_this_year(realm_id)
    return DATA.realm[realm_id].budget_tax_collected_this_year
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_budget_tax_collected_this_year(realm_id, value)
    DATA.realm[realm_id].budget_tax_collected_this_year = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_budget_tax_collected_this_year(realm_id, value)
    DATA.realm[realm_id].budget_tax_collected_this_year = DATA.realm[realm_id].budget_tax_collected_this_year + value
end
---@param realm_id realm_id valid realm id
---@return number r 
function DATA.realm_get_r(realm_id)
    return DATA.realm[realm_id].r
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_r(realm_id, value)
    DATA.realm[realm_id].r = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_r(realm_id, value)
    DATA.realm[realm_id].r = DATA.realm[realm_id].r + value
end
---@param realm_id realm_id valid realm id
---@return number g 
function DATA.realm_get_g(realm_id)
    return DATA.realm[realm_id].g
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_g(realm_id, value)
    DATA.realm[realm_id].g = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_g(realm_id, value)
    DATA.realm[realm_id].g = DATA.realm[realm_id].g + value
end
---@param realm_id realm_id valid realm id
---@return number b 
function DATA.realm_get_b(realm_id)
    return DATA.realm[realm_id].b
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_b(realm_id, value)
    DATA.realm[realm_id].b = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_b(realm_id, value)
    DATA.realm[realm_id].b = DATA.realm[realm_id].b + value
end
---@param realm_id realm_id valid realm id
---@return race_id primary_race 
function DATA.realm_get_primary_race(realm_id)
    return DATA.realm[realm_id].primary_race
end
---@param realm_id realm_id valid realm id
---@param value race_id valid race_id
function DATA.realm_set_primary_race(realm_id, value)
    DATA.realm[realm_id].primary_race = value
end
---@param realm_id realm_id valid realm id
---@return Culture primary_culture 
function DATA.realm_get_primary_culture(realm_id)
    return DATA.realm_primary_culture[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value Culture valid Culture
function DATA.realm_set_primary_culture(realm_id, value)
    DATA.realm_primary_culture[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return Faith primary_faith 
function DATA.realm_get_primary_faith(realm_id)
    return DATA.realm_primary_faith[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value Faith valid Faith
function DATA.realm_set_primary_faith(realm_id, value)
    DATA.realm_primary_faith[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return province_id capitol 
function DATA.realm_get_capitol(realm_id)
    return DATA.realm[realm_id].capitol
end
---@param realm_id realm_id valid realm id
---@param value province_id valid province_id
function DATA.realm_set_capitol(realm_id, value)
    DATA.realm[realm_id].capitol = value
end
---@param realm_id realm_id valid realm id
---@return number trading_right_cost 
function DATA.realm_get_trading_right_cost(realm_id)
    return DATA.realm[realm_id].trading_right_cost
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_trading_right_cost(realm_id, value)
    DATA.realm[realm_id].trading_right_cost = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_trading_right_cost(realm_id, value)
    DATA.realm[realm_id].trading_right_cost = DATA.realm[realm_id].trading_right_cost + value
end
---@param realm_id realm_id valid realm id
---@return number building_right_cost 
function DATA.realm_get_building_right_cost(realm_id)
    return DATA.realm[realm_id].building_right_cost
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_building_right_cost(realm_id, value)
    DATA.realm[realm_id].building_right_cost = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_building_right_cost(realm_id, value)
    DATA.realm[realm_id].building_right_cost = DATA.realm[realm_id].building_right_cost + value
end
---@param realm_id realm_id valid realm id
---@return TradingRightLaw trading_right_law 
function DATA.realm_get_trading_right_law(realm_id)
    return DATA.realm_trading_right_law[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value TradingRightLaw valid TradingRightLaw
function DATA.realm_set_trading_right_law(realm_id, value)
    DATA.realm_trading_right_law[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return BuildingRightLaw building_right_law 
function DATA.realm_get_building_right_law(realm_id)
    return DATA.realm_building_right_law[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value BuildingRightLaw valid BuildingRightLaw
function DATA.realm_set_building_right_law(realm_id, value)
    DATA.realm_building_right_law[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return table<province_id,nil|number> quests_raid reward for raid
function DATA.realm_get_quests_raid(realm_id)
    return DATA.realm_quests_raid[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value table<province_id,nil|number> valid table<province_id,nil|number>
function DATA.realm_set_quests_raid(realm_id, value)
    DATA.realm_quests_raid[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return table<province_id,nil|number> quests_explore reward for exploration
function DATA.realm_get_quests_explore(realm_id)
    return DATA.realm_quests_explore[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value table<province_id,nil|number> valid table<province_id,nil|number>
function DATA.realm_set_quests_explore(realm_id, value)
    DATA.realm_quests_explore[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return table<province_id,nil|number> quests_patrol reward for patrol
function DATA.realm_get_quests_patrol(realm_id)
    return DATA.realm_quests_patrol[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value table<province_id,nil|number> valid table<province_id,nil|number>
function DATA.realm_set_quests_patrol(realm_id, value)
    DATA.realm_quests_patrol[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return table<province_id,table<warband_id,warband_id>> patrols 
function DATA.realm_get_patrols(realm_id)
    return DATA.realm_patrols[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value table<province_id,table<warband_id,warband_id>> valid table<province_id,table<warband_id,warband_id>>
function DATA.realm_set_patrols(realm_id, value)
    DATA.realm_patrols[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return boolean prepare_attack_flag 
function DATA.realm_get_prepare_attack_flag(realm_id)
    return DATA.realm[realm_id].prepare_attack_flag
end
---@param realm_id realm_id valid realm id
---@param value boolean valid boolean
function DATA.realm_set_prepare_attack_flag(realm_id, value)
    DATA.realm[realm_id].prepare_attack_flag = value
end
---@param realm_id realm_id valid realm id
---@return table<province_id,province_id> known_provinces For terra incognita.
function DATA.realm_get_known_provinces(realm_id)
    return DATA.realm_known_provinces[realm_id]
end
---@param realm_id realm_id valid realm id
---@param value table<province_id,province_id> valid table<province_id,province_id>
function DATA.realm_set_known_provinces(realm_id, value)
    DATA.realm_known_provinces[realm_id] = value
end
---@param realm_id realm_id valid realm id
---@return number coa_base_r 
function DATA.realm_get_coa_base_r(realm_id)
    return DATA.realm[realm_id].coa_base_r
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_base_r(realm_id, value)
    DATA.realm[realm_id].coa_base_r = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_base_r(realm_id, value)
    DATA.realm[realm_id].coa_base_r = DATA.realm[realm_id].coa_base_r + value
end
---@param realm_id realm_id valid realm id
---@return number coa_base_g 
function DATA.realm_get_coa_base_g(realm_id)
    return DATA.realm[realm_id].coa_base_g
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_base_g(realm_id, value)
    DATA.realm[realm_id].coa_base_g = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_base_g(realm_id, value)
    DATA.realm[realm_id].coa_base_g = DATA.realm[realm_id].coa_base_g + value
end
---@param realm_id realm_id valid realm id
---@return number coa_base_b 
function DATA.realm_get_coa_base_b(realm_id)
    return DATA.realm[realm_id].coa_base_b
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_base_b(realm_id, value)
    DATA.realm[realm_id].coa_base_b = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_base_b(realm_id, value)
    DATA.realm[realm_id].coa_base_b = DATA.realm[realm_id].coa_base_b + value
end
---@param realm_id realm_id valid realm id
---@return number coa_background_r 
function DATA.realm_get_coa_background_r(realm_id)
    return DATA.realm[realm_id].coa_background_r
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_background_r(realm_id, value)
    DATA.realm[realm_id].coa_background_r = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_background_r(realm_id, value)
    DATA.realm[realm_id].coa_background_r = DATA.realm[realm_id].coa_background_r + value
end
---@param realm_id realm_id valid realm id
---@return number coa_background_g 
function DATA.realm_get_coa_background_g(realm_id)
    return DATA.realm[realm_id].coa_background_g
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_background_g(realm_id, value)
    DATA.realm[realm_id].coa_background_g = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_background_g(realm_id, value)
    DATA.realm[realm_id].coa_background_g = DATA.realm[realm_id].coa_background_g + value
end
---@param realm_id realm_id valid realm id
---@return number coa_background_b 
function DATA.realm_get_coa_background_b(realm_id)
    return DATA.realm[realm_id].coa_background_b
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_background_b(realm_id, value)
    DATA.realm[realm_id].coa_background_b = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_background_b(realm_id, value)
    DATA.realm[realm_id].coa_background_b = DATA.realm[realm_id].coa_background_b + value
end
---@param realm_id realm_id valid realm id
---@return number coa_foreground_r 
function DATA.realm_get_coa_foreground_r(realm_id)
    return DATA.realm[realm_id].coa_foreground_r
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_foreground_r(realm_id, value)
    DATA.realm[realm_id].coa_foreground_r = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_foreground_r(realm_id, value)
    DATA.realm[realm_id].coa_foreground_r = DATA.realm[realm_id].coa_foreground_r + value
end
---@param realm_id realm_id valid realm id
---@return number coa_foreground_g 
function DATA.realm_get_coa_foreground_g(realm_id)
    return DATA.realm[realm_id].coa_foreground_g
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_foreground_g(realm_id, value)
    DATA.realm[realm_id].coa_foreground_g = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_foreground_g(realm_id, value)
    DATA.realm[realm_id].coa_foreground_g = DATA.realm[realm_id].coa_foreground_g + value
end
---@param realm_id realm_id valid realm id
---@return number coa_foreground_b 
function DATA.realm_get_coa_foreground_b(realm_id)
    return DATA.realm[realm_id].coa_foreground_b
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_foreground_b(realm_id, value)
    DATA.realm[realm_id].coa_foreground_b = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_foreground_b(realm_id, value)
    DATA.realm[realm_id].coa_foreground_b = DATA.realm[realm_id].coa_foreground_b + value
end
---@param realm_id realm_id valid realm id
---@return number coa_emblem_r 
function DATA.realm_get_coa_emblem_r(realm_id)
    return DATA.realm[realm_id].coa_emblem_r
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_emblem_r(realm_id, value)
    DATA.realm[realm_id].coa_emblem_r = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_emblem_r(realm_id, value)
    DATA.realm[realm_id].coa_emblem_r = DATA.realm[realm_id].coa_emblem_r + value
end
---@param realm_id realm_id valid realm id
---@return number coa_emblem_g 
function DATA.realm_get_coa_emblem_g(realm_id)
    return DATA.realm[realm_id].coa_emblem_g
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_emblem_g(realm_id, value)
    DATA.realm[realm_id].coa_emblem_g = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_emblem_g(realm_id, value)
    DATA.realm[realm_id].coa_emblem_g = DATA.realm[realm_id].coa_emblem_g + value
end
---@param realm_id realm_id valid realm id
---@return number coa_emblem_b 
function DATA.realm_get_coa_emblem_b(realm_id)
    return DATA.realm[realm_id].coa_emblem_b
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_emblem_b(realm_id, value)
    DATA.realm[realm_id].coa_emblem_b = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_emblem_b(realm_id, value)
    DATA.realm[realm_id].coa_emblem_b = DATA.realm[realm_id].coa_emblem_b + value
end
---@param realm_id realm_id valid realm id
---@return number coa_background_image 
function DATA.realm_get_coa_background_image(realm_id)
    return DATA.realm[realm_id].coa_background_image
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_background_image(realm_id, value)
    DATA.realm[realm_id].coa_background_image = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_background_image(realm_id, value)
    DATA.realm[realm_id].coa_background_image = DATA.realm[realm_id].coa_background_image + value
end
---@param realm_id realm_id valid realm id
---@return number coa_foreground_image 
function DATA.realm_get_coa_foreground_image(realm_id)
    return DATA.realm[realm_id].coa_foreground_image
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_foreground_image(realm_id, value)
    DATA.realm[realm_id].coa_foreground_image = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_foreground_image(realm_id, value)
    DATA.realm[realm_id].coa_foreground_image = DATA.realm[realm_id].coa_foreground_image + value
end
---@param realm_id realm_id valid realm id
---@return number coa_emblem_image 
function DATA.realm_get_coa_emblem_image(realm_id)
    return DATA.realm[realm_id].coa_emblem_image
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_coa_emblem_image(realm_id, value)
    DATA.realm[realm_id].coa_emblem_image = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_coa_emblem_image(realm_id, value)
    DATA.realm[realm_id].coa_emblem_image = DATA.realm[realm_id].coa_emblem_image + value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid
---@return number resources Currently stockpiled resources
function DATA.realm_get_resources(realm_id, index)
    return DATA.realm[realm_id].resources[index]
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_set_resources(realm_id, index, value)
    DATA.realm[realm_id].resources[index] = value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_inc_resources(realm_id, index, value)
    DATA.realm[realm_id].resources[index] = DATA.realm[realm_id].resources[index] + value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid
---@return number production A "balance" of resource creation
function DATA.realm_get_production(realm_id, index)
    return DATA.realm[realm_id].production[index]
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_set_production(realm_id, index, value)
    DATA.realm[realm_id].production[index] = value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_inc_production(realm_id, index, value)
    DATA.realm[realm_id].production[index] = DATA.realm[realm_id].production[index] + value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid
---@return number bought 
function DATA.realm_get_bought(realm_id, index)
    return DATA.realm[realm_id].bought[index]
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_set_bought(realm_id, index, value)
    DATA.realm[realm_id].bought[index] = value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_inc_bought(realm_id, index, value)
    DATA.realm[realm_id].bought[index] = DATA.realm[realm_id].bought[index] + value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid
---@return number sold 
function DATA.realm_get_sold(realm_id, index)
    return DATA.realm[realm_id].sold[index]
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_set_sold(realm_id, index, value)
    DATA.realm[realm_id].sold[index] = value
end
---@param realm_id realm_id valid realm id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.realm_inc_sold(realm_id, index, value)
    DATA.realm[realm_id].sold[index] = DATA.realm[realm_id].sold[index] + value
end
---@param realm_id realm_id valid realm id
---@return number expected_food_consumption 
function DATA.realm_get_expected_food_consumption(realm_id)
    return DATA.realm[realm_id].expected_food_consumption
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_set_expected_food_consumption(realm_id, value)
    DATA.realm[realm_id].expected_food_consumption = value
end
---@param realm_id realm_id valid realm id
---@param value number valid number
function DATA.realm_inc_expected_food_consumption(realm_id, value)
    DATA.realm[realm_id].expected_food_consumption = DATA.realm[realm_id].expected_food_consumption + value
end


local fat_realm_id_metatable = {
    __index = function (t,k)
        if (k == "exists") then return DATA.realm_get_exists(t.id) end
        if (k == "name") then return DATA.realm_get_name(t.id) end
        if (k == "budget_change") then return DATA.realm_get_budget_change(t.id) end
        if (k == "budget_saved_change") then return DATA.realm_get_budget_saved_change(t.id) end
        if (k == "budget_treasury") then return DATA.realm_get_budget_treasury(t.id) end
        if (k == "budget_treasury_target") then return DATA.realm_get_budget_treasury_target(t.id) end
        if (k == "budget_tax_target") then return DATA.realm_get_budget_tax_target(t.id) end
        if (k == "budget_tax_collected_this_year") then return DATA.realm_get_budget_tax_collected_this_year(t.id) end
        if (k == "r") then return DATA.realm_get_r(t.id) end
        if (k == "g") then return DATA.realm_get_g(t.id) end
        if (k == "b") then return DATA.realm_get_b(t.id) end
        if (k == "primary_race") then return DATA.realm_get_primary_race(t.id) end
        if (k == "primary_culture") then return DATA.realm_get_primary_culture(t.id) end
        if (k == "primary_faith") then return DATA.realm_get_primary_faith(t.id) end
        if (k == "capitol") then return DATA.realm_get_capitol(t.id) end
        if (k == "trading_right_cost") then return DATA.realm_get_trading_right_cost(t.id) end
        if (k == "building_right_cost") then return DATA.realm_get_building_right_cost(t.id) end
        if (k == "trading_right_law") then return DATA.realm_get_trading_right_law(t.id) end
        if (k == "building_right_law") then return DATA.realm_get_building_right_law(t.id) end
        if (k == "quests_raid") then return DATA.realm_get_quests_raid(t.id) end
        if (k == "quests_explore") then return DATA.realm_get_quests_explore(t.id) end
        if (k == "quests_patrol") then return DATA.realm_get_quests_patrol(t.id) end
        if (k == "patrols") then return DATA.realm_get_patrols(t.id) end
        if (k == "prepare_attack_flag") then return DATA.realm_get_prepare_attack_flag(t.id) end
        if (k == "known_provinces") then return DATA.realm_get_known_provinces(t.id) end
        if (k == "coa_base_r") then return DATA.realm_get_coa_base_r(t.id) end
        if (k == "coa_base_g") then return DATA.realm_get_coa_base_g(t.id) end
        if (k == "coa_base_b") then return DATA.realm_get_coa_base_b(t.id) end
        if (k == "coa_background_r") then return DATA.realm_get_coa_background_r(t.id) end
        if (k == "coa_background_g") then return DATA.realm_get_coa_background_g(t.id) end
        if (k == "coa_background_b") then return DATA.realm_get_coa_background_b(t.id) end
        if (k == "coa_foreground_r") then return DATA.realm_get_coa_foreground_r(t.id) end
        if (k == "coa_foreground_g") then return DATA.realm_get_coa_foreground_g(t.id) end
        if (k == "coa_foreground_b") then return DATA.realm_get_coa_foreground_b(t.id) end
        if (k == "coa_emblem_r") then return DATA.realm_get_coa_emblem_r(t.id) end
        if (k == "coa_emblem_g") then return DATA.realm_get_coa_emblem_g(t.id) end
        if (k == "coa_emblem_b") then return DATA.realm_get_coa_emblem_b(t.id) end
        if (k == "coa_background_image") then return DATA.realm_get_coa_background_image(t.id) end
        if (k == "coa_foreground_image") then return DATA.realm_get_coa_foreground_image(t.id) end
        if (k == "coa_emblem_image") then return DATA.realm_get_coa_emblem_image(t.id) end
        if (k == "expected_food_consumption") then return DATA.realm_get_expected_food_consumption(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "exists") then
            DATA.realm_set_exists(t.id, v)
            return
        end
        if (k == "name") then
            DATA.realm_set_name(t.id, v)
            return
        end
        if (k == "budget_change") then
            DATA.realm_set_budget_change(t.id, v)
            return
        end
        if (k == "budget_saved_change") then
            DATA.realm_set_budget_saved_change(t.id, v)
            return
        end
        if (k == "budget_treasury") then
            DATA.realm_set_budget_treasury(t.id, v)
            return
        end
        if (k == "budget_treasury_target") then
            DATA.realm_set_budget_treasury_target(t.id, v)
            return
        end
        if (k == "budget_tax_target") then
            DATA.realm_set_budget_tax_target(t.id, v)
            return
        end
        if (k == "budget_tax_collected_this_year") then
            DATA.realm_set_budget_tax_collected_this_year(t.id, v)
            return
        end
        if (k == "r") then
            DATA.realm_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.realm_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.realm_set_b(t.id, v)
            return
        end
        if (k == "primary_race") then
            DATA.realm_set_primary_race(t.id, v)
            return
        end
        if (k == "primary_culture") then
            DATA.realm_set_primary_culture(t.id, v)
            return
        end
        if (k == "primary_faith") then
            DATA.realm_set_primary_faith(t.id, v)
            return
        end
        if (k == "capitol") then
            DATA.realm_set_capitol(t.id, v)
            return
        end
        if (k == "trading_right_cost") then
            DATA.realm_set_trading_right_cost(t.id, v)
            return
        end
        if (k == "building_right_cost") then
            DATA.realm_set_building_right_cost(t.id, v)
            return
        end
        if (k == "trading_right_law") then
            DATA.realm_set_trading_right_law(t.id, v)
            return
        end
        if (k == "building_right_law") then
            DATA.realm_set_building_right_law(t.id, v)
            return
        end
        if (k == "quests_raid") then
            DATA.realm_set_quests_raid(t.id, v)
            return
        end
        if (k == "quests_explore") then
            DATA.realm_set_quests_explore(t.id, v)
            return
        end
        if (k == "quests_patrol") then
            DATA.realm_set_quests_patrol(t.id, v)
            return
        end
        if (k == "patrols") then
            DATA.realm_set_patrols(t.id, v)
            return
        end
        if (k == "prepare_attack_flag") then
            DATA.realm_set_prepare_attack_flag(t.id, v)
            return
        end
        if (k == "known_provinces") then
            DATA.realm_set_known_provinces(t.id, v)
            return
        end
        if (k == "coa_base_r") then
            DATA.realm_set_coa_base_r(t.id, v)
            return
        end
        if (k == "coa_base_g") then
            DATA.realm_set_coa_base_g(t.id, v)
            return
        end
        if (k == "coa_base_b") then
            DATA.realm_set_coa_base_b(t.id, v)
            return
        end
        if (k == "coa_background_r") then
            DATA.realm_set_coa_background_r(t.id, v)
            return
        end
        if (k == "coa_background_g") then
            DATA.realm_set_coa_background_g(t.id, v)
            return
        end
        if (k == "coa_background_b") then
            DATA.realm_set_coa_background_b(t.id, v)
            return
        end
        if (k == "coa_foreground_r") then
            DATA.realm_set_coa_foreground_r(t.id, v)
            return
        end
        if (k == "coa_foreground_g") then
            DATA.realm_set_coa_foreground_g(t.id, v)
            return
        end
        if (k == "coa_foreground_b") then
            DATA.realm_set_coa_foreground_b(t.id, v)
            return
        end
        if (k == "coa_emblem_r") then
            DATA.realm_set_coa_emblem_r(t.id, v)
            return
        end
        if (k == "coa_emblem_g") then
            DATA.realm_set_coa_emblem_g(t.id, v)
            return
        end
        if (k == "coa_emblem_b") then
            DATA.realm_set_coa_emblem_b(t.id, v)
            return
        end
        if (k == "coa_background_image") then
            DATA.realm_set_coa_background_image(t.id, v)
            return
        end
        if (k == "coa_foreground_image") then
            DATA.realm_set_coa_foreground_image(t.id, v)
            return
        end
        if (k == "coa_emblem_image") then
            DATA.realm_set_coa_emblem_image(t.id, v)
            return
        end
        if (k == "expected_food_consumption") then
            DATA.realm_set_expected_food_consumption(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id realm_id
---@return fat_realm_id fat_id
function DATA.fatten_realm(id)
    local result = {id = id}
    setmetatable(result, fat_realm_id_metatable)    return result
end
----------negotiation----------


---negotiation: LSP types---

---Unique identificator for negotiation entity
---@alias negotiation_id number

---@class (exact) fat_negotiation_id
---@field id negotiation_id Unique negotiation id
---@field initiator pop_id 
---@field target pop_id 

---@class struct_negotiation
---@field initiator pop_id 
---@field target pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t initiator;
        uint32_t target;
    } negotiation;
void dcon_delete_negotiation(int32_t j);
int32_t dcon_create_negotiation();
void dcon_negotiation_resize(uint32_t sz);
]]

---negotiation: FFI arrays---
---@type nil
DATA.negotiation_calloc = ffi.C.calloc(1, ffi.sizeof("negotiation") * 2501)
---@type table<negotiation_id, struct_negotiation>
DATA.negotiation = ffi.cast("negotiation*", DATA.negotiation_calloc)
---@type table<pop_id, negotiation_id[]>>
DATA.negotiation_from_initiator= {}
for i = 1, 2500 do
    DATA.negotiation_from_initiator[i] = {}
end
---@type table<pop_id, negotiation_id[]>>
DATA.negotiation_from_target= {}
for i = 1, 2500 do
    DATA.negotiation_from_target[i] = {}
end

---negotiation: LUA bindings---

DATA.negotiation_size = 2500
---@type table<negotiation_id, boolean>
local negotiation_indices_pool = ffi.new("bool[?]", 2500)
for i = 1, 2499 do
    negotiation_indices_pool[i] = true 
end
---@type table<negotiation_id, negotiation_id>
DATA.negotiation_indices_set = {}
function DATA.create_negotiation()
    ---@type number
    local i = DCON.dcon_create_negotiation() + 1
            DATA.negotiation_indices_set[i] = i
    return i
end
function DATA.delete_negotiation(i)
    do
        local old_value = DATA.negotiation[i].initiator
        __REMOVE_KEY_NEGOTIATION_INITIATOR(i, old_value)
    end
    do
        local old_value = DATA.negotiation[i].target
        __REMOVE_KEY_NEGOTIATION_TARGET(i, old_value)
    end
    DATA.negotiation_indices_set[i] = nil
    return DCON.dcon_delete_negotiation(i - 1)
end
---@param func fun(item: negotiation_id) 
function DATA.for_each_negotiation(func)
    for _, item in pairs(DATA.negotiation_indices_set) do
        func(item)
    end
end
---@param func fun(item: negotiation_id):boolean 
---@return table<negotiation_id, negotiation_id> 
function DATA.filter_negotiation(func)
    ---@type table<negotiation_id, negotiation_id> 
    local t = {}
    for _, item in pairs(DATA.negotiation_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param negotiation_id negotiation_id valid negotiation id
---@return pop_id initiator 
function DATA.negotiation_get_initiator(negotiation_id)
    return DATA.negotiation[negotiation_id].initiator
end
---@param initiator pop_id valid pop_id
---@return negotiation_id[] An array of negotiation 
function DATA.get_negotiation_from_initiator(initiator)
    return DATA.negotiation_from_initiator[initiator]
end
---@param initiator pop_id valid pop_id
---@param func fun(item: negotiation_id) valid pop_id
function DATA.for_each_negotiation_from_initiator(initiator, func)
    if DATA.negotiation_from_initiator[initiator] == nil then return end
    for _, item in pairs(DATA.negotiation_from_initiator[initiator]) do func(item) end
end
---@param initiator pop_id valid pop_id
---@param func fun(item: negotiation_id):boolean 
---@return table<negotiation_id, negotiation_id> 
function DATA.filter_array_negotiation_from_initiator(initiator, func)
    ---@type table<negotiation_id, negotiation_id> 
    local t = {}
    for _, item in pairs(DATA.negotiation_from_initiator[initiator]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param initiator pop_id valid pop_id
---@param func fun(item: negotiation_id):boolean 
---@return table<negotiation_id, negotiation_id> 
function DATA.filter_negotiation_from_initiator(initiator, func)
    ---@type table<negotiation_id, negotiation_id> 
    local t = {}
    for _, item in pairs(DATA.negotiation_from_initiator[initiator]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param negotiation_id negotiation_id valid negotiation id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_NEGOTIATION_INITIATOR(negotiation_id, old_value)
    local found_key = nil
    if DATA.negotiation_from_initiator[old_value] == nil then
        DATA.negotiation_from_initiator[old_value] = {}
        return
    end
    for key, value in pairs(DATA.negotiation_from_initiator[old_value]) do
        if value == negotiation_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.negotiation_from_initiator[old_value], found_key)
    end
end
---@param negotiation_id negotiation_id valid negotiation id
---@param value pop_id valid pop_id
function DATA.negotiation_set_initiator(negotiation_id, value)
    local old_value = DATA.negotiation[negotiation_id].initiator
    DATA.negotiation[negotiation_id].initiator = value
    __REMOVE_KEY_NEGOTIATION_INITIATOR(negotiation_id, old_value)
    if DATA.negotiation_from_initiator[value] == nil then DATA.negotiation_from_initiator[value] = {} end
    table.insert(DATA.negotiation_from_initiator[value], negotiation_id)
end
---@param negotiation_id negotiation_id valid negotiation id
---@return pop_id target 
function DATA.negotiation_get_target(negotiation_id)
    return DATA.negotiation[negotiation_id].target
end
---@param target pop_id valid pop_id
---@return negotiation_id[] An array of negotiation 
function DATA.get_negotiation_from_target(target)
    return DATA.negotiation_from_target[target]
end
---@param target pop_id valid pop_id
---@param func fun(item: negotiation_id) valid pop_id
function DATA.for_each_negotiation_from_target(target, func)
    if DATA.negotiation_from_target[target] == nil then return end
    for _, item in pairs(DATA.negotiation_from_target[target]) do func(item) end
end
---@param target pop_id valid pop_id
---@param func fun(item: negotiation_id):boolean 
---@return table<negotiation_id, negotiation_id> 
function DATA.filter_array_negotiation_from_target(target, func)
    ---@type table<negotiation_id, negotiation_id> 
    local t = {}
    for _, item in pairs(DATA.negotiation_from_target[target]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param target pop_id valid pop_id
---@param func fun(item: negotiation_id):boolean 
---@return table<negotiation_id, negotiation_id> 
function DATA.filter_negotiation_from_target(target, func)
    ---@type table<negotiation_id, negotiation_id> 
    local t = {}
    for _, item in pairs(DATA.negotiation_from_target[target]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param negotiation_id negotiation_id valid negotiation id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_NEGOTIATION_TARGET(negotiation_id, old_value)
    local found_key = nil
    if DATA.negotiation_from_target[old_value] == nil then
        DATA.negotiation_from_target[old_value] = {}
        return
    end
    for key, value in pairs(DATA.negotiation_from_target[old_value]) do
        if value == negotiation_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.negotiation_from_target[old_value], found_key)
    end
end
---@param negotiation_id negotiation_id valid negotiation id
---@param value pop_id valid pop_id
function DATA.negotiation_set_target(negotiation_id, value)
    local old_value = DATA.negotiation[negotiation_id].target
    DATA.negotiation[negotiation_id].target = value
    __REMOVE_KEY_NEGOTIATION_TARGET(negotiation_id, old_value)
    if DATA.negotiation_from_target[value] == nil then DATA.negotiation_from_target[value] = {} end
    table.insert(DATA.negotiation_from_target[value], negotiation_id)
end


local fat_negotiation_id_metatable = {
    __index = function (t,k)
        if (k == "initiator") then return DATA.negotiation_get_initiator(t.id) end
        if (k == "target") then return DATA.negotiation_get_target(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "initiator") then
            DATA.negotiation_set_initiator(t.id, v)
            return
        end
        if (k == "target") then
            DATA.negotiation_set_target(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id negotiation_id
---@return fat_negotiation_id fat_id
function DATA.fatten_negotiation(id)
    local result = {id = id}
    setmetatable(result, fat_negotiation_id_metatable)    return result
end
----------building----------


---building: LSP types---

---Unique identificator for building entity
---@alias building_id number

---@class (exact) fat_building_id
---@field id building_id Unique building id
---@field type building_type_id 
---@field subsidy number 
---@field subsidy_last number 
---@field income_mean number 
---@field last_income number 
---@field last_donation_to_owner number 
---@field unused number 
---@field work_ratio number 

---@class struct_building
---@field type building_type_id 
---@field spent_on_inputs table<number, struct_trade_good_container> 
---@field earn_from_outputs table<number, struct_trade_good_container> 
---@field amount_of_inputs table<number, struct_trade_good_container> 
---@field amount_of_outputs table<number, struct_trade_good_container> 


ffi.cdef[[
    typedef struct {
        uint32_t type;
        trade_good_container spent_on_inputs[8];
        trade_good_container earn_from_outputs[8];
        trade_good_container amount_of_inputs[8];
        trade_good_container amount_of_outputs[8];
    } building;
void dcon_delete_building(int32_t j);
int32_t dcon_create_building();
void dcon_building_resize(uint32_t sz);
]]

---building: FFI arrays---
---@type (number)[]
DATA.building_subsidy= {}
---@type (number)[]
DATA.building_subsidy_last= {}
---@type (number)[]
DATA.building_income_mean= {}
---@type (number)[]
DATA.building_last_income= {}
---@type (number)[]
DATA.building_last_donation_to_owner= {}
---@type (number)[]
DATA.building_unused= {}
---@type (number)[]
DATA.building_work_ratio= {}
---@type nil
DATA.building_calloc = ffi.C.calloc(1, ffi.sizeof("building") * 200001)
---@type table<building_id, struct_building>
DATA.building = ffi.cast("building*", DATA.building_calloc)

---building: LUA bindings---

DATA.building_size = 200000
---@type table<building_id, boolean>
local building_indices_pool = ffi.new("bool[?]", 200000)
for i = 1, 199999 do
    building_indices_pool[i] = true 
end
---@type table<building_id, building_id>
DATA.building_indices_set = {}
function DATA.create_building()
    ---@type number
    local i = DCON.dcon_create_building() + 1
            DATA.building_indices_set[i] = i
    return i
end
function DATA.delete_building(i)
    do
        local to_delete = DATA.get_ownership_from_building(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_ownership(to_delete)
        end
    end
    do
        ---@type employment_id[]
        local to_delete = {}
        if DATA.get_employment_from_building(i) ~= nil then
            for _, value in ipairs(DATA.get_employment_from_building(i)) do
                table.insert(to_delete, value)
            end
        end
        for _, value in ipairs(to_delete) do
            DATA.delete_employment(value)
        end
    end
    do
        local to_delete = DATA.get_building_location_from_building(i)
        if to_delete ~= INVALID_ID then
            DATA.delete_building_location(to_delete)
        end
    end
    DATA.building_indices_set[i] = nil
    return DCON.dcon_delete_building(i - 1)
end
---@param func fun(item: building_id) 
function DATA.for_each_building(func)
    for _, item in pairs(DATA.building_indices_set) do
        func(item)
    end
end
---@param func fun(item: building_id):boolean 
---@return table<building_id, building_id> 
function DATA.filter_building(func)
    ---@type table<building_id, building_id> 
    local t = {}
    for _, item in pairs(DATA.building_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param building_id building_id valid building id
---@return building_type_id type 
function DATA.building_get_type(building_id)
    return DATA.building[building_id].type
end
---@param building_id building_id valid building id
---@param value building_type_id valid building_type_id
function DATA.building_set_type(building_id, value)
    DATA.building[building_id].type = value
end
---@param building_id building_id valid building id
---@return number subsidy 
function DATA.building_get_subsidy(building_id)
    return DATA.building_subsidy[building_id]
end
---@param building_id building_id valid building id
---@param value number valid number
function DATA.building_set_subsidy(building_id, value)
    DATA.building_subsidy[building_id] = value
end
---@param building_id building_id valid building id
---@return number subsidy_last 
function DATA.building_get_subsidy_last(building_id)
    return DATA.building_subsidy_last[building_id]
end
---@param building_id building_id valid building id
---@param value number valid number
function DATA.building_set_subsidy_last(building_id, value)
    DATA.building_subsidy_last[building_id] = value
end
---@param building_id building_id valid building id
---@return number income_mean 
function DATA.building_get_income_mean(building_id)
    return DATA.building_income_mean[building_id]
end
---@param building_id building_id valid building id
---@param value number valid number
function DATA.building_set_income_mean(building_id, value)
    DATA.building_income_mean[building_id] = value
end
---@param building_id building_id valid building id
---@return number last_income 
function DATA.building_get_last_income(building_id)
    return DATA.building_last_income[building_id]
end
---@param building_id building_id valid building id
---@param value number valid number
function DATA.building_set_last_income(building_id, value)
    DATA.building_last_income[building_id] = value
end
---@param building_id building_id valid building id
---@return number last_donation_to_owner 
function DATA.building_get_last_donation_to_owner(building_id)
    return DATA.building_last_donation_to_owner[building_id]
end
---@param building_id building_id valid building id
---@param value number valid number
function DATA.building_set_last_donation_to_owner(building_id, value)
    DATA.building_last_donation_to_owner[building_id] = value
end
---@param building_id building_id valid building id
---@return number unused 
function DATA.building_get_unused(building_id)
    return DATA.building_unused[building_id]
end
---@param building_id building_id valid building id
---@param value number valid number
function DATA.building_set_unused(building_id, value)
    DATA.building_unused[building_id] = value
end
---@param building_id building_id valid building id
---@return number work_ratio 
function DATA.building_get_work_ratio(building_id)
    return DATA.building_work_ratio[building_id]
end
---@param building_id building_id valid building id
---@param value number valid number
function DATA.building_set_work_ratio(building_id, value)
    DATA.building_work_ratio[building_id] = value
end
---@param building_id building_id valid building id
---@param index number valid
---@return trade_good_id spent_on_inputs 
function DATA.building_get_spent_on_inputs_good(building_id, index)
    return DATA.building[building_id].spent_on_inputs[index].good
end
---@param building_id building_id valid building id
---@param index number valid
---@return number spent_on_inputs 
function DATA.building_get_spent_on_inputs_amount(building_id, index)
    return DATA.building[building_id].spent_on_inputs[index].amount
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.building_set_spent_on_inputs_good(building_id, index, value)
    DATA.building[building_id].spent_on_inputs[index].good = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_set_spent_on_inputs_amount(building_id, index, value)
    DATA.building[building_id].spent_on_inputs[index].amount = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_inc_spent_on_inputs_amount(building_id, index, value)
    DATA.building[building_id].spent_on_inputs[index].amount = DATA.building[building_id].spent_on_inputs[index].amount + value
end
---@param building_id building_id valid building id
---@param index number valid
---@return trade_good_id earn_from_outputs 
function DATA.building_get_earn_from_outputs_good(building_id, index)
    return DATA.building[building_id].earn_from_outputs[index].good
end
---@param building_id building_id valid building id
---@param index number valid
---@return number earn_from_outputs 
function DATA.building_get_earn_from_outputs_amount(building_id, index)
    return DATA.building[building_id].earn_from_outputs[index].amount
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.building_set_earn_from_outputs_good(building_id, index, value)
    DATA.building[building_id].earn_from_outputs[index].good = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_set_earn_from_outputs_amount(building_id, index, value)
    DATA.building[building_id].earn_from_outputs[index].amount = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_inc_earn_from_outputs_amount(building_id, index, value)
    DATA.building[building_id].earn_from_outputs[index].amount = DATA.building[building_id].earn_from_outputs[index].amount + value
end
---@param building_id building_id valid building id
---@param index number valid
---@return trade_good_id amount_of_inputs 
function DATA.building_get_amount_of_inputs_good(building_id, index)
    return DATA.building[building_id].amount_of_inputs[index].good
end
---@param building_id building_id valid building id
---@param index number valid
---@return number amount_of_inputs 
function DATA.building_get_amount_of_inputs_amount(building_id, index)
    return DATA.building[building_id].amount_of_inputs[index].amount
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.building_set_amount_of_inputs_good(building_id, index, value)
    DATA.building[building_id].amount_of_inputs[index].good = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_set_amount_of_inputs_amount(building_id, index, value)
    DATA.building[building_id].amount_of_inputs[index].amount = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_inc_amount_of_inputs_amount(building_id, index, value)
    DATA.building[building_id].amount_of_inputs[index].amount = DATA.building[building_id].amount_of_inputs[index].amount + value
end
---@param building_id building_id valid building id
---@param index number valid
---@return trade_good_id amount_of_outputs 
function DATA.building_get_amount_of_outputs_good(building_id, index)
    return DATA.building[building_id].amount_of_outputs[index].good
end
---@param building_id building_id valid building id
---@param index number valid
---@return number amount_of_outputs 
function DATA.building_get_amount_of_outputs_amount(building_id, index)
    return DATA.building[building_id].amount_of_outputs[index].amount
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.building_set_amount_of_outputs_good(building_id, index, value)
    DATA.building[building_id].amount_of_outputs[index].good = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_set_amount_of_outputs_amount(building_id, index, value)
    DATA.building[building_id].amount_of_outputs[index].amount = value
end
---@param building_id building_id valid building id
---@param index number valid index
---@param value number valid number
function DATA.building_inc_amount_of_outputs_amount(building_id, index, value)
    DATA.building[building_id].amount_of_outputs[index].amount = DATA.building[building_id].amount_of_outputs[index].amount + value
end


local fat_building_id_metatable = {
    __index = function (t,k)
        if (k == "type") then return DATA.building_get_type(t.id) end
        if (k == "subsidy") then return DATA.building_get_subsidy(t.id) end
        if (k == "subsidy_last") then return DATA.building_get_subsidy_last(t.id) end
        if (k == "income_mean") then return DATA.building_get_income_mean(t.id) end
        if (k == "last_income") then return DATA.building_get_last_income(t.id) end
        if (k == "last_donation_to_owner") then return DATA.building_get_last_donation_to_owner(t.id) end
        if (k == "unused") then return DATA.building_get_unused(t.id) end
        if (k == "work_ratio") then return DATA.building_get_work_ratio(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "type") then
            DATA.building_set_type(t.id, v)
            return
        end
        if (k == "subsidy") then
            DATA.building_set_subsidy(t.id, v)
            return
        end
        if (k == "subsidy_last") then
            DATA.building_set_subsidy_last(t.id, v)
            return
        end
        if (k == "income_mean") then
            DATA.building_set_income_mean(t.id, v)
            return
        end
        if (k == "last_income") then
            DATA.building_set_last_income(t.id, v)
            return
        end
        if (k == "last_donation_to_owner") then
            DATA.building_set_last_donation_to_owner(t.id, v)
            return
        end
        if (k == "unused") then
            DATA.building_set_unused(t.id, v)
            return
        end
        if (k == "work_ratio") then
            DATA.building_set_work_ratio(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id building_id
---@return fat_building_id fat_id
function DATA.fatten_building(id)
    local result = {id = id}
    setmetatable(result, fat_building_id_metatable)    return result
end
----------ownership----------


---ownership: LSP types---

---Unique identificator for ownership entity
---@alias ownership_id number

---@class (exact) fat_ownership_id
---@field id ownership_id Unique ownership id
---@field building building_id 
---@field owner pop_id 

---@class struct_ownership
---@field building building_id 
---@field owner pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t building;
        uint32_t owner;
    } ownership;
void dcon_delete_ownership(int32_t j);
int32_t dcon_create_ownership();
void dcon_ownership_resize(uint32_t sz);
]]

---ownership: FFI arrays---
---@type nil
DATA.ownership_calloc = ffi.C.calloc(1, ffi.sizeof("ownership") * 200001)
---@type table<ownership_id, struct_ownership>
DATA.ownership = ffi.cast("ownership*", DATA.ownership_calloc)
---@type table<building_id, ownership_id>
DATA.ownership_from_building= {}
---@type table<pop_id, ownership_id[]>>
DATA.ownership_from_owner= {}
for i = 1, 200000 do
    DATA.ownership_from_owner[i] = {}
end

---ownership: LUA bindings---

DATA.ownership_size = 200000
---@type table<ownership_id, boolean>
local ownership_indices_pool = ffi.new("bool[?]", 200000)
for i = 1, 199999 do
    ownership_indices_pool[i] = true 
end
---@type table<ownership_id, ownership_id>
DATA.ownership_indices_set = {}
function DATA.create_ownership()
    ---@type number
    local i = DCON.dcon_create_ownership() + 1
            DATA.ownership_indices_set[i] = i
    return i
end
function DATA.delete_ownership(i)
    do
        local old_value = DATA.ownership[i].building
        __REMOVE_KEY_OWNERSHIP_BUILDING(old_value)
    end
    do
        local old_value = DATA.ownership[i].owner
        __REMOVE_KEY_OWNERSHIP_OWNER(i, old_value)
    end
    DATA.ownership_indices_set[i] = nil
    return DCON.dcon_delete_ownership(i - 1)
end
---@param func fun(item: ownership_id) 
function DATA.for_each_ownership(func)
    for _, item in pairs(DATA.ownership_indices_set) do
        func(item)
    end
end
---@param func fun(item: ownership_id):boolean 
---@return table<ownership_id, ownership_id> 
function DATA.filter_ownership(func)
    ---@type table<ownership_id, ownership_id> 
    local t = {}
    for _, item in pairs(DATA.ownership_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param ownership_id ownership_id valid ownership id
---@return building_id building 
function DATA.ownership_get_building(ownership_id)
    return DATA.ownership[ownership_id].building
end
---@param building building_id valid building_id
---@return ownership_id ownership 
function DATA.get_ownership_from_building(building)
    if DATA.ownership_from_building[building] == nil then return 0 end
    return DATA.ownership_from_building[building]
end
function __REMOVE_KEY_OWNERSHIP_BUILDING(old_value)
    DATA.ownership_from_building[old_value] = nil
end
---@param ownership_id ownership_id valid ownership id
---@param value building_id valid building_id
function DATA.ownership_set_building(ownership_id, value)
    local old_value = DATA.ownership[ownership_id].building
    DATA.ownership[ownership_id].building = value
    __REMOVE_KEY_OWNERSHIP_BUILDING(old_value)
    DATA.ownership_from_building[value] = ownership_id
end
---@param ownership_id ownership_id valid ownership id
---@return pop_id owner 
function DATA.ownership_get_owner(ownership_id)
    return DATA.ownership[ownership_id].owner
end
---@param owner pop_id valid pop_id
---@return ownership_id[] An array of ownership 
function DATA.get_ownership_from_owner(owner)
    return DATA.ownership_from_owner[owner]
end
---@param owner pop_id valid pop_id
---@param func fun(item: ownership_id) valid pop_id
function DATA.for_each_ownership_from_owner(owner, func)
    if DATA.ownership_from_owner[owner] == nil then return end
    for _, item in pairs(DATA.ownership_from_owner[owner]) do func(item) end
end
---@param owner pop_id valid pop_id
---@param func fun(item: ownership_id):boolean 
---@return table<ownership_id, ownership_id> 
function DATA.filter_array_ownership_from_owner(owner, func)
    ---@type table<ownership_id, ownership_id> 
    local t = {}
    for _, item in pairs(DATA.ownership_from_owner[owner]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param owner pop_id valid pop_id
---@param func fun(item: ownership_id):boolean 
---@return table<ownership_id, ownership_id> 
function DATA.filter_ownership_from_owner(owner, func)
    ---@type table<ownership_id, ownership_id> 
    local t = {}
    for _, item in pairs(DATA.ownership_from_owner[owner]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param ownership_id ownership_id valid ownership id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_OWNERSHIP_OWNER(ownership_id, old_value)
    local found_key = nil
    if DATA.ownership_from_owner[old_value] == nil then
        DATA.ownership_from_owner[old_value] = {}
        return
    end
    for key, value in pairs(DATA.ownership_from_owner[old_value]) do
        if value == ownership_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.ownership_from_owner[old_value], found_key)
    end
end
---@param ownership_id ownership_id valid ownership id
---@param value pop_id valid pop_id
function DATA.ownership_set_owner(ownership_id, value)
    local old_value = DATA.ownership[ownership_id].owner
    DATA.ownership[ownership_id].owner = value
    __REMOVE_KEY_OWNERSHIP_OWNER(ownership_id, old_value)
    if DATA.ownership_from_owner[value] == nil then DATA.ownership_from_owner[value] = {} end
    table.insert(DATA.ownership_from_owner[value], ownership_id)
end


local fat_ownership_id_metatable = {
    __index = function (t,k)
        if (k == "building") then return DATA.ownership_get_building(t.id) end
        if (k == "owner") then return DATA.ownership_get_owner(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "building") then
            DATA.ownership_set_building(t.id, v)
            return
        end
        if (k == "owner") then
            DATA.ownership_set_owner(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id ownership_id
---@return fat_ownership_id fat_id
function DATA.fatten_ownership(id)
    local result = {id = id}
    setmetatable(result, fat_ownership_id_metatable)    return result
end
----------employment----------


---employment: LSP types---

---Unique identificator for employment entity
---@alias employment_id number

---@class (exact) fat_employment_id
---@field id employment_id Unique employment id
---@field worker_income number 
---@field job job_id 
---@field building building_id 
---@field worker pop_id 

---@class struct_employment
---@field worker_income number 
---@field job job_id 
---@field building building_id 
---@field worker pop_id 


ffi.cdef[[
    typedef struct {
        float worker_income;
        uint32_t job;
        uint32_t building;
        uint32_t worker;
    } employment;
void dcon_delete_employment(int32_t j);
int32_t dcon_create_employment();
void dcon_employment_resize(uint32_t sz);
]]

---employment: FFI arrays---
---@type nil
DATA.employment_calloc = ffi.C.calloc(1, ffi.sizeof("employment") * 300001)
---@type table<employment_id, struct_employment>
DATA.employment = ffi.cast("employment*", DATA.employment_calloc)
---@type table<building_id, employment_id[]>>
DATA.employment_from_building= {}
for i = 1, 300000 do
    DATA.employment_from_building[i] = {}
end
---@type table<pop_id, employment_id>
DATA.employment_from_worker= {}

---employment: LUA bindings---

DATA.employment_size = 300000
---@type table<employment_id, boolean>
local employment_indices_pool = ffi.new("bool[?]", 300000)
for i = 1, 299999 do
    employment_indices_pool[i] = true 
end
---@type table<employment_id, employment_id>
DATA.employment_indices_set = {}
function DATA.create_employment()
    ---@type number
    local i = DCON.dcon_create_employment() + 1
            DATA.employment_indices_set[i] = i
    return i
end
function DATA.delete_employment(i)
    do
        local old_value = DATA.employment[i].building
        __REMOVE_KEY_EMPLOYMENT_BUILDING(i, old_value)
    end
    do
        local old_value = DATA.employment[i].worker
        __REMOVE_KEY_EMPLOYMENT_WORKER(old_value)
    end
    DATA.employment_indices_set[i] = nil
    return DCON.dcon_delete_employment(i - 1)
end
---@param func fun(item: employment_id) 
function DATA.for_each_employment(func)
    for _, item in pairs(DATA.employment_indices_set) do
        func(item)
    end
end
---@param func fun(item: employment_id):boolean 
---@return table<employment_id, employment_id> 
function DATA.filter_employment(func)
    ---@type table<employment_id, employment_id> 
    local t = {}
    for _, item in pairs(DATA.employment_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param employment_id employment_id valid employment id
---@return number worker_income 
function DATA.employment_get_worker_income(employment_id)
    return DATA.employment[employment_id].worker_income
end
---@param employment_id employment_id valid employment id
---@param value number valid number
function DATA.employment_set_worker_income(employment_id, value)
    DATA.employment[employment_id].worker_income = value
end
---@param employment_id employment_id valid employment id
---@param value number valid number
function DATA.employment_inc_worker_income(employment_id, value)
    DATA.employment[employment_id].worker_income = DATA.employment[employment_id].worker_income + value
end
---@param employment_id employment_id valid employment id
---@return job_id job 
function DATA.employment_get_job(employment_id)
    return DATA.employment[employment_id].job
end
---@param employment_id employment_id valid employment id
---@param value job_id valid job_id
function DATA.employment_set_job(employment_id, value)
    DATA.employment[employment_id].job = value
end
---@param employment_id employment_id valid employment id
---@return building_id building 
function DATA.employment_get_building(employment_id)
    return DATA.employment[employment_id].building
end
---@param building building_id valid building_id
---@return employment_id[] An array of employment 
function DATA.get_employment_from_building(building)
    return DATA.employment_from_building[building]
end
---@param building building_id valid building_id
---@param func fun(item: employment_id) valid building_id
function DATA.for_each_employment_from_building(building, func)
    if DATA.employment_from_building[building] == nil then return end
    for _, item in pairs(DATA.employment_from_building[building]) do func(item) end
end
---@param building building_id valid building_id
---@param func fun(item: employment_id):boolean 
---@return table<employment_id, employment_id> 
function DATA.filter_array_employment_from_building(building, func)
    ---@type table<employment_id, employment_id> 
    local t = {}
    for _, item in pairs(DATA.employment_from_building[building]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param building building_id valid building_id
---@param func fun(item: employment_id):boolean 
---@return table<employment_id, employment_id> 
function DATA.filter_employment_from_building(building, func)
    ---@type table<employment_id, employment_id> 
    local t = {}
    for _, item in pairs(DATA.employment_from_building[building]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param employment_id employment_id valid employment id
---@param old_value building_id valid building_id
function __REMOVE_KEY_EMPLOYMENT_BUILDING(employment_id, old_value)
    local found_key = nil
    if DATA.employment_from_building[old_value] == nil then
        DATA.employment_from_building[old_value] = {}
        return
    end
    for key, value in pairs(DATA.employment_from_building[old_value]) do
        if value == employment_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.employment_from_building[old_value], found_key)
    end
end
---@param employment_id employment_id valid employment id
---@param value building_id valid building_id
function DATA.employment_set_building(employment_id, value)
    local old_value = DATA.employment[employment_id].building
    DATA.employment[employment_id].building = value
    __REMOVE_KEY_EMPLOYMENT_BUILDING(employment_id, old_value)
    if DATA.employment_from_building[value] == nil then DATA.employment_from_building[value] = {} end
    table.insert(DATA.employment_from_building[value], employment_id)
end
---@param employment_id employment_id valid employment id
---@return pop_id worker 
function DATA.employment_get_worker(employment_id)
    return DATA.employment[employment_id].worker
end
---@param worker pop_id valid pop_id
---@return employment_id employment 
function DATA.get_employment_from_worker(worker)
    if DATA.employment_from_worker[worker] == nil then return 0 end
    return DATA.employment_from_worker[worker]
end
function __REMOVE_KEY_EMPLOYMENT_WORKER(old_value)
    DATA.employment_from_worker[old_value] = nil
end
---@param employment_id employment_id valid employment id
---@param value pop_id valid pop_id
function DATA.employment_set_worker(employment_id, value)
    local old_value = DATA.employment[employment_id].worker
    DATA.employment[employment_id].worker = value
    __REMOVE_KEY_EMPLOYMENT_WORKER(old_value)
    DATA.employment_from_worker[value] = employment_id
end


local fat_employment_id_metatable = {
    __index = function (t,k)
        if (k == "worker_income") then return DATA.employment_get_worker_income(t.id) end
        if (k == "job") then return DATA.employment_get_job(t.id) end
        if (k == "building") then return DATA.employment_get_building(t.id) end
        if (k == "worker") then return DATA.employment_get_worker(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "worker_income") then
            DATA.employment_set_worker_income(t.id, v)
            return
        end
        if (k == "job") then
            DATA.employment_set_job(t.id, v)
            return
        end
        if (k == "building") then
            DATA.employment_set_building(t.id, v)
            return
        end
        if (k == "worker") then
            DATA.employment_set_worker(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id employment_id
---@return fat_employment_id fat_id
function DATA.fatten_employment(id)
    local result = {id = id}
    setmetatable(result, fat_employment_id_metatable)    return result
end
----------building_location----------


---building_location: LSP types---

---Unique identificator for building_location entity
---@alias building_location_id number

---@class (exact) fat_building_location_id
---@field id building_location_id Unique building_location id
---@field location province_id location of the building
---@field building building_id 

---@class struct_building_location
---@field location province_id location of the building
---@field building building_id 


ffi.cdef[[
    typedef struct {
        uint32_t location;
        uint32_t building;
    } building_location;
void dcon_delete_building_location(int32_t j);
int32_t dcon_create_building_location();
void dcon_building_location_resize(uint32_t sz);
]]

---building_location: FFI arrays---
---@type nil
DATA.building_location_calloc = ffi.C.calloc(1, ffi.sizeof("building_location") * 200001)
---@type table<building_location_id, struct_building_location>
DATA.building_location = ffi.cast("building_location*", DATA.building_location_calloc)
---@type table<province_id, building_location_id[]>>
DATA.building_location_from_location= {}
for i = 1, 200000 do
    DATA.building_location_from_location[i] = {}
end
---@type table<building_id, building_location_id>
DATA.building_location_from_building= {}

---building_location: LUA bindings---

DATA.building_location_size = 200000
---@type table<building_location_id, boolean>
local building_location_indices_pool = ffi.new("bool[?]", 200000)
for i = 1, 199999 do
    building_location_indices_pool[i] = true 
end
---@type table<building_location_id, building_location_id>
DATA.building_location_indices_set = {}
function DATA.create_building_location()
    ---@type number
    local i = DCON.dcon_create_building_location() + 1
            DATA.building_location_indices_set[i] = i
    return i
end
function DATA.delete_building_location(i)
    do
        local old_value = DATA.building_location[i].location
        __REMOVE_KEY_BUILDING_LOCATION_LOCATION(i, old_value)
    end
    do
        local old_value = DATA.building_location[i].building
        __REMOVE_KEY_BUILDING_LOCATION_BUILDING(old_value)
    end
    DATA.building_location_indices_set[i] = nil
    return DCON.dcon_delete_building_location(i - 1)
end
---@param func fun(item: building_location_id) 
function DATA.for_each_building_location(func)
    for _, item in pairs(DATA.building_location_indices_set) do
        func(item)
    end
end
---@param func fun(item: building_location_id):boolean 
---@return table<building_location_id, building_location_id> 
function DATA.filter_building_location(func)
    ---@type table<building_location_id, building_location_id> 
    local t = {}
    for _, item in pairs(DATA.building_location_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param building_location_id building_location_id valid building_location id
---@return province_id location location of the building
function DATA.building_location_get_location(building_location_id)
    return DATA.building_location[building_location_id].location
end
---@param location province_id valid province_id
---@return building_location_id[] An array of building_location 
function DATA.get_building_location_from_location(location)
    return DATA.building_location_from_location[location]
end
---@param location province_id valid province_id
---@param func fun(item: building_location_id) valid province_id
function DATA.for_each_building_location_from_location(location, func)
    if DATA.building_location_from_location[location] == nil then return end
    for _, item in pairs(DATA.building_location_from_location[location]) do func(item) end
end
---@param location province_id valid province_id
---@param func fun(item: building_location_id):boolean 
---@return table<building_location_id, building_location_id> 
function DATA.filter_array_building_location_from_location(location, func)
    ---@type table<building_location_id, building_location_id> 
    local t = {}
    for _, item in pairs(DATA.building_location_from_location[location]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param location province_id valid province_id
---@param func fun(item: building_location_id):boolean 
---@return table<building_location_id, building_location_id> 
function DATA.filter_building_location_from_location(location, func)
    ---@type table<building_location_id, building_location_id> 
    local t = {}
    for _, item in pairs(DATA.building_location_from_location[location]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param building_location_id building_location_id valid building_location id
---@param old_value province_id valid province_id
function __REMOVE_KEY_BUILDING_LOCATION_LOCATION(building_location_id, old_value)
    local found_key = nil
    if DATA.building_location_from_location[old_value] == nil then
        DATA.building_location_from_location[old_value] = {}
        return
    end
    for key, value in pairs(DATA.building_location_from_location[old_value]) do
        if value == building_location_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.building_location_from_location[old_value], found_key)
    end
end
---@param building_location_id building_location_id valid building_location id
---@param value province_id valid province_id
function DATA.building_location_set_location(building_location_id, value)
    local old_value = DATA.building_location[building_location_id].location
    DATA.building_location[building_location_id].location = value
    __REMOVE_KEY_BUILDING_LOCATION_LOCATION(building_location_id, old_value)
    if DATA.building_location_from_location[value] == nil then DATA.building_location_from_location[value] = {} end
    table.insert(DATA.building_location_from_location[value], building_location_id)
end
---@param building_location_id building_location_id valid building_location id
---@return building_id building 
function DATA.building_location_get_building(building_location_id)
    return DATA.building_location[building_location_id].building
end
---@param building building_id valid building_id
---@return building_location_id building_location 
function DATA.get_building_location_from_building(building)
    if DATA.building_location_from_building[building] == nil then return 0 end
    return DATA.building_location_from_building[building]
end
function __REMOVE_KEY_BUILDING_LOCATION_BUILDING(old_value)
    DATA.building_location_from_building[old_value] = nil
end
---@param building_location_id building_location_id valid building_location id
---@param value building_id valid building_id
function DATA.building_location_set_building(building_location_id, value)
    local old_value = DATA.building_location[building_location_id].building
    DATA.building_location[building_location_id].building = value
    __REMOVE_KEY_BUILDING_LOCATION_BUILDING(old_value)
    DATA.building_location_from_building[value] = building_location_id
end


local fat_building_location_id_metatable = {
    __index = function (t,k)
        if (k == "location") then return DATA.building_location_get_location(t.id) end
        if (k == "building") then return DATA.building_location_get_building(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "location") then
            DATA.building_location_set_location(t.id, v)
            return
        end
        if (k == "building") then
            DATA.building_location_set_building(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id building_location_id
---@return fat_building_location_id fat_id
function DATA.fatten_building_location(id)
    local result = {id = id}
    setmetatable(result, fat_building_location_id_metatable)    return result
end
----------army_membership----------


---army_membership: LSP types---

---Unique identificator for army_membership entity
---@alias army_membership_id number

---@class (exact) fat_army_membership_id
---@field id army_membership_id Unique army_membership id
---@field army army_id 
---@field member warband_id part of army

---@class struct_army_membership
---@field army army_id 
---@field member warband_id part of army


ffi.cdef[[
    typedef struct {
        uint32_t army;
        uint32_t member;
    } army_membership;
void dcon_delete_army_membership(int32_t j);
int32_t dcon_create_army_membership();
void dcon_army_membership_resize(uint32_t sz);
]]

---army_membership: FFI arrays---
---@type nil
DATA.army_membership_calloc = ffi.C.calloc(1, ffi.sizeof("army_membership") * 10001)
---@type table<army_membership_id, struct_army_membership>
DATA.army_membership = ffi.cast("army_membership*", DATA.army_membership_calloc)
---@type table<army_id, army_membership_id[]>>
DATA.army_membership_from_army= {}
for i = 1, 10000 do
    DATA.army_membership_from_army[i] = {}
end
---@type table<warband_id, army_membership_id>
DATA.army_membership_from_member= {}

---army_membership: LUA bindings---

DATA.army_membership_size = 10000
---@type table<army_membership_id, boolean>
local army_membership_indices_pool = ffi.new("bool[?]", 10000)
for i = 1, 9999 do
    army_membership_indices_pool[i] = true 
end
---@type table<army_membership_id, army_membership_id>
DATA.army_membership_indices_set = {}
function DATA.create_army_membership()
    ---@type number
    local i = DCON.dcon_create_army_membership() + 1
            DATA.army_membership_indices_set[i] = i
    return i
end
function DATA.delete_army_membership(i)
    do
        local old_value = DATA.army_membership[i].army
        __REMOVE_KEY_ARMY_MEMBERSHIP_ARMY(i, old_value)
    end
    do
        local old_value = DATA.army_membership[i].member
        __REMOVE_KEY_ARMY_MEMBERSHIP_MEMBER(old_value)
    end
    DATA.army_membership_indices_set[i] = nil
    return DCON.dcon_delete_army_membership(i - 1)
end
---@param func fun(item: army_membership_id) 
function DATA.for_each_army_membership(func)
    for _, item in pairs(DATA.army_membership_indices_set) do
        func(item)
    end
end
---@param func fun(item: army_membership_id):boolean 
---@return table<army_membership_id, army_membership_id> 
function DATA.filter_army_membership(func)
    ---@type table<army_membership_id, army_membership_id> 
    local t = {}
    for _, item in pairs(DATA.army_membership_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param army_membership_id army_membership_id valid army_membership id
---@return army_id army 
function DATA.army_membership_get_army(army_membership_id)
    return DATA.army_membership[army_membership_id].army
end
---@param army army_id valid army_id
---@return army_membership_id[] An array of army_membership 
function DATA.get_army_membership_from_army(army)
    return DATA.army_membership_from_army[army]
end
---@param army army_id valid army_id
---@param func fun(item: army_membership_id) valid army_id
function DATA.for_each_army_membership_from_army(army, func)
    if DATA.army_membership_from_army[army] == nil then return end
    for _, item in pairs(DATA.army_membership_from_army[army]) do func(item) end
end
---@param army army_id valid army_id
---@param func fun(item: army_membership_id):boolean 
---@return table<army_membership_id, army_membership_id> 
function DATA.filter_array_army_membership_from_army(army, func)
    ---@type table<army_membership_id, army_membership_id> 
    local t = {}
    for _, item in pairs(DATA.army_membership_from_army[army]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param army army_id valid army_id
---@param func fun(item: army_membership_id):boolean 
---@return table<army_membership_id, army_membership_id> 
function DATA.filter_army_membership_from_army(army, func)
    ---@type table<army_membership_id, army_membership_id> 
    local t = {}
    for _, item in pairs(DATA.army_membership_from_army[army]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param army_membership_id army_membership_id valid army_membership id
---@param old_value army_id valid army_id
function __REMOVE_KEY_ARMY_MEMBERSHIP_ARMY(army_membership_id, old_value)
    local found_key = nil
    if DATA.army_membership_from_army[old_value] == nil then
        DATA.army_membership_from_army[old_value] = {}
        return
    end
    for key, value in pairs(DATA.army_membership_from_army[old_value]) do
        if value == army_membership_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.army_membership_from_army[old_value], found_key)
    end
end
---@param army_membership_id army_membership_id valid army_membership id
---@param value army_id valid army_id
function DATA.army_membership_set_army(army_membership_id, value)
    local old_value = DATA.army_membership[army_membership_id].army
    DATA.army_membership[army_membership_id].army = value
    __REMOVE_KEY_ARMY_MEMBERSHIP_ARMY(army_membership_id, old_value)
    if DATA.army_membership_from_army[value] == nil then DATA.army_membership_from_army[value] = {} end
    table.insert(DATA.army_membership_from_army[value], army_membership_id)
end
---@param army_membership_id army_membership_id valid army_membership id
---@return warband_id member part of army
function DATA.army_membership_get_member(army_membership_id)
    return DATA.army_membership[army_membership_id].member
end
---@param member warband_id valid warband_id
---@return army_membership_id army_membership 
function DATA.get_army_membership_from_member(member)
    if DATA.army_membership_from_member[member] == nil then return 0 end
    return DATA.army_membership_from_member[member]
end
function __REMOVE_KEY_ARMY_MEMBERSHIP_MEMBER(old_value)
    DATA.army_membership_from_member[old_value] = nil
end
---@param army_membership_id army_membership_id valid army_membership id
---@param value warband_id valid warband_id
function DATA.army_membership_set_member(army_membership_id, value)
    local old_value = DATA.army_membership[army_membership_id].member
    DATA.army_membership[army_membership_id].member = value
    __REMOVE_KEY_ARMY_MEMBERSHIP_MEMBER(old_value)
    DATA.army_membership_from_member[value] = army_membership_id
end


local fat_army_membership_id_metatable = {
    __index = function (t,k)
        if (k == "army") then return DATA.army_membership_get_army(t.id) end
        if (k == "member") then return DATA.army_membership_get_member(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "army") then
            DATA.army_membership_set_army(t.id, v)
            return
        end
        if (k == "member") then
            DATA.army_membership_set_member(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id army_membership_id
---@return fat_army_membership_id fat_id
function DATA.fatten_army_membership(id)
    local result = {id = id}
    setmetatable(result, fat_army_membership_id_metatable)    return result
end
----------warband_leader----------


---warband_leader: LSP types---

---Unique identificator for warband_leader entity
---@alias warband_leader_id number

---@class (exact) fat_warband_leader_id
---@field id warband_leader_id Unique warband_leader id
---@field leader pop_id 
---@field warband warband_id 

---@class struct_warband_leader
---@field leader pop_id 
---@field warband warband_id 


ffi.cdef[[
    typedef struct {
        uint32_t leader;
        uint32_t warband;
    } warband_leader;
void dcon_delete_warband_leader(int32_t j);
int32_t dcon_create_warband_leader();
void dcon_warband_leader_resize(uint32_t sz);
]]

---warband_leader: FFI arrays---
---@type nil
DATA.warband_leader_calloc = ffi.C.calloc(1, ffi.sizeof("warband_leader") * 10001)
---@type table<warband_leader_id, struct_warband_leader>
DATA.warband_leader = ffi.cast("warband_leader*", DATA.warband_leader_calloc)
---@type table<pop_id, warband_leader_id>
DATA.warband_leader_from_leader= {}
---@type table<warband_id, warband_leader_id>
DATA.warband_leader_from_warband= {}

---warband_leader: LUA bindings---

DATA.warband_leader_size = 10000
---@type table<warband_leader_id, boolean>
local warband_leader_indices_pool = ffi.new("bool[?]", 10000)
for i = 1, 9999 do
    warband_leader_indices_pool[i] = true 
end
---@type table<warband_leader_id, warband_leader_id>
DATA.warband_leader_indices_set = {}
function DATA.create_warband_leader()
    ---@type number
    local i = DCON.dcon_create_warband_leader() + 1
            DATA.warband_leader_indices_set[i] = i
    return i
end
function DATA.delete_warband_leader(i)
    do
        local old_value = DATA.warband_leader[i].leader
        __REMOVE_KEY_WARBAND_LEADER_LEADER(old_value)
    end
    do
        local old_value = DATA.warband_leader[i].warband
        __REMOVE_KEY_WARBAND_LEADER_WARBAND(old_value)
    end
    DATA.warband_leader_indices_set[i] = nil
    return DCON.dcon_delete_warband_leader(i - 1)
end
---@param func fun(item: warband_leader_id) 
function DATA.for_each_warband_leader(func)
    for _, item in pairs(DATA.warband_leader_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_leader_id):boolean 
---@return table<warband_leader_id, warband_leader_id> 
function DATA.filter_warband_leader(func)
    ---@type table<warband_leader_id, warband_leader_id> 
    local t = {}
    for _, item in pairs(DATA.warband_leader_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_leader_id warband_leader_id valid warband_leader id
---@return pop_id leader 
function DATA.warband_leader_get_leader(warband_leader_id)
    return DATA.warband_leader[warband_leader_id].leader
end
---@param leader pop_id valid pop_id
---@return warband_leader_id warband_leader 
function DATA.get_warband_leader_from_leader(leader)
    if DATA.warband_leader_from_leader[leader] == nil then return 0 end
    return DATA.warband_leader_from_leader[leader]
end
function __REMOVE_KEY_WARBAND_LEADER_LEADER(old_value)
    DATA.warband_leader_from_leader[old_value] = nil
end
---@param warband_leader_id warband_leader_id valid warband_leader id
---@param value pop_id valid pop_id
function DATA.warband_leader_set_leader(warband_leader_id, value)
    local old_value = DATA.warband_leader[warband_leader_id].leader
    DATA.warband_leader[warband_leader_id].leader = value
    __REMOVE_KEY_WARBAND_LEADER_LEADER(old_value)
    DATA.warband_leader_from_leader[value] = warband_leader_id
end
---@param warband_leader_id warband_leader_id valid warband_leader id
---@return warband_id warband 
function DATA.warband_leader_get_warband(warband_leader_id)
    return DATA.warband_leader[warband_leader_id].warband
end
---@param warband warband_id valid warband_id
---@return warband_leader_id warband_leader 
function DATA.get_warband_leader_from_warband(warband)
    if DATA.warband_leader_from_warband[warband] == nil then return 0 end
    return DATA.warband_leader_from_warband[warband]
end
function __REMOVE_KEY_WARBAND_LEADER_WARBAND(old_value)
    DATA.warband_leader_from_warband[old_value] = nil
end
---@param warband_leader_id warband_leader_id valid warband_leader id
---@param value warband_id valid warband_id
function DATA.warband_leader_set_warband(warband_leader_id, value)
    local old_value = DATA.warband_leader[warband_leader_id].warband
    DATA.warband_leader[warband_leader_id].warband = value
    __REMOVE_KEY_WARBAND_LEADER_WARBAND(old_value)
    DATA.warband_leader_from_warband[value] = warband_leader_id
end


local fat_warband_leader_id_metatable = {
    __index = function (t,k)
        if (k == "leader") then return DATA.warband_leader_get_leader(t.id) end
        if (k == "warband") then return DATA.warband_leader_get_warband(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "leader") then
            DATA.warband_leader_set_leader(t.id, v)
            return
        end
        if (k == "warband") then
            DATA.warband_leader_set_warband(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_leader_id
---@return fat_warband_leader_id fat_id
function DATA.fatten_warband_leader(id)
    local result = {id = id}
    setmetatable(result, fat_warband_leader_id_metatable)    return result
end
----------warband_recruiter----------


---warband_recruiter: LSP types---

---Unique identificator for warband_recruiter entity
---@alias warband_recruiter_id number

---@class (exact) fat_warband_recruiter_id
---@field id warband_recruiter_id Unique warband_recruiter id
---@field recruiter pop_id 
---@field warband warband_id 

---@class struct_warband_recruiter
---@field recruiter pop_id 
---@field warband warband_id 


ffi.cdef[[
    typedef struct {
        uint32_t recruiter;
        uint32_t warband;
    } warband_recruiter;
void dcon_delete_warband_recruiter(int32_t j);
int32_t dcon_create_warband_recruiter();
void dcon_warband_recruiter_resize(uint32_t sz);
]]

---warband_recruiter: FFI arrays---
---@type nil
DATA.warband_recruiter_calloc = ffi.C.calloc(1, ffi.sizeof("warband_recruiter") * 10001)
---@type table<warband_recruiter_id, struct_warband_recruiter>
DATA.warband_recruiter = ffi.cast("warband_recruiter*", DATA.warband_recruiter_calloc)
---@type table<pop_id, warband_recruiter_id>
DATA.warband_recruiter_from_recruiter= {}
---@type table<warband_id, warband_recruiter_id>
DATA.warband_recruiter_from_warband= {}

---warband_recruiter: LUA bindings---

DATA.warband_recruiter_size = 10000
---@type table<warband_recruiter_id, boolean>
local warband_recruiter_indices_pool = ffi.new("bool[?]", 10000)
for i = 1, 9999 do
    warband_recruiter_indices_pool[i] = true 
end
---@type table<warband_recruiter_id, warband_recruiter_id>
DATA.warband_recruiter_indices_set = {}
function DATA.create_warband_recruiter()
    ---@type number
    local i = DCON.dcon_create_warband_recruiter() + 1
            DATA.warband_recruiter_indices_set[i] = i
    return i
end
function DATA.delete_warband_recruiter(i)
    do
        local old_value = DATA.warband_recruiter[i].recruiter
        __REMOVE_KEY_WARBAND_RECRUITER_RECRUITER(old_value)
    end
    do
        local old_value = DATA.warband_recruiter[i].warband
        __REMOVE_KEY_WARBAND_RECRUITER_WARBAND(old_value)
    end
    DATA.warband_recruiter_indices_set[i] = nil
    return DCON.dcon_delete_warband_recruiter(i - 1)
end
---@param func fun(item: warband_recruiter_id) 
function DATA.for_each_warband_recruiter(func)
    for _, item in pairs(DATA.warband_recruiter_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_recruiter_id):boolean 
---@return table<warband_recruiter_id, warband_recruiter_id> 
function DATA.filter_warband_recruiter(func)
    ---@type table<warband_recruiter_id, warband_recruiter_id> 
    local t = {}
    for _, item in pairs(DATA.warband_recruiter_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_recruiter_id warband_recruiter_id valid warband_recruiter id
---@return pop_id recruiter 
function DATA.warband_recruiter_get_recruiter(warband_recruiter_id)
    return DATA.warband_recruiter[warband_recruiter_id].recruiter
end
---@param recruiter pop_id valid pop_id
---@return warband_recruiter_id warband_recruiter 
function DATA.get_warband_recruiter_from_recruiter(recruiter)
    if DATA.warband_recruiter_from_recruiter[recruiter] == nil then return 0 end
    return DATA.warband_recruiter_from_recruiter[recruiter]
end
function __REMOVE_KEY_WARBAND_RECRUITER_RECRUITER(old_value)
    DATA.warband_recruiter_from_recruiter[old_value] = nil
end
---@param warband_recruiter_id warband_recruiter_id valid warband_recruiter id
---@param value pop_id valid pop_id
function DATA.warband_recruiter_set_recruiter(warband_recruiter_id, value)
    local old_value = DATA.warband_recruiter[warband_recruiter_id].recruiter
    DATA.warband_recruiter[warband_recruiter_id].recruiter = value
    __REMOVE_KEY_WARBAND_RECRUITER_RECRUITER(old_value)
    DATA.warband_recruiter_from_recruiter[value] = warband_recruiter_id
end
---@param warband_recruiter_id warband_recruiter_id valid warband_recruiter id
---@return warband_id warband 
function DATA.warband_recruiter_get_warband(warband_recruiter_id)
    return DATA.warband_recruiter[warband_recruiter_id].warband
end
---@param warband warband_id valid warband_id
---@return warband_recruiter_id warband_recruiter 
function DATA.get_warband_recruiter_from_warband(warband)
    if DATA.warband_recruiter_from_warband[warband] == nil then return 0 end
    return DATA.warband_recruiter_from_warband[warband]
end
function __REMOVE_KEY_WARBAND_RECRUITER_WARBAND(old_value)
    DATA.warband_recruiter_from_warband[old_value] = nil
end
---@param warband_recruiter_id warband_recruiter_id valid warband_recruiter id
---@param value warband_id valid warband_id
function DATA.warband_recruiter_set_warband(warband_recruiter_id, value)
    local old_value = DATA.warband_recruiter[warband_recruiter_id].warband
    DATA.warband_recruiter[warband_recruiter_id].warband = value
    __REMOVE_KEY_WARBAND_RECRUITER_WARBAND(old_value)
    DATA.warband_recruiter_from_warband[value] = warband_recruiter_id
end


local fat_warband_recruiter_id_metatable = {
    __index = function (t,k)
        if (k == "recruiter") then return DATA.warband_recruiter_get_recruiter(t.id) end
        if (k == "warband") then return DATA.warband_recruiter_get_warband(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "recruiter") then
            DATA.warband_recruiter_set_recruiter(t.id, v)
            return
        end
        if (k == "warband") then
            DATA.warband_recruiter_set_warband(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_recruiter_id
---@return fat_warband_recruiter_id fat_id
function DATA.fatten_warband_recruiter(id)
    local result = {id = id}
    setmetatable(result, fat_warband_recruiter_id_metatable)    return result
end
----------warband_commander----------


---warband_commander: LSP types---

---Unique identificator for warband_commander entity
---@alias warband_commander_id number

---@class (exact) fat_warband_commander_id
---@field id warband_commander_id Unique warband_commander id
---@field commander pop_id 
---@field warband warband_id 

---@class struct_warband_commander
---@field commander pop_id 
---@field warband warband_id 


ffi.cdef[[
    typedef struct {
        uint32_t commander;
        uint32_t warband;
    } warband_commander;
void dcon_delete_warband_commander(int32_t j);
int32_t dcon_create_warband_commander();
void dcon_warband_commander_resize(uint32_t sz);
]]

---warband_commander: FFI arrays---
---@type nil
DATA.warband_commander_calloc = ffi.C.calloc(1, ffi.sizeof("warband_commander") * 10001)
---@type table<warband_commander_id, struct_warband_commander>
DATA.warband_commander = ffi.cast("warband_commander*", DATA.warband_commander_calloc)
---@type table<pop_id, warband_commander_id>
DATA.warband_commander_from_commander= {}
---@type table<warband_id, warband_commander_id>
DATA.warband_commander_from_warband= {}

---warband_commander: LUA bindings---

DATA.warband_commander_size = 10000
---@type table<warband_commander_id, boolean>
local warband_commander_indices_pool = ffi.new("bool[?]", 10000)
for i = 1, 9999 do
    warband_commander_indices_pool[i] = true 
end
---@type table<warband_commander_id, warband_commander_id>
DATA.warband_commander_indices_set = {}
function DATA.create_warband_commander()
    ---@type number
    local i = DCON.dcon_create_warband_commander() + 1
            DATA.warband_commander_indices_set[i] = i
    return i
end
function DATA.delete_warband_commander(i)
    do
        local old_value = DATA.warband_commander[i].commander
        __REMOVE_KEY_WARBAND_COMMANDER_COMMANDER(old_value)
    end
    do
        local old_value = DATA.warband_commander[i].warband
        __REMOVE_KEY_WARBAND_COMMANDER_WARBAND(old_value)
    end
    DATA.warband_commander_indices_set[i] = nil
    return DCON.dcon_delete_warband_commander(i - 1)
end
---@param func fun(item: warband_commander_id) 
function DATA.for_each_warband_commander(func)
    for _, item in pairs(DATA.warband_commander_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_commander_id):boolean 
---@return table<warband_commander_id, warband_commander_id> 
function DATA.filter_warband_commander(func)
    ---@type table<warband_commander_id, warband_commander_id> 
    local t = {}
    for _, item in pairs(DATA.warband_commander_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_commander_id warband_commander_id valid warband_commander id
---@return pop_id commander 
function DATA.warband_commander_get_commander(warband_commander_id)
    return DATA.warband_commander[warband_commander_id].commander
end
---@param commander pop_id valid pop_id
---@return warband_commander_id warband_commander 
function DATA.get_warband_commander_from_commander(commander)
    if DATA.warband_commander_from_commander[commander] == nil then return 0 end
    return DATA.warband_commander_from_commander[commander]
end
function __REMOVE_KEY_WARBAND_COMMANDER_COMMANDER(old_value)
    DATA.warband_commander_from_commander[old_value] = nil
end
---@param warband_commander_id warband_commander_id valid warband_commander id
---@param value pop_id valid pop_id
function DATA.warband_commander_set_commander(warband_commander_id, value)
    local old_value = DATA.warband_commander[warband_commander_id].commander
    DATA.warband_commander[warband_commander_id].commander = value
    __REMOVE_KEY_WARBAND_COMMANDER_COMMANDER(old_value)
    DATA.warband_commander_from_commander[value] = warband_commander_id
end
---@param warband_commander_id warband_commander_id valid warband_commander id
---@return warband_id warband 
function DATA.warband_commander_get_warband(warband_commander_id)
    return DATA.warband_commander[warband_commander_id].warband
end
---@param warband warband_id valid warband_id
---@return warband_commander_id warband_commander 
function DATA.get_warband_commander_from_warband(warband)
    if DATA.warband_commander_from_warband[warband] == nil then return 0 end
    return DATA.warband_commander_from_warband[warband]
end
function __REMOVE_KEY_WARBAND_COMMANDER_WARBAND(old_value)
    DATA.warband_commander_from_warband[old_value] = nil
end
---@param warband_commander_id warband_commander_id valid warband_commander id
---@param value warband_id valid warband_id
function DATA.warband_commander_set_warband(warband_commander_id, value)
    local old_value = DATA.warband_commander[warband_commander_id].warband
    DATA.warband_commander[warband_commander_id].warband = value
    __REMOVE_KEY_WARBAND_COMMANDER_WARBAND(old_value)
    DATA.warband_commander_from_warband[value] = warband_commander_id
end


local fat_warband_commander_id_metatable = {
    __index = function (t,k)
        if (k == "commander") then return DATA.warband_commander_get_commander(t.id) end
        if (k == "warband") then return DATA.warband_commander_get_warband(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "commander") then
            DATA.warband_commander_set_commander(t.id, v)
            return
        end
        if (k == "warband") then
            DATA.warband_commander_set_warband(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_commander_id
---@return fat_warband_commander_id fat_id
function DATA.fatten_warband_commander(id)
    local result = {id = id}
    setmetatable(result, fat_warband_commander_id_metatable)    return result
end
----------warband_location----------


---warband_location: LSP types---

---Unique identificator for warband_location entity
---@alias warband_location_id number

---@class (exact) fat_warband_location_id
---@field id warband_location_id Unique warband_location id
---@field location province_id location of warband
---@field warband warband_id 

---@class struct_warband_location
---@field location province_id location of warband
---@field warband warband_id 


ffi.cdef[[
    typedef struct {
        uint32_t location;
        uint32_t warband;
    } warband_location;
void dcon_delete_warband_location(int32_t j);
int32_t dcon_create_warband_location();
void dcon_warband_location_resize(uint32_t sz);
]]

---warband_location: FFI arrays---
---@type nil
DATA.warband_location_calloc = ffi.C.calloc(1, ffi.sizeof("warband_location") * 10001)
---@type table<warband_location_id, struct_warband_location>
DATA.warband_location = ffi.cast("warband_location*", DATA.warband_location_calloc)
---@type table<province_id, warband_location_id[]>>
DATA.warband_location_from_location= {}
for i = 1, 10000 do
    DATA.warband_location_from_location[i] = {}
end
---@type table<warband_id, warband_location_id>
DATA.warband_location_from_warband= {}

---warband_location: LUA bindings---

DATA.warband_location_size = 10000
---@type table<warband_location_id, boolean>
local warband_location_indices_pool = ffi.new("bool[?]", 10000)
for i = 1, 9999 do
    warband_location_indices_pool[i] = true 
end
---@type table<warband_location_id, warband_location_id>
DATA.warband_location_indices_set = {}
function DATA.create_warband_location()
    ---@type number
    local i = DCON.dcon_create_warband_location() + 1
            DATA.warband_location_indices_set[i] = i
    return i
end
function DATA.delete_warband_location(i)
    do
        local old_value = DATA.warband_location[i].location
        __REMOVE_KEY_WARBAND_LOCATION_LOCATION(i, old_value)
    end
    do
        local old_value = DATA.warband_location[i].warband
        __REMOVE_KEY_WARBAND_LOCATION_WARBAND(old_value)
    end
    DATA.warband_location_indices_set[i] = nil
    return DCON.dcon_delete_warband_location(i - 1)
end
---@param func fun(item: warband_location_id) 
function DATA.for_each_warband_location(func)
    for _, item in pairs(DATA.warband_location_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_location_id):boolean 
---@return table<warband_location_id, warband_location_id> 
function DATA.filter_warband_location(func)
    ---@type table<warband_location_id, warband_location_id> 
    local t = {}
    for _, item in pairs(DATA.warband_location_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_location_id warband_location_id valid warband_location id
---@return province_id location location of warband
function DATA.warband_location_get_location(warband_location_id)
    return DATA.warband_location[warband_location_id].location
end
---@param location province_id valid province_id
---@return warband_location_id[] An array of warband_location 
function DATA.get_warband_location_from_location(location)
    return DATA.warband_location_from_location[location]
end
---@param location province_id valid province_id
---@param func fun(item: warband_location_id) valid province_id
function DATA.for_each_warband_location_from_location(location, func)
    if DATA.warband_location_from_location[location] == nil then return end
    for _, item in pairs(DATA.warband_location_from_location[location]) do func(item) end
end
---@param location province_id valid province_id
---@param func fun(item: warband_location_id):boolean 
---@return table<warband_location_id, warband_location_id> 
function DATA.filter_array_warband_location_from_location(location, func)
    ---@type table<warband_location_id, warband_location_id> 
    local t = {}
    for _, item in pairs(DATA.warband_location_from_location[location]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param location province_id valid province_id
---@param func fun(item: warband_location_id):boolean 
---@return table<warband_location_id, warband_location_id> 
function DATA.filter_warband_location_from_location(location, func)
    ---@type table<warband_location_id, warband_location_id> 
    local t = {}
    for _, item in pairs(DATA.warband_location_from_location[location]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param warband_location_id warband_location_id valid warband_location id
---@param old_value province_id valid province_id
function __REMOVE_KEY_WARBAND_LOCATION_LOCATION(warband_location_id, old_value)
    local found_key = nil
    if DATA.warband_location_from_location[old_value] == nil then
        DATA.warband_location_from_location[old_value] = {}
        return
    end
    for key, value in pairs(DATA.warband_location_from_location[old_value]) do
        if value == warband_location_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.warband_location_from_location[old_value], found_key)
    end
end
---@param warband_location_id warband_location_id valid warband_location id
---@param value province_id valid province_id
function DATA.warband_location_set_location(warband_location_id, value)
    local old_value = DATA.warband_location[warband_location_id].location
    DATA.warband_location[warband_location_id].location = value
    __REMOVE_KEY_WARBAND_LOCATION_LOCATION(warband_location_id, old_value)
    if DATA.warband_location_from_location[value] == nil then DATA.warband_location_from_location[value] = {} end
    table.insert(DATA.warband_location_from_location[value], warband_location_id)
end
---@param warband_location_id warband_location_id valid warband_location id
---@return warband_id warband 
function DATA.warband_location_get_warband(warband_location_id)
    return DATA.warband_location[warband_location_id].warband
end
---@param warband warband_id valid warband_id
---@return warband_location_id warband_location 
function DATA.get_warband_location_from_warband(warband)
    if DATA.warband_location_from_warband[warband] == nil then return 0 end
    return DATA.warband_location_from_warband[warband]
end
function __REMOVE_KEY_WARBAND_LOCATION_WARBAND(old_value)
    DATA.warband_location_from_warband[old_value] = nil
end
---@param warband_location_id warband_location_id valid warband_location id
---@param value warband_id valid warband_id
function DATA.warband_location_set_warband(warband_location_id, value)
    local old_value = DATA.warband_location[warband_location_id].warband
    DATA.warband_location[warband_location_id].warband = value
    __REMOVE_KEY_WARBAND_LOCATION_WARBAND(old_value)
    DATA.warband_location_from_warband[value] = warband_location_id
end


local fat_warband_location_id_metatable = {
    __index = function (t,k)
        if (k == "location") then return DATA.warband_location_get_location(t.id) end
        if (k == "warband") then return DATA.warband_location_get_warband(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "location") then
            DATA.warband_location_set_location(t.id, v)
            return
        end
        if (k == "warband") then
            DATA.warband_location_set_warband(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_location_id
---@return fat_warband_location_id fat_id
function DATA.fatten_warband_location(id)
    local result = {id = id}
    setmetatable(result, fat_warband_location_id_metatable)    return result
end
----------warband_unit----------


---warband_unit: LSP types---

---Unique identificator for warband_unit entity
---@alias warband_unit_id number

---@class (exact) fat_warband_unit_id
---@field id warband_unit_id Unique warband_unit id
---@field type unit_type_id Current unit type
---@field unit pop_id 
---@field warband warband_id 

---@class struct_warband_unit
---@field type unit_type_id Current unit type
---@field unit pop_id 
---@field warband warband_id 


ffi.cdef[[
    typedef struct {
        uint32_t type;
        uint32_t unit;
        uint32_t warband;
    } warband_unit;
void dcon_delete_warband_unit(int32_t j);
int32_t dcon_create_warband_unit();
void dcon_warband_unit_resize(uint32_t sz);
]]

---warband_unit: FFI arrays---
---@type nil
DATA.warband_unit_calloc = ffi.C.calloc(1, ffi.sizeof("warband_unit") * 50001)
---@type table<warband_unit_id, struct_warband_unit>
DATA.warband_unit = ffi.cast("warband_unit*", DATA.warband_unit_calloc)
---@type table<pop_id, warband_unit_id>
DATA.warband_unit_from_unit= {}
---@type table<warband_id, warband_unit_id[]>>
DATA.warband_unit_from_warband= {}
for i = 1, 50000 do
    DATA.warband_unit_from_warband[i] = {}
end

---warband_unit: LUA bindings---

DATA.warband_unit_size = 50000
---@type table<warband_unit_id, boolean>
local warband_unit_indices_pool = ffi.new("bool[?]", 50000)
for i = 1, 49999 do
    warband_unit_indices_pool[i] = true 
end
---@type table<warband_unit_id, warband_unit_id>
DATA.warband_unit_indices_set = {}
function DATA.create_warband_unit()
    ---@type number
    local i = DCON.dcon_create_warband_unit() + 1
            DATA.warband_unit_indices_set[i] = i
    return i
end
function DATA.delete_warband_unit(i)
    do
        local old_value = DATA.warband_unit[i].unit
        __REMOVE_KEY_WARBAND_UNIT_UNIT(old_value)
    end
    do
        local old_value = DATA.warband_unit[i].warband
        __REMOVE_KEY_WARBAND_UNIT_WARBAND(i, old_value)
    end
    DATA.warband_unit_indices_set[i] = nil
    return DCON.dcon_delete_warband_unit(i - 1)
end
---@param func fun(item: warband_unit_id) 
function DATA.for_each_warband_unit(func)
    for _, item in pairs(DATA.warband_unit_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_unit_id):boolean 
---@return table<warband_unit_id, warband_unit_id> 
function DATA.filter_warband_unit(func)
    ---@type table<warband_unit_id, warband_unit_id> 
    local t = {}
    for _, item in pairs(DATA.warband_unit_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_unit_id warband_unit_id valid warband_unit id
---@return unit_type_id type Current unit type
function DATA.warband_unit_get_type(warband_unit_id)
    return DATA.warband_unit[warband_unit_id].type
end
---@param warband_unit_id warband_unit_id valid warband_unit id
---@param value unit_type_id valid unit_type_id
function DATA.warband_unit_set_type(warband_unit_id, value)
    DATA.warband_unit[warband_unit_id].type = value
end
---@param warband_unit_id warband_unit_id valid warband_unit id
---@return pop_id unit 
function DATA.warband_unit_get_unit(warband_unit_id)
    return DATA.warband_unit[warband_unit_id].unit
end
---@param unit pop_id valid pop_id
---@return warband_unit_id warband_unit 
function DATA.get_warband_unit_from_unit(unit)
    if DATA.warband_unit_from_unit[unit] == nil then return 0 end
    return DATA.warband_unit_from_unit[unit]
end
function __REMOVE_KEY_WARBAND_UNIT_UNIT(old_value)
    DATA.warband_unit_from_unit[old_value] = nil
end
---@param warband_unit_id warband_unit_id valid warband_unit id
---@param value pop_id valid pop_id
function DATA.warband_unit_set_unit(warband_unit_id, value)
    local old_value = DATA.warband_unit[warband_unit_id].unit
    DATA.warband_unit[warband_unit_id].unit = value
    __REMOVE_KEY_WARBAND_UNIT_UNIT(old_value)
    DATA.warband_unit_from_unit[value] = warband_unit_id
end
---@param warband_unit_id warband_unit_id valid warband_unit id
---@return warband_id warband 
function DATA.warband_unit_get_warband(warband_unit_id)
    return DATA.warband_unit[warband_unit_id].warband
end
---@param warband warband_id valid warband_id
---@return warband_unit_id[] An array of warband_unit 
function DATA.get_warband_unit_from_warband(warband)
    return DATA.warband_unit_from_warband[warband]
end
---@param warband warband_id valid warband_id
---@param func fun(item: warband_unit_id) valid warband_id
function DATA.for_each_warband_unit_from_warband(warband, func)
    if DATA.warband_unit_from_warband[warband] == nil then return end
    for _, item in pairs(DATA.warband_unit_from_warband[warband]) do func(item) end
end
---@param warband warband_id valid warband_id
---@param func fun(item: warband_unit_id):boolean 
---@return table<warband_unit_id, warband_unit_id> 
function DATA.filter_array_warband_unit_from_warband(warband, func)
    ---@type table<warband_unit_id, warband_unit_id> 
    local t = {}
    for _, item in pairs(DATA.warband_unit_from_warband[warband]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param warband warband_id valid warband_id
---@param func fun(item: warband_unit_id):boolean 
---@return table<warband_unit_id, warband_unit_id> 
function DATA.filter_warband_unit_from_warband(warband, func)
    ---@type table<warband_unit_id, warband_unit_id> 
    local t = {}
    for _, item in pairs(DATA.warband_unit_from_warband[warband]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param warband_unit_id warband_unit_id valid warband_unit id
---@param old_value warband_id valid warband_id
function __REMOVE_KEY_WARBAND_UNIT_WARBAND(warband_unit_id, old_value)
    local found_key = nil
    if DATA.warband_unit_from_warband[old_value] == nil then
        DATA.warband_unit_from_warband[old_value] = {}
        return
    end
    for key, value in pairs(DATA.warband_unit_from_warband[old_value]) do
        if value == warband_unit_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.warband_unit_from_warband[old_value], found_key)
    end
end
---@param warband_unit_id warband_unit_id valid warband_unit id
---@param value warband_id valid warband_id
function DATA.warband_unit_set_warband(warband_unit_id, value)
    local old_value = DATA.warband_unit[warband_unit_id].warband
    DATA.warband_unit[warband_unit_id].warband = value
    __REMOVE_KEY_WARBAND_UNIT_WARBAND(warband_unit_id, old_value)
    if DATA.warband_unit_from_warband[value] == nil then DATA.warband_unit_from_warband[value] = {} end
    table.insert(DATA.warband_unit_from_warband[value], warband_unit_id)
end


local fat_warband_unit_id_metatable = {
    __index = function (t,k)
        if (k == "type") then return DATA.warband_unit_get_type(t.id) end
        if (k == "unit") then return DATA.warband_unit_get_unit(t.id) end
        if (k == "warband") then return DATA.warband_unit_get_warband(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "type") then
            DATA.warband_unit_set_type(t.id, v)
            return
        end
        if (k == "unit") then
            DATA.warband_unit_set_unit(t.id, v)
            return
        end
        if (k == "warband") then
            DATA.warband_unit_set_warband(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_unit_id
---@return fat_warband_unit_id fat_id
function DATA.fatten_warband_unit(id)
    local result = {id = id}
    setmetatable(result, fat_warband_unit_id_metatable)    return result
end
----------character_location----------


---character_location: LSP types---

---Unique identificator for character_location entity
---@alias character_location_id number

---@class (exact) fat_character_location_id
---@field id character_location_id Unique character_location id
---@field location province_id location of character
---@field character pop_id 

---@class struct_character_location
---@field location province_id location of character
---@field character pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t location;
        uint32_t character;
    } character_location;
void dcon_delete_character_location(int32_t j);
int32_t dcon_create_character_location();
void dcon_character_location_resize(uint32_t sz);
]]

---character_location: FFI arrays---
---@type nil
DATA.character_location_calloc = ffi.C.calloc(1, ffi.sizeof("character_location") * 100001)
---@type table<character_location_id, struct_character_location>
DATA.character_location = ffi.cast("character_location*", DATA.character_location_calloc)
---@type table<province_id, character_location_id[]>>
DATA.character_location_from_location= {}
for i = 1, 100000 do
    DATA.character_location_from_location[i] = {}
end
---@type table<pop_id, character_location_id>
DATA.character_location_from_character= {}

---character_location: LUA bindings---

DATA.character_location_size = 100000
---@type table<character_location_id, boolean>
local character_location_indices_pool = ffi.new("bool[?]", 100000)
for i = 1, 99999 do
    character_location_indices_pool[i] = true 
end
---@type table<character_location_id, character_location_id>
DATA.character_location_indices_set = {}
function DATA.create_character_location()
    ---@type number
    local i = DCON.dcon_create_character_location() + 1
            DATA.character_location_indices_set[i] = i
    return i
end
function DATA.delete_character_location(i)
    do
        local old_value = DATA.character_location[i].location
        __REMOVE_KEY_CHARACTER_LOCATION_LOCATION(i, old_value)
    end
    do
        local old_value = DATA.character_location[i].character
        __REMOVE_KEY_CHARACTER_LOCATION_CHARACTER(old_value)
    end
    DATA.character_location_indices_set[i] = nil
    return DCON.dcon_delete_character_location(i - 1)
end
---@param func fun(item: character_location_id) 
function DATA.for_each_character_location(func)
    for _, item in pairs(DATA.character_location_indices_set) do
        func(item)
    end
end
---@param func fun(item: character_location_id):boolean 
---@return table<character_location_id, character_location_id> 
function DATA.filter_character_location(func)
    ---@type table<character_location_id, character_location_id> 
    local t = {}
    for _, item in pairs(DATA.character_location_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param character_location_id character_location_id valid character_location id
---@return province_id location location of character
function DATA.character_location_get_location(character_location_id)
    return DATA.character_location[character_location_id].location
end
---@param location province_id valid province_id
---@return character_location_id[] An array of character_location 
function DATA.get_character_location_from_location(location)
    return DATA.character_location_from_location[location]
end
---@param location province_id valid province_id
---@param func fun(item: character_location_id) valid province_id
function DATA.for_each_character_location_from_location(location, func)
    if DATA.character_location_from_location[location] == nil then return end
    for _, item in pairs(DATA.character_location_from_location[location]) do func(item) end
end
---@param location province_id valid province_id
---@param func fun(item: character_location_id):boolean 
---@return table<character_location_id, character_location_id> 
function DATA.filter_array_character_location_from_location(location, func)
    ---@type table<character_location_id, character_location_id> 
    local t = {}
    for _, item in pairs(DATA.character_location_from_location[location]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param location province_id valid province_id
---@param func fun(item: character_location_id):boolean 
---@return table<character_location_id, character_location_id> 
function DATA.filter_character_location_from_location(location, func)
    ---@type table<character_location_id, character_location_id> 
    local t = {}
    for _, item in pairs(DATA.character_location_from_location[location]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param character_location_id character_location_id valid character_location id
---@param old_value province_id valid province_id
function __REMOVE_KEY_CHARACTER_LOCATION_LOCATION(character_location_id, old_value)
    local found_key = nil
    if DATA.character_location_from_location[old_value] == nil then
        DATA.character_location_from_location[old_value] = {}
        return
    end
    for key, value in pairs(DATA.character_location_from_location[old_value]) do
        if value == character_location_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.character_location_from_location[old_value], found_key)
    end
end
---@param character_location_id character_location_id valid character_location id
---@param value province_id valid province_id
function DATA.character_location_set_location(character_location_id, value)
    local old_value = DATA.character_location[character_location_id].location
    DATA.character_location[character_location_id].location = value
    __REMOVE_KEY_CHARACTER_LOCATION_LOCATION(character_location_id, old_value)
    if DATA.character_location_from_location[value] == nil then DATA.character_location_from_location[value] = {} end
    table.insert(DATA.character_location_from_location[value], character_location_id)
end
---@param character_location_id character_location_id valid character_location id
---@return pop_id character 
function DATA.character_location_get_character(character_location_id)
    return DATA.character_location[character_location_id].character
end
---@param character pop_id valid pop_id
---@return character_location_id character_location 
function DATA.get_character_location_from_character(character)
    if DATA.character_location_from_character[character] == nil then return 0 end
    return DATA.character_location_from_character[character]
end
function __REMOVE_KEY_CHARACTER_LOCATION_CHARACTER(old_value)
    DATA.character_location_from_character[old_value] = nil
end
---@param character_location_id character_location_id valid character_location id
---@param value pop_id valid pop_id
function DATA.character_location_set_character(character_location_id, value)
    local old_value = DATA.character_location[character_location_id].character
    DATA.character_location[character_location_id].character = value
    __REMOVE_KEY_CHARACTER_LOCATION_CHARACTER(old_value)
    DATA.character_location_from_character[value] = character_location_id
end


local fat_character_location_id_metatable = {
    __index = function (t,k)
        if (k == "location") then return DATA.character_location_get_location(t.id) end
        if (k == "character") then return DATA.character_location_get_character(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "location") then
            DATA.character_location_set_location(t.id, v)
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
    setmetatable(result, fat_character_location_id_metatable)    return result
end
----------home----------


---home: LSP types---

---Unique identificator for home entity
---@alias home_id number

---@class (exact) fat_home_id
---@field id home_id Unique home id
---@field home province_id home of pop
---@field pop pop_id characters and pops which think of this province as their home

---@class struct_home
---@field home province_id home of pop
---@field pop pop_id characters and pops which think of this province as their home


ffi.cdef[[
    typedef struct {
        uint32_t home;
        uint32_t pop;
    } home;
void dcon_delete_home(int32_t j);
int32_t dcon_create_home();
void dcon_home_resize(uint32_t sz);
]]

---home: FFI arrays---
---@type nil
DATA.home_calloc = ffi.C.calloc(1, ffi.sizeof("home") * 300001)
---@type table<home_id, struct_home>
DATA.home = ffi.cast("home*", DATA.home_calloc)
---@type table<province_id, home_id[]>>
DATA.home_from_home= {}
for i = 1, 300000 do
    DATA.home_from_home[i] = {}
end
---@type table<pop_id, home_id>
DATA.home_from_pop= {}

---home: LUA bindings---

DATA.home_size = 300000
---@type table<home_id, boolean>
local home_indices_pool = ffi.new("bool[?]", 300000)
for i = 1, 299999 do
    home_indices_pool[i] = true 
end
---@type table<home_id, home_id>
DATA.home_indices_set = {}
function DATA.create_home()
    ---@type number
    local i = DCON.dcon_create_home() + 1
            DATA.home_indices_set[i] = i
    return i
end
function DATA.delete_home(i)
    do
        local old_value = DATA.home[i].home
        __REMOVE_KEY_HOME_HOME(i, old_value)
    end
    do
        local old_value = DATA.home[i].pop
        __REMOVE_KEY_HOME_POP(old_value)
    end
    DATA.home_indices_set[i] = nil
    return DCON.dcon_delete_home(i - 1)
end
---@param func fun(item: home_id) 
function DATA.for_each_home(func)
    for _, item in pairs(DATA.home_indices_set) do
        func(item)
    end
end
---@param func fun(item: home_id):boolean 
---@return table<home_id, home_id> 
function DATA.filter_home(func)
    ---@type table<home_id, home_id> 
    local t = {}
    for _, item in pairs(DATA.home_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param home_id home_id valid home id
---@return province_id home home of pop
function DATA.home_get_home(home_id)
    return DATA.home[home_id].home
end
---@param home province_id valid province_id
---@return home_id[] An array of home 
function DATA.get_home_from_home(home)
    return DATA.home_from_home[home]
end
---@param home province_id valid province_id
---@param func fun(item: home_id) valid province_id
function DATA.for_each_home_from_home(home, func)
    if DATA.home_from_home[home] == nil then return end
    for _, item in pairs(DATA.home_from_home[home]) do func(item) end
end
---@param home province_id valid province_id
---@param func fun(item: home_id):boolean 
---@return table<home_id, home_id> 
function DATA.filter_array_home_from_home(home, func)
    ---@type table<home_id, home_id> 
    local t = {}
    for _, item in pairs(DATA.home_from_home[home]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param home province_id valid province_id
---@param func fun(item: home_id):boolean 
---@return table<home_id, home_id> 
function DATA.filter_home_from_home(home, func)
    ---@type table<home_id, home_id> 
    local t = {}
    for _, item in pairs(DATA.home_from_home[home]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param home_id home_id valid home id
---@param old_value province_id valid province_id
function __REMOVE_KEY_HOME_HOME(home_id, old_value)
    local found_key = nil
    if DATA.home_from_home[old_value] == nil then
        DATA.home_from_home[old_value] = {}
        return
    end
    for key, value in pairs(DATA.home_from_home[old_value]) do
        if value == home_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.home_from_home[old_value], found_key)
    end
end
---@param home_id home_id valid home id
---@param value province_id valid province_id
function DATA.home_set_home(home_id, value)
    local old_value = DATA.home[home_id].home
    DATA.home[home_id].home = value
    __REMOVE_KEY_HOME_HOME(home_id, old_value)
    if DATA.home_from_home[value] == nil then DATA.home_from_home[value] = {} end
    table.insert(DATA.home_from_home[value], home_id)
end
---@param home_id home_id valid home id
---@return pop_id pop characters and pops which think of this province as their home
function DATA.home_get_pop(home_id)
    return DATA.home[home_id].pop
end
---@param pop pop_id valid pop_id
---@return home_id home 
function DATA.get_home_from_pop(pop)
    if DATA.home_from_pop[pop] == nil then return 0 end
    return DATA.home_from_pop[pop]
end
function __REMOVE_KEY_HOME_POP(old_value)
    DATA.home_from_pop[old_value] = nil
end
---@param home_id home_id valid home id
---@param value pop_id valid pop_id
function DATA.home_set_pop(home_id, value)
    local old_value = DATA.home[home_id].pop
    DATA.home[home_id].pop = value
    __REMOVE_KEY_HOME_POP(old_value)
    DATA.home_from_pop[value] = home_id
end


local fat_home_id_metatable = {
    __index = function (t,k)
        if (k == "home") then return DATA.home_get_home(t.id) end
        if (k == "pop") then return DATA.home_get_pop(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "home") then
            DATA.home_set_home(t.id, v)
            return
        end
        if (k == "pop") then
            DATA.home_set_pop(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id home_id
---@return fat_home_id fat_id
function DATA.fatten_home(id)
    local result = {id = id}
    setmetatable(result, fat_home_id_metatable)    return result
end
----------pop_location----------


---pop_location: LSP types---

---Unique identificator for pop_location entity
---@alias pop_location_id number

---@class (exact) fat_pop_location_id
---@field id pop_location_id Unique pop_location id
---@field location province_id location of pop
---@field pop pop_id 

---@class struct_pop_location
---@field location province_id location of pop
---@field pop pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t location;
        uint32_t pop;
    } pop_location;
void dcon_delete_pop_location(int32_t j);
int32_t dcon_create_pop_location();
void dcon_pop_location_resize(uint32_t sz);
]]

---pop_location: FFI arrays---
---@type nil
DATA.pop_location_calloc = ffi.C.calloc(1, ffi.sizeof("pop_location") * 300001)
---@type table<pop_location_id, struct_pop_location>
DATA.pop_location = ffi.cast("pop_location*", DATA.pop_location_calloc)
---@type table<province_id, pop_location_id[]>>
DATA.pop_location_from_location= {}
for i = 1, 300000 do
    DATA.pop_location_from_location[i] = {}
end
---@type table<pop_id, pop_location_id>
DATA.pop_location_from_pop= {}

---pop_location: LUA bindings---

DATA.pop_location_size = 300000
---@type table<pop_location_id, boolean>
local pop_location_indices_pool = ffi.new("bool[?]", 300000)
for i = 1, 299999 do
    pop_location_indices_pool[i] = true 
end
---@type table<pop_location_id, pop_location_id>
DATA.pop_location_indices_set = {}
function DATA.create_pop_location()
    ---@type number
    local i = DCON.dcon_create_pop_location() + 1
            DATA.pop_location_indices_set[i] = i
    return i
end
function DATA.delete_pop_location(i)
    do
        local old_value = DATA.pop_location[i].location
        __REMOVE_KEY_POP_LOCATION_LOCATION(i, old_value)
    end
    do
        local old_value = DATA.pop_location[i].pop
        __REMOVE_KEY_POP_LOCATION_POP(old_value)
    end
    DATA.pop_location_indices_set[i] = nil
    return DCON.dcon_delete_pop_location(i - 1)
end
---@param func fun(item: pop_location_id) 
function DATA.for_each_pop_location(func)
    for _, item in pairs(DATA.pop_location_indices_set) do
        func(item)
    end
end
---@param func fun(item: pop_location_id):boolean 
---@return table<pop_location_id, pop_location_id> 
function DATA.filter_pop_location(func)
    ---@type table<pop_location_id, pop_location_id> 
    local t = {}
    for _, item in pairs(DATA.pop_location_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param pop_location_id pop_location_id valid pop_location id
---@return province_id location location of pop
function DATA.pop_location_get_location(pop_location_id)
    return DATA.pop_location[pop_location_id].location
end
---@param location province_id valid province_id
---@return pop_location_id[] An array of pop_location 
function DATA.get_pop_location_from_location(location)
    return DATA.pop_location_from_location[location]
end
---@param location province_id valid province_id
---@param func fun(item: pop_location_id) valid province_id
function DATA.for_each_pop_location_from_location(location, func)
    if DATA.pop_location_from_location[location] == nil then return end
    for _, item in pairs(DATA.pop_location_from_location[location]) do func(item) end
end
---@param location province_id valid province_id
---@param func fun(item: pop_location_id):boolean 
---@return table<pop_location_id, pop_location_id> 
function DATA.filter_array_pop_location_from_location(location, func)
    ---@type table<pop_location_id, pop_location_id> 
    local t = {}
    for _, item in pairs(DATA.pop_location_from_location[location]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param location province_id valid province_id
---@param func fun(item: pop_location_id):boolean 
---@return table<pop_location_id, pop_location_id> 
function DATA.filter_pop_location_from_location(location, func)
    ---@type table<pop_location_id, pop_location_id> 
    local t = {}
    for _, item in pairs(DATA.pop_location_from_location[location]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param pop_location_id pop_location_id valid pop_location id
---@param old_value province_id valid province_id
function __REMOVE_KEY_POP_LOCATION_LOCATION(pop_location_id, old_value)
    local found_key = nil
    if DATA.pop_location_from_location[old_value] == nil then
        DATA.pop_location_from_location[old_value] = {}
        return
    end
    for key, value in pairs(DATA.pop_location_from_location[old_value]) do
        if value == pop_location_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.pop_location_from_location[old_value], found_key)
    end
end
---@param pop_location_id pop_location_id valid pop_location id
---@param value province_id valid province_id
function DATA.pop_location_set_location(pop_location_id, value)
    local old_value = DATA.pop_location[pop_location_id].location
    DATA.pop_location[pop_location_id].location = value
    __REMOVE_KEY_POP_LOCATION_LOCATION(pop_location_id, old_value)
    if DATA.pop_location_from_location[value] == nil then DATA.pop_location_from_location[value] = {} end
    table.insert(DATA.pop_location_from_location[value], pop_location_id)
end
---@param pop_location_id pop_location_id valid pop_location id
---@return pop_id pop 
function DATA.pop_location_get_pop(pop_location_id)
    return DATA.pop_location[pop_location_id].pop
end
---@param pop pop_id valid pop_id
---@return pop_location_id pop_location 
function DATA.get_pop_location_from_pop(pop)
    if DATA.pop_location_from_pop[pop] == nil then return 0 end
    return DATA.pop_location_from_pop[pop]
end
function __REMOVE_KEY_POP_LOCATION_POP(old_value)
    DATA.pop_location_from_pop[old_value] = nil
end
---@param pop_location_id pop_location_id valid pop_location id
---@param value pop_id valid pop_id
function DATA.pop_location_set_pop(pop_location_id, value)
    local old_value = DATA.pop_location[pop_location_id].pop
    DATA.pop_location[pop_location_id].pop = value
    __REMOVE_KEY_POP_LOCATION_POP(old_value)
    DATA.pop_location_from_pop[value] = pop_location_id
end


local fat_pop_location_id_metatable = {
    __index = function (t,k)
        if (k == "location") then return DATA.pop_location_get_location(t.id) end
        if (k == "pop") then return DATA.pop_location_get_pop(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "location") then
            DATA.pop_location_set_location(t.id, v)
            return
        end
        if (k == "pop") then
            DATA.pop_location_set_pop(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id pop_location_id
---@return fat_pop_location_id fat_id
function DATA.fatten_pop_location(id)
    local result = {id = id}
    setmetatable(result, fat_pop_location_id_metatable)    return result
end
----------outlaw_location----------


---outlaw_location: LSP types---

---Unique identificator for outlaw_location entity
---@alias outlaw_location_id number

---@class (exact) fat_outlaw_location_id
---@field id outlaw_location_id Unique outlaw_location id
---@field location province_id location of the outlaw
---@field outlaw pop_id 

---@class struct_outlaw_location
---@field location province_id location of the outlaw
---@field outlaw pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t location;
        uint32_t outlaw;
    } outlaw_location;
void dcon_delete_outlaw_location(int32_t j);
int32_t dcon_create_outlaw_location();
void dcon_outlaw_location_resize(uint32_t sz);
]]

---outlaw_location: FFI arrays---
---@type nil
DATA.outlaw_location_calloc = ffi.C.calloc(1, ffi.sizeof("outlaw_location") * 300001)
---@type table<outlaw_location_id, struct_outlaw_location>
DATA.outlaw_location = ffi.cast("outlaw_location*", DATA.outlaw_location_calloc)
---@type table<province_id, outlaw_location_id[]>>
DATA.outlaw_location_from_location= {}
for i = 1, 300000 do
    DATA.outlaw_location_from_location[i] = {}
end
---@type table<pop_id, outlaw_location_id>
DATA.outlaw_location_from_outlaw= {}

---outlaw_location: LUA bindings---

DATA.outlaw_location_size = 300000
---@type table<outlaw_location_id, boolean>
local outlaw_location_indices_pool = ffi.new("bool[?]", 300000)
for i = 1, 299999 do
    outlaw_location_indices_pool[i] = true 
end
---@type table<outlaw_location_id, outlaw_location_id>
DATA.outlaw_location_indices_set = {}
function DATA.create_outlaw_location()
    ---@type number
    local i = DCON.dcon_create_outlaw_location() + 1
            DATA.outlaw_location_indices_set[i] = i
    return i
end
function DATA.delete_outlaw_location(i)
    do
        local old_value = DATA.outlaw_location[i].location
        __REMOVE_KEY_OUTLAW_LOCATION_LOCATION(i, old_value)
    end
    do
        local old_value = DATA.outlaw_location[i].outlaw
        __REMOVE_KEY_OUTLAW_LOCATION_OUTLAW(old_value)
    end
    DATA.outlaw_location_indices_set[i] = nil
    return DCON.dcon_delete_outlaw_location(i - 1)
end
---@param func fun(item: outlaw_location_id) 
function DATA.for_each_outlaw_location(func)
    for _, item in pairs(DATA.outlaw_location_indices_set) do
        func(item)
    end
end
---@param func fun(item: outlaw_location_id):boolean 
---@return table<outlaw_location_id, outlaw_location_id> 
function DATA.filter_outlaw_location(func)
    ---@type table<outlaw_location_id, outlaw_location_id> 
    local t = {}
    for _, item in pairs(DATA.outlaw_location_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param outlaw_location_id outlaw_location_id valid outlaw_location id
---@return province_id location location of the outlaw
function DATA.outlaw_location_get_location(outlaw_location_id)
    return DATA.outlaw_location[outlaw_location_id].location
end
---@param location province_id valid province_id
---@return outlaw_location_id[] An array of outlaw_location 
function DATA.get_outlaw_location_from_location(location)
    return DATA.outlaw_location_from_location[location]
end
---@param location province_id valid province_id
---@param func fun(item: outlaw_location_id) valid province_id
function DATA.for_each_outlaw_location_from_location(location, func)
    if DATA.outlaw_location_from_location[location] == nil then return end
    for _, item in pairs(DATA.outlaw_location_from_location[location]) do func(item) end
end
---@param location province_id valid province_id
---@param func fun(item: outlaw_location_id):boolean 
---@return table<outlaw_location_id, outlaw_location_id> 
function DATA.filter_array_outlaw_location_from_location(location, func)
    ---@type table<outlaw_location_id, outlaw_location_id> 
    local t = {}
    for _, item in pairs(DATA.outlaw_location_from_location[location]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param location province_id valid province_id
---@param func fun(item: outlaw_location_id):boolean 
---@return table<outlaw_location_id, outlaw_location_id> 
function DATA.filter_outlaw_location_from_location(location, func)
    ---@type table<outlaw_location_id, outlaw_location_id> 
    local t = {}
    for _, item in pairs(DATA.outlaw_location_from_location[location]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param outlaw_location_id outlaw_location_id valid outlaw_location id
---@param old_value province_id valid province_id
function __REMOVE_KEY_OUTLAW_LOCATION_LOCATION(outlaw_location_id, old_value)
    local found_key = nil
    if DATA.outlaw_location_from_location[old_value] == nil then
        DATA.outlaw_location_from_location[old_value] = {}
        return
    end
    for key, value in pairs(DATA.outlaw_location_from_location[old_value]) do
        if value == outlaw_location_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.outlaw_location_from_location[old_value], found_key)
    end
end
---@param outlaw_location_id outlaw_location_id valid outlaw_location id
---@param value province_id valid province_id
function DATA.outlaw_location_set_location(outlaw_location_id, value)
    local old_value = DATA.outlaw_location[outlaw_location_id].location
    DATA.outlaw_location[outlaw_location_id].location = value
    __REMOVE_KEY_OUTLAW_LOCATION_LOCATION(outlaw_location_id, old_value)
    if DATA.outlaw_location_from_location[value] == nil then DATA.outlaw_location_from_location[value] = {} end
    table.insert(DATA.outlaw_location_from_location[value], outlaw_location_id)
end
---@param outlaw_location_id outlaw_location_id valid outlaw_location id
---@return pop_id outlaw 
function DATA.outlaw_location_get_outlaw(outlaw_location_id)
    return DATA.outlaw_location[outlaw_location_id].outlaw
end
---@param outlaw pop_id valid pop_id
---@return outlaw_location_id outlaw_location 
function DATA.get_outlaw_location_from_outlaw(outlaw)
    if DATA.outlaw_location_from_outlaw[outlaw] == nil then return 0 end
    return DATA.outlaw_location_from_outlaw[outlaw]
end
function __REMOVE_KEY_OUTLAW_LOCATION_OUTLAW(old_value)
    DATA.outlaw_location_from_outlaw[old_value] = nil
end
---@param outlaw_location_id outlaw_location_id valid outlaw_location id
---@param value pop_id valid pop_id
function DATA.outlaw_location_set_outlaw(outlaw_location_id, value)
    local old_value = DATA.outlaw_location[outlaw_location_id].outlaw
    DATA.outlaw_location[outlaw_location_id].outlaw = value
    __REMOVE_KEY_OUTLAW_LOCATION_OUTLAW(old_value)
    DATA.outlaw_location_from_outlaw[value] = outlaw_location_id
end


local fat_outlaw_location_id_metatable = {
    __index = function (t,k)
        if (k == "location") then return DATA.outlaw_location_get_location(t.id) end
        if (k == "outlaw") then return DATA.outlaw_location_get_outlaw(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "location") then
            DATA.outlaw_location_set_location(t.id, v)
            return
        end
        if (k == "outlaw") then
            DATA.outlaw_location_set_outlaw(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id outlaw_location_id
---@return fat_outlaw_location_id fat_id
function DATA.fatten_outlaw_location(id)
    local result = {id = id}
    setmetatable(result, fat_outlaw_location_id_metatable)    return result
end
----------tile_province_membership----------


---tile_province_membership: LSP types---

---Unique identificator for tile_province_membership entity
---@alias tile_province_membership_id number

---@class (exact) fat_tile_province_membership_id
---@field id tile_province_membership_id Unique tile_province_membership id
---@field province province_id 
---@field tile tile_id 

---@class struct_tile_province_membership
---@field province province_id 
---@field tile tile_id 


ffi.cdef[[
    typedef struct {
        uint32_t province;
        uint32_t tile;
    } tile_province_membership;
void dcon_delete_tile_province_membership(int32_t j);
int32_t dcon_create_tile_province_membership();
void dcon_tile_province_membership_resize(uint32_t sz);
]]

---tile_province_membership: FFI arrays---
---@type nil
DATA.tile_province_membership_calloc = ffi.C.calloc(1, ffi.sizeof("tile_province_membership") * 1500001)
---@type table<tile_province_membership_id, struct_tile_province_membership>
DATA.tile_province_membership = ffi.cast("tile_province_membership*", DATA.tile_province_membership_calloc)
---@type table<province_id, tile_province_membership_id[]>>
DATA.tile_province_membership_from_province= {}
for i = 1, 1500000 do
    DATA.tile_province_membership_from_province[i] = {}
end
---@type table<tile_id, tile_province_membership_id>
DATA.tile_province_membership_from_tile= {}

---tile_province_membership: LUA bindings---

DATA.tile_province_membership_size = 1500000
---@type table<tile_province_membership_id, boolean>
local tile_province_membership_indices_pool = ffi.new("bool[?]", 1500000)
for i = 1, 1499999 do
    tile_province_membership_indices_pool[i] = true 
end
---@type table<tile_province_membership_id, tile_province_membership_id>
DATA.tile_province_membership_indices_set = {}
function DATA.create_tile_province_membership()
    ---@type number
    local i = DCON.dcon_create_tile_province_membership() + 1
            DATA.tile_province_membership_indices_set[i] = i
    return i
end
function DATA.delete_tile_province_membership(i)
    do
        local old_value = DATA.tile_province_membership[i].province
        __REMOVE_KEY_TILE_PROVINCE_MEMBERSHIP_PROVINCE(i, old_value)
    end
    do
        local old_value = DATA.tile_province_membership[i].tile
        __REMOVE_KEY_TILE_PROVINCE_MEMBERSHIP_TILE(old_value)
    end
    DATA.tile_province_membership_indices_set[i] = nil
    return DCON.dcon_delete_tile_province_membership(i - 1)
end
---@param func fun(item: tile_province_membership_id) 
function DATA.for_each_tile_province_membership(func)
    for _, item in pairs(DATA.tile_province_membership_indices_set) do
        func(item)
    end
end
---@param func fun(item: tile_province_membership_id):boolean 
---@return table<tile_province_membership_id, tile_province_membership_id> 
function DATA.filter_tile_province_membership(func)
    ---@type table<tile_province_membership_id, tile_province_membership_id> 
    local t = {}
    for _, item in pairs(DATA.tile_province_membership_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param tile_province_membership_id tile_province_membership_id valid tile_province_membership id
---@return province_id province 
function DATA.tile_province_membership_get_province(tile_province_membership_id)
    return DATA.tile_province_membership[tile_province_membership_id].province
end
---@param province province_id valid province_id
---@return tile_province_membership_id[] An array of tile_province_membership 
function DATA.get_tile_province_membership_from_province(province)
    return DATA.tile_province_membership_from_province[province]
end
---@param province province_id valid province_id
---@param func fun(item: tile_province_membership_id) valid province_id
function DATA.for_each_tile_province_membership_from_province(province, func)
    if DATA.tile_province_membership_from_province[province] == nil then return end
    for _, item in pairs(DATA.tile_province_membership_from_province[province]) do func(item) end
end
---@param province province_id valid province_id
---@param func fun(item: tile_province_membership_id):boolean 
---@return table<tile_province_membership_id, tile_province_membership_id> 
function DATA.filter_array_tile_province_membership_from_province(province, func)
    ---@type table<tile_province_membership_id, tile_province_membership_id> 
    local t = {}
    for _, item in pairs(DATA.tile_province_membership_from_province[province]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param province province_id valid province_id
---@param func fun(item: tile_province_membership_id):boolean 
---@return table<tile_province_membership_id, tile_province_membership_id> 
function DATA.filter_tile_province_membership_from_province(province, func)
    ---@type table<tile_province_membership_id, tile_province_membership_id> 
    local t = {}
    for _, item in pairs(DATA.tile_province_membership_from_province[province]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param tile_province_membership_id tile_province_membership_id valid tile_province_membership id
---@param old_value province_id valid province_id
function __REMOVE_KEY_TILE_PROVINCE_MEMBERSHIP_PROVINCE(tile_province_membership_id, old_value)
    local found_key = nil
    if DATA.tile_province_membership_from_province[old_value] == nil then
        DATA.tile_province_membership_from_province[old_value] = {}
        return
    end
    for key, value in pairs(DATA.tile_province_membership_from_province[old_value]) do
        if value == tile_province_membership_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.tile_province_membership_from_province[old_value], found_key)
    end
end
---@param tile_province_membership_id tile_province_membership_id valid tile_province_membership id
---@param value province_id valid province_id
function DATA.tile_province_membership_set_province(tile_province_membership_id, value)
    local old_value = DATA.tile_province_membership[tile_province_membership_id].province
    DATA.tile_province_membership[tile_province_membership_id].province = value
    __REMOVE_KEY_TILE_PROVINCE_MEMBERSHIP_PROVINCE(tile_province_membership_id, old_value)
    if DATA.tile_province_membership_from_province[value] == nil then DATA.tile_province_membership_from_province[value] = {} end
    table.insert(DATA.tile_province_membership_from_province[value], tile_province_membership_id)
end
---@param tile_province_membership_id tile_province_membership_id valid tile_province_membership id
---@return tile_id tile 
function DATA.tile_province_membership_get_tile(tile_province_membership_id)
    return DATA.tile_province_membership[tile_province_membership_id].tile
end
---@param tile tile_id valid tile_id
---@return tile_province_membership_id tile_province_membership 
function DATA.get_tile_province_membership_from_tile(tile)
    if DATA.tile_province_membership_from_tile[tile] == nil then return 0 end
    return DATA.tile_province_membership_from_tile[tile]
end
function __REMOVE_KEY_TILE_PROVINCE_MEMBERSHIP_TILE(old_value)
    DATA.tile_province_membership_from_tile[old_value] = nil
end
---@param tile_province_membership_id tile_province_membership_id valid tile_province_membership id
---@param value tile_id valid tile_id
function DATA.tile_province_membership_set_tile(tile_province_membership_id, value)
    local old_value = DATA.tile_province_membership[tile_province_membership_id].tile
    DATA.tile_province_membership[tile_province_membership_id].tile = value
    __REMOVE_KEY_TILE_PROVINCE_MEMBERSHIP_TILE(old_value)
    DATA.tile_province_membership_from_tile[value] = tile_province_membership_id
end


local fat_tile_province_membership_id_metatable = {
    __index = function (t,k)
        if (k == "province") then return DATA.tile_province_membership_get_province(t.id) end
        if (k == "tile") then return DATA.tile_province_membership_get_tile(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "province") then
            DATA.tile_province_membership_set_province(t.id, v)
            return
        end
        if (k == "tile") then
            DATA.tile_province_membership_set_tile(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id tile_province_membership_id
---@return fat_tile_province_membership_id fat_id
function DATA.fatten_tile_province_membership(id)
    local result = {id = id}
    setmetatable(result, fat_tile_province_membership_id_metatable)    return result
end
----------province_neighborhood----------


---province_neighborhood: LSP types---

---Unique identificator for province_neighborhood entity
---@alias province_neighborhood_id number

---@class (exact) fat_province_neighborhood_id
---@field id province_neighborhood_id Unique province_neighborhood id
---@field origin province_id 
---@field target province_id 

---@class struct_province_neighborhood
---@field origin province_id 
---@field target province_id 


ffi.cdef[[
    typedef struct {
        uint32_t origin;
        uint32_t target;
    } province_neighborhood;
void dcon_delete_province_neighborhood(int32_t j);
int32_t dcon_create_province_neighborhood();
void dcon_province_neighborhood_resize(uint32_t sz);
]]

---province_neighborhood: FFI arrays---
---@type nil
DATA.province_neighborhood_calloc = ffi.C.calloc(1, ffi.sizeof("province_neighborhood") * 250001)
---@type table<province_neighborhood_id, struct_province_neighborhood>
DATA.province_neighborhood = ffi.cast("province_neighborhood*", DATA.province_neighborhood_calloc)
---@type table<province_id, province_neighborhood_id[]>>
DATA.province_neighborhood_from_origin= {}
for i = 1, 250000 do
    DATA.province_neighborhood_from_origin[i] = {}
end
---@type table<province_id, province_neighborhood_id[]>>
DATA.province_neighborhood_from_target= {}
for i = 1, 250000 do
    DATA.province_neighborhood_from_target[i] = {}
end

---province_neighborhood: LUA bindings---

DATA.province_neighborhood_size = 250000
---@type table<province_neighborhood_id, boolean>
local province_neighborhood_indices_pool = ffi.new("bool[?]", 250000)
for i = 1, 249999 do
    province_neighborhood_indices_pool[i] = true 
end
---@type table<province_neighborhood_id, province_neighborhood_id>
DATA.province_neighborhood_indices_set = {}
function DATA.create_province_neighborhood()
    ---@type number
    local i = DCON.dcon_create_province_neighborhood() + 1
            DATA.province_neighborhood_indices_set[i] = i
    return i
end
function DATA.delete_province_neighborhood(i)
    do
        local old_value = DATA.province_neighborhood[i].origin
        __REMOVE_KEY_PROVINCE_NEIGHBORHOOD_ORIGIN(i, old_value)
    end
    do
        local old_value = DATA.province_neighborhood[i].target
        __REMOVE_KEY_PROVINCE_NEIGHBORHOOD_TARGET(i, old_value)
    end
    DATA.province_neighborhood_indices_set[i] = nil
    return DCON.dcon_delete_province_neighborhood(i - 1)
end
---@param func fun(item: province_neighborhood_id) 
function DATA.for_each_province_neighborhood(func)
    for _, item in pairs(DATA.province_neighborhood_indices_set) do
        func(item)
    end
end
---@param func fun(item: province_neighborhood_id):boolean 
---@return table<province_neighborhood_id, province_neighborhood_id> 
function DATA.filter_province_neighborhood(func)
    ---@type table<province_neighborhood_id, province_neighborhood_id> 
    local t = {}
    for _, item in pairs(DATA.province_neighborhood_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param province_neighborhood_id province_neighborhood_id valid province_neighborhood id
---@return province_id origin 
function DATA.province_neighborhood_get_origin(province_neighborhood_id)
    return DATA.province_neighborhood[province_neighborhood_id].origin
end
---@param origin province_id valid province_id
---@return province_neighborhood_id[] An array of province_neighborhood 
function DATA.get_province_neighborhood_from_origin(origin)
    return DATA.province_neighborhood_from_origin[origin]
end
---@param origin province_id valid province_id
---@param func fun(item: province_neighborhood_id) valid province_id
function DATA.for_each_province_neighborhood_from_origin(origin, func)
    if DATA.province_neighborhood_from_origin[origin] == nil then return end
    for _, item in pairs(DATA.province_neighborhood_from_origin[origin]) do func(item) end
end
---@param origin province_id valid province_id
---@param func fun(item: province_neighborhood_id):boolean 
---@return table<province_neighborhood_id, province_neighborhood_id> 
function DATA.filter_array_province_neighborhood_from_origin(origin, func)
    ---@type table<province_neighborhood_id, province_neighborhood_id> 
    local t = {}
    for _, item in pairs(DATA.province_neighborhood_from_origin[origin]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param origin province_id valid province_id
---@param func fun(item: province_neighborhood_id):boolean 
---@return table<province_neighborhood_id, province_neighborhood_id> 
function DATA.filter_province_neighborhood_from_origin(origin, func)
    ---@type table<province_neighborhood_id, province_neighborhood_id> 
    local t = {}
    for _, item in pairs(DATA.province_neighborhood_from_origin[origin]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param province_neighborhood_id province_neighborhood_id valid province_neighborhood id
---@param old_value province_id valid province_id
function __REMOVE_KEY_PROVINCE_NEIGHBORHOOD_ORIGIN(province_neighborhood_id, old_value)
    local found_key = nil
    if DATA.province_neighborhood_from_origin[old_value] == nil then
        DATA.province_neighborhood_from_origin[old_value] = {}
        return
    end
    for key, value in pairs(DATA.province_neighborhood_from_origin[old_value]) do
        if value == province_neighborhood_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.province_neighborhood_from_origin[old_value], found_key)
    end
end
---@param province_neighborhood_id province_neighborhood_id valid province_neighborhood id
---@param value province_id valid province_id
function DATA.province_neighborhood_set_origin(province_neighborhood_id, value)
    local old_value = DATA.province_neighborhood[province_neighborhood_id].origin
    DATA.province_neighborhood[province_neighborhood_id].origin = value
    __REMOVE_KEY_PROVINCE_NEIGHBORHOOD_ORIGIN(province_neighborhood_id, old_value)
    if DATA.province_neighborhood_from_origin[value] == nil then DATA.province_neighborhood_from_origin[value] = {} end
    table.insert(DATA.province_neighborhood_from_origin[value], province_neighborhood_id)
end
---@param province_neighborhood_id province_neighborhood_id valid province_neighborhood id
---@return province_id target 
function DATA.province_neighborhood_get_target(province_neighborhood_id)
    return DATA.province_neighborhood[province_neighborhood_id].target
end
---@param target province_id valid province_id
---@return province_neighborhood_id[] An array of province_neighborhood 
function DATA.get_province_neighborhood_from_target(target)
    return DATA.province_neighborhood_from_target[target]
end
---@param target province_id valid province_id
---@param func fun(item: province_neighborhood_id) valid province_id
function DATA.for_each_province_neighborhood_from_target(target, func)
    if DATA.province_neighborhood_from_target[target] == nil then return end
    for _, item in pairs(DATA.province_neighborhood_from_target[target]) do func(item) end
end
---@param target province_id valid province_id
---@param func fun(item: province_neighborhood_id):boolean 
---@return table<province_neighborhood_id, province_neighborhood_id> 
function DATA.filter_array_province_neighborhood_from_target(target, func)
    ---@type table<province_neighborhood_id, province_neighborhood_id> 
    local t = {}
    for _, item in pairs(DATA.province_neighborhood_from_target[target]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param target province_id valid province_id
---@param func fun(item: province_neighborhood_id):boolean 
---@return table<province_neighborhood_id, province_neighborhood_id> 
function DATA.filter_province_neighborhood_from_target(target, func)
    ---@type table<province_neighborhood_id, province_neighborhood_id> 
    local t = {}
    for _, item in pairs(DATA.province_neighborhood_from_target[target]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param province_neighborhood_id province_neighborhood_id valid province_neighborhood id
---@param old_value province_id valid province_id
function __REMOVE_KEY_PROVINCE_NEIGHBORHOOD_TARGET(province_neighborhood_id, old_value)
    local found_key = nil
    if DATA.province_neighborhood_from_target[old_value] == nil then
        DATA.province_neighborhood_from_target[old_value] = {}
        return
    end
    for key, value in pairs(DATA.province_neighborhood_from_target[old_value]) do
        if value == province_neighborhood_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.province_neighborhood_from_target[old_value], found_key)
    end
end
---@param province_neighborhood_id province_neighborhood_id valid province_neighborhood id
---@param value province_id valid province_id
function DATA.province_neighborhood_set_target(province_neighborhood_id, value)
    local old_value = DATA.province_neighborhood[province_neighborhood_id].target
    DATA.province_neighborhood[province_neighborhood_id].target = value
    __REMOVE_KEY_PROVINCE_NEIGHBORHOOD_TARGET(province_neighborhood_id, old_value)
    if DATA.province_neighborhood_from_target[value] == nil then DATA.province_neighborhood_from_target[value] = {} end
    table.insert(DATA.province_neighborhood_from_target[value], province_neighborhood_id)
end


local fat_province_neighborhood_id_metatable = {
    __index = function (t,k)
        if (k == "origin") then return DATA.province_neighborhood_get_origin(t.id) end
        if (k == "target") then return DATA.province_neighborhood_get_target(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "origin") then
            DATA.province_neighborhood_set_origin(t.id, v)
            return
        end
        if (k == "target") then
            DATA.province_neighborhood_set_target(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id province_neighborhood_id
---@return fat_province_neighborhood_id fat_id
function DATA.fatten_province_neighborhood(id)
    local result = {id = id}
    setmetatable(result, fat_province_neighborhood_id_metatable)    return result
end
----------parent_child_relation----------


---parent_child_relation: LSP types---

---Unique identificator for parent_child_relation entity
---@alias parent_child_relation_id number

---@class (exact) fat_parent_child_relation_id
---@field id parent_child_relation_id Unique parent_child_relation id
---@field parent pop_id 
---@field child pop_id 

---@class struct_parent_child_relation
---@field parent pop_id 
---@field child pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t parent;
        uint32_t child;
    } parent_child_relation;
void dcon_delete_parent_child_relation(int32_t j);
int32_t dcon_create_parent_child_relation();
void dcon_parent_child_relation_resize(uint32_t sz);
]]

---parent_child_relation: FFI arrays---
---@type nil
DATA.parent_child_relation_calloc = ffi.C.calloc(1, ffi.sizeof("parent_child_relation") * 900001)
---@type table<parent_child_relation_id, struct_parent_child_relation>
DATA.parent_child_relation = ffi.cast("parent_child_relation*", DATA.parent_child_relation_calloc)
---@type table<pop_id, parent_child_relation_id[]>>
DATA.parent_child_relation_from_parent= {}
for i = 1, 900000 do
    DATA.parent_child_relation_from_parent[i] = {}
end
---@type table<pop_id, parent_child_relation_id>
DATA.parent_child_relation_from_child= {}

---parent_child_relation: LUA bindings---

DATA.parent_child_relation_size = 900000
---@type table<parent_child_relation_id, boolean>
local parent_child_relation_indices_pool = ffi.new("bool[?]", 900000)
for i = 1, 899999 do
    parent_child_relation_indices_pool[i] = true 
end
---@type table<parent_child_relation_id, parent_child_relation_id>
DATA.parent_child_relation_indices_set = {}
function DATA.create_parent_child_relation()
    ---@type number
    local i = DCON.dcon_create_parent_child_relation() + 1
            DATA.parent_child_relation_indices_set[i] = i
    return i
end
function DATA.delete_parent_child_relation(i)
    do
        local old_value = DATA.parent_child_relation[i].parent
        __REMOVE_KEY_PARENT_CHILD_RELATION_PARENT(i, old_value)
    end
    do
        local old_value = DATA.parent_child_relation[i].child
        __REMOVE_KEY_PARENT_CHILD_RELATION_CHILD(old_value)
    end
    DATA.parent_child_relation_indices_set[i] = nil
    return DCON.dcon_delete_parent_child_relation(i - 1)
end
---@param func fun(item: parent_child_relation_id) 
function DATA.for_each_parent_child_relation(func)
    for _, item in pairs(DATA.parent_child_relation_indices_set) do
        func(item)
    end
end
---@param func fun(item: parent_child_relation_id):boolean 
---@return table<parent_child_relation_id, parent_child_relation_id> 
function DATA.filter_parent_child_relation(func)
    ---@type table<parent_child_relation_id, parent_child_relation_id> 
    local t = {}
    for _, item in pairs(DATA.parent_child_relation_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param parent_child_relation_id parent_child_relation_id valid parent_child_relation id
---@return pop_id parent 
function DATA.parent_child_relation_get_parent(parent_child_relation_id)
    return DATA.parent_child_relation[parent_child_relation_id].parent
end
---@param parent pop_id valid pop_id
---@return parent_child_relation_id[] An array of parent_child_relation 
function DATA.get_parent_child_relation_from_parent(parent)
    return DATA.parent_child_relation_from_parent[parent]
end
---@param parent pop_id valid pop_id
---@param func fun(item: parent_child_relation_id) valid pop_id
function DATA.for_each_parent_child_relation_from_parent(parent, func)
    if DATA.parent_child_relation_from_parent[parent] == nil then return end
    for _, item in pairs(DATA.parent_child_relation_from_parent[parent]) do func(item) end
end
---@param parent pop_id valid pop_id
---@param func fun(item: parent_child_relation_id):boolean 
---@return table<parent_child_relation_id, parent_child_relation_id> 
function DATA.filter_array_parent_child_relation_from_parent(parent, func)
    ---@type table<parent_child_relation_id, parent_child_relation_id> 
    local t = {}
    for _, item in pairs(DATA.parent_child_relation_from_parent[parent]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param parent pop_id valid pop_id
---@param func fun(item: parent_child_relation_id):boolean 
---@return table<parent_child_relation_id, parent_child_relation_id> 
function DATA.filter_parent_child_relation_from_parent(parent, func)
    ---@type table<parent_child_relation_id, parent_child_relation_id> 
    local t = {}
    for _, item in pairs(DATA.parent_child_relation_from_parent[parent]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param parent_child_relation_id parent_child_relation_id valid parent_child_relation id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_PARENT_CHILD_RELATION_PARENT(parent_child_relation_id, old_value)
    local found_key = nil
    if DATA.parent_child_relation_from_parent[old_value] == nil then
        DATA.parent_child_relation_from_parent[old_value] = {}
        return
    end
    for key, value in pairs(DATA.parent_child_relation_from_parent[old_value]) do
        if value == parent_child_relation_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.parent_child_relation_from_parent[old_value], found_key)
    end
end
---@param parent_child_relation_id parent_child_relation_id valid parent_child_relation id
---@param value pop_id valid pop_id
function DATA.parent_child_relation_set_parent(parent_child_relation_id, value)
    local old_value = DATA.parent_child_relation[parent_child_relation_id].parent
    DATA.parent_child_relation[parent_child_relation_id].parent = value
    __REMOVE_KEY_PARENT_CHILD_RELATION_PARENT(parent_child_relation_id, old_value)
    if DATA.parent_child_relation_from_parent[value] == nil then DATA.parent_child_relation_from_parent[value] = {} end
    table.insert(DATA.parent_child_relation_from_parent[value], parent_child_relation_id)
end
---@param parent_child_relation_id parent_child_relation_id valid parent_child_relation id
---@return pop_id child 
function DATA.parent_child_relation_get_child(parent_child_relation_id)
    return DATA.parent_child_relation[parent_child_relation_id].child
end
---@param child pop_id valid pop_id
---@return parent_child_relation_id parent_child_relation 
function DATA.get_parent_child_relation_from_child(child)
    if DATA.parent_child_relation_from_child[child] == nil then return 0 end
    return DATA.parent_child_relation_from_child[child]
end
function __REMOVE_KEY_PARENT_CHILD_RELATION_CHILD(old_value)
    DATA.parent_child_relation_from_child[old_value] = nil
end
---@param parent_child_relation_id parent_child_relation_id valid parent_child_relation id
---@param value pop_id valid pop_id
function DATA.parent_child_relation_set_child(parent_child_relation_id, value)
    local old_value = DATA.parent_child_relation[parent_child_relation_id].child
    DATA.parent_child_relation[parent_child_relation_id].child = value
    __REMOVE_KEY_PARENT_CHILD_RELATION_CHILD(old_value)
    DATA.parent_child_relation_from_child[value] = parent_child_relation_id
end


local fat_parent_child_relation_id_metatable = {
    __index = function (t,k)
        if (k == "parent") then return DATA.parent_child_relation_get_parent(t.id) end
        if (k == "child") then return DATA.parent_child_relation_get_child(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "parent") then
            DATA.parent_child_relation_set_parent(t.id, v)
            return
        end
        if (k == "child") then
            DATA.parent_child_relation_set_child(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id parent_child_relation_id
---@return fat_parent_child_relation_id fat_id
function DATA.fatten_parent_child_relation(id)
    local result = {id = id}
    setmetatable(result, fat_parent_child_relation_id_metatable)    return result
end
----------loyalty----------


---loyalty: LSP types---

---Unique identificator for loyalty entity
---@alias loyalty_id number

---@class (exact) fat_loyalty_id
---@field id loyalty_id Unique loyalty id
---@field top pop_id 
---@field bottom pop_id 

---@class struct_loyalty
---@field top pop_id 
---@field bottom pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t top;
        uint32_t bottom;
    } loyalty;
void dcon_delete_loyalty(int32_t j);
int32_t dcon_create_loyalty();
void dcon_loyalty_resize(uint32_t sz);
]]

---loyalty: FFI arrays---
---@type nil
DATA.loyalty_calloc = ffi.C.calloc(1, ffi.sizeof("loyalty") * 10001)
---@type table<loyalty_id, struct_loyalty>
DATA.loyalty = ffi.cast("loyalty*", DATA.loyalty_calloc)
---@type table<pop_id, loyalty_id[]>>
DATA.loyalty_from_top= {}
for i = 1, 10000 do
    DATA.loyalty_from_top[i] = {}
end
---@type table<pop_id, loyalty_id>
DATA.loyalty_from_bottom= {}

---loyalty: LUA bindings---

DATA.loyalty_size = 10000
---@type table<loyalty_id, boolean>
local loyalty_indices_pool = ffi.new("bool[?]", 10000)
for i = 1, 9999 do
    loyalty_indices_pool[i] = true 
end
---@type table<loyalty_id, loyalty_id>
DATA.loyalty_indices_set = {}
function DATA.create_loyalty()
    ---@type number
    local i = DCON.dcon_create_loyalty() + 1
            DATA.loyalty_indices_set[i] = i
    return i
end
function DATA.delete_loyalty(i)
    do
        local old_value = DATA.loyalty[i].top
        __REMOVE_KEY_LOYALTY_TOP(i, old_value)
    end
    do
        local old_value = DATA.loyalty[i].bottom
        __REMOVE_KEY_LOYALTY_BOTTOM(old_value)
    end
    DATA.loyalty_indices_set[i] = nil
    return DCON.dcon_delete_loyalty(i - 1)
end
---@param func fun(item: loyalty_id) 
function DATA.for_each_loyalty(func)
    for _, item in pairs(DATA.loyalty_indices_set) do
        func(item)
    end
end
---@param func fun(item: loyalty_id):boolean 
---@return table<loyalty_id, loyalty_id> 
function DATA.filter_loyalty(func)
    ---@type table<loyalty_id, loyalty_id> 
    local t = {}
    for _, item in pairs(DATA.loyalty_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param loyalty_id loyalty_id valid loyalty id
---@return pop_id top 
function DATA.loyalty_get_top(loyalty_id)
    return DATA.loyalty[loyalty_id].top
end
---@param top pop_id valid pop_id
---@return loyalty_id[] An array of loyalty 
function DATA.get_loyalty_from_top(top)
    return DATA.loyalty_from_top[top]
end
---@param top pop_id valid pop_id
---@param func fun(item: loyalty_id) valid pop_id
function DATA.for_each_loyalty_from_top(top, func)
    if DATA.loyalty_from_top[top] == nil then return end
    for _, item in pairs(DATA.loyalty_from_top[top]) do func(item) end
end
---@param top pop_id valid pop_id
---@param func fun(item: loyalty_id):boolean 
---@return table<loyalty_id, loyalty_id> 
function DATA.filter_array_loyalty_from_top(top, func)
    ---@type table<loyalty_id, loyalty_id> 
    local t = {}
    for _, item in pairs(DATA.loyalty_from_top[top]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param top pop_id valid pop_id
---@param func fun(item: loyalty_id):boolean 
---@return table<loyalty_id, loyalty_id> 
function DATA.filter_loyalty_from_top(top, func)
    ---@type table<loyalty_id, loyalty_id> 
    local t = {}
    for _, item in pairs(DATA.loyalty_from_top[top]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param loyalty_id loyalty_id valid loyalty id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_LOYALTY_TOP(loyalty_id, old_value)
    local found_key = nil
    if DATA.loyalty_from_top[old_value] == nil then
        DATA.loyalty_from_top[old_value] = {}
        return
    end
    for key, value in pairs(DATA.loyalty_from_top[old_value]) do
        if value == loyalty_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.loyalty_from_top[old_value], found_key)
    end
end
---@param loyalty_id loyalty_id valid loyalty id
---@param value pop_id valid pop_id
function DATA.loyalty_set_top(loyalty_id, value)
    local old_value = DATA.loyalty[loyalty_id].top
    DATA.loyalty[loyalty_id].top = value
    __REMOVE_KEY_LOYALTY_TOP(loyalty_id, old_value)
    if DATA.loyalty_from_top[value] == nil then DATA.loyalty_from_top[value] = {} end
    table.insert(DATA.loyalty_from_top[value], loyalty_id)
end
---@param loyalty_id loyalty_id valid loyalty id
---@return pop_id bottom 
function DATA.loyalty_get_bottom(loyalty_id)
    return DATA.loyalty[loyalty_id].bottom
end
---@param bottom pop_id valid pop_id
---@return loyalty_id loyalty 
function DATA.get_loyalty_from_bottom(bottom)
    if DATA.loyalty_from_bottom[bottom] == nil then return 0 end
    return DATA.loyalty_from_bottom[bottom]
end
function __REMOVE_KEY_LOYALTY_BOTTOM(old_value)
    DATA.loyalty_from_bottom[old_value] = nil
end
---@param loyalty_id loyalty_id valid loyalty id
---@param value pop_id valid pop_id
function DATA.loyalty_set_bottom(loyalty_id, value)
    local old_value = DATA.loyalty[loyalty_id].bottom
    DATA.loyalty[loyalty_id].bottom = value
    __REMOVE_KEY_LOYALTY_BOTTOM(old_value)
    DATA.loyalty_from_bottom[value] = loyalty_id
end


local fat_loyalty_id_metatable = {
    __index = function (t,k)
        if (k == "top") then return DATA.loyalty_get_top(t.id) end
        if (k == "bottom") then return DATA.loyalty_get_bottom(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "top") then
            DATA.loyalty_set_top(t.id, v)
            return
        end
        if (k == "bottom") then
            DATA.loyalty_set_bottom(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id loyalty_id
---@return fat_loyalty_id fat_id
function DATA.fatten_loyalty(id)
    local result = {id = id}
    setmetatable(result, fat_loyalty_id_metatable)    return result
end
----------succession----------


---succession: LSP types---

---Unique identificator for succession entity
---@alias succession_id number

---@class (exact) fat_succession_id
---@field id succession_id Unique succession id
---@field successor_of pop_id 
---@field successor pop_id 

---@class struct_succession
---@field successor_of pop_id 
---@field successor pop_id 


ffi.cdef[[
    typedef struct {
        uint32_t successor_of;
        uint32_t successor;
    } succession;
void dcon_delete_succession(int32_t j);
int32_t dcon_create_succession();
void dcon_succession_resize(uint32_t sz);
]]

---succession: FFI arrays---
---@type nil
DATA.succession_calloc = ffi.C.calloc(1, ffi.sizeof("succession") * 10001)
---@type table<succession_id, struct_succession>
DATA.succession = ffi.cast("succession*", DATA.succession_calloc)
---@type table<pop_id, succession_id>
DATA.succession_from_successor_of= {}
---@type table<pop_id, succession_id[]>>
DATA.succession_from_successor= {}
for i = 1, 10000 do
    DATA.succession_from_successor[i] = {}
end

---succession: LUA bindings---

DATA.succession_size = 10000
---@type table<succession_id, boolean>
local succession_indices_pool = ffi.new("bool[?]", 10000)
for i = 1, 9999 do
    succession_indices_pool[i] = true 
end
---@type table<succession_id, succession_id>
DATA.succession_indices_set = {}
function DATA.create_succession()
    ---@type number
    local i = DCON.dcon_create_succession() + 1
            DATA.succession_indices_set[i] = i
    return i
end
function DATA.delete_succession(i)
    do
        local old_value = DATA.succession[i].successor_of
        __REMOVE_KEY_SUCCESSION_SUCCESSOR_OF(old_value)
    end
    do
        local old_value = DATA.succession[i].successor
        __REMOVE_KEY_SUCCESSION_SUCCESSOR(i, old_value)
    end
    DATA.succession_indices_set[i] = nil
    return DCON.dcon_delete_succession(i - 1)
end
---@param func fun(item: succession_id) 
function DATA.for_each_succession(func)
    for _, item in pairs(DATA.succession_indices_set) do
        func(item)
    end
end
---@param func fun(item: succession_id):boolean 
---@return table<succession_id, succession_id> 
function DATA.filter_succession(func)
    ---@type table<succession_id, succession_id> 
    local t = {}
    for _, item in pairs(DATA.succession_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param succession_id succession_id valid succession id
---@return pop_id successor_of 
function DATA.succession_get_successor_of(succession_id)
    return DATA.succession[succession_id].successor_of
end
---@param successor_of pop_id valid pop_id
---@return succession_id succession 
function DATA.get_succession_from_successor_of(successor_of)
    if DATA.succession_from_successor_of[successor_of] == nil then return 0 end
    return DATA.succession_from_successor_of[successor_of]
end
function __REMOVE_KEY_SUCCESSION_SUCCESSOR_OF(old_value)
    DATA.succession_from_successor_of[old_value] = nil
end
---@param succession_id succession_id valid succession id
---@param value pop_id valid pop_id
function DATA.succession_set_successor_of(succession_id, value)
    local old_value = DATA.succession[succession_id].successor_of
    DATA.succession[succession_id].successor_of = value
    __REMOVE_KEY_SUCCESSION_SUCCESSOR_OF(old_value)
    DATA.succession_from_successor_of[value] = succession_id
end
---@param succession_id succession_id valid succession id
---@return pop_id successor 
function DATA.succession_get_successor(succession_id)
    return DATA.succession[succession_id].successor
end
---@param successor pop_id valid pop_id
---@return succession_id[] An array of succession 
function DATA.get_succession_from_successor(successor)
    return DATA.succession_from_successor[successor]
end
---@param successor pop_id valid pop_id
---@param func fun(item: succession_id) valid pop_id
function DATA.for_each_succession_from_successor(successor, func)
    if DATA.succession_from_successor[successor] == nil then return end
    for _, item in pairs(DATA.succession_from_successor[successor]) do func(item) end
end
---@param successor pop_id valid pop_id
---@param func fun(item: succession_id):boolean 
---@return table<succession_id, succession_id> 
function DATA.filter_array_succession_from_successor(successor, func)
    ---@type table<succession_id, succession_id> 
    local t = {}
    for _, item in pairs(DATA.succession_from_successor[successor]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param successor pop_id valid pop_id
---@param func fun(item: succession_id):boolean 
---@return table<succession_id, succession_id> 
function DATA.filter_succession_from_successor(successor, func)
    ---@type table<succession_id, succession_id> 
    local t = {}
    for _, item in pairs(DATA.succession_from_successor[successor]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param succession_id succession_id valid succession id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_SUCCESSION_SUCCESSOR(succession_id, old_value)
    local found_key = nil
    if DATA.succession_from_successor[old_value] == nil then
        DATA.succession_from_successor[old_value] = {}
        return
    end
    for key, value in pairs(DATA.succession_from_successor[old_value]) do
        if value == succession_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.succession_from_successor[old_value], found_key)
    end
end
---@param succession_id succession_id valid succession id
---@param value pop_id valid pop_id
function DATA.succession_set_successor(succession_id, value)
    local old_value = DATA.succession[succession_id].successor
    DATA.succession[succession_id].successor = value
    __REMOVE_KEY_SUCCESSION_SUCCESSOR(succession_id, old_value)
    if DATA.succession_from_successor[value] == nil then DATA.succession_from_successor[value] = {} end
    table.insert(DATA.succession_from_successor[value], succession_id)
end


local fat_succession_id_metatable = {
    __index = function (t,k)
        if (k == "successor_of") then return DATA.succession_get_successor_of(t.id) end
        if (k == "successor") then return DATA.succession_get_successor(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "successor_of") then
            DATA.succession_set_successor_of(t.id, v)
            return
        end
        if (k == "successor") then
            DATA.succession_set_successor(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id succession_id
---@return fat_succession_id fat_id
function DATA.fatten_succession(id)
    local result = {id = id}
    setmetatable(result, fat_succession_id_metatable)    return result
end
----------realm_armies----------


---realm_armies: LSP types---

---Unique identificator for realm_armies entity
---@alias realm_armies_id number

---@class (exact) fat_realm_armies_id
---@field id realm_armies_id Unique realm_armies id
---@field realm realm_id 
---@field army army_id 

---@class struct_realm_armies
---@field realm realm_id 
---@field army army_id 


ffi.cdef[[
    typedef struct {
        uint32_t realm;
        uint32_t army;
    } realm_armies;
void dcon_delete_realm_armies(int32_t j);
int32_t dcon_create_realm_armies();
void dcon_realm_armies_resize(uint32_t sz);
]]

---realm_armies: FFI arrays---
---@type nil
DATA.realm_armies_calloc = ffi.C.calloc(1, ffi.sizeof("realm_armies") * 15001)
---@type table<realm_armies_id, struct_realm_armies>
DATA.realm_armies = ffi.cast("realm_armies*", DATA.realm_armies_calloc)
---@type table<realm_id, realm_armies_id[]>>
DATA.realm_armies_from_realm= {}
for i = 1, 15000 do
    DATA.realm_armies_from_realm[i] = {}
end
---@type table<army_id, realm_armies_id>
DATA.realm_armies_from_army= {}

---realm_armies: LUA bindings---

DATA.realm_armies_size = 15000
---@type table<realm_armies_id, boolean>
local realm_armies_indices_pool = ffi.new("bool[?]", 15000)
for i = 1, 14999 do
    realm_armies_indices_pool[i] = true 
end
---@type table<realm_armies_id, realm_armies_id>
DATA.realm_armies_indices_set = {}
function DATA.create_realm_armies()
    ---@type number
    local i = DCON.dcon_create_realm_armies() + 1
            DATA.realm_armies_indices_set[i] = i
    return i
end
function DATA.delete_realm_armies(i)
    do
        local old_value = DATA.realm_armies[i].realm
        __REMOVE_KEY_REALM_ARMIES_REALM(i, old_value)
    end
    do
        local old_value = DATA.realm_armies[i].army
        __REMOVE_KEY_REALM_ARMIES_ARMY(old_value)
    end
    DATA.realm_armies_indices_set[i] = nil
    return DCON.dcon_delete_realm_armies(i - 1)
end
---@param func fun(item: realm_armies_id) 
function DATA.for_each_realm_armies(func)
    for _, item in pairs(DATA.realm_armies_indices_set) do
        func(item)
    end
end
---@param func fun(item: realm_armies_id):boolean 
---@return table<realm_armies_id, realm_armies_id> 
function DATA.filter_realm_armies(func)
    ---@type table<realm_armies_id, realm_armies_id> 
    local t = {}
    for _, item in pairs(DATA.realm_armies_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param realm_armies_id realm_armies_id valid realm_armies id
---@return realm_id realm 
function DATA.realm_armies_get_realm(realm_armies_id)
    return DATA.realm_armies[realm_armies_id].realm
end
---@param realm realm_id valid realm_id
---@return realm_armies_id[] An array of realm_armies 
function DATA.get_realm_armies_from_realm(realm)
    return DATA.realm_armies_from_realm[realm]
end
---@param realm realm_id valid realm_id
---@param func fun(item: realm_armies_id) valid realm_id
function DATA.for_each_realm_armies_from_realm(realm, func)
    if DATA.realm_armies_from_realm[realm] == nil then return end
    for _, item in pairs(DATA.realm_armies_from_realm[realm]) do func(item) end
end
---@param realm realm_id valid realm_id
---@param func fun(item: realm_armies_id):boolean 
---@return table<realm_armies_id, realm_armies_id> 
function DATA.filter_array_realm_armies_from_realm(realm, func)
    ---@type table<realm_armies_id, realm_armies_id> 
    local t = {}
    for _, item in pairs(DATA.realm_armies_from_realm[realm]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param realm realm_id valid realm_id
---@param func fun(item: realm_armies_id):boolean 
---@return table<realm_armies_id, realm_armies_id> 
function DATA.filter_realm_armies_from_realm(realm, func)
    ---@type table<realm_armies_id, realm_armies_id> 
    local t = {}
    for _, item in pairs(DATA.realm_armies_from_realm[realm]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param realm_armies_id realm_armies_id valid realm_armies id
---@param old_value realm_id valid realm_id
function __REMOVE_KEY_REALM_ARMIES_REALM(realm_armies_id, old_value)
    local found_key = nil
    if DATA.realm_armies_from_realm[old_value] == nil then
        DATA.realm_armies_from_realm[old_value] = {}
        return
    end
    for key, value in pairs(DATA.realm_armies_from_realm[old_value]) do
        if value == realm_armies_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.realm_armies_from_realm[old_value], found_key)
    end
end
---@param realm_armies_id realm_armies_id valid realm_armies id
---@param value realm_id valid realm_id
function DATA.realm_armies_set_realm(realm_armies_id, value)
    local old_value = DATA.realm_armies[realm_armies_id].realm
    DATA.realm_armies[realm_armies_id].realm = value
    __REMOVE_KEY_REALM_ARMIES_REALM(realm_armies_id, old_value)
    if DATA.realm_armies_from_realm[value] == nil then DATA.realm_armies_from_realm[value] = {} end
    table.insert(DATA.realm_armies_from_realm[value], realm_armies_id)
end
---@param realm_armies_id realm_armies_id valid realm_armies id
---@return army_id army 
function DATA.realm_armies_get_army(realm_armies_id)
    return DATA.realm_armies[realm_armies_id].army
end
---@param army army_id valid army_id
---@return realm_armies_id realm_armies 
function DATA.get_realm_armies_from_army(army)
    if DATA.realm_armies_from_army[army] == nil then return 0 end
    return DATA.realm_armies_from_army[army]
end
function __REMOVE_KEY_REALM_ARMIES_ARMY(old_value)
    DATA.realm_armies_from_army[old_value] = nil
end
---@param realm_armies_id realm_armies_id valid realm_armies id
---@param value army_id valid army_id
function DATA.realm_armies_set_army(realm_armies_id, value)
    local old_value = DATA.realm_armies[realm_armies_id].army
    DATA.realm_armies[realm_armies_id].army = value
    __REMOVE_KEY_REALM_ARMIES_ARMY(old_value)
    DATA.realm_armies_from_army[value] = realm_armies_id
end


local fat_realm_armies_id_metatable = {
    __index = function (t,k)
        if (k == "realm") then return DATA.realm_armies_get_realm(t.id) end
        if (k == "army") then return DATA.realm_armies_get_army(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "realm") then
            DATA.realm_armies_set_realm(t.id, v)
            return
        end
        if (k == "army") then
            DATA.realm_armies_set_army(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id realm_armies_id
---@return fat_realm_armies_id fat_id
function DATA.fatten_realm_armies(id)
    local result = {id = id}
    setmetatable(result, fat_realm_armies_id_metatable)    return result
end
----------realm_guard----------


---realm_guard: LSP types---

---Unique identificator for realm_guard entity
---@alias realm_guard_id number

---@class (exact) fat_realm_guard_id
---@field id realm_guard_id Unique realm_guard id
---@field guard warband_id 
---@field realm realm_id 

---@class struct_realm_guard
---@field guard warband_id 
---@field realm realm_id 


ffi.cdef[[
    typedef struct {
        uint32_t guard;
        uint32_t realm;
    } realm_guard;
void dcon_delete_realm_guard(int32_t j);
int32_t dcon_create_realm_guard();
void dcon_realm_guard_resize(uint32_t sz);
]]

---realm_guard: FFI arrays---
---@type nil
DATA.realm_guard_calloc = ffi.C.calloc(1, ffi.sizeof("realm_guard") * 15001)
---@type table<realm_guard_id, struct_realm_guard>
DATA.realm_guard = ffi.cast("realm_guard*", DATA.realm_guard_calloc)
---@type table<warband_id, realm_guard_id>
DATA.realm_guard_from_guard= {}
---@type table<realm_id, realm_guard_id>
DATA.realm_guard_from_realm= {}

---realm_guard: LUA bindings---

DATA.realm_guard_size = 15000
---@type table<realm_guard_id, boolean>
local realm_guard_indices_pool = ffi.new("bool[?]", 15000)
for i = 1, 14999 do
    realm_guard_indices_pool[i] = true 
end
---@type table<realm_guard_id, realm_guard_id>
DATA.realm_guard_indices_set = {}
function DATA.create_realm_guard()
    ---@type number
    local i = DCON.dcon_create_realm_guard() + 1
            DATA.realm_guard_indices_set[i] = i
    return i
end
function DATA.delete_realm_guard(i)
    do
        local old_value = DATA.realm_guard[i].guard
        __REMOVE_KEY_REALM_GUARD_GUARD(old_value)
    end
    do
        local old_value = DATA.realm_guard[i].realm
        __REMOVE_KEY_REALM_GUARD_REALM(old_value)
    end
    DATA.realm_guard_indices_set[i] = nil
    return DCON.dcon_delete_realm_guard(i - 1)
end
---@param func fun(item: realm_guard_id) 
function DATA.for_each_realm_guard(func)
    for _, item in pairs(DATA.realm_guard_indices_set) do
        func(item)
    end
end
---@param func fun(item: realm_guard_id):boolean 
---@return table<realm_guard_id, realm_guard_id> 
function DATA.filter_realm_guard(func)
    ---@type table<realm_guard_id, realm_guard_id> 
    local t = {}
    for _, item in pairs(DATA.realm_guard_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param realm_guard_id realm_guard_id valid realm_guard id
---@return warband_id guard 
function DATA.realm_guard_get_guard(realm_guard_id)
    return DATA.realm_guard[realm_guard_id].guard
end
---@param guard warband_id valid warband_id
---@return realm_guard_id realm_guard 
function DATA.get_realm_guard_from_guard(guard)
    if DATA.realm_guard_from_guard[guard] == nil then return 0 end
    return DATA.realm_guard_from_guard[guard]
end
function __REMOVE_KEY_REALM_GUARD_GUARD(old_value)
    DATA.realm_guard_from_guard[old_value] = nil
end
---@param realm_guard_id realm_guard_id valid realm_guard id
---@param value warband_id valid warband_id
function DATA.realm_guard_set_guard(realm_guard_id, value)
    local old_value = DATA.realm_guard[realm_guard_id].guard
    DATA.realm_guard[realm_guard_id].guard = value
    __REMOVE_KEY_REALM_GUARD_GUARD(old_value)
    DATA.realm_guard_from_guard[value] = realm_guard_id
end
---@param realm_guard_id realm_guard_id valid realm_guard id
---@return realm_id realm 
function DATA.realm_guard_get_realm(realm_guard_id)
    return DATA.realm_guard[realm_guard_id].realm
end
---@param realm realm_id valid realm_id
---@return realm_guard_id realm_guard 
function DATA.get_realm_guard_from_realm(realm)
    if DATA.realm_guard_from_realm[realm] == nil then return 0 end
    return DATA.realm_guard_from_realm[realm]
end
function __REMOVE_KEY_REALM_GUARD_REALM(old_value)
    DATA.realm_guard_from_realm[old_value] = nil
end
---@param realm_guard_id realm_guard_id valid realm_guard id
---@param value realm_id valid realm_id
function DATA.realm_guard_set_realm(realm_guard_id, value)
    local old_value = DATA.realm_guard[realm_guard_id].realm
    DATA.realm_guard[realm_guard_id].realm = value
    __REMOVE_KEY_REALM_GUARD_REALM(old_value)
    DATA.realm_guard_from_realm[value] = realm_guard_id
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
    setmetatable(result, fat_realm_guard_id_metatable)    return result
end
----------realm_overseer----------


---realm_overseer: LSP types---

---Unique identificator for realm_overseer entity
---@alias realm_overseer_id number

---@class (exact) fat_realm_overseer_id
---@field id realm_overseer_id Unique realm_overseer id
---@field overseer pop_id 
---@field realm realm_id 

---@class struct_realm_overseer
---@field overseer pop_id 
---@field realm realm_id 


ffi.cdef[[
    typedef struct {
        uint32_t overseer;
        uint32_t realm;
    } realm_overseer;
void dcon_delete_realm_overseer(int32_t j);
int32_t dcon_create_realm_overseer();
void dcon_realm_overseer_resize(uint32_t sz);
]]

---realm_overseer: FFI arrays---
---@type nil
DATA.realm_overseer_calloc = ffi.C.calloc(1, ffi.sizeof("realm_overseer") * 15001)
---@type table<realm_overseer_id, struct_realm_overseer>
DATA.realm_overseer = ffi.cast("realm_overseer*", DATA.realm_overseer_calloc)
---@type table<pop_id, realm_overseer_id>
DATA.realm_overseer_from_overseer= {}
---@type table<realm_id, realm_overseer_id>
DATA.realm_overseer_from_realm= {}

---realm_overseer: LUA bindings---

DATA.realm_overseer_size = 15000
---@type table<realm_overseer_id, boolean>
local realm_overseer_indices_pool = ffi.new("bool[?]", 15000)
for i = 1, 14999 do
    realm_overseer_indices_pool[i] = true 
end
---@type table<realm_overseer_id, realm_overseer_id>
DATA.realm_overseer_indices_set = {}
function DATA.create_realm_overseer()
    ---@type number
    local i = DCON.dcon_create_realm_overseer() + 1
            DATA.realm_overseer_indices_set[i] = i
    return i
end
function DATA.delete_realm_overseer(i)
    do
        local old_value = DATA.realm_overseer[i].overseer
        __REMOVE_KEY_REALM_OVERSEER_OVERSEER(old_value)
    end
    do
        local old_value = DATA.realm_overseer[i].realm
        __REMOVE_KEY_REALM_OVERSEER_REALM(old_value)
    end
    DATA.realm_overseer_indices_set[i] = nil
    return DCON.dcon_delete_realm_overseer(i - 1)
end
---@param func fun(item: realm_overseer_id) 
function DATA.for_each_realm_overseer(func)
    for _, item in pairs(DATA.realm_overseer_indices_set) do
        func(item)
    end
end
---@param func fun(item: realm_overseer_id):boolean 
---@return table<realm_overseer_id, realm_overseer_id> 
function DATA.filter_realm_overseer(func)
    ---@type table<realm_overseer_id, realm_overseer_id> 
    local t = {}
    for _, item in pairs(DATA.realm_overseer_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param realm_overseer_id realm_overseer_id valid realm_overseer id
---@return pop_id overseer 
function DATA.realm_overseer_get_overseer(realm_overseer_id)
    return DATA.realm_overseer[realm_overseer_id].overseer
end
---@param overseer pop_id valid pop_id
---@return realm_overseer_id realm_overseer 
function DATA.get_realm_overseer_from_overseer(overseer)
    if DATA.realm_overseer_from_overseer[overseer] == nil then return 0 end
    return DATA.realm_overseer_from_overseer[overseer]
end
function __REMOVE_KEY_REALM_OVERSEER_OVERSEER(old_value)
    DATA.realm_overseer_from_overseer[old_value] = nil
end
---@param realm_overseer_id realm_overseer_id valid realm_overseer id
---@param value pop_id valid pop_id
function DATA.realm_overseer_set_overseer(realm_overseer_id, value)
    local old_value = DATA.realm_overseer[realm_overseer_id].overseer
    DATA.realm_overseer[realm_overseer_id].overseer = value
    __REMOVE_KEY_REALM_OVERSEER_OVERSEER(old_value)
    DATA.realm_overseer_from_overseer[value] = realm_overseer_id
end
---@param realm_overseer_id realm_overseer_id valid realm_overseer id
---@return realm_id realm 
function DATA.realm_overseer_get_realm(realm_overseer_id)
    return DATA.realm_overseer[realm_overseer_id].realm
end
---@param realm realm_id valid realm_id
---@return realm_overseer_id realm_overseer 
function DATA.get_realm_overseer_from_realm(realm)
    if DATA.realm_overseer_from_realm[realm] == nil then return 0 end
    return DATA.realm_overseer_from_realm[realm]
end
function __REMOVE_KEY_REALM_OVERSEER_REALM(old_value)
    DATA.realm_overseer_from_realm[old_value] = nil
end
---@param realm_overseer_id realm_overseer_id valid realm_overseer id
---@param value realm_id valid realm_id
function DATA.realm_overseer_set_realm(realm_overseer_id, value)
    local old_value = DATA.realm_overseer[realm_overseer_id].realm
    DATA.realm_overseer[realm_overseer_id].realm = value
    __REMOVE_KEY_REALM_OVERSEER_REALM(old_value)
    DATA.realm_overseer_from_realm[value] = realm_overseer_id
end


local fat_realm_overseer_id_metatable = {
    __index = function (t,k)
        if (k == "overseer") then return DATA.realm_overseer_get_overseer(t.id) end
        if (k == "realm") then return DATA.realm_overseer_get_realm(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "overseer") then
            DATA.realm_overseer_set_overseer(t.id, v)
            return
        end
        if (k == "realm") then
            DATA.realm_overseer_set_realm(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id realm_overseer_id
---@return fat_realm_overseer_id fat_id
function DATA.fatten_realm_overseer(id)
    local result = {id = id}
    setmetatable(result, fat_realm_overseer_id_metatable)    return result
end
----------realm_leadership----------


---realm_leadership: LSP types---

---Unique identificator for realm_leadership entity
---@alias realm_leadership_id number

---@class (exact) fat_realm_leadership_id
---@field id realm_leadership_id Unique realm_leadership id
---@field leader pop_id 
---@field realm realm_id 

---@class struct_realm_leadership
---@field leader pop_id 
---@field realm realm_id 


ffi.cdef[[
    typedef struct {
        uint32_t leader;
        uint32_t realm;
    } realm_leadership;
void dcon_delete_realm_leadership(int32_t j);
int32_t dcon_create_realm_leadership();
void dcon_realm_leadership_resize(uint32_t sz);
]]

---realm_leadership: FFI arrays---
---@type nil
DATA.realm_leadership_calloc = ffi.C.calloc(1, ffi.sizeof("realm_leadership") * 15001)
---@type table<realm_leadership_id, struct_realm_leadership>
DATA.realm_leadership = ffi.cast("realm_leadership*", DATA.realm_leadership_calloc)
---@type table<pop_id, realm_leadership_id[]>>
DATA.realm_leadership_from_leader= {}
for i = 1, 15000 do
    DATA.realm_leadership_from_leader[i] = {}
end
---@type table<realm_id, realm_leadership_id>
DATA.realm_leadership_from_realm= {}

---realm_leadership: LUA bindings---

DATA.realm_leadership_size = 15000
---@type table<realm_leadership_id, boolean>
local realm_leadership_indices_pool = ffi.new("bool[?]", 15000)
for i = 1, 14999 do
    realm_leadership_indices_pool[i] = true 
end
---@type table<realm_leadership_id, realm_leadership_id>
DATA.realm_leadership_indices_set = {}
function DATA.create_realm_leadership()
    ---@type number
    local i = DCON.dcon_create_realm_leadership() + 1
            DATA.realm_leadership_indices_set[i] = i
    return i
end
function DATA.delete_realm_leadership(i)
    do
        local old_value = DATA.realm_leadership[i].leader
        __REMOVE_KEY_REALM_LEADERSHIP_LEADER(i, old_value)
    end
    do
        local old_value = DATA.realm_leadership[i].realm
        __REMOVE_KEY_REALM_LEADERSHIP_REALM(old_value)
    end
    DATA.realm_leadership_indices_set[i] = nil
    return DCON.dcon_delete_realm_leadership(i - 1)
end
---@param func fun(item: realm_leadership_id) 
function DATA.for_each_realm_leadership(func)
    for _, item in pairs(DATA.realm_leadership_indices_set) do
        func(item)
    end
end
---@param func fun(item: realm_leadership_id):boolean 
---@return table<realm_leadership_id, realm_leadership_id> 
function DATA.filter_realm_leadership(func)
    ---@type table<realm_leadership_id, realm_leadership_id> 
    local t = {}
    for _, item in pairs(DATA.realm_leadership_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param realm_leadership_id realm_leadership_id valid realm_leadership id
---@return pop_id leader 
function DATA.realm_leadership_get_leader(realm_leadership_id)
    return DATA.realm_leadership[realm_leadership_id].leader
end
---@param leader pop_id valid pop_id
---@return realm_leadership_id[] An array of realm_leadership 
function DATA.get_realm_leadership_from_leader(leader)
    return DATA.realm_leadership_from_leader[leader]
end
---@param leader pop_id valid pop_id
---@param func fun(item: realm_leadership_id) valid pop_id
function DATA.for_each_realm_leadership_from_leader(leader, func)
    if DATA.realm_leadership_from_leader[leader] == nil then return end
    for _, item in pairs(DATA.realm_leadership_from_leader[leader]) do func(item) end
end
---@param leader pop_id valid pop_id
---@param func fun(item: realm_leadership_id):boolean 
---@return table<realm_leadership_id, realm_leadership_id> 
function DATA.filter_array_realm_leadership_from_leader(leader, func)
    ---@type table<realm_leadership_id, realm_leadership_id> 
    local t = {}
    for _, item in pairs(DATA.realm_leadership_from_leader[leader]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param leader pop_id valid pop_id
---@param func fun(item: realm_leadership_id):boolean 
---@return table<realm_leadership_id, realm_leadership_id> 
function DATA.filter_realm_leadership_from_leader(leader, func)
    ---@type table<realm_leadership_id, realm_leadership_id> 
    local t = {}
    for _, item in pairs(DATA.realm_leadership_from_leader[leader]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param realm_leadership_id realm_leadership_id valid realm_leadership id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_REALM_LEADERSHIP_LEADER(realm_leadership_id, old_value)
    local found_key = nil
    if DATA.realm_leadership_from_leader[old_value] == nil then
        DATA.realm_leadership_from_leader[old_value] = {}
        return
    end
    for key, value in pairs(DATA.realm_leadership_from_leader[old_value]) do
        if value == realm_leadership_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.realm_leadership_from_leader[old_value], found_key)
    end
end
---@param realm_leadership_id realm_leadership_id valid realm_leadership id
---@param value pop_id valid pop_id
function DATA.realm_leadership_set_leader(realm_leadership_id, value)
    local old_value = DATA.realm_leadership[realm_leadership_id].leader
    DATA.realm_leadership[realm_leadership_id].leader = value
    __REMOVE_KEY_REALM_LEADERSHIP_LEADER(realm_leadership_id, old_value)
    if DATA.realm_leadership_from_leader[value] == nil then DATA.realm_leadership_from_leader[value] = {} end
    table.insert(DATA.realm_leadership_from_leader[value], realm_leadership_id)
end
---@param realm_leadership_id realm_leadership_id valid realm_leadership id
---@return realm_id realm 
function DATA.realm_leadership_get_realm(realm_leadership_id)
    return DATA.realm_leadership[realm_leadership_id].realm
end
---@param realm realm_id valid realm_id
---@return realm_leadership_id realm_leadership 
function DATA.get_realm_leadership_from_realm(realm)
    if DATA.realm_leadership_from_realm[realm] == nil then return 0 end
    return DATA.realm_leadership_from_realm[realm]
end
function __REMOVE_KEY_REALM_LEADERSHIP_REALM(old_value)
    DATA.realm_leadership_from_realm[old_value] = nil
end
---@param realm_leadership_id realm_leadership_id valid realm_leadership id
---@param value realm_id valid realm_id
function DATA.realm_leadership_set_realm(realm_leadership_id, value)
    local old_value = DATA.realm_leadership[realm_leadership_id].realm
    DATA.realm_leadership[realm_leadership_id].realm = value
    __REMOVE_KEY_REALM_LEADERSHIP_REALM(old_value)
    DATA.realm_leadership_from_realm[value] = realm_leadership_id
end


local fat_realm_leadership_id_metatable = {
    __index = function (t,k)
        if (k == "leader") then return DATA.realm_leadership_get_leader(t.id) end
        if (k == "realm") then return DATA.realm_leadership_get_realm(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "leader") then
            DATA.realm_leadership_set_leader(t.id, v)
            return
        end
        if (k == "realm") then
            DATA.realm_leadership_set_realm(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id realm_leadership_id
---@return fat_realm_leadership_id fat_id
function DATA.fatten_realm_leadership(id)
    local result = {id = id}
    setmetatable(result, fat_realm_leadership_id_metatable)    return result
end
----------realm_subject_relation----------


---realm_subject_relation: LSP types---

---Unique identificator for realm_subject_relation entity
---@alias realm_subject_relation_id number

---@class (exact) fat_realm_subject_relation_id
---@field id realm_subject_relation_id Unique realm_subject_relation id
---@field wealth_transfer boolean 
---@field goods_transfer boolean 
---@field warriors_contribution boolean 
---@field protection boolean 
---@field local_ruler boolean 
---@field overlord realm_id 
---@field subject realm_id 

---@class struct_realm_subject_relation
---@field wealth_transfer boolean 
---@field goods_transfer boolean 
---@field warriors_contribution boolean 
---@field protection boolean 
---@field local_ruler boolean 
---@field overlord realm_id 
---@field subject realm_id 


ffi.cdef[[
    typedef struct {
        bool wealth_transfer;
        bool goods_transfer;
        bool warriors_contribution;
        bool protection;
        bool local_ruler;
        uint32_t overlord;
        uint32_t subject;
    } realm_subject_relation;
void dcon_delete_realm_subject_relation(int32_t j);
int32_t dcon_create_realm_subject_relation();
void dcon_realm_subject_relation_resize(uint32_t sz);
]]

---realm_subject_relation: FFI arrays---
---@type nil
DATA.realm_subject_relation_calloc = ffi.C.calloc(1, ffi.sizeof("realm_subject_relation") * 15001)
---@type table<realm_subject_relation_id, struct_realm_subject_relation>
DATA.realm_subject_relation = ffi.cast("realm_subject_relation*", DATA.realm_subject_relation_calloc)
---@type table<realm_id, realm_subject_relation_id[]>>
DATA.realm_subject_relation_from_overlord= {}
for i = 1, 15000 do
    DATA.realm_subject_relation_from_overlord[i] = {}
end
---@type table<realm_id, realm_subject_relation_id[]>>
DATA.realm_subject_relation_from_subject= {}
for i = 1, 15000 do
    DATA.realm_subject_relation_from_subject[i] = {}
end

---realm_subject_relation: LUA bindings---

DATA.realm_subject_relation_size = 15000
---@type table<realm_subject_relation_id, boolean>
local realm_subject_relation_indices_pool = ffi.new("bool[?]", 15000)
for i = 1, 14999 do
    realm_subject_relation_indices_pool[i] = true 
end
---@type table<realm_subject_relation_id, realm_subject_relation_id>
DATA.realm_subject_relation_indices_set = {}
function DATA.create_realm_subject_relation()
    ---@type number
    local i = DCON.dcon_create_realm_subject_relation() + 1
            DATA.realm_subject_relation_indices_set[i] = i
    return i
end
function DATA.delete_realm_subject_relation(i)
    do
        local old_value = DATA.realm_subject_relation[i].overlord
        __REMOVE_KEY_REALM_SUBJECT_RELATION_OVERLORD(i, old_value)
    end
    do
        local old_value = DATA.realm_subject_relation[i].subject
        __REMOVE_KEY_REALM_SUBJECT_RELATION_SUBJECT(i, old_value)
    end
    DATA.realm_subject_relation_indices_set[i] = nil
    return DCON.dcon_delete_realm_subject_relation(i - 1)
end
---@param func fun(item: realm_subject_relation_id) 
function DATA.for_each_realm_subject_relation(func)
    for _, item in pairs(DATA.realm_subject_relation_indices_set) do
        func(item)
    end
end
---@param func fun(item: realm_subject_relation_id):boolean 
---@return table<realm_subject_relation_id, realm_subject_relation_id> 
function DATA.filter_realm_subject_relation(func)
    ---@type table<realm_subject_relation_id, realm_subject_relation_id> 
    local t = {}
    for _, item in pairs(DATA.realm_subject_relation_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@return boolean wealth_transfer 
function DATA.realm_subject_relation_get_wealth_transfer(realm_subject_relation_id)
    return DATA.realm_subject_relation[realm_subject_relation_id].wealth_transfer
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param value boolean valid boolean
function DATA.realm_subject_relation_set_wealth_transfer(realm_subject_relation_id, value)
    DATA.realm_subject_relation[realm_subject_relation_id].wealth_transfer = value
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@return boolean goods_transfer 
function DATA.realm_subject_relation_get_goods_transfer(realm_subject_relation_id)
    return DATA.realm_subject_relation[realm_subject_relation_id].goods_transfer
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param value boolean valid boolean
function DATA.realm_subject_relation_set_goods_transfer(realm_subject_relation_id, value)
    DATA.realm_subject_relation[realm_subject_relation_id].goods_transfer = value
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@return boolean warriors_contribution 
function DATA.realm_subject_relation_get_warriors_contribution(realm_subject_relation_id)
    return DATA.realm_subject_relation[realm_subject_relation_id].warriors_contribution
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param value boolean valid boolean
function DATA.realm_subject_relation_set_warriors_contribution(realm_subject_relation_id, value)
    DATA.realm_subject_relation[realm_subject_relation_id].warriors_contribution = value
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@return boolean protection 
function DATA.realm_subject_relation_get_protection(realm_subject_relation_id)
    return DATA.realm_subject_relation[realm_subject_relation_id].protection
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param value boolean valid boolean
function DATA.realm_subject_relation_set_protection(realm_subject_relation_id, value)
    DATA.realm_subject_relation[realm_subject_relation_id].protection = value
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@return boolean local_ruler 
function DATA.realm_subject_relation_get_local_ruler(realm_subject_relation_id)
    return DATA.realm_subject_relation[realm_subject_relation_id].local_ruler
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param value boolean valid boolean
function DATA.realm_subject_relation_set_local_ruler(realm_subject_relation_id, value)
    DATA.realm_subject_relation[realm_subject_relation_id].local_ruler = value
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@return realm_id overlord 
function DATA.realm_subject_relation_get_overlord(realm_subject_relation_id)
    return DATA.realm_subject_relation[realm_subject_relation_id].overlord
end
---@param overlord realm_id valid realm_id
---@return realm_subject_relation_id[] An array of realm_subject_relation 
function DATA.get_realm_subject_relation_from_overlord(overlord)
    return DATA.realm_subject_relation_from_overlord[overlord]
end
---@param overlord realm_id valid realm_id
---@param func fun(item: realm_subject_relation_id) valid realm_id
function DATA.for_each_realm_subject_relation_from_overlord(overlord, func)
    if DATA.realm_subject_relation_from_overlord[overlord] == nil then return end
    for _, item in pairs(DATA.realm_subject_relation_from_overlord[overlord]) do func(item) end
end
---@param overlord realm_id valid realm_id
---@param func fun(item: realm_subject_relation_id):boolean 
---@return table<realm_subject_relation_id, realm_subject_relation_id> 
function DATA.filter_array_realm_subject_relation_from_overlord(overlord, func)
    ---@type table<realm_subject_relation_id, realm_subject_relation_id> 
    local t = {}
    for _, item in pairs(DATA.realm_subject_relation_from_overlord[overlord]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param overlord realm_id valid realm_id
---@param func fun(item: realm_subject_relation_id):boolean 
---@return table<realm_subject_relation_id, realm_subject_relation_id> 
function DATA.filter_realm_subject_relation_from_overlord(overlord, func)
    ---@type table<realm_subject_relation_id, realm_subject_relation_id> 
    local t = {}
    for _, item in pairs(DATA.realm_subject_relation_from_overlord[overlord]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param old_value realm_id valid realm_id
function __REMOVE_KEY_REALM_SUBJECT_RELATION_OVERLORD(realm_subject_relation_id, old_value)
    local found_key = nil
    if DATA.realm_subject_relation_from_overlord[old_value] == nil then
        DATA.realm_subject_relation_from_overlord[old_value] = {}
        return
    end
    for key, value in pairs(DATA.realm_subject_relation_from_overlord[old_value]) do
        if value == realm_subject_relation_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.realm_subject_relation_from_overlord[old_value], found_key)
    end
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param value realm_id valid realm_id
function DATA.realm_subject_relation_set_overlord(realm_subject_relation_id, value)
    local old_value = DATA.realm_subject_relation[realm_subject_relation_id].overlord
    DATA.realm_subject_relation[realm_subject_relation_id].overlord = value
    __REMOVE_KEY_REALM_SUBJECT_RELATION_OVERLORD(realm_subject_relation_id, old_value)
    if DATA.realm_subject_relation_from_overlord[value] == nil then DATA.realm_subject_relation_from_overlord[value] = {} end
    table.insert(DATA.realm_subject_relation_from_overlord[value], realm_subject_relation_id)
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@return realm_id subject 
function DATA.realm_subject_relation_get_subject(realm_subject_relation_id)
    return DATA.realm_subject_relation[realm_subject_relation_id].subject
end
---@param subject realm_id valid realm_id
---@return realm_subject_relation_id[] An array of realm_subject_relation 
function DATA.get_realm_subject_relation_from_subject(subject)
    return DATA.realm_subject_relation_from_subject[subject]
end
---@param subject realm_id valid realm_id
---@param func fun(item: realm_subject_relation_id) valid realm_id
function DATA.for_each_realm_subject_relation_from_subject(subject, func)
    if DATA.realm_subject_relation_from_subject[subject] == nil then return end
    for _, item in pairs(DATA.realm_subject_relation_from_subject[subject]) do func(item) end
end
---@param subject realm_id valid realm_id
---@param func fun(item: realm_subject_relation_id):boolean 
---@return table<realm_subject_relation_id, realm_subject_relation_id> 
function DATA.filter_array_realm_subject_relation_from_subject(subject, func)
    ---@type table<realm_subject_relation_id, realm_subject_relation_id> 
    local t = {}
    for _, item in pairs(DATA.realm_subject_relation_from_subject[subject]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param subject realm_id valid realm_id
---@param func fun(item: realm_subject_relation_id):boolean 
---@return table<realm_subject_relation_id, realm_subject_relation_id> 
function DATA.filter_realm_subject_relation_from_subject(subject, func)
    ---@type table<realm_subject_relation_id, realm_subject_relation_id> 
    local t = {}
    for _, item in pairs(DATA.realm_subject_relation_from_subject[subject]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param old_value realm_id valid realm_id
function __REMOVE_KEY_REALM_SUBJECT_RELATION_SUBJECT(realm_subject_relation_id, old_value)
    local found_key = nil
    if DATA.realm_subject_relation_from_subject[old_value] == nil then
        DATA.realm_subject_relation_from_subject[old_value] = {}
        return
    end
    for key, value in pairs(DATA.realm_subject_relation_from_subject[old_value]) do
        if value == realm_subject_relation_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.realm_subject_relation_from_subject[old_value], found_key)
    end
end
---@param realm_subject_relation_id realm_subject_relation_id valid realm_subject_relation id
---@param value realm_id valid realm_id
function DATA.realm_subject_relation_set_subject(realm_subject_relation_id, value)
    local old_value = DATA.realm_subject_relation[realm_subject_relation_id].subject
    DATA.realm_subject_relation[realm_subject_relation_id].subject = value
    __REMOVE_KEY_REALM_SUBJECT_RELATION_SUBJECT(realm_subject_relation_id, old_value)
    if DATA.realm_subject_relation_from_subject[value] == nil then DATA.realm_subject_relation_from_subject[value] = {} end
    table.insert(DATA.realm_subject_relation_from_subject[value], realm_subject_relation_id)
end


local fat_realm_subject_relation_id_metatable = {
    __index = function (t,k)
        if (k == "wealth_transfer") then return DATA.realm_subject_relation_get_wealth_transfer(t.id) end
        if (k == "goods_transfer") then return DATA.realm_subject_relation_get_goods_transfer(t.id) end
        if (k == "warriors_contribution") then return DATA.realm_subject_relation_get_warriors_contribution(t.id) end
        if (k == "protection") then return DATA.realm_subject_relation_get_protection(t.id) end
        if (k == "local_ruler") then return DATA.realm_subject_relation_get_local_ruler(t.id) end
        if (k == "overlord") then return DATA.realm_subject_relation_get_overlord(t.id) end
        if (k == "subject") then return DATA.realm_subject_relation_get_subject(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "wealth_transfer") then
            DATA.realm_subject_relation_set_wealth_transfer(t.id, v)
            return
        end
        if (k == "goods_transfer") then
            DATA.realm_subject_relation_set_goods_transfer(t.id, v)
            return
        end
        if (k == "warriors_contribution") then
            DATA.realm_subject_relation_set_warriors_contribution(t.id, v)
            return
        end
        if (k == "protection") then
            DATA.realm_subject_relation_set_protection(t.id, v)
            return
        end
        if (k == "local_ruler") then
            DATA.realm_subject_relation_set_local_ruler(t.id, v)
            return
        end
        if (k == "overlord") then
            DATA.realm_subject_relation_set_overlord(t.id, v)
            return
        end
        if (k == "subject") then
            DATA.realm_subject_relation_set_subject(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id realm_subject_relation_id
---@return fat_realm_subject_relation_id fat_id
function DATA.fatten_realm_subject_relation(id)
    local result = {id = id}
    setmetatable(result, fat_realm_subject_relation_id_metatable)    return result
end
----------tax_collector----------


---tax_collector: LSP types---

---Unique identificator for tax_collector entity
---@alias tax_collector_id number

---@class (exact) fat_tax_collector_id
---@field id tax_collector_id Unique tax_collector id
---@field collector pop_id 
---@field realm realm_id 

---@class struct_tax_collector
---@field collector pop_id 
---@field realm realm_id 


ffi.cdef[[
    typedef struct {
        uint32_t collector;
        uint32_t realm;
    } tax_collector;
void dcon_delete_tax_collector(int32_t j);
int32_t dcon_create_tax_collector();
void dcon_tax_collector_resize(uint32_t sz);
]]

---tax_collector: FFI arrays---
---@type nil
DATA.tax_collector_calloc = ffi.C.calloc(1, ffi.sizeof("tax_collector") * 45001)
---@type table<tax_collector_id, struct_tax_collector>
DATA.tax_collector = ffi.cast("tax_collector*", DATA.tax_collector_calloc)
---@type table<pop_id, tax_collector_id>
DATA.tax_collector_from_collector= {}
---@type table<realm_id, tax_collector_id[]>>
DATA.tax_collector_from_realm= {}
for i = 1, 45000 do
    DATA.tax_collector_from_realm[i] = {}
end

---tax_collector: LUA bindings---

DATA.tax_collector_size = 45000
---@type table<tax_collector_id, boolean>
local tax_collector_indices_pool = ffi.new("bool[?]", 45000)
for i = 1, 44999 do
    tax_collector_indices_pool[i] = true 
end
---@type table<tax_collector_id, tax_collector_id>
DATA.tax_collector_indices_set = {}
function DATA.create_tax_collector()
    ---@type number
    local i = DCON.dcon_create_tax_collector() + 1
            DATA.tax_collector_indices_set[i] = i
    return i
end
function DATA.delete_tax_collector(i)
    do
        local old_value = DATA.tax_collector[i].collector
        __REMOVE_KEY_TAX_COLLECTOR_COLLECTOR(old_value)
    end
    do
        local old_value = DATA.tax_collector[i].realm
        __REMOVE_KEY_TAX_COLLECTOR_REALM(i, old_value)
    end
    DATA.tax_collector_indices_set[i] = nil
    return DCON.dcon_delete_tax_collector(i - 1)
end
---@param func fun(item: tax_collector_id) 
function DATA.for_each_tax_collector(func)
    for _, item in pairs(DATA.tax_collector_indices_set) do
        func(item)
    end
end
---@param func fun(item: tax_collector_id):boolean 
---@return table<tax_collector_id, tax_collector_id> 
function DATA.filter_tax_collector(func)
    ---@type table<tax_collector_id, tax_collector_id> 
    local t = {}
    for _, item in pairs(DATA.tax_collector_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param tax_collector_id tax_collector_id valid tax_collector id
---@return pop_id collector 
function DATA.tax_collector_get_collector(tax_collector_id)
    return DATA.tax_collector[tax_collector_id].collector
end
---@param collector pop_id valid pop_id
---@return tax_collector_id tax_collector 
function DATA.get_tax_collector_from_collector(collector)
    if DATA.tax_collector_from_collector[collector] == nil then return 0 end
    return DATA.tax_collector_from_collector[collector]
end
function __REMOVE_KEY_TAX_COLLECTOR_COLLECTOR(old_value)
    DATA.tax_collector_from_collector[old_value] = nil
end
---@param tax_collector_id tax_collector_id valid tax_collector id
---@param value pop_id valid pop_id
function DATA.tax_collector_set_collector(tax_collector_id, value)
    local old_value = DATA.tax_collector[tax_collector_id].collector
    DATA.tax_collector[tax_collector_id].collector = value
    __REMOVE_KEY_TAX_COLLECTOR_COLLECTOR(old_value)
    DATA.tax_collector_from_collector[value] = tax_collector_id
end
---@param tax_collector_id tax_collector_id valid tax_collector id
---@return realm_id realm 
function DATA.tax_collector_get_realm(tax_collector_id)
    return DATA.tax_collector[tax_collector_id].realm
end
---@param realm realm_id valid realm_id
---@return tax_collector_id[] An array of tax_collector 
function DATA.get_tax_collector_from_realm(realm)
    return DATA.tax_collector_from_realm[realm]
end
---@param realm realm_id valid realm_id
---@param func fun(item: tax_collector_id) valid realm_id
function DATA.for_each_tax_collector_from_realm(realm, func)
    if DATA.tax_collector_from_realm[realm] == nil then return end
    for _, item in pairs(DATA.tax_collector_from_realm[realm]) do func(item) end
end
---@param realm realm_id valid realm_id
---@param func fun(item: tax_collector_id):boolean 
---@return table<tax_collector_id, tax_collector_id> 
function DATA.filter_array_tax_collector_from_realm(realm, func)
    ---@type table<tax_collector_id, tax_collector_id> 
    local t = {}
    for _, item in pairs(DATA.tax_collector_from_realm[realm]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param realm realm_id valid realm_id
---@param func fun(item: tax_collector_id):boolean 
---@return table<tax_collector_id, tax_collector_id> 
function DATA.filter_tax_collector_from_realm(realm, func)
    ---@type table<tax_collector_id, tax_collector_id> 
    local t = {}
    for _, item in pairs(DATA.tax_collector_from_realm[realm]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param tax_collector_id tax_collector_id valid tax_collector id
---@param old_value realm_id valid realm_id
function __REMOVE_KEY_TAX_COLLECTOR_REALM(tax_collector_id, old_value)
    local found_key = nil
    if DATA.tax_collector_from_realm[old_value] == nil then
        DATA.tax_collector_from_realm[old_value] = {}
        return
    end
    for key, value in pairs(DATA.tax_collector_from_realm[old_value]) do
        if value == tax_collector_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.tax_collector_from_realm[old_value], found_key)
    end
end
---@param tax_collector_id tax_collector_id valid tax_collector id
---@param value realm_id valid realm_id
function DATA.tax_collector_set_realm(tax_collector_id, value)
    local old_value = DATA.tax_collector[tax_collector_id].realm
    DATA.tax_collector[tax_collector_id].realm = value
    __REMOVE_KEY_TAX_COLLECTOR_REALM(tax_collector_id, old_value)
    if DATA.tax_collector_from_realm[value] == nil then DATA.tax_collector_from_realm[value] = {} end
    table.insert(DATA.tax_collector_from_realm[value], tax_collector_id)
end


local fat_tax_collector_id_metatable = {
    __index = function (t,k)
        if (k == "collector") then return DATA.tax_collector_get_collector(t.id) end
        if (k == "realm") then return DATA.tax_collector_get_realm(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "collector") then
            DATA.tax_collector_set_collector(t.id, v)
            return
        end
        if (k == "realm") then
            DATA.tax_collector_set_realm(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id tax_collector_id
---@return fat_tax_collector_id fat_id
function DATA.fatten_tax_collector(id)
    local result = {id = id}
    setmetatable(result, fat_tax_collector_id_metatable)    return result
end
----------personal_rights----------


---personal_rights: LSP types---

---Unique identificator for personal_rights entity
---@alias personal_rights_id number

---@class (exact) fat_personal_rights_id
---@field id personal_rights_id Unique personal_rights id
---@field can_trade boolean 
---@field can_build boolean 
---@field person pop_id 
---@field realm realm_id 

---@class struct_personal_rights
---@field can_trade boolean 
---@field can_build boolean 
---@field person pop_id 
---@field realm realm_id 


ffi.cdef[[
    typedef struct {
        bool can_trade;
        bool can_build;
        uint32_t person;
        uint32_t realm;
    } personal_rights;
void dcon_delete_personal_rights(int32_t j);
int32_t dcon_create_personal_rights();
void dcon_personal_rights_resize(uint32_t sz);
]]

---personal_rights: FFI arrays---
---@type nil
DATA.personal_rights_calloc = ffi.C.calloc(1, ffi.sizeof("personal_rights") * 450001)
---@type table<personal_rights_id, struct_personal_rights>
DATA.personal_rights = ffi.cast("personal_rights*", DATA.personal_rights_calloc)
---@type table<pop_id, personal_rights_id[]>>
DATA.personal_rights_from_person= {}
for i = 1, 450000 do
    DATA.personal_rights_from_person[i] = {}
end
---@type table<realm_id, personal_rights_id[]>>
DATA.personal_rights_from_realm= {}
for i = 1, 450000 do
    DATA.personal_rights_from_realm[i] = {}
end

---personal_rights: LUA bindings---

DATA.personal_rights_size = 450000
---@type table<personal_rights_id, boolean>
local personal_rights_indices_pool = ffi.new("bool[?]", 450000)
for i = 1, 449999 do
    personal_rights_indices_pool[i] = true 
end
---@type table<personal_rights_id, personal_rights_id>
DATA.personal_rights_indices_set = {}
function DATA.create_personal_rights()
    ---@type number
    local i = DCON.dcon_create_personal_rights() + 1
            DATA.personal_rights_indices_set[i] = i
    return i
end
function DATA.delete_personal_rights(i)
    do
        local old_value = DATA.personal_rights[i].person
        __REMOVE_KEY_PERSONAL_RIGHTS_PERSON(i, old_value)
    end
    do
        local old_value = DATA.personal_rights[i].realm
        __REMOVE_KEY_PERSONAL_RIGHTS_REALM(i, old_value)
    end
    DATA.personal_rights_indices_set[i] = nil
    return DCON.dcon_delete_personal_rights(i - 1)
end
---@param func fun(item: personal_rights_id) 
function DATA.for_each_personal_rights(func)
    for _, item in pairs(DATA.personal_rights_indices_set) do
        func(item)
    end
end
---@param func fun(item: personal_rights_id):boolean 
---@return table<personal_rights_id, personal_rights_id> 
function DATA.filter_personal_rights(func)
    ---@type table<personal_rights_id, personal_rights_id> 
    local t = {}
    for _, item in pairs(DATA.personal_rights_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param personal_rights_id personal_rights_id valid personal_rights id
---@return boolean can_trade 
function DATA.personal_rights_get_can_trade(personal_rights_id)
    return DATA.personal_rights[personal_rights_id].can_trade
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@param value boolean valid boolean
function DATA.personal_rights_set_can_trade(personal_rights_id, value)
    DATA.personal_rights[personal_rights_id].can_trade = value
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@return boolean can_build 
function DATA.personal_rights_get_can_build(personal_rights_id)
    return DATA.personal_rights[personal_rights_id].can_build
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@param value boolean valid boolean
function DATA.personal_rights_set_can_build(personal_rights_id, value)
    DATA.personal_rights[personal_rights_id].can_build = value
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@return pop_id person 
function DATA.personal_rights_get_person(personal_rights_id)
    return DATA.personal_rights[personal_rights_id].person
end
---@param person pop_id valid pop_id
---@return personal_rights_id[] An array of personal_rights 
function DATA.get_personal_rights_from_person(person)
    return DATA.personal_rights_from_person[person]
end
---@param person pop_id valid pop_id
---@param func fun(item: personal_rights_id) valid pop_id
function DATA.for_each_personal_rights_from_person(person, func)
    if DATA.personal_rights_from_person[person] == nil then return end
    for _, item in pairs(DATA.personal_rights_from_person[person]) do func(item) end
end
---@param person pop_id valid pop_id
---@param func fun(item: personal_rights_id):boolean 
---@return table<personal_rights_id, personal_rights_id> 
function DATA.filter_array_personal_rights_from_person(person, func)
    ---@type table<personal_rights_id, personal_rights_id> 
    local t = {}
    for _, item in pairs(DATA.personal_rights_from_person[person]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param person pop_id valid pop_id
---@param func fun(item: personal_rights_id):boolean 
---@return table<personal_rights_id, personal_rights_id> 
function DATA.filter_personal_rights_from_person(person, func)
    ---@type table<personal_rights_id, personal_rights_id> 
    local t = {}
    for _, item in pairs(DATA.personal_rights_from_person[person]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_PERSONAL_RIGHTS_PERSON(personal_rights_id, old_value)
    local found_key = nil
    if DATA.personal_rights_from_person[old_value] == nil then
        DATA.personal_rights_from_person[old_value] = {}
        return
    end
    for key, value in pairs(DATA.personal_rights_from_person[old_value]) do
        if value == personal_rights_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.personal_rights_from_person[old_value], found_key)
    end
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@param value pop_id valid pop_id
function DATA.personal_rights_set_person(personal_rights_id, value)
    local old_value = DATA.personal_rights[personal_rights_id].person
    DATA.personal_rights[personal_rights_id].person = value
    __REMOVE_KEY_PERSONAL_RIGHTS_PERSON(personal_rights_id, old_value)
    if DATA.personal_rights_from_person[value] == nil then DATA.personal_rights_from_person[value] = {} end
    table.insert(DATA.personal_rights_from_person[value], personal_rights_id)
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@return realm_id realm 
function DATA.personal_rights_get_realm(personal_rights_id)
    return DATA.personal_rights[personal_rights_id].realm
end
---@param realm realm_id valid realm_id
---@return personal_rights_id[] An array of personal_rights 
function DATA.get_personal_rights_from_realm(realm)
    return DATA.personal_rights_from_realm[realm]
end
---@param realm realm_id valid realm_id
---@param func fun(item: personal_rights_id) valid realm_id
function DATA.for_each_personal_rights_from_realm(realm, func)
    if DATA.personal_rights_from_realm[realm] == nil then return end
    for _, item in pairs(DATA.personal_rights_from_realm[realm]) do func(item) end
end
---@param realm realm_id valid realm_id
---@param func fun(item: personal_rights_id):boolean 
---@return table<personal_rights_id, personal_rights_id> 
function DATA.filter_array_personal_rights_from_realm(realm, func)
    ---@type table<personal_rights_id, personal_rights_id> 
    local t = {}
    for _, item in pairs(DATA.personal_rights_from_realm[realm]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param realm realm_id valid realm_id
---@param func fun(item: personal_rights_id):boolean 
---@return table<personal_rights_id, personal_rights_id> 
function DATA.filter_personal_rights_from_realm(realm, func)
    ---@type table<personal_rights_id, personal_rights_id> 
    local t = {}
    for _, item in pairs(DATA.personal_rights_from_realm[realm]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@param old_value realm_id valid realm_id
function __REMOVE_KEY_PERSONAL_RIGHTS_REALM(personal_rights_id, old_value)
    local found_key = nil
    if DATA.personal_rights_from_realm[old_value] == nil then
        DATA.personal_rights_from_realm[old_value] = {}
        return
    end
    for key, value in pairs(DATA.personal_rights_from_realm[old_value]) do
        if value == personal_rights_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.personal_rights_from_realm[old_value], found_key)
    end
end
---@param personal_rights_id personal_rights_id valid personal_rights id
---@param value realm_id valid realm_id
function DATA.personal_rights_set_realm(personal_rights_id, value)
    local old_value = DATA.personal_rights[personal_rights_id].realm
    DATA.personal_rights[personal_rights_id].realm = value
    __REMOVE_KEY_PERSONAL_RIGHTS_REALM(personal_rights_id, old_value)
    if DATA.personal_rights_from_realm[value] == nil then DATA.personal_rights_from_realm[value] = {} end
    table.insert(DATA.personal_rights_from_realm[value], personal_rights_id)
end


local fat_personal_rights_id_metatable = {
    __index = function (t,k)
        if (k == "can_trade") then return DATA.personal_rights_get_can_trade(t.id) end
        if (k == "can_build") then return DATA.personal_rights_get_can_build(t.id) end
        if (k == "person") then return DATA.personal_rights_get_person(t.id) end
        if (k == "realm") then return DATA.personal_rights_get_realm(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "can_trade") then
            DATA.personal_rights_set_can_trade(t.id, v)
            return
        end
        if (k == "can_build") then
            DATA.personal_rights_set_can_build(t.id, v)
            return
        end
        if (k == "person") then
            DATA.personal_rights_set_person(t.id, v)
            return
        end
        if (k == "realm") then
            DATA.personal_rights_set_realm(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id personal_rights_id
---@return fat_personal_rights_id fat_id
function DATA.fatten_personal_rights(id)
    local result = {id = id}
    setmetatable(result, fat_personal_rights_id_metatable)    return result
end
----------realm_provinces----------


---realm_provinces: LSP types---

---Unique identificator for realm_provinces entity
---@alias realm_provinces_id number

---@class (exact) fat_realm_provinces_id
---@field id realm_provinces_id Unique realm_provinces id
---@field province province_id 
---@field realm realm_id 

---@class struct_realm_provinces
---@field province province_id 
---@field realm realm_id 


ffi.cdef[[
    typedef struct {
        uint32_t province;
        uint32_t realm;
    } realm_provinces;
void dcon_delete_realm_provinces(int32_t j);
int32_t dcon_create_realm_provinces();
void dcon_realm_provinces_resize(uint32_t sz);
]]

---realm_provinces: FFI arrays---
---@type nil
DATA.realm_provinces_calloc = ffi.C.calloc(1, ffi.sizeof("realm_provinces") * 30001)
---@type table<realm_provinces_id, struct_realm_provinces>
DATA.realm_provinces = ffi.cast("realm_provinces*", DATA.realm_provinces_calloc)
---@type table<province_id, realm_provinces_id>
DATA.realm_provinces_from_province= {}
---@type table<realm_id, realm_provinces_id[]>>
DATA.realm_provinces_from_realm= {}
for i = 1, 30000 do
    DATA.realm_provinces_from_realm[i] = {}
end

---realm_provinces: LUA bindings---

DATA.realm_provinces_size = 30000
---@type table<realm_provinces_id, boolean>
local realm_provinces_indices_pool = ffi.new("bool[?]", 30000)
for i = 1, 29999 do
    realm_provinces_indices_pool[i] = true 
end
---@type table<realm_provinces_id, realm_provinces_id>
DATA.realm_provinces_indices_set = {}
function DATA.create_realm_provinces()
    ---@type number
    local i = DCON.dcon_create_realm_provinces() + 1
            DATA.realm_provinces_indices_set[i] = i
    return i
end
function DATA.delete_realm_provinces(i)
    do
        local old_value = DATA.realm_provinces[i].province
        __REMOVE_KEY_REALM_PROVINCES_PROVINCE(old_value)
    end
    do
        local old_value = DATA.realm_provinces[i].realm
        __REMOVE_KEY_REALM_PROVINCES_REALM(i, old_value)
    end
    DATA.realm_provinces_indices_set[i] = nil
    return DCON.dcon_delete_realm_provinces(i - 1)
end
---@param func fun(item: realm_provinces_id) 
function DATA.for_each_realm_provinces(func)
    for _, item in pairs(DATA.realm_provinces_indices_set) do
        func(item)
    end
end
---@param func fun(item: realm_provinces_id):boolean 
---@return table<realm_provinces_id, realm_provinces_id> 
function DATA.filter_realm_provinces(func)
    ---@type table<realm_provinces_id, realm_provinces_id> 
    local t = {}
    for _, item in pairs(DATA.realm_provinces_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param realm_provinces_id realm_provinces_id valid realm_provinces id
---@return province_id province 
function DATA.realm_provinces_get_province(realm_provinces_id)
    return DATA.realm_provinces[realm_provinces_id].province
end
---@param province province_id valid province_id
---@return realm_provinces_id realm_provinces 
function DATA.get_realm_provinces_from_province(province)
    if DATA.realm_provinces_from_province[province] == nil then return 0 end
    return DATA.realm_provinces_from_province[province]
end
function __REMOVE_KEY_REALM_PROVINCES_PROVINCE(old_value)
    DATA.realm_provinces_from_province[old_value] = nil
end
---@param realm_provinces_id realm_provinces_id valid realm_provinces id
---@param value province_id valid province_id
function DATA.realm_provinces_set_province(realm_provinces_id, value)
    local old_value = DATA.realm_provinces[realm_provinces_id].province
    DATA.realm_provinces[realm_provinces_id].province = value
    __REMOVE_KEY_REALM_PROVINCES_PROVINCE(old_value)
    DATA.realm_provinces_from_province[value] = realm_provinces_id
end
---@param realm_provinces_id realm_provinces_id valid realm_provinces id
---@return realm_id realm 
function DATA.realm_provinces_get_realm(realm_provinces_id)
    return DATA.realm_provinces[realm_provinces_id].realm
end
---@param realm realm_id valid realm_id
---@return realm_provinces_id[] An array of realm_provinces 
function DATA.get_realm_provinces_from_realm(realm)
    return DATA.realm_provinces_from_realm[realm]
end
---@param realm realm_id valid realm_id
---@param func fun(item: realm_provinces_id) valid realm_id
function DATA.for_each_realm_provinces_from_realm(realm, func)
    if DATA.realm_provinces_from_realm[realm] == nil then return end
    for _, item in pairs(DATA.realm_provinces_from_realm[realm]) do func(item) end
end
---@param realm realm_id valid realm_id
---@param func fun(item: realm_provinces_id):boolean 
---@return table<realm_provinces_id, realm_provinces_id> 
function DATA.filter_array_realm_provinces_from_realm(realm, func)
    ---@type table<realm_provinces_id, realm_provinces_id> 
    local t = {}
    for _, item in pairs(DATA.realm_provinces_from_realm[realm]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param realm realm_id valid realm_id
---@param func fun(item: realm_provinces_id):boolean 
---@return table<realm_provinces_id, realm_provinces_id> 
function DATA.filter_realm_provinces_from_realm(realm, func)
    ---@type table<realm_provinces_id, realm_provinces_id> 
    local t = {}
    for _, item in pairs(DATA.realm_provinces_from_realm[realm]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param realm_provinces_id realm_provinces_id valid realm_provinces id
---@param old_value realm_id valid realm_id
function __REMOVE_KEY_REALM_PROVINCES_REALM(realm_provinces_id, old_value)
    local found_key = nil
    if DATA.realm_provinces_from_realm[old_value] == nil then
        DATA.realm_provinces_from_realm[old_value] = {}
        return
    end
    for key, value in pairs(DATA.realm_provinces_from_realm[old_value]) do
        if value == realm_provinces_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.realm_provinces_from_realm[old_value], found_key)
    end
end
---@param realm_provinces_id realm_provinces_id valid realm_provinces id
---@param value realm_id valid realm_id
function DATA.realm_provinces_set_realm(realm_provinces_id, value)
    local old_value = DATA.realm_provinces[realm_provinces_id].realm
    DATA.realm_provinces[realm_provinces_id].realm = value
    __REMOVE_KEY_REALM_PROVINCES_REALM(realm_provinces_id, old_value)
    if DATA.realm_provinces_from_realm[value] == nil then DATA.realm_provinces_from_realm[value] = {} end
    table.insert(DATA.realm_provinces_from_realm[value], realm_provinces_id)
end


local fat_realm_provinces_id_metatable = {
    __index = function (t,k)
        if (k == "province") then return DATA.realm_provinces_get_province(t.id) end
        if (k == "realm") then return DATA.realm_provinces_get_realm(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "province") then
            DATA.realm_provinces_set_province(t.id, v)
            return
        end
        if (k == "realm") then
            DATA.realm_provinces_set_realm(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id realm_provinces_id
---@return fat_realm_provinces_id fat_id
function DATA.fatten_realm_provinces(id)
    local result = {id = id}
    setmetatable(result, fat_realm_provinces_id_metatable)    return result
end
----------popularity----------


---popularity: LSP types---

---Unique identificator for popularity entity
---@alias popularity_id number

---@class (exact) fat_popularity_id
---@field id popularity_id Unique popularity id
---@field value number efficiency of this relation
---@field who pop_id 
---@field where realm_id popularity where

---@class struct_popularity
---@field value number efficiency of this relation
---@field who pop_id 
---@field where realm_id popularity where


ffi.cdef[[
    typedef struct {
        float value;
        uint32_t who;
        uint32_t where;
    } popularity;
void dcon_delete_popularity(int32_t j);
int32_t dcon_create_popularity();
void dcon_popularity_resize(uint32_t sz);
]]

---popularity: FFI arrays---
---@type nil
DATA.popularity_calloc = ffi.C.calloc(1, ffi.sizeof("popularity") * 450001)
---@type table<popularity_id, struct_popularity>
DATA.popularity = ffi.cast("popularity*", DATA.popularity_calloc)
---@type table<pop_id, popularity_id[]>>
DATA.popularity_from_who= {}
for i = 1, 450000 do
    DATA.popularity_from_who[i] = {}
end
---@type table<realm_id, popularity_id[]>>
DATA.popularity_from_where= {}
for i = 1, 450000 do
    DATA.popularity_from_where[i] = {}
end

---popularity: LUA bindings---

DATA.popularity_size = 450000
---@type table<popularity_id, boolean>
local popularity_indices_pool = ffi.new("bool[?]", 450000)
for i = 1, 449999 do
    popularity_indices_pool[i] = true 
end
---@type table<popularity_id, popularity_id>
DATA.popularity_indices_set = {}
function DATA.create_popularity()
    ---@type number
    local i = DCON.dcon_create_popularity() + 1
            DATA.popularity_indices_set[i] = i
    return i
end
function DATA.delete_popularity(i)
    do
        local old_value = DATA.popularity[i].who
        __REMOVE_KEY_POPULARITY_WHO(i, old_value)
    end
    do
        local old_value = DATA.popularity[i].where
        __REMOVE_KEY_POPULARITY_WHERE(i, old_value)
    end
    DATA.popularity_indices_set[i] = nil
    return DCON.dcon_delete_popularity(i - 1)
end
---@param func fun(item: popularity_id) 
function DATA.for_each_popularity(func)
    for _, item in pairs(DATA.popularity_indices_set) do
        func(item)
    end
end
---@param func fun(item: popularity_id):boolean 
---@return table<popularity_id, popularity_id> 
function DATA.filter_popularity(func)
    ---@type table<popularity_id, popularity_id> 
    local t = {}
    for _, item in pairs(DATA.popularity_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param popularity_id popularity_id valid popularity id
---@return number value efficiency of this relation
function DATA.popularity_get_value(popularity_id)
    return DATA.popularity[popularity_id].value
end
---@param popularity_id popularity_id valid popularity id
---@param value number valid number
function DATA.popularity_set_value(popularity_id, value)
    DATA.popularity[popularity_id].value = value
end
---@param popularity_id popularity_id valid popularity id
---@param value number valid number
function DATA.popularity_inc_value(popularity_id, value)
    DATA.popularity[popularity_id].value = DATA.popularity[popularity_id].value + value
end
---@param popularity_id popularity_id valid popularity id
---@return pop_id who 
function DATA.popularity_get_who(popularity_id)
    return DATA.popularity[popularity_id].who
end
---@param who pop_id valid pop_id
---@return popularity_id[] An array of popularity 
function DATA.get_popularity_from_who(who)
    return DATA.popularity_from_who[who]
end
---@param who pop_id valid pop_id
---@param func fun(item: popularity_id) valid pop_id
function DATA.for_each_popularity_from_who(who, func)
    if DATA.popularity_from_who[who] == nil then return end
    for _, item in pairs(DATA.popularity_from_who[who]) do func(item) end
end
---@param who pop_id valid pop_id
---@param func fun(item: popularity_id):boolean 
---@return table<popularity_id, popularity_id> 
function DATA.filter_array_popularity_from_who(who, func)
    ---@type table<popularity_id, popularity_id> 
    local t = {}
    for _, item in pairs(DATA.popularity_from_who[who]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param who pop_id valid pop_id
---@param func fun(item: popularity_id):boolean 
---@return table<popularity_id, popularity_id> 
function DATA.filter_popularity_from_who(who, func)
    ---@type table<popularity_id, popularity_id> 
    local t = {}
    for _, item in pairs(DATA.popularity_from_who[who]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param popularity_id popularity_id valid popularity id
---@param old_value pop_id valid pop_id
function __REMOVE_KEY_POPULARITY_WHO(popularity_id, old_value)
    local found_key = nil
    if DATA.popularity_from_who[old_value] == nil then
        DATA.popularity_from_who[old_value] = {}
        return
    end
    for key, value in pairs(DATA.popularity_from_who[old_value]) do
        if value == popularity_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.popularity_from_who[old_value], found_key)
    end
end
---@param popularity_id popularity_id valid popularity id
---@param value pop_id valid pop_id
function DATA.popularity_set_who(popularity_id, value)
    local old_value = DATA.popularity[popularity_id].who
    DATA.popularity[popularity_id].who = value
    __REMOVE_KEY_POPULARITY_WHO(popularity_id, old_value)
    if DATA.popularity_from_who[value] == nil then DATA.popularity_from_who[value] = {} end
    table.insert(DATA.popularity_from_who[value], popularity_id)
end
---@param popularity_id popularity_id valid popularity id
---@return realm_id where popularity where
function DATA.popularity_get_where(popularity_id)
    return DATA.popularity[popularity_id].where
end
---@param where realm_id valid realm_id
---@return popularity_id[] An array of popularity 
function DATA.get_popularity_from_where(where)
    return DATA.popularity_from_where[where]
end
---@param where realm_id valid realm_id
---@param func fun(item: popularity_id) valid realm_id
function DATA.for_each_popularity_from_where(where, func)
    if DATA.popularity_from_where[where] == nil then return end
    for _, item in pairs(DATA.popularity_from_where[where]) do func(item) end
end
---@param where realm_id valid realm_id
---@param func fun(item: popularity_id):boolean 
---@return table<popularity_id, popularity_id> 
function DATA.filter_array_popularity_from_where(where, func)
    ---@type table<popularity_id, popularity_id> 
    local t = {}
    for _, item in pairs(DATA.popularity_from_where[where]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param where realm_id valid realm_id
---@param func fun(item: popularity_id):boolean 
---@return table<popularity_id, popularity_id> 
function DATA.filter_popularity_from_where(where, func)
    ---@type table<popularity_id, popularity_id> 
    local t = {}
    for _, item in pairs(DATA.popularity_from_where[where]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param popularity_id popularity_id valid popularity id
---@param old_value realm_id valid realm_id
function __REMOVE_KEY_POPULARITY_WHERE(popularity_id, old_value)
    local found_key = nil
    if DATA.popularity_from_where[old_value] == nil then
        DATA.popularity_from_where[old_value] = {}
        return
    end
    for key, value in pairs(DATA.popularity_from_where[old_value]) do
        if value == popularity_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.popularity_from_where[old_value], found_key)
    end
end
---@param popularity_id popularity_id valid popularity id
---@param value realm_id valid realm_id
function DATA.popularity_set_where(popularity_id, value)
    local old_value = DATA.popularity[popularity_id].where
    DATA.popularity[popularity_id].where = value
    __REMOVE_KEY_POPULARITY_WHERE(popularity_id, old_value)
    if DATA.popularity_from_where[value] == nil then DATA.popularity_from_where[value] = {} end
    table.insert(DATA.popularity_from_where[value], popularity_id)
end


local fat_popularity_id_metatable = {
    __index = function (t,k)
        if (k == "value") then return DATA.popularity_get_value(t.id) end
        if (k == "who") then return DATA.popularity_get_who(t.id) end
        if (k == "where") then return DATA.popularity_get_where(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "value") then
            DATA.popularity_set_value(t.id, v)
            return
        end
        if (k == "who") then
            DATA.popularity_set_who(t.id, v)
            return
        end
        if (k == "where") then
            DATA.popularity_set_where(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id popularity_id
---@return fat_popularity_id fat_id
function DATA.fatten_popularity(id)
    local result = {id = id}
    setmetatable(result, fat_popularity_id_metatable)    return result
end
----------jobtype----------


---jobtype: LSP types---

---Unique identificator for jobtype entity
---@alias jobtype_id number

---@class (exact) fat_jobtype_id
---@field id jobtype_id Unique jobtype id
---@field name string 
---@field action_word string 

---@class struct_jobtype

---@class (exact) jobtype_id_data_blob_definition
---@field name string 
---@field action_word string 
---Sets values of jobtype for given id
---@param id jobtype_id
---@param data jobtype_id_data_blob_definition
function DATA.setup_jobtype(id, data)
    DATA.jobtype_set_name(id, data.name)
    DATA.jobtype_set_action_word(id, data.action_word)
end

ffi.cdef[[
    typedef struct {
    } jobtype;
int32_t dcon_create_jobtype();
void dcon_jobtype_resize(uint32_t sz);
]]

---jobtype: FFI arrays---
---@type (string)[]
DATA.jobtype_name= {}
---@type (string)[]
DATA.jobtype_action_word= {}
---@type nil
DATA.jobtype_calloc = ffi.C.calloc(1, ffi.sizeof("jobtype") * 11)
---@type table<jobtype_id, struct_jobtype>
DATA.jobtype = ffi.cast("jobtype*", DATA.jobtype_calloc)

---jobtype: LUA bindings---

DATA.jobtype_size = 10
---@type table<jobtype_id, boolean>
local jobtype_indices_pool = ffi.new("bool[?]", 10)
for i = 1, 9 do
    jobtype_indices_pool[i] = true 
end
---@type table<jobtype_id, jobtype_id>
DATA.jobtype_indices_set = {}
function DATA.create_jobtype()
    ---@type number
    local i = DCON.dcon_create_jobtype() + 1
            DATA.jobtype_indices_set[i] = i
    return i
end
---@param func fun(item: jobtype_id) 
function DATA.for_each_jobtype(func)
    for _, item in pairs(DATA.jobtype_indices_set) do
        func(item)
    end
end
---@param func fun(item: jobtype_id):boolean 
---@return table<jobtype_id, jobtype_id> 
function DATA.filter_jobtype(func)
    ---@type table<jobtype_id, jobtype_id> 
    local t = {}
    for _, item in pairs(DATA.jobtype_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param jobtype_id jobtype_id valid jobtype id
---@return string name 
function DATA.jobtype_get_name(jobtype_id)
    return DATA.jobtype_name[jobtype_id]
end
---@param jobtype_id jobtype_id valid jobtype id
---@param value string valid string
function DATA.jobtype_set_name(jobtype_id, value)
    DATA.jobtype_name[jobtype_id] = value
end
---@param jobtype_id jobtype_id valid jobtype id
---@return string action_word 
function DATA.jobtype_get_action_word(jobtype_id)
    return DATA.jobtype_action_word[jobtype_id]
end
---@param jobtype_id jobtype_id valid jobtype id
---@param value string valid string
function DATA.jobtype_set_action_word(jobtype_id, value)
    DATA.jobtype_action_word[jobtype_id] = value
end


local fat_jobtype_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.jobtype_get_name(t.id) end
        if (k == "action_word") then return DATA.jobtype_get_action_word(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.jobtype_set_name(t.id, v)
            return
        end
        if (k == "action_word") then
            DATA.jobtype_set_action_word(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id jobtype_id
---@return fat_jobtype_id fat_id
function DATA.fatten_jobtype(id)
    local result = {id = id}
    setmetatable(result, fat_jobtype_id_metatable)    return result
end
---@enum JOBTYPE
JOBTYPE = {
    INVALID = 0,
    FORAGER = 1,
    FARMER = 2,
    LABOURER = 3,
    ARTISAN = 4,
    CLERK = 5,
    WARRIOR = 6,
    HAULING = 7,
    HUNTING = 8,
}
local index_jobtype
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "FORAGER")
DATA.jobtype_set_action_word(index_jobtype, "foraging")
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "FARMER")
DATA.jobtype_set_action_word(index_jobtype, "farming")
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "LABOURER")
DATA.jobtype_set_action_word(index_jobtype, "labouring")
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "ARTISAN")
DATA.jobtype_set_action_word(index_jobtype, "artisianship")
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "CLERK")
DATA.jobtype_set_action_word(index_jobtype, "recalling")
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "WARRIOR")
DATA.jobtype_set_action_word(index_jobtype, "fighting")
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "HAULING")
DATA.jobtype_set_action_word(index_jobtype, "hauling")
index_jobtype = DATA.create_jobtype()
DATA.jobtype_set_name(index_jobtype, "HUNTING")
DATA.jobtype_set_action_word(index_jobtype, "hunting")
----------need----------


---need: LSP types---

---Unique identificator for need entity
---@alias need_id number

---@class (exact) fat_need_id
---@field id need_id Unique need id
---@field name string 
---@field age_independent boolean 
---@field life_need boolean 
---@field tool boolean can we use satisfaction of this need in calculations related to production
---@field container boolean can we use satisfaction of this need in calculations related to gathering
---@field time_to_satisfy number Represents amount of time a pop should spend to satisfy a unit of this need.
---@field job_to_satisfy JOBTYPE represents a job type required to satisfy the need on your own

---@class struct_need
---@field age_independent boolean 
---@field life_need boolean 
---@field tool boolean can we use satisfaction of this need in calculations related to production
---@field container boolean can we use satisfaction of this need in calculations related to gathering
---@field time_to_satisfy number Represents amount of time a pop should spend to satisfy a unit of this need.
---@field job_to_satisfy JOBTYPE represents a job type required to satisfy the need on your own

---@class (exact) need_id_data_blob_definition
---@field name string 
---@field age_independent boolean 
---@field life_need boolean 
---@field tool boolean can we use satisfaction of this need in calculations related to production
---@field container boolean can we use satisfaction of this need in calculations related to gathering
---@field time_to_satisfy number Represents amount of time a pop should spend to satisfy a unit of this need.
---@field job_to_satisfy JOBTYPE represents a job type required to satisfy the need on your own
---Sets values of need for given id
---@param id need_id
---@param data need_id_data_blob_definition
function DATA.setup_need(id, data)
    DATA.need_set_name(id, data.name)
    DATA.need_set_age_independent(id, data.age_independent)
    DATA.need_set_life_need(id, data.life_need)
    DATA.need_set_tool(id, data.tool)
    DATA.need_set_container(id, data.container)
    DATA.need_set_time_to_satisfy(id, data.time_to_satisfy)
    DATA.need_set_job_to_satisfy(id, data.job_to_satisfy)
end

ffi.cdef[[
    typedef struct {
        bool age_independent;
        bool life_need;
        bool tool;
        bool container;
        float time_to_satisfy;
        uint8_t job_to_satisfy;
    } need;
int32_t dcon_create_need();
void dcon_need_resize(uint32_t sz);
]]

---need: FFI arrays---
---@type (string)[]
DATA.need_name= {}
---@type nil
DATA.need_calloc = ffi.C.calloc(1, ffi.sizeof("need") * 10)
---@type table<need_id, struct_need>
DATA.need = ffi.cast("need*", DATA.need_calloc)

---need: LUA bindings---

DATA.need_size = 9
---@type table<need_id, boolean>
local need_indices_pool = ffi.new("bool[?]", 9)
for i = 1, 8 do
    need_indices_pool[i] = true 
end
---@type table<need_id, need_id>
DATA.need_indices_set = {}
function DATA.create_need()
    ---@type number
    local i = DCON.dcon_create_need() + 1
            DATA.need_indices_set[i] = i
    return i
end
---@param func fun(item: need_id) 
function DATA.for_each_need(func)
    for _, item in pairs(DATA.need_indices_set) do
        func(item)
    end
end
---@param func fun(item: need_id):boolean 
---@return table<need_id, need_id> 
function DATA.filter_need(func)
    ---@type table<need_id, need_id> 
    local t = {}
    for _, item in pairs(DATA.need_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param need_id need_id valid need id
---@return string name 
function DATA.need_get_name(need_id)
    return DATA.need_name[need_id]
end
---@param need_id need_id valid need id
---@param value string valid string
function DATA.need_set_name(need_id, value)
    DATA.need_name[need_id] = value
end
---@param need_id need_id valid need id
---@return boolean age_independent 
function DATA.need_get_age_independent(need_id)
    return DATA.need[need_id].age_independent
end
---@param need_id need_id valid need id
---@param value boolean valid boolean
function DATA.need_set_age_independent(need_id, value)
    DATA.need[need_id].age_independent = value
end
---@param need_id need_id valid need id
---@return boolean life_need 
function DATA.need_get_life_need(need_id)
    return DATA.need[need_id].life_need
end
---@param need_id need_id valid need id
---@param value boolean valid boolean
function DATA.need_set_life_need(need_id, value)
    DATA.need[need_id].life_need = value
end
---@param need_id need_id valid need id
---@return boolean tool can we use satisfaction of this need in calculations related to production
function DATA.need_get_tool(need_id)
    return DATA.need[need_id].tool
end
---@param need_id need_id valid need id
---@param value boolean valid boolean
function DATA.need_set_tool(need_id, value)
    DATA.need[need_id].tool = value
end
---@param need_id need_id valid need id
---@return boolean container can we use satisfaction of this need in calculations related to gathering
function DATA.need_get_container(need_id)
    return DATA.need[need_id].container
end
---@param need_id need_id valid need id
---@param value boolean valid boolean
function DATA.need_set_container(need_id, value)
    DATA.need[need_id].container = value
end
---@param need_id need_id valid need id
---@return number time_to_satisfy Represents amount of time a pop should spend to satisfy a unit of this need.
function DATA.need_get_time_to_satisfy(need_id)
    return DATA.need[need_id].time_to_satisfy
end
---@param need_id need_id valid need id
---@param value number valid number
function DATA.need_set_time_to_satisfy(need_id, value)
    DATA.need[need_id].time_to_satisfy = value
end
---@param need_id need_id valid need id
---@param value number valid number
function DATA.need_inc_time_to_satisfy(need_id, value)
    DATA.need[need_id].time_to_satisfy = DATA.need[need_id].time_to_satisfy + value
end
---@param need_id need_id valid need id
---@return JOBTYPE job_to_satisfy represents a job type required to satisfy the need on your own
function DATA.need_get_job_to_satisfy(need_id)
    return DATA.need[need_id].job_to_satisfy
end
---@param need_id need_id valid need id
---@param value JOBTYPE valid JOBTYPE
function DATA.need_set_job_to_satisfy(need_id, value)
    DATA.need[need_id].job_to_satisfy = value
end


local fat_need_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.need_get_name(t.id) end
        if (k == "age_independent") then return DATA.need_get_age_independent(t.id) end
        if (k == "life_need") then return DATA.need_get_life_need(t.id) end
        if (k == "tool") then return DATA.need_get_tool(t.id) end
        if (k == "container") then return DATA.need_get_container(t.id) end
        if (k == "time_to_satisfy") then return DATA.need_get_time_to_satisfy(t.id) end
        if (k == "job_to_satisfy") then return DATA.need_get_job_to_satisfy(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.need_set_name(t.id, v)
            return
        end
        if (k == "age_independent") then
            DATA.need_set_age_independent(t.id, v)
            return
        end
        if (k == "life_need") then
            DATA.need_set_life_need(t.id, v)
            return
        end
        if (k == "tool") then
            DATA.need_set_tool(t.id, v)
            return
        end
        if (k == "container") then
            DATA.need_set_container(t.id, v)
            return
        end
        if (k == "time_to_satisfy") then
            DATA.need_set_time_to_satisfy(t.id, v)
            return
        end
        if (k == "job_to_satisfy") then
            DATA.need_set_job_to_satisfy(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id need_id
---@return fat_need_id fat_id
function DATA.fatten_need(id)
    local result = {id = id}
    setmetatable(result, fat_need_id_metatable)    return result
end
---@enum NEED
NEED = {
    INVALID = 0,
    FOOD = 1,
    TOOLS = 2,
    CONTAINER = 3,
    CLOTHING = 4,
    FURNITURE = 5,
    HEALTHCARE = 6,
    LUXURY = 7,
}
local index_need
index_need = DATA.create_need()
DATA.need_set_name(index_need, "food")
DATA.need_set_age_independent(index_need, false)
DATA.need_set_life_need(index_need, true)
DATA.need_set_tool(index_need, false)
DATA.need_set_container(index_need, false)
DATA.need_set_time_to_satisfy(index_need, 1.5)
DATA.need_set_job_to_satisfy(index_need, JOBTYPE.FORAGER)
index_need = DATA.create_need()
DATA.need_set_name(index_need, "tools")
DATA.need_set_age_independent(index_need, false)
DATA.need_set_life_need(index_need, false)
DATA.need_set_tool(index_need, true)
DATA.need_set_container(index_need, false)
DATA.need_set_time_to_satisfy(index_need, 1.0)
DATA.need_set_job_to_satisfy(index_need, JOBTYPE.ARTISAN)
index_need = DATA.create_need()
DATA.need_set_name(index_need, "container")
DATA.need_set_age_independent(index_need, false)
DATA.need_set_life_need(index_need, false)
DATA.need_set_tool(index_need, false)
DATA.need_set_container(index_need, true)
DATA.need_set_time_to_satisfy(index_need, 1.0)
DATA.need_set_job_to_satisfy(index_need, JOBTYPE.ARTISAN)
index_need = DATA.create_need()
DATA.need_set_name(index_need, "clothing")
DATA.need_set_age_independent(index_need, false)
DATA.need_set_life_need(index_need, false)
DATA.need_set_tool(index_need, false)
DATA.need_set_container(index_need, false)
DATA.need_set_time_to_satisfy(index_need, 0.5)
DATA.need_set_job_to_satisfy(index_need, JOBTYPE.LABOURER)
index_need = DATA.create_need()
DATA.need_set_name(index_need, "furniture")
DATA.need_set_age_independent(index_need, false)
DATA.need_set_life_need(index_need, false)
DATA.need_set_tool(index_need, false)
DATA.need_set_container(index_need, false)
DATA.need_set_time_to_satisfy(index_need, 2.0)
DATA.need_set_job_to_satisfy(index_need, JOBTYPE.LABOURER)
index_need = DATA.create_need()
DATA.need_set_name(index_need, "healthcare")
DATA.need_set_age_independent(index_need, false)
DATA.need_set_life_need(index_need, false)
DATA.need_set_tool(index_need, false)
DATA.need_set_container(index_need, false)
DATA.need_set_time_to_satisfy(index_need, 1.0)
DATA.need_set_job_to_satisfy(index_need, JOBTYPE.CLERK)
index_need = DATA.create_need()
DATA.need_set_name(index_need, "luxury")
DATA.need_set_age_independent(index_need, false)
DATA.need_set_life_need(index_need, false)
DATA.need_set_tool(index_need, false)
DATA.need_set_container(index_need, false)
DATA.need_set_time_to_satisfy(index_need, 3.0)
DATA.need_set_job_to_satisfy(index_need, JOBTYPE.ARTISAN)
----------character_rank----------


---character_rank: LSP types---

---Unique identificator for character_rank entity
---@alias character_rank_id number

---@class (exact) fat_character_rank_id
---@field id character_rank_id Unique character_rank id
---@field name string 
---@field localisation string 

---@class struct_character_rank

---@class (exact) character_rank_id_data_blob_definition
---@field name string 
---@field localisation string 
---Sets values of character_rank for given id
---@param id character_rank_id
---@param data character_rank_id_data_blob_definition
function DATA.setup_character_rank(id, data)
    DATA.character_rank_set_name(id, data.name)
    DATA.character_rank_set_localisation(id, data.localisation)
end

ffi.cdef[[
    typedef struct {
    } character_rank;
int32_t dcon_create_character_rank();
void dcon_character_rank_resize(uint32_t sz);
]]

---character_rank: FFI arrays---
---@type (string)[]
DATA.character_rank_name= {}
---@type (string)[]
DATA.character_rank_localisation= {}
---@type nil
DATA.character_rank_calloc = ffi.C.calloc(1, ffi.sizeof("character_rank") * 6)
---@type table<character_rank_id, struct_character_rank>
DATA.character_rank = ffi.cast("character_rank*", DATA.character_rank_calloc)

---character_rank: LUA bindings---

DATA.character_rank_size = 5
---@type table<character_rank_id, boolean>
local character_rank_indices_pool = ffi.new("bool[?]", 5)
for i = 1, 4 do
    character_rank_indices_pool[i] = true 
end
---@type table<character_rank_id, character_rank_id>
DATA.character_rank_indices_set = {}
function DATA.create_character_rank()
    ---@type number
    local i = DCON.dcon_create_character_rank() + 1
            DATA.character_rank_indices_set[i] = i
    return i
end
---@param func fun(item: character_rank_id) 
function DATA.for_each_character_rank(func)
    for _, item in pairs(DATA.character_rank_indices_set) do
        func(item)
    end
end
---@param func fun(item: character_rank_id):boolean 
---@return table<character_rank_id, character_rank_id> 
function DATA.filter_character_rank(func)
    ---@type table<character_rank_id, character_rank_id> 
    local t = {}
    for _, item in pairs(DATA.character_rank_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param character_rank_id character_rank_id valid character_rank id
---@return string name 
function DATA.character_rank_get_name(character_rank_id)
    return DATA.character_rank_name[character_rank_id]
end
---@param character_rank_id character_rank_id valid character_rank id
---@param value string valid string
function DATA.character_rank_set_name(character_rank_id, value)
    DATA.character_rank_name[character_rank_id] = value
end
---@param character_rank_id character_rank_id valid character_rank id
---@return string localisation 
function DATA.character_rank_get_localisation(character_rank_id)
    return DATA.character_rank_localisation[character_rank_id]
end
---@param character_rank_id character_rank_id valid character_rank id
---@param value string valid string
function DATA.character_rank_set_localisation(character_rank_id, value)
    DATA.character_rank_localisation[character_rank_id] = value
end


local fat_character_rank_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.character_rank_get_name(t.id) end
        if (k == "localisation") then return DATA.character_rank_get_localisation(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.character_rank_set_name(t.id, v)
            return
        end
        if (k == "localisation") then
            DATA.character_rank_set_localisation(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id character_rank_id
---@return fat_character_rank_id fat_id
function DATA.fatten_character_rank(id)
    local result = {id = id}
    setmetatable(result, fat_character_rank_id_metatable)    return result
end
---@enum CHARACTER_RANK
CHARACTER_RANK = {
    INVALID = 0,
    POP = 1,
    NOBLE = 2,
    CHIEF = 3,
}
local index_character_rank
index_character_rank = DATA.create_character_rank()
DATA.character_rank_set_name(index_character_rank, "POP")
DATA.character_rank_set_localisation(index_character_rank, "Commoner")
index_character_rank = DATA.create_character_rank()
DATA.character_rank_set_name(index_character_rank, "NOBLE")
DATA.character_rank_set_localisation(index_character_rank, "Noble")
index_character_rank = DATA.create_character_rank()
DATA.character_rank_set_name(index_character_rank, "CHIEF")
DATA.character_rank_set_localisation(index_character_rank, "Chief")
----------trait----------


---trait: LSP types---

---Unique identificator for trait entity
---@alias trait_id number

---@class (exact) fat_trait_id
---@field id trait_id Unique trait id
---@field name string 
---@field short_description string 
---@field full_description string 
---@field icon string 

---@class struct_trait

---@class (exact) trait_id_data_blob_definition
---@field name string 
---@field short_description string 
---@field full_description string 
---@field icon string 
---Sets values of trait for given id
---@param id trait_id
---@param data trait_id_data_blob_definition
function DATA.setup_trait(id, data)
    DATA.trait_set_name(id, data.name)
    DATA.trait_set_short_description(id, data.short_description)
    DATA.trait_set_full_description(id, data.full_description)
    DATA.trait_set_icon(id, data.icon)
end

ffi.cdef[[
    typedef struct {
    } trait;
int32_t dcon_create_trait();
void dcon_trait_resize(uint32_t sz);
]]

---trait: FFI arrays---
---@type (string)[]
DATA.trait_name= {}
---@type (string)[]
DATA.trait_short_description= {}
---@type (string)[]
DATA.trait_full_description= {}
---@type (string)[]
DATA.trait_icon= {}
---@type nil
DATA.trait_calloc = ffi.C.calloc(1, ffi.sizeof("trait") * 13)
---@type table<trait_id, struct_trait>
DATA.trait = ffi.cast("trait*", DATA.trait_calloc)

---trait: LUA bindings---

DATA.trait_size = 12
---@type table<trait_id, boolean>
local trait_indices_pool = ffi.new("bool[?]", 12)
for i = 1, 11 do
    trait_indices_pool[i] = true 
end
---@type table<trait_id, trait_id>
DATA.trait_indices_set = {}
function DATA.create_trait()
    ---@type number
    local i = DCON.dcon_create_trait() + 1
            DATA.trait_indices_set[i] = i
    return i
end
---@param func fun(item: trait_id) 
function DATA.for_each_trait(func)
    for _, item in pairs(DATA.trait_indices_set) do
        func(item)
    end
end
---@param func fun(item: trait_id):boolean 
---@return table<trait_id, trait_id> 
function DATA.filter_trait(func)
    ---@type table<trait_id, trait_id> 
    local t = {}
    for _, item in pairs(DATA.trait_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param trait_id trait_id valid trait id
---@return string name 
function DATA.trait_get_name(trait_id)
    return DATA.trait_name[trait_id]
end
---@param trait_id trait_id valid trait id
---@param value string valid string
function DATA.trait_set_name(trait_id, value)
    DATA.trait_name[trait_id] = value
end
---@param trait_id trait_id valid trait id
---@return string short_description 
function DATA.trait_get_short_description(trait_id)
    return DATA.trait_short_description[trait_id]
end
---@param trait_id trait_id valid trait id
---@param value string valid string
function DATA.trait_set_short_description(trait_id, value)
    DATA.trait_short_description[trait_id] = value
end
---@param trait_id trait_id valid trait id
---@return string full_description 
function DATA.trait_get_full_description(trait_id)
    return DATA.trait_full_description[trait_id]
end
---@param trait_id trait_id valid trait id
---@param value string valid string
function DATA.trait_set_full_description(trait_id, value)
    DATA.trait_full_description[trait_id] = value
end
---@param trait_id trait_id valid trait id
---@return string icon 
function DATA.trait_get_icon(trait_id)
    return DATA.trait_icon[trait_id]
end
---@param trait_id trait_id valid trait id
---@param value string valid string
function DATA.trait_set_icon(trait_id, value)
    DATA.trait_icon[trait_id] = value
end


local fat_trait_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.trait_get_name(t.id) end
        if (k == "short_description") then return DATA.trait_get_short_description(t.id) end
        if (k == "full_description") then return DATA.trait_get_full_description(t.id) end
        if (k == "icon") then return DATA.trait_get_icon(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.trait_set_name(t.id, v)
            return
        end
        if (k == "short_description") then
            DATA.trait_set_short_description(t.id, v)
            return
        end
        if (k == "full_description") then
            DATA.trait_set_full_description(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.trait_set_icon(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id trait_id
---@return fat_trait_id fat_id
function DATA.fatten_trait(id)
    local result = {id = id}
    setmetatable(result, fat_trait_id_metatable)    return result
end
---@enum TRAIT
TRAIT = {
    INVALID = 0,
    AMBITIOUS = 1,
    CONTENT = 2,
    LOYAL = 3,
    GREEDY = 4,
    WARLIKE = 5,
    BAD_ORGANISER = 6,
    GOOD_ORGANISER = 7,
    LAZY = 8,
    HARDWORKER = 9,
    TRADER = 10,
}
local index_trait
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "AMBITIOUS")
DATA.trait_set_short_description(index_trait, "ambitious")
DATA.trait_set_full_description(index_trait, "TODO")
DATA.trait_set_icon(index_trait, "mountaintop.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "CONTENT")
DATA.trait_set_short_description(index_trait, "content")
DATA.trait_set_full_description(index_trait, "This person has no ambitions: it would be hard to persuade them to change occupation")
DATA.trait_set_icon(index_trait, "inner-self.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "LOYAL")
DATA.trait_set_short_description(index_trait, "loyal")
DATA.trait_set_full_description(index_trait, "This person rarely betrays people")
DATA.trait_set_icon(index_trait, "check-mark.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "GREEDY")
DATA.trait_set_short_description(index_trait, "greedy")
DATA.trait_set_full_description(index_trait, "Desire for money drives this person's actions")
DATA.trait_set_icon(index_trait, "receive-money.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "WARLIKE")
DATA.trait_set_short_description(index_trait, "warlike")
DATA.trait_set_full_description(index_trait, "TODO")
DATA.trait_set_icon(index_trait, "barbute.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "BAD_ORGANISER")
DATA.trait_set_short_description(index_trait, "bad organiser")
DATA.trait_set_full_description(index_trait, "TODO")
DATA.trait_set_icon(index_trait, "shrug.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "GOOD_ORGANISER")
DATA.trait_set_short_description(index_trait, "good organiser")
DATA.trait_set_full_description(index_trait, "TODO")
DATA.trait_set_icon(index_trait, "pitchfork.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "LAZY")
DATA.trait_set_short_description(index_trait, "lazy")
DATA.trait_set_full_description(index_trait, "This person prefers to do nothing")
DATA.trait_set_icon(index_trait, "parmecia.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "HARDWORKER")
DATA.trait_set_short_description(index_trait, "hard worker")
DATA.trait_set_full_description(index_trait, "TODO")
DATA.trait_set_icon(index_trait, "miner.png")
index_trait = DATA.create_trait()
DATA.trait_set_name(index_trait, "TRADER")
DATA.trait_set_short_description(index_trait, "trader")
DATA.trait_set_full_description(index_trait, "TODO")
DATA.trait_set_icon(index_trait, "scales.png")
----------trade_good_category----------


---trade_good_category: LSP types---

---Unique identificator for trade_good_category entity
---@alias trade_good_category_id number

---@class (exact) fat_trade_good_category_id
---@field id trade_good_category_id Unique trade_good_category id
---@field name string 

---@class struct_trade_good_category

---@class (exact) trade_good_category_id_data_blob_definition
---@field name string 
---Sets values of trade_good_category for given id
---@param id trade_good_category_id
---@param data trade_good_category_id_data_blob_definition
function DATA.setup_trade_good_category(id, data)
    DATA.trade_good_category_set_name(id, data.name)
end

ffi.cdef[[
    typedef struct {
    } trade_good_category;
int32_t dcon_create_trade_good_category();
void dcon_trade_good_category_resize(uint32_t sz);
]]

---trade_good_category: FFI arrays---
---@type (string)[]
DATA.trade_good_category_name= {}
---@type nil
DATA.trade_good_category_calloc = ffi.C.calloc(1, ffi.sizeof("trade_good_category") * 6)
---@type table<trade_good_category_id, struct_trade_good_category>
DATA.trade_good_category = ffi.cast("trade_good_category*", DATA.trade_good_category_calloc)

---trade_good_category: LUA bindings---

DATA.trade_good_category_size = 5
---@type table<trade_good_category_id, boolean>
local trade_good_category_indices_pool = ffi.new("bool[?]", 5)
for i = 1, 4 do
    trade_good_category_indices_pool[i] = true 
end
---@type table<trade_good_category_id, trade_good_category_id>
DATA.trade_good_category_indices_set = {}
function DATA.create_trade_good_category()
    ---@type number
    local i = DCON.dcon_create_trade_good_category() + 1
            DATA.trade_good_category_indices_set[i] = i
    return i
end
---@param func fun(item: trade_good_category_id) 
function DATA.for_each_trade_good_category(func)
    for _, item in pairs(DATA.trade_good_category_indices_set) do
        func(item)
    end
end
---@param func fun(item: trade_good_category_id):boolean 
---@return table<trade_good_category_id, trade_good_category_id> 
function DATA.filter_trade_good_category(func)
    ---@type table<trade_good_category_id, trade_good_category_id> 
    local t = {}
    for _, item in pairs(DATA.trade_good_category_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param trade_good_category_id trade_good_category_id valid trade_good_category id
---@return string name 
function DATA.trade_good_category_get_name(trade_good_category_id)
    return DATA.trade_good_category_name[trade_good_category_id]
end
---@param trade_good_category_id trade_good_category_id valid trade_good_category id
---@param value string valid string
function DATA.trade_good_category_set_name(trade_good_category_id, value)
    DATA.trade_good_category_name[trade_good_category_id] = value
end


local fat_trade_good_category_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.trade_good_category_get_name(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.trade_good_category_set_name(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id trade_good_category_id
---@return fat_trade_good_category_id fat_id
function DATA.fatten_trade_good_category(id)
    local result = {id = id}
    setmetatable(result, fat_trade_good_category_id_metatable)    return result
end
---@enum TRADE_GOOD_CATEGORY
TRADE_GOOD_CATEGORY = {
    INVALID = 0,
    GOOD = 1,
    SERVICE = 2,
    CAPACITY = 3,
}
local index_trade_good_category
index_trade_good_category = DATA.create_trade_good_category()
DATA.trade_good_category_set_name(index_trade_good_category, "good")
index_trade_good_category = DATA.create_trade_good_category()
DATA.trade_good_category_set_name(index_trade_good_category, "service")
index_trade_good_category = DATA.create_trade_good_category()
DATA.trade_good_category_set_name(index_trade_good_category, "capacity")
----------warband_status----------


---warband_status: LSP types---

---Unique identificator for warband_status entity
---@alias warband_status_id number

---@class (exact) fat_warband_status_id
---@field id warband_status_id Unique warband_status id
---@field name string 

---@class struct_warband_status

---@class (exact) warband_status_id_data_blob_definition
---@field name string 
---Sets values of warband_status for given id
---@param id warband_status_id
---@param data warband_status_id_data_blob_definition
function DATA.setup_warband_status(id, data)
    DATA.warband_status_set_name(id, data.name)
end

ffi.cdef[[
    typedef struct {
    } warband_status;
int32_t dcon_create_warband_status();
void dcon_warband_status_resize(uint32_t sz);
]]

---warband_status: FFI arrays---
---@type (string)[]
DATA.warband_status_name= {}
---@type nil
DATA.warband_status_calloc = ffi.C.calloc(1, ffi.sizeof("warband_status") * 11)
---@type table<warband_status_id, struct_warband_status>
DATA.warband_status = ffi.cast("warband_status*", DATA.warband_status_calloc)

---warband_status: LUA bindings---

DATA.warband_status_size = 10
---@type table<warband_status_id, boolean>
local warband_status_indices_pool = ffi.new("bool[?]", 10)
for i = 1, 9 do
    warband_status_indices_pool[i] = true 
end
---@type table<warband_status_id, warband_status_id>
DATA.warband_status_indices_set = {}
function DATA.create_warband_status()
    ---@type number
    local i = DCON.dcon_create_warband_status() + 1
            DATA.warband_status_indices_set[i] = i
    return i
end
---@param func fun(item: warband_status_id) 
function DATA.for_each_warband_status(func)
    for _, item in pairs(DATA.warband_status_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_status_id):boolean 
---@return table<warband_status_id, warband_status_id> 
function DATA.filter_warband_status(func)
    ---@type table<warband_status_id, warband_status_id> 
    local t = {}
    for _, item in pairs(DATA.warband_status_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_status_id warband_status_id valid warband_status id
---@return string name 
function DATA.warband_status_get_name(warband_status_id)
    return DATA.warband_status_name[warband_status_id]
end
---@param warband_status_id warband_status_id valid warband_status id
---@param value string valid string
function DATA.warband_status_set_name(warband_status_id, value)
    DATA.warband_status_name[warband_status_id] = value
end


local fat_warband_status_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.warband_status_get_name(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.warband_status_set_name(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_status_id
---@return fat_warband_status_id fat_id
function DATA.fatten_warband_status(id)
    local result = {id = id}
    setmetatable(result, fat_warband_status_id_metatable)    return result
end
---@enum WARBAND_STATUS
WARBAND_STATUS = {
    INVALID = 0,
    IDLE = 1,
    RAIDING = 2,
    PREPARING_RAID = 3,
    PREPARING_PATROL = 4,
    PATROL = 5,
    ATTACKING = 6,
    TRAVELLING = 7,
    OFF_DUTY = 8,
}
local index_warband_status
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "idle")
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "raiding")
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "preparing_raid")
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "preparing_patrol")
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "patrol")
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "attacking")
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "travelling")
index_warband_status = DATA.create_warband_status()
DATA.warband_status_set_name(index_warband_status, "off_duty")
----------warband_stance----------


---warband_stance: LSP types---

---Unique identificator for warband_stance entity
---@alias warband_stance_id number

---@class (exact) fat_warband_stance_id
---@field id warband_stance_id Unique warband_stance id
---@field name string 

---@class struct_warband_stance

---@class (exact) warband_stance_id_data_blob_definition
---@field name string 
---Sets values of warband_stance for given id
---@param id warband_stance_id
---@param data warband_stance_id_data_blob_definition
function DATA.setup_warband_stance(id, data)
    DATA.warband_stance_set_name(id, data.name)
end

ffi.cdef[[
    typedef struct {
    } warband_stance;
int32_t dcon_create_warband_stance();
void dcon_warband_stance_resize(uint32_t sz);
]]

---warband_stance: FFI arrays---
---@type (string)[]
DATA.warband_stance_name= {}
---@type nil
DATA.warband_stance_calloc = ffi.C.calloc(1, ffi.sizeof("warband_stance") * 5)
---@type table<warband_stance_id, struct_warband_stance>
DATA.warband_stance = ffi.cast("warband_stance*", DATA.warband_stance_calloc)

---warband_stance: LUA bindings---

DATA.warband_stance_size = 4
---@type table<warband_stance_id, boolean>
local warband_stance_indices_pool = ffi.new("bool[?]", 4)
for i = 1, 3 do
    warband_stance_indices_pool[i] = true 
end
---@type table<warband_stance_id, warband_stance_id>
DATA.warband_stance_indices_set = {}
function DATA.create_warband_stance()
    ---@type number
    local i = DCON.dcon_create_warband_stance() + 1
            DATA.warband_stance_indices_set[i] = i
    return i
end
---@param func fun(item: warband_stance_id) 
function DATA.for_each_warband_stance(func)
    for _, item in pairs(DATA.warband_stance_indices_set) do
        func(item)
    end
end
---@param func fun(item: warband_stance_id):boolean 
---@return table<warband_stance_id, warband_stance_id> 
function DATA.filter_warband_stance(func)
    ---@type table<warband_stance_id, warband_stance_id> 
    local t = {}
    for _, item in pairs(DATA.warband_stance_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param warband_stance_id warband_stance_id valid warband_stance id
---@return string name 
function DATA.warband_stance_get_name(warband_stance_id)
    return DATA.warband_stance_name[warband_stance_id]
end
---@param warband_stance_id warband_stance_id valid warband_stance id
---@param value string valid string
function DATA.warband_stance_set_name(warband_stance_id, value)
    DATA.warband_stance_name[warband_stance_id] = value
end


local fat_warband_stance_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.warband_stance_get_name(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.warband_stance_set_name(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id warband_stance_id
---@return fat_warband_stance_id fat_id
function DATA.fatten_warband_stance(id)
    local result = {id = id}
    setmetatable(result, fat_warband_stance_id_metatable)    return result
end
---@enum WARBAND_STANCE
WARBAND_STANCE = {
    INVALID = 0,
    WORK = 1,
    FORAGE = 2,
}
local index_warband_stance
index_warband_stance = DATA.create_warband_stance()
DATA.warband_stance_set_name(index_warband_stance, "work")
index_warband_stance = DATA.create_warband_stance()
DATA.warband_stance_set_name(index_warband_stance, "forage")
----------building_archetype----------


---building_archetype: LSP types---

---Unique identificator for building_archetype entity
---@alias building_archetype_id number

---@class (exact) fat_building_archetype_id
---@field id building_archetype_id Unique building_archetype id
---@field name string 

---@class struct_building_archetype

---@class (exact) building_archetype_id_data_blob_definition
---@field name string 
---Sets values of building_archetype for given id
---@param id building_archetype_id
---@param data building_archetype_id_data_blob_definition
function DATA.setup_building_archetype(id, data)
    DATA.building_archetype_set_name(id, data.name)
end

ffi.cdef[[
    typedef struct {
    } building_archetype;
int32_t dcon_create_building_archetype();
void dcon_building_archetype_resize(uint32_t sz);
]]

---building_archetype: FFI arrays---
---@type (string)[]
DATA.building_archetype_name= {}
---@type nil
DATA.building_archetype_calloc = ffi.C.calloc(1, ffi.sizeof("building_archetype") * 8)
---@type table<building_archetype_id, struct_building_archetype>
DATA.building_archetype = ffi.cast("building_archetype*", DATA.building_archetype_calloc)

---building_archetype: LUA bindings---

DATA.building_archetype_size = 7
---@type table<building_archetype_id, boolean>
local building_archetype_indices_pool = ffi.new("bool[?]", 7)
for i = 1, 6 do
    building_archetype_indices_pool[i] = true 
end
---@type table<building_archetype_id, building_archetype_id>
DATA.building_archetype_indices_set = {}
function DATA.create_building_archetype()
    ---@type number
    local i = DCON.dcon_create_building_archetype() + 1
            DATA.building_archetype_indices_set[i] = i
    return i
end
---@param func fun(item: building_archetype_id) 
function DATA.for_each_building_archetype(func)
    for _, item in pairs(DATA.building_archetype_indices_set) do
        func(item)
    end
end
---@param func fun(item: building_archetype_id):boolean 
---@return table<building_archetype_id, building_archetype_id> 
function DATA.filter_building_archetype(func)
    ---@type table<building_archetype_id, building_archetype_id> 
    local t = {}
    for _, item in pairs(DATA.building_archetype_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param building_archetype_id building_archetype_id valid building_archetype id
---@return string name 
function DATA.building_archetype_get_name(building_archetype_id)
    return DATA.building_archetype_name[building_archetype_id]
end
---@param building_archetype_id building_archetype_id valid building_archetype id
---@param value string valid string
function DATA.building_archetype_set_name(building_archetype_id, value)
    DATA.building_archetype_name[building_archetype_id] = value
end


local fat_building_archetype_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.building_archetype_get_name(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.building_archetype_set_name(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id building_archetype_id
---@return fat_building_archetype_id fat_id
function DATA.fatten_building_archetype(id)
    local result = {id = id}
    setmetatable(result, fat_building_archetype_id_metatable)    return result
end
---@enum BUILDING_ARCHETYPE
BUILDING_ARCHETYPE = {
    INVALID = 0,
    GROUNDS = 1,
    FARM = 2,
    MINE = 3,
    WORKSHOP = 4,
    DEFENSE = 5,
}
local index_building_archetype
index_building_archetype = DATA.create_building_archetype()
DATA.building_archetype_set_name(index_building_archetype, "GROUNDS")
index_building_archetype = DATA.create_building_archetype()
DATA.building_archetype_set_name(index_building_archetype, "FARM")
index_building_archetype = DATA.create_building_archetype()
DATA.building_archetype_set_name(index_building_archetype, "MINE")
index_building_archetype = DATA.create_building_archetype()
DATA.building_archetype_set_name(index_building_archetype, "WORKSHOP")
index_building_archetype = DATA.create_building_archetype()
DATA.building_archetype_set_name(index_building_archetype, "DEFENSE")
----------forage_resource----------


---forage_resource: LSP types---

---Unique identificator for forage_resource entity
---@alias forage_resource_id number

---@class (exact) fat_forage_resource_id
---@field id forage_resource_id Unique forage_resource id
---@field name string 
---@field description string 
---@field icon string 
---@field handle JOBTYPE 

---@class struct_forage_resource
---@field handle JOBTYPE 

---@class (exact) forage_resource_id_data_blob_definition
---@field name string 
---@field description string 
---@field icon string 
---@field handle JOBTYPE 
---Sets values of forage_resource for given id
---@param id forage_resource_id
---@param data forage_resource_id_data_blob_definition
function DATA.setup_forage_resource(id, data)
    DATA.forage_resource_set_name(id, data.name)
    DATA.forage_resource_set_description(id, data.description)
    DATA.forage_resource_set_icon(id, data.icon)
    DATA.forage_resource_set_handle(id, data.handle)
end

ffi.cdef[[
    typedef struct {
        uint8_t handle;
    } forage_resource;
int32_t dcon_create_forage_resource();
void dcon_forage_resource_resize(uint32_t sz);
]]

---forage_resource: FFI arrays---
---@type (string)[]
DATA.forage_resource_name= {}
---@type (string)[]
DATA.forage_resource_description= {}
---@type (string)[]
DATA.forage_resource_icon= {}
---@type nil
DATA.forage_resource_calloc = ffi.C.calloc(1, ffi.sizeof("forage_resource") * 11)
---@type table<forage_resource_id, struct_forage_resource>
DATA.forage_resource = ffi.cast("forage_resource*", DATA.forage_resource_calloc)

---forage_resource: LUA bindings---

DATA.forage_resource_size = 10
---@type table<forage_resource_id, boolean>
local forage_resource_indices_pool = ffi.new("bool[?]", 10)
for i = 1, 9 do
    forage_resource_indices_pool[i] = true 
end
---@type table<forage_resource_id, forage_resource_id>
DATA.forage_resource_indices_set = {}
function DATA.create_forage_resource()
    ---@type number
    local i = DCON.dcon_create_forage_resource() + 1
            DATA.forage_resource_indices_set[i] = i
    return i
end
---@param func fun(item: forage_resource_id) 
function DATA.for_each_forage_resource(func)
    for _, item in pairs(DATA.forage_resource_indices_set) do
        func(item)
    end
end
---@param func fun(item: forage_resource_id):boolean 
---@return table<forage_resource_id, forage_resource_id> 
function DATA.filter_forage_resource(func)
    ---@type table<forage_resource_id, forage_resource_id> 
    local t = {}
    for _, item in pairs(DATA.forage_resource_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param forage_resource_id forage_resource_id valid forage_resource id
---@return string name 
function DATA.forage_resource_get_name(forage_resource_id)
    return DATA.forage_resource_name[forage_resource_id]
end
---@param forage_resource_id forage_resource_id valid forage_resource id
---@param value string valid string
function DATA.forage_resource_set_name(forage_resource_id, value)
    DATA.forage_resource_name[forage_resource_id] = value
end
---@param forage_resource_id forage_resource_id valid forage_resource id
---@return string description 
function DATA.forage_resource_get_description(forage_resource_id)
    return DATA.forage_resource_description[forage_resource_id]
end
---@param forage_resource_id forage_resource_id valid forage_resource id
---@param value string valid string
function DATA.forage_resource_set_description(forage_resource_id, value)
    DATA.forage_resource_description[forage_resource_id] = value
end
---@param forage_resource_id forage_resource_id valid forage_resource id
---@return string icon 
function DATA.forage_resource_get_icon(forage_resource_id)
    return DATA.forage_resource_icon[forage_resource_id]
end
---@param forage_resource_id forage_resource_id valid forage_resource id
---@param value string valid string
function DATA.forage_resource_set_icon(forage_resource_id, value)
    DATA.forage_resource_icon[forage_resource_id] = value
end
---@param forage_resource_id forage_resource_id valid forage_resource id
---@return JOBTYPE handle 
function DATA.forage_resource_get_handle(forage_resource_id)
    return DATA.forage_resource[forage_resource_id].handle
end
---@param forage_resource_id forage_resource_id valid forage_resource id
---@param value JOBTYPE valid JOBTYPE
function DATA.forage_resource_set_handle(forage_resource_id, value)
    DATA.forage_resource[forage_resource_id].handle = value
end


local fat_forage_resource_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.forage_resource_get_name(t.id) end
        if (k == "description") then return DATA.forage_resource_get_description(t.id) end
        if (k == "icon") then return DATA.forage_resource_get_icon(t.id) end
        if (k == "handle") then return DATA.forage_resource_get_handle(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.forage_resource_set_name(t.id, v)
            return
        end
        if (k == "description") then
            DATA.forage_resource_set_description(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.forage_resource_set_icon(t.id, v)
            return
        end
        if (k == "handle") then
            DATA.forage_resource_set_handle(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id forage_resource_id
---@return fat_forage_resource_id fat_id
function DATA.fatten_forage_resource(id)
    local result = {id = id}
    setmetatable(result, fat_forage_resource_id_metatable)    return result
end
---@enum FORAGE_RESOURCE
FORAGE_RESOURCE = {
    INVALID = 0,
    WATER = 1,
    FRUIT = 2,
    GRAIN = 3,
    GAME = 4,
    FUNGI = 5,
    SHELL = 6,
    FISH = 7,
    WOOD = 8,
}
local index_forage_resource
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Water")
DATA.forage_resource_set_description(index_forage_resource, "water")
DATA.forage_resource_set_icon(index_forage_resource, "droplets.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.HAULING)
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Fruit")
DATA.forage_resource_set_description(index_forage_resource, "berries")
DATA.forage_resource_set_icon(index_forage_resource, "berries-bowl.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.FORAGER)
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Grain")
DATA.forage_resource_set_description(index_forage_resource, "seeds")
DATA.forage_resource_set_icon(index_forage_resource, "wheat.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.FARMER)
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Game")
DATA.forage_resource_set_description(index_forage_resource, "game")
DATA.forage_resource_set_icon(index_forage_resource, "bison.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.HUNTING)
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Fungi")
DATA.forage_resource_set_description(index_forage_resource, "mushrooms")
DATA.forage_resource_set_icon(index_forage_resource, "chanterelles.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.CLERK)
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Shell")
DATA.forage_resource_set_description(index_forage_resource, "shellfish")
DATA.forage_resource_set_icon(index_forage_resource, "oyster.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.HAULING)
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Fish")
DATA.forage_resource_set_description(index_forage_resource, "fish")
DATA.forage_resource_set_icon(index_forage_resource, "salmon.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.LABOURER)
index_forage_resource = DATA.create_forage_resource()
DATA.forage_resource_set_name(index_forage_resource, "Wood")
DATA.forage_resource_set_description(index_forage_resource, "timber")
DATA.forage_resource_set_icon(index_forage_resource, "pine-tree.png")
DATA.forage_resource_set_handle(index_forage_resource, JOBTYPE.ARTISAN)
----------budget_category----------


---budget_category: LSP types---

---Unique identificator for budget_category entity
---@alias budget_category_id number

---@class (exact) fat_budget_category_id
---@field id budget_category_id Unique budget_category id
---@field name string 

---@class struct_budget_category

---@class (exact) budget_category_id_data_blob_definition
---@field name string 
---Sets values of budget_category for given id
---@param id budget_category_id
---@param data budget_category_id_data_blob_definition
function DATA.setup_budget_category(id, data)
    DATA.budget_category_set_name(id, data.name)
end

ffi.cdef[[
    typedef struct {
    } budget_category;
int32_t dcon_create_budget_category();
void dcon_budget_category_resize(uint32_t sz);
]]

---budget_category: FFI arrays---
---@type (string)[]
DATA.budget_category_name= {}
---@type nil
DATA.budget_category_calloc = ffi.C.calloc(1, ffi.sizeof("budget_category") * 8)
---@type table<budget_category_id, struct_budget_category>
DATA.budget_category = ffi.cast("budget_category*", DATA.budget_category_calloc)

---budget_category: LUA bindings---

DATA.budget_category_size = 7
---@type table<budget_category_id, boolean>
local budget_category_indices_pool = ffi.new("bool[?]", 7)
for i = 1, 6 do
    budget_category_indices_pool[i] = true 
end
---@type table<budget_category_id, budget_category_id>
DATA.budget_category_indices_set = {}
function DATA.create_budget_category()
    ---@type number
    local i = DCON.dcon_create_budget_category() + 1
            DATA.budget_category_indices_set[i] = i
    return i
end
---@param func fun(item: budget_category_id) 
function DATA.for_each_budget_category(func)
    for _, item in pairs(DATA.budget_category_indices_set) do
        func(item)
    end
end
---@param func fun(item: budget_category_id):boolean 
---@return table<budget_category_id, budget_category_id> 
function DATA.filter_budget_category(func)
    ---@type table<budget_category_id, budget_category_id> 
    local t = {}
    for _, item in pairs(DATA.budget_category_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param budget_category_id budget_category_id valid budget_category id
---@return string name 
function DATA.budget_category_get_name(budget_category_id)
    return DATA.budget_category_name[budget_category_id]
end
---@param budget_category_id budget_category_id valid budget_category id
---@param value string valid string
function DATA.budget_category_set_name(budget_category_id, value)
    DATA.budget_category_name[budget_category_id] = value
end


local fat_budget_category_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.budget_category_get_name(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.budget_category_set_name(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id budget_category_id
---@return fat_budget_category_id fat_id
function DATA.fatten_budget_category(id)
    local result = {id = id}
    setmetatable(result, fat_budget_category_id_metatable)    return result
end
---@enum BUDGET_CATEGORY
BUDGET_CATEGORY = {
    INVALID = 0,
    EDUCATION = 1,
    COURT = 2,
    INFRASTRUCTURE = 3,
    MILITARY = 4,
    TRIBUTE = 5,
}
local index_budget_category
index_budget_category = DATA.create_budget_category()
DATA.budget_category_set_name(index_budget_category, "education")
index_budget_category = DATA.create_budget_category()
DATA.budget_category_set_name(index_budget_category, "court")
index_budget_category = DATA.create_budget_category()
DATA.budget_category_set_name(index_budget_category, "infrastructure")
index_budget_category = DATA.create_budget_category()
DATA.budget_category_set_name(index_budget_category, "military")
index_budget_category = DATA.create_budget_category()
DATA.budget_category_set_name(index_budget_category, "tribute")
----------economy_reason----------


---economy_reason: LSP types---

---Unique identificator for economy_reason entity
---@alias economy_reason_id number

---@class (exact) fat_economy_reason_id
---@field id economy_reason_id Unique economy_reason id
---@field name string 
---@field description string 

---@class struct_economy_reason

---@class (exact) economy_reason_id_data_blob_definition
---@field name string 
---@field description string 
---Sets values of economy_reason for given id
---@param id economy_reason_id
---@param data economy_reason_id_data_blob_definition
function DATA.setup_economy_reason(id, data)
    DATA.economy_reason_set_name(id, data.name)
    DATA.economy_reason_set_description(id, data.description)
end

ffi.cdef[[
    typedef struct {
    } economy_reason;
int32_t dcon_create_economy_reason();
void dcon_economy_reason_resize(uint32_t sz);
]]

---economy_reason: FFI arrays---
---@type (string)[]
DATA.economy_reason_name= {}
---@type (string)[]
DATA.economy_reason_description= {}
---@type nil
DATA.economy_reason_calloc = ffi.C.calloc(1, ffi.sizeof("economy_reason") * 39)
---@type table<economy_reason_id, struct_economy_reason>
DATA.economy_reason = ffi.cast("economy_reason*", DATA.economy_reason_calloc)

---economy_reason: LUA bindings---

DATA.economy_reason_size = 38
---@type table<economy_reason_id, boolean>
local economy_reason_indices_pool = ffi.new("bool[?]", 38)
for i = 1, 37 do
    economy_reason_indices_pool[i] = true 
end
---@type table<economy_reason_id, economy_reason_id>
DATA.economy_reason_indices_set = {}
function DATA.create_economy_reason()
    ---@type number
    local i = DCON.dcon_create_economy_reason() + 1
            DATA.economy_reason_indices_set[i] = i
    return i
end
---@param func fun(item: economy_reason_id) 
function DATA.for_each_economy_reason(func)
    for _, item in pairs(DATA.economy_reason_indices_set) do
        func(item)
    end
end
---@param func fun(item: economy_reason_id):boolean 
---@return table<economy_reason_id, economy_reason_id> 
function DATA.filter_economy_reason(func)
    ---@type table<economy_reason_id, economy_reason_id> 
    local t = {}
    for _, item in pairs(DATA.economy_reason_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param economy_reason_id economy_reason_id valid economy_reason id
---@return string name 
function DATA.economy_reason_get_name(economy_reason_id)
    return DATA.economy_reason_name[economy_reason_id]
end
---@param economy_reason_id economy_reason_id valid economy_reason id
---@param value string valid string
function DATA.economy_reason_set_name(economy_reason_id, value)
    DATA.economy_reason_name[economy_reason_id] = value
end
---@param economy_reason_id economy_reason_id valid economy_reason id
---@return string description 
function DATA.economy_reason_get_description(economy_reason_id)
    return DATA.economy_reason_description[economy_reason_id]
end
---@param economy_reason_id economy_reason_id valid economy_reason id
---@param value string valid string
function DATA.economy_reason_set_description(economy_reason_id, value)
    DATA.economy_reason_description[economy_reason_id] = value
end


local fat_economy_reason_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.economy_reason_get_name(t.id) end
        if (k == "description") then return DATA.economy_reason_get_description(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.economy_reason_set_name(t.id, v)
            return
        end
        if (k == "description") then
            DATA.economy_reason_set_description(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id economy_reason_id
---@return fat_economy_reason_id fat_id
function DATA.fatten_economy_reason(id)
    local result = {id = id}
    setmetatable(result, fat_economy_reason_id_metatable)    return result
end
---@enum ECONOMY_REASON
ECONOMY_REASON = {
    INVALID = 0,
    BASIC_NEEDS = 1,
    WELFARE = 2,
    RAID = 3,
    DONATION = 4,
    MONTHLY_CHANGE = 5,
    YEARLY_CHANGE = 6,
    INFRASTRUCTURE = 7,
    EDUCATION = 8,
    COURT = 9,
    MILITARY = 10,
    EXPLORATION = 11,
    UPKEEP = 12,
    NEW_MONTH = 13,
    LOYALTY_GIFT = 14,
    BUILDING = 15,
    BUILDING_INCOME = 16,
    TREASURY = 17,
    BUDGET = 18,
    WASTE = 19,
    TRIBUTE = 20,
    INHERITANCE = 21,
    TRADE = 22,
    WARBAND = 23,
    WATER = 24,
    FOOD = 25,
    OTHER_NEEDS = 26,
    FORAGE = 27,
    WORK = 28,
    OTHER = 29,
    SIPHON = 30,
    TRADE_SIPHON = 31,
    QUEST = 32,
    NEIGHBOR_SIPHON = 33,
    COLONISATION = 34,
    TAX = 35,
    NEGOTIATIONS = 36,
}
local index_economy_reason
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Basic_Needs")
DATA.economy_reason_set_description(index_economy_reason, "Basic needs")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Welfare")
DATA.economy_reason_set_description(index_economy_reason, "Welfare")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Raid")
DATA.economy_reason_set_description(index_economy_reason, "Eaid")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Donation")
DATA.economy_reason_set_description(index_economy_reason, "Donation")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Monthly_Change")
DATA.economy_reason_set_description(index_economy_reason, "Monthly change")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Yearly_Change")
DATA.economy_reason_set_description(index_economy_reason, "Yearly change")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Infrastructure")
DATA.economy_reason_set_description(index_economy_reason, "Infrastructure")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Education")
DATA.economy_reason_set_description(index_economy_reason, "Education")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Court")
DATA.economy_reason_set_description(index_economy_reason, "Court")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Military")
DATA.economy_reason_set_description(index_economy_reason, "Military")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Exploration")
DATA.economy_reason_set_description(index_economy_reason, "Exploration")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Upkeep")
DATA.economy_reason_set_description(index_economy_reason, "Upkeep")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "New_Month")
DATA.economy_reason_set_description(index_economy_reason, "New month")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Loyalty_Gift")
DATA.economy_reason_set_description(index_economy_reason, "Loyalty gift")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Building")
DATA.economy_reason_set_description(index_economy_reason, "Building")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Building_Income")
DATA.economy_reason_set_description(index_economy_reason, "Building income")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Treasury")
DATA.economy_reason_set_description(index_economy_reason, "Treasury")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Budget")
DATA.economy_reason_set_description(index_economy_reason, "Budget")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Waste")
DATA.economy_reason_set_description(index_economy_reason, "Waste")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Tribute")
DATA.economy_reason_set_description(index_economy_reason, "Tribute")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Inheritance")
DATA.economy_reason_set_description(index_economy_reason, "Inheritance")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Trade")
DATA.economy_reason_set_description(index_economy_reason, "Trade")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Warband")
DATA.economy_reason_set_description(index_economy_reason, "Warband")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Water")
DATA.economy_reason_set_description(index_economy_reason, "Water")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Food")
DATA.economy_reason_set_description(index_economy_reason, "Food")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Other_Needs")
DATA.economy_reason_set_description(index_economy_reason, "Other needs")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Forage")
DATA.economy_reason_set_description(index_economy_reason, "Forage")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Work")
DATA.economy_reason_set_description(index_economy_reason, "Work")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Other")
DATA.economy_reason_set_description(index_economy_reason, "Other")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Siphon")
DATA.economy_reason_set_description(index_economy_reason, "Siphon")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Trade_Siphon")
DATA.economy_reason_set_description(index_economy_reason, "Trade siphon")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Quest")
DATA.economy_reason_set_description(index_economy_reason, "Quest")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Neighbor_Siphon")
DATA.economy_reason_set_description(index_economy_reason, "Neigbour siphon")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Colonisation")
DATA.economy_reason_set_description(index_economy_reason, "Colonisation")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Tax")
DATA.economy_reason_set_description(index_economy_reason, "Tax")
index_economy_reason = DATA.create_economy_reason()
DATA.economy_reason_set_name(index_economy_reason, "Negotiations")
DATA.economy_reason_set_description(index_economy_reason, "Negotiations")
----------trade_good----------


---trade_good: LSP types---

---Unique identificator for trade_good entity
---@alias trade_good_id number

---@class (exact) fat_trade_good_id
---@field id trade_good_id Unique trade_good id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field category TRADE_GOOD_CATEGORY 
---@field base_price number 

---@class struct_trade_good
---@field r number 
---@field g number 
---@field b number 
---@field category TRADE_GOOD_CATEGORY 
---@field base_price number 

---@class (exact) trade_good_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field category TRADE_GOOD_CATEGORY? 
---@field base_price number 
---Sets values of trade_good for given id
---@param id trade_good_id
---@param data trade_good_id_data_blob_definition
function DATA.setup_trade_good(id, data)
    DATA.trade_good_set_category(id, TRADE_GOOD_CATEGORY.GOOD)
    DATA.trade_good_set_name(id, data.name)
    DATA.trade_good_set_icon(id, data.icon)
    DATA.trade_good_set_description(id, data.description)
    DATA.trade_good_set_r(id, data.r)
    DATA.trade_good_set_g(id, data.g)
    DATA.trade_good_set_b(id, data.b)
    if data.category ~= nil then
        DATA.trade_good_set_category(id, data.category)
    end
    DATA.trade_good_set_base_price(id, data.base_price)
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        uint8_t category;
        float base_price;
    } trade_good;
int32_t dcon_create_trade_good();
void dcon_trade_good_resize(uint32_t sz);
]]

---trade_good: FFI arrays---
---@type (string)[]
DATA.trade_good_name= {}
---@type (string)[]
DATA.trade_good_icon= {}
---@type (string)[]
DATA.trade_good_description= {}
---@type nil
DATA.trade_good_calloc = ffi.C.calloc(1, ffi.sizeof("trade_good") * 101)
---@type table<trade_good_id, struct_trade_good>
DATA.trade_good = ffi.cast("trade_good*", DATA.trade_good_calloc)

---trade_good: LUA bindings---

DATA.trade_good_size = 100
---@type table<trade_good_id, boolean>
local trade_good_indices_pool = ffi.new("bool[?]", 100)
for i = 1, 99 do
    trade_good_indices_pool[i] = true 
end
---@type table<trade_good_id, trade_good_id>
DATA.trade_good_indices_set = {}
function DATA.create_trade_good()
    ---@type number
    local i = DCON.dcon_create_trade_good() + 1
            DATA.trade_good_indices_set[i] = i
    return i
end
---@param func fun(item: trade_good_id) 
function DATA.for_each_trade_good(func)
    for _, item in pairs(DATA.trade_good_indices_set) do
        func(item)
    end
end
---@param func fun(item: trade_good_id):boolean 
---@return table<trade_good_id, trade_good_id> 
function DATA.filter_trade_good(func)
    ---@type table<trade_good_id, trade_good_id> 
    local t = {}
    for _, item in pairs(DATA.trade_good_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param trade_good_id trade_good_id valid trade_good id
---@return string name 
function DATA.trade_good_get_name(trade_good_id)
    return DATA.trade_good_name[trade_good_id]
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value string valid string
function DATA.trade_good_set_name(trade_good_id, value)
    DATA.trade_good_name[trade_good_id] = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@return string icon 
function DATA.trade_good_get_icon(trade_good_id)
    return DATA.trade_good_icon[trade_good_id]
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value string valid string
function DATA.trade_good_set_icon(trade_good_id, value)
    DATA.trade_good_icon[trade_good_id] = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@return string description 
function DATA.trade_good_get_description(trade_good_id)
    return DATA.trade_good_description[trade_good_id]
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value string valid string
function DATA.trade_good_set_description(trade_good_id, value)
    DATA.trade_good_description[trade_good_id] = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@return number r 
function DATA.trade_good_get_r(trade_good_id)
    return DATA.trade_good[trade_good_id].r
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_set_r(trade_good_id, value)
    DATA.trade_good[trade_good_id].r = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_inc_r(trade_good_id, value)
    DATA.trade_good[trade_good_id].r = DATA.trade_good[trade_good_id].r + value
end
---@param trade_good_id trade_good_id valid trade_good id
---@return number g 
function DATA.trade_good_get_g(trade_good_id)
    return DATA.trade_good[trade_good_id].g
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_set_g(trade_good_id, value)
    DATA.trade_good[trade_good_id].g = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_inc_g(trade_good_id, value)
    DATA.trade_good[trade_good_id].g = DATA.trade_good[trade_good_id].g + value
end
---@param trade_good_id trade_good_id valid trade_good id
---@return number b 
function DATA.trade_good_get_b(trade_good_id)
    return DATA.trade_good[trade_good_id].b
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_set_b(trade_good_id, value)
    DATA.trade_good[trade_good_id].b = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_inc_b(trade_good_id, value)
    DATA.trade_good[trade_good_id].b = DATA.trade_good[trade_good_id].b + value
end
---@param trade_good_id trade_good_id valid trade_good id
---@return TRADE_GOOD_CATEGORY category 
function DATA.trade_good_get_category(trade_good_id)
    return DATA.trade_good[trade_good_id].category
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value TRADE_GOOD_CATEGORY valid TRADE_GOOD_CATEGORY
function DATA.trade_good_set_category(trade_good_id, value)
    DATA.trade_good[trade_good_id].category = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@return number base_price 
function DATA.trade_good_get_base_price(trade_good_id)
    return DATA.trade_good[trade_good_id].base_price
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_set_base_price(trade_good_id, value)
    DATA.trade_good[trade_good_id].base_price = value
end
---@param trade_good_id trade_good_id valid trade_good id
---@param value number valid number
function DATA.trade_good_inc_base_price(trade_good_id, value)
    DATA.trade_good[trade_good_id].base_price = DATA.trade_good[trade_good_id].base_price + value
end


local fat_trade_good_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.trade_good_get_name(t.id) end
        if (k == "icon") then return DATA.trade_good_get_icon(t.id) end
        if (k == "description") then return DATA.trade_good_get_description(t.id) end
        if (k == "r") then return DATA.trade_good_get_r(t.id) end
        if (k == "g") then return DATA.trade_good_get_g(t.id) end
        if (k == "b") then return DATA.trade_good_get_b(t.id) end
        if (k == "category") then return DATA.trade_good_get_category(t.id) end
        if (k == "base_price") then return DATA.trade_good_get_base_price(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.trade_good_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.trade_good_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.trade_good_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.trade_good_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.trade_good_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.trade_good_set_b(t.id, v)
            return
        end
        if (k == "category") then
            DATA.trade_good_set_category(t.id, v)
            return
        end
        if (k == "base_price") then
            DATA.trade_good_set_base_price(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id trade_good_id
---@return fat_trade_good_id fat_id
function DATA.fatten_trade_good(id)
    local result = {id = id}
    setmetatable(result, fat_trade_good_id_metatable)    return result
end
----------use_case----------


---use_case: LSP types---

---Unique identificator for use_case entity
---@alias use_case_id number

---@class (exact) fat_use_case_id
---@field id use_case_id Unique use_case id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 

---@class struct_use_case
---@field r number 
---@field g number 
---@field b number 

---@class (exact) use_case_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---Sets values of use_case for given id
---@param id use_case_id
---@param data use_case_id_data_blob_definition
function DATA.setup_use_case(id, data)
    DATA.use_case_set_name(id, data.name)
    DATA.use_case_set_icon(id, data.icon)
    DATA.use_case_set_description(id, data.description)
    DATA.use_case_set_r(id, data.r)
    DATA.use_case_set_g(id, data.g)
    DATA.use_case_set_b(id, data.b)
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
    } use_case;
int32_t dcon_create_use_case();
void dcon_use_case_resize(uint32_t sz);
]]

---use_case: FFI arrays---
---@type (string)[]
DATA.use_case_name= {}
---@type (string)[]
DATA.use_case_icon= {}
---@type (string)[]
DATA.use_case_description= {}
---@type nil
DATA.use_case_calloc = ffi.C.calloc(1, ffi.sizeof("use_case") * 101)
---@type table<use_case_id, struct_use_case>
DATA.use_case = ffi.cast("use_case*", DATA.use_case_calloc)

---use_case: LUA bindings---

DATA.use_case_size = 100
---@type table<use_case_id, boolean>
local use_case_indices_pool = ffi.new("bool[?]", 100)
for i = 1, 99 do
    use_case_indices_pool[i] = true 
end
---@type table<use_case_id, use_case_id>
DATA.use_case_indices_set = {}
function DATA.create_use_case()
    ---@type number
    local i = DCON.dcon_create_use_case() + 1
            DATA.use_case_indices_set[i] = i
    return i
end
---@param func fun(item: use_case_id) 
function DATA.for_each_use_case(func)
    for _, item in pairs(DATA.use_case_indices_set) do
        func(item)
    end
end
---@param func fun(item: use_case_id):boolean 
---@return table<use_case_id, use_case_id> 
function DATA.filter_use_case(func)
    ---@type table<use_case_id, use_case_id> 
    local t = {}
    for _, item in pairs(DATA.use_case_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param use_case_id use_case_id valid use_case id
---@return string name 
function DATA.use_case_get_name(use_case_id)
    return DATA.use_case_name[use_case_id]
end
---@param use_case_id use_case_id valid use_case id
---@param value string valid string
function DATA.use_case_set_name(use_case_id, value)
    DATA.use_case_name[use_case_id] = value
end
---@param use_case_id use_case_id valid use_case id
---@return string icon 
function DATA.use_case_get_icon(use_case_id)
    return DATA.use_case_icon[use_case_id]
end
---@param use_case_id use_case_id valid use_case id
---@param value string valid string
function DATA.use_case_set_icon(use_case_id, value)
    DATA.use_case_icon[use_case_id] = value
end
---@param use_case_id use_case_id valid use_case id
---@return string description 
function DATA.use_case_get_description(use_case_id)
    return DATA.use_case_description[use_case_id]
end
---@param use_case_id use_case_id valid use_case id
---@param value string valid string
function DATA.use_case_set_description(use_case_id, value)
    DATA.use_case_description[use_case_id] = value
end
---@param use_case_id use_case_id valid use_case id
---@return number r 
function DATA.use_case_get_r(use_case_id)
    return DATA.use_case[use_case_id].r
end
---@param use_case_id use_case_id valid use_case id
---@param value number valid number
function DATA.use_case_set_r(use_case_id, value)
    DATA.use_case[use_case_id].r = value
end
---@param use_case_id use_case_id valid use_case id
---@param value number valid number
function DATA.use_case_inc_r(use_case_id, value)
    DATA.use_case[use_case_id].r = DATA.use_case[use_case_id].r + value
end
---@param use_case_id use_case_id valid use_case id
---@return number g 
function DATA.use_case_get_g(use_case_id)
    return DATA.use_case[use_case_id].g
end
---@param use_case_id use_case_id valid use_case id
---@param value number valid number
function DATA.use_case_set_g(use_case_id, value)
    DATA.use_case[use_case_id].g = value
end
---@param use_case_id use_case_id valid use_case id
---@param value number valid number
function DATA.use_case_inc_g(use_case_id, value)
    DATA.use_case[use_case_id].g = DATA.use_case[use_case_id].g + value
end
---@param use_case_id use_case_id valid use_case id
---@return number b 
function DATA.use_case_get_b(use_case_id)
    return DATA.use_case[use_case_id].b
end
---@param use_case_id use_case_id valid use_case id
---@param value number valid number
function DATA.use_case_set_b(use_case_id, value)
    DATA.use_case[use_case_id].b = value
end
---@param use_case_id use_case_id valid use_case id
---@param value number valid number
function DATA.use_case_inc_b(use_case_id, value)
    DATA.use_case[use_case_id].b = DATA.use_case[use_case_id].b + value
end


local fat_use_case_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.use_case_get_name(t.id) end
        if (k == "icon") then return DATA.use_case_get_icon(t.id) end
        if (k == "description") then return DATA.use_case_get_description(t.id) end
        if (k == "r") then return DATA.use_case_get_r(t.id) end
        if (k == "g") then return DATA.use_case_get_g(t.id) end
        if (k == "b") then return DATA.use_case_get_b(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.use_case_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.use_case_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.use_case_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.use_case_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.use_case_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.use_case_set_b(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id use_case_id
---@return fat_use_case_id fat_id
function DATA.fatten_use_case(id)
    local result = {id = id}
    setmetatable(result, fat_use_case_id_metatable)    return result
end
----------use_weight----------


---use_weight: LSP types---

---Unique identificator for use_weight entity
---@alias use_weight_id number

---@class (exact) fat_use_weight_id
---@field id use_weight_id Unique use_weight id
---@field weight number efficiency of this relation
---@field trade_good trade_good_id index of trade good
---@field use_case use_case_id index of use case

---@class struct_use_weight
---@field weight number efficiency of this relation
---@field trade_good trade_good_id index of trade good
---@field use_case use_case_id index of use case

---@class (exact) use_weight_id_data_blob_definition
---@field weight number efficiency of this relation
---@field trade_good trade_good_id index of trade good
---@field use_case use_case_id index of use case
---Sets values of use_weight for given id
---@param id use_weight_id
---@param data use_weight_id_data_blob_definition
function DATA.setup_use_weight(id, data)
    DATA.use_weight_set_weight(id, data.weight)
end

ffi.cdef[[
    typedef struct {
        float weight;
        uint32_t trade_good;
        uint32_t use_case;
    } use_weight;
int32_t dcon_create_use_weight();
void dcon_use_weight_resize(uint32_t sz);
]]

---use_weight: FFI arrays---
---@type nil
DATA.use_weight_calloc = ffi.C.calloc(1, ffi.sizeof("use_weight") * 301)
---@type table<use_weight_id, struct_use_weight>
DATA.use_weight = ffi.cast("use_weight*", DATA.use_weight_calloc)
---@type table<trade_good_id, use_weight_id[]>>
DATA.use_weight_from_trade_good= {}
for i = 1, 300 do
    DATA.use_weight_from_trade_good[i] = {}
end
---@type table<use_case_id, use_weight_id[]>>
DATA.use_weight_from_use_case= {}
for i = 1, 300 do
    DATA.use_weight_from_use_case[i] = {}
end

---use_weight: LUA bindings---

DATA.use_weight_size = 300
---@type table<use_weight_id, boolean>
local use_weight_indices_pool = ffi.new("bool[?]", 300)
for i = 1, 299 do
    use_weight_indices_pool[i] = true 
end
---@type table<use_weight_id, use_weight_id>
DATA.use_weight_indices_set = {}
function DATA.create_use_weight()
    ---@type number
    local i = DCON.dcon_create_use_weight() + 1
            DATA.use_weight_indices_set[i] = i
    return i
end
---@param func fun(item: use_weight_id) 
function DATA.for_each_use_weight(func)
    for _, item in pairs(DATA.use_weight_indices_set) do
        func(item)
    end
end
---@param func fun(item: use_weight_id):boolean 
---@return table<use_weight_id, use_weight_id> 
function DATA.filter_use_weight(func)
    ---@type table<use_weight_id, use_weight_id> 
    local t = {}
    for _, item in pairs(DATA.use_weight_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param use_weight_id use_weight_id valid use_weight id
---@return number weight efficiency of this relation
function DATA.use_weight_get_weight(use_weight_id)
    return DATA.use_weight[use_weight_id].weight
end
---@param use_weight_id use_weight_id valid use_weight id
---@param value number valid number
function DATA.use_weight_set_weight(use_weight_id, value)
    DATA.use_weight[use_weight_id].weight = value
end
---@param use_weight_id use_weight_id valid use_weight id
---@param value number valid number
function DATA.use_weight_inc_weight(use_weight_id, value)
    DATA.use_weight[use_weight_id].weight = DATA.use_weight[use_weight_id].weight + value
end
---@param use_weight_id use_weight_id valid use_weight id
---@return trade_good_id trade_good index of trade good
function DATA.use_weight_get_trade_good(use_weight_id)
    return DATA.use_weight[use_weight_id].trade_good
end
---@param trade_good trade_good_id valid trade_good_id
---@return use_weight_id[] An array of use_weight 
function DATA.get_use_weight_from_trade_good(trade_good)
    return DATA.use_weight_from_trade_good[trade_good]
end
---@param trade_good trade_good_id valid trade_good_id
---@param func fun(item: use_weight_id) valid trade_good_id
function DATA.for_each_use_weight_from_trade_good(trade_good, func)
    if DATA.use_weight_from_trade_good[trade_good] == nil then return end
    for _, item in pairs(DATA.use_weight_from_trade_good[trade_good]) do func(item) end
end
---@param trade_good trade_good_id valid trade_good_id
---@param func fun(item: use_weight_id):boolean 
---@return table<use_weight_id, use_weight_id> 
function DATA.filter_array_use_weight_from_trade_good(trade_good, func)
    ---@type table<use_weight_id, use_weight_id> 
    local t = {}
    for _, item in pairs(DATA.use_weight_from_trade_good[trade_good]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param trade_good trade_good_id valid trade_good_id
---@param func fun(item: use_weight_id):boolean 
---@return table<use_weight_id, use_weight_id> 
function DATA.filter_use_weight_from_trade_good(trade_good, func)
    ---@type table<use_weight_id, use_weight_id> 
    local t = {}
    for _, item in pairs(DATA.use_weight_from_trade_good[trade_good]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param use_weight_id use_weight_id valid use_weight id
---@param old_value trade_good_id valid trade_good_id
function __REMOVE_KEY_USE_WEIGHT_TRADE_GOOD(use_weight_id, old_value)
    local found_key = nil
    if DATA.use_weight_from_trade_good[old_value] == nil then
        DATA.use_weight_from_trade_good[old_value] = {}
        return
    end
    for key, value in pairs(DATA.use_weight_from_trade_good[old_value]) do
        if value == use_weight_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.use_weight_from_trade_good[old_value], found_key)
    end
end
---@param use_weight_id use_weight_id valid use_weight id
---@param value trade_good_id valid trade_good_id
function DATA.use_weight_set_trade_good(use_weight_id, value)
    local old_value = DATA.use_weight[use_weight_id].trade_good
    DATA.use_weight[use_weight_id].trade_good = value
    __REMOVE_KEY_USE_WEIGHT_TRADE_GOOD(use_weight_id, old_value)
    if DATA.use_weight_from_trade_good[value] == nil then DATA.use_weight_from_trade_good[value] = {} end
    table.insert(DATA.use_weight_from_trade_good[value], use_weight_id)
end
---@param use_weight_id use_weight_id valid use_weight id
---@return use_case_id use_case index of use case
function DATA.use_weight_get_use_case(use_weight_id)
    return DATA.use_weight[use_weight_id].use_case
end
---@param use_case use_case_id valid use_case_id
---@return use_weight_id[] An array of use_weight 
function DATA.get_use_weight_from_use_case(use_case)
    return DATA.use_weight_from_use_case[use_case]
end
---@param use_case use_case_id valid use_case_id
---@param func fun(item: use_weight_id) valid use_case_id
function DATA.for_each_use_weight_from_use_case(use_case, func)
    if DATA.use_weight_from_use_case[use_case] == nil then return end
    for _, item in pairs(DATA.use_weight_from_use_case[use_case]) do func(item) end
end
---@param use_case use_case_id valid use_case_id
---@param func fun(item: use_weight_id):boolean 
---@return table<use_weight_id, use_weight_id> 
function DATA.filter_array_use_weight_from_use_case(use_case, func)
    ---@type table<use_weight_id, use_weight_id> 
    local t = {}
    for _, item in pairs(DATA.use_weight_from_use_case[use_case]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param use_case use_case_id valid use_case_id
---@param func fun(item: use_weight_id):boolean 
---@return table<use_weight_id, use_weight_id> 
function DATA.filter_use_weight_from_use_case(use_case, func)
    ---@type table<use_weight_id, use_weight_id> 
    local t = {}
    for _, item in pairs(DATA.use_weight_from_use_case[use_case]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param use_weight_id use_weight_id valid use_weight id
---@param old_value use_case_id valid use_case_id
function __REMOVE_KEY_USE_WEIGHT_USE_CASE(use_weight_id, old_value)
    local found_key = nil
    if DATA.use_weight_from_use_case[old_value] == nil then
        DATA.use_weight_from_use_case[old_value] = {}
        return
    end
    for key, value in pairs(DATA.use_weight_from_use_case[old_value]) do
        if value == use_weight_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.use_weight_from_use_case[old_value], found_key)
    end
end
---@param use_weight_id use_weight_id valid use_weight id
---@param value use_case_id valid use_case_id
function DATA.use_weight_set_use_case(use_weight_id, value)
    local old_value = DATA.use_weight[use_weight_id].use_case
    DATA.use_weight[use_weight_id].use_case = value
    __REMOVE_KEY_USE_WEIGHT_USE_CASE(use_weight_id, old_value)
    if DATA.use_weight_from_use_case[value] == nil then DATA.use_weight_from_use_case[value] = {} end
    table.insert(DATA.use_weight_from_use_case[value], use_weight_id)
end


local fat_use_weight_id_metatable = {
    __index = function (t,k)
        if (k == "weight") then return DATA.use_weight_get_weight(t.id) end
        if (k == "trade_good") then return DATA.use_weight_get_trade_good(t.id) end
        if (k == "use_case") then return DATA.use_weight_get_use_case(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "weight") then
            DATA.use_weight_set_weight(t.id, v)
            return
        end
        if (k == "trade_good") then
            DATA.use_weight_set_trade_good(t.id, v)
            return
        end
        if (k == "use_case") then
            DATA.use_weight_set_use_case(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id use_weight_id
---@return fat_use_weight_id fat_id
function DATA.fatten_use_weight(id)
    local result = {id = id}
    setmetatable(result, fat_use_weight_id_metatable)    return result
end
----------biome----------


---biome: LSP types---

---Unique identificator for biome entity
---@alias biome_id number

---@class (exact) fat_biome_id
---@field id biome_id Unique biome id
---@field name string 
---@field r number 
---@field g number 
---@field b number 
---@field aquatic boolean 
---@field marsh boolean 
---@field icy boolean 
---@field minimum_slope number m
---@field maximum_slope number m
---@field minimum_elevation number m
---@field maximum_elevation number m
---@field minimum_temperature number C
---@field maximum_temperature number C
---@field minimum_summer_temperature number C
---@field maximum_summer_temperature number C
---@field minimum_winter_temperature number C
---@field maximum_winter_temperature number C
---@field minimum_rain number mm
---@field maximum_rain number mm
---@field minimum_available_water number abstract, adjusted for permeability
---@field maximum_available_water number abstract, adjusted for permeability
---@field minimum_trees number %
---@field maximum_trees number %
---@field minimum_grass number %
---@field maximum_grass number %
---@field minimum_shrubs number %
---@field maximum_shrubs number %
---@field minimum_conifer_fraction number %
---@field maximum_conifer_fraction number %
---@field minimum_dead_land number %
---@field maximum_dead_land number %
---@field minimum_soil_depth number m
---@field maximum_soil_depth number m
---@field minimum_soil_richness number %
---@field maximum_soil_richness number %
---@field minimum_sand number %
---@field maximum_sand number %
---@field minimum_clay number %
---@field maximum_clay number %
---@field minimum_silt number %
---@field maximum_silt number %

---@class struct_biome
---@field r number 
---@field g number 
---@field b number 
---@field aquatic boolean 
---@field marsh boolean 
---@field icy boolean 
---@field minimum_slope number m
---@field maximum_slope number m
---@field minimum_elevation number m
---@field maximum_elevation number m
---@field minimum_temperature number C
---@field maximum_temperature number C
---@field minimum_summer_temperature number C
---@field maximum_summer_temperature number C
---@field minimum_winter_temperature number C
---@field maximum_winter_temperature number C
---@field minimum_rain number mm
---@field maximum_rain number mm
---@field minimum_available_water number abstract, adjusted for permeability
---@field maximum_available_water number abstract, adjusted for permeability
---@field minimum_trees number %
---@field maximum_trees number %
---@field minimum_grass number %
---@field maximum_grass number %
---@field minimum_shrubs number %
---@field maximum_shrubs number %
---@field minimum_conifer_fraction number %
---@field maximum_conifer_fraction number %
---@field minimum_dead_land number %
---@field maximum_dead_land number %
---@field minimum_soil_depth number m
---@field maximum_soil_depth number m
---@field minimum_soil_richness number %
---@field maximum_soil_richness number %
---@field minimum_sand number %
---@field maximum_sand number %
---@field minimum_clay number %
---@field maximum_clay number %
---@field minimum_silt number %
---@field maximum_silt number %

---@class (exact) biome_id_data_blob_definition
---@field name string 
---@field r number 
---@field g number 
---@field b number 
---@field aquatic boolean? 
---@field marsh boolean? 
---@field icy boolean? 
---@field minimum_slope number? m
---@field maximum_slope number? m
---@field minimum_elevation number? m
---@field maximum_elevation number? m
---@field minimum_temperature number? C
---@field maximum_temperature number? C
---@field minimum_summer_temperature number? C
---@field maximum_summer_temperature number? C
---@field minimum_winter_temperature number? C
---@field maximum_winter_temperature number? C
---@field minimum_rain number? mm
---@field maximum_rain number? mm
---@field minimum_available_water number? abstract, adjusted for permeability
---@field maximum_available_water number? abstract, adjusted for permeability
---@field minimum_trees number? %
---@field maximum_trees number? %
---@field minimum_grass number? %
---@field maximum_grass number? %
---@field minimum_shrubs number? %
---@field maximum_shrubs number? %
---@field minimum_conifer_fraction number? %
---@field maximum_conifer_fraction number? %
---@field minimum_dead_land number? %
---@field maximum_dead_land number? %
---@field minimum_soil_depth number? m
---@field maximum_soil_depth number? m
---@field minimum_soil_richness number? %
---@field maximum_soil_richness number? %
---@field minimum_sand number? %
---@field maximum_sand number? %
---@field minimum_clay number? %
---@field maximum_clay number? %
---@field minimum_silt number? %
---@field maximum_silt number? %
---Sets values of biome for given id
---@param id biome_id
---@param data biome_id_data_blob_definition
function DATA.setup_biome(id, data)
    DATA.biome_set_aquatic(id, false)
    DATA.biome_set_marsh(id, false)
    DATA.biome_set_icy(id, false)
    DATA.biome_set_minimum_slope(id, -99999999)
    DATA.biome_set_maximum_slope(id, 99999999)
    DATA.biome_set_minimum_elevation(id, -99999999)
    DATA.biome_set_maximum_elevation(id, 99999999)
    DATA.biome_set_minimum_temperature(id, -99999999)
    DATA.biome_set_maximum_temperature(id, 99999999)
    DATA.biome_set_minimum_summer_temperature(id, -99999999)
    DATA.biome_set_maximum_summer_temperature(id, 99999999)
    DATA.biome_set_minimum_winter_temperature(id, -99999999)
    DATA.biome_set_maximum_winter_temperature(id, 99999999)
    DATA.biome_set_minimum_rain(id, -99999999)
    DATA.biome_set_maximum_rain(id, 99999999)
    DATA.biome_set_minimum_available_water(id, -99999999)
    DATA.biome_set_maximum_available_water(id, 99999999)
    DATA.biome_set_minimum_trees(id, -99999999)
    DATA.biome_set_maximum_trees(id, 99999999)
    DATA.biome_set_minimum_grass(id, -99999999)
    DATA.biome_set_maximum_grass(id, 99999999)
    DATA.biome_set_minimum_shrubs(id, -99999999)
    DATA.biome_set_maximum_shrubs(id, 99999999)
    DATA.biome_set_minimum_conifer_fraction(id, -99999999)
    DATA.biome_set_maximum_conifer_fraction(id, 99999999)
    DATA.biome_set_minimum_dead_land(id, -99999999)
    DATA.biome_set_maximum_dead_land(id, 99999999)
    DATA.biome_set_minimum_soil_depth(id, -99999999)
    DATA.biome_set_maximum_soil_depth(id, 99999999)
    DATA.biome_set_minimum_soil_richness(id, -99999999)
    DATA.biome_set_maximum_soil_richness(id, 99999999)
    DATA.biome_set_minimum_sand(id, -99999999)
    DATA.biome_set_maximum_sand(id, 99999999)
    DATA.biome_set_minimum_clay(id, -99999999)
    DATA.biome_set_maximum_clay(id, 99999999)
    DATA.biome_set_minimum_silt(id, -99999999)
    DATA.biome_set_maximum_silt(id, 99999999)
    DATA.biome_set_name(id, data.name)
    DATA.biome_set_r(id, data.r)
    DATA.biome_set_g(id, data.g)
    DATA.biome_set_b(id, data.b)
    if data.aquatic ~= nil then
        DATA.biome_set_aquatic(id, data.aquatic)
    end
    if data.marsh ~= nil then
        DATA.biome_set_marsh(id, data.marsh)
    end
    if data.icy ~= nil then
        DATA.biome_set_icy(id, data.icy)
    end
    if data.minimum_slope ~= nil then
        DATA.biome_set_minimum_slope(id, data.minimum_slope)
    end
    if data.maximum_slope ~= nil then
        DATA.biome_set_maximum_slope(id, data.maximum_slope)
    end
    if data.minimum_elevation ~= nil then
        DATA.biome_set_minimum_elevation(id, data.minimum_elevation)
    end
    if data.maximum_elevation ~= nil then
        DATA.biome_set_maximum_elevation(id, data.maximum_elevation)
    end
    if data.minimum_temperature ~= nil then
        DATA.biome_set_minimum_temperature(id, data.minimum_temperature)
    end
    if data.maximum_temperature ~= nil then
        DATA.biome_set_maximum_temperature(id, data.maximum_temperature)
    end
    if data.minimum_summer_temperature ~= nil then
        DATA.biome_set_minimum_summer_temperature(id, data.minimum_summer_temperature)
    end
    if data.maximum_summer_temperature ~= nil then
        DATA.biome_set_maximum_summer_temperature(id, data.maximum_summer_temperature)
    end
    if data.minimum_winter_temperature ~= nil then
        DATA.biome_set_minimum_winter_temperature(id, data.minimum_winter_temperature)
    end
    if data.maximum_winter_temperature ~= nil then
        DATA.biome_set_maximum_winter_temperature(id, data.maximum_winter_temperature)
    end
    if data.minimum_rain ~= nil then
        DATA.biome_set_minimum_rain(id, data.minimum_rain)
    end
    if data.maximum_rain ~= nil then
        DATA.biome_set_maximum_rain(id, data.maximum_rain)
    end
    if data.minimum_available_water ~= nil then
        DATA.biome_set_minimum_available_water(id, data.minimum_available_water)
    end
    if data.maximum_available_water ~= nil then
        DATA.biome_set_maximum_available_water(id, data.maximum_available_water)
    end
    if data.minimum_trees ~= nil then
        DATA.biome_set_minimum_trees(id, data.minimum_trees)
    end
    if data.maximum_trees ~= nil then
        DATA.biome_set_maximum_trees(id, data.maximum_trees)
    end
    if data.minimum_grass ~= nil then
        DATA.biome_set_minimum_grass(id, data.minimum_grass)
    end
    if data.maximum_grass ~= nil then
        DATA.biome_set_maximum_grass(id, data.maximum_grass)
    end
    if data.minimum_shrubs ~= nil then
        DATA.biome_set_minimum_shrubs(id, data.minimum_shrubs)
    end
    if data.maximum_shrubs ~= nil then
        DATA.biome_set_maximum_shrubs(id, data.maximum_shrubs)
    end
    if data.minimum_conifer_fraction ~= nil then
        DATA.biome_set_minimum_conifer_fraction(id, data.minimum_conifer_fraction)
    end
    if data.maximum_conifer_fraction ~= nil then
        DATA.biome_set_maximum_conifer_fraction(id, data.maximum_conifer_fraction)
    end
    if data.minimum_dead_land ~= nil then
        DATA.biome_set_minimum_dead_land(id, data.minimum_dead_land)
    end
    if data.maximum_dead_land ~= nil then
        DATA.biome_set_maximum_dead_land(id, data.maximum_dead_land)
    end
    if data.minimum_soil_depth ~= nil then
        DATA.biome_set_minimum_soil_depth(id, data.minimum_soil_depth)
    end
    if data.maximum_soil_depth ~= nil then
        DATA.biome_set_maximum_soil_depth(id, data.maximum_soil_depth)
    end
    if data.minimum_soil_richness ~= nil then
        DATA.biome_set_minimum_soil_richness(id, data.minimum_soil_richness)
    end
    if data.maximum_soil_richness ~= nil then
        DATA.biome_set_maximum_soil_richness(id, data.maximum_soil_richness)
    end
    if data.minimum_sand ~= nil then
        DATA.biome_set_minimum_sand(id, data.minimum_sand)
    end
    if data.maximum_sand ~= nil then
        DATA.biome_set_maximum_sand(id, data.maximum_sand)
    end
    if data.minimum_clay ~= nil then
        DATA.biome_set_minimum_clay(id, data.minimum_clay)
    end
    if data.maximum_clay ~= nil then
        DATA.biome_set_maximum_clay(id, data.maximum_clay)
    end
    if data.minimum_silt ~= nil then
        DATA.biome_set_minimum_silt(id, data.minimum_silt)
    end
    if data.maximum_silt ~= nil then
        DATA.biome_set_maximum_silt(id, data.maximum_silt)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        bool aquatic;
        bool marsh;
        bool icy;
        float minimum_slope;
        float maximum_slope;
        float minimum_elevation;
        float maximum_elevation;
        float minimum_temperature;
        float maximum_temperature;
        float minimum_summer_temperature;
        float maximum_summer_temperature;
        float minimum_winter_temperature;
        float maximum_winter_temperature;
        float minimum_rain;
        float maximum_rain;
        float minimum_available_water;
        float maximum_available_water;
        float minimum_trees;
        float maximum_trees;
        float minimum_grass;
        float maximum_grass;
        float minimum_shrubs;
        float maximum_shrubs;
        float minimum_conifer_fraction;
        float maximum_conifer_fraction;
        float minimum_dead_land;
        float maximum_dead_land;
        float minimum_soil_depth;
        float maximum_soil_depth;
        float minimum_soil_richness;
        float maximum_soil_richness;
        float minimum_sand;
        float maximum_sand;
        float minimum_clay;
        float maximum_clay;
        float minimum_silt;
        float maximum_silt;
    } biome;
int32_t dcon_create_biome();
void dcon_biome_resize(uint32_t sz);
]]

---biome: FFI arrays---
---@type (string)[]
DATA.biome_name= {}
---@type nil
DATA.biome_calloc = ffi.C.calloc(1, ffi.sizeof("biome") * 101)
---@type table<biome_id, struct_biome>
DATA.biome = ffi.cast("biome*", DATA.biome_calloc)

---biome: LUA bindings---

DATA.biome_size = 100
---@type table<biome_id, boolean>
local biome_indices_pool = ffi.new("bool[?]", 100)
for i = 1, 99 do
    biome_indices_pool[i] = true 
end
---@type table<biome_id, biome_id>
DATA.biome_indices_set = {}
function DATA.create_biome()
    ---@type number
    local i = DCON.dcon_create_biome() + 1
            DATA.biome_indices_set[i] = i
    return i
end
---@param func fun(item: biome_id) 
function DATA.for_each_biome(func)
    for _, item in pairs(DATA.biome_indices_set) do
        func(item)
    end
end
---@param func fun(item: biome_id):boolean 
---@return table<biome_id, biome_id> 
function DATA.filter_biome(func)
    ---@type table<biome_id, biome_id> 
    local t = {}
    for _, item in pairs(DATA.biome_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param biome_id biome_id valid biome id
---@return string name 
function DATA.biome_get_name(biome_id)
    return DATA.biome_name[biome_id]
end
---@param biome_id biome_id valid biome id
---@param value string valid string
function DATA.biome_set_name(biome_id, value)
    DATA.biome_name[biome_id] = value
end
---@param biome_id biome_id valid biome id
---@return number r 
function DATA.biome_get_r(biome_id)
    return DATA.biome[biome_id].r
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_r(biome_id, value)
    DATA.biome[biome_id].r = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_r(biome_id, value)
    DATA.biome[biome_id].r = DATA.biome[biome_id].r + value
end
---@param biome_id biome_id valid biome id
---@return number g 
function DATA.biome_get_g(biome_id)
    return DATA.biome[biome_id].g
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_g(biome_id, value)
    DATA.biome[biome_id].g = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_g(biome_id, value)
    DATA.biome[biome_id].g = DATA.biome[biome_id].g + value
end
---@param biome_id biome_id valid biome id
---@return number b 
function DATA.biome_get_b(biome_id)
    return DATA.biome[biome_id].b
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_b(biome_id, value)
    DATA.biome[biome_id].b = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_b(biome_id, value)
    DATA.biome[biome_id].b = DATA.biome[biome_id].b + value
end
---@param biome_id biome_id valid biome id
---@return boolean aquatic 
function DATA.biome_get_aquatic(biome_id)
    return DATA.biome[biome_id].aquatic
end
---@param biome_id biome_id valid biome id
---@param value boolean valid boolean
function DATA.biome_set_aquatic(biome_id, value)
    DATA.biome[biome_id].aquatic = value
end
---@param biome_id biome_id valid biome id
---@return boolean marsh 
function DATA.biome_get_marsh(biome_id)
    return DATA.biome[biome_id].marsh
end
---@param biome_id biome_id valid biome id
---@param value boolean valid boolean
function DATA.biome_set_marsh(biome_id, value)
    DATA.biome[biome_id].marsh = value
end
---@param biome_id biome_id valid biome id
---@return boolean icy 
function DATA.biome_get_icy(biome_id)
    return DATA.biome[biome_id].icy
end
---@param biome_id biome_id valid biome id
---@param value boolean valid boolean
function DATA.biome_set_icy(biome_id, value)
    DATA.biome[biome_id].icy = value
end
---@param biome_id biome_id valid biome id
---@return number minimum_slope m
function DATA.biome_get_minimum_slope(biome_id)
    return DATA.biome[biome_id].minimum_slope
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_slope(biome_id, value)
    DATA.biome[biome_id].minimum_slope = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_slope(biome_id, value)
    DATA.biome[biome_id].minimum_slope = DATA.biome[biome_id].minimum_slope + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_slope m
function DATA.biome_get_maximum_slope(biome_id)
    return DATA.biome[biome_id].maximum_slope
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_slope(biome_id, value)
    DATA.biome[biome_id].maximum_slope = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_slope(biome_id, value)
    DATA.biome[biome_id].maximum_slope = DATA.biome[biome_id].maximum_slope + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_elevation m
function DATA.biome_get_minimum_elevation(biome_id)
    return DATA.biome[biome_id].minimum_elevation
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_elevation(biome_id, value)
    DATA.biome[biome_id].minimum_elevation = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_elevation(biome_id, value)
    DATA.biome[biome_id].minimum_elevation = DATA.biome[biome_id].minimum_elevation + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_elevation m
function DATA.biome_get_maximum_elevation(biome_id)
    return DATA.biome[biome_id].maximum_elevation
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_elevation(biome_id, value)
    DATA.biome[biome_id].maximum_elevation = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_elevation(biome_id, value)
    DATA.biome[biome_id].maximum_elevation = DATA.biome[biome_id].maximum_elevation + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_temperature C
function DATA.biome_get_minimum_temperature(biome_id)
    return DATA.biome[biome_id].minimum_temperature
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_temperature(biome_id, value)
    DATA.biome[biome_id].minimum_temperature = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_temperature(biome_id, value)
    DATA.biome[biome_id].minimum_temperature = DATA.biome[biome_id].minimum_temperature + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_temperature C
function DATA.biome_get_maximum_temperature(biome_id)
    return DATA.biome[biome_id].maximum_temperature
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_temperature(biome_id, value)
    DATA.biome[biome_id].maximum_temperature = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_temperature(biome_id, value)
    DATA.biome[biome_id].maximum_temperature = DATA.biome[biome_id].maximum_temperature + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_summer_temperature C
function DATA.biome_get_minimum_summer_temperature(biome_id)
    return DATA.biome[biome_id].minimum_summer_temperature
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_summer_temperature(biome_id, value)
    DATA.biome[biome_id].minimum_summer_temperature = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_summer_temperature(biome_id, value)
    DATA.biome[biome_id].minimum_summer_temperature = DATA.biome[biome_id].minimum_summer_temperature + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_summer_temperature C
function DATA.biome_get_maximum_summer_temperature(biome_id)
    return DATA.biome[biome_id].maximum_summer_temperature
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_summer_temperature(biome_id, value)
    DATA.biome[biome_id].maximum_summer_temperature = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_summer_temperature(biome_id, value)
    DATA.biome[biome_id].maximum_summer_temperature = DATA.biome[biome_id].maximum_summer_temperature + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_winter_temperature C
function DATA.biome_get_minimum_winter_temperature(biome_id)
    return DATA.biome[biome_id].minimum_winter_temperature
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_winter_temperature(biome_id, value)
    DATA.biome[biome_id].minimum_winter_temperature = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_winter_temperature(biome_id, value)
    DATA.biome[biome_id].minimum_winter_temperature = DATA.biome[biome_id].minimum_winter_temperature + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_winter_temperature C
function DATA.biome_get_maximum_winter_temperature(biome_id)
    return DATA.biome[biome_id].maximum_winter_temperature
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_winter_temperature(biome_id, value)
    DATA.biome[biome_id].maximum_winter_temperature = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_winter_temperature(biome_id, value)
    DATA.biome[biome_id].maximum_winter_temperature = DATA.biome[biome_id].maximum_winter_temperature + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_rain mm
function DATA.biome_get_minimum_rain(biome_id)
    return DATA.biome[biome_id].minimum_rain
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_rain(biome_id, value)
    DATA.biome[biome_id].minimum_rain = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_rain(biome_id, value)
    DATA.biome[biome_id].minimum_rain = DATA.biome[biome_id].minimum_rain + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_rain mm
function DATA.biome_get_maximum_rain(biome_id)
    return DATA.biome[biome_id].maximum_rain
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_rain(biome_id, value)
    DATA.biome[biome_id].maximum_rain = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_rain(biome_id, value)
    DATA.biome[biome_id].maximum_rain = DATA.biome[biome_id].maximum_rain + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_available_water abstract, adjusted for permeability
function DATA.biome_get_minimum_available_water(biome_id)
    return DATA.biome[biome_id].minimum_available_water
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_available_water(biome_id, value)
    DATA.biome[biome_id].minimum_available_water = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_available_water(biome_id, value)
    DATA.biome[biome_id].minimum_available_water = DATA.biome[biome_id].minimum_available_water + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_available_water abstract, adjusted for permeability
function DATA.biome_get_maximum_available_water(biome_id)
    return DATA.biome[biome_id].maximum_available_water
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_available_water(biome_id, value)
    DATA.biome[biome_id].maximum_available_water = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_available_water(biome_id, value)
    DATA.biome[biome_id].maximum_available_water = DATA.biome[biome_id].maximum_available_water + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_trees %
function DATA.biome_get_minimum_trees(biome_id)
    return DATA.biome[biome_id].minimum_trees
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_trees(biome_id, value)
    DATA.biome[biome_id].minimum_trees = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_trees(biome_id, value)
    DATA.biome[biome_id].minimum_trees = DATA.biome[biome_id].minimum_trees + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_trees %
function DATA.biome_get_maximum_trees(biome_id)
    return DATA.biome[biome_id].maximum_trees
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_trees(biome_id, value)
    DATA.biome[biome_id].maximum_trees = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_trees(biome_id, value)
    DATA.biome[biome_id].maximum_trees = DATA.biome[biome_id].maximum_trees + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_grass %
function DATA.biome_get_minimum_grass(biome_id)
    return DATA.biome[biome_id].minimum_grass
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_grass(biome_id, value)
    DATA.biome[biome_id].minimum_grass = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_grass(biome_id, value)
    DATA.biome[biome_id].minimum_grass = DATA.biome[biome_id].minimum_grass + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_grass %
function DATA.biome_get_maximum_grass(biome_id)
    return DATA.biome[biome_id].maximum_grass
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_grass(biome_id, value)
    DATA.biome[biome_id].maximum_grass = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_grass(biome_id, value)
    DATA.biome[biome_id].maximum_grass = DATA.biome[biome_id].maximum_grass + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_shrubs %
function DATA.biome_get_minimum_shrubs(biome_id)
    return DATA.biome[biome_id].minimum_shrubs
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_shrubs(biome_id, value)
    DATA.biome[biome_id].minimum_shrubs = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_shrubs(biome_id, value)
    DATA.biome[biome_id].minimum_shrubs = DATA.biome[biome_id].minimum_shrubs + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_shrubs %
function DATA.biome_get_maximum_shrubs(biome_id)
    return DATA.biome[biome_id].maximum_shrubs
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_shrubs(biome_id, value)
    DATA.biome[biome_id].maximum_shrubs = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_shrubs(biome_id, value)
    DATA.biome[biome_id].maximum_shrubs = DATA.biome[biome_id].maximum_shrubs + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_conifer_fraction %
function DATA.biome_get_minimum_conifer_fraction(biome_id)
    return DATA.biome[biome_id].minimum_conifer_fraction
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_conifer_fraction(biome_id, value)
    DATA.biome[biome_id].minimum_conifer_fraction = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_conifer_fraction(biome_id, value)
    DATA.biome[biome_id].minimum_conifer_fraction = DATA.biome[biome_id].minimum_conifer_fraction + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_conifer_fraction %
function DATA.biome_get_maximum_conifer_fraction(biome_id)
    return DATA.biome[biome_id].maximum_conifer_fraction
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_conifer_fraction(biome_id, value)
    DATA.biome[biome_id].maximum_conifer_fraction = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_conifer_fraction(biome_id, value)
    DATA.biome[biome_id].maximum_conifer_fraction = DATA.biome[biome_id].maximum_conifer_fraction + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_dead_land %
function DATA.biome_get_minimum_dead_land(biome_id)
    return DATA.biome[biome_id].minimum_dead_land
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_dead_land(biome_id, value)
    DATA.biome[biome_id].minimum_dead_land = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_dead_land(biome_id, value)
    DATA.biome[biome_id].minimum_dead_land = DATA.biome[biome_id].minimum_dead_land + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_dead_land %
function DATA.biome_get_maximum_dead_land(biome_id)
    return DATA.biome[biome_id].maximum_dead_land
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_dead_land(biome_id, value)
    DATA.biome[biome_id].maximum_dead_land = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_dead_land(biome_id, value)
    DATA.biome[biome_id].maximum_dead_land = DATA.biome[biome_id].maximum_dead_land + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_soil_depth m
function DATA.biome_get_minimum_soil_depth(biome_id)
    return DATA.biome[biome_id].minimum_soil_depth
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_soil_depth(biome_id, value)
    DATA.biome[biome_id].minimum_soil_depth = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_soil_depth(biome_id, value)
    DATA.biome[biome_id].minimum_soil_depth = DATA.biome[biome_id].minimum_soil_depth + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_soil_depth m
function DATA.biome_get_maximum_soil_depth(biome_id)
    return DATA.biome[biome_id].maximum_soil_depth
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_soil_depth(biome_id, value)
    DATA.biome[biome_id].maximum_soil_depth = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_soil_depth(biome_id, value)
    DATA.biome[biome_id].maximum_soil_depth = DATA.biome[biome_id].maximum_soil_depth + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_soil_richness %
function DATA.biome_get_minimum_soil_richness(biome_id)
    return DATA.biome[biome_id].minimum_soil_richness
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_soil_richness(biome_id, value)
    DATA.biome[biome_id].minimum_soil_richness = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_soil_richness(biome_id, value)
    DATA.biome[biome_id].minimum_soil_richness = DATA.biome[biome_id].minimum_soil_richness + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_soil_richness %
function DATA.biome_get_maximum_soil_richness(biome_id)
    return DATA.biome[biome_id].maximum_soil_richness
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_soil_richness(biome_id, value)
    DATA.biome[biome_id].maximum_soil_richness = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_soil_richness(biome_id, value)
    DATA.biome[biome_id].maximum_soil_richness = DATA.biome[biome_id].maximum_soil_richness + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_sand %
function DATA.biome_get_minimum_sand(biome_id)
    return DATA.biome[biome_id].minimum_sand
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_sand(biome_id, value)
    DATA.biome[biome_id].minimum_sand = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_sand(biome_id, value)
    DATA.biome[biome_id].minimum_sand = DATA.biome[biome_id].minimum_sand + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_sand %
function DATA.biome_get_maximum_sand(biome_id)
    return DATA.biome[biome_id].maximum_sand
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_sand(biome_id, value)
    DATA.biome[biome_id].maximum_sand = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_sand(biome_id, value)
    DATA.biome[biome_id].maximum_sand = DATA.biome[biome_id].maximum_sand + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_clay %
function DATA.biome_get_minimum_clay(biome_id)
    return DATA.biome[biome_id].minimum_clay
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_clay(biome_id, value)
    DATA.biome[biome_id].minimum_clay = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_clay(biome_id, value)
    DATA.biome[biome_id].minimum_clay = DATA.biome[biome_id].minimum_clay + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_clay %
function DATA.biome_get_maximum_clay(biome_id)
    return DATA.biome[biome_id].maximum_clay
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_clay(biome_id, value)
    DATA.biome[biome_id].maximum_clay = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_clay(biome_id, value)
    DATA.biome[biome_id].maximum_clay = DATA.biome[biome_id].maximum_clay + value
end
---@param biome_id biome_id valid biome id
---@return number minimum_silt %
function DATA.biome_get_minimum_silt(biome_id)
    return DATA.biome[biome_id].minimum_silt
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_minimum_silt(biome_id, value)
    DATA.biome[biome_id].minimum_silt = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_minimum_silt(biome_id, value)
    DATA.biome[biome_id].minimum_silt = DATA.biome[biome_id].minimum_silt + value
end
---@param biome_id biome_id valid biome id
---@return number maximum_silt %
function DATA.biome_get_maximum_silt(biome_id)
    return DATA.biome[biome_id].maximum_silt
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_set_maximum_silt(biome_id, value)
    DATA.biome[biome_id].maximum_silt = value
end
---@param biome_id biome_id valid biome id
---@param value number valid number
function DATA.biome_inc_maximum_silt(biome_id, value)
    DATA.biome[biome_id].maximum_silt = DATA.biome[biome_id].maximum_silt + value
end


local fat_biome_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.biome_get_name(t.id) end
        if (k == "r") then return DATA.biome_get_r(t.id) end
        if (k == "g") then return DATA.biome_get_g(t.id) end
        if (k == "b") then return DATA.biome_get_b(t.id) end
        if (k == "aquatic") then return DATA.biome_get_aquatic(t.id) end
        if (k == "marsh") then return DATA.biome_get_marsh(t.id) end
        if (k == "icy") then return DATA.biome_get_icy(t.id) end
        if (k == "minimum_slope") then return DATA.biome_get_minimum_slope(t.id) end
        if (k == "maximum_slope") then return DATA.biome_get_maximum_slope(t.id) end
        if (k == "minimum_elevation") then return DATA.biome_get_minimum_elevation(t.id) end
        if (k == "maximum_elevation") then return DATA.biome_get_maximum_elevation(t.id) end
        if (k == "minimum_temperature") then return DATA.biome_get_minimum_temperature(t.id) end
        if (k == "maximum_temperature") then return DATA.biome_get_maximum_temperature(t.id) end
        if (k == "minimum_summer_temperature") then return DATA.biome_get_minimum_summer_temperature(t.id) end
        if (k == "maximum_summer_temperature") then return DATA.biome_get_maximum_summer_temperature(t.id) end
        if (k == "minimum_winter_temperature") then return DATA.biome_get_minimum_winter_temperature(t.id) end
        if (k == "maximum_winter_temperature") then return DATA.biome_get_maximum_winter_temperature(t.id) end
        if (k == "minimum_rain") then return DATA.biome_get_minimum_rain(t.id) end
        if (k == "maximum_rain") then return DATA.biome_get_maximum_rain(t.id) end
        if (k == "minimum_available_water") then return DATA.biome_get_minimum_available_water(t.id) end
        if (k == "maximum_available_water") then return DATA.biome_get_maximum_available_water(t.id) end
        if (k == "minimum_trees") then return DATA.biome_get_minimum_trees(t.id) end
        if (k == "maximum_trees") then return DATA.biome_get_maximum_trees(t.id) end
        if (k == "minimum_grass") then return DATA.biome_get_minimum_grass(t.id) end
        if (k == "maximum_grass") then return DATA.biome_get_maximum_grass(t.id) end
        if (k == "minimum_shrubs") then return DATA.biome_get_minimum_shrubs(t.id) end
        if (k == "maximum_shrubs") then return DATA.biome_get_maximum_shrubs(t.id) end
        if (k == "minimum_conifer_fraction") then return DATA.biome_get_minimum_conifer_fraction(t.id) end
        if (k == "maximum_conifer_fraction") then return DATA.biome_get_maximum_conifer_fraction(t.id) end
        if (k == "minimum_dead_land") then return DATA.biome_get_minimum_dead_land(t.id) end
        if (k == "maximum_dead_land") then return DATA.biome_get_maximum_dead_land(t.id) end
        if (k == "minimum_soil_depth") then return DATA.biome_get_minimum_soil_depth(t.id) end
        if (k == "maximum_soil_depth") then return DATA.biome_get_maximum_soil_depth(t.id) end
        if (k == "minimum_soil_richness") then return DATA.biome_get_minimum_soil_richness(t.id) end
        if (k == "maximum_soil_richness") then return DATA.biome_get_maximum_soil_richness(t.id) end
        if (k == "minimum_sand") then return DATA.biome_get_minimum_sand(t.id) end
        if (k == "maximum_sand") then return DATA.biome_get_maximum_sand(t.id) end
        if (k == "minimum_clay") then return DATA.biome_get_minimum_clay(t.id) end
        if (k == "maximum_clay") then return DATA.biome_get_maximum_clay(t.id) end
        if (k == "minimum_silt") then return DATA.biome_get_minimum_silt(t.id) end
        if (k == "maximum_silt") then return DATA.biome_get_maximum_silt(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.biome_set_name(t.id, v)
            return
        end
        if (k == "r") then
            DATA.biome_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.biome_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.biome_set_b(t.id, v)
            return
        end
        if (k == "aquatic") then
            DATA.biome_set_aquatic(t.id, v)
            return
        end
        if (k == "marsh") then
            DATA.biome_set_marsh(t.id, v)
            return
        end
        if (k == "icy") then
            DATA.biome_set_icy(t.id, v)
            return
        end
        if (k == "minimum_slope") then
            DATA.biome_set_minimum_slope(t.id, v)
            return
        end
        if (k == "maximum_slope") then
            DATA.biome_set_maximum_slope(t.id, v)
            return
        end
        if (k == "minimum_elevation") then
            DATA.biome_set_minimum_elevation(t.id, v)
            return
        end
        if (k == "maximum_elevation") then
            DATA.biome_set_maximum_elevation(t.id, v)
            return
        end
        if (k == "minimum_temperature") then
            DATA.biome_set_minimum_temperature(t.id, v)
            return
        end
        if (k == "maximum_temperature") then
            DATA.biome_set_maximum_temperature(t.id, v)
            return
        end
        if (k == "minimum_summer_temperature") then
            DATA.biome_set_minimum_summer_temperature(t.id, v)
            return
        end
        if (k == "maximum_summer_temperature") then
            DATA.biome_set_maximum_summer_temperature(t.id, v)
            return
        end
        if (k == "minimum_winter_temperature") then
            DATA.biome_set_minimum_winter_temperature(t.id, v)
            return
        end
        if (k == "maximum_winter_temperature") then
            DATA.biome_set_maximum_winter_temperature(t.id, v)
            return
        end
        if (k == "minimum_rain") then
            DATA.biome_set_minimum_rain(t.id, v)
            return
        end
        if (k == "maximum_rain") then
            DATA.biome_set_maximum_rain(t.id, v)
            return
        end
        if (k == "minimum_available_water") then
            DATA.biome_set_minimum_available_water(t.id, v)
            return
        end
        if (k == "maximum_available_water") then
            DATA.biome_set_maximum_available_water(t.id, v)
            return
        end
        if (k == "minimum_trees") then
            DATA.biome_set_minimum_trees(t.id, v)
            return
        end
        if (k == "maximum_trees") then
            DATA.biome_set_maximum_trees(t.id, v)
            return
        end
        if (k == "minimum_grass") then
            DATA.biome_set_minimum_grass(t.id, v)
            return
        end
        if (k == "maximum_grass") then
            DATA.biome_set_maximum_grass(t.id, v)
            return
        end
        if (k == "minimum_shrubs") then
            DATA.biome_set_minimum_shrubs(t.id, v)
            return
        end
        if (k == "maximum_shrubs") then
            DATA.biome_set_maximum_shrubs(t.id, v)
            return
        end
        if (k == "minimum_conifer_fraction") then
            DATA.biome_set_minimum_conifer_fraction(t.id, v)
            return
        end
        if (k == "maximum_conifer_fraction") then
            DATA.biome_set_maximum_conifer_fraction(t.id, v)
            return
        end
        if (k == "minimum_dead_land") then
            DATA.biome_set_minimum_dead_land(t.id, v)
            return
        end
        if (k == "maximum_dead_land") then
            DATA.biome_set_maximum_dead_land(t.id, v)
            return
        end
        if (k == "minimum_soil_depth") then
            DATA.biome_set_minimum_soil_depth(t.id, v)
            return
        end
        if (k == "maximum_soil_depth") then
            DATA.biome_set_maximum_soil_depth(t.id, v)
            return
        end
        if (k == "minimum_soil_richness") then
            DATA.biome_set_minimum_soil_richness(t.id, v)
            return
        end
        if (k == "maximum_soil_richness") then
            DATA.biome_set_maximum_soil_richness(t.id, v)
            return
        end
        if (k == "minimum_sand") then
            DATA.biome_set_minimum_sand(t.id, v)
            return
        end
        if (k == "maximum_sand") then
            DATA.biome_set_maximum_sand(t.id, v)
            return
        end
        if (k == "minimum_clay") then
            DATA.biome_set_minimum_clay(t.id, v)
            return
        end
        if (k == "maximum_clay") then
            DATA.biome_set_maximum_clay(t.id, v)
            return
        end
        if (k == "minimum_silt") then
            DATA.biome_set_minimum_silt(t.id, v)
            return
        end
        if (k == "maximum_silt") then
            DATA.biome_set_maximum_silt(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id biome_id
---@return fat_biome_id fat_id
function DATA.fatten_biome(id)
    local result = {id = id}
    setmetatable(result, fat_biome_id_metatable)    return result
end
----------bedrock----------


---bedrock: LSP types---

---Unique identificator for bedrock entity
---@alias bedrock_id number

---@class (exact) fat_bedrock_id
---@field id bedrock_id Unique bedrock id
---@field name string 
---@field r number 
---@field g number 
---@field b number 
---@field color_id number 
---@field sand number 
---@field silt number 
---@field clay number 
---@field organics number 
---@field minerals number 
---@field weathering number 
---@field grain_size number 
---@field acidity number 
---@field igneous_extrusive boolean 
---@field igneous_intrusive boolean 
---@field sedimentary boolean 
---@field clastic boolean 
---@field evaporative boolean 
---@field metamorphic_marble boolean 
---@field metamorphic_slate boolean 
---@field oceanic boolean 
---@field sedimentary_ocean_deep boolean 
---@field sedimentary_ocean_shallow boolean 

---@class struct_bedrock
---@field r number 
---@field g number 
---@field b number 
---@field color_id number 
---@field sand number 
---@field silt number 
---@field clay number 
---@field organics number 
---@field minerals number 
---@field weathering number 
---@field grain_size number 
---@field acidity number 
---@field igneous_extrusive boolean 
---@field igneous_intrusive boolean 
---@field sedimentary boolean 
---@field clastic boolean 
---@field evaporative boolean 
---@field metamorphic_marble boolean 
---@field metamorphic_slate boolean 
---@field oceanic boolean 
---@field sedimentary_ocean_deep boolean 
---@field sedimentary_ocean_shallow boolean 

---@class (exact) bedrock_id_data_blob_definition
---@field name string 
---@field r number 
---@field g number 
---@field b number 
---@field sand number 
---@field silt number 
---@field clay number 
---@field organics number 
---@field minerals number 
---@field weathering number 
---@field grain_size number? 
---@field acidity number? 
---@field igneous_extrusive boolean? 
---@field igneous_intrusive boolean? 
---@field sedimentary boolean? 
---@field clastic boolean? 
---@field evaporative boolean? 
---@field metamorphic_marble boolean? 
---@field metamorphic_slate boolean? 
---@field oceanic boolean? 
---@field sedimentary_ocean_deep boolean? 
---@field sedimentary_ocean_shallow boolean? 
---Sets values of bedrock for given id
---@param id bedrock_id
---@param data bedrock_id_data_blob_definition
function DATA.setup_bedrock(id, data)
    DATA.bedrock_set_grain_size(id, 0.0)
    DATA.bedrock_set_acidity(id, 0.0)
    DATA.bedrock_set_igneous_extrusive(id, false)
    DATA.bedrock_set_igneous_intrusive(id, false)
    DATA.bedrock_set_sedimentary(id, false)
    DATA.bedrock_set_clastic(id, false)
    DATA.bedrock_set_evaporative(id, false)
    DATA.bedrock_set_metamorphic_marble(id, false)
    DATA.bedrock_set_metamorphic_slate(id, false)
    DATA.bedrock_set_oceanic(id, false)
    DATA.bedrock_set_sedimentary_ocean_deep(id, false)
    DATA.bedrock_set_sedimentary_ocean_shallow(id, false)
    DATA.bedrock_set_name(id, data.name)
    DATA.bedrock_set_r(id, data.r)
    DATA.bedrock_set_g(id, data.g)
    DATA.bedrock_set_b(id, data.b)
    DATA.bedrock_set_sand(id, data.sand)
    DATA.bedrock_set_silt(id, data.silt)
    DATA.bedrock_set_clay(id, data.clay)
    DATA.bedrock_set_organics(id, data.organics)
    DATA.bedrock_set_minerals(id, data.minerals)
    DATA.bedrock_set_weathering(id, data.weathering)
    if data.grain_size ~= nil then
        DATA.bedrock_set_grain_size(id, data.grain_size)
    end
    if data.acidity ~= nil then
        DATA.bedrock_set_acidity(id, data.acidity)
    end
    if data.igneous_extrusive ~= nil then
        DATA.bedrock_set_igneous_extrusive(id, data.igneous_extrusive)
    end
    if data.igneous_intrusive ~= nil then
        DATA.bedrock_set_igneous_intrusive(id, data.igneous_intrusive)
    end
    if data.sedimentary ~= nil then
        DATA.bedrock_set_sedimentary(id, data.sedimentary)
    end
    if data.clastic ~= nil then
        DATA.bedrock_set_clastic(id, data.clastic)
    end
    if data.evaporative ~= nil then
        DATA.bedrock_set_evaporative(id, data.evaporative)
    end
    if data.metamorphic_marble ~= nil then
        DATA.bedrock_set_metamorphic_marble(id, data.metamorphic_marble)
    end
    if data.metamorphic_slate ~= nil then
        DATA.bedrock_set_metamorphic_slate(id, data.metamorphic_slate)
    end
    if data.oceanic ~= nil then
        DATA.bedrock_set_oceanic(id, data.oceanic)
    end
    if data.sedimentary_ocean_deep ~= nil then
        DATA.bedrock_set_sedimentary_ocean_deep(id, data.sedimentary_ocean_deep)
    end
    if data.sedimentary_ocean_shallow ~= nil then
        DATA.bedrock_set_sedimentary_ocean_shallow(id, data.sedimentary_ocean_shallow)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        uint32_t color_id;
        float sand;
        float silt;
        float clay;
        float organics;
        float minerals;
        float weathering;
        float grain_size;
        float acidity;
        bool igneous_extrusive;
        bool igneous_intrusive;
        bool sedimentary;
        bool clastic;
        bool evaporative;
        bool metamorphic_marble;
        bool metamorphic_slate;
        bool oceanic;
        bool sedimentary_ocean_deep;
        bool sedimentary_ocean_shallow;
    } bedrock;
int32_t dcon_create_bedrock();
void dcon_bedrock_resize(uint32_t sz);
]]

---bedrock: FFI arrays---
---@type (string)[]
DATA.bedrock_name= {}
---@type nil
DATA.bedrock_calloc = ffi.C.calloc(1, ffi.sizeof("bedrock") * 151)
---@type table<bedrock_id, struct_bedrock>
DATA.bedrock = ffi.cast("bedrock*", DATA.bedrock_calloc)

---bedrock: LUA bindings---

DATA.bedrock_size = 150
---@type table<bedrock_id, boolean>
local bedrock_indices_pool = ffi.new("bool[?]", 150)
for i = 1, 149 do
    bedrock_indices_pool[i] = true 
end
---@type table<bedrock_id, bedrock_id>
DATA.bedrock_indices_set = {}
function DATA.create_bedrock()
    ---@type number
    local i = DCON.dcon_create_bedrock() + 1
            DATA.bedrock_indices_set[i] = i
    return i
end
---@param func fun(item: bedrock_id) 
function DATA.for_each_bedrock(func)
    for _, item in pairs(DATA.bedrock_indices_set) do
        func(item)
    end
end
---@param func fun(item: bedrock_id):boolean 
---@return table<bedrock_id, bedrock_id> 
function DATA.filter_bedrock(func)
    ---@type table<bedrock_id, bedrock_id> 
    local t = {}
    for _, item in pairs(DATA.bedrock_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param bedrock_id bedrock_id valid bedrock id
---@return string name 
function DATA.bedrock_get_name(bedrock_id)
    return DATA.bedrock_name[bedrock_id]
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value string valid string
function DATA.bedrock_set_name(bedrock_id, value)
    DATA.bedrock_name[bedrock_id] = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number r 
function DATA.bedrock_get_r(bedrock_id)
    return DATA.bedrock[bedrock_id].r
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_r(bedrock_id, value)
    DATA.bedrock[bedrock_id].r = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_r(bedrock_id, value)
    DATA.bedrock[bedrock_id].r = DATA.bedrock[bedrock_id].r + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number g 
function DATA.bedrock_get_g(bedrock_id)
    return DATA.bedrock[bedrock_id].g
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_g(bedrock_id, value)
    DATA.bedrock[bedrock_id].g = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_g(bedrock_id, value)
    DATA.bedrock[bedrock_id].g = DATA.bedrock[bedrock_id].g + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number b 
function DATA.bedrock_get_b(bedrock_id)
    return DATA.bedrock[bedrock_id].b
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_b(bedrock_id, value)
    DATA.bedrock[bedrock_id].b = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_b(bedrock_id, value)
    DATA.bedrock[bedrock_id].b = DATA.bedrock[bedrock_id].b + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number color_id 
function DATA.bedrock_get_color_id(bedrock_id)
    return DATA.bedrock[bedrock_id].color_id
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_color_id(bedrock_id, value)
    DATA.bedrock[bedrock_id].color_id = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_color_id(bedrock_id, value)
    DATA.bedrock[bedrock_id].color_id = DATA.bedrock[bedrock_id].color_id + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number sand 
function DATA.bedrock_get_sand(bedrock_id)
    return DATA.bedrock[bedrock_id].sand
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_sand(bedrock_id, value)
    DATA.bedrock[bedrock_id].sand = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_sand(bedrock_id, value)
    DATA.bedrock[bedrock_id].sand = DATA.bedrock[bedrock_id].sand + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number silt 
function DATA.bedrock_get_silt(bedrock_id)
    return DATA.bedrock[bedrock_id].silt
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_silt(bedrock_id, value)
    DATA.bedrock[bedrock_id].silt = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_silt(bedrock_id, value)
    DATA.bedrock[bedrock_id].silt = DATA.bedrock[bedrock_id].silt + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number clay 
function DATA.bedrock_get_clay(bedrock_id)
    return DATA.bedrock[bedrock_id].clay
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_clay(bedrock_id, value)
    DATA.bedrock[bedrock_id].clay = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_clay(bedrock_id, value)
    DATA.bedrock[bedrock_id].clay = DATA.bedrock[bedrock_id].clay + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number organics 
function DATA.bedrock_get_organics(bedrock_id)
    return DATA.bedrock[bedrock_id].organics
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_organics(bedrock_id, value)
    DATA.bedrock[bedrock_id].organics = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_organics(bedrock_id, value)
    DATA.bedrock[bedrock_id].organics = DATA.bedrock[bedrock_id].organics + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number minerals 
function DATA.bedrock_get_minerals(bedrock_id)
    return DATA.bedrock[bedrock_id].minerals
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_minerals(bedrock_id, value)
    DATA.bedrock[bedrock_id].minerals = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_minerals(bedrock_id, value)
    DATA.bedrock[bedrock_id].minerals = DATA.bedrock[bedrock_id].minerals + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number weathering 
function DATA.bedrock_get_weathering(bedrock_id)
    return DATA.bedrock[bedrock_id].weathering
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_weathering(bedrock_id, value)
    DATA.bedrock[bedrock_id].weathering = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_weathering(bedrock_id, value)
    DATA.bedrock[bedrock_id].weathering = DATA.bedrock[bedrock_id].weathering + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number grain_size 
function DATA.bedrock_get_grain_size(bedrock_id)
    return DATA.bedrock[bedrock_id].grain_size
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_grain_size(bedrock_id, value)
    DATA.bedrock[bedrock_id].grain_size = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_grain_size(bedrock_id, value)
    DATA.bedrock[bedrock_id].grain_size = DATA.bedrock[bedrock_id].grain_size + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return number acidity 
function DATA.bedrock_get_acidity(bedrock_id)
    return DATA.bedrock[bedrock_id].acidity
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_set_acidity(bedrock_id, value)
    DATA.bedrock[bedrock_id].acidity = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value number valid number
function DATA.bedrock_inc_acidity(bedrock_id, value)
    DATA.bedrock[bedrock_id].acidity = DATA.bedrock[bedrock_id].acidity + value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean igneous_extrusive 
function DATA.bedrock_get_igneous_extrusive(bedrock_id)
    return DATA.bedrock[bedrock_id].igneous_extrusive
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_igneous_extrusive(bedrock_id, value)
    DATA.bedrock[bedrock_id].igneous_extrusive = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean igneous_intrusive 
function DATA.bedrock_get_igneous_intrusive(bedrock_id)
    return DATA.bedrock[bedrock_id].igneous_intrusive
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_igneous_intrusive(bedrock_id, value)
    DATA.bedrock[bedrock_id].igneous_intrusive = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean sedimentary 
function DATA.bedrock_get_sedimentary(bedrock_id)
    return DATA.bedrock[bedrock_id].sedimentary
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_sedimentary(bedrock_id, value)
    DATA.bedrock[bedrock_id].sedimentary = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean clastic 
function DATA.bedrock_get_clastic(bedrock_id)
    return DATA.bedrock[bedrock_id].clastic
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_clastic(bedrock_id, value)
    DATA.bedrock[bedrock_id].clastic = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean evaporative 
function DATA.bedrock_get_evaporative(bedrock_id)
    return DATA.bedrock[bedrock_id].evaporative
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_evaporative(bedrock_id, value)
    DATA.bedrock[bedrock_id].evaporative = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean metamorphic_marble 
function DATA.bedrock_get_metamorphic_marble(bedrock_id)
    return DATA.bedrock[bedrock_id].metamorphic_marble
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_metamorphic_marble(bedrock_id, value)
    DATA.bedrock[bedrock_id].metamorphic_marble = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean metamorphic_slate 
function DATA.bedrock_get_metamorphic_slate(bedrock_id)
    return DATA.bedrock[bedrock_id].metamorphic_slate
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_metamorphic_slate(bedrock_id, value)
    DATA.bedrock[bedrock_id].metamorphic_slate = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean oceanic 
function DATA.bedrock_get_oceanic(bedrock_id)
    return DATA.bedrock[bedrock_id].oceanic
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_oceanic(bedrock_id, value)
    DATA.bedrock[bedrock_id].oceanic = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean sedimentary_ocean_deep 
function DATA.bedrock_get_sedimentary_ocean_deep(bedrock_id)
    return DATA.bedrock[bedrock_id].sedimentary_ocean_deep
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_sedimentary_ocean_deep(bedrock_id, value)
    DATA.bedrock[bedrock_id].sedimentary_ocean_deep = value
end
---@param bedrock_id bedrock_id valid bedrock id
---@return boolean sedimentary_ocean_shallow 
function DATA.bedrock_get_sedimentary_ocean_shallow(bedrock_id)
    return DATA.bedrock[bedrock_id].sedimentary_ocean_shallow
end
---@param bedrock_id bedrock_id valid bedrock id
---@param value boolean valid boolean
function DATA.bedrock_set_sedimentary_ocean_shallow(bedrock_id, value)
    DATA.bedrock[bedrock_id].sedimentary_ocean_shallow = value
end


local fat_bedrock_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.bedrock_get_name(t.id) end
        if (k == "r") then return DATA.bedrock_get_r(t.id) end
        if (k == "g") then return DATA.bedrock_get_g(t.id) end
        if (k == "b") then return DATA.bedrock_get_b(t.id) end
        if (k == "color_id") then return DATA.bedrock_get_color_id(t.id) end
        if (k == "sand") then return DATA.bedrock_get_sand(t.id) end
        if (k == "silt") then return DATA.bedrock_get_silt(t.id) end
        if (k == "clay") then return DATA.bedrock_get_clay(t.id) end
        if (k == "organics") then return DATA.bedrock_get_organics(t.id) end
        if (k == "minerals") then return DATA.bedrock_get_minerals(t.id) end
        if (k == "weathering") then return DATA.bedrock_get_weathering(t.id) end
        if (k == "grain_size") then return DATA.bedrock_get_grain_size(t.id) end
        if (k == "acidity") then return DATA.bedrock_get_acidity(t.id) end
        if (k == "igneous_extrusive") then return DATA.bedrock_get_igneous_extrusive(t.id) end
        if (k == "igneous_intrusive") then return DATA.bedrock_get_igneous_intrusive(t.id) end
        if (k == "sedimentary") then return DATA.bedrock_get_sedimentary(t.id) end
        if (k == "clastic") then return DATA.bedrock_get_clastic(t.id) end
        if (k == "evaporative") then return DATA.bedrock_get_evaporative(t.id) end
        if (k == "metamorphic_marble") then return DATA.bedrock_get_metamorphic_marble(t.id) end
        if (k == "metamorphic_slate") then return DATA.bedrock_get_metamorphic_slate(t.id) end
        if (k == "oceanic") then return DATA.bedrock_get_oceanic(t.id) end
        if (k == "sedimentary_ocean_deep") then return DATA.bedrock_get_sedimentary_ocean_deep(t.id) end
        if (k == "sedimentary_ocean_shallow") then return DATA.bedrock_get_sedimentary_ocean_shallow(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.bedrock_set_name(t.id, v)
            return
        end
        if (k == "r") then
            DATA.bedrock_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.bedrock_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.bedrock_set_b(t.id, v)
            return
        end
        if (k == "color_id") then
            DATA.bedrock_set_color_id(t.id, v)
            return
        end
        if (k == "sand") then
            DATA.bedrock_set_sand(t.id, v)
            return
        end
        if (k == "silt") then
            DATA.bedrock_set_silt(t.id, v)
            return
        end
        if (k == "clay") then
            DATA.bedrock_set_clay(t.id, v)
            return
        end
        if (k == "organics") then
            DATA.bedrock_set_organics(t.id, v)
            return
        end
        if (k == "minerals") then
            DATA.bedrock_set_minerals(t.id, v)
            return
        end
        if (k == "weathering") then
            DATA.bedrock_set_weathering(t.id, v)
            return
        end
        if (k == "grain_size") then
            DATA.bedrock_set_grain_size(t.id, v)
            return
        end
        if (k == "acidity") then
            DATA.bedrock_set_acidity(t.id, v)
            return
        end
        if (k == "igneous_extrusive") then
            DATA.bedrock_set_igneous_extrusive(t.id, v)
            return
        end
        if (k == "igneous_intrusive") then
            DATA.bedrock_set_igneous_intrusive(t.id, v)
            return
        end
        if (k == "sedimentary") then
            DATA.bedrock_set_sedimentary(t.id, v)
            return
        end
        if (k == "clastic") then
            DATA.bedrock_set_clastic(t.id, v)
            return
        end
        if (k == "evaporative") then
            DATA.bedrock_set_evaporative(t.id, v)
            return
        end
        if (k == "metamorphic_marble") then
            DATA.bedrock_set_metamorphic_marble(t.id, v)
            return
        end
        if (k == "metamorphic_slate") then
            DATA.bedrock_set_metamorphic_slate(t.id, v)
            return
        end
        if (k == "oceanic") then
            DATA.bedrock_set_oceanic(t.id, v)
            return
        end
        if (k == "sedimentary_ocean_deep") then
            DATA.bedrock_set_sedimentary_ocean_deep(t.id, v)
            return
        end
        if (k == "sedimentary_ocean_shallow") then
            DATA.bedrock_set_sedimentary_ocean_shallow(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id bedrock_id
---@return fat_bedrock_id fat_id
function DATA.fatten_bedrock(id)
    local result = {id = id}
    setmetatable(result, fat_bedrock_id_metatable)    return result
end
----------resource----------


---resource: LSP types---

---Unique identificator for resource entity
---@alias resource_id number

---@class (exact) fat_resource_id
---@field id resource_id Unique resource id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field base_frequency number number of tiles per which this resource is spawned
---@field coastal boolean 
---@field land boolean 
---@field water boolean 
---@field ice_age boolean requires presence of ice age ice
---@field minimum_trees number 
---@field maximum_trees number 
---@field minimum_elevation number 
---@field maximum_elevation number 

---@class struct_resource
---@field r number 
---@field g number 
---@field b number 
---@field required_biome table<number, biome_id> 
---@field required_bedrock table<number, bedrock_id> 
---@field base_frequency number number of tiles per which this resource is spawned
---@field minimum_trees number 
---@field maximum_trees number 
---@field minimum_elevation number 
---@field maximum_elevation number 

---@class (exact) resource_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field required_biome biome_id[] 
---@field required_bedrock bedrock_id[] 
---@field base_frequency number? number of tiles per which this resource is spawned
---@field coastal boolean? 
---@field land boolean? 
---@field water boolean? 
---@field ice_age boolean? requires presence of ice age ice
---@field minimum_trees number? 
---@field maximum_trees number? 
---@field minimum_elevation number? 
---@field maximum_elevation number? 
---Sets values of resource for given id
---@param id resource_id
---@param data resource_id_data_blob_definition
function DATA.setup_resource(id, data)
    DATA.resource_set_base_frequency(id, 1000)
    DATA.resource_set_coastal(id, false)
    DATA.resource_set_land(id, true)
    DATA.resource_set_water(id, false)
    DATA.resource_set_ice_age(id, false)
    DATA.resource_set_minimum_trees(id, 0)
    DATA.resource_set_maximum_trees(id, 1)
    DATA.resource_set_minimum_elevation(id, -math.huge)
    DATA.resource_set_maximum_elevation(id, math.huge)
    DATA.resource_set_name(id, data.name)
    DATA.resource_set_icon(id, data.icon)
    DATA.resource_set_description(id, data.description)
    DATA.resource_set_r(id, data.r)
    DATA.resource_set_g(id, data.g)
    DATA.resource_set_b(id, data.b)
    for i, value in ipairs(data.required_biome) do
        DATA.resource_set_required_biome(id, i - 1, value)
    end
    for i, value in ipairs(data.required_bedrock) do
        DATA.resource_set_required_bedrock(id, i - 1, value)
    end
    if data.base_frequency ~= nil then
        DATA.resource_set_base_frequency(id, data.base_frequency)
    end
    if data.coastal ~= nil then
        DATA.resource_set_coastal(id, data.coastal)
    end
    if data.land ~= nil then
        DATA.resource_set_land(id, data.land)
    end
    if data.water ~= nil then
        DATA.resource_set_water(id, data.water)
    end
    if data.ice_age ~= nil then
        DATA.resource_set_ice_age(id, data.ice_age)
    end
    if data.minimum_trees ~= nil then
        DATA.resource_set_minimum_trees(id, data.minimum_trees)
    end
    if data.maximum_trees ~= nil then
        DATA.resource_set_maximum_trees(id, data.maximum_trees)
    end
    if data.minimum_elevation ~= nil then
        DATA.resource_set_minimum_elevation(id, data.minimum_elevation)
    end
    if data.maximum_elevation ~= nil then
        DATA.resource_set_maximum_elevation(id, data.maximum_elevation)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        uint32_t required_biome[20];
        uint32_t required_bedrock[20];
        float base_frequency;
        float minimum_trees;
        float maximum_trees;
        float minimum_elevation;
        float maximum_elevation;
    } resource;
int32_t dcon_create_resource();
void dcon_resource_resize(uint32_t sz);
]]

---resource: FFI arrays---
---@type (string)[]
DATA.resource_name= {}
---@type (string)[]
DATA.resource_icon= {}
---@type (string)[]
DATA.resource_description= {}
---@type (boolean)[]
DATA.resource_coastal= {}
---@type (boolean)[]
DATA.resource_land= {}
---@type (boolean)[]
DATA.resource_water= {}
---@type (boolean)[]
DATA.resource_ice_age= {}
---@type nil
DATA.resource_calloc = ffi.C.calloc(1, ffi.sizeof("resource") * 301)
---@type table<resource_id, struct_resource>
DATA.resource = ffi.cast("resource*", DATA.resource_calloc)

---resource: LUA bindings---

DATA.resource_size = 300
---@type table<resource_id, boolean>
local resource_indices_pool = ffi.new("bool[?]", 300)
for i = 1, 299 do
    resource_indices_pool[i] = true 
end
---@type table<resource_id, resource_id>
DATA.resource_indices_set = {}
function DATA.create_resource()
    ---@type number
    local i = DCON.dcon_create_resource() + 1
            DATA.resource_indices_set[i] = i
    return i
end
---@param func fun(item: resource_id) 
function DATA.for_each_resource(func)
    for _, item in pairs(DATA.resource_indices_set) do
        func(item)
    end
end
---@param func fun(item: resource_id):boolean 
---@return table<resource_id, resource_id> 
function DATA.filter_resource(func)
    ---@type table<resource_id, resource_id> 
    local t = {}
    for _, item in pairs(DATA.resource_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param resource_id resource_id valid resource id
---@return string name 
function DATA.resource_get_name(resource_id)
    return DATA.resource_name[resource_id]
end
---@param resource_id resource_id valid resource id
---@param value string valid string
function DATA.resource_set_name(resource_id, value)
    DATA.resource_name[resource_id] = value
end
---@param resource_id resource_id valid resource id
---@return string icon 
function DATA.resource_get_icon(resource_id)
    return DATA.resource_icon[resource_id]
end
---@param resource_id resource_id valid resource id
---@param value string valid string
function DATA.resource_set_icon(resource_id, value)
    DATA.resource_icon[resource_id] = value
end
---@param resource_id resource_id valid resource id
---@return string description 
function DATA.resource_get_description(resource_id)
    return DATA.resource_description[resource_id]
end
---@param resource_id resource_id valid resource id
---@param value string valid string
function DATA.resource_set_description(resource_id, value)
    DATA.resource_description[resource_id] = value
end
---@param resource_id resource_id valid resource id
---@return number r 
function DATA.resource_get_r(resource_id)
    return DATA.resource[resource_id].r
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_r(resource_id, value)
    DATA.resource[resource_id].r = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_r(resource_id, value)
    DATA.resource[resource_id].r = DATA.resource[resource_id].r + value
end
---@param resource_id resource_id valid resource id
---@return number g 
function DATA.resource_get_g(resource_id)
    return DATA.resource[resource_id].g
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_g(resource_id, value)
    DATA.resource[resource_id].g = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_g(resource_id, value)
    DATA.resource[resource_id].g = DATA.resource[resource_id].g + value
end
---@param resource_id resource_id valid resource id
---@return number b 
function DATA.resource_get_b(resource_id)
    return DATA.resource[resource_id].b
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_b(resource_id, value)
    DATA.resource[resource_id].b = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_b(resource_id, value)
    DATA.resource[resource_id].b = DATA.resource[resource_id].b + value
end
---@param resource_id resource_id valid resource id
---@param index number valid
---@return biome_id required_biome 
function DATA.resource_get_required_biome(resource_id, index)
    return DATA.resource[resource_id].required_biome[index]
end
---@param resource_id resource_id valid resource id
---@param index number valid index
---@param value biome_id valid biome_id
function DATA.resource_set_required_biome(resource_id, index, value)
    DATA.resource[resource_id].required_biome[index] = value
end
---@param resource_id resource_id valid resource id
---@param index number valid
---@return bedrock_id required_bedrock 
function DATA.resource_get_required_bedrock(resource_id, index)
    return DATA.resource[resource_id].required_bedrock[index]
end
---@param resource_id resource_id valid resource id
---@param index number valid index
---@param value bedrock_id valid bedrock_id
function DATA.resource_set_required_bedrock(resource_id, index, value)
    DATA.resource[resource_id].required_bedrock[index] = value
end
---@param resource_id resource_id valid resource id
---@return number base_frequency number of tiles per which this resource is spawned
function DATA.resource_get_base_frequency(resource_id)
    return DATA.resource[resource_id].base_frequency
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_base_frequency(resource_id, value)
    DATA.resource[resource_id].base_frequency = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_base_frequency(resource_id, value)
    DATA.resource[resource_id].base_frequency = DATA.resource[resource_id].base_frequency + value
end
---@param resource_id resource_id valid resource id
---@return boolean coastal 
function DATA.resource_get_coastal(resource_id)
    return DATA.resource_coastal[resource_id]
end
---@param resource_id resource_id valid resource id
---@param value boolean valid boolean
function DATA.resource_set_coastal(resource_id, value)
    DATA.resource_coastal[resource_id] = value
end
---@param resource_id resource_id valid resource id
---@return boolean land 
function DATA.resource_get_land(resource_id)
    return DATA.resource_land[resource_id]
end
---@param resource_id resource_id valid resource id
---@param value boolean valid boolean
function DATA.resource_set_land(resource_id, value)
    DATA.resource_land[resource_id] = value
end
---@param resource_id resource_id valid resource id
---@return boolean water 
function DATA.resource_get_water(resource_id)
    return DATA.resource_water[resource_id]
end
---@param resource_id resource_id valid resource id
---@param value boolean valid boolean
function DATA.resource_set_water(resource_id, value)
    DATA.resource_water[resource_id] = value
end
---@param resource_id resource_id valid resource id
---@return boolean ice_age requires presence of ice age ice
function DATA.resource_get_ice_age(resource_id)
    return DATA.resource_ice_age[resource_id]
end
---@param resource_id resource_id valid resource id
---@param value boolean valid boolean
function DATA.resource_set_ice_age(resource_id, value)
    DATA.resource_ice_age[resource_id] = value
end
---@param resource_id resource_id valid resource id
---@return number minimum_trees 
function DATA.resource_get_minimum_trees(resource_id)
    return DATA.resource[resource_id].minimum_trees
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_minimum_trees(resource_id, value)
    DATA.resource[resource_id].minimum_trees = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_minimum_trees(resource_id, value)
    DATA.resource[resource_id].minimum_trees = DATA.resource[resource_id].minimum_trees + value
end
---@param resource_id resource_id valid resource id
---@return number maximum_trees 
function DATA.resource_get_maximum_trees(resource_id)
    return DATA.resource[resource_id].maximum_trees
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_maximum_trees(resource_id, value)
    DATA.resource[resource_id].maximum_trees = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_maximum_trees(resource_id, value)
    DATA.resource[resource_id].maximum_trees = DATA.resource[resource_id].maximum_trees + value
end
---@param resource_id resource_id valid resource id
---@return number minimum_elevation 
function DATA.resource_get_minimum_elevation(resource_id)
    return DATA.resource[resource_id].minimum_elevation
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_minimum_elevation(resource_id, value)
    DATA.resource[resource_id].minimum_elevation = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_minimum_elevation(resource_id, value)
    DATA.resource[resource_id].minimum_elevation = DATA.resource[resource_id].minimum_elevation + value
end
---@param resource_id resource_id valid resource id
---@return number maximum_elevation 
function DATA.resource_get_maximum_elevation(resource_id)
    return DATA.resource[resource_id].maximum_elevation
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_set_maximum_elevation(resource_id, value)
    DATA.resource[resource_id].maximum_elevation = value
end
---@param resource_id resource_id valid resource id
---@param value number valid number
function DATA.resource_inc_maximum_elevation(resource_id, value)
    DATA.resource[resource_id].maximum_elevation = DATA.resource[resource_id].maximum_elevation + value
end


local fat_resource_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.resource_get_name(t.id) end
        if (k == "icon") then return DATA.resource_get_icon(t.id) end
        if (k == "description") then return DATA.resource_get_description(t.id) end
        if (k == "r") then return DATA.resource_get_r(t.id) end
        if (k == "g") then return DATA.resource_get_g(t.id) end
        if (k == "b") then return DATA.resource_get_b(t.id) end
        if (k == "base_frequency") then return DATA.resource_get_base_frequency(t.id) end
        if (k == "coastal") then return DATA.resource_get_coastal(t.id) end
        if (k == "land") then return DATA.resource_get_land(t.id) end
        if (k == "water") then return DATA.resource_get_water(t.id) end
        if (k == "ice_age") then return DATA.resource_get_ice_age(t.id) end
        if (k == "minimum_trees") then return DATA.resource_get_minimum_trees(t.id) end
        if (k == "maximum_trees") then return DATA.resource_get_maximum_trees(t.id) end
        if (k == "minimum_elevation") then return DATA.resource_get_minimum_elevation(t.id) end
        if (k == "maximum_elevation") then return DATA.resource_get_maximum_elevation(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.resource_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.resource_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.resource_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.resource_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.resource_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.resource_set_b(t.id, v)
            return
        end
        if (k == "base_frequency") then
            DATA.resource_set_base_frequency(t.id, v)
            return
        end
        if (k == "coastal") then
            DATA.resource_set_coastal(t.id, v)
            return
        end
        if (k == "land") then
            DATA.resource_set_land(t.id, v)
            return
        end
        if (k == "water") then
            DATA.resource_set_water(t.id, v)
            return
        end
        if (k == "ice_age") then
            DATA.resource_set_ice_age(t.id, v)
            return
        end
        if (k == "minimum_trees") then
            DATA.resource_set_minimum_trees(t.id, v)
            return
        end
        if (k == "maximum_trees") then
            DATA.resource_set_maximum_trees(t.id, v)
            return
        end
        if (k == "minimum_elevation") then
            DATA.resource_set_minimum_elevation(t.id, v)
            return
        end
        if (k == "maximum_elevation") then
            DATA.resource_set_maximum_elevation(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id resource_id
---@return fat_resource_id fat_id
function DATA.fatten_resource(id)
    local result = {id = id}
    setmetatable(result, fat_resource_id_metatable)    return result
end
----------unit_type----------


---unit_type: LSP types---

---Unique identificator for unit_type entity
---@alias unit_type_id number

---@class (exact) fat_unit_type_id
---@field id unit_type_id Unique unit_type id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field base_price number 
---@field upkeep number 
---@field supply_used number how much food does this unit consume each month
---@field base_health number 
---@field base_attack number 
---@field base_armor number 
---@field speed number 
---@field foraging number how much food does this unit forage from the local province?
---@field supply_capacity number how much food can this unit carry
---@field spotting number 
---@field visibility number 

---@class struct_unit_type
---@field r number 
---@field g number 
---@field b number 
---@field base_price number 
---@field upkeep number 
---@field supply_used number how much food does this unit consume each month
---@field trade_good_requirements table<number, struct_trade_good_container> 
---@field base_health number 
---@field base_attack number 
---@field base_armor number 
---@field speed number 
---@field foraging number how much food does this unit forage from the local province?
---@field bonuses table<unit_type_id, number> 
---@field supply_capacity number how much food can this unit carry
---@field spotting number 
---@field visibility number 

---@class (exact) unit_type_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field base_price number? 
---@field upkeep number? 
---@field supply_used number? how much food does this unit consume each month
---@field base_health number? 
---@field base_attack number? 
---@field base_armor number? 
---@field speed number? 
---@field foraging number? how much food does this unit forage from the local province?
---@field bonuses number[] 
---@field supply_capacity number? how much food can this unit carry
---@field unlocked_by technology_id 
---@field spotting number? 
---@field visibility number? 
---Sets values of unit_type for given id
---@param id unit_type_id
---@param data unit_type_id_data_blob_definition
function DATA.setup_unit_type(id, data)
    DATA.unit_type_set_base_price(id, 10)
    DATA.unit_type_set_upkeep(id, 0.5)
    DATA.unit_type_set_supply_used(id, 1)
    DATA.unit_type_set_base_health(id, 50)
    DATA.unit_type_set_base_attack(id, 5)
    DATA.unit_type_set_base_armor(id, 1)
    DATA.unit_type_set_speed(id, 1)
    DATA.unit_type_set_foraging(id, 0.1)
    DATA.unit_type_set_supply_capacity(id, 5)
    DATA.unit_type_set_spotting(id, 1)
    DATA.unit_type_set_visibility(id, 1)
    DATA.unit_type_set_name(id, data.name)
    DATA.unit_type_set_icon(id, data.icon)
    DATA.unit_type_set_description(id, data.description)
    DATA.unit_type_set_r(id, data.r)
    DATA.unit_type_set_g(id, data.g)
    DATA.unit_type_set_b(id, data.b)
    if data.base_price ~= nil then
        DATA.unit_type_set_base_price(id, data.base_price)
    end
    if data.upkeep ~= nil then
        DATA.unit_type_set_upkeep(id, data.upkeep)
    end
    if data.supply_used ~= nil then
        DATA.unit_type_set_supply_used(id, data.supply_used)
    end
    if data.base_health ~= nil then
        DATA.unit_type_set_base_health(id, data.base_health)
    end
    if data.base_attack ~= nil then
        DATA.unit_type_set_base_attack(id, data.base_attack)
    end
    if data.base_armor ~= nil then
        DATA.unit_type_set_base_armor(id, data.base_armor)
    end
    if data.speed ~= nil then
        DATA.unit_type_set_speed(id, data.speed)
    end
    if data.foraging ~= nil then
        DATA.unit_type_set_foraging(id, data.foraging)
    end
    for i, value in ipairs(data.bonuses) do
        DATA.unit_type_set_bonuses(id, i - 1, value)
    end
    if data.supply_capacity ~= nil then
        DATA.unit_type_set_supply_capacity(id, data.supply_capacity)
    end
    if data.spotting ~= nil then
        DATA.unit_type_set_spotting(id, data.spotting)
    end
    if data.visibility ~= nil then
        DATA.unit_type_set_visibility(id, data.visibility)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        float base_price;
        float upkeep;
        float supply_used;
        trade_good_container trade_good_requirements[10];
        float base_health;
        float base_attack;
        float base_armor;
        float speed;
        float foraging;
        float bonuses[20];
        float supply_capacity;
        float spotting;
        float visibility;
    } unit_type;
int32_t dcon_create_unit_type();
void dcon_unit_type_resize(uint32_t sz);
]]

---unit_type: FFI arrays---
---@type (string)[]
DATA.unit_type_name= {}
---@type (string)[]
DATA.unit_type_icon= {}
---@type (string)[]
DATA.unit_type_description= {}
---@type nil
DATA.unit_type_calloc = ffi.C.calloc(1, ffi.sizeof("unit_type") * 21)
---@type table<unit_type_id, struct_unit_type>
DATA.unit_type = ffi.cast("unit_type*", DATA.unit_type_calloc)

---unit_type: LUA bindings---

DATA.unit_type_size = 20
---@type table<unit_type_id, boolean>
local unit_type_indices_pool = ffi.new("bool[?]", 20)
for i = 1, 19 do
    unit_type_indices_pool[i] = true 
end
---@type table<unit_type_id, unit_type_id>
DATA.unit_type_indices_set = {}
function DATA.create_unit_type()
    ---@type number
    local i = DCON.dcon_create_unit_type() + 1
            DATA.unit_type_indices_set[i] = i
    return i
end
---@param func fun(item: unit_type_id) 
function DATA.for_each_unit_type(func)
    for _, item in pairs(DATA.unit_type_indices_set) do
        func(item)
    end
end
---@param func fun(item: unit_type_id):boolean 
---@return table<unit_type_id, unit_type_id> 
function DATA.filter_unit_type(func)
    ---@type table<unit_type_id, unit_type_id> 
    local t = {}
    for _, item in pairs(DATA.unit_type_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param unit_type_id unit_type_id valid unit_type id
---@return string name 
function DATA.unit_type_get_name(unit_type_id)
    return DATA.unit_type_name[unit_type_id]
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value string valid string
function DATA.unit_type_set_name(unit_type_id, value)
    DATA.unit_type_name[unit_type_id] = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return string icon 
function DATA.unit_type_get_icon(unit_type_id)
    return DATA.unit_type_icon[unit_type_id]
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value string valid string
function DATA.unit_type_set_icon(unit_type_id, value)
    DATA.unit_type_icon[unit_type_id] = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return string description 
function DATA.unit_type_get_description(unit_type_id)
    return DATA.unit_type_description[unit_type_id]
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value string valid string
function DATA.unit_type_set_description(unit_type_id, value)
    DATA.unit_type_description[unit_type_id] = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number r 
function DATA.unit_type_get_r(unit_type_id)
    return DATA.unit_type[unit_type_id].r
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_r(unit_type_id, value)
    DATA.unit_type[unit_type_id].r = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_r(unit_type_id, value)
    DATA.unit_type[unit_type_id].r = DATA.unit_type[unit_type_id].r + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number g 
function DATA.unit_type_get_g(unit_type_id)
    return DATA.unit_type[unit_type_id].g
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_g(unit_type_id, value)
    DATA.unit_type[unit_type_id].g = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_g(unit_type_id, value)
    DATA.unit_type[unit_type_id].g = DATA.unit_type[unit_type_id].g + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number b 
function DATA.unit_type_get_b(unit_type_id)
    return DATA.unit_type[unit_type_id].b
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_b(unit_type_id, value)
    DATA.unit_type[unit_type_id].b = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_b(unit_type_id, value)
    DATA.unit_type[unit_type_id].b = DATA.unit_type[unit_type_id].b + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number base_price 
function DATA.unit_type_get_base_price(unit_type_id)
    return DATA.unit_type[unit_type_id].base_price
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_base_price(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_price = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_base_price(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_price = DATA.unit_type[unit_type_id].base_price + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number upkeep 
function DATA.unit_type_get_upkeep(unit_type_id)
    return DATA.unit_type[unit_type_id].upkeep
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_upkeep(unit_type_id, value)
    DATA.unit_type[unit_type_id].upkeep = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_upkeep(unit_type_id, value)
    DATA.unit_type[unit_type_id].upkeep = DATA.unit_type[unit_type_id].upkeep + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number supply_used how much food does this unit consume each month
function DATA.unit_type_get_supply_used(unit_type_id)
    return DATA.unit_type[unit_type_id].supply_used
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_supply_used(unit_type_id, value)
    DATA.unit_type[unit_type_id].supply_used = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_supply_used(unit_type_id, value)
    DATA.unit_type[unit_type_id].supply_used = DATA.unit_type[unit_type_id].supply_used + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index number valid
---@return trade_good_id trade_good_requirements 
function DATA.unit_type_get_trade_good_requirements_good(unit_type_id, index)
    return DATA.unit_type[unit_type_id].trade_good_requirements[index].good
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index number valid
---@return number trade_good_requirements 
function DATA.unit_type_get_trade_good_requirements_amount(unit_type_id, index)
    return DATA.unit_type[unit_type_id].trade_good_requirements[index].amount
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.unit_type_set_trade_good_requirements_good(unit_type_id, index, value)
    DATA.unit_type[unit_type_id].trade_good_requirements[index].good = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index number valid index
---@param value number valid number
function DATA.unit_type_set_trade_good_requirements_amount(unit_type_id, index, value)
    DATA.unit_type[unit_type_id].trade_good_requirements[index].amount = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index number valid index
---@param value number valid number
function DATA.unit_type_inc_trade_good_requirements_amount(unit_type_id, index, value)
    DATA.unit_type[unit_type_id].trade_good_requirements[index].amount = DATA.unit_type[unit_type_id].trade_good_requirements[index].amount + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number base_health 
function DATA.unit_type_get_base_health(unit_type_id)
    return DATA.unit_type[unit_type_id].base_health
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_base_health(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_health = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_base_health(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_health = DATA.unit_type[unit_type_id].base_health + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number base_attack 
function DATA.unit_type_get_base_attack(unit_type_id)
    return DATA.unit_type[unit_type_id].base_attack
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_base_attack(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_attack = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_base_attack(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_attack = DATA.unit_type[unit_type_id].base_attack + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number base_armor 
function DATA.unit_type_get_base_armor(unit_type_id)
    return DATA.unit_type[unit_type_id].base_armor
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_base_armor(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_armor = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_base_armor(unit_type_id, value)
    DATA.unit_type[unit_type_id].base_armor = DATA.unit_type[unit_type_id].base_armor + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number speed 
function DATA.unit_type_get_speed(unit_type_id)
    return DATA.unit_type[unit_type_id].speed
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_speed(unit_type_id, value)
    DATA.unit_type[unit_type_id].speed = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_speed(unit_type_id, value)
    DATA.unit_type[unit_type_id].speed = DATA.unit_type[unit_type_id].speed + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number foraging how much food does this unit forage from the local province?
function DATA.unit_type_get_foraging(unit_type_id)
    return DATA.unit_type[unit_type_id].foraging
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_foraging(unit_type_id, value)
    DATA.unit_type[unit_type_id].foraging = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_foraging(unit_type_id, value)
    DATA.unit_type[unit_type_id].foraging = DATA.unit_type[unit_type_id].foraging + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index unit_type_id valid
---@return number bonuses 
function DATA.unit_type_get_bonuses(unit_type_id, index)
    return DATA.unit_type[unit_type_id].bonuses[index]
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.unit_type_set_bonuses(unit_type_id, index, value)
    DATA.unit_type[unit_type_id].bonuses[index] = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param index unit_type_id valid index
---@param value number valid number
function DATA.unit_type_inc_bonuses(unit_type_id, index, value)
    DATA.unit_type[unit_type_id].bonuses[index] = DATA.unit_type[unit_type_id].bonuses[index] + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number supply_capacity how much food can this unit carry
function DATA.unit_type_get_supply_capacity(unit_type_id)
    return DATA.unit_type[unit_type_id].supply_capacity
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_supply_capacity(unit_type_id, value)
    DATA.unit_type[unit_type_id].supply_capacity = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_supply_capacity(unit_type_id, value)
    DATA.unit_type[unit_type_id].supply_capacity = DATA.unit_type[unit_type_id].supply_capacity + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number spotting 
function DATA.unit_type_get_spotting(unit_type_id)
    return DATA.unit_type[unit_type_id].spotting
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_spotting(unit_type_id, value)
    DATA.unit_type[unit_type_id].spotting = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_spotting(unit_type_id, value)
    DATA.unit_type[unit_type_id].spotting = DATA.unit_type[unit_type_id].spotting + value
end
---@param unit_type_id unit_type_id valid unit_type id
---@return number visibility 
function DATA.unit_type_get_visibility(unit_type_id)
    return DATA.unit_type[unit_type_id].visibility
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_set_visibility(unit_type_id, value)
    DATA.unit_type[unit_type_id].visibility = value
end
---@param unit_type_id unit_type_id valid unit_type id
---@param value number valid number
function DATA.unit_type_inc_visibility(unit_type_id, value)
    DATA.unit_type[unit_type_id].visibility = DATA.unit_type[unit_type_id].visibility + value
end


local fat_unit_type_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.unit_type_get_name(t.id) end
        if (k == "icon") then return DATA.unit_type_get_icon(t.id) end
        if (k == "description") then return DATA.unit_type_get_description(t.id) end
        if (k == "r") then return DATA.unit_type_get_r(t.id) end
        if (k == "g") then return DATA.unit_type_get_g(t.id) end
        if (k == "b") then return DATA.unit_type_get_b(t.id) end
        if (k == "base_price") then return DATA.unit_type_get_base_price(t.id) end
        if (k == "upkeep") then return DATA.unit_type_get_upkeep(t.id) end
        if (k == "supply_used") then return DATA.unit_type_get_supply_used(t.id) end
        if (k == "base_health") then return DATA.unit_type_get_base_health(t.id) end
        if (k == "base_attack") then return DATA.unit_type_get_base_attack(t.id) end
        if (k == "base_armor") then return DATA.unit_type_get_base_armor(t.id) end
        if (k == "speed") then return DATA.unit_type_get_speed(t.id) end
        if (k == "foraging") then return DATA.unit_type_get_foraging(t.id) end
        if (k == "supply_capacity") then return DATA.unit_type_get_supply_capacity(t.id) end
        if (k == "spotting") then return DATA.unit_type_get_spotting(t.id) end
        if (k == "visibility") then return DATA.unit_type_get_visibility(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.unit_type_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.unit_type_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.unit_type_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.unit_type_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.unit_type_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.unit_type_set_b(t.id, v)
            return
        end
        if (k == "base_price") then
            DATA.unit_type_set_base_price(t.id, v)
            return
        end
        if (k == "upkeep") then
            DATA.unit_type_set_upkeep(t.id, v)
            return
        end
        if (k == "supply_used") then
            DATA.unit_type_set_supply_used(t.id, v)
            return
        end
        if (k == "base_health") then
            DATA.unit_type_set_base_health(t.id, v)
            return
        end
        if (k == "base_attack") then
            DATA.unit_type_set_base_attack(t.id, v)
            return
        end
        if (k == "base_armor") then
            DATA.unit_type_set_base_armor(t.id, v)
            return
        end
        if (k == "speed") then
            DATA.unit_type_set_speed(t.id, v)
            return
        end
        if (k == "foraging") then
            DATA.unit_type_set_foraging(t.id, v)
            return
        end
        if (k == "supply_capacity") then
            DATA.unit_type_set_supply_capacity(t.id, v)
            return
        end
        if (k == "spotting") then
            DATA.unit_type_set_spotting(t.id, v)
            return
        end
        if (k == "visibility") then
            DATA.unit_type_set_visibility(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id unit_type_id
---@return fat_unit_type_id fat_id
function DATA.fatten_unit_type(id)
    local result = {id = id}
    setmetatable(result, fat_unit_type_id_metatable)    return result
end
----------job----------


---job: LSP types---

---Unique identificator for job entity
---@alias job_id number

---@class (exact) fat_job_id
---@field id job_id Unique job id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 

---@class struct_job
---@field r number 
---@field g number 
---@field b number 

---@class (exact) job_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---Sets values of job for given id
---@param id job_id
---@param data job_id_data_blob_definition
function DATA.setup_job(id, data)
    DATA.job_set_name(id, data.name)
    DATA.job_set_icon(id, data.icon)
    DATA.job_set_description(id, data.description)
    DATA.job_set_r(id, data.r)
    DATA.job_set_g(id, data.g)
    DATA.job_set_b(id, data.b)
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
    } job;
int32_t dcon_create_job();
void dcon_job_resize(uint32_t sz);
]]

---job: FFI arrays---
---@type (string)[]
DATA.job_name= {}
---@type (string)[]
DATA.job_icon= {}
---@type (string)[]
DATA.job_description= {}
---@type nil
DATA.job_calloc = ffi.C.calloc(1, ffi.sizeof("job") * 251)
---@type table<job_id, struct_job>
DATA.job = ffi.cast("job*", DATA.job_calloc)

---job: LUA bindings---

DATA.job_size = 250
---@type table<job_id, boolean>
local job_indices_pool = ffi.new("bool[?]", 250)
for i = 1, 249 do
    job_indices_pool[i] = true 
end
---@type table<job_id, job_id>
DATA.job_indices_set = {}
function DATA.create_job()
    ---@type number
    local i = DCON.dcon_create_job() + 1
            DATA.job_indices_set[i] = i
    return i
end
---@param func fun(item: job_id) 
function DATA.for_each_job(func)
    for _, item in pairs(DATA.job_indices_set) do
        func(item)
    end
end
---@param func fun(item: job_id):boolean 
---@return table<job_id, job_id> 
function DATA.filter_job(func)
    ---@type table<job_id, job_id> 
    local t = {}
    for _, item in pairs(DATA.job_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param job_id job_id valid job id
---@return string name 
function DATA.job_get_name(job_id)
    return DATA.job_name[job_id]
end
---@param job_id job_id valid job id
---@param value string valid string
function DATA.job_set_name(job_id, value)
    DATA.job_name[job_id] = value
end
---@param job_id job_id valid job id
---@return string icon 
function DATA.job_get_icon(job_id)
    return DATA.job_icon[job_id]
end
---@param job_id job_id valid job id
---@param value string valid string
function DATA.job_set_icon(job_id, value)
    DATA.job_icon[job_id] = value
end
---@param job_id job_id valid job id
---@return string description 
function DATA.job_get_description(job_id)
    return DATA.job_description[job_id]
end
---@param job_id job_id valid job id
---@param value string valid string
function DATA.job_set_description(job_id, value)
    DATA.job_description[job_id] = value
end
---@param job_id job_id valid job id
---@return number r 
function DATA.job_get_r(job_id)
    return DATA.job[job_id].r
end
---@param job_id job_id valid job id
---@param value number valid number
function DATA.job_set_r(job_id, value)
    DATA.job[job_id].r = value
end
---@param job_id job_id valid job id
---@param value number valid number
function DATA.job_inc_r(job_id, value)
    DATA.job[job_id].r = DATA.job[job_id].r + value
end
---@param job_id job_id valid job id
---@return number g 
function DATA.job_get_g(job_id)
    return DATA.job[job_id].g
end
---@param job_id job_id valid job id
---@param value number valid number
function DATA.job_set_g(job_id, value)
    DATA.job[job_id].g = value
end
---@param job_id job_id valid job id
---@param value number valid number
function DATA.job_inc_g(job_id, value)
    DATA.job[job_id].g = DATA.job[job_id].g + value
end
---@param job_id job_id valid job id
---@return number b 
function DATA.job_get_b(job_id)
    return DATA.job[job_id].b
end
---@param job_id job_id valid job id
---@param value number valid number
function DATA.job_set_b(job_id, value)
    DATA.job[job_id].b = value
end
---@param job_id job_id valid job id
---@param value number valid number
function DATA.job_inc_b(job_id, value)
    DATA.job[job_id].b = DATA.job[job_id].b + value
end


local fat_job_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.job_get_name(t.id) end
        if (k == "icon") then return DATA.job_get_icon(t.id) end
        if (k == "description") then return DATA.job_get_description(t.id) end
        if (k == "r") then return DATA.job_get_r(t.id) end
        if (k == "g") then return DATA.job_get_g(t.id) end
        if (k == "b") then return DATA.job_get_b(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.job_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.job_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.job_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.job_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.job_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.job_set_b(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id job_id
---@return fat_job_id fat_id
function DATA.fatten_job(id)
    local result = {id = id}
    setmetatable(result, fat_job_id_metatable)    return result
end
----------production_method----------


---production_method: LSP types---

---Unique identificator for production_method entity
---@alias production_method_id number

---@class (exact) fat_production_method_id
---@field id production_method_id Unique production_method id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field job_type JOBTYPE 
---@field foraging boolean If true, worktime counts towards the foragers count
---@field hydration boolean If true, worktime counts towards the foragers_water count
---@field nature_yield_dependence number How much does the local flora and fauna impact this buildings yield? Defaults to 0
---@field forest_dependence number Set to 1 if building consumes local forests
---@field crop boolean If true, the building will periodically change its yield for a season.
---@field temperature_ideal_min number 
---@field temperature_ideal_max number 
---@field temperature_extreme_min number 
---@field temperature_extreme_max number 
---@field rainfall_ideal_min number 
---@field rainfall_ideal_max number 
---@field rainfall_extreme_min number 
---@field rainfall_extreme_max number 
---@field clay_ideal_min number 
---@field clay_ideal_max number 
---@field clay_extreme_min number 
---@field clay_extreme_max number 

---@class struct_production_method
---@field r number 
---@field g number 
---@field b number 
---@field job_type JOBTYPE 
---@field jobs table<number, struct_job_container> 
---@field inputs table<number, struct_use_case_container> 
---@field outputs table<number, struct_trade_good_container> 
---@field foraging boolean If true, worktime counts towards the foragers count
---@field hydration boolean If true, worktime counts towards the foragers_water count
---@field nature_yield_dependence number How much does the local flora and fauna impact this buildings yield? Defaults to 0
---@field forest_dependence number Set to 1 if building consumes local forests
---@field crop boolean If true, the building will periodically change its yield for a season.
---@field temperature_ideal_min number 
---@field temperature_ideal_max number 
---@field temperature_extreme_min number 
---@field temperature_extreme_max number 
---@field rainfall_ideal_min number 
---@field rainfall_ideal_max number 
---@field rainfall_extreme_min number 
---@field rainfall_extreme_max number 
---@field clay_ideal_min number 
---@field clay_ideal_max number 
---@field clay_extreme_min number 
---@field clay_extreme_max number 

---@class (exact) production_method_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field job_type JOBTYPE 
---@field foraging boolean? If true, worktime counts towards the foragers count
---@field hydration boolean? If true, worktime counts towards the foragers_water count
---@field nature_yield_dependence number? How much does the local flora and fauna impact this buildings yield? Defaults to 0
---@field forest_dependence number? Set to 1 if building consumes local forests
---@field crop boolean? If true, the building will periodically change its yield for a season.
---@field temperature_ideal_min number? 
---@field temperature_ideal_max number? 
---@field temperature_extreme_min number? 
---@field temperature_extreme_max number? 
---@field rainfall_ideal_min number? 
---@field rainfall_ideal_max number? 
---@field rainfall_extreme_min number? 
---@field rainfall_extreme_max number? 
---@field clay_ideal_min number? 
---@field clay_ideal_max number? 
---@field clay_extreme_min number? 
---@field clay_extreme_max number? 
---Sets values of production_method for given id
---@param id production_method_id
---@param data production_method_id_data_blob_definition
function DATA.setup_production_method(id, data)
    DATA.production_method_set_foraging(id, false)
    DATA.production_method_set_hydration(id, false)
    DATA.production_method_set_nature_yield_dependence(id, 0)
    DATA.production_method_set_forest_dependence(id, 0)
    DATA.production_method_set_crop(id, false)
    DATA.production_method_set_temperature_ideal_min(id, 10)
    DATA.production_method_set_temperature_ideal_max(id, 30)
    DATA.production_method_set_temperature_extreme_min(id, 0)
    DATA.production_method_set_temperature_extreme_max(id, 50)
    DATA.production_method_set_rainfall_ideal_min(id, 50)
    DATA.production_method_set_rainfall_ideal_max(id, 100)
    DATA.production_method_set_rainfall_extreme_min(id, 5)
    DATA.production_method_set_rainfall_extreme_max(id, 350)
    DATA.production_method_set_clay_ideal_min(id, 0)
    DATA.production_method_set_clay_ideal_max(id, 1)
    DATA.production_method_set_clay_extreme_min(id, 0)
    DATA.production_method_set_clay_extreme_max(id, 1)
    DATA.production_method_set_name(id, data.name)
    DATA.production_method_set_icon(id, data.icon)
    DATA.production_method_set_description(id, data.description)
    DATA.production_method_set_r(id, data.r)
    DATA.production_method_set_g(id, data.g)
    DATA.production_method_set_b(id, data.b)
    DATA.production_method_set_job_type(id, data.job_type)
    if data.foraging ~= nil then
        DATA.production_method_set_foraging(id, data.foraging)
    end
    if data.hydration ~= nil then
        DATA.production_method_set_hydration(id, data.hydration)
    end
    if data.nature_yield_dependence ~= nil then
        DATA.production_method_set_nature_yield_dependence(id, data.nature_yield_dependence)
    end
    if data.forest_dependence ~= nil then
        DATA.production_method_set_forest_dependence(id, data.forest_dependence)
    end
    if data.crop ~= nil then
        DATA.production_method_set_crop(id, data.crop)
    end
    if data.temperature_ideal_min ~= nil then
        DATA.production_method_set_temperature_ideal_min(id, data.temperature_ideal_min)
    end
    if data.temperature_ideal_max ~= nil then
        DATA.production_method_set_temperature_ideal_max(id, data.temperature_ideal_max)
    end
    if data.temperature_extreme_min ~= nil then
        DATA.production_method_set_temperature_extreme_min(id, data.temperature_extreme_min)
    end
    if data.temperature_extreme_max ~= nil then
        DATA.production_method_set_temperature_extreme_max(id, data.temperature_extreme_max)
    end
    if data.rainfall_ideal_min ~= nil then
        DATA.production_method_set_rainfall_ideal_min(id, data.rainfall_ideal_min)
    end
    if data.rainfall_ideal_max ~= nil then
        DATA.production_method_set_rainfall_ideal_max(id, data.rainfall_ideal_max)
    end
    if data.rainfall_extreme_min ~= nil then
        DATA.production_method_set_rainfall_extreme_min(id, data.rainfall_extreme_min)
    end
    if data.rainfall_extreme_max ~= nil then
        DATA.production_method_set_rainfall_extreme_max(id, data.rainfall_extreme_max)
    end
    if data.clay_ideal_min ~= nil then
        DATA.production_method_set_clay_ideal_min(id, data.clay_ideal_min)
    end
    if data.clay_ideal_max ~= nil then
        DATA.production_method_set_clay_ideal_max(id, data.clay_ideal_max)
    end
    if data.clay_extreme_min ~= nil then
        DATA.production_method_set_clay_extreme_min(id, data.clay_extreme_min)
    end
    if data.clay_extreme_max ~= nil then
        DATA.production_method_set_clay_extreme_max(id, data.clay_extreme_max)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        uint8_t job_type;
        job_container jobs[8];
        use_case_container inputs[8];
        trade_good_container outputs[8];
        bool foraging;
        bool hydration;
        float nature_yield_dependence;
        float forest_dependence;
        bool crop;
        float temperature_ideal_min;
        float temperature_ideal_max;
        float temperature_extreme_min;
        float temperature_extreme_max;
        float rainfall_ideal_min;
        float rainfall_ideal_max;
        float rainfall_extreme_min;
        float rainfall_extreme_max;
        float clay_ideal_min;
        float clay_ideal_max;
        float clay_extreme_min;
        float clay_extreme_max;
    } production_method;
int32_t dcon_create_production_method();
void dcon_production_method_resize(uint32_t sz);
]]

---production_method: FFI arrays---
---@type (string)[]
DATA.production_method_name= {}
---@type (string)[]
DATA.production_method_icon= {}
---@type (string)[]
DATA.production_method_description= {}
---@type nil
DATA.production_method_calloc = ffi.C.calloc(1, ffi.sizeof("production_method") * 251)
---@type table<production_method_id, struct_production_method>
DATA.production_method = ffi.cast("production_method*", DATA.production_method_calloc)

---production_method: LUA bindings---

DATA.production_method_size = 250
---@type table<production_method_id, boolean>
local production_method_indices_pool = ffi.new("bool[?]", 250)
for i = 1, 249 do
    production_method_indices_pool[i] = true 
end
---@type table<production_method_id, production_method_id>
DATA.production_method_indices_set = {}
function DATA.create_production_method()
    ---@type number
    local i = DCON.dcon_create_production_method() + 1
            DATA.production_method_indices_set[i] = i
    return i
end
---@param func fun(item: production_method_id) 
function DATA.for_each_production_method(func)
    for _, item in pairs(DATA.production_method_indices_set) do
        func(item)
    end
end
---@param func fun(item: production_method_id):boolean 
---@return table<production_method_id, production_method_id> 
function DATA.filter_production_method(func)
    ---@type table<production_method_id, production_method_id> 
    local t = {}
    for _, item in pairs(DATA.production_method_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param production_method_id production_method_id valid production_method id
---@return string name 
function DATA.production_method_get_name(production_method_id)
    return DATA.production_method_name[production_method_id]
end
---@param production_method_id production_method_id valid production_method id
---@param value string valid string
function DATA.production_method_set_name(production_method_id, value)
    DATA.production_method_name[production_method_id] = value
end
---@param production_method_id production_method_id valid production_method id
---@return string icon 
function DATA.production_method_get_icon(production_method_id)
    return DATA.production_method_icon[production_method_id]
end
---@param production_method_id production_method_id valid production_method id
---@param value string valid string
function DATA.production_method_set_icon(production_method_id, value)
    DATA.production_method_icon[production_method_id] = value
end
---@param production_method_id production_method_id valid production_method id
---@return string description 
function DATA.production_method_get_description(production_method_id)
    return DATA.production_method_description[production_method_id]
end
---@param production_method_id production_method_id valid production_method id
---@param value string valid string
function DATA.production_method_set_description(production_method_id, value)
    DATA.production_method_description[production_method_id] = value
end
---@param production_method_id production_method_id valid production_method id
---@return number r 
function DATA.production_method_get_r(production_method_id)
    return DATA.production_method[production_method_id].r
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_r(production_method_id, value)
    DATA.production_method[production_method_id].r = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_r(production_method_id, value)
    DATA.production_method[production_method_id].r = DATA.production_method[production_method_id].r + value
end
---@param production_method_id production_method_id valid production_method id
---@return number g 
function DATA.production_method_get_g(production_method_id)
    return DATA.production_method[production_method_id].g
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_g(production_method_id, value)
    DATA.production_method[production_method_id].g = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_g(production_method_id, value)
    DATA.production_method[production_method_id].g = DATA.production_method[production_method_id].g + value
end
---@param production_method_id production_method_id valid production_method id
---@return number b 
function DATA.production_method_get_b(production_method_id)
    return DATA.production_method[production_method_id].b
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_b(production_method_id, value)
    DATA.production_method[production_method_id].b = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_b(production_method_id, value)
    DATA.production_method[production_method_id].b = DATA.production_method[production_method_id].b + value
end
---@param production_method_id production_method_id valid production_method id
---@return JOBTYPE job_type 
function DATA.production_method_get_job_type(production_method_id)
    return DATA.production_method[production_method_id].job_type
end
---@param production_method_id production_method_id valid production_method id
---@param value JOBTYPE valid JOBTYPE
function DATA.production_method_set_job_type(production_method_id, value)
    DATA.production_method[production_method_id].job_type = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return job_id jobs 
function DATA.production_method_get_jobs_job(production_method_id, index)
    return DATA.production_method[production_method_id].jobs[index].job
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return number jobs 
function DATA.production_method_get_jobs_amount(production_method_id, index)
    return DATA.production_method[production_method_id].jobs[index].amount
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value job_id valid job_id
function DATA.production_method_set_jobs_job(production_method_id, index, value)
    DATA.production_method[production_method_id].jobs[index].job = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_set_jobs_amount(production_method_id, index, value)
    DATA.production_method[production_method_id].jobs[index].amount = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_inc_jobs_amount(production_method_id, index, value)
    DATA.production_method[production_method_id].jobs[index].amount = DATA.production_method[production_method_id].jobs[index].amount + value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return use_case_id inputs 
function DATA.production_method_get_inputs_use(production_method_id, index)
    return DATA.production_method[production_method_id].inputs[index].use
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return number inputs 
function DATA.production_method_get_inputs_amount(production_method_id, index)
    return DATA.production_method[production_method_id].inputs[index].amount
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value use_case_id valid use_case_id
function DATA.production_method_set_inputs_use(production_method_id, index, value)
    DATA.production_method[production_method_id].inputs[index].use = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_set_inputs_amount(production_method_id, index, value)
    DATA.production_method[production_method_id].inputs[index].amount = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_inc_inputs_amount(production_method_id, index, value)
    DATA.production_method[production_method_id].inputs[index].amount = DATA.production_method[production_method_id].inputs[index].amount + value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return trade_good_id outputs 
function DATA.production_method_get_outputs_good(production_method_id, index)
    return DATA.production_method[production_method_id].outputs[index].good
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid
---@return number outputs 
function DATA.production_method_get_outputs_amount(production_method_id, index)
    return DATA.production_method[production_method_id].outputs[index].amount
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value trade_good_id valid trade_good_id
function DATA.production_method_set_outputs_good(production_method_id, index, value)
    DATA.production_method[production_method_id].outputs[index].good = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_set_outputs_amount(production_method_id, index, value)
    DATA.production_method[production_method_id].outputs[index].amount = value
end
---@param production_method_id production_method_id valid production_method id
---@param index number valid index
---@param value number valid number
function DATA.production_method_inc_outputs_amount(production_method_id, index, value)
    DATA.production_method[production_method_id].outputs[index].amount = DATA.production_method[production_method_id].outputs[index].amount + value
end
---@param production_method_id production_method_id valid production_method id
---@return boolean foraging If true, worktime counts towards the foragers count
function DATA.production_method_get_foraging(production_method_id)
    return DATA.production_method[production_method_id].foraging
end
---@param production_method_id production_method_id valid production_method id
---@param value boolean valid boolean
function DATA.production_method_set_foraging(production_method_id, value)
    DATA.production_method[production_method_id].foraging = value
end
---@param production_method_id production_method_id valid production_method id
---@return boolean hydration If true, worktime counts towards the foragers_water count
function DATA.production_method_get_hydration(production_method_id)
    return DATA.production_method[production_method_id].hydration
end
---@param production_method_id production_method_id valid production_method id
---@param value boolean valid boolean
function DATA.production_method_set_hydration(production_method_id, value)
    DATA.production_method[production_method_id].hydration = value
end
---@param production_method_id production_method_id valid production_method id
---@return number nature_yield_dependence How much does the local flora and fauna impact this buildings yield? Defaults to 0
function DATA.production_method_get_nature_yield_dependence(production_method_id)
    return DATA.production_method[production_method_id].nature_yield_dependence
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_nature_yield_dependence(production_method_id, value)
    DATA.production_method[production_method_id].nature_yield_dependence = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_nature_yield_dependence(production_method_id, value)
    DATA.production_method[production_method_id].nature_yield_dependence = DATA.production_method[production_method_id].nature_yield_dependence + value
end
---@param production_method_id production_method_id valid production_method id
---@return number forest_dependence Set to 1 if building consumes local forests
function DATA.production_method_get_forest_dependence(production_method_id)
    return DATA.production_method[production_method_id].forest_dependence
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_forest_dependence(production_method_id, value)
    DATA.production_method[production_method_id].forest_dependence = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_forest_dependence(production_method_id, value)
    DATA.production_method[production_method_id].forest_dependence = DATA.production_method[production_method_id].forest_dependence + value
end
---@param production_method_id production_method_id valid production_method id
---@return boolean crop If true, the building will periodically change its yield for a season.
function DATA.production_method_get_crop(production_method_id)
    return DATA.production_method[production_method_id].crop
end
---@param production_method_id production_method_id valid production_method id
---@param value boolean valid boolean
function DATA.production_method_set_crop(production_method_id, value)
    DATA.production_method[production_method_id].crop = value
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_ideal_min 
function DATA.production_method_get_temperature_ideal_min(production_method_id)
    return DATA.production_method[production_method_id].temperature_ideal_min
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_ideal_min(production_method_id, value)
    DATA.production_method[production_method_id].temperature_ideal_min = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_ideal_min(production_method_id, value)
    DATA.production_method[production_method_id].temperature_ideal_min = DATA.production_method[production_method_id].temperature_ideal_min + value
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_ideal_max 
function DATA.production_method_get_temperature_ideal_max(production_method_id)
    return DATA.production_method[production_method_id].temperature_ideal_max
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_ideal_max(production_method_id, value)
    DATA.production_method[production_method_id].temperature_ideal_max = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_ideal_max(production_method_id, value)
    DATA.production_method[production_method_id].temperature_ideal_max = DATA.production_method[production_method_id].temperature_ideal_max + value
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_extreme_min 
function DATA.production_method_get_temperature_extreme_min(production_method_id)
    return DATA.production_method[production_method_id].temperature_extreme_min
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_extreme_min(production_method_id, value)
    DATA.production_method[production_method_id].temperature_extreme_min = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_extreme_min(production_method_id, value)
    DATA.production_method[production_method_id].temperature_extreme_min = DATA.production_method[production_method_id].temperature_extreme_min + value
end
---@param production_method_id production_method_id valid production_method id
---@return number temperature_extreme_max 
function DATA.production_method_get_temperature_extreme_max(production_method_id)
    return DATA.production_method[production_method_id].temperature_extreme_max
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_temperature_extreme_max(production_method_id, value)
    DATA.production_method[production_method_id].temperature_extreme_max = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_temperature_extreme_max(production_method_id, value)
    DATA.production_method[production_method_id].temperature_extreme_max = DATA.production_method[production_method_id].temperature_extreme_max + value
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_ideal_min 
function DATA.production_method_get_rainfall_ideal_min(production_method_id)
    return DATA.production_method[production_method_id].rainfall_ideal_min
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_ideal_min(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_ideal_min = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_ideal_min(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_ideal_min = DATA.production_method[production_method_id].rainfall_ideal_min + value
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_ideal_max 
function DATA.production_method_get_rainfall_ideal_max(production_method_id)
    return DATA.production_method[production_method_id].rainfall_ideal_max
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_ideal_max(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_ideal_max = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_ideal_max(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_ideal_max = DATA.production_method[production_method_id].rainfall_ideal_max + value
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_extreme_min 
function DATA.production_method_get_rainfall_extreme_min(production_method_id)
    return DATA.production_method[production_method_id].rainfall_extreme_min
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_extreme_min(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_extreme_min = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_extreme_min(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_extreme_min = DATA.production_method[production_method_id].rainfall_extreme_min + value
end
---@param production_method_id production_method_id valid production_method id
---@return number rainfall_extreme_max 
function DATA.production_method_get_rainfall_extreme_max(production_method_id)
    return DATA.production_method[production_method_id].rainfall_extreme_max
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_rainfall_extreme_max(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_extreme_max = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_rainfall_extreme_max(production_method_id, value)
    DATA.production_method[production_method_id].rainfall_extreme_max = DATA.production_method[production_method_id].rainfall_extreme_max + value
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_ideal_min 
function DATA.production_method_get_clay_ideal_min(production_method_id)
    return DATA.production_method[production_method_id].clay_ideal_min
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_ideal_min(production_method_id, value)
    DATA.production_method[production_method_id].clay_ideal_min = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_ideal_min(production_method_id, value)
    DATA.production_method[production_method_id].clay_ideal_min = DATA.production_method[production_method_id].clay_ideal_min + value
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_ideal_max 
function DATA.production_method_get_clay_ideal_max(production_method_id)
    return DATA.production_method[production_method_id].clay_ideal_max
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_ideal_max(production_method_id, value)
    DATA.production_method[production_method_id].clay_ideal_max = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_ideal_max(production_method_id, value)
    DATA.production_method[production_method_id].clay_ideal_max = DATA.production_method[production_method_id].clay_ideal_max + value
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_extreme_min 
function DATA.production_method_get_clay_extreme_min(production_method_id)
    return DATA.production_method[production_method_id].clay_extreme_min
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_extreme_min(production_method_id, value)
    DATA.production_method[production_method_id].clay_extreme_min = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_extreme_min(production_method_id, value)
    DATA.production_method[production_method_id].clay_extreme_min = DATA.production_method[production_method_id].clay_extreme_min + value
end
---@param production_method_id production_method_id valid production_method id
---@return number clay_extreme_max 
function DATA.production_method_get_clay_extreme_max(production_method_id)
    return DATA.production_method[production_method_id].clay_extreme_max
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_set_clay_extreme_max(production_method_id, value)
    DATA.production_method[production_method_id].clay_extreme_max = value
end
---@param production_method_id production_method_id valid production_method id
---@param value number valid number
function DATA.production_method_inc_clay_extreme_max(production_method_id, value)
    DATA.production_method[production_method_id].clay_extreme_max = DATA.production_method[production_method_id].clay_extreme_max + value
end


local fat_production_method_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.production_method_get_name(t.id) end
        if (k == "icon") then return DATA.production_method_get_icon(t.id) end
        if (k == "description") then return DATA.production_method_get_description(t.id) end
        if (k == "r") then return DATA.production_method_get_r(t.id) end
        if (k == "g") then return DATA.production_method_get_g(t.id) end
        if (k == "b") then return DATA.production_method_get_b(t.id) end
        if (k == "job_type") then return DATA.production_method_get_job_type(t.id) end
        if (k == "foraging") then return DATA.production_method_get_foraging(t.id) end
        if (k == "hydration") then return DATA.production_method_get_hydration(t.id) end
        if (k == "nature_yield_dependence") then return DATA.production_method_get_nature_yield_dependence(t.id) end
        if (k == "forest_dependence") then return DATA.production_method_get_forest_dependence(t.id) end
        if (k == "crop") then return DATA.production_method_get_crop(t.id) end
        if (k == "temperature_ideal_min") then return DATA.production_method_get_temperature_ideal_min(t.id) end
        if (k == "temperature_ideal_max") then return DATA.production_method_get_temperature_ideal_max(t.id) end
        if (k == "temperature_extreme_min") then return DATA.production_method_get_temperature_extreme_min(t.id) end
        if (k == "temperature_extreme_max") then return DATA.production_method_get_temperature_extreme_max(t.id) end
        if (k == "rainfall_ideal_min") then return DATA.production_method_get_rainfall_ideal_min(t.id) end
        if (k == "rainfall_ideal_max") then return DATA.production_method_get_rainfall_ideal_max(t.id) end
        if (k == "rainfall_extreme_min") then return DATA.production_method_get_rainfall_extreme_min(t.id) end
        if (k == "rainfall_extreme_max") then return DATA.production_method_get_rainfall_extreme_max(t.id) end
        if (k == "clay_ideal_min") then return DATA.production_method_get_clay_ideal_min(t.id) end
        if (k == "clay_ideal_max") then return DATA.production_method_get_clay_ideal_max(t.id) end
        if (k == "clay_extreme_min") then return DATA.production_method_get_clay_extreme_min(t.id) end
        if (k == "clay_extreme_max") then return DATA.production_method_get_clay_extreme_max(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.production_method_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.production_method_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.production_method_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.production_method_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.production_method_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.production_method_set_b(t.id, v)
            return
        end
        if (k == "job_type") then
            DATA.production_method_set_job_type(t.id, v)
            return
        end
        if (k == "foraging") then
            DATA.production_method_set_foraging(t.id, v)
            return
        end
        if (k == "hydration") then
            DATA.production_method_set_hydration(t.id, v)
            return
        end
        if (k == "nature_yield_dependence") then
            DATA.production_method_set_nature_yield_dependence(t.id, v)
            return
        end
        if (k == "forest_dependence") then
            DATA.production_method_set_forest_dependence(t.id, v)
            return
        end
        if (k == "crop") then
            DATA.production_method_set_crop(t.id, v)
            return
        end
        if (k == "temperature_ideal_min") then
            DATA.production_method_set_temperature_ideal_min(t.id, v)
            return
        end
        if (k == "temperature_ideal_max") then
            DATA.production_method_set_temperature_ideal_max(t.id, v)
            return
        end
        if (k == "temperature_extreme_min") then
            DATA.production_method_set_temperature_extreme_min(t.id, v)
            return
        end
        if (k == "temperature_extreme_max") then
            DATA.production_method_set_temperature_extreme_max(t.id, v)
            return
        end
        if (k == "rainfall_ideal_min") then
            DATA.production_method_set_rainfall_ideal_min(t.id, v)
            return
        end
        if (k == "rainfall_ideal_max") then
            DATA.production_method_set_rainfall_ideal_max(t.id, v)
            return
        end
        if (k == "rainfall_extreme_min") then
            DATA.production_method_set_rainfall_extreme_min(t.id, v)
            return
        end
        if (k == "rainfall_extreme_max") then
            DATA.production_method_set_rainfall_extreme_max(t.id, v)
            return
        end
        if (k == "clay_ideal_min") then
            DATA.production_method_set_clay_ideal_min(t.id, v)
            return
        end
        if (k == "clay_ideal_max") then
            DATA.production_method_set_clay_ideal_max(t.id, v)
            return
        end
        if (k == "clay_extreme_min") then
            DATA.production_method_set_clay_extreme_min(t.id, v)
            return
        end
        if (k == "clay_extreme_max") then
            DATA.production_method_set_clay_extreme_max(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id production_method_id
---@return fat_production_method_id fat_id
function DATA.fatten_production_method(id)
    local result = {id = id}
    setmetatable(result, fat_production_method_id_metatable)    return result
end
----------technology----------


---technology: LSP types---

---Unique identificator for technology entity
---@alias technology_id number

---@class (exact) fat_technology_id
---@field id technology_id Unique technology id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field research_cost number Amount of research points (education_endowment) per pop needed for the technology
---@field associated_job job_id The job that is needed to perform this research. Without it, the research odds will be significantly lower. We'll be using this to make technology implicitly tied to player decisions

---@class struct_technology
---@field r number 
---@field g number 
---@field b number 
---@field research_cost number Amount of research points (education_endowment) per pop needed for the technology
---@field required_biome table<number, biome_id> 
---@field required_resource table<number, resource_id> 
---@field associated_job job_id The job that is needed to perform this research. Without it, the research odds will be significantly lower. We'll be using this to make technology implicitly tied to player decisions
---@field throughput_boosts table<production_method_id, number> 
---@field input_efficiency_boosts table<production_method_id, number> 
---@field output_efficiency_boosts table<production_method_id, number> 

---@class (exact) technology_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field research_cost number Amount of research points (education_endowment) per pop needed for the technology
---@field required_biome biome_id[] 
---@field required_race race_id[] 
---@field required_resource resource_id[] 
---@field associated_job job_id The job that is needed to perform this research. Without it, the research odds will be significantly lower. We'll be using this to make technology implicitly tied to player decisions
---@field throughput_boosts number[] 
---@field input_efficiency_boosts number[] 
---@field output_efficiency_boosts number[] 
---Sets values of technology for given id
---@param id technology_id
---@param data technology_id_data_blob_definition
function DATA.setup_technology(id, data)
    DATA.technology_set_name(id, data.name)
    DATA.technology_set_icon(id, data.icon)
    DATA.technology_set_description(id, data.description)
    DATA.technology_set_r(id, data.r)
    DATA.technology_set_g(id, data.g)
    DATA.technology_set_b(id, data.b)
    DATA.technology_set_research_cost(id, data.research_cost)
    for i, value in ipairs(data.required_biome) do
        DATA.technology_set_required_biome(id, i - 1, value)
    end
    for i, value in ipairs(data.required_race) do
        DATA.technology_set_required_race(id, i - 1, value)
    end
    for i, value in ipairs(data.required_resource) do
        DATA.technology_set_required_resource(id, i - 1, value)
    end
    DATA.technology_set_associated_job(id, data.associated_job)
    for i, value in ipairs(data.throughput_boosts) do
        DATA.technology_set_throughput_boosts(id, i - 1, value)
    end
    for i, value in ipairs(data.input_efficiency_boosts) do
        DATA.technology_set_input_efficiency_boosts(id, i - 1, value)
    end
    for i, value in ipairs(data.output_efficiency_boosts) do
        DATA.technology_set_output_efficiency_boosts(id, i - 1, value)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        float research_cost;
        uint32_t required_biome[20];
        uint32_t required_resource[20];
        uint32_t associated_job;
        float throughput_boosts[250];
        float input_efficiency_boosts[250];
        float output_efficiency_boosts[250];
    } technology;
int32_t dcon_create_technology();
void dcon_technology_resize(uint32_t sz);
]]

---technology: FFI arrays---
---@type (string)[]
DATA.technology_name= {}
---@type (string)[]
DATA.technology_icon= {}
---@type (string)[]
DATA.technology_description= {}
---@type (table<number, race_id>)[]
DATA.technology_required_race= {}
---@type nil
DATA.technology_calloc = ffi.C.calloc(1, ffi.sizeof("technology") * 401)
---@type table<technology_id, struct_technology>
DATA.technology = ffi.cast("technology*", DATA.technology_calloc)

---technology: LUA bindings---

DATA.technology_size = 400
---@type table<technology_id, boolean>
local technology_indices_pool = ffi.new("bool[?]", 400)
for i = 1, 399 do
    technology_indices_pool[i] = true 
end
---@type table<technology_id, technology_id>
DATA.technology_indices_set = {}
function DATA.create_technology()
    ---@type number
    local i = DCON.dcon_create_technology() + 1
            DATA.technology_indices_set[i] = i
    return i
end
---@param func fun(item: technology_id) 
function DATA.for_each_technology(func)
    for _, item in pairs(DATA.technology_indices_set) do
        func(item)
    end
end
---@param func fun(item: technology_id):boolean 
---@return table<technology_id, technology_id> 
function DATA.filter_technology(func)
    ---@type table<technology_id, technology_id> 
    local t = {}
    for _, item in pairs(DATA.technology_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param technology_id technology_id valid technology id
---@return string name 
function DATA.technology_get_name(technology_id)
    return DATA.technology_name[technology_id]
end
---@param technology_id technology_id valid technology id
---@param value string valid string
function DATA.technology_set_name(technology_id, value)
    DATA.technology_name[technology_id] = value
end
---@param technology_id technology_id valid technology id
---@return string icon 
function DATA.technology_get_icon(technology_id)
    return DATA.technology_icon[technology_id]
end
---@param technology_id technology_id valid technology id
---@param value string valid string
function DATA.technology_set_icon(technology_id, value)
    DATA.technology_icon[technology_id] = value
end
---@param technology_id technology_id valid technology id
---@return string description 
function DATA.technology_get_description(technology_id)
    return DATA.technology_description[technology_id]
end
---@param technology_id technology_id valid technology id
---@param value string valid string
function DATA.technology_set_description(technology_id, value)
    DATA.technology_description[technology_id] = value
end
---@param technology_id technology_id valid technology id
---@return number r 
function DATA.technology_get_r(technology_id)
    return DATA.technology[technology_id].r
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_set_r(technology_id, value)
    DATA.technology[technology_id].r = value
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_inc_r(technology_id, value)
    DATA.technology[technology_id].r = DATA.technology[technology_id].r + value
end
---@param technology_id technology_id valid technology id
---@return number g 
function DATA.technology_get_g(technology_id)
    return DATA.technology[technology_id].g
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_set_g(technology_id, value)
    DATA.technology[technology_id].g = value
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_inc_g(technology_id, value)
    DATA.technology[technology_id].g = DATA.technology[technology_id].g + value
end
---@param technology_id technology_id valid technology id
---@return number b 
function DATA.technology_get_b(technology_id)
    return DATA.technology[technology_id].b
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_set_b(technology_id, value)
    DATA.technology[technology_id].b = value
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_inc_b(technology_id, value)
    DATA.technology[technology_id].b = DATA.technology[technology_id].b + value
end
---@param technology_id technology_id valid technology id
---@return number research_cost Amount of research points (education_endowment) per pop needed for the technology
function DATA.technology_get_research_cost(technology_id)
    return DATA.technology[technology_id].research_cost
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_set_research_cost(technology_id, value)
    DATA.technology[technology_id].research_cost = value
end
---@param technology_id technology_id valid technology id
---@param value number valid number
function DATA.technology_inc_research_cost(technology_id, value)
    DATA.technology[technology_id].research_cost = DATA.technology[technology_id].research_cost + value
end
---@param technology_id technology_id valid technology id
---@param index number valid
---@return biome_id required_biome 
function DATA.technology_get_required_biome(technology_id, index)
    return DATA.technology[technology_id].required_biome[index]
end
---@param technology_id technology_id valid technology id
---@param index number valid index
---@param value biome_id valid biome_id
function DATA.technology_set_required_biome(technology_id, index, value)
    DATA.technology[technology_id].required_biome[index] = value
end
---@param technology_id technology_id valid technology id
---@param index number valid
---@return race_id required_race 
function DATA.technology_get_required_race(technology_id, index)
    return DATA.technology_required_race[technology_id][index]
end
---@param technology_id technology_id valid technology id
---@param index number valid index
---@param value race_id valid race_id
function DATA.technology_set_required_race(technology_id, index, value)
    DATA.technology_required_race[technology_id][index] = value
end
---@param technology_id technology_id valid technology id
---@param index number valid
---@return resource_id required_resource 
function DATA.technology_get_required_resource(technology_id, index)
    return DATA.technology[technology_id].required_resource[index]
end
---@param technology_id technology_id valid technology id
---@param index number valid index
---@param value resource_id valid resource_id
function DATA.technology_set_required_resource(technology_id, index, value)
    DATA.technology[technology_id].required_resource[index] = value
end
---@param technology_id technology_id valid technology id
---@return job_id associated_job The job that is needed to perform this research. Without it, the research odds will be significantly lower. We'll be using this to make technology implicitly tied to player decisions
function DATA.technology_get_associated_job(technology_id)
    return DATA.technology[technology_id].associated_job
end
---@param technology_id technology_id valid technology id
---@param value job_id valid job_id
function DATA.technology_set_associated_job(technology_id, value)
    DATA.technology[technology_id].associated_job = value
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid
---@return number throughput_boosts 
function DATA.technology_get_throughput_boosts(technology_id, index)
    return DATA.technology[technology_id].throughput_boosts[index]
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid index
---@param value number valid number
function DATA.technology_set_throughput_boosts(technology_id, index, value)
    DATA.technology[technology_id].throughput_boosts[index] = value
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid index
---@param value number valid number
function DATA.technology_inc_throughput_boosts(technology_id, index, value)
    DATA.technology[technology_id].throughput_boosts[index] = DATA.technology[technology_id].throughput_boosts[index] + value
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid
---@return number input_efficiency_boosts 
function DATA.technology_get_input_efficiency_boosts(technology_id, index)
    return DATA.technology[technology_id].input_efficiency_boosts[index]
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid index
---@param value number valid number
function DATA.technology_set_input_efficiency_boosts(technology_id, index, value)
    DATA.technology[technology_id].input_efficiency_boosts[index] = value
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid index
---@param value number valid number
function DATA.technology_inc_input_efficiency_boosts(technology_id, index, value)
    DATA.technology[technology_id].input_efficiency_boosts[index] = DATA.technology[technology_id].input_efficiency_boosts[index] + value
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid
---@return number output_efficiency_boosts 
function DATA.technology_get_output_efficiency_boosts(technology_id, index)
    return DATA.technology[technology_id].output_efficiency_boosts[index]
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid index
---@param value number valid number
function DATA.technology_set_output_efficiency_boosts(technology_id, index, value)
    DATA.technology[technology_id].output_efficiency_boosts[index] = value
end
---@param technology_id technology_id valid technology id
---@param index production_method_id valid index
---@param value number valid number
function DATA.technology_inc_output_efficiency_boosts(technology_id, index, value)
    DATA.technology[technology_id].output_efficiency_boosts[index] = DATA.technology[technology_id].output_efficiency_boosts[index] + value
end


local fat_technology_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.technology_get_name(t.id) end
        if (k == "icon") then return DATA.technology_get_icon(t.id) end
        if (k == "description") then return DATA.technology_get_description(t.id) end
        if (k == "r") then return DATA.technology_get_r(t.id) end
        if (k == "g") then return DATA.technology_get_g(t.id) end
        if (k == "b") then return DATA.technology_get_b(t.id) end
        if (k == "research_cost") then return DATA.technology_get_research_cost(t.id) end
        if (k == "associated_job") then return DATA.technology_get_associated_job(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.technology_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.technology_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.technology_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.technology_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.technology_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.technology_set_b(t.id, v)
            return
        end
        if (k == "research_cost") then
            DATA.technology_set_research_cost(t.id, v)
            return
        end
        if (k == "associated_job") then
            DATA.technology_set_associated_job(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id technology_id
---@return fat_technology_id fat_id
function DATA.fatten_technology(id)
    local result = {id = id}
    setmetatable(result, fat_technology_id_metatable)    return result
end
----------technology_unlock----------


---technology_unlock: LSP types---

---Unique identificator for technology_unlock entity
---@alias technology_unlock_id number

---@class (exact) fat_technology_unlock_id
---@field id technology_unlock_id Unique technology_unlock id
---@field origin technology_id 
---@field unlocked technology_id 

---@class struct_technology_unlock
---@field origin technology_id 
---@field unlocked technology_id 

---@class (exact) technology_unlock_id_data_blob_definition
---@field origin technology_id 
---@field unlocked technology_id 
---Sets values of technology_unlock for given id
---@param id technology_unlock_id
---@param data technology_unlock_id_data_blob_definition
function DATA.setup_technology_unlock(id, data)
end

ffi.cdef[[
    typedef struct {
        uint32_t origin;
        uint32_t unlocked;
    } technology_unlock;
int32_t dcon_create_technology_unlock();
void dcon_technology_unlock_resize(uint32_t sz);
]]

---technology_unlock: FFI arrays---
---@type nil
DATA.technology_unlock_calloc = ffi.C.calloc(1, ffi.sizeof("technology_unlock") * 801)
---@type table<technology_unlock_id, struct_technology_unlock>
DATA.technology_unlock = ffi.cast("technology_unlock*", DATA.technology_unlock_calloc)
---@type table<technology_id, technology_unlock_id[]>>
DATA.technology_unlock_from_origin= {}
for i = 1, 800 do
    DATA.technology_unlock_from_origin[i] = {}
end
---@type table<technology_id, technology_unlock_id[]>>
DATA.technology_unlock_from_unlocked= {}
for i = 1, 800 do
    DATA.technology_unlock_from_unlocked[i] = {}
end

---technology_unlock: LUA bindings---

DATA.technology_unlock_size = 800
---@type table<technology_unlock_id, boolean>
local technology_unlock_indices_pool = ffi.new("bool[?]", 800)
for i = 1, 799 do
    technology_unlock_indices_pool[i] = true 
end
---@type table<technology_unlock_id, technology_unlock_id>
DATA.technology_unlock_indices_set = {}
function DATA.create_technology_unlock()
    ---@type number
    local i = DCON.dcon_create_technology_unlock() + 1
            DATA.technology_unlock_indices_set[i] = i
    return i
end
---@param func fun(item: technology_unlock_id) 
function DATA.for_each_technology_unlock(func)
    for _, item in pairs(DATA.technology_unlock_indices_set) do
        func(item)
    end
end
---@param func fun(item: technology_unlock_id):boolean 
---@return table<technology_unlock_id, technology_unlock_id> 
function DATA.filter_technology_unlock(func)
    ---@type table<technology_unlock_id, technology_unlock_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unlock_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param technology_unlock_id technology_unlock_id valid technology_unlock id
---@return technology_id origin 
function DATA.technology_unlock_get_origin(technology_unlock_id)
    return DATA.technology_unlock[technology_unlock_id].origin
end
---@param origin technology_id valid technology_id
---@return technology_unlock_id[] An array of technology_unlock 
function DATA.get_technology_unlock_from_origin(origin)
    return DATA.technology_unlock_from_origin[origin]
end
---@param origin technology_id valid technology_id
---@param func fun(item: technology_unlock_id) valid technology_id
function DATA.for_each_technology_unlock_from_origin(origin, func)
    if DATA.technology_unlock_from_origin[origin] == nil then return end
    for _, item in pairs(DATA.technology_unlock_from_origin[origin]) do func(item) end
end
---@param origin technology_id valid technology_id
---@param func fun(item: technology_unlock_id):boolean 
---@return table<technology_unlock_id, technology_unlock_id> 
function DATA.filter_array_technology_unlock_from_origin(origin, func)
    ---@type table<technology_unlock_id, technology_unlock_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unlock_from_origin[origin]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param origin technology_id valid technology_id
---@param func fun(item: technology_unlock_id):boolean 
---@return table<technology_unlock_id, technology_unlock_id> 
function DATA.filter_technology_unlock_from_origin(origin, func)
    ---@type table<technology_unlock_id, technology_unlock_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unlock_from_origin[origin]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param technology_unlock_id technology_unlock_id valid technology_unlock id
---@param old_value technology_id valid technology_id
function __REMOVE_KEY_TECHNOLOGY_UNLOCK_ORIGIN(technology_unlock_id, old_value)
    local found_key = nil
    if DATA.technology_unlock_from_origin[old_value] == nil then
        DATA.technology_unlock_from_origin[old_value] = {}
        return
    end
    for key, value in pairs(DATA.technology_unlock_from_origin[old_value]) do
        if value == technology_unlock_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.technology_unlock_from_origin[old_value], found_key)
    end
end
---@param technology_unlock_id technology_unlock_id valid technology_unlock id
---@param value technology_id valid technology_id
function DATA.technology_unlock_set_origin(technology_unlock_id, value)
    local old_value = DATA.technology_unlock[technology_unlock_id].origin
    DATA.technology_unlock[technology_unlock_id].origin = value
    __REMOVE_KEY_TECHNOLOGY_UNLOCK_ORIGIN(technology_unlock_id, old_value)
    if DATA.technology_unlock_from_origin[value] == nil then DATA.technology_unlock_from_origin[value] = {} end
    table.insert(DATA.technology_unlock_from_origin[value], technology_unlock_id)
end
---@param technology_unlock_id technology_unlock_id valid technology_unlock id
---@return technology_id unlocked 
function DATA.technology_unlock_get_unlocked(technology_unlock_id)
    return DATA.technology_unlock[technology_unlock_id].unlocked
end
---@param unlocked technology_id valid technology_id
---@return technology_unlock_id[] An array of technology_unlock 
function DATA.get_technology_unlock_from_unlocked(unlocked)
    return DATA.technology_unlock_from_unlocked[unlocked]
end
---@param unlocked technology_id valid technology_id
---@param func fun(item: technology_unlock_id) valid technology_id
function DATA.for_each_technology_unlock_from_unlocked(unlocked, func)
    if DATA.technology_unlock_from_unlocked[unlocked] == nil then return end
    for _, item in pairs(DATA.technology_unlock_from_unlocked[unlocked]) do func(item) end
end
---@param unlocked technology_id valid technology_id
---@param func fun(item: technology_unlock_id):boolean 
---@return table<technology_unlock_id, technology_unlock_id> 
function DATA.filter_array_technology_unlock_from_unlocked(unlocked, func)
    ---@type table<technology_unlock_id, technology_unlock_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unlock_from_unlocked[unlocked]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param unlocked technology_id valid technology_id
---@param func fun(item: technology_unlock_id):boolean 
---@return table<technology_unlock_id, technology_unlock_id> 
function DATA.filter_technology_unlock_from_unlocked(unlocked, func)
    ---@type table<technology_unlock_id, technology_unlock_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unlock_from_unlocked[unlocked]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param technology_unlock_id technology_unlock_id valid technology_unlock id
---@param old_value technology_id valid technology_id
function __REMOVE_KEY_TECHNOLOGY_UNLOCK_UNLOCKED(technology_unlock_id, old_value)
    local found_key = nil
    if DATA.technology_unlock_from_unlocked[old_value] == nil then
        DATA.technology_unlock_from_unlocked[old_value] = {}
        return
    end
    for key, value in pairs(DATA.technology_unlock_from_unlocked[old_value]) do
        if value == technology_unlock_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.technology_unlock_from_unlocked[old_value], found_key)
    end
end
---@param technology_unlock_id technology_unlock_id valid technology_unlock id
---@param value technology_id valid technology_id
function DATA.technology_unlock_set_unlocked(technology_unlock_id, value)
    local old_value = DATA.technology_unlock[technology_unlock_id].unlocked
    DATA.technology_unlock[technology_unlock_id].unlocked = value
    __REMOVE_KEY_TECHNOLOGY_UNLOCK_UNLOCKED(technology_unlock_id, old_value)
    if DATA.technology_unlock_from_unlocked[value] == nil then DATA.technology_unlock_from_unlocked[value] = {} end
    table.insert(DATA.technology_unlock_from_unlocked[value], technology_unlock_id)
end


local fat_technology_unlock_id_metatable = {
    __index = function (t,k)
        if (k == "origin") then return DATA.technology_unlock_get_origin(t.id) end
        if (k == "unlocked") then return DATA.technology_unlock_get_unlocked(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "origin") then
            DATA.technology_unlock_set_origin(t.id, v)
            return
        end
        if (k == "unlocked") then
            DATA.technology_unlock_set_unlocked(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id technology_unlock_id
---@return fat_technology_unlock_id fat_id
function DATA.fatten_technology_unlock(id)
    local result = {id = id}
    setmetatable(result, fat_technology_unlock_id_metatable)    return result
end
----------building_type----------


---building_type: LSP types---

---Unique identificator for building_type entity
---@alias building_type_id number

---@class (exact) fat_building_type_id
---@field id building_type_id Unique building_type id
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field production_method production_method_id 
---@field construction_cost number 
---@field upkeep number 
---@field unique boolean only one per province!
---@field movable boolean is it possible to migrate with this building?
---@field government boolean only the government can build this building!
---@field needed_infrastructure number 
---@field spotting number The amount of "spotting" a building provides. Spotting is used in warfare. Higher spotting makes it more difficult for foreign armies to sneak in.

---@class struct_building_type
---@field r number 
---@field g number 
---@field b number 
---@field production_method production_method_id 
---@field construction_cost number 
---@field upkeep number 
---@field required_biome table<number, biome_id> 
---@field required_resource table<number, resource_id> 
---@field unique boolean only one per province!
---@field movable boolean is it possible to migrate with this building?
---@field government boolean only the government can build this building!
---@field needed_infrastructure number 
---@field spotting number The amount of "spotting" a building provides. Spotting is used in warfare. Higher spotting makes it more difficult for foreign armies to sneak in.

---@class (exact) building_type_id_data_blob_definition
---@field name string 
---@field icon string 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field production_method production_method_id 
---@field archetype BUILDING_ARCHETYPE 
---@field unlocked_by technology_id 
---@field construction_cost number 
---@field upkeep number? 
---@field required_biome biome_id[] 
---@field required_resource resource_id[] 
---@field unique boolean? only one per province!
---@field movable boolean? is it possible to migrate with this building?
---@field government boolean? only the government can build this building!
---@field needed_infrastructure number? 
---@field spotting number? The amount of "spotting" a building provides. Spotting is used in warfare. Higher spotting makes it more difficult for foreign armies to sneak in.
---Sets values of building_type for given id
---@param id building_type_id
---@param data building_type_id_data_blob_definition
function DATA.setup_building_type(id, data)
    DATA.building_type_set_upkeep(id, 0)
    DATA.building_type_set_unique(id, false)
    DATA.building_type_set_movable(id, false)
    DATA.building_type_set_government(id, false)
    DATA.building_type_set_needed_infrastructure(id, 0)
    DATA.building_type_set_spotting(id, 0)
    DATA.building_type_set_name(id, data.name)
    DATA.building_type_set_icon(id, data.icon)
    DATA.building_type_set_description(id, data.description)
    DATA.building_type_set_r(id, data.r)
    DATA.building_type_set_g(id, data.g)
    DATA.building_type_set_b(id, data.b)
    DATA.building_type_set_production_method(id, data.production_method)
    DATA.building_type_set_construction_cost(id, data.construction_cost)
    if data.upkeep ~= nil then
        DATA.building_type_set_upkeep(id, data.upkeep)
    end
    for i, value in ipairs(data.required_biome) do
        DATA.building_type_set_required_biome(id, i - 1, value)
    end
    for i, value in ipairs(data.required_resource) do
        DATA.building_type_set_required_resource(id, i - 1, value)
    end
    if data.unique ~= nil then
        DATA.building_type_set_unique(id, data.unique)
    end
    if data.movable ~= nil then
        DATA.building_type_set_movable(id, data.movable)
    end
    if data.government ~= nil then
        DATA.building_type_set_government(id, data.government)
    end
    if data.needed_infrastructure ~= nil then
        DATA.building_type_set_needed_infrastructure(id, data.needed_infrastructure)
    end
    if data.spotting ~= nil then
        DATA.building_type_set_spotting(id, data.spotting)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        uint32_t production_method;
        float construction_cost;
        float upkeep;
        uint32_t required_biome[20];
        uint32_t required_resource[20];
        bool unique;
        bool movable;
        bool government;
        float needed_infrastructure;
        float spotting;
    } building_type;
int32_t dcon_create_building_type();
void dcon_building_type_resize(uint32_t sz);
]]

---building_type: FFI arrays---
---@type (string)[]
DATA.building_type_name= {}
---@type (string)[]
DATA.building_type_icon= {}
---@type (string)[]
DATA.building_type_description= {}
---@type nil
DATA.building_type_calloc = ffi.C.calloc(1, ffi.sizeof("building_type") * 251)
---@type table<building_type_id, struct_building_type>
DATA.building_type = ffi.cast("building_type*", DATA.building_type_calloc)

---building_type: LUA bindings---

DATA.building_type_size = 250
---@type table<building_type_id, boolean>
local building_type_indices_pool = ffi.new("bool[?]", 250)
for i = 1, 249 do
    building_type_indices_pool[i] = true 
end
---@type table<building_type_id, building_type_id>
DATA.building_type_indices_set = {}
function DATA.create_building_type()
    ---@type number
    local i = DCON.dcon_create_building_type() + 1
            DATA.building_type_indices_set[i] = i
    return i
end
---@param func fun(item: building_type_id) 
function DATA.for_each_building_type(func)
    for _, item in pairs(DATA.building_type_indices_set) do
        func(item)
    end
end
---@param func fun(item: building_type_id):boolean 
---@return table<building_type_id, building_type_id> 
function DATA.filter_building_type(func)
    ---@type table<building_type_id, building_type_id> 
    local t = {}
    for _, item in pairs(DATA.building_type_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param building_type_id building_type_id valid building_type id
---@return string name 
function DATA.building_type_get_name(building_type_id)
    return DATA.building_type_name[building_type_id]
end
---@param building_type_id building_type_id valid building_type id
---@param value string valid string
function DATA.building_type_set_name(building_type_id, value)
    DATA.building_type_name[building_type_id] = value
end
---@param building_type_id building_type_id valid building_type id
---@return string icon 
function DATA.building_type_get_icon(building_type_id)
    return DATA.building_type_icon[building_type_id]
end
---@param building_type_id building_type_id valid building_type id
---@param value string valid string
function DATA.building_type_set_icon(building_type_id, value)
    DATA.building_type_icon[building_type_id] = value
end
---@param building_type_id building_type_id valid building_type id
---@return string description 
function DATA.building_type_get_description(building_type_id)
    return DATA.building_type_description[building_type_id]
end
---@param building_type_id building_type_id valid building_type id
---@param value string valid string
function DATA.building_type_set_description(building_type_id, value)
    DATA.building_type_description[building_type_id] = value
end
---@param building_type_id building_type_id valid building_type id
---@return number r 
function DATA.building_type_get_r(building_type_id)
    return DATA.building_type[building_type_id].r
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_set_r(building_type_id, value)
    DATA.building_type[building_type_id].r = value
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_inc_r(building_type_id, value)
    DATA.building_type[building_type_id].r = DATA.building_type[building_type_id].r + value
end
---@param building_type_id building_type_id valid building_type id
---@return number g 
function DATA.building_type_get_g(building_type_id)
    return DATA.building_type[building_type_id].g
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_set_g(building_type_id, value)
    DATA.building_type[building_type_id].g = value
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_inc_g(building_type_id, value)
    DATA.building_type[building_type_id].g = DATA.building_type[building_type_id].g + value
end
---@param building_type_id building_type_id valid building_type id
---@return number b 
function DATA.building_type_get_b(building_type_id)
    return DATA.building_type[building_type_id].b
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_set_b(building_type_id, value)
    DATA.building_type[building_type_id].b = value
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_inc_b(building_type_id, value)
    DATA.building_type[building_type_id].b = DATA.building_type[building_type_id].b + value
end
---@param building_type_id building_type_id valid building_type id
---@return production_method_id production_method 
function DATA.building_type_get_production_method(building_type_id)
    return DATA.building_type[building_type_id].production_method
end
---@param building_type_id building_type_id valid building_type id
---@param value production_method_id valid production_method_id
function DATA.building_type_set_production_method(building_type_id, value)
    DATA.building_type[building_type_id].production_method = value
end
---@param building_type_id building_type_id valid building_type id
---@return number construction_cost 
function DATA.building_type_get_construction_cost(building_type_id)
    return DATA.building_type[building_type_id].construction_cost
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_set_construction_cost(building_type_id, value)
    DATA.building_type[building_type_id].construction_cost = value
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_inc_construction_cost(building_type_id, value)
    DATA.building_type[building_type_id].construction_cost = DATA.building_type[building_type_id].construction_cost + value
end
---@param building_type_id building_type_id valid building_type id
---@return number upkeep 
function DATA.building_type_get_upkeep(building_type_id)
    return DATA.building_type[building_type_id].upkeep
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_set_upkeep(building_type_id, value)
    DATA.building_type[building_type_id].upkeep = value
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_inc_upkeep(building_type_id, value)
    DATA.building_type[building_type_id].upkeep = DATA.building_type[building_type_id].upkeep + value
end
---@param building_type_id building_type_id valid building_type id
---@param index number valid
---@return biome_id required_biome 
function DATA.building_type_get_required_biome(building_type_id, index)
    return DATA.building_type[building_type_id].required_biome[index]
end
---@param building_type_id building_type_id valid building_type id
---@param index number valid index
---@param value biome_id valid biome_id
function DATA.building_type_set_required_biome(building_type_id, index, value)
    DATA.building_type[building_type_id].required_biome[index] = value
end
---@param building_type_id building_type_id valid building_type id
---@param index number valid
---@return resource_id required_resource 
function DATA.building_type_get_required_resource(building_type_id, index)
    return DATA.building_type[building_type_id].required_resource[index]
end
---@param building_type_id building_type_id valid building_type id
---@param index number valid index
---@param value resource_id valid resource_id
function DATA.building_type_set_required_resource(building_type_id, index, value)
    DATA.building_type[building_type_id].required_resource[index] = value
end
---@param building_type_id building_type_id valid building_type id
---@return boolean unique only one per province!
function DATA.building_type_get_unique(building_type_id)
    return DATA.building_type[building_type_id].unique
end
---@param building_type_id building_type_id valid building_type id
---@param value boolean valid boolean
function DATA.building_type_set_unique(building_type_id, value)
    DATA.building_type[building_type_id].unique = value
end
---@param building_type_id building_type_id valid building_type id
---@return boolean movable is it possible to migrate with this building?
function DATA.building_type_get_movable(building_type_id)
    return DATA.building_type[building_type_id].movable
end
---@param building_type_id building_type_id valid building_type id
---@param value boolean valid boolean
function DATA.building_type_set_movable(building_type_id, value)
    DATA.building_type[building_type_id].movable = value
end
---@param building_type_id building_type_id valid building_type id
---@return boolean government only the government can build this building!
function DATA.building_type_get_government(building_type_id)
    return DATA.building_type[building_type_id].government
end
---@param building_type_id building_type_id valid building_type id
---@param value boolean valid boolean
function DATA.building_type_set_government(building_type_id, value)
    DATA.building_type[building_type_id].government = value
end
---@param building_type_id building_type_id valid building_type id
---@return number needed_infrastructure 
function DATA.building_type_get_needed_infrastructure(building_type_id)
    return DATA.building_type[building_type_id].needed_infrastructure
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_set_needed_infrastructure(building_type_id, value)
    DATA.building_type[building_type_id].needed_infrastructure = value
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_inc_needed_infrastructure(building_type_id, value)
    DATA.building_type[building_type_id].needed_infrastructure = DATA.building_type[building_type_id].needed_infrastructure + value
end
---@param building_type_id building_type_id valid building_type id
---@return number spotting The amount of "spotting" a building provides. Spotting is used in warfare. Higher spotting makes it more difficult for foreign armies to sneak in.
function DATA.building_type_get_spotting(building_type_id)
    return DATA.building_type[building_type_id].spotting
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_set_spotting(building_type_id, value)
    DATA.building_type[building_type_id].spotting = value
end
---@param building_type_id building_type_id valid building_type id
---@param value number valid number
function DATA.building_type_inc_spotting(building_type_id, value)
    DATA.building_type[building_type_id].spotting = DATA.building_type[building_type_id].spotting + value
end


local fat_building_type_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.building_type_get_name(t.id) end
        if (k == "icon") then return DATA.building_type_get_icon(t.id) end
        if (k == "description") then return DATA.building_type_get_description(t.id) end
        if (k == "r") then return DATA.building_type_get_r(t.id) end
        if (k == "g") then return DATA.building_type_get_g(t.id) end
        if (k == "b") then return DATA.building_type_get_b(t.id) end
        if (k == "production_method") then return DATA.building_type_get_production_method(t.id) end
        if (k == "construction_cost") then return DATA.building_type_get_construction_cost(t.id) end
        if (k == "upkeep") then return DATA.building_type_get_upkeep(t.id) end
        if (k == "unique") then return DATA.building_type_get_unique(t.id) end
        if (k == "movable") then return DATA.building_type_get_movable(t.id) end
        if (k == "government") then return DATA.building_type_get_government(t.id) end
        if (k == "needed_infrastructure") then return DATA.building_type_get_needed_infrastructure(t.id) end
        if (k == "spotting") then return DATA.building_type_get_spotting(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.building_type_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.building_type_set_icon(t.id, v)
            return
        end
        if (k == "description") then
            DATA.building_type_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.building_type_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.building_type_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.building_type_set_b(t.id, v)
            return
        end
        if (k == "production_method") then
            DATA.building_type_set_production_method(t.id, v)
            return
        end
        if (k == "construction_cost") then
            DATA.building_type_set_construction_cost(t.id, v)
            return
        end
        if (k == "upkeep") then
            DATA.building_type_set_upkeep(t.id, v)
            return
        end
        if (k == "unique") then
            DATA.building_type_set_unique(t.id, v)
            return
        end
        if (k == "movable") then
            DATA.building_type_set_movable(t.id, v)
            return
        end
        if (k == "government") then
            DATA.building_type_set_government(t.id, v)
            return
        end
        if (k == "needed_infrastructure") then
            DATA.building_type_set_needed_infrastructure(t.id, v)
            return
        end
        if (k == "spotting") then
            DATA.building_type_set_spotting(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id building_type_id
---@return fat_building_type_id fat_id
function DATA.fatten_building_type(id)
    local result = {id = id}
    setmetatable(result, fat_building_type_id_metatable)    return result
end
----------technology_building----------


---technology_building: LSP types---

---Unique identificator for technology_building entity
---@alias technology_building_id number

---@class (exact) fat_technology_building_id
---@field id technology_building_id Unique technology_building id
---@field technology technology_id 
---@field unlocked building_type_id 

---@class struct_technology_building
---@field technology technology_id 
---@field unlocked building_type_id 

---@class (exact) technology_building_id_data_blob_definition
---@field technology technology_id 
---@field unlocked building_type_id 
---Sets values of technology_building for given id
---@param id technology_building_id
---@param data technology_building_id_data_blob_definition
function DATA.setup_technology_building(id, data)
end

ffi.cdef[[
    typedef struct {
        uint32_t technology;
        uint32_t unlocked;
    } technology_building;
int32_t dcon_create_technology_building();
void dcon_technology_building_resize(uint32_t sz);
]]

---technology_building: FFI arrays---
---@type nil
DATA.technology_building_calloc = ffi.C.calloc(1, ffi.sizeof("technology_building") * 401)
---@type table<technology_building_id, struct_technology_building>
DATA.technology_building = ffi.cast("technology_building*", DATA.technology_building_calloc)
---@type table<technology_id, technology_building_id[]>>
DATA.technology_building_from_technology= {}
for i = 1, 400 do
    DATA.technology_building_from_technology[i] = {}
end
---@type table<building_type_id, technology_building_id>
DATA.technology_building_from_unlocked= {}

---technology_building: LUA bindings---

DATA.technology_building_size = 400
---@type table<technology_building_id, boolean>
local technology_building_indices_pool = ffi.new("bool[?]", 400)
for i = 1, 399 do
    technology_building_indices_pool[i] = true 
end
---@type table<technology_building_id, technology_building_id>
DATA.technology_building_indices_set = {}
function DATA.create_technology_building()
    ---@type number
    local i = DCON.dcon_create_technology_building() + 1
            DATA.technology_building_indices_set[i] = i
    return i
end
---@param func fun(item: technology_building_id) 
function DATA.for_each_technology_building(func)
    for _, item in pairs(DATA.technology_building_indices_set) do
        func(item)
    end
end
---@param func fun(item: technology_building_id):boolean 
---@return table<technology_building_id, technology_building_id> 
function DATA.filter_technology_building(func)
    ---@type table<technology_building_id, technology_building_id> 
    local t = {}
    for _, item in pairs(DATA.technology_building_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param technology_building_id technology_building_id valid technology_building id
---@return technology_id technology 
function DATA.technology_building_get_technology(technology_building_id)
    return DATA.technology_building[technology_building_id].technology
end
---@param technology technology_id valid technology_id
---@return technology_building_id[] An array of technology_building 
function DATA.get_technology_building_from_technology(technology)
    return DATA.technology_building_from_technology[technology]
end
---@param technology technology_id valid technology_id
---@param func fun(item: technology_building_id) valid technology_id
function DATA.for_each_technology_building_from_technology(technology, func)
    if DATA.technology_building_from_technology[technology] == nil then return end
    for _, item in pairs(DATA.technology_building_from_technology[technology]) do func(item) end
end
---@param technology technology_id valid technology_id
---@param func fun(item: technology_building_id):boolean 
---@return table<technology_building_id, technology_building_id> 
function DATA.filter_array_technology_building_from_technology(technology, func)
    ---@type table<technology_building_id, technology_building_id> 
    local t = {}
    for _, item in pairs(DATA.technology_building_from_technology[technology]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param technology technology_id valid technology_id
---@param func fun(item: technology_building_id):boolean 
---@return table<technology_building_id, technology_building_id> 
function DATA.filter_technology_building_from_technology(technology, func)
    ---@type table<technology_building_id, technology_building_id> 
    local t = {}
    for _, item in pairs(DATA.technology_building_from_technology[technology]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param technology_building_id technology_building_id valid technology_building id
---@param old_value technology_id valid technology_id
function __REMOVE_KEY_TECHNOLOGY_BUILDING_TECHNOLOGY(technology_building_id, old_value)
    local found_key = nil
    if DATA.technology_building_from_technology[old_value] == nil then
        DATA.technology_building_from_technology[old_value] = {}
        return
    end
    for key, value in pairs(DATA.technology_building_from_technology[old_value]) do
        if value == technology_building_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.technology_building_from_technology[old_value], found_key)
    end
end
---@param technology_building_id technology_building_id valid technology_building id
---@param value technology_id valid technology_id
function DATA.technology_building_set_technology(technology_building_id, value)
    local old_value = DATA.technology_building[technology_building_id].technology
    DATA.technology_building[technology_building_id].technology = value
    __REMOVE_KEY_TECHNOLOGY_BUILDING_TECHNOLOGY(technology_building_id, old_value)
    if DATA.technology_building_from_technology[value] == nil then DATA.technology_building_from_technology[value] = {} end
    table.insert(DATA.technology_building_from_technology[value], technology_building_id)
end
---@param technology_building_id technology_building_id valid technology_building id
---@return building_type_id unlocked 
function DATA.technology_building_get_unlocked(technology_building_id)
    return DATA.technology_building[technology_building_id].unlocked
end
---@param unlocked building_type_id valid building_type_id
---@return technology_building_id technology_building 
function DATA.get_technology_building_from_unlocked(unlocked)
    if DATA.technology_building_from_unlocked[unlocked] == nil then return 0 end
    return DATA.technology_building_from_unlocked[unlocked]
end
function __REMOVE_KEY_TECHNOLOGY_BUILDING_UNLOCKED(old_value)
    DATA.technology_building_from_unlocked[old_value] = nil
end
---@param technology_building_id technology_building_id valid technology_building id
---@param value building_type_id valid building_type_id
function DATA.technology_building_set_unlocked(technology_building_id, value)
    local old_value = DATA.technology_building[technology_building_id].unlocked
    DATA.technology_building[technology_building_id].unlocked = value
    __REMOVE_KEY_TECHNOLOGY_BUILDING_UNLOCKED(old_value)
    DATA.technology_building_from_unlocked[value] = technology_building_id
end


local fat_technology_building_id_metatable = {
    __index = function (t,k)
        if (k == "technology") then return DATA.technology_building_get_technology(t.id) end
        if (k == "unlocked") then return DATA.technology_building_get_unlocked(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "technology") then
            DATA.technology_building_set_technology(t.id, v)
            return
        end
        if (k == "unlocked") then
            DATA.technology_building_set_unlocked(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id technology_building_id
---@return fat_technology_building_id fat_id
function DATA.fatten_technology_building(id)
    local result = {id = id}
    setmetatable(result, fat_technology_building_id_metatable)    return result
end
----------technology_unit----------


---technology_unit: LSP types---

---Unique identificator for technology_unit entity
---@alias technology_unit_id number

---@class (exact) fat_technology_unit_id
---@field id technology_unit_id Unique technology_unit id
---@field technology technology_id 
---@field unlocked unit_type_id 

---@class struct_technology_unit
---@field technology technology_id 
---@field unlocked unit_type_id 

---@class (exact) technology_unit_id_data_blob_definition
---@field technology technology_id 
---@field unlocked unit_type_id 
---Sets values of technology_unit for given id
---@param id technology_unit_id
---@param data technology_unit_id_data_blob_definition
function DATA.setup_technology_unit(id, data)
end

ffi.cdef[[
    typedef struct {
        uint32_t technology;
        uint32_t unlocked;
    } technology_unit;
int32_t dcon_create_technology_unit();
void dcon_technology_unit_resize(uint32_t sz);
]]

---technology_unit: FFI arrays---
---@type nil
DATA.technology_unit_calloc = ffi.C.calloc(1, ffi.sizeof("technology_unit") * 401)
---@type table<technology_unit_id, struct_technology_unit>
DATA.technology_unit = ffi.cast("technology_unit*", DATA.technology_unit_calloc)
---@type table<technology_id, technology_unit_id[]>>
DATA.technology_unit_from_technology= {}
for i = 1, 400 do
    DATA.technology_unit_from_technology[i] = {}
end
---@type table<unit_type_id, technology_unit_id>
DATA.technology_unit_from_unlocked= {}

---technology_unit: LUA bindings---

DATA.technology_unit_size = 400
---@type table<technology_unit_id, boolean>
local technology_unit_indices_pool = ffi.new("bool[?]", 400)
for i = 1, 399 do
    technology_unit_indices_pool[i] = true 
end
---@type table<technology_unit_id, technology_unit_id>
DATA.technology_unit_indices_set = {}
function DATA.create_technology_unit()
    ---@type number
    local i = DCON.dcon_create_technology_unit() + 1
            DATA.technology_unit_indices_set[i] = i
    return i
end
---@param func fun(item: technology_unit_id) 
function DATA.for_each_technology_unit(func)
    for _, item in pairs(DATA.technology_unit_indices_set) do
        func(item)
    end
end
---@param func fun(item: technology_unit_id):boolean 
---@return table<technology_unit_id, technology_unit_id> 
function DATA.filter_technology_unit(func)
    ---@type table<technology_unit_id, technology_unit_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unit_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param technology_unit_id technology_unit_id valid technology_unit id
---@return technology_id technology 
function DATA.technology_unit_get_technology(technology_unit_id)
    return DATA.technology_unit[technology_unit_id].technology
end
---@param technology technology_id valid technology_id
---@return technology_unit_id[] An array of technology_unit 
function DATA.get_technology_unit_from_technology(technology)
    return DATA.technology_unit_from_technology[technology]
end
---@param technology technology_id valid technology_id
---@param func fun(item: technology_unit_id) valid technology_id
function DATA.for_each_technology_unit_from_technology(technology, func)
    if DATA.technology_unit_from_technology[technology] == nil then return end
    for _, item in pairs(DATA.technology_unit_from_technology[technology]) do func(item) end
end
---@param technology technology_id valid technology_id
---@param func fun(item: technology_unit_id):boolean 
---@return table<technology_unit_id, technology_unit_id> 
function DATA.filter_array_technology_unit_from_technology(technology, func)
    ---@type table<technology_unit_id, technology_unit_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unit_from_technology[technology]) do
        if func(item) then table.insert(t, item) end
    end
    return t
end
---@param technology technology_id valid technology_id
---@param func fun(item: technology_unit_id):boolean 
---@return table<technology_unit_id, technology_unit_id> 
function DATA.filter_technology_unit_from_technology(technology, func)
    ---@type table<technology_unit_id, technology_unit_id> 
    local t = {}
    for _, item in pairs(DATA.technology_unit_from_technology[technology]) do
        if func(item) then t[item] = item end
    end
    return t
end
---@param technology_unit_id technology_unit_id valid technology_unit id
---@param old_value technology_id valid technology_id
function __REMOVE_KEY_TECHNOLOGY_UNIT_TECHNOLOGY(technology_unit_id, old_value)
    local found_key = nil
    if DATA.technology_unit_from_technology[old_value] == nil then
        DATA.technology_unit_from_technology[old_value] = {}
        return
    end
    for key, value in pairs(DATA.technology_unit_from_technology[old_value]) do
        if value == technology_unit_id then
            found_key = key
            break
        end
    end
    if found_key ~= nil then
        table.remove(DATA.technology_unit_from_technology[old_value], found_key)
    end
end
---@param technology_unit_id technology_unit_id valid technology_unit id
---@param value technology_id valid technology_id
function DATA.technology_unit_set_technology(technology_unit_id, value)
    local old_value = DATA.technology_unit[technology_unit_id].technology
    DATA.technology_unit[technology_unit_id].technology = value
    __REMOVE_KEY_TECHNOLOGY_UNIT_TECHNOLOGY(technology_unit_id, old_value)
    if DATA.technology_unit_from_technology[value] == nil then DATA.technology_unit_from_technology[value] = {} end
    table.insert(DATA.technology_unit_from_technology[value], technology_unit_id)
end
---@param technology_unit_id technology_unit_id valid technology_unit id
---@return unit_type_id unlocked 
function DATA.technology_unit_get_unlocked(technology_unit_id)
    return DATA.technology_unit[technology_unit_id].unlocked
end
---@param unlocked unit_type_id valid unit_type_id
---@return technology_unit_id technology_unit 
function DATA.get_technology_unit_from_unlocked(unlocked)
    if DATA.technology_unit_from_unlocked[unlocked] == nil then return 0 end
    return DATA.technology_unit_from_unlocked[unlocked]
end
function __REMOVE_KEY_TECHNOLOGY_UNIT_UNLOCKED(old_value)
    DATA.technology_unit_from_unlocked[old_value] = nil
end
---@param technology_unit_id technology_unit_id valid technology_unit id
---@param value unit_type_id valid unit_type_id
function DATA.technology_unit_set_unlocked(technology_unit_id, value)
    local old_value = DATA.technology_unit[technology_unit_id].unlocked
    DATA.technology_unit[technology_unit_id].unlocked = value
    __REMOVE_KEY_TECHNOLOGY_UNIT_UNLOCKED(old_value)
    DATA.technology_unit_from_unlocked[value] = technology_unit_id
end


local fat_technology_unit_id_metatable = {
    __index = function (t,k)
        if (k == "technology") then return DATA.technology_unit_get_technology(t.id) end
        if (k == "unlocked") then return DATA.technology_unit_get_unlocked(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "technology") then
            DATA.technology_unit_set_technology(t.id, v)
            return
        end
        if (k == "unlocked") then
            DATA.technology_unit_set_unlocked(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id technology_unit_id
---@return fat_technology_unit_id fat_id
function DATA.fatten_technology_unit(id)
    local result = {id = id}
    setmetatable(result, fat_technology_unit_id_metatable)    return result
end
----------race----------


---race: LSP types---

---Unique identificator for race entity
---@alias race_id number

---@class (exact) fat_race_id
---@field id race_id Unique race id
---@field name string 
---@field icon string 
---@field female_portrait nil|PortraitSet 
---@field male_portrait nil|PortraitSet 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field carrying_capacity_weight number 
---@field fecundity number 
---@field spotting number How good is this unit at scouting
---@field visibility number How visible is this unit in battles
---@field males_per_hundred_females number 
---@field child_age number 
---@field teen_age number 
---@field adult_age number 
---@field middle_age number 
---@field elder_age number 
---@field max_age number 
---@field minimum_comfortable_temperature number 
---@field minimum_absolute_temperature number 
---@field minimum_comfortable_elevation number 
---@field female_body_size number 
---@field male_body_size number 
---@field female_infrastructure_needs number 
---@field male_infrastructure_needs number 
---@field requires_large_river boolean 
---@field requires_large_forest boolean 

---@class struct_race
---@field r number 
---@field g number 
---@field b number 
---@field carrying_capacity_weight number 
---@field fecundity number 
---@field spotting number How good is this unit at scouting
---@field visibility number How visible is this unit in battles
---@field males_per_hundred_females number 
---@field child_age number 
---@field teen_age number 
---@field adult_age number 
---@field middle_age number 
---@field elder_age number 
---@field max_age number 
---@field minimum_comfortable_temperature number 
---@field minimum_absolute_temperature number 
---@field minimum_comfortable_elevation number 
---@field female_body_size number 
---@field male_body_size number 
---@field female_efficiency table<JOBTYPE, number> 
---@field male_efficiency table<JOBTYPE, number> 
---@field female_infrastructure_needs number 
---@field male_infrastructure_needs number 
---@field female_needs table<number, struct_need_definition> 
---@field male_needs table<number, struct_need_definition> 
---@field requires_large_river boolean 
---@field requires_large_forest boolean 

---@class (exact) race_id_data_blob_definition
---@field name string 
---@field icon string 
---@field female_portrait nil|PortraitSet 
---@field male_portrait nil|PortraitSet 
---@field description string 
---@field r number 
---@field g number 
---@field b number 
---@field carrying_capacity_weight number 
---@field fecundity number 
---@field spotting number How good is this unit at scouting
---@field visibility number How visible is this unit in battles
---@field males_per_hundred_females number 
---@field child_age number 
---@field teen_age number 
---@field adult_age number 
---@field middle_age number 
---@field elder_age number 
---@field max_age number 
---@field minimum_comfortable_temperature number 
---@field minimum_absolute_temperature number 
---@field minimum_comfortable_elevation number? 
---@field female_body_size number 
---@field male_body_size number 
---@field female_efficiency number[] 
---@field male_efficiency number[] 
---@field female_infrastructure_needs number 
---@field male_infrastructure_needs number 
---@field requires_large_river boolean? 
---@field requires_large_forest boolean? 
---Sets values of race for given id
---@param id race_id
---@param data race_id_data_blob_definition
function DATA.setup_race(id, data)
    DATA.race_set_minimum_comfortable_elevation(id, 0.0)
    DATA.race_set_requires_large_river(id, false)
    DATA.race_set_requires_large_forest(id, false)
    DATA.race_set_name(id, data.name)
    DATA.race_set_icon(id, data.icon)
    DATA.race_set_female_portrait(id, data.female_portrait)
    DATA.race_set_male_portrait(id, data.male_portrait)
    DATA.race_set_description(id, data.description)
    DATA.race_set_r(id, data.r)
    DATA.race_set_g(id, data.g)
    DATA.race_set_b(id, data.b)
    DATA.race_set_carrying_capacity_weight(id, data.carrying_capacity_weight)
    DATA.race_set_fecundity(id, data.fecundity)
    DATA.race_set_spotting(id, data.spotting)
    DATA.race_set_visibility(id, data.visibility)
    DATA.race_set_males_per_hundred_females(id, data.males_per_hundred_females)
    DATA.race_set_child_age(id, data.child_age)
    DATA.race_set_teen_age(id, data.teen_age)
    DATA.race_set_adult_age(id, data.adult_age)
    DATA.race_set_middle_age(id, data.middle_age)
    DATA.race_set_elder_age(id, data.elder_age)
    DATA.race_set_max_age(id, data.max_age)
    DATA.race_set_minimum_comfortable_temperature(id, data.minimum_comfortable_temperature)
    DATA.race_set_minimum_absolute_temperature(id, data.minimum_absolute_temperature)
    if data.minimum_comfortable_elevation ~= nil then
        DATA.race_set_minimum_comfortable_elevation(id, data.minimum_comfortable_elevation)
    end
    DATA.race_set_female_body_size(id, data.female_body_size)
    DATA.race_set_male_body_size(id, data.male_body_size)
    for i, value in ipairs(data.female_efficiency) do
        DATA.race_set_female_efficiency(id, i - 1, value)
    end
    for i, value in ipairs(data.male_efficiency) do
        DATA.race_set_male_efficiency(id, i - 1, value)
    end
    DATA.race_set_female_infrastructure_needs(id, data.female_infrastructure_needs)
    DATA.race_set_male_infrastructure_needs(id, data.male_infrastructure_needs)
    if data.requires_large_river ~= nil then
        DATA.race_set_requires_large_river(id, data.requires_large_river)
    end
    if data.requires_large_forest ~= nil then
        DATA.race_set_requires_large_forest(id, data.requires_large_forest)
    end
end

ffi.cdef[[
    typedef struct {
        float r;
        float g;
        float b;
        float carrying_capacity_weight;
        float fecundity;
        float spotting;
        float visibility;
        float males_per_hundred_females;
        float child_age;
        float teen_age;
        float adult_age;
        float middle_age;
        float elder_age;
        float max_age;
        float minimum_comfortable_temperature;
        float minimum_absolute_temperature;
        float minimum_comfortable_elevation;
        float female_body_size;
        float male_body_size;
        float female_efficiency[10];
        float male_efficiency[10];
        float female_infrastructure_needs;
        float male_infrastructure_needs;
        need_definition female_needs[20];
        need_definition male_needs[20];
        bool requires_large_river;
        bool requires_large_forest;
    } race;
int32_t dcon_create_race();
void dcon_race_resize(uint32_t sz);
]]

---race: FFI arrays---
---@type (string)[]
DATA.race_name= {}
---@type (string)[]
DATA.race_icon= {}
---@type (nil|PortraitSet)[]
DATA.race_female_portrait= {}
---@type (nil|PortraitSet)[]
DATA.race_male_portrait= {}
---@type (string)[]
DATA.race_description= {}
---@type nil
DATA.race_calloc = ffi.C.calloc(1, ffi.sizeof("race") * 16)
---@type table<race_id, struct_race>
DATA.race = ffi.cast("race*", DATA.race_calloc)

---race: LUA bindings---

DATA.race_size = 15
---@type table<race_id, boolean>
local race_indices_pool = ffi.new("bool[?]", 15)
for i = 1, 14 do
    race_indices_pool[i] = true 
end
---@type table<race_id, race_id>
DATA.race_indices_set = {}
function DATA.create_race()
    ---@type number
    local i = DCON.dcon_create_race() + 1
            DATA.race_indices_set[i] = i
    return i
end
---@param func fun(item: race_id) 
function DATA.for_each_race(func)
    for _, item in pairs(DATA.race_indices_set) do
        func(item)
    end
end
---@param func fun(item: race_id):boolean 
---@return table<race_id, race_id> 
function DATA.filter_race(func)
    ---@type table<race_id, race_id> 
    local t = {}
    for _, item in pairs(DATA.race_indices_set) do
        if func(item) then t[item] = item end
    end
    return t
end

---@param race_id race_id valid race id
---@return string name 
function DATA.race_get_name(race_id)
    return DATA.race_name[race_id]
end
---@param race_id race_id valid race id
---@param value string valid string
function DATA.race_set_name(race_id, value)
    DATA.race_name[race_id] = value
end
---@param race_id race_id valid race id
---@return string icon 
function DATA.race_get_icon(race_id)
    return DATA.race_icon[race_id]
end
---@param race_id race_id valid race id
---@param value string valid string
function DATA.race_set_icon(race_id, value)
    DATA.race_icon[race_id] = value
end
---@param race_id race_id valid race id
---@return nil|PortraitSet female_portrait 
function DATA.race_get_female_portrait(race_id)
    return DATA.race_female_portrait[race_id]
end
---@param race_id race_id valid race id
---@param value nil|PortraitSet valid nil|PortraitSet
function DATA.race_set_female_portrait(race_id, value)
    DATA.race_female_portrait[race_id] = value
end
---@param race_id race_id valid race id
---@return nil|PortraitSet male_portrait 
function DATA.race_get_male_portrait(race_id)
    return DATA.race_male_portrait[race_id]
end
---@param race_id race_id valid race id
---@param value nil|PortraitSet valid nil|PortraitSet
function DATA.race_set_male_portrait(race_id, value)
    DATA.race_male_portrait[race_id] = value
end
---@param race_id race_id valid race id
---@return string description 
function DATA.race_get_description(race_id)
    return DATA.race_description[race_id]
end
---@param race_id race_id valid race id
---@param value string valid string
function DATA.race_set_description(race_id, value)
    DATA.race_description[race_id] = value
end
---@param race_id race_id valid race id
---@return number r 
function DATA.race_get_r(race_id)
    return DATA.race[race_id].r
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_r(race_id, value)
    DATA.race[race_id].r = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_r(race_id, value)
    DATA.race[race_id].r = DATA.race[race_id].r + value
end
---@param race_id race_id valid race id
---@return number g 
function DATA.race_get_g(race_id)
    return DATA.race[race_id].g
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_g(race_id, value)
    DATA.race[race_id].g = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_g(race_id, value)
    DATA.race[race_id].g = DATA.race[race_id].g + value
end
---@param race_id race_id valid race id
---@return number b 
function DATA.race_get_b(race_id)
    return DATA.race[race_id].b
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_b(race_id, value)
    DATA.race[race_id].b = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_b(race_id, value)
    DATA.race[race_id].b = DATA.race[race_id].b + value
end
---@param race_id race_id valid race id
---@return number carrying_capacity_weight 
function DATA.race_get_carrying_capacity_weight(race_id)
    return DATA.race[race_id].carrying_capacity_weight
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_carrying_capacity_weight(race_id, value)
    DATA.race[race_id].carrying_capacity_weight = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_carrying_capacity_weight(race_id, value)
    DATA.race[race_id].carrying_capacity_weight = DATA.race[race_id].carrying_capacity_weight + value
end
---@param race_id race_id valid race id
---@return number fecundity 
function DATA.race_get_fecundity(race_id)
    return DATA.race[race_id].fecundity
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_fecundity(race_id, value)
    DATA.race[race_id].fecundity = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_fecundity(race_id, value)
    DATA.race[race_id].fecundity = DATA.race[race_id].fecundity + value
end
---@param race_id race_id valid race id
---@return number spotting How good is this unit at scouting
function DATA.race_get_spotting(race_id)
    return DATA.race[race_id].spotting
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_spotting(race_id, value)
    DATA.race[race_id].spotting = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_spotting(race_id, value)
    DATA.race[race_id].spotting = DATA.race[race_id].spotting + value
end
---@param race_id race_id valid race id
---@return number visibility How visible is this unit in battles
function DATA.race_get_visibility(race_id)
    return DATA.race[race_id].visibility
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_visibility(race_id, value)
    DATA.race[race_id].visibility = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_visibility(race_id, value)
    DATA.race[race_id].visibility = DATA.race[race_id].visibility + value
end
---@param race_id race_id valid race id
---@return number males_per_hundred_females 
function DATA.race_get_males_per_hundred_females(race_id)
    return DATA.race[race_id].males_per_hundred_females
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_males_per_hundred_females(race_id, value)
    DATA.race[race_id].males_per_hundred_females = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_males_per_hundred_females(race_id, value)
    DATA.race[race_id].males_per_hundred_females = DATA.race[race_id].males_per_hundred_females + value
end
---@param race_id race_id valid race id
---@return number child_age 
function DATA.race_get_child_age(race_id)
    return DATA.race[race_id].child_age
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_child_age(race_id, value)
    DATA.race[race_id].child_age = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_child_age(race_id, value)
    DATA.race[race_id].child_age = DATA.race[race_id].child_age + value
end
---@param race_id race_id valid race id
---@return number teen_age 
function DATA.race_get_teen_age(race_id)
    return DATA.race[race_id].teen_age
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_teen_age(race_id, value)
    DATA.race[race_id].teen_age = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_teen_age(race_id, value)
    DATA.race[race_id].teen_age = DATA.race[race_id].teen_age + value
end
---@param race_id race_id valid race id
---@return number adult_age 
function DATA.race_get_adult_age(race_id)
    return DATA.race[race_id].adult_age
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_adult_age(race_id, value)
    DATA.race[race_id].adult_age = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_adult_age(race_id, value)
    DATA.race[race_id].adult_age = DATA.race[race_id].adult_age + value
end
---@param race_id race_id valid race id
---@return number middle_age 
function DATA.race_get_middle_age(race_id)
    return DATA.race[race_id].middle_age
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_middle_age(race_id, value)
    DATA.race[race_id].middle_age = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_middle_age(race_id, value)
    DATA.race[race_id].middle_age = DATA.race[race_id].middle_age + value
end
---@param race_id race_id valid race id
---@return number elder_age 
function DATA.race_get_elder_age(race_id)
    return DATA.race[race_id].elder_age
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_elder_age(race_id, value)
    DATA.race[race_id].elder_age = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_elder_age(race_id, value)
    DATA.race[race_id].elder_age = DATA.race[race_id].elder_age + value
end
---@param race_id race_id valid race id
---@return number max_age 
function DATA.race_get_max_age(race_id)
    return DATA.race[race_id].max_age
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_max_age(race_id, value)
    DATA.race[race_id].max_age = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_max_age(race_id, value)
    DATA.race[race_id].max_age = DATA.race[race_id].max_age + value
end
---@param race_id race_id valid race id
---@return number minimum_comfortable_temperature 
function DATA.race_get_minimum_comfortable_temperature(race_id)
    return DATA.race[race_id].minimum_comfortable_temperature
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_minimum_comfortable_temperature(race_id, value)
    DATA.race[race_id].minimum_comfortable_temperature = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_minimum_comfortable_temperature(race_id, value)
    DATA.race[race_id].minimum_comfortable_temperature = DATA.race[race_id].minimum_comfortable_temperature + value
end
---@param race_id race_id valid race id
---@return number minimum_absolute_temperature 
function DATA.race_get_minimum_absolute_temperature(race_id)
    return DATA.race[race_id].minimum_absolute_temperature
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_minimum_absolute_temperature(race_id, value)
    DATA.race[race_id].minimum_absolute_temperature = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_minimum_absolute_temperature(race_id, value)
    DATA.race[race_id].minimum_absolute_temperature = DATA.race[race_id].minimum_absolute_temperature + value
end
---@param race_id race_id valid race id
---@return number minimum_comfortable_elevation 
function DATA.race_get_minimum_comfortable_elevation(race_id)
    return DATA.race[race_id].minimum_comfortable_elevation
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_minimum_comfortable_elevation(race_id, value)
    DATA.race[race_id].minimum_comfortable_elevation = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_minimum_comfortable_elevation(race_id, value)
    DATA.race[race_id].minimum_comfortable_elevation = DATA.race[race_id].minimum_comfortable_elevation + value
end
---@param race_id race_id valid race id
---@return number female_body_size 
function DATA.race_get_female_body_size(race_id)
    return DATA.race[race_id].female_body_size
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_female_body_size(race_id, value)
    DATA.race[race_id].female_body_size = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_female_body_size(race_id, value)
    DATA.race[race_id].female_body_size = DATA.race[race_id].female_body_size + value
end
---@param race_id race_id valid race id
---@return number male_body_size 
function DATA.race_get_male_body_size(race_id)
    return DATA.race[race_id].male_body_size
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_male_body_size(race_id, value)
    DATA.race[race_id].male_body_size = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_male_body_size(race_id, value)
    DATA.race[race_id].male_body_size = DATA.race[race_id].male_body_size + value
end
---@param race_id race_id valid race id
---@param index JOBTYPE valid
---@return number female_efficiency 
function DATA.race_get_female_efficiency(race_id, index)
    return DATA.race[race_id].female_efficiency[index]
end
---@param race_id race_id valid race id
---@param index JOBTYPE valid index
---@param value number valid number
function DATA.race_set_female_efficiency(race_id, index, value)
    DATA.race[race_id].female_efficiency[index] = value
end
---@param race_id race_id valid race id
---@param index JOBTYPE valid index
---@param value number valid number
function DATA.race_inc_female_efficiency(race_id, index, value)
    DATA.race[race_id].female_efficiency[index] = DATA.race[race_id].female_efficiency[index] + value
end
---@param race_id race_id valid race id
---@param index JOBTYPE valid
---@return number male_efficiency 
function DATA.race_get_male_efficiency(race_id, index)
    return DATA.race[race_id].male_efficiency[index]
end
---@param race_id race_id valid race id
---@param index JOBTYPE valid index
---@param value number valid number
function DATA.race_set_male_efficiency(race_id, index, value)
    DATA.race[race_id].male_efficiency[index] = value
end
---@param race_id race_id valid race id
---@param index JOBTYPE valid index
---@param value number valid number
function DATA.race_inc_male_efficiency(race_id, index, value)
    DATA.race[race_id].male_efficiency[index] = DATA.race[race_id].male_efficiency[index] + value
end
---@param race_id race_id valid race id
---@return number female_infrastructure_needs 
function DATA.race_get_female_infrastructure_needs(race_id)
    return DATA.race[race_id].female_infrastructure_needs
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_female_infrastructure_needs(race_id, value)
    DATA.race[race_id].female_infrastructure_needs = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_female_infrastructure_needs(race_id, value)
    DATA.race[race_id].female_infrastructure_needs = DATA.race[race_id].female_infrastructure_needs + value
end
---@param race_id race_id valid race id
---@return number male_infrastructure_needs 
function DATA.race_get_male_infrastructure_needs(race_id)
    return DATA.race[race_id].male_infrastructure_needs
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_set_male_infrastructure_needs(race_id, value)
    DATA.race[race_id].male_infrastructure_needs = value
end
---@param race_id race_id valid race id
---@param value number valid number
function DATA.race_inc_male_infrastructure_needs(race_id, value)
    DATA.race[race_id].male_infrastructure_needs = DATA.race[race_id].male_infrastructure_needs + value
end
---@param race_id race_id valid race id
---@param index number valid
---@return NEED female_needs 
function DATA.race_get_female_needs_need(race_id, index)
    return DATA.race[race_id].female_needs[index].need
end
---@param race_id race_id valid race id
---@param index number valid
---@return use_case_id female_needs 
function DATA.race_get_female_needs_use_case(race_id, index)
    return DATA.race[race_id].female_needs[index].use_case
end
---@param race_id race_id valid race id
---@param index number valid
---@return number female_needs 
function DATA.race_get_female_needs_required(race_id, index)
    return DATA.race[race_id].female_needs[index].required
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value NEED valid NEED
function DATA.race_set_female_needs_need(race_id, index, value)
    DATA.race[race_id].female_needs[index].need = value
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value use_case_id valid use_case_id
function DATA.race_set_female_needs_use_case(race_id, index, value)
    DATA.race[race_id].female_needs[index].use_case = value
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value number valid number
function DATA.race_set_female_needs_required(race_id, index, value)
    DATA.race[race_id].female_needs[index].required = value
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value number valid number
function DATA.race_inc_female_needs_required(race_id, index, value)
    DATA.race[race_id].female_needs[index].required = DATA.race[race_id].female_needs[index].required + value
end
---@param race_id race_id valid race id
---@param index number valid
---@return NEED male_needs 
function DATA.race_get_male_needs_need(race_id, index)
    return DATA.race[race_id].male_needs[index].need
end
---@param race_id race_id valid race id
---@param index number valid
---@return use_case_id male_needs 
function DATA.race_get_male_needs_use_case(race_id, index)
    return DATA.race[race_id].male_needs[index].use_case
end
---@param race_id race_id valid race id
---@param index number valid
---@return number male_needs 
function DATA.race_get_male_needs_required(race_id, index)
    return DATA.race[race_id].male_needs[index].required
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value NEED valid NEED
function DATA.race_set_male_needs_need(race_id, index, value)
    DATA.race[race_id].male_needs[index].need = value
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value use_case_id valid use_case_id
function DATA.race_set_male_needs_use_case(race_id, index, value)
    DATA.race[race_id].male_needs[index].use_case = value
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value number valid number
function DATA.race_set_male_needs_required(race_id, index, value)
    DATA.race[race_id].male_needs[index].required = value
end
---@param race_id race_id valid race id
---@param index number valid index
---@param value number valid number
function DATA.race_inc_male_needs_required(race_id, index, value)
    DATA.race[race_id].male_needs[index].required = DATA.race[race_id].male_needs[index].required + value
end
---@param race_id race_id valid race id
---@return boolean requires_large_river 
function DATA.race_get_requires_large_river(race_id)
    return DATA.race[race_id].requires_large_river
end
---@param race_id race_id valid race id
---@param value boolean valid boolean
function DATA.race_set_requires_large_river(race_id, value)
    DATA.race[race_id].requires_large_river = value
end
---@param race_id race_id valid race id
---@return boolean requires_large_forest 
function DATA.race_get_requires_large_forest(race_id)
    return DATA.race[race_id].requires_large_forest
end
---@param race_id race_id valid race id
---@param value boolean valid boolean
function DATA.race_set_requires_large_forest(race_id, value)
    DATA.race[race_id].requires_large_forest = value
end


local fat_race_id_metatable = {
    __index = function (t,k)
        if (k == "name") then return DATA.race_get_name(t.id) end
        if (k == "icon") then return DATA.race_get_icon(t.id) end
        if (k == "female_portrait") then return DATA.race_get_female_portrait(t.id) end
        if (k == "male_portrait") then return DATA.race_get_male_portrait(t.id) end
        if (k == "description") then return DATA.race_get_description(t.id) end
        if (k == "r") then return DATA.race_get_r(t.id) end
        if (k == "g") then return DATA.race_get_g(t.id) end
        if (k == "b") then return DATA.race_get_b(t.id) end
        if (k == "carrying_capacity_weight") then return DATA.race_get_carrying_capacity_weight(t.id) end
        if (k == "fecundity") then return DATA.race_get_fecundity(t.id) end
        if (k == "spotting") then return DATA.race_get_spotting(t.id) end
        if (k == "visibility") then return DATA.race_get_visibility(t.id) end
        if (k == "males_per_hundred_females") then return DATA.race_get_males_per_hundred_females(t.id) end
        if (k == "child_age") then return DATA.race_get_child_age(t.id) end
        if (k == "teen_age") then return DATA.race_get_teen_age(t.id) end
        if (k == "adult_age") then return DATA.race_get_adult_age(t.id) end
        if (k == "middle_age") then return DATA.race_get_middle_age(t.id) end
        if (k == "elder_age") then return DATA.race_get_elder_age(t.id) end
        if (k == "max_age") then return DATA.race_get_max_age(t.id) end
        if (k == "minimum_comfortable_temperature") then return DATA.race_get_minimum_comfortable_temperature(t.id) end
        if (k == "minimum_absolute_temperature") then return DATA.race_get_minimum_absolute_temperature(t.id) end
        if (k == "minimum_comfortable_elevation") then return DATA.race_get_minimum_comfortable_elevation(t.id) end
        if (k == "female_body_size") then return DATA.race_get_female_body_size(t.id) end
        if (k == "male_body_size") then return DATA.race_get_male_body_size(t.id) end
        if (k == "female_infrastructure_needs") then return DATA.race_get_female_infrastructure_needs(t.id) end
        if (k == "male_infrastructure_needs") then return DATA.race_get_male_infrastructure_needs(t.id) end
        if (k == "requires_large_river") then return DATA.race_get_requires_large_river(t.id) end
        if (k == "requires_large_forest") then return DATA.race_get_requires_large_forest(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "name") then
            DATA.race_set_name(t.id, v)
            return
        end
        if (k == "icon") then
            DATA.race_set_icon(t.id, v)
            return
        end
        if (k == "female_portrait") then
            DATA.race_set_female_portrait(t.id, v)
            return
        end
        if (k == "male_portrait") then
            DATA.race_set_male_portrait(t.id, v)
            return
        end
        if (k == "description") then
            DATA.race_set_description(t.id, v)
            return
        end
        if (k == "r") then
            DATA.race_set_r(t.id, v)
            return
        end
        if (k == "g") then
            DATA.race_set_g(t.id, v)
            return
        end
        if (k == "b") then
            DATA.race_set_b(t.id, v)
            return
        end
        if (k == "carrying_capacity_weight") then
            DATA.race_set_carrying_capacity_weight(t.id, v)
            return
        end
        if (k == "fecundity") then
            DATA.race_set_fecundity(t.id, v)
            return
        end
        if (k == "spotting") then
            DATA.race_set_spotting(t.id, v)
            return
        end
        if (k == "visibility") then
            DATA.race_set_visibility(t.id, v)
            return
        end
        if (k == "males_per_hundred_females") then
            DATA.race_set_males_per_hundred_females(t.id, v)
            return
        end
        if (k == "child_age") then
            DATA.race_set_child_age(t.id, v)
            return
        end
        if (k == "teen_age") then
            DATA.race_set_teen_age(t.id, v)
            return
        end
        if (k == "adult_age") then
            DATA.race_set_adult_age(t.id, v)
            return
        end
        if (k == "middle_age") then
            DATA.race_set_middle_age(t.id, v)
            return
        end
        if (k == "elder_age") then
            DATA.race_set_elder_age(t.id, v)
            return
        end
        if (k == "max_age") then
            DATA.race_set_max_age(t.id, v)
            return
        end
        if (k == "minimum_comfortable_temperature") then
            DATA.race_set_minimum_comfortable_temperature(t.id, v)
            return
        end
        if (k == "minimum_absolute_temperature") then
            DATA.race_set_minimum_absolute_temperature(t.id, v)
            return
        end
        if (k == "minimum_comfortable_elevation") then
            DATA.race_set_minimum_comfortable_elevation(t.id, v)
            return
        end
        if (k == "female_body_size") then
            DATA.race_set_female_body_size(t.id, v)
            return
        end
        if (k == "male_body_size") then
            DATA.race_set_male_body_size(t.id, v)
            return
        end
        if (k == "female_infrastructure_needs") then
            DATA.race_set_female_infrastructure_needs(t.id, v)
            return
        end
        if (k == "male_infrastructure_needs") then
            DATA.race_set_male_infrastructure_needs(t.id, v)
            return
        end
        if (k == "requires_large_river") then
            DATA.race_set_requires_large_river(t.id, v)
            return
        end
        if (k == "requires_large_forest") then
            DATA.race_set_requires_large_forest(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id race_id
---@return fat_race_id fat_id
function DATA.fatten_race(id)
    local result = {id = id}
    setmetatable(result, fat_race_id_metatable)    return result
end


function DATA.save_state()
    local current_offset = 0
    local current_shift = 0
    local total_ffi_size = 0
    total_ffi_size = total_ffi_size + ffi.sizeof("tile") * 1500000
    total_ffi_size = total_ffi_size + ffi.sizeof("pop") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("province") * 20000
    total_ffi_size = total_ffi_size + ffi.sizeof("army") * 5000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband") * 20000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("negotiation") * 2500
    total_ffi_size = total_ffi_size + ffi.sizeof("building") * 200000
    total_ffi_size = total_ffi_size + ffi.sizeof("ownership") * 200000
    total_ffi_size = total_ffi_size + ffi.sizeof("employment") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("building_location") * 200000
    total_ffi_size = total_ffi_size + ffi.sizeof("army_membership") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_leader") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_recruiter") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_commander") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_location") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_unit") * 50000
    total_ffi_size = total_ffi_size + ffi.sizeof("character_location") * 100000
    total_ffi_size = total_ffi_size + ffi.sizeof("home") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("pop_location") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("outlaw_location") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("tile_province_membership") * 1500000
    total_ffi_size = total_ffi_size + ffi.sizeof("province_neighborhood") * 250000
    total_ffi_size = total_ffi_size + ffi.sizeof("parent_child_relation") * 900000
    total_ffi_size = total_ffi_size + ffi.sizeof("loyalty") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("succession") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_armies") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_guard") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_overseer") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_leadership") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_subject_relation") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("tax_collector") * 45000
    total_ffi_size = total_ffi_size + ffi.sizeof("personal_rights") * 450000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_provinces") * 30000
    total_ffi_size = total_ffi_size + ffi.sizeof("popularity") * 450000
    local current_buffer = ffi.new("uint8_t[?]", total_ffi_size)
    current_shift = ffi.sizeof("tile") * 1500000
    ffi.copy(current_buffer + current_offset, DATA.tile, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("pop") * 300000
    ffi.copy(current_buffer + current_offset, DATA.pop, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("province") * 20000
    ffi.copy(current_buffer + current_offset, DATA.province, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("army") * 5000
    ffi.copy(current_buffer + current_offset, DATA.army, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband") * 20000
    ffi.copy(current_buffer + current_offset, DATA.warband, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm") * 15000
    ffi.copy(current_buffer + current_offset, DATA.realm, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("negotiation") * 2500
    ffi.copy(current_buffer + current_offset, DATA.negotiation, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("building") * 200000
    ffi.copy(current_buffer + current_offset, DATA.building, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("ownership") * 200000
    ffi.copy(current_buffer + current_offset, DATA.ownership, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("employment") * 300000
    ffi.copy(current_buffer + current_offset, DATA.employment, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("building_location") * 200000
    ffi.copy(current_buffer + current_offset, DATA.building_location, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("army_membership") * 10000
    ffi.copy(current_buffer + current_offset, DATA.army_membership, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_leader") * 10000
    ffi.copy(current_buffer + current_offset, DATA.warband_leader, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_recruiter") * 10000
    ffi.copy(current_buffer + current_offset, DATA.warband_recruiter, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_commander") * 10000
    ffi.copy(current_buffer + current_offset, DATA.warband_commander, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_location") * 10000
    ffi.copy(current_buffer + current_offset, DATA.warband_location, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_unit") * 50000
    ffi.copy(current_buffer + current_offset, DATA.warband_unit, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("character_location") * 100000
    ffi.copy(current_buffer + current_offset, DATA.character_location, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("home") * 300000
    ffi.copy(current_buffer + current_offset, DATA.home, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("pop_location") * 300000
    ffi.copy(current_buffer + current_offset, DATA.pop_location, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("outlaw_location") * 300000
    ffi.copy(current_buffer + current_offset, DATA.outlaw_location, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("tile_province_membership") * 1500000
    ffi.copy(current_buffer + current_offset, DATA.tile_province_membership, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("province_neighborhood") * 250000
    ffi.copy(current_buffer + current_offset, DATA.province_neighborhood, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("parent_child_relation") * 900000
    ffi.copy(current_buffer + current_offset, DATA.parent_child_relation, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("loyalty") * 10000
    ffi.copy(current_buffer + current_offset, DATA.loyalty, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("succession") * 10000
    ffi.copy(current_buffer + current_offset, DATA.succession, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_armies") * 15000
    ffi.copy(current_buffer + current_offset, DATA.realm_armies, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_guard") * 15000
    ffi.copy(current_buffer + current_offset, DATA.realm_guard, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_overseer") * 15000
    ffi.copy(current_buffer + current_offset, DATA.realm_overseer, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_leadership") * 15000
    ffi.copy(current_buffer + current_offset, DATA.realm_leadership, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_subject_relation") * 15000
    ffi.copy(current_buffer + current_offset, DATA.realm_subject_relation, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("tax_collector") * 45000
    ffi.copy(current_buffer + current_offset, DATA.tax_collector, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("personal_rights") * 450000
    ffi.copy(current_buffer + current_offset, DATA.personal_rights, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_provinces") * 30000
    ffi.copy(current_buffer + current_offset, DATA.realm_provinces, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("popularity") * 450000
    ffi.copy(current_buffer + current_offset, DATA.popularity, current_shift)
    current_offset = current_offset + current_shift
    assert(love.filesystem.write("gamestatesave.binbeaver", ffi.string(current_buffer, total_ffi_size)))
end
function DATA.load_state()
    local data_love, error = love.filesystem.newFileData("gamestatesave.binbeaver")
    assert(data_love, error)
    local data = ffi.cast("uint8_t*", data_love:getPointer())
    local current_offset = 0
    local current_shift = 0
    local total_ffi_size = 0
    total_ffi_size = total_ffi_size + ffi.sizeof("tile") * 1500000
    total_ffi_size = total_ffi_size + ffi.sizeof("pop") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("province") * 20000
    total_ffi_size = total_ffi_size + ffi.sizeof("army") * 5000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband") * 20000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("negotiation") * 2500
    total_ffi_size = total_ffi_size + ffi.sizeof("building") * 200000
    total_ffi_size = total_ffi_size + ffi.sizeof("ownership") * 200000
    total_ffi_size = total_ffi_size + ffi.sizeof("employment") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("building_location") * 200000
    total_ffi_size = total_ffi_size + ffi.sizeof("army_membership") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_leader") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_recruiter") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_commander") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_location") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("warband_unit") * 50000
    total_ffi_size = total_ffi_size + ffi.sizeof("character_location") * 100000
    total_ffi_size = total_ffi_size + ffi.sizeof("home") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("pop_location") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("outlaw_location") * 300000
    total_ffi_size = total_ffi_size + ffi.sizeof("tile_province_membership") * 1500000
    total_ffi_size = total_ffi_size + ffi.sizeof("province_neighborhood") * 250000
    total_ffi_size = total_ffi_size + ffi.sizeof("parent_child_relation") * 900000
    total_ffi_size = total_ffi_size + ffi.sizeof("loyalty") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("succession") * 10000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_armies") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_guard") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_overseer") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_leadership") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_subject_relation") * 15000
    total_ffi_size = total_ffi_size + ffi.sizeof("tax_collector") * 45000
    total_ffi_size = total_ffi_size + ffi.sizeof("personal_rights") * 450000
    total_ffi_size = total_ffi_size + ffi.sizeof("realm_provinces") * 30000
    total_ffi_size = total_ffi_size + ffi.sizeof("popularity") * 450000
    current_shift = ffi.sizeof("tile") * 1500000
    ffi.copy(DATA.tile, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("pop") * 300000
    ffi.copy(DATA.pop, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("province") * 20000
    ffi.copy(DATA.province, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("army") * 5000
    ffi.copy(DATA.army, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband") * 20000
    ffi.copy(DATA.warband, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm") * 15000
    ffi.copy(DATA.realm, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("negotiation") * 2500
    ffi.copy(DATA.negotiation, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("building") * 200000
    ffi.copy(DATA.building, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("ownership") * 200000
    ffi.copy(DATA.ownership, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("employment") * 300000
    ffi.copy(DATA.employment, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("building_location") * 200000
    ffi.copy(DATA.building_location, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("army_membership") * 10000
    ffi.copy(DATA.army_membership, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_leader") * 10000
    ffi.copy(DATA.warband_leader, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_recruiter") * 10000
    ffi.copy(DATA.warband_recruiter, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_commander") * 10000
    ffi.copy(DATA.warband_commander, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_location") * 10000
    ffi.copy(DATA.warband_location, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("warband_unit") * 50000
    ffi.copy(DATA.warband_unit, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("character_location") * 100000
    ffi.copy(DATA.character_location, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("home") * 300000
    ffi.copy(DATA.home, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("pop_location") * 300000
    ffi.copy(DATA.pop_location, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("outlaw_location") * 300000
    ffi.copy(DATA.outlaw_location, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("tile_province_membership") * 1500000
    ffi.copy(DATA.tile_province_membership, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("province_neighborhood") * 250000
    ffi.copy(DATA.province_neighborhood, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("parent_child_relation") * 900000
    ffi.copy(DATA.parent_child_relation, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("loyalty") * 10000
    ffi.copy(DATA.loyalty, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("succession") * 10000
    ffi.copy(DATA.succession, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_armies") * 15000
    ffi.copy(DATA.realm_armies, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_guard") * 15000
    ffi.copy(DATA.realm_guard, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_overseer") * 15000
    ffi.copy(DATA.realm_overseer, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_leadership") * 15000
    ffi.copy(DATA.realm_leadership, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_subject_relation") * 15000
    ffi.copy(DATA.realm_subject_relation, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("tax_collector") * 45000
    ffi.copy(DATA.tax_collector, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("personal_rights") * 450000
    ffi.copy(DATA.personal_rights, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("realm_provinces") * 30000
    ffi.copy(DATA.realm_provinces, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
    current_shift = ffi.sizeof("popularity") * 450000
    ffi.copy(DATA.popularity, data + current_offset, current_shift)
    current_offset = current_offset + current_shift
end
function DATA.test_save_load_0()
    print("tile world_id")
    for i = 0, 1500000 do
        DATA.tile[i].world_id = 12
    end
    print("tile is_land")
    for i = 0, 1500000 do
        DATA.tile[i].is_land = false
    end
    print("tile is_fresh")
    for i = 0, 1500000 do
        DATA.tile[i].is_fresh = true
    end
    print("tile elevation")
    for i = 0, 1500000 do
        DATA.tile[i].elevation = -4
    end
    print("tile grass")
    for i = 0, 1500000 do
        DATA.tile[i].grass = 12
    end
    print("tile shrub")
    for i = 0, 1500000 do
        DATA.tile[i].shrub = 11
    end
    print("tile conifer")
    for i = 0, 1500000 do
        DATA.tile[i].conifer = 5
    end
    print("tile broadleaf")
    for i = 0, 1500000 do
        DATA.tile[i].broadleaf = -1
    end
    print("tile ideal_grass")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_grass = 10
    end
    print("tile ideal_shrub")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_shrub = 2
    end
    print("tile ideal_conifer")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_conifer = 17
    end
    print("tile ideal_broadleaf")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_broadleaf = -7
    end
    print("tile silt")
    for i = 0, 1500000 do
        DATA.tile[i].silt = 12
    end
    print("tile clay")
    for i = 0, 1500000 do
        DATA.tile[i].clay = -12
    end
    print("tile sand")
    for i = 0, 1500000 do
        DATA.tile[i].sand = -2
    end
    print("tile soil_minerals")
    for i = 0, 1500000 do
        DATA.tile[i].soil_minerals = -12
    end
    print("tile soil_organics")
    for i = 0, 1500000 do
        DATA.tile[i].soil_organics = -14
    end
    print("tile january_waterflow")
    for i = 0, 1500000 do
        DATA.tile[i].january_waterflow = 19
    end
    print("tile july_waterflow")
    for i = 0, 1500000 do
        DATA.tile[i].july_waterflow = -4
    end
    print("tile waterlevel")
    for i = 0, 1500000 do
        DATA.tile[i].waterlevel = 14
    end
    print("tile has_river")
    for i = 0, 1500000 do
        DATA.tile[i].has_river = true
    end
    print("tile has_marsh")
    for i = 0, 1500000 do
        DATA.tile[i].has_marsh = false
    end
    print("tile ice")
    for i = 0, 1500000 do
        DATA.tile[i].ice = -14
    end
    print("tile ice_age_ice")
    for i = 0, 1500000 do
        DATA.tile[i].ice_age_ice = -16
    end
    print("tile debug_r")
    for i = 0, 1500000 do
        DATA.tile[i].debug_r = 1
    end
    print("tile debug_g")
    for i = 0, 1500000 do
        DATA.tile[i].debug_g = 10
    end
    print("tile debug_b")
    for i = 0, 1500000 do
        DATA.tile[i].debug_b = 15
    end
    print("tile real_r")
    for i = 0, 1500000 do
        DATA.tile[i].real_r = -14
    end
    print("tile real_g")
    for i = 0, 1500000 do
        DATA.tile[i].real_g = 2
    end
    print("tile real_b")
    for i = 0, 1500000 do
        DATA.tile[i].real_b = 7
    end
    print("tile pathfinding_index")
    for i = 0, 1500000 do
        DATA.tile[i].pathfinding_index = 10
    end
    print("tile resource")
    for i = 0, 1500000 do
        DATA.tile[i].resource = 19
    end
    print("tile bedrock")
    for i = 0, 1500000 do
        DATA.tile[i].bedrock = 20
    end
    print("tile biome")
    for i = 0, 1500000 do
        DATA.tile[i].biome = 6
    end
    print("pop race")
    for i = 0, 300000 do
        DATA.pop[i].race = 17
    end
    print("pop female")
    for i = 0, 300000 do
        DATA.pop[i].female = false
    end
    print("pop age")
    for i = 0, 300000 do
        DATA.pop[i].age = 14
    end
    print("pop savings")
    for i = 0, 300000 do
        DATA.pop[i].savings = 13
    end
    print("pop parent")
    for i = 0, 300000 do
        DATA.pop[i].parent = 8
    end
    print("pop loyalty")
    for i = 0, 300000 do
        DATA.pop[i].loyalty = 1
    end
    print("pop life_needs_satisfaction")
    for i = 0, 300000 do
        DATA.pop[i].life_needs_satisfaction = 15
    end
    print("pop basic_needs_satisfaction")
    for i = 0, 300000 do
        DATA.pop[i].basic_needs_satisfaction = -20
    end
    print("pop need_satisfaction")
    for i = 0, 300000 do
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].need = 1
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].use_case = 12
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].consumed = 20
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].demanded = -20
    end
    end
    print("pop traits")
    for i = 0, 300000 do
    for j = 0, 9 do
        DATA.pop[i].traits[j] = 9
    end
    end
    print("pop successor")
    for i = 0, 300000 do
        DATA.pop[i].successor = 15
    end
    print("pop inventory")
    for i = 0, 300000 do
    for j = 0, 99 do
        DATA.pop[i].inventory[j] = 1
    end
    end
    print("pop price_memory")
    for i = 0, 300000 do
    for j = 0, 99 do
        DATA.pop[i].price_memory[j] = -5
    end
    end
    print("pop forage_ratio")
    for i = 0, 300000 do
        DATA.pop[i].forage_ratio = 0
    end
    print("pop work_ratio")
    for i = 0, 300000 do
        DATA.pop[i].work_ratio = -16
    end
    print("pop rank")
    for i = 0, 300000 do
        DATA.pop[i].rank = 1
    end
    print("pop dna")
    for i = 0, 300000 do
    for j = 0, 19 do
        DATA.pop[i].dna[j] = 16
    end
    end
    print("province r")
    for i = 0, 20000 do
        DATA.province[i].r = -6
    end
    print("province g")
    for i = 0, 20000 do
        DATA.province[i].g = -5
    end
    print("province b")
    for i = 0, 20000 do
        DATA.province[i].b = -11
    end
    print("province is_land")
    for i = 0, 20000 do
        DATA.province[i].is_land = false
    end
    print("province province_id")
    for i = 0, 20000 do
        DATA.province[i].province_id = -15
    end
    print("province size")
    for i = 0, 20000 do
        DATA.province[i].size = -15
    end
    print("province hydration")
    for i = 0, 20000 do
        DATA.province[i].hydration = 0
    end
    print("province movement_cost")
    for i = 0, 20000 do
        DATA.province[i].movement_cost = 12
    end
    print("province center")
    for i = 0, 20000 do
        DATA.province[i].center = 15
    end
    print("province infrastructure_needed")
    for i = 0, 20000 do
        DATA.province[i].infrastructure_needed = -14
    end
    print("province infrastructure")
    for i = 0, 20000 do
        DATA.province[i].infrastructure = -1
    end
    print("province infrastructure_investment")
    for i = 0, 20000 do
        DATA.province[i].infrastructure_investment = 15
    end
    print("province technologies_present")
    for i = 0, 20000 do
    for j = 0, 399 do
        DATA.province[i].technologies_present[j] = 9
    end
    end
    print("province technologies_researchable")
    for i = 0, 20000 do
    for j = 0, 399 do
        DATA.province[i].technologies_researchable[j] = 3
    end
    end
    print("province buildable_buildings")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].buildable_buildings[j] = 17
    end
    end
    print("province local_production")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_production[j] = 1
    end
    end
    print("province local_consumption")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_consumption[j] = 14
    end
    end
    print("province local_demand")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_demand[j] = -7
    end
    end
    print("province local_storage")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_storage[j] = 18
    end
    end
    print("province local_prices")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_prices[j] = 15
    end
    end
    print("province local_wealth")
    for i = 0, 20000 do
        DATA.province[i].local_wealth = 17
    end
    print("province trade_wealth")
    for i = 0, 20000 do
        DATA.province[i].trade_wealth = -2
    end
    print("province local_income")
    for i = 0, 20000 do
        DATA.province[i].local_income = 8
    end
    print("province local_building_upkeep")
    for i = 0, 20000 do
        DATA.province[i].local_building_upkeep = -15
    end
    print("province foragers")
    for i = 0, 20000 do
        DATA.province[i].foragers = 18
    end
    print("province foragers_water")
    for i = 0, 20000 do
        DATA.province[i].foragers_water = 4
    end
    print("province foragers_limit")
    for i = 0, 20000 do
        DATA.province[i].foragers_limit = 0
    end
    print("province foragers_targets")
    for i = 0, 20000 do
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].output_good = 18
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].output_value = -5
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].amount = -2
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].forage = 2
    end
    end
    print("province local_resources")
    for i = 0, 20000 do
    for j = 0, 24 do
        DATA.province[i].local_resources[j].resource = 6
    end
    for j = 0, 24 do
        DATA.province[i].local_resources[j].location = 5
    end
    end
    print("province mood")
    for i = 0, 20000 do
        DATA.province[i].mood = -18
    end
    print("province unit_types")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.province[i].unit_types[j] = 19
    end
    end
    print("province throughput_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].throughput_boosts[j] = -4
    end
    end
    print("province input_efficiency_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].input_efficiency_boosts[j] = 10
    end
    end
    print("province output_efficiency_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].output_efficiency_boosts[j] = -16
    end
    end
    print("province on_a_river")
    for i = 0, 20000 do
        DATA.province[i].on_a_river = true
    end
    print("province on_a_forest")
    for i = 0, 20000 do
        DATA.province[i].on_a_forest = true
    end
    print("army destination")
    for i = 0, 5000 do
        DATA.army[i].destination = 4
    end
    print("warband units_current")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.warband[i].units_current[j] = -18
    end
    end
    print("warband units_target")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.warband[i].units_target[j] = -15
    end
    end
    print("warband status")
    for i = 0, 20000 do
        DATA.warband[i].status = 8
    end
    print("warband idle_stance")
    for i = 0, 20000 do
        DATA.warband[i].idle_stance = 2
    end
    print("warband current_free_time_ratio")
    for i = 0, 20000 do
        DATA.warband[i].current_free_time_ratio = 5
    end
    print("warband treasury")
    for i = 0, 20000 do
        DATA.warband[i].treasury = 13
    end
    print("warband total_upkeep")
    for i = 0, 20000 do
        DATA.warband[i].total_upkeep = -3
    end
    print("warband predicted_upkeep")
    for i = 0, 20000 do
        DATA.warband[i].predicted_upkeep = 13
    end
    print("warband supplies")
    for i = 0, 20000 do
        DATA.warband[i].supplies = -5
    end
    print("warband supplies_target_days")
    for i = 0, 20000 do
        DATA.warband[i].supplies_target_days = -7
    end
    print("warband morale")
    for i = 0, 20000 do
        DATA.warband[i].morale = 17
    end
    print("realm budget_change")
    for i = 0, 15000 do
        DATA.realm[i].budget_change = 6
    end
    print("realm budget_saved_change")
    for i = 0, 15000 do
        DATA.realm[i].budget_saved_change = 17
    end
    print("realm budget_spending_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_spending_by_category[j] = -3
    end
    end
    print("realm budget_income_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_income_by_category[j] = 8
    end
    end
    print("realm budget_treasury_change_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_treasury_change_by_category[j] = 11
    end
    end
    print("realm budget_treasury")
    for i = 0, 15000 do
        DATA.realm[i].budget_treasury = 2
    end
    print("realm budget_treasury_target")
    for i = 0, 15000 do
        DATA.realm[i].budget_treasury_target = -15
    end
    print("realm budget")
    for i = 0, 15000 do
    for j = 0, 6 do
        DATA.realm[i].budget[j].ratio = 0
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].budget = 19
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].to_be_invested = -13
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].target = 11
    end
    end
    print("realm budget_tax_target")
    for i = 0, 15000 do
        DATA.realm[i].budget_tax_target = 17
    end
    print("realm budget_tax_collected_this_year")
    for i = 0, 15000 do
        DATA.realm[i].budget_tax_collected_this_year = 20
    end
    print("realm r")
    for i = 0, 15000 do
        DATA.realm[i].r = 1
    end
    print("realm g")
    for i = 0, 15000 do
        DATA.realm[i].g = -8
    end
    print("realm b")
    for i = 0, 15000 do
        DATA.realm[i].b = -5
    end
    print("realm primary_race")
    for i = 0, 15000 do
        DATA.realm[i].primary_race = 0
    end
    print("realm capitol")
    for i = 0, 15000 do
        DATA.realm[i].capitol = 8
    end
    print("realm trading_right_cost")
    for i = 0, 15000 do
        DATA.realm[i].trading_right_cost = -13
    end
    print("realm building_right_cost")
    for i = 0, 15000 do
        DATA.realm[i].building_right_cost = -6
    end
    print("realm prepare_attack_flag")
    for i = 0, 15000 do
        DATA.realm[i].prepare_attack_flag = false
    end
    print("realm coa_base_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_r = -10
    end
    print("realm coa_base_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_g = 1
    end
    print("realm coa_base_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_b = 7
    end
    print("realm coa_background_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_r = -17
    end
    print("realm coa_background_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_g = -14
    end
    print("realm coa_background_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_b = -11
    end
    print("realm coa_foreground_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_r = -6
    end
    print("realm coa_foreground_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_g = -18
    end
    print("realm coa_foreground_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_b = 16
    end
    print("realm coa_emblem_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_r = 20
    end
    print("realm coa_emblem_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_g = 14
    end
    print("realm coa_emblem_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_b = 18
    end
    print("realm coa_background_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_image = 2
    end
    print("realm coa_foreground_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_image = 0
    end
    print("realm coa_emblem_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_image = 3
    end
    print("realm resources")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].resources[j] = 20
    end
    end
    print("realm production")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].production[j] = -8
    end
    end
    print("realm bought")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].bought[j] = 18
    end
    end
    print("realm sold")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].sold[j] = 16
    end
    end
    print("realm expected_food_consumption")
    for i = 0, 15000 do
        DATA.realm[i].expected_food_consumption = -13
    end
    print("building type")
    for i = 0, 200000 do
        DATA.building[i].type = 12
    end
    print("building spent_on_inputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].spent_on_inputs[j].good = 2
    end
    for j = 0, 7 do
        DATA.building[i].spent_on_inputs[j].amount = 3
    end
    end
    print("building earn_from_outputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].earn_from_outputs[j].good = 3
    end
    for j = 0, 7 do
        DATA.building[i].earn_from_outputs[j].amount = -18
    end
    end
    print("building amount_of_inputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].amount_of_inputs[j].good = 19
    end
    for j = 0, 7 do
        DATA.building[i].amount_of_inputs[j].amount = -19
    end
    end
    print("building amount_of_outputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].amount_of_outputs[j].good = 6
    end
    for j = 0, 7 do
        DATA.building[i].amount_of_outputs[j].amount = -9
    end
    end
    print("employment worker_income")
    for i = 0, 300000 do
        DATA.employment[i].worker_income = -13
    end
    print("employment job")
    for i = 0, 300000 do
        DATA.employment[i].job = 15
    end
    print("warband_unit type")
    for i = 0, 50000 do
        DATA.warband_unit[i].type = 6
    end
    print("realm_subject_relation wealth_transfer")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].wealth_transfer = true
    end
    print("realm_subject_relation goods_transfer")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].goods_transfer = true
    end
    print("realm_subject_relation warriors_contribution")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].warriors_contribution = false
    end
    print("realm_subject_relation protection")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].protection = true
    end
    print("realm_subject_relation local_ruler")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].local_ruler = false
    end
    print("personal_rights can_trade")
    for i = 0, 450000 do
        DATA.personal_rights[i].can_trade = true
    end
    print("personal_rights can_build")
    for i = 0, 450000 do
        DATA.personal_rights[i].can_build = true
    end
    print("popularity value")
    for i = 0, 450000 do
        DATA.popularity[i].value = -16
    end
    DATA.save_state()
    DATA.load_state()
    local test_passed = true
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].world_id == 12
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].is_land == false
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].is_fresh == true
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].elevation == -4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].grass == 12
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].shrub == 11
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].conifer == 5
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].broadleaf == -1
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_grass == 10
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_shrub == 2
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_conifer == 17
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_broadleaf == -7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].silt == 12
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].clay == -12
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].sand == -2
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].soil_minerals == -12
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].soil_organics == -14
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].january_waterflow == 19
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].july_waterflow == -4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].waterlevel == 14
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].has_river == true
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].has_marsh == false
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ice == -14
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ice_age_ice == -16
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_r == 1
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_g == 10
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_b == 15
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_r == -14
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_g == 2
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_b == 7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].pathfinding_index == 10
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].resource == 19
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].bedrock == 20
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].biome == 6
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].race == 17
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].female == false
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].age == 14
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].savings == 13
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].parent == 8
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].loyalty == 1
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].life_needs_satisfaction == 15
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].basic_needs_satisfaction == -20
    end
    for i = 0, 300000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].need == 1
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].use_case == 12
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].consumed == 20
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].demanded == -20
    end
    end
    for i = 0, 300000 do
    for j = 0, 9 do
        test_passed = test_passed and DATA.pop[i].traits[j] == 9
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].successor == 15
    end
    for i = 0, 300000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[i].inventory[j] == 1
    end
    end
    for i = 0, 300000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[i].price_memory[j] == -5
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].forage_ratio == 0
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].work_ratio == -16
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].rank == 1
    end
    for i = 0, 300000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].dna[j] == 16
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].r == -6
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].g == -5
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].b == -11
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].is_land == false
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].province_id == -15
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].size == -15
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].hydration == 0
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].movement_cost == 12
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].center == 15
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure_needed == -14
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure == -1
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure_investment == 15
    end
    for i = 0, 20000 do
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[i].technologies_present[j] == 9
    end
    end
    for i = 0, 20000 do
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[i].technologies_researchable[j] == 3
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].buildable_buildings[j] == 17
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_production[j] == 1
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_consumption[j] == 14
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_demand[j] == -7
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_storage[j] == 18
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_prices[j] == 15
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_wealth == 17
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].trade_wealth == -2
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_income == 8
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_building_upkeep == -15
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers == 18
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers_water == 4
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers_limit == 0
    end
    for i = 0, 20000 do
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].output_good == 18
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].output_value == -5
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].amount == -2
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].forage == 2
    end
    end
    for i = 0, 20000 do
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].local_resources[j].resource == 6
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].local_resources[j].location == 5
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].mood == -18
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.province[i].unit_types[j] == 19
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].throughput_boosts[j] == -4
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].input_efficiency_boosts[j] == 10
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].output_efficiency_boosts[j] == -16
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].on_a_river == true
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].on_a_forest == true
    end
    for i = 0, 5000 do
        test_passed = test_passed and DATA.army[i].destination == 4
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[i].units_current[j] == -18
    end
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[i].units_target[j] == -15
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].status == 8
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].idle_stance == 2
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].current_free_time_ratio == 5
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].treasury == 13
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].total_upkeep == -3
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].predicted_upkeep == 13
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].supplies == -5
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].supplies_target_days == -7
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].morale == 17
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_change == 6
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_saved_change == 17
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_spending_by_category[j] == -3
    end
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_income_by_category[j] == 8
    end
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_treasury_change_by_category[j] == 11
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_treasury == 2
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_treasury_target == -15
    end
    for i = 0, 15000 do
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].ratio == 0
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].budget == 19
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].to_be_invested == -13
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].target == 11
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_tax_target == 17
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_tax_collected_this_year == 20
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].r == 1
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].g == -8
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].b == -5
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].primary_race == 0
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].capitol == 8
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].trading_right_cost == -13
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].building_right_cost == -6
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].prepare_attack_flag == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_r == -10
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_g == 1
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_b == 7
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_r == -17
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_g == -14
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_b == -11
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_r == -6
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_g == -18
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_b == 16
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_r == 20
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_g == 14
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_b == 18
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_image == 2
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_image == 0
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_image == 3
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].resources[j] == 20
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].production[j] == -8
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].bought[j] == 18
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].sold[j] == 16
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].expected_food_consumption == -13
    end
    for i = 0, 200000 do
        test_passed = test_passed and DATA.building[i].type == 12
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].spent_on_inputs[j].good == 2
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].spent_on_inputs[j].amount == 3
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].earn_from_outputs[j].good == 3
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].earn_from_outputs[j].amount == -18
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_inputs[j].good == 19
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_inputs[j].amount == -19
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_outputs[j].good == 6
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_outputs[j].amount == -9
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.employment[i].worker_income == -13
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.employment[i].job == 15
    end
    for i = 0, 50000 do
        test_passed = test_passed and DATA.warband_unit[i].type == 6
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].wealth_transfer == true
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].goods_transfer == true
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].warriors_contribution == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].protection == true
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].local_ruler == false
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.personal_rights[i].can_trade == true
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.personal_rights[i].can_build == true
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.popularity[i].value == -16
    end
    print("SAVE_LOAD_TEST_0:")
    if test_passed then print("PASSED") else print("ERROR") end
end
function DATA.test_set_get_0()
    local id = DATA.create_tile()
    local fat_id = DATA.fatten_tile(id)
    fat_id.world_id = 12
    fat_id.is_land = false
    fat_id.is_fresh = true
    fat_id.elevation = -4
    fat_id.grass = 12
    fat_id.shrub = 11
    fat_id.conifer = 5
    fat_id.broadleaf = -1
    fat_id.ideal_grass = 10
    fat_id.ideal_shrub = 2
    fat_id.ideal_conifer = 17
    fat_id.ideal_broadleaf = -7
    fat_id.silt = 12
    fat_id.clay = -12
    fat_id.sand = -2
    fat_id.soil_minerals = -12
    fat_id.soil_organics = -14
    fat_id.january_waterflow = 19
    fat_id.july_waterflow = -4
    fat_id.waterlevel = 14
    fat_id.has_river = true
    fat_id.has_marsh = false
    fat_id.ice = -14
    fat_id.ice_age_ice = -16
    fat_id.debug_r = 1
    fat_id.debug_g = 10
    fat_id.debug_b = 15
    fat_id.real_r = -14
    fat_id.real_g = 2
    fat_id.real_b = 7
    fat_id.pathfinding_index = 10
    fat_id.resource = 19
    fat_id.bedrock = 20
    fat_id.biome = 6
    local test_passed = true
    test_passed = test_passed and fat_id.world_id == 12
    if not test_passed then print("world_id", 12, fat_id.world_id) end
    test_passed = test_passed and fat_id.is_land == false
    if not test_passed then print("is_land", false, fat_id.is_land) end
    test_passed = test_passed and fat_id.is_fresh == true
    if not test_passed then print("is_fresh", true, fat_id.is_fresh) end
    test_passed = test_passed and fat_id.elevation == -4
    if not test_passed then print("elevation", -4, fat_id.elevation) end
    test_passed = test_passed and fat_id.grass == 12
    if not test_passed then print("grass", 12, fat_id.grass) end
    test_passed = test_passed and fat_id.shrub == 11
    if not test_passed then print("shrub", 11, fat_id.shrub) end
    test_passed = test_passed and fat_id.conifer == 5
    if not test_passed then print("conifer", 5, fat_id.conifer) end
    test_passed = test_passed and fat_id.broadleaf == -1
    if not test_passed then print("broadleaf", -1, fat_id.broadleaf) end
    test_passed = test_passed and fat_id.ideal_grass == 10
    if not test_passed then print("ideal_grass", 10, fat_id.ideal_grass) end
    test_passed = test_passed and fat_id.ideal_shrub == 2
    if not test_passed then print("ideal_shrub", 2, fat_id.ideal_shrub) end
    test_passed = test_passed and fat_id.ideal_conifer == 17
    if not test_passed then print("ideal_conifer", 17, fat_id.ideal_conifer) end
    test_passed = test_passed and fat_id.ideal_broadleaf == -7
    if not test_passed then print("ideal_broadleaf", -7, fat_id.ideal_broadleaf) end
    test_passed = test_passed and fat_id.silt == 12
    if not test_passed then print("silt", 12, fat_id.silt) end
    test_passed = test_passed and fat_id.clay == -12
    if not test_passed then print("clay", -12, fat_id.clay) end
    test_passed = test_passed and fat_id.sand == -2
    if not test_passed then print("sand", -2, fat_id.sand) end
    test_passed = test_passed and fat_id.soil_minerals == -12
    if not test_passed then print("soil_minerals", -12, fat_id.soil_minerals) end
    test_passed = test_passed and fat_id.soil_organics == -14
    if not test_passed then print("soil_organics", -14, fat_id.soil_organics) end
    test_passed = test_passed and fat_id.january_waterflow == 19
    if not test_passed then print("january_waterflow", 19, fat_id.january_waterflow) end
    test_passed = test_passed and fat_id.july_waterflow == -4
    if not test_passed then print("july_waterflow", -4, fat_id.july_waterflow) end
    test_passed = test_passed and fat_id.waterlevel == 14
    if not test_passed then print("waterlevel", 14, fat_id.waterlevel) end
    test_passed = test_passed and fat_id.has_river == true
    if not test_passed then print("has_river", true, fat_id.has_river) end
    test_passed = test_passed and fat_id.has_marsh == false
    if not test_passed then print("has_marsh", false, fat_id.has_marsh) end
    test_passed = test_passed and fat_id.ice == -14
    if not test_passed then print("ice", -14, fat_id.ice) end
    test_passed = test_passed and fat_id.ice_age_ice == -16
    if not test_passed then print("ice_age_ice", -16, fat_id.ice_age_ice) end
    test_passed = test_passed and fat_id.debug_r == 1
    if not test_passed then print("debug_r", 1, fat_id.debug_r) end
    test_passed = test_passed and fat_id.debug_g == 10
    if not test_passed then print("debug_g", 10, fat_id.debug_g) end
    test_passed = test_passed and fat_id.debug_b == 15
    if not test_passed then print("debug_b", 15, fat_id.debug_b) end
    test_passed = test_passed and fat_id.real_r == -14
    if not test_passed then print("real_r", -14, fat_id.real_r) end
    test_passed = test_passed and fat_id.real_g == 2
    if not test_passed then print("real_g", 2, fat_id.real_g) end
    test_passed = test_passed and fat_id.real_b == 7
    if not test_passed then print("real_b", 7, fat_id.real_b) end
    test_passed = test_passed and fat_id.pathfinding_index == 10
    if not test_passed then print("pathfinding_index", 10, fat_id.pathfinding_index) end
    test_passed = test_passed and fat_id.resource == 19
    if not test_passed then print("resource", 19, fat_id.resource) end
    test_passed = test_passed and fat_id.bedrock == 20
    if not test_passed then print("bedrock", 20, fat_id.bedrock) end
    test_passed = test_passed and fat_id.biome == 6
    if not test_passed then print("biome", 6, fat_id.biome) end
    print("SET_GET_TEST_0_tile:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_pop()
    local fat_id = DATA.fatten_pop(id)
    fat_id.race = 12
    fat_id.female = false
    fat_id.age = 1
    fat_id.savings = -4
    fat_id.parent = 16
    fat_id.loyalty = 15
    fat_id.life_needs_satisfaction = 5
    fat_id.basic_needs_satisfaction = -1
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].need = 7
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].use_case = 11
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].consumed = 17
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].demanded = -7
    end
    for j = 0, 9 do
        DATA.pop[id].traits[j] = 8
    end
    fat_id.successor = 4
    for j = 0, 99 do
        DATA.pop[id].inventory[j] = -2
    end
    for j = 0, 99 do
        DATA.pop[id].price_memory[j] = -12
    end
    fat_id.forage_ratio = -14
    fat_id.work_ratio = 19
    fat_id.rank = 2
    for j = 0, 19 do
        DATA.pop[id].dna[j] = 14
    end
    local test_passed = true
    test_passed = test_passed and fat_id.race == 12
    if not test_passed then print("race", 12, fat_id.race) end
    test_passed = test_passed and fat_id.female == false
    if not test_passed then print("female", false, fat_id.female) end
    test_passed = test_passed and fat_id.age == 1
    if not test_passed then print("age", 1, fat_id.age) end
    test_passed = test_passed and fat_id.savings == -4
    if not test_passed then print("savings", -4, fat_id.savings) end
    test_passed = test_passed and fat_id.parent == 16
    if not test_passed then print("parent", 16, fat_id.parent) end
    test_passed = test_passed and fat_id.loyalty == 15
    if not test_passed then print("loyalty", 15, fat_id.loyalty) end
    test_passed = test_passed and fat_id.life_needs_satisfaction == 5
    if not test_passed then print("life_needs_satisfaction", 5, fat_id.life_needs_satisfaction) end
    test_passed = test_passed and fat_id.basic_needs_satisfaction == -1
    if not test_passed then print("basic_needs_satisfaction", -1, fat_id.basic_needs_satisfaction) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].need == 7
    end
    if not test_passed then print("need_satisfaction.need", 7, DATA.pop[id].need_satisfaction[0].need) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].use_case == 11
    end
    if not test_passed then print("need_satisfaction.use_case", 11, DATA.pop[id].need_satisfaction[0].use_case) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].consumed == 17
    end
    if not test_passed then print("need_satisfaction.consumed", 17, DATA.pop[id].need_satisfaction[0].consumed) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].demanded == -7
    end
    if not test_passed then print("need_satisfaction.demanded", -7, DATA.pop[id].need_satisfaction[0].demanded) end
    for j = 0, 9 do
        test_passed = test_passed and DATA.pop[id].traits[j] == 8
    end
    if not test_passed then print("traits", 8, DATA.pop[id].traits[0]) end
    test_passed = test_passed and fat_id.successor == 4
    if not test_passed then print("successor", 4, fat_id.successor) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[id].inventory[j] == -2
    end
    if not test_passed then print("inventory", -2, DATA.pop[id].inventory[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[id].price_memory[j] == -12
    end
    if not test_passed then print("price_memory", -12, DATA.pop[id].price_memory[0]) end
    test_passed = test_passed and fat_id.forage_ratio == -14
    if not test_passed then print("forage_ratio", -14, fat_id.forage_ratio) end
    test_passed = test_passed and fat_id.work_ratio == 19
    if not test_passed then print("work_ratio", 19, fat_id.work_ratio) end
    test_passed = test_passed and fat_id.rank == 2
    if not test_passed then print("rank", 2, fat_id.rank) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].dna[j] == 14
    end
    if not test_passed then print("dna", 14, DATA.pop[id].dna[0]) end
    print("SET_GET_TEST_0_pop:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_province()
    local fat_id = DATA.fatten_province(id)
    fat_id.r = 4
    fat_id.g = 6
    fat_id.b = -18
    fat_id.is_land = false
    fat_id.province_id = 12
    fat_id.size = 11
    fat_id.hydration = 5
    fat_id.movement_cost = -1
    fat_id.center = 15
    fat_id.infrastructure_needed = 2
    fat_id.infrastructure = 17
    fat_id.infrastructure_investment = -7
    for j = 0, 399 do
        DATA.province[id].technologies_present[j] = 16
    end
    for j = 0, 399 do
        DATA.province[id].technologies_researchable[j] = 4
    end
    for j = 0, 249 do
        DATA.province[id].buildable_buildings[j] = 9
    end
    for j = 0, 99 do
        DATA.province[id].local_production[j] = -12
    end
    for j = 0, 99 do
        DATA.province[id].local_consumption[j] = -14
    end
    for j = 0, 99 do
        DATA.province[id].local_demand[j] = 19
    end
    for j = 0, 99 do
        DATA.province[id].local_storage[j] = -4
    end
    for j = 0, 99 do
        DATA.province[id].local_prices[j] = 14
    end
    fat_id.local_wealth = 18
    fat_id.trade_wealth = -11
    fat_id.local_income = -1
    fat_id.local_building_upkeep = -14
    fat_id.foragers = -16
    fat_id.foragers_water = 1
    fat_id.foragers_limit = 10
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].output_good = 17
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].output_value = -14
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].amount = 2
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].forage = 6
    end
    for j = 0, 24 do
        DATA.province[id].local_resources[j].resource = 10
    end
    for j = 0, 24 do
        DATA.province[id].local_resources[j].location = 19
    end
    fat_id.mood = 20
    for j = 0, 19 do
        DATA.province[id].unit_types[j] = 6
    end
    for j = 0, 249 do
        DATA.province[id].throughput_boosts[j] = 15
    end
    for j = 0, 249 do
        DATA.province[id].input_efficiency_boosts[j] = 10
    end
    for j = 0, 249 do
        DATA.province[id].output_efficiency_boosts[j] = 8
    end
    fat_id.on_a_river = false
    fat_id.on_a_forest = true
    local test_passed = true
    test_passed = test_passed and fat_id.r == 4
    if not test_passed then print("r", 4, fat_id.r) end
    test_passed = test_passed and fat_id.g == 6
    if not test_passed then print("g", 6, fat_id.g) end
    test_passed = test_passed and fat_id.b == -18
    if not test_passed then print("b", -18, fat_id.b) end
    test_passed = test_passed and fat_id.is_land == false
    if not test_passed then print("is_land", false, fat_id.is_land) end
    test_passed = test_passed and fat_id.province_id == 12
    if not test_passed then print("province_id", 12, fat_id.province_id) end
    test_passed = test_passed and fat_id.size == 11
    if not test_passed then print("size", 11, fat_id.size) end
    test_passed = test_passed and fat_id.hydration == 5
    if not test_passed then print("hydration", 5, fat_id.hydration) end
    test_passed = test_passed and fat_id.movement_cost == -1
    if not test_passed then print("movement_cost", -1, fat_id.movement_cost) end
    test_passed = test_passed and fat_id.center == 15
    if not test_passed then print("center", 15, fat_id.center) end
    test_passed = test_passed and fat_id.infrastructure_needed == 2
    if not test_passed then print("infrastructure_needed", 2, fat_id.infrastructure_needed) end
    test_passed = test_passed and fat_id.infrastructure == 17
    if not test_passed then print("infrastructure", 17, fat_id.infrastructure) end
    test_passed = test_passed and fat_id.infrastructure_investment == -7
    if not test_passed then print("infrastructure_investment", -7, fat_id.infrastructure_investment) end
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[id].technologies_present[j] == 16
    end
    if not test_passed then print("technologies_present", 16, DATA.province[id].technologies_present[0]) end
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[id].technologies_researchable[j] == 4
    end
    if not test_passed then print("technologies_researchable", 4, DATA.province[id].technologies_researchable[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].buildable_buildings[j] == 9
    end
    if not test_passed then print("buildable_buildings", 9, DATA.province[id].buildable_buildings[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_production[j] == -12
    end
    if not test_passed then print("local_production", -12, DATA.province[id].local_production[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_consumption[j] == -14
    end
    if not test_passed then print("local_consumption", -14, DATA.province[id].local_consumption[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_demand[j] == 19
    end
    if not test_passed then print("local_demand", 19, DATA.province[id].local_demand[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_storage[j] == -4
    end
    if not test_passed then print("local_storage", -4, DATA.province[id].local_storage[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_prices[j] == 14
    end
    if not test_passed then print("local_prices", 14, DATA.province[id].local_prices[0]) end
    test_passed = test_passed and fat_id.local_wealth == 18
    if not test_passed then print("local_wealth", 18, fat_id.local_wealth) end
    test_passed = test_passed and fat_id.trade_wealth == -11
    if not test_passed then print("trade_wealth", -11, fat_id.trade_wealth) end
    test_passed = test_passed and fat_id.local_income == -1
    if not test_passed then print("local_income", -1, fat_id.local_income) end
    test_passed = test_passed and fat_id.local_building_upkeep == -14
    if not test_passed then print("local_building_upkeep", -14, fat_id.local_building_upkeep) end
    test_passed = test_passed and fat_id.foragers == -16
    if not test_passed then print("foragers", -16, fat_id.foragers) end
    test_passed = test_passed and fat_id.foragers_water == 1
    if not test_passed then print("foragers_water", 1, fat_id.foragers_water) end
    test_passed = test_passed and fat_id.foragers_limit == 10
    if not test_passed then print("foragers_limit", 10, fat_id.foragers_limit) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].output_good == 17
    end
    if not test_passed then print("foragers_targets.output_good", 17, DATA.province[id].foragers_targets[0].output_good) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].output_value == -14
    end
    if not test_passed then print("foragers_targets.output_value", -14, DATA.province[id].foragers_targets[0].output_value) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].amount == 2
    end
    if not test_passed then print("foragers_targets.amount", 2, DATA.province[id].foragers_targets[0].amount) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].forage == 6
    end
    if not test_passed then print("foragers_targets.forage", 6, DATA.province[id].foragers_targets[0].forage) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].local_resources[j].resource == 10
    end
    if not test_passed then print("local_resources.resource", 10, DATA.province[id].local_resources[0].resource) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].local_resources[j].location == 19
    end
    if not test_passed then print("local_resources.location", 19, DATA.province[id].local_resources[0].location) end
    test_passed = test_passed and fat_id.mood == 20
    if not test_passed then print("mood", 20, fat_id.mood) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.province[id].unit_types[j] == 6
    end
    if not test_passed then print("unit_types", 6, DATA.province[id].unit_types[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].throughput_boosts[j] == 15
    end
    if not test_passed then print("throughput_boosts", 15, DATA.province[id].throughput_boosts[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].input_efficiency_boosts[j] == 10
    end
    if not test_passed then print("input_efficiency_boosts", 10, DATA.province[id].input_efficiency_boosts[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].output_efficiency_boosts[j] == 8
    end
    if not test_passed then print("output_efficiency_boosts", 8, DATA.province[id].output_efficiency_boosts[0]) end
    test_passed = test_passed and fat_id.on_a_river == false
    if not test_passed then print("on_a_river", false, fat_id.on_a_river) end
    test_passed = test_passed and fat_id.on_a_forest == true
    if not test_passed then print("on_a_forest", true, fat_id.on_a_forest) end
    print("SET_GET_TEST_0_province:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_army()
    local fat_id = DATA.fatten_army(id)
    fat_id.destination = 12
    local test_passed = true
    test_passed = test_passed and fat_id.destination == 12
    if not test_passed then print("destination", 12, fat_id.destination) end
    print("SET_GET_TEST_0_army:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband()
    local fat_id = DATA.fatten_warband(id)
    for j = 0, 19 do
        DATA.warband[id].units_current[j] = 4
    end
    for j = 0, 19 do
        DATA.warband[id].units_target[j] = 6
    end
    fat_id.status = 0
    fat_id.idle_stance = 1
    fat_id.current_free_time_ratio = 12
    fat_id.treasury = 11
    fat_id.total_upkeep = 5
    fat_id.predicted_upkeep = -1
    fat_id.supplies = 10
    fat_id.supplies_target_days = 2
    fat_id.morale = 17
    local test_passed = true
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[id].units_current[j] == 4
    end
    if not test_passed then print("units_current", 4, DATA.warband[id].units_current[0]) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[id].units_target[j] == 6
    end
    if not test_passed then print("units_target", 6, DATA.warband[id].units_target[0]) end
    test_passed = test_passed and fat_id.status == 0
    if not test_passed then print("status", 0, fat_id.status) end
    test_passed = test_passed and fat_id.idle_stance == 1
    if not test_passed then print("idle_stance", 1, fat_id.idle_stance) end
    test_passed = test_passed and fat_id.current_free_time_ratio == 12
    if not test_passed then print("current_free_time_ratio", 12, fat_id.current_free_time_ratio) end
    test_passed = test_passed and fat_id.treasury == 11
    if not test_passed then print("treasury", 11, fat_id.treasury) end
    test_passed = test_passed and fat_id.total_upkeep == 5
    if not test_passed then print("total_upkeep", 5, fat_id.total_upkeep) end
    test_passed = test_passed and fat_id.predicted_upkeep == -1
    if not test_passed then print("predicted_upkeep", -1, fat_id.predicted_upkeep) end
    test_passed = test_passed and fat_id.supplies == 10
    if not test_passed then print("supplies", 10, fat_id.supplies) end
    test_passed = test_passed and fat_id.supplies_target_days == 2
    if not test_passed then print("supplies_target_days", 2, fat_id.supplies_target_days) end
    test_passed = test_passed and fat_id.morale == 17
    if not test_passed then print("morale", 17, fat_id.morale) end
    print("SET_GET_TEST_0_warband:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm()
    local fat_id = DATA.fatten_realm(id)
    fat_id.budget_change = 4
    fat_id.budget_saved_change = 6
    for j = 0, 37 do
        DATA.realm[id].budget_spending_by_category[j] = -18
    end
    for j = 0, 37 do
        DATA.realm[id].budget_income_by_category[j] = -4
    end
    for j = 0, 37 do
        DATA.realm[id].budget_treasury_change_by_category[j] = 12
    end
    fat_id.budget_treasury = 11
    fat_id.budget_treasury_target = 5
    for j = 0, 6 do
        DATA.realm[id].budget[j].ratio = -1
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].budget = 10
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].to_be_invested = 2
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].target = 17
    end
    fat_id.budget_tax_target = -7
    fat_id.budget_tax_collected_this_year = 12
    fat_id.r = -12
    fat_id.g = -2
    fat_id.b = -12
    fat_id.primary_race = 3
    fat_id.capitol = 19
    fat_id.trading_right_cost = -4
    fat_id.building_right_cost = 14
    fat_id.prepare_attack_flag = true
    fat_id.coa_base_r = -1
    fat_id.coa_base_g = -14
    fat_id.coa_base_b = -16
    fat_id.coa_background_r = 1
    fat_id.coa_background_g = 10
    fat_id.coa_background_b = 15
    fat_id.coa_foreground_r = -14
    fat_id.coa_foreground_g = 2
    fat_id.coa_foreground_b = 7
    fat_id.coa_emblem_r = 0
    fat_id.coa_emblem_g = 19
    fat_id.coa_emblem_b = 20
    fat_id.coa_background_image = 6
    fat_id.coa_foreground_image = 17
    fat_id.coa_emblem_image = 15
    for j = 0, 99 do
        DATA.realm[id].resources[j] = 8
    end
    for j = 0, 99 do
        DATA.realm[id].production[j] = 13
    end
    for j = 0, 99 do
        DATA.realm[id].bought[j] = -4
    end
    for j = 0, 99 do
        DATA.realm[id].sold[j] = -17
    end
    fat_id.expected_food_consumption = 15
    local test_passed = true
    test_passed = test_passed and fat_id.budget_change == 4
    if not test_passed then print("budget_change", 4, fat_id.budget_change) end
    test_passed = test_passed and fat_id.budget_saved_change == 6
    if not test_passed then print("budget_saved_change", 6, fat_id.budget_saved_change) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_spending_by_category[j] == -18
    end
    if not test_passed then print("budget_spending_by_category", -18, DATA.realm[id].budget_spending_by_category[0]) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_income_by_category[j] == -4
    end
    if not test_passed then print("budget_income_by_category", -4, DATA.realm[id].budget_income_by_category[0]) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_treasury_change_by_category[j] == 12
    end
    if not test_passed then print("budget_treasury_change_by_category", 12, DATA.realm[id].budget_treasury_change_by_category[0]) end
    test_passed = test_passed and fat_id.budget_treasury == 11
    if not test_passed then print("budget_treasury", 11, fat_id.budget_treasury) end
    test_passed = test_passed and fat_id.budget_treasury_target == 5
    if not test_passed then print("budget_treasury_target", 5, fat_id.budget_treasury_target) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].ratio == -1
    end
    if not test_passed then print("budget.ratio", -1, DATA.realm[id].budget[0].ratio) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].budget == 10
    end
    if not test_passed then print("budget.budget", 10, DATA.realm[id].budget[0].budget) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].to_be_invested == 2
    end
    if not test_passed then print("budget.to_be_invested", 2, DATA.realm[id].budget[0].to_be_invested) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].target == 17
    end
    if not test_passed then print("budget.target", 17, DATA.realm[id].budget[0].target) end
    test_passed = test_passed and fat_id.budget_tax_target == -7
    if not test_passed then print("budget_tax_target", -7, fat_id.budget_tax_target) end
    test_passed = test_passed and fat_id.budget_tax_collected_this_year == 12
    if not test_passed then print("budget_tax_collected_this_year", 12, fat_id.budget_tax_collected_this_year) end
    test_passed = test_passed and fat_id.r == -12
    if not test_passed then print("r", -12, fat_id.r) end
    test_passed = test_passed and fat_id.g == -2
    if not test_passed then print("g", -2, fat_id.g) end
    test_passed = test_passed and fat_id.b == -12
    if not test_passed then print("b", -12, fat_id.b) end
    test_passed = test_passed and fat_id.primary_race == 3
    if not test_passed then print("primary_race", 3, fat_id.primary_race) end
    test_passed = test_passed and fat_id.capitol == 19
    if not test_passed then print("capitol", 19, fat_id.capitol) end
    test_passed = test_passed and fat_id.trading_right_cost == -4
    if not test_passed then print("trading_right_cost", -4, fat_id.trading_right_cost) end
    test_passed = test_passed and fat_id.building_right_cost == 14
    if not test_passed then print("building_right_cost", 14, fat_id.building_right_cost) end
    test_passed = test_passed and fat_id.prepare_attack_flag == true
    if not test_passed then print("prepare_attack_flag", true, fat_id.prepare_attack_flag) end
    test_passed = test_passed and fat_id.coa_base_r == -1
    if not test_passed then print("coa_base_r", -1, fat_id.coa_base_r) end
    test_passed = test_passed and fat_id.coa_base_g == -14
    if not test_passed then print("coa_base_g", -14, fat_id.coa_base_g) end
    test_passed = test_passed and fat_id.coa_base_b == -16
    if not test_passed then print("coa_base_b", -16, fat_id.coa_base_b) end
    test_passed = test_passed and fat_id.coa_background_r == 1
    if not test_passed then print("coa_background_r", 1, fat_id.coa_background_r) end
    test_passed = test_passed and fat_id.coa_background_g == 10
    if not test_passed then print("coa_background_g", 10, fat_id.coa_background_g) end
    test_passed = test_passed and fat_id.coa_background_b == 15
    if not test_passed then print("coa_background_b", 15, fat_id.coa_background_b) end
    test_passed = test_passed and fat_id.coa_foreground_r == -14
    if not test_passed then print("coa_foreground_r", -14, fat_id.coa_foreground_r) end
    test_passed = test_passed and fat_id.coa_foreground_g == 2
    if not test_passed then print("coa_foreground_g", 2, fat_id.coa_foreground_g) end
    test_passed = test_passed and fat_id.coa_foreground_b == 7
    if not test_passed then print("coa_foreground_b", 7, fat_id.coa_foreground_b) end
    test_passed = test_passed and fat_id.coa_emblem_r == 0
    if not test_passed then print("coa_emblem_r", 0, fat_id.coa_emblem_r) end
    test_passed = test_passed and fat_id.coa_emblem_g == 19
    if not test_passed then print("coa_emblem_g", 19, fat_id.coa_emblem_g) end
    test_passed = test_passed and fat_id.coa_emblem_b == 20
    if not test_passed then print("coa_emblem_b", 20, fat_id.coa_emblem_b) end
    test_passed = test_passed and fat_id.coa_background_image == 6
    if not test_passed then print("coa_background_image", 6, fat_id.coa_background_image) end
    test_passed = test_passed and fat_id.coa_foreground_image == 17
    if not test_passed then print("coa_foreground_image", 17, fat_id.coa_foreground_image) end
    test_passed = test_passed and fat_id.coa_emblem_image == 15
    if not test_passed then print("coa_emblem_image", 15, fat_id.coa_emblem_image) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].resources[j] == 8
    end
    if not test_passed then print("resources", 8, DATA.realm[id].resources[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].production[j] == 13
    end
    if not test_passed then print("production", 13, DATA.realm[id].production[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].bought[j] == -4
    end
    if not test_passed then print("bought", -4, DATA.realm[id].bought[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].sold[j] == -17
    end
    if not test_passed then print("sold", -17, DATA.realm[id].sold[0]) end
    test_passed = test_passed and fat_id.expected_food_consumption == 15
    if not test_passed then print("expected_food_consumption", 15, fat_id.expected_food_consumption) end
    print("SET_GET_TEST_0_realm:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_negotiation()
    local fat_id = DATA.fatten_negotiation(id)
    local test_passed = true
    print("SET_GET_TEST_0_negotiation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_building()
    local fat_id = DATA.fatten_building(id)
    fat_id.type = 12
    for j = 0, 7 do
        DATA.building[id].spent_on_inputs[j].good = 13
    end
    for j = 0, 7 do
        DATA.building[id].spent_on_inputs[j].amount = -18
    end
    for j = 0, 7 do
        DATA.building[id].earn_from_outputs[j].good = 8
    end
    for j = 0, 7 do
        DATA.building[id].earn_from_outputs[j].amount = 12
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_inputs[j].good = 15
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_inputs[j].amount = 5
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_outputs[j].good = 9
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_outputs[j].amount = 10
    end
    local test_passed = true
    test_passed = test_passed and fat_id.type == 12
    if not test_passed then print("type", 12, fat_id.type) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].spent_on_inputs[j].good == 13
    end
    if not test_passed then print("spent_on_inputs.good", 13, DATA.building[id].spent_on_inputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].spent_on_inputs[j].amount == -18
    end
    if not test_passed then print("spent_on_inputs.amount", -18, DATA.building[id].spent_on_inputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].earn_from_outputs[j].good == 8
    end
    if not test_passed then print("earn_from_outputs.good", 8, DATA.building[id].earn_from_outputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].earn_from_outputs[j].amount == 12
    end
    if not test_passed then print("earn_from_outputs.amount", 12, DATA.building[id].earn_from_outputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_inputs[j].good == 15
    end
    if not test_passed then print("amount_of_inputs.good", 15, DATA.building[id].amount_of_inputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_inputs[j].amount == 5
    end
    if not test_passed then print("amount_of_inputs.amount", 5, DATA.building[id].amount_of_inputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_outputs[j].good == 9
    end
    if not test_passed then print("amount_of_outputs.good", 9, DATA.building[id].amount_of_outputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_outputs[j].amount == 10
    end
    if not test_passed then print("amount_of_outputs.amount", 10, DATA.building[id].amount_of_outputs[0].amount) end
    print("SET_GET_TEST_0_building:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_ownership()
    local fat_id = DATA.fatten_ownership(id)
    local test_passed = true
    print("SET_GET_TEST_0_ownership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_employment()
    local fat_id = DATA.fatten_employment(id)
    fat_id.worker_income = 4
    fat_id.job = 13
    local test_passed = true
    test_passed = test_passed and fat_id.worker_income == 4
    if not test_passed then print("worker_income", 4, fat_id.worker_income) end
    test_passed = test_passed and fat_id.job == 13
    if not test_passed then print("job", 13, fat_id.job) end
    print("SET_GET_TEST_0_employment:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_building_location()
    local fat_id = DATA.fatten_building_location(id)
    local test_passed = true
    print("SET_GET_TEST_0_building_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_army_membership()
    local fat_id = DATA.fatten_army_membership(id)
    local test_passed = true
    print("SET_GET_TEST_0_army_membership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_leader()
    local fat_id = DATA.fatten_warband_leader(id)
    local test_passed = true
    print("SET_GET_TEST_0_warband_leader:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_recruiter()
    local fat_id = DATA.fatten_warband_recruiter(id)
    local test_passed = true
    print("SET_GET_TEST_0_warband_recruiter:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_commander()
    local fat_id = DATA.fatten_warband_commander(id)
    local test_passed = true
    print("SET_GET_TEST_0_warband_commander:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_location()
    local fat_id = DATA.fatten_warband_location(id)
    local test_passed = true
    print("SET_GET_TEST_0_warband_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_unit()
    local fat_id = DATA.fatten_warband_unit(id)
    fat_id.type = 12
    local test_passed = true
    test_passed = test_passed and fat_id.type == 12
    if not test_passed then print("type", 12, fat_id.type) end
    print("SET_GET_TEST_0_warband_unit:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_character_location()
    local fat_id = DATA.fatten_character_location(id)
    local test_passed = true
    print("SET_GET_TEST_0_character_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_home()
    local fat_id = DATA.fatten_home(id)
    local test_passed = true
    print("SET_GET_TEST_0_home:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_pop_location()
    local fat_id = DATA.fatten_pop_location(id)
    local test_passed = true
    print("SET_GET_TEST_0_pop_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_outlaw_location()
    local fat_id = DATA.fatten_outlaw_location(id)
    local test_passed = true
    print("SET_GET_TEST_0_outlaw_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_tile_province_membership()
    local fat_id = DATA.fatten_tile_province_membership(id)
    local test_passed = true
    print("SET_GET_TEST_0_tile_province_membership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_province_neighborhood()
    local fat_id = DATA.fatten_province_neighborhood(id)
    local test_passed = true
    print("SET_GET_TEST_0_province_neighborhood:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_parent_child_relation()
    local fat_id = DATA.fatten_parent_child_relation(id)
    local test_passed = true
    print("SET_GET_TEST_0_parent_child_relation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_loyalty()
    local fat_id = DATA.fatten_loyalty(id)
    local test_passed = true
    print("SET_GET_TEST_0_loyalty:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_succession()
    local fat_id = DATA.fatten_succession(id)
    local test_passed = true
    print("SET_GET_TEST_0_succession:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_armies()
    local fat_id = DATA.fatten_realm_armies(id)
    local test_passed = true
    print("SET_GET_TEST_0_realm_armies:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_guard()
    local fat_id = DATA.fatten_realm_guard(id)
    local test_passed = true
    print("SET_GET_TEST_0_realm_guard:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_overseer()
    local fat_id = DATA.fatten_realm_overseer(id)
    local test_passed = true
    print("SET_GET_TEST_0_realm_overseer:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_leadership()
    local fat_id = DATA.fatten_realm_leadership(id)
    local test_passed = true
    print("SET_GET_TEST_0_realm_leadership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_subject_relation()
    local fat_id = DATA.fatten_realm_subject_relation(id)
    fat_id.wealth_transfer = false
    fat_id.goods_transfer = false
    fat_id.warriors_contribution = true
    fat_id.protection = false
    fat_id.local_ruler = false
    local test_passed = true
    test_passed = test_passed and fat_id.wealth_transfer == false
    if not test_passed then print("wealth_transfer", false, fat_id.wealth_transfer) end
    test_passed = test_passed and fat_id.goods_transfer == false
    if not test_passed then print("goods_transfer", false, fat_id.goods_transfer) end
    test_passed = test_passed and fat_id.warriors_contribution == true
    if not test_passed then print("warriors_contribution", true, fat_id.warriors_contribution) end
    test_passed = test_passed and fat_id.protection == false
    if not test_passed then print("protection", false, fat_id.protection) end
    test_passed = test_passed and fat_id.local_ruler == false
    if not test_passed then print("local_ruler", false, fat_id.local_ruler) end
    print("SET_GET_TEST_0_realm_subject_relation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_tax_collector()
    local fat_id = DATA.fatten_tax_collector(id)
    local test_passed = true
    print("SET_GET_TEST_0_tax_collector:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_personal_rights()
    local fat_id = DATA.fatten_personal_rights(id)
    fat_id.can_trade = false
    fat_id.can_build = false
    local test_passed = true
    test_passed = test_passed and fat_id.can_trade == false
    if not test_passed then print("can_trade", false, fat_id.can_trade) end
    test_passed = test_passed and fat_id.can_build == false
    if not test_passed then print("can_build", false, fat_id.can_build) end
    print("SET_GET_TEST_0_personal_rights:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_provinces()
    local fat_id = DATA.fatten_realm_provinces(id)
    local test_passed = true
    print("SET_GET_TEST_0_realm_provinces:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_popularity()
    local fat_id = DATA.fatten_popularity(id)
    fat_id.value = 4
    local test_passed = true
    test_passed = test_passed and fat_id.value == 4
    if not test_passed then print("value", 4, fat_id.value) end
    print("SET_GET_TEST_0_popularity:")
    if test_passed then print("PASSED") else print("ERROR") end
end
function DATA.test_save_load_1()
    print("tile world_id")
    for i = 0, 1500000 do
        DATA.tile[i].world_id = 4
    end
    print("tile is_land")
    for i = 0, 1500000 do
        DATA.tile[i].is_land = true
    end
    print("tile is_fresh")
    for i = 0, 1500000 do
        DATA.tile[i].is_fresh = false
    end
    print("tile elevation")
    for i = 0, 1500000 do
        DATA.tile[i].elevation = -13
    end
    print("tile grass")
    for i = 0, 1500000 do
        DATA.tile[i].grass = 11
    end
    print("tile shrub")
    for i = 0, 1500000 do
        DATA.tile[i].shrub = 8
    end
    print("tile conifer")
    for i = 0, 1500000 do
        DATA.tile[i].conifer = 10
    end
    print("tile broadleaf")
    for i = 0, 1500000 do
        DATA.tile[i].broadleaf = 4
    end
    print("tile ideal_grass")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_grass = -7
    end
    print("tile ideal_shrub")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_shrub = -14
    end
    print("tile ideal_conifer")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_conifer = 11
    end
    print("tile ideal_broadleaf")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_broadleaf = -19
    end
    print("tile silt")
    for i = 0, 1500000 do
        DATA.tile[i].silt = 4
    end
    print("tile clay")
    for i = 0, 1500000 do
        DATA.tile[i].clay = 7
    end
    print("tile sand")
    for i = 0, 1500000 do
        DATA.tile[i].sand = 18
    end
    print("tile soil_minerals")
    for i = 0, 1500000 do
        DATA.tile[i].soil_minerals = -20
    end
    print("tile soil_organics")
    for i = 0, 1500000 do
        DATA.tile[i].soil_organics = 8
    end
    print("tile january_waterflow")
    for i = 0, 1500000 do
        DATA.tile[i].january_waterflow = -3
    end
    print("tile july_waterflow")
    for i = 0, 1500000 do
        DATA.tile[i].july_waterflow = -6
    end
    print("tile waterlevel")
    for i = 0, 1500000 do
        DATA.tile[i].waterlevel = 17
    end
    print("tile has_river")
    for i = 0, 1500000 do
        DATA.tile[i].has_river = true
    end
    print("tile has_marsh")
    for i = 0, 1500000 do
        DATA.tile[i].has_marsh = false
    end
    print("tile ice")
    for i = 0, 1500000 do
        DATA.tile[i].ice = -19
    end
    print("tile ice_age_ice")
    for i = 0, 1500000 do
        DATA.tile[i].ice_age_ice = -19
    end
    print("tile debug_r")
    for i = 0, 1500000 do
        DATA.tile[i].debug_r = -19
    end
    print("tile debug_g")
    for i = 0, 1500000 do
        DATA.tile[i].debug_g = 14
    end
    print("tile debug_b")
    for i = 0, 1500000 do
        DATA.tile[i].debug_b = -20
    end
    print("tile real_r")
    for i = 0, 1500000 do
        DATA.tile[i].real_r = 4
    end
    print("tile real_g")
    for i = 0, 1500000 do
        DATA.tile[i].real_g = -7
    end
    print("tile real_b")
    for i = 0, 1500000 do
        DATA.tile[i].real_b = 7
    end
    print("tile pathfinding_index")
    for i = 0, 1500000 do
        DATA.tile[i].pathfinding_index = 0
    end
    print("tile resource")
    for i = 0, 1500000 do
        DATA.tile[i].resource = 16
    end
    print("tile bedrock")
    for i = 0, 1500000 do
        DATA.tile[i].bedrock = 7
    end
    print("tile biome")
    for i = 0, 1500000 do
        DATA.tile[i].biome = 14
    end
    print("pop race")
    for i = 0, 300000 do
        DATA.pop[i].race = 15
    end
    print("pop female")
    for i = 0, 300000 do
        DATA.pop[i].female = true
    end
    print("pop age")
    for i = 0, 300000 do
        DATA.pop[i].age = 11
    end
    print("pop savings")
    for i = 0, 300000 do
        DATA.pop[i].savings = -6
    end
    print("pop parent")
    for i = 0, 300000 do
        DATA.pop[i].parent = 7
    end
    print("pop loyalty")
    for i = 0, 300000 do
        DATA.pop[i].loyalty = 14
    end
    print("pop life_needs_satisfaction")
    for i = 0, 300000 do
        DATA.pop[i].life_needs_satisfaction = -2
    end
    print("pop basic_needs_satisfaction")
    for i = 0, 300000 do
        DATA.pop[i].basic_needs_satisfaction = -19
    end
    print("pop need_satisfaction")
    for i = 0, 300000 do
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].need = 6
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].use_case = 17
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].consumed = -14
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].demanded = -9
    end
    end
    print("pop traits")
    for i = 0, 300000 do
    for j = 0, 9 do
        DATA.pop[i].traits[j] = 10
    end
    end
    print("pop successor")
    for i = 0, 300000 do
        DATA.pop[i].successor = 9
    end
    print("pop inventory")
    for i = 0, 300000 do
    for j = 0, 99 do
        DATA.pop[i].inventory[j] = -13
    end
    end
    print("pop price_memory")
    for i = 0, 300000 do
    for j = 0, 99 do
        DATA.pop[i].price_memory[j] = 1
    end
    end
    print("pop forage_ratio")
    for i = 0, 300000 do
        DATA.pop[i].forage_ratio = 12
    end
    print("pop work_ratio")
    for i = 0, 300000 do
        DATA.pop[i].work_ratio = 7
    end
    print("pop rank")
    for i = 0, 300000 do
        DATA.pop[i].rank = 1
    end
    print("pop dna")
    for i = 0, 300000 do
    for j = 0, 19 do
        DATA.pop[i].dna[j] = -1
    end
    end
    print("province r")
    for i = 0, 20000 do
        DATA.province[i].r = -2
    end
    print("province g")
    for i = 0, 20000 do
        DATA.province[i].g = 17
    end
    print("province b")
    for i = 0, 20000 do
        DATA.province[i].b = 11
    end
    print("province is_land")
    for i = 0, 20000 do
        DATA.province[i].is_land = false
    end
    print("province province_id")
    for i = 0, 20000 do
        DATA.province[i].province_id = 17
    end
    print("province size")
    for i = 0, 20000 do
        DATA.province[i].size = -18
    end
    print("province hydration")
    for i = 0, 20000 do
        DATA.province[i].hydration = 10
    end
    print("province movement_cost")
    for i = 0, 20000 do
        DATA.province[i].movement_cost = -5
    end
    print("province center")
    for i = 0, 20000 do
        DATA.province[i].center = 12
    end
    print("province infrastructure_needed")
    for i = 0, 20000 do
        DATA.province[i].infrastructure_needed = 6
    end
    print("province infrastructure")
    for i = 0, 20000 do
        DATA.province[i].infrastructure = -9
    end
    print("province infrastructure_investment")
    for i = 0, 20000 do
        DATA.province[i].infrastructure_investment = 3
    end
    print("province technologies_present")
    for i = 0, 20000 do
    for j = 0, 399 do
        DATA.province[i].technologies_present[j] = 17
    end
    end
    print("province technologies_researchable")
    for i = 0, 20000 do
    for j = 0, 399 do
        DATA.province[i].technologies_researchable[j] = 11
    end
    end
    print("province buildable_buildings")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].buildable_buildings[j] = 2
    end
    end
    print("province local_production")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_production[j] = 8
    end
    end
    print("province local_consumption")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_consumption[j] = 12
    end
    end
    print("province local_demand")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_demand[j] = -14
    end
    end
    print("province local_storage")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_storage[j] = -10
    end
    end
    print("province local_prices")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_prices[j] = 13
    end
    end
    print("province local_wealth")
    for i = 0, 20000 do
        DATA.province[i].local_wealth = 5
    end
    print("province trade_wealth")
    for i = 0, 20000 do
        DATA.province[i].trade_wealth = 3
    end
    print("province local_income")
    for i = 0, 20000 do
        DATA.province[i].local_income = 11
    end
    print("province local_building_upkeep")
    for i = 0, 20000 do
        DATA.province[i].local_building_upkeep = -19
    end
    print("province foragers")
    for i = 0, 20000 do
        DATA.province[i].foragers = 10
    end
    print("province foragers_water")
    for i = 0, 20000 do
        DATA.province[i].foragers_water = -18
    end
    print("province foragers_limit")
    for i = 0, 20000 do
        DATA.province[i].foragers_limit = -1
    end
    print("province foragers_targets")
    for i = 0, 20000 do
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].output_good = 19
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].output_value = 17
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].amount = 17
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].forage = 6
    end
    end
    print("province local_resources")
    for i = 0, 20000 do
    for j = 0, 24 do
        DATA.province[i].local_resources[j].resource = 20
    end
    for j = 0, 24 do
        DATA.province[i].local_resources[j].location = 5
    end
    end
    print("province mood")
    for i = 0, 20000 do
        DATA.province[i].mood = -10
    end
    print("province unit_types")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.province[i].unit_types[j] = 16
    end
    end
    print("province throughput_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].throughput_boosts[j] = -6
    end
    end
    print("province input_efficiency_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].input_efficiency_boosts[j] = -20
    end
    end
    print("province output_efficiency_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].output_efficiency_boosts[j] = -8
    end
    end
    print("province on_a_river")
    for i = 0, 20000 do
        DATA.province[i].on_a_river = true
    end
    print("province on_a_forest")
    for i = 0, 20000 do
        DATA.province[i].on_a_forest = false
    end
    print("army destination")
    for i = 0, 5000 do
        DATA.army[i].destination = 16
    end
    print("warband units_current")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.warband[i].units_current[j] = 2
    end
    end
    print("warband units_target")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.warband[i].units_target[j] = 16
    end
    end
    print("warband status")
    for i = 0, 20000 do
        DATA.warband[i].status = 5
    end
    print("warband idle_stance")
    for i = 0, 20000 do
        DATA.warband[i].idle_stance = 1
    end
    print("warband current_free_time_ratio")
    for i = 0, 20000 do
        DATA.warband[i].current_free_time_ratio = -3
    end
    print("warband treasury")
    for i = 0, 20000 do
        DATA.warband[i].treasury = 15
    end
    print("warband total_upkeep")
    for i = 0, 20000 do
        DATA.warband[i].total_upkeep = 18
    end
    print("warband predicted_upkeep")
    for i = 0, 20000 do
        DATA.warband[i].predicted_upkeep = -20
    end
    print("warband supplies")
    for i = 0, 20000 do
        DATA.warband[i].supplies = 4
    end
    print("warband supplies_target_days")
    for i = 0, 20000 do
        DATA.warband[i].supplies_target_days = 12
    end
    print("warband morale")
    for i = 0, 20000 do
        DATA.warband[i].morale = -12
    end
    print("realm budget_change")
    for i = 0, 15000 do
        DATA.realm[i].budget_change = 13
    end
    print("realm budget_saved_change")
    for i = 0, 15000 do
        DATA.realm[i].budget_saved_change = 15
    end
    print("realm budget_spending_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_spending_by_category[j] = -7
    end
    end
    print("realm budget_income_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_income_by_category[j] = 7
    end
    end
    print("realm budget_treasury_change_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_treasury_change_by_category[j] = -17
    end
    end
    print("realm budget_treasury")
    for i = 0, 15000 do
        DATA.realm[i].budget_treasury = 10
    end
    print("realm budget_treasury_target")
    for i = 0, 15000 do
        DATA.realm[i].budget_treasury_target = 3
    end
    print("realm budget")
    for i = 0, 15000 do
    for j = 0, 6 do
        DATA.realm[i].budget[j].ratio = 16
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].budget = 15
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].to_be_invested = -8
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].target = 12
    end
    end
    print("realm budget_tax_target")
    for i = 0, 15000 do
        DATA.realm[i].budget_tax_target = 6
    end
    print("realm budget_tax_collected_this_year")
    for i = 0, 15000 do
        DATA.realm[i].budget_tax_collected_this_year = 11
    end
    print("realm r")
    for i = 0, 15000 do
        DATA.realm[i].r = 2
    end
    print("realm g")
    for i = 0, 15000 do
        DATA.realm[i].g = 6
    end
    print("realm b")
    for i = 0, 15000 do
        DATA.realm[i].b = 2
    end
    print("realm primary_race")
    for i = 0, 15000 do
        DATA.realm[i].primary_race = 0
    end
    print("realm capitol")
    for i = 0, 15000 do
        DATA.realm[i].capitol = 17
    end
    print("realm trading_right_cost")
    for i = 0, 15000 do
        DATA.realm[i].trading_right_cost = 14
    end
    print("realm building_right_cost")
    for i = 0, 15000 do
        DATA.realm[i].building_right_cost = 19
    end
    print("realm prepare_attack_flag")
    for i = 0, 15000 do
        DATA.realm[i].prepare_attack_flag = false
    end
    print("realm coa_base_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_r = 9
    end
    print("realm coa_base_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_g = 18
    end
    print("realm coa_base_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_b = -19
    end
    print("realm coa_background_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_r = -6
    end
    print("realm coa_background_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_g = 20
    end
    print("realm coa_background_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_b = -9
    end
    print("realm coa_foreground_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_r = 15
    end
    print("realm coa_foreground_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_g = 17
    end
    print("realm coa_foreground_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_b = -9
    end
    print("realm coa_emblem_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_r = -15
    end
    print("realm coa_emblem_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_g = 15
    end
    print("realm coa_emblem_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_b = -4
    end
    print("realm coa_background_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_image = 1
    end
    print("realm coa_foreground_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_image = 2
    end
    print("realm coa_emblem_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_image = 2
    end
    print("realm resources")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].resources[j] = -19
    end
    end
    print("realm production")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].production[j] = 8
    end
    end
    print("realm bought")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].bought[j] = -20
    end
    end
    print("realm sold")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].sold[j] = -3
    end
    end
    print("realm expected_food_consumption")
    for i = 0, 15000 do
        DATA.realm[i].expected_food_consumption = -5
    end
    print("building type")
    for i = 0, 200000 do
        DATA.building[i].type = 8
    end
    print("building spent_on_inputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].spent_on_inputs[j].good = 3
    end
    for j = 0, 7 do
        DATA.building[i].spent_on_inputs[j].amount = 19
    end
    end
    print("building earn_from_outputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].earn_from_outputs[j].good = 5
    end
    for j = 0, 7 do
        DATA.building[i].earn_from_outputs[j].amount = 2
    end
    end
    print("building amount_of_inputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].amount_of_inputs[j].good = 9
    end
    for j = 0, 7 do
        DATA.building[i].amount_of_inputs[j].amount = -16
    end
    end
    print("building amount_of_outputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].amount_of_outputs[j].good = 5
    end
    for j = 0, 7 do
        DATA.building[i].amount_of_outputs[j].amount = -10
    end
    end
    print("employment worker_income")
    for i = 0, 300000 do
        DATA.employment[i].worker_income = -4
    end
    print("employment job")
    for i = 0, 300000 do
        DATA.employment[i].job = 16
    end
    print("warband_unit type")
    for i = 0, 50000 do
        DATA.warband_unit[i].type = 5
    end
    print("realm_subject_relation wealth_transfer")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].wealth_transfer = false
    end
    print("realm_subject_relation goods_transfer")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].goods_transfer = false
    end
    print("realm_subject_relation warriors_contribution")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].warriors_contribution = false
    end
    print("realm_subject_relation protection")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].protection = false
    end
    print("realm_subject_relation local_ruler")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].local_ruler = false
    end
    print("personal_rights can_trade")
    for i = 0, 450000 do
        DATA.personal_rights[i].can_trade = false
    end
    print("personal_rights can_build")
    for i = 0, 450000 do
        DATA.personal_rights[i].can_build = true
    end
    print("popularity value")
    for i = 0, 450000 do
        DATA.popularity[i].value = -19
    end
    DATA.save_state()
    DATA.load_state()
    local test_passed = true
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].world_id == 4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].is_land == true
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].is_fresh == false
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].elevation == -13
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].grass == 11
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].shrub == 8
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].conifer == 10
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].broadleaf == 4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_grass == -7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_shrub == -14
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_conifer == 11
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_broadleaf == -19
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].silt == 4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].clay == 7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].sand == 18
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].soil_minerals == -20
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].soil_organics == 8
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].january_waterflow == -3
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].july_waterflow == -6
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].waterlevel == 17
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].has_river == true
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].has_marsh == false
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ice == -19
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ice_age_ice == -19
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_r == -19
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_g == 14
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_b == -20
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_r == 4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_g == -7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_b == 7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].pathfinding_index == 0
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].resource == 16
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].bedrock == 7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].biome == 14
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].race == 15
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].female == true
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].age == 11
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].savings == -6
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].parent == 7
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].loyalty == 14
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].life_needs_satisfaction == -2
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].basic_needs_satisfaction == -19
    end
    for i = 0, 300000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].need == 6
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].use_case == 17
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].consumed == -14
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].demanded == -9
    end
    end
    for i = 0, 300000 do
    for j = 0, 9 do
        test_passed = test_passed and DATA.pop[i].traits[j] == 10
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].successor == 9
    end
    for i = 0, 300000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[i].inventory[j] == -13
    end
    end
    for i = 0, 300000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[i].price_memory[j] == 1
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].forage_ratio == 12
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].work_ratio == 7
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].rank == 1
    end
    for i = 0, 300000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].dna[j] == -1
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].r == -2
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].g == 17
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].b == 11
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].is_land == false
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].province_id == 17
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].size == -18
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].hydration == 10
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].movement_cost == -5
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].center == 12
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure_needed == 6
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure == -9
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure_investment == 3
    end
    for i = 0, 20000 do
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[i].technologies_present[j] == 17
    end
    end
    for i = 0, 20000 do
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[i].technologies_researchable[j] == 11
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].buildable_buildings[j] == 2
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_production[j] == 8
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_consumption[j] == 12
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_demand[j] == -14
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_storage[j] == -10
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_prices[j] == 13
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_wealth == 5
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].trade_wealth == 3
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_income == 11
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_building_upkeep == -19
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers == 10
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers_water == -18
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers_limit == -1
    end
    for i = 0, 20000 do
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].output_good == 19
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].output_value == 17
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].amount == 17
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].forage == 6
    end
    end
    for i = 0, 20000 do
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].local_resources[j].resource == 20
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].local_resources[j].location == 5
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].mood == -10
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.province[i].unit_types[j] == 16
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].throughput_boosts[j] == -6
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].input_efficiency_boosts[j] == -20
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].output_efficiency_boosts[j] == -8
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].on_a_river == true
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].on_a_forest == false
    end
    for i = 0, 5000 do
        test_passed = test_passed and DATA.army[i].destination == 16
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[i].units_current[j] == 2
    end
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[i].units_target[j] == 16
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].status == 5
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].idle_stance == 1
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].current_free_time_ratio == -3
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].treasury == 15
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].total_upkeep == 18
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].predicted_upkeep == -20
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].supplies == 4
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].supplies_target_days == 12
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].morale == -12
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_change == 13
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_saved_change == 15
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_spending_by_category[j] == -7
    end
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_income_by_category[j] == 7
    end
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_treasury_change_by_category[j] == -17
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_treasury == 10
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_treasury_target == 3
    end
    for i = 0, 15000 do
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].ratio == 16
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].budget == 15
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].to_be_invested == -8
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].target == 12
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_tax_target == 6
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_tax_collected_this_year == 11
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].r == 2
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].g == 6
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].b == 2
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].primary_race == 0
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].capitol == 17
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].trading_right_cost == 14
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].building_right_cost == 19
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].prepare_attack_flag == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_r == 9
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_g == 18
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_b == -19
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_r == -6
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_g == 20
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_b == -9
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_r == 15
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_g == 17
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_b == -9
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_r == -15
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_g == 15
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_b == -4
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_image == 1
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_image == 2
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_image == 2
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].resources[j] == -19
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].production[j] == 8
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].bought[j] == -20
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].sold[j] == -3
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].expected_food_consumption == -5
    end
    for i = 0, 200000 do
        test_passed = test_passed and DATA.building[i].type == 8
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].spent_on_inputs[j].good == 3
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].spent_on_inputs[j].amount == 19
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].earn_from_outputs[j].good == 5
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].earn_from_outputs[j].amount == 2
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_inputs[j].good == 9
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_inputs[j].amount == -16
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_outputs[j].good == 5
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_outputs[j].amount == -10
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.employment[i].worker_income == -4
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.employment[i].job == 16
    end
    for i = 0, 50000 do
        test_passed = test_passed and DATA.warband_unit[i].type == 5
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].wealth_transfer == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].goods_transfer == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].warriors_contribution == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].protection == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].local_ruler == false
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.personal_rights[i].can_trade == false
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.personal_rights[i].can_build == true
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.popularity[i].value == -19
    end
    print("SAVE_LOAD_TEST_1:")
    if test_passed then print("PASSED") else print("ERROR") end
end
function DATA.test_set_get_1()
    local id = DATA.create_tile()
    local fat_id = DATA.fatten_tile(id)
    fat_id.world_id = 4
    fat_id.is_land = true
    fat_id.is_fresh = false
    fat_id.elevation = -13
    fat_id.grass = 11
    fat_id.shrub = 8
    fat_id.conifer = 10
    fat_id.broadleaf = 4
    fat_id.ideal_grass = -7
    fat_id.ideal_shrub = -14
    fat_id.ideal_conifer = 11
    fat_id.ideal_broadleaf = -19
    fat_id.silt = 4
    fat_id.clay = 7
    fat_id.sand = 18
    fat_id.soil_minerals = -20
    fat_id.soil_organics = 8
    fat_id.january_waterflow = -3
    fat_id.july_waterflow = -6
    fat_id.waterlevel = 17
    fat_id.has_river = true
    fat_id.has_marsh = false
    fat_id.ice = -19
    fat_id.ice_age_ice = -19
    fat_id.debug_r = -19
    fat_id.debug_g = 14
    fat_id.debug_b = -20
    fat_id.real_r = 4
    fat_id.real_g = -7
    fat_id.real_b = 7
    fat_id.pathfinding_index = 0
    fat_id.resource = 16
    fat_id.bedrock = 7
    fat_id.biome = 14
    local test_passed = true
    test_passed = test_passed and fat_id.world_id == 4
    if not test_passed then print("world_id", 4, fat_id.world_id) end
    test_passed = test_passed and fat_id.is_land == true
    if not test_passed then print("is_land", true, fat_id.is_land) end
    test_passed = test_passed and fat_id.is_fresh == false
    if not test_passed then print("is_fresh", false, fat_id.is_fresh) end
    test_passed = test_passed and fat_id.elevation == -13
    if not test_passed then print("elevation", -13, fat_id.elevation) end
    test_passed = test_passed and fat_id.grass == 11
    if not test_passed then print("grass", 11, fat_id.grass) end
    test_passed = test_passed and fat_id.shrub == 8
    if not test_passed then print("shrub", 8, fat_id.shrub) end
    test_passed = test_passed and fat_id.conifer == 10
    if not test_passed then print("conifer", 10, fat_id.conifer) end
    test_passed = test_passed and fat_id.broadleaf == 4
    if not test_passed then print("broadleaf", 4, fat_id.broadleaf) end
    test_passed = test_passed and fat_id.ideal_grass == -7
    if not test_passed then print("ideal_grass", -7, fat_id.ideal_grass) end
    test_passed = test_passed and fat_id.ideal_shrub == -14
    if not test_passed then print("ideal_shrub", -14, fat_id.ideal_shrub) end
    test_passed = test_passed and fat_id.ideal_conifer == 11
    if not test_passed then print("ideal_conifer", 11, fat_id.ideal_conifer) end
    test_passed = test_passed and fat_id.ideal_broadleaf == -19
    if not test_passed then print("ideal_broadleaf", -19, fat_id.ideal_broadleaf) end
    test_passed = test_passed and fat_id.silt == 4
    if not test_passed then print("silt", 4, fat_id.silt) end
    test_passed = test_passed and fat_id.clay == 7
    if not test_passed then print("clay", 7, fat_id.clay) end
    test_passed = test_passed and fat_id.sand == 18
    if not test_passed then print("sand", 18, fat_id.sand) end
    test_passed = test_passed and fat_id.soil_minerals == -20
    if not test_passed then print("soil_minerals", -20, fat_id.soil_minerals) end
    test_passed = test_passed and fat_id.soil_organics == 8
    if not test_passed then print("soil_organics", 8, fat_id.soil_organics) end
    test_passed = test_passed and fat_id.january_waterflow == -3
    if not test_passed then print("january_waterflow", -3, fat_id.january_waterflow) end
    test_passed = test_passed and fat_id.july_waterflow == -6
    if not test_passed then print("july_waterflow", -6, fat_id.july_waterflow) end
    test_passed = test_passed and fat_id.waterlevel == 17
    if not test_passed then print("waterlevel", 17, fat_id.waterlevel) end
    test_passed = test_passed and fat_id.has_river == true
    if not test_passed then print("has_river", true, fat_id.has_river) end
    test_passed = test_passed and fat_id.has_marsh == false
    if not test_passed then print("has_marsh", false, fat_id.has_marsh) end
    test_passed = test_passed and fat_id.ice == -19
    if not test_passed then print("ice", -19, fat_id.ice) end
    test_passed = test_passed and fat_id.ice_age_ice == -19
    if not test_passed then print("ice_age_ice", -19, fat_id.ice_age_ice) end
    test_passed = test_passed and fat_id.debug_r == -19
    if not test_passed then print("debug_r", -19, fat_id.debug_r) end
    test_passed = test_passed and fat_id.debug_g == 14
    if not test_passed then print("debug_g", 14, fat_id.debug_g) end
    test_passed = test_passed and fat_id.debug_b == -20
    if not test_passed then print("debug_b", -20, fat_id.debug_b) end
    test_passed = test_passed and fat_id.real_r == 4
    if not test_passed then print("real_r", 4, fat_id.real_r) end
    test_passed = test_passed and fat_id.real_g == -7
    if not test_passed then print("real_g", -7, fat_id.real_g) end
    test_passed = test_passed and fat_id.real_b == 7
    if not test_passed then print("real_b", 7, fat_id.real_b) end
    test_passed = test_passed and fat_id.pathfinding_index == 0
    if not test_passed then print("pathfinding_index", 0, fat_id.pathfinding_index) end
    test_passed = test_passed and fat_id.resource == 16
    if not test_passed then print("resource", 16, fat_id.resource) end
    test_passed = test_passed and fat_id.bedrock == 7
    if not test_passed then print("bedrock", 7, fat_id.bedrock) end
    test_passed = test_passed and fat_id.biome == 14
    if not test_passed then print("biome", 14, fat_id.biome) end
    print("SET_GET_TEST_1_tile:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_pop()
    local fat_id = DATA.fatten_pop(id)
    fat_id.race = 4
    fat_id.female = true
    fat_id.age = 8
    fat_id.savings = -13
    fat_id.parent = 15
    fat_id.loyalty = 14
    fat_id.life_needs_satisfaction = 10
    fat_id.basic_needs_satisfaction = 4
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].need = 3
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].use_case = 3
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].consumed = 11
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].demanded = -19
    end
    for j = 0, 9 do
        DATA.pop[id].traits[j] = 6
    end
    fat_id.successor = 13
    for j = 0, 99 do
        DATA.pop[id].inventory[j] = 18
    end
    for j = 0, 99 do
        DATA.pop[id].price_memory[j] = -20
    end
    fat_id.forage_ratio = 8
    fat_id.work_ratio = -3
    fat_id.rank = 1
    for j = 0, 19 do
        DATA.pop[id].dna[j] = 17
    end
    local test_passed = true
    test_passed = test_passed and fat_id.race == 4
    if not test_passed then print("race", 4, fat_id.race) end
    test_passed = test_passed and fat_id.female == true
    if not test_passed then print("female", true, fat_id.female) end
    test_passed = test_passed and fat_id.age == 8
    if not test_passed then print("age", 8, fat_id.age) end
    test_passed = test_passed and fat_id.savings == -13
    if not test_passed then print("savings", -13, fat_id.savings) end
    test_passed = test_passed and fat_id.parent == 15
    if not test_passed then print("parent", 15, fat_id.parent) end
    test_passed = test_passed and fat_id.loyalty == 14
    if not test_passed then print("loyalty", 14, fat_id.loyalty) end
    test_passed = test_passed and fat_id.life_needs_satisfaction == 10
    if not test_passed then print("life_needs_satisfaction", 10, fat_id.life_needs_satisfaction) end
    test_passed = test_passed and fat_id.basic_needs_satisfaction == 4
    if not test_passed then print("basic_needs_satisfaction", 4, fat_id.basic_needs_satisfaction) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].need == 3
    end
    if not test_passed then print("need_satisfaction.need", 3, DATA.pop[id].need_satisfaction[0].need) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].use_case == 3
    end
    if not test_passed then print("need_satisfaction.use_case", 3, DATA.pop[id].need_satisfaction[0].use_case) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].consumed == 11
    end
    if not test_passed then print("need_satisfaction.consumed", 11, DATA.pop[id].need_satisfaction[0].consumed) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].demanded == -19
    end
    if not test_passed then print("need_satisfaction.demanded", -19, DATA.pop[id].need_satisfaction[0].demanded) end
    for j = 0, 9 do
        test_passed = test_passed and DATA.pop[id].traits[j] == 6
    end
    if not test_passed then print("traits", 6, DATA.pop[id].traits[0]) end
    test_passed = test_passed and fat_id.successor == 13
    if not test_passed then print("successor", 13, fat_id.successor) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[id].inventory[j] == 18
    end
    if not test_passed then print("inventory", 18, DATA.pop[id].inventory[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[id].price_memory[j] == -20
    end
    if not test_passed then print("price_memory", -20, DATA.pop[id].price_memory[0]) end
    test_passed = test_passed and fat_id.forage_ratio == 8
    if not test_passed then print("forage_ratio", 8, fat_id.forage_ratio) end
    test_passed = test_passed and fat_id.work_ratio == -3
    if not test_passed then print("work_ratio", -3, fat_id.work_ratio) end
    test_passed = test_passed and fat_id.rank == 1
    if not test_passed then print("rank", 1, fat_id.rank) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].dna[j] == 17
    end
    if not test_passed then print("dna", 17, DATA.pop[id].dna[0]) end
    print("SET_GET_TEST_1_pop:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_province()
    local fat_id = DATA.fatten_province(id)
    fat_id.r = -12
    fat_id.g = 16
    fat_id.b = -16
    fat_id.is_land = false
    fat_id.province_id = -13
    fat_id.size = 11
    fat_id.hydration = 8
    fat_id.movement_cost = 10
    fat_id.center = 20
    fat_id.infrastructure_needed = 4
    fat_id.infrastructure = -7
    fat_id.infrastructure_investment = -14
    for j = 0, 399 do
        DATA.province[id].technologies_present[j] = 15
    end
    for j = 0, 399 do
        DATA.province[id].technologies_researchable[j] = 0
    end
    for j = 0, 249 do
        DATA.province[id].buildable_buildings[j] = 12
    end
    for j = 0, 99 do
        DATA.province[id].local_production[j] = 7
    end
    for j = 0, 99 do
        DATA.province[id].local_consumption[j] = 18
    end
    for j = 0, 99 do
        DATA.province[id].local_demand[j] = -20
    end
    for j = 0, 99 do
        DATA.province[id].local_storage[j] = 8
    end
    for j = 0, 99 do
        DATA.province[id].local_prices[j] = -3
    end
    fat_id.local_wealth = -6
    fat_id.trade_wealth = 17
    fat_id.local_income = -14
    fat_id.local_building_upkeep = 0
    fat_id.foragers = -19
    fat_id.foragers_water = -19
    fat_id.foragers_limit = -19
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].output_good = 20
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].output_value = 14
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].amount = -20
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].forage = 6
    end
    for j = 0, 24 do
        DATA.province[id].local_resources[j].resource = 6
    end
    for j = 0, 24 do
        DATA.province[id].local_resources[j].location = 13
    end
    fat_id.mood = -19
    for j = 0, 19 do
        DATA.province[id].unit_types[j] = 16
    end
    for j = 0, 249 do
        DATA.province[id].throughput_boosts[j] = -6
    end
    for j = 0, 249 do
        DATA.province[id].input_efficiency_boosts[j] = 8
    end
    for j = 0, 249 do
        DATA.province[id].output_efficiency_boosts[j] = 11
    end
    fat_id.on_a_river = true
    fat_id.on_a_forest = false
    local test_passed = true
    test_passed = test_passed and fat_id.r == -12
    if not test_passed then print("r", -12, fat_id.r) end
    test_passed = test_passed and fat_id.g == 16
    if not test_passed then print("g", 16, fat_id.g) end
    test_passed = test_passed and fat_id.b == -16
    if not test_passed then print("b", -16, fat_id.b) end
    test_passed = test_passed and fat_id.is_land == false
    if not test_passed then print("is_land", false, fat_id.is_land) end
    test_passed = test_passed and fat_id.province_id == -13
    if not test_passed then print("province_id", -13, fat_id.province_id) end
    test_passed = test_passed and fat_id.size == 11
    if not test_passed then print("size", 11, fat_id.size) end
    test_passed = test_passed and fat_id.hydration == 8
    if not test_passed then print("hydration", 8, fat_id.hydration) end
    test_passed = test_passed and fat_id.movement_cost == 10
    if not test_passed then print("movement_cost", 10, fat_id.movement_cost) end
    test_passed = test_passed and fat_id.center == 20
    if not test_passed then print("center", 20, fat_id.center) end
    test_passed = test_passed and fat_id.infrastructure_needed == 4
    if not test_passed then print("infrastructure_needed", 4, fat_id.infrastructure_needed) end
    test_passed = test_passed and fat_id.infrastructure == -7
    if not test_passed then print("infrastructure", -7, fat_id.infrastructure) end
    test_passed = test_passed and fat_id.infrastructure_investment == -14
    if not test_passed then print("infrastructure_investment", -14, fat_id.infrastructure_investment) end
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[id].technologies_present[j] == 15
    end
    if not test_passed then print("technologies_present", 15, DATA.province[id].technologies_present[0]) end
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[id].technologies_researchable[j] == 0
    end
    if not test_passed then print("technologies_researchable", 0, DATA.province[id].technologies_researchable[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].buildable_buildings[j] == 12
    end
    if not test_passed then print("buildable_buildings", 12, DATA.province[id].buildable_buildings[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_production[j] == 7
    end
    if not test_passed then print("local_production", 7, DATA.province[id].local_production[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_consumption[j] == 18
    end
    if not test_passed then print("local_consumption", 18, DATA.province[id].local_consumption[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_demand[j] == -20
    end
    if not test_passed then print("local_demand", -20, DATA.province[id].local_demand[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_storage[j] == 8
    end
    if not test_passed then print("local_storage", 8, DATA.province[id].local_storage[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_prices[j] == -3
    end
    if not test_passed then print("local_prices", -3, DATA.province[id].local_prices[0]) end
    test_passed = test_passed and fat_id.local_wealth == -6
    if not test_passed then print("local_wealth", -6, fat_id.local_wealth) end
    test_passed = test_passed and fat_id.trade_wealth == 17
    if not test_passed then print("trade_wealth", 17, fat_id.trade_wealth) end
    test_passed = test_passed and fat_id.local_income == -14
    if not test_passed then print("local_income", -14, fat_id.local_income) end
    test_passed = test_passed and fat_id.local_building_upkeep == 0
    if not test_passed then print("local_building_upkeep", 0, fat_id.local_building_upkeep) end
    test_passed = test_passed and fat_id.foragers == -19
    if not test_passed then print("foragers", -19, fat_id.foragers) end
    test_passed = test_passed and fat_id.foragers_water == -19
    if not test_passed then print("foragers_water", -19, fat_id.foragers_water) end
    test_passed = test_passed and fat_id.foragers_limit == -19
    if not test_passed then print("foragers_limit", -19, fat_id.foragers_limit) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].output_good == 20
    end
    if not test_passed then print("foragers_targets.output_good", 20, DATA.province[id].foragers_targets[0].output_good) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].output_value == 14
    end
    if not test_passed then print("foragers_targets.output_value", 14, DATA.province[id].foragers_targets[0].output_value) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].amount == -20
    end
    if not test_passed then print("foragers_targets.amount", -20, DATA.province[id].foragers_targets[0].amount) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].forage == 6
    end
    if not test_passed then print("foragers_targets.forage", 6, DATA.province[id].foragers_targets[0].forage) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].local_resources[j].resource == 6
    end
    if not test_passed then print("local_resources.resource", 6, DATA.province[id].local_resources[0].resource) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].local_resources[j].location == 13
    end
    if not test_passed then print("local_resources.location", 13, DATA.province[id].local_resources[0].location) end
    test_passed = test_passed and fat_id.mood == -19
    if not test_passed then print("mood", -19, fat_id.mood) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.province[id].unit_types[j] == 16
    end
    if not test_passed then print("unit_types", 16, DATA.province[id].unit_types[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].throughput_boosts[j] == -6
    end
    if not test_passed then print("throughput_boosts", -6, DATA.province[id].throughput_boosts[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].input_efficiency_boosts[j] == 8
    end
    if not test_passed then print("input_efficiency_boosts", 8, DATA.province[id].input_efficiency_boosts[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].output_efficiency_boosts[j] == 11
    end
    if not test_passed then print("output_efficiency_boosts", 11, DATA.province[id].output_efficiency_boosts[0]) end
    test_passed = test_passed and fat_id.on_a_river == true
    if not test_passed then print("on_a_river", true, fat_id.on_a_river) end
    test_passed = test_passed and fat_id.on_a_forest == false
    if not test_passed then print("on_a_forest", false, fat_id.on_a_forest) end
    print("SET_GET_TEST_1_province:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_army()
    local fat_id = DATA.fatten_army(id)
    fat_id.destination = 4
    local test_passed = true
    test_passed = test_passed and fat_id.destination == 4
    if not test_passed then print("destination", 4, fat_id.destination) end
    print("SET_GET_TEST_1_army:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband()
    local fat_id = DATA.fatten_warband(id)
    for j = 0, 19 do
        DATA.warband[id].units_current[j] = -12
    end
    for j = 0, 19 do
        DATA.warband[id].units_target[j] = 16
    end
    fat_id.status = 1
    fat_id.idle_stance = 1
    fat_id.current_free_time_ratio = -13
    fat_id.treasury = 11
    fat_id.total_upkeep = 8
    fat_id.predicted_upkeep = 10
    fat_id.supplies = 4
    fat_id.supplies_target_days = -7
    fat_id.morale = -14
    local test_passed = true
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[id].units_current[j] == -12
    end
    if not test_passed then print("units_current", -12, DATA.warband[id].units_current[0]) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[id].units_target[j] == 16
    end
    if not test_passed then print("units_target", 16, DATA.warband[id].units_target[0]) end
    test_passed = test_passed and fat_id.status == 1
    if not test_passed then print("status", 1, fat_id.status) end
    test_passed = test_passed and fat_id.idle_stance == 1
    if not test_passed then print("idle_stance", 1, fat_id.idle_stance) end
    test_passed = test_passed and fat_id.current_free_time_ratio == -13
    if not test_passed then print("current_free_time_ratio", -13, fat_id.current_free_time_ratio) end
    test_passed = test_passed and fat_id.treasury == 11
    if not test_passed then print("treasury", 11, fat_id.treasury) end
    test_passed = test_passed and fat_id.total_upkeep == 8
    if not test_passed then print("total_upkeep", 8, fat_id.total_upkeep) end
    test_passed = test_passed and fat_id.predicted_upkeep == 10
    if not test_passed then print("predicted_upkeep", 10, fat_id.predicted_upkeep) end
    test_passed = test_passed and fat_id.supplies == 4
    if not test_passed then print("supplies", 4, fat_id.supplies) end
    test_passed = test_passed and fat_id.supplies_target_days == -7
    if not test_passed then print("supplies_target_days", -7, fat_id.supplies_target_days) end
    test_passed = test_passed and fat_id.morale == -14
    if not test_passed then print("morale", -14, fat_id.morale) end
    print("SET_GET_TEST_1_warband:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm()
    local fat_id = DATA.fatten_realm(id)
    fat_id.budget_change = -12
    fat_id.budget_saved_change = 16
    for j = 0, 37 do
        DATA.realm[id].budget_spending_by_category[j] = -16
    end
    for j = 0, 37 do
        DATA.realm[id].budget_income_by_category[j] = -4
    end
    for j = 0, 37 do
        DATA.realm[id].budget_treasury_change_by_category[j] = -13
    end
    fat_id.budget_treasury = 11
    fat_id.budget_treasury_target = 8
    for j = 0, 6 do
        DATA.realm[id].budget[j].ratio = 10
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].budget = 4
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].to_be_invested = -7
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].target = -14
    end
    fat_id.budget_tax_target = 11
    fat_id.budget_tax_collected_this_year = -19
    fat_id.r = 4
    fat_id.g = 7
    fat_id.b = 18
    fat_id.primary_race = 0
    fat_id.capitol = 14
    fat_id.trading_right_cost = -3
    fat_id.building_right_cost = -6
    fat_id.prepare_attack_flag = true
    fat_id.coa_base_r = 0
    fat_id.coa_base_g = -19
    fat_id.coa_base_b = -19
    fat_id.coa_background_r = -19
    fat_id.coa_background_g = 14
    fat_id.coa_background_b = -20
    fat_id.coa_foreground_r = 4
    fat_id.coa_foreground_g = -7
    fat_id.coa_foreground_b = 7
    fat_id.coa_emblem_r = -19
    fat_id.coa_emblem_g = 13
    fat_id.coa_emblem_b = -6
    fat_id.coa_background_image = 14
    fat_id.coa_foreground_image = 15
    fat_id.coa_emblem_image = 17
    for j = 0, 99 do
        DATA.realm[id].resources[j] = -6
    end
    for j = 0, 99 do
        DATA.realm[id].production[j] = 2
    end
    for j = 0, 99 do
        DATA.realm[id].bought[j] = -6
    end
    for j = 0, 99 do
        DATA.realm[id].sold[j] = -6
    end
    fat_id.expected_food_consumption = 9
    local test_passed = true
    test_passed = test_passed and fat_id.budget_change == -12
    if not test_passed then print("budget_change", -12, fat_id.budget_change) end
    test_passed = test_passed and fat_id.budget_saved_change == 16
    if not test_passed then print("budget_saved_change", 16, fat_id.budget_saved_change) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_spending_by_category[j] == -16
    end
    if not test_passed then print("budget_spending_by_category", -16, DATA.realm[id].budget_spending_by_category[0]) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_income_by_category[j] == -4
    end
    if not test_passed then print("budget_income_by_category", -4, DATA.realm[id].budget_income_by_category[0]) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_treasury_change_by_category[j] == -13
    end
    if not test_passed then print("budget_treasury_change_by_category", -13, DATA.realm[id].budget_treasury_change_by_category[0]) end
    test_passed = test_passed and fat_id.budget_treasury == 11
    if not test_passed then print("budget_treasury", 11, fat_id.budget_treasury) end
    test_passed = test_passed and fat_id.budget_treasury_target == 8
    if not test_passed then print("budget_treasury_target", 8, fat_id.budget_treasury_target) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].ratio == 10
    end
    if not test_passed then print("budget.ratio", 10, DATA.realm[id].budget[0].ratio) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].budget == 4
    end
    if not test_passed then print("budget.budget", 4, DATA.realm[id].budget[0].budget) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].to_be_invested == -7
    end
    if not test_passed then print("budget.to_be_invested", -7, DATA.realm[id].budget[0].to_be_invested) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].target == -14
    end
    if not test_passed then print("budget.target", -14, DATA.realm[id].budget[0].target) end
    test_passed = test_passed and fat_id.budget_tax_target == 11
    if not test_passed then print("budget_tax_target", 11, fat_id.budget_tax_target) end
    test_passed = test_passed and fat_id.budget_tax_collected_this_year == -19
    if not test_passed then print("budget_tax_collected_this_year", -19, fat_id.budget_tax_collected_this_year) end
    test_passed = test_passed and fat_id.r == 4
    if not test_passed then print("r", 4, fat_id.r) end
    test_passed = test_passed and fat_id.g == 7
    if not test_passed then print("g", 7, fat_id.g) end
    test_passed = test_passed and fat_id.b == 18
    if not test_passed then print("b", 18, fat_id.b) end
    test_passed = test_passed and fat_id.primary_race == 0
    if not test_passed then print("primary_race", 0, fat_id.primary_race) end
    test_passed = test_passed and fat_id.capitol == 14
    if not test_passed then print("capitol", 14, fat_id.capitol) end
    test_passed = test_passed and fat_id.trading_right_cost == -3
    if not test_passed then print("trading_right_cost", -3, fat_id.trading_right_cost) end
    test_passed = test_passed and fat_id.building_right_cost == -6
    if not test_passed then print("building_right_cost", -6, fat_id.building_right_cost) end
    test_passed = test_passed and fat_id.prepare_attack_flag == true
    if not test_passed then print("prepare_attack_flag", true, fat_id.prepare_attack_flag) end
    test_passed = test_passed and fat_id.coa_base_r == 0
    if not test_passed then print("coa_base_r", 0, fat_id.coa_base_r) end
    test_passed = test_passed and fat_id.coa_base_g == -19
    if not test_passed then print("coa_base_g", -19, fat_id.coa_base_g) end
    test_passed = test_passed and fat_id.coa_base_b == -19
    if not test_passed then print("coa_base_b", -19, fat_id.coa_base_b) end
    test_passed = test_passed and fat_id.coa_background_r == -19
    if not test_passed then print("coa_background_r", -19, fat_id.coa_background_r) end
    test_passed = test_passed and fat_id.coa_background_g == 14
    if not test_passed then print("coa_background_g", 14, fat_id.coa_background_g) end
    test_passed = test_passed and fat_id.coa_background_b == -20
    if not test_passed then print("coa_background_b", -20, fat_id.coa_background_b) end
    test_passed = test_passed and fat_id.coa_foreground_r == 4
    if not test_passed then print("coa_foreground_r", 4, fat_id.coa_foreground_r) end
    test_passed = test_passed and fat_id.coa_foreground_g == -7
    if not test_passed then print("coa_foreground_g", -7, fat_id.coa_foreground_g) end
    test_passed = test_passed and fat_id.coa_foreground_b == 7
    if not test_passed then print("coa_foreground_b", 7, fat_id.coa_foreground_b) end
    test_passed = test_passed and fat_id.coa_emblem_r == -19
    if not test_passed then print("coa_emblem_r", -19, fat_id.coa_emblem_r) end
    test_passed = test_passed and fat_id.coa_emblem_g == 13
    if not test_passed then print("coa_emblem_g", 13, fat_id.coa_emblem_g) end
    test_passed = test_passed and fat_id.coa_emblem_b == -6
    if not test_passed then print("coa_emblem_b", -6, fat_id.coa_emblem_b) end
    test_passed = test_passed and fat_id.coa_background_image == 14
    if not test_passed then print("coa_background_image", 14, fat_id.coa_background_image) end
    test_passed = test_passed and fat_id.coa_foreground_image == 15
    if not test_passed then print("coa_foreground_image", 15, fat_id.coa_foreground_image) end
    test_passed = test_passed and fat_id.coa_emblem_image == 17
    if not test_passed then print("coa_emblem_image", 17, fat_id.coa_emblem_image) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].resources[j] == -6
    end
    if not test_passed then print("resources", -6, DATA.realm[id].resources[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].production[j] == 2
    end
    if not test_passed then print("production", 2, DATA.realm[id].production[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].bought[j] == -6
    end
    if not test_passed then print("bought", -6, DATA.realm[id].bought[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].sold[j] == -6
    end
    if not test_passed then print("sold", -6, DATA.realm[id].sold[0]) end
    test_passed = test_passed and fat_id.expected_food_consumption == 9
    if not test_passed then print("expected_food_consumption", 9, fat_id.expected_food_consumption) end
    print("SET_GET_TEST_1_realm:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_negotiation()
    local fat_id = DATA.fatten_negotiation(id)
    local test_passed = true
    print("SET_GET_TEST_1_negotiation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_building()
    local fat_id = DATA.fatten_building(id)
    fat_id.type = 4
    for j = 0, 7 do
        DATA.building[id].spent_on_inputs[j].good = 18
    end
    for j = 0, 7 do
        DATA.building[id].spent_on_inputs[j].amount = -16
    end
    for j = 0, 7 do
        DATA.building[id].earn_from_outputs[j].good = 8
    end
    for j = 0, 7 do
        DATA.building[id].earn_from_outputs[j].amount = -13
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_inputs[j].good = 15
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_inputs[j].amount = 8
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_outputs[j].good = 15
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_outputs[j].amount = 4
    end
    local test_passed = true
    test_passed = test_passed and fat_id.type == 4
    if not test_passed then print("type", 4, fat_id.type) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].spent_on_inputs[j].good == 18
    end
    if not test_passed then print("spent_on_inputs.good", 18, DATA.building[id].spent_on_inputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].spent_on_inputs[j].amount == -16
    end
    if not test_passed then print("spent_on_inputs.amount", -16, DATA.building[id].spent_on_inputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].earn_from_outputs[j].good == 8
    end
    if not test_passed then print("earn_from_outputs.good", 8, DATA.building[id].earn_from_outputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].earn_from_outputs[j].amount == -13
    end
    if not test_passed then print("earn_from_outputs.amount", -13, DATA.building[id].earn_from_outputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_inputs[j].good == 15
    end
    if not test_passed then print("amount_of_inputs.good", 15, DATA.building[id].amount_of_inputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_inputs[j].amount == 8
    end
    if not test_passed then print("amount_of_inputs.amount", 8, DATA.building[id].amount_of_inputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_outputs[j].good == 15
    end
    if not test_passed then print("amount_of_outputs.good", 15, DATA.building[id].amount_of_outputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_outputs[j].amount == 4
    end
    if not test_passed then print("amount_of_outputs.amount", 4, DATA.building[id].amount_of_outputs[0].amount) end
    print("SET_GET_TEST_1_building:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_ownership()
    local fat_id = DATA.fatten_ownership(id)
    local test_passed = true
    print("SET_GET_TEST_1_ownership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_employment()
    local fat_id = DATA.fatten_employment(id)
    fat_id.worker_income = -12
    fat_id.job = 18
    local test_passed = true
    test_passed = test_passed and fat_id.worker_income == -12
    if not test_passed then print("worker_income", -12, fat_id.worker_income) end
    test_passed = test_passed and fat_id.job == 18
    if not test_passed then print("job", 18, fat_id.job) end
    print("SET_GET_TEST_1_employment:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_building_location()
    local fat_id = DATA.fatten_building_location(id)
    local test_passed = true
    print("SET_GET_TEST_1_building_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_army_membership()
    local fat_id = DATA.fatten_army_membership(id)
    local test_passed = true
    print("SET_GET_TEST_1_army_membership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_leader()
    local fat_id = DATA.fatten_warband_leader(id)
    local test_passed = true
    print("SET_GET_TEST_1_warband_leader:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_recruiter()
    local fat_id = DATA.fatten_warband_recruiter(id)
    local test_passed = true
    print("SET_GET_TEST_1_warband_recruiter:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_commander()
    local fat_id = DATA.fatten_warband_commander(id)
    local test_passed = true
    print("SET_GET_TEST_1_warband_commander:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_location()
    local fat_id = DATA.fatten_warband_location(id)
    local test_passed = true
    print("SET_GET_TEST_1_warband_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_unit()
    local fat_id = DATA.fatten_warband_unit(id)
    fat_id.type = 4
    local test_passed = true
    test_passed = test_passed and fat_id.type == 4
    if not test_passed then print("type", 4, fat_id.type) end
    print("SET_GET_TEST_1_warband_unit:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_character_location()
    local fat_id = DATA.fatten_character_location(id)
    local test_passed = true
    print("SET_GET_TEST_1_character_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_home()
    local fat_id = DATA.fatten_home(id)
    local test_passed = true
    print("SET_GET_TEST_1_home:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_pop_location()
    local fat_id = DATA.fatten_pop_location(id)
    local test_passed = true
    print("SET_GET_TEST_1_pop_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_outlaw_location()
    local fat_id = DATA.fatten_outlaw_location(id)
    local test_passed = true
    print("SET_GET_TEST_1_outlaw_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_tile_province_membership()
    local fat_id = DATA.fatten_tile_province_membership(id)
    local test_passed = true
    print("SET_GET_TEST_1_tile_province_membership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_province_neighborhood()
    local fat_id = DATA.fatten_province_neighborhood(id)
    local test_passed = true
    print("SET_GET_TEST_1_province_neighborhood:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_parent_child_relation()
    local fat_id = DATA.fatten_parent_child_relation(id)
    local test_passed = true
    print("SET_GET_TEST_1_parent_child_relation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_loyalty()
    local fat_id = DATA.fatten_loyalty(id)
    local test_passed = true
    print("SET_GET_TEST_1_loyalty:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_succession()
    local fat_id = DATA.fatten_succession(id)
    local test_passed = true
    print("SET_GET_TEST_1_succession:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_armies()
    local fat_id = DATA.fatten_realm_armies(id)
    local test_passed = true
    print("SET_GET_TEST_1_realm_armies:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_guard()
    local fat_id = DATA.fatten_realm_guard(id)
    local test_passed = true
    print("SET_GET_TEST_1_realm_guard:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_overseer()
    local fat_id = DATA.fatten_realm_overseer(id)
    local test_passed = true
    print("SET_GET_TEST_1_realm_overseer:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_leadership()
    local fat_id = DATA.fatten_realm_leadership(id)
    local test_passed = true
    print("SET_GET_TEST_1_realm_leadership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_subject_relation()
    local fat_id = DATA.fatten_realm_subject_relation(id)
    fat_id.wealth_transfer = true
    fat_id.goods_transfer = true
    fat_id.warriors_contribution = false
    fat_id.protection = true
    fat_id.local_ruler = false
    local test_passed = true
    test_passed = test_passed and fat_id.wealth_transfer == true
    if not test_passed then print("wealth_transfer", true, fat_id.wealth_transfer) end
    test_passed = test_passed and fat_id.goods_transfer == true
    if not test_passed then print("goods_transfer", true, fat_id.goods_transfer) end
    test_passed = test_passed and fat_id.warriors_contribution == false
    if not test_passed then print("warriors_contribution", false, fat_id.warriors_contribution) end
    test_passed = test_passed and fat_id.protection == true
    if not test_passed then print("protection", true, fat_id.protection) end
    test_passed = test_passed and fat_id.local_ruler == false
    if not test_passed then print("local_ruler", false, fat_id.local_ruler) end
    print("SET_GET_TEST_1_realm_subject_relation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_tax_collector()
    local fat_id = DATA.fatten_tax_collector(id)
    local test_passed = true
    print("SET_GET_TEST_1_tax_collector:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_personal_rights()
    local fat_id = DATA.fatten_personal_rights(id)
    fat_id.can_trade = true
    fat_id.can_build = true
    local test_passed = true
    test_passed = test_passed and fat_id.can_trade == true
    if not test_passed then print("can_trade", true, fat_id.can_trade) end
    test_passed = test_passed and fat_id.can_build == true
    if not test_passed then print("can_build", true, fat_id.can_build) end
    print("SET_GET_TEST_1_personal_rights:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_provinces()
    local fat_id = DATA.fatten_realm_provinces(id)
    local test_passed = true
    print("SET_GET_TEST_1_realm_provinces:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_popularity()
    local fat_id = DATA.fatten_popularity(id)
    fat_id.value = -12
    local test_passed = true
    test_passed = test_passed and fat_id.value == -12
    if not test_passed then print("value", -12, fat_id.value) end
    print("SET_GET_TEST_1_popularity:")
    if test_passed then print("PASSED") else print("ERROR") end
end
function DATA.test_save_load_2()
    print("tile world_id")
    for i = 0, 1500000 do
        DATA.tile[i].world_id = 1
    end
    print("tile is_land")
    for i = 0, 1500000 do
        DATA.tile[i].is_land = true
    end
    print("tile is_fresh")
    for i = 0, 1500000 do
        DATA.tile[i].is_fresh = true
    end
    print("tile elevation")
    for i = 0, 1500000 do
        DATA.tile[i].elevation = 3
    end
    print("tile grass")
    for i = 0, 1500000 do
        DATA.tile[i].grass = -10
    end
    print("tile shrub")
    for i = 0, 1500000 do
        DATA.tile[i].shrub = -1
    end
    print("tile conifer")
    for i = 0, 1500000 do
        DATA.tile[i].conifer = -4
    end
    print("tile broadleaf")
    for i = 0, 1500000 do
        DATA.tile[i].broadleaf = 18
    end
    print("tile ideal_grass")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_grass = -7
    end
    print("tile ideal_shrub")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_shrub = 18
    end
    print("tile ideal_conifer")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_conifer = -18
    end
    print("tile ideal_broadleaf")
    for i = 0, 1500000 do
        DATA.tile[i].ideal_broadleaf = 17
    end
    print("tile silt")
    for i = 0, 1500000 do
        DATA.tile[i].silt = -10
    end
    print("tile clay")
    for i = 0, 1500000 do
        DATA.tile[i].clay = 7
    end
    print("tile sand")
    for i = 0, 1500000 do
        DATA.tile[i].sand = 20
    end
    print("tile soil_minerals")
    for i = 0, 1500000 do
        DATA.tile[i].soil_minerals = 5
    end
    print("tile soil_organics")
    for i = 0, 1500000 do
        DATA.tile[i].soil_organics = 12
    end
    print("tile january_waterflow")
    for i = 0, 1500000 do
        DATA.tile[i].january_waterflow = 3
    end
    print("tile july_waterflow")
    for i = 0, 1500000 do
        DATA.tile[i].july_waterflow = 14
    end
    print("tile waterlevel")
    for i = 0, 1500000 do
        DATA.tile[i].waterlevel = 8
    end
    print("tile has_river")
    for i = 0, 1500000 do
        DATA.tile[i].has_river = false
    end
    print("tile has_marsh")
    for i = 0, 1500000 do
        DATA.tile[i].has_marsh = true
    end
    print("tile ice")
    for i = 0, 1500000 do
        DATA.tile[i].ice = -19
    end
    print("tile ice_age_ice")
    for i = 0, 1500000 do
        DATA.tile[i].ice_age_ice = 3
    end
    print("tile debug_r")
    for i = 0, 1500000 do
        DATA.tile[i].debug_r = 9
    end
    print("tile debug_g")
    for i = 0, 1500000 do
        DATA.tile[i].debug_g = 0
    end
    print("tile debug_b")
    for i = 0, 1500000 do
        DATA.tile[i].debug_b = 4
    end
    print("tile real_r")
    for i = 0, 1500000 do
        DATA.tile[i].real_r = 7
    end
    print("tile real_g")
    for i = 0, 1500000 do
        DATA.tile[i].real_g = 13
    end
    print("tile real_b")
    for i = 0, 1500000 do
        DATA.tile[i].real_b = -10
    end
    print("tile pathfinding_index")
    for i = 0, 1500000 do
        DATA.tile[i].pathfinding_index = 17
    end
    print("tile resource")
    for i = 0, 1500000 do
        DATA.tile[i].resource = 5
    end
    print("tile bedrock")
    for i = 0, 1500000 do
        DATA.tile[i].bedrock = 7
    end
    print("tile biome")
    for i = 0, 1500000 do
        DATA.tile[i].biome = 7
    end
    print("pop race")
    for i = 0, 300000 do
        DATA.pop[i].race = 0
    end
    print("pop female")
    for i = 0, 300000 do
        DATA.pop[i].female = true
    end
    print("pop age")
    for i = 0, 300000 do
        DATA.pop[i].age = 10
    end
    print("pop savings")
    for i = 0, 300000 do
        DATA.pop[i].savings = -9
    end
    print("pop parent")
    for i = 0, 300000 do
        DATA.pop[i].parent = 4
    end
    print("pop loyalty")
    for i = 0, 300000 do
        DATA.pop[i].loyalty = 16
    end
    print("pop life_needs_satisfaction")
    for i = 0, 300000 do
        DATA.pop[i].life_needs_satisfaction = 12
    end
    print("pop basic_needs_satisfaction")
    for i = 0, 300000 do
        DATA.pop[i].basic_needs_satisfaction = 3
    end
    print("pop need_satisfaction")
    for i = 0, 300000 do
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].need = 2
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].use_case = 14
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].consumed = 6
    end
    for j = 0, 19 do
        DATA.pop[i].need_satisfaction[j].demanded = 13
    end
    end
    print("pop traits")
    for i = 0, 300000 do
    for j = 0, 9 do
        DATA.pop[i].traits[j] = 5
    end
    end
    print("pop successor")
    for i = 0, 300000 do
        DATA.pop[i].successor = 18
    end
    print("pop inventory")
    for i = 0, 300000 do
    for j = 0, 99 do
        DATA.pop[i].inventory[j] = 2
    end
    end
    print("pop price_memory")
    for i = 0, 300000 do
    for j = 0, 99 do
        DATA.pop[i].price_memory[j] = 3
    end
    end
    print("pop forage_ratio")
    for i = 0, 300000 do
        DATA.pop[i].forage_ratio = 8
    end
    print("pop work_ratio")
    for i = 0, 300000 do
        DATA.pop[i].work_ratio = -10
    end
    print("pop rank")
    for i = 0, 300000 do
        DATA.pop[i].rank = 3
    end
    print("pop dna")
    for i = 0, 300000 do
    for j = 0, 19 do
        DATA.pop[i].dna[j] = 9
    end
    end
    print("province r")
    for i = 0, 20000 do
        DATA.province[i].r = 13
    end
    print("province g")
    for i = 0, 20000 do
        DATA.province[i].g = -5
    end
    print("province b")
    for i = 0, 20000 do
        DATA.province[i].b = 11
    end
    print("province is_land")
    for i = 0, 20000 do
        DATA.province[i].is_land = false
    end
    print("province province_id")
    for i = 0, 20000 do
        DATA.province[i].province_id = 11
    end
    print("province size")
    for i = 0, 20000 do
        DATA.province[i].size = 12
    end
    print("province hydration")
    for i = 0, 20000 do
        DATA.province[i].hydration = 12
    end
    print("province movement_cost")
    for i = 0, 20000 do
        DATA.province[i].movement_cost = 2
    end
    print("province center")
    for i = 0, 20000 do
        DATA.province[i].center = 14
    end
    print("province infrastructure_needed")
    for i = 0, 20000 do
        DATA.province[i].infrastructure_needed = 9
    end
    print("province infrastructure")
    for i = 0, 20000 do
        DATA.province[i].infrastructure = 2
    end
    print("province infrastructure_investment")
    for i = 0, 20000 do
        DATA.province[i].infrastructure_investment = 16
    end
    print("province technologies_present")
    for i = 0, 20000 do
    for j = 0, 399 do
        DATA.province[i].technologies_present[j] = 17
    end
    end
    print("province technologies_researchable")
    for i = 0, 20000 do
    for j = 0, 399 do
        DATA.province[i].technologies_researchable[j] = 14
    end
    end
    print("province buildable_buildings")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].buildable_buildings[j] = 15
    end
    end
    print("province local_production")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_production[j] = -6
    end
    end
    print("province local_consumption")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_consumption[j] = 0
    end
    end
    print("province local_demand")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_demand[j] = -10
    end
    end
    print("province local_storage")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_storage[j] = 19
    end
    end
    print("province local_prices")
    for i = 0, 20000 do
    for j = 0, 99 do
        DATA.province[i].local_prices[j] = -3
    end
    end
    print("province local_wealth")
    for i = 0, 20000 do
        DATA.province[i].local_wealth = 10
    end
    print("province trade_wealth")
    for i = 0, 20000 do
        DATA.province[i].trade_wealth = -1
    end
    print("province local_income")
    for i = 0, 20000 do
        DATA.province[i].local_income = -1
    end
    print("province local_building_upkeep")
    for i = 0, 20000 do
        DATA.province[i].local_building_upkeep = 12
    end
    print("province foragers")
    for i = 0, 20000 do
        DATA.province[i].foragers = 15
    end
    print("province foragers_water")
    for i = 0, 20000 do
        DATA.province[i].foragers_water = 13
    end
    print("province foragers_limit")
    for i = 0, 20000 do
        DATA.province[i].foragers_limit = 12
    end
    print("province foragers_targets")
    for i = 0, 20000 do
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].output_good = 20
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].output_value = 19
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].amount = 17
    end
    for j = 0, 24 do
        DATA.province[i].foragers_targets[j].forage = 6
    end
    end
    print("province local_resources")
    for i = 0, 20000 do
    for j = 0, 24 do
        DATA.province[i].local_resources[j].resource = 9
    end
    for j = 0, 24 do
        DATA.province[i].local_resources[j].location = 6
    end
    end
    print("province mood")
    for i = 0, 20000 do
        DATA.province[i].mood = 11
    end
    print("province unit_types")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.province[i].unit_types[j] = 16
    end
    end
    print("province throughput_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].throughput_boosts[j] = 3
    end
    end
    print("province input_efficiency_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].input_efficiency_boosts[j] = 19
    end
    end
    print("province output_efficiency_boosts")
    for i = 0, 20000 do
    for j = 0, 249 do
        DATA.province[i].output_efficiency_boosts[j] = -16
    end
    end
    print("province on_a_river")
    for i = 0, 20000 do
        DATA.province[i].on_a_river = false
    end
    print("province on_a_forest")
    for i = 0, 20000 do
        DATA.province[i].on_a_forest = true
    end
    print("army destination")
    for i = 0, 5000 do
        DATA.army[i].destination = 6
    end
    print("warband units_current")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.warband[i].units_current[j] = -14
    end
    end
    print("warband units_target")
    for i = 0, 20000 do
    for j = 0, 19 do
        DATA.warband[i].units_target[j] = -17
    end
    end
    print("warband status")
    for i = 0, 20000 do
        DATA.warband[i].status = 0
    end
    print("warband idle_stance")
    for i = 0, 20000 do
        DATA.warband[i].idle_stance = 1
    end
    print("warband current_free_time_ratio")
    for i = 0, 20000 do
        DATA.warband[i].current_free_time_ratio = 17
    end
    print("warband treasury")
    for i = 0, 20000 do
        DATA.warband[i].treasury = -6
    end
    print("warband total_upkeep")
    for i = 0, 20000 do
        DATA.warband[i].total_upkeep = -14
    end
    print("warband predicted_upkeep")
    for i = 0, 20000 do
        DATA.warband[i].predicted_upkeep = 13
    end
    print("warband supplies")
    for i = 0, 20000 do
        DATA.warband[i].supplies = -12
    end
    print("warband supplies_target_days")
    for i = 0, 20000 do
        DATA.warband[i].supplies_target_days = -3
    end
    print("warband morale")
    for i = 0, 20000 do
        DATA.warband[i].morale = -5
    end
    print("realm budget_change")
    for i = 0, 15000 do
        DATA.realm[i].budget_change = -7
    end
    print("realm budget_saved_change")
    for i = 0, 15000 do
        DATA.realm[i].budget_saved_change = -17
    end
    print("realm budget_spending_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_spending_by_category[j] = 7
    end
    end
    print("realm budget_income_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_income_by_category[j] = -18
    end
    end
    print("realm budget_treasury_change_by_category")
    for i = 0, 15000 do
    for j = 0, 37 do
        DATA.realm[i].budget_treasury_change_by_category[j] = -17
    end
    end
    print("realm budget_treasury")
    for i = 0, 15000 do
        DATA.realm[i].budget_treasury = 3
    end
    print("realm budget_treasury_target")
    for i = 0, 15000 do
        DATA.realm[i].budget_treasury_target = 3
    end
    print("realm budget")
    for i = 0, 15000 do
    for j = 0, 6 do
        DATA.realm[i].budget[j].ratio = -9
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].budget = -5
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].to_be_invested = -19
    end
    for j = 0, 6 do
        DATA.realm[i].budget[j].target = -15
    end
    end
    print("realm budget_tax_target")
    for i = 0, 15000 do
        DATA.realm[i].budget_tax_target = -13
    end
    print("realm budget_tax_collected_this_year")
    for i = 0, 15000 do
        DATA.realm[i].budget_tax_collected_this_year = -16
    end
    print("realm r")
    for i = 0, 15000 do
        DATA.realm[i].r = -19
    end
    print("realm g")
    for i = 0, 15000 do
        DATA.realm[i].g = -18
    end
    print("realm b")
    for i = 0, 15000 do
        DATA.realm[i].b = -19
    end
    print("realm primary_race")
    for i = 0, 15000 do
        DATA.realm[i].primary_race = 11
    end
    print("realm capitol")
    for i = 0, 15000 do
        DATA.realm[i].capitol = 8
    end
    print("realm trading_right_cost")
    for i = 0, 15000 do
        DATA.realm[i].trading_right_cost = -12
    end
    print("realm building_right_cost")
    for i = 0, 15000 do
        DATA.realm[i].building_right_cost = -10
    end
    print("realm prepare_attack_flag")
    for i = 0, 15000 do
        DATA.realm[i].prepare_attack_flag = true
    end
    print("realm coa_base_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_r = 13
    end
    print("realm coa_base_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_g = -20
    end
    print("realm coa_base_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_base_b = 4
    end
    print("realm coa_background_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_r = 17
    end
    print("realm coa_background_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_g = -18
    end
    print("realm coa_background_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_b = -5
    end
    print("realm coa_foreground_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_r = -11
    end
    print("realm coa_foreground_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_g = -18
    end
    print("realm coa_foreground_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_b = -20
    end
    print("realm coa_emblem_r")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_r = 2
    end
    print("realm coa_emblem_g")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_g = 19
    end
    print("realm coa_emblem_b")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_b = 20
    end
    print("realm coa_background_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_background_image = 3
    end
    print("realm coa_foreground_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_foreground_image = 9
    end
    print("realm coa_emblem_image")
    for i = 0, 15000 do
        DATA.realm[i].coa_emblem_image = 10
    end
    print("realm resources")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].resources[j] = 11
    end
    end
    print("realm production")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].production[j] = -19
    end
    end
    print("realm bought")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].bought[j] = -1
    end
    end
    print("realm sold")
    for i = 0, 15000 do
    for j = 0, 99 do
        DATA.realm[i].sold[j] = 8
    end
    end
    print("realm expected_food_consumption")
    for i = 0, 15000 do
        DATA.realm[i].expected_food_consumption = 15
    end
    print("building type")
    for i = 0, 200000 do
        DATA.building[i].type = 19
    end
    print("building spent_on_inputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].spent_on_inputs[j].good = 1
    end
    for j = 0, 7 do
        DATA.building[i].spent_on_inputs[j].amount = -4
    end
    end
    print("building earn_from_outputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].earn_from_outputs[j].good = 12
    end
    for j = 0, 7 do
        DATA.building[i].earn_from_outputs[j].amount = 19
    end
    end
    print("building amount_of_inputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].amount_of_inputs[j].good = 4
    end
    for j = 0, 7 do
        DATA.building[i].amount_of_inputs[j].amount = 10
    end
    end
    print("building amount_of_outputs")
    for i = 0, 200000 do
    for j = 0, 7 do
        DATA.building[i].amount_of_outputs[j].good = 7
    end
    for j = 0, 7 do
        DATA.building[i].amount_of_outputs[j].amount = -15
    end
    end
    print("employment worker_income")
    for i = 0, 300000 do
        DATA.employment[i].worker_income = 0
    end
    print("employment job")
    for i = 0, 300000 do
        DATA.employment[i].job = 3
    end
    print("warband_unit type")
    for i = 0, 50000 do
        DATA.warband_unit[i].type = 0
    end
    print("realm_subject_relation wealth_transfer")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].wealth_transfer = false
    end
    print("realm_subject_relation goods_transfer")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].goods_transfer = true
    end
    print("realm_subject_relation warriors_contribution")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].warriors_contribution = false
    end
    print("realm_subject_relation protection")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].protection = false
    end
    print("realm_subject_relation local_ruler")
    for i = 0, 15000 do
        DATA.realm_subject_relation[i].local_ruler = false
    end
    print("personal_rights can_trade")
    for i = 0, 450000 do
        DATA.personal_rights[i].can_trade = true
    end
    print("personal_rights can_build")
    for i = 0, 450000 do
        DATA.personal_rights[i].can_build = false
    end
    print("popularity value")
    for i = 0, 450000 do
        DATA.popularity[i].value = -4
    end
    DATA.save_state()
    DATA.load_state()
    local test_passed = true
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].world_id == 1
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].is_land == true
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].is_fresh == true
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].elevation == 3
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].grass == -10
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].shrub == -1
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].conifer == -4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].broadleaf == 18
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_grass == -7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_shrub == 18
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_conifer == -18
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ideal_broadleaf == 17
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].silt == -10
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].clay == 7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].sand == 20
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].soil_minerals == 5
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].soil_organics == 12
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].january_waterflow == 3
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].july_waterflow == 14
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].waterlevel == 8
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].has_river == false
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].has_marsh == true
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ice == -19
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].ice_age_ice == 3
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_r == 9
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_g == 0
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].debug_b == 4
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_r == 7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_g == 13
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].real_b == -10
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].pathfinding_index == 17
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].resource == 5
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].bedrock == 7
    end
    for i = 0, 1500000 do
        test_passed = test_passed and DATA.tile[i].biome == 7
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].race == 0
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].female == true
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].age == 10
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].savings == -9
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].parent == 4
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].loyalty == 16
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].life_needs_satisfaction == 12
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].basic_needs_satisfaction == 3
    end
    for i = 0, 300000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].need == 2
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].use_case == 14
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].consumed == 6
    end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].need_satisfaction[j].demanded == 13
    end
    end
    for i = 0, 300000 do
    for j = 0, 9 do
        test_passed = test_passed and DATA.pop[i].traits[j] == 5
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].successor == 18
    end
    for i = 0, 300000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[i].inventory[j] == 2
    end
    end
    for i = 0, 300000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[i].price_memory[j] == 3
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].forage_ratio == 8
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].work_ratio == -10
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.pop[i].rank == 3
    end
    for i = 0, 300000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[i].dna[j] == 9
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].r == 13
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].g == -5
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].b == 11
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].is_land == false
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].province_id == 11
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].size == 12
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].hydration == 12
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].movement_cost == 2
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].center == 14
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure_needed == 9
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure == 2
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].infrastructure_investment == 16
    end
    for i = 0, 20000 do
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[i].technologies_present[j] == 17
    end
    end
    for i = 0, 20000 do
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[i].technologies_researchable[j] == 14
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].buildable_buildings[j] == 15
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_production[j] == -6
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_consumption[j] == 0
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_demand[j] == -10
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_storage[j] == 19
    end
    end
    for i = 0, 20000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[i].local_prices[j] == -3
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_wealth == 10
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].trade_wealth == -1
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_income == -1
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].local_building_upkeep == 12
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers == 15
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers_water == 13
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].foragers_limit == 12
    end
    for i = 0, 20000 do
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].output_good == 20
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].output_value == 19
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].amount == 17
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].foragers_targets[j].forage == 6
    end
    end
    for i = 0, 20000 do
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].local_resources[j].resource == 9
    end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[i].local_resources[j].location == 6
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].mood == 11
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.province[i].unit_types[j] == 16
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].throughput_boosts[j] == 3
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].input_efficiency_boosts[j] == 19
    end
    end
    for i = 0, 20000 do
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[i].output_efficiency_boosts[j] == -16
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].on_a_river == false
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.province[i].on_a_forest == true
    end
    for i = 0, 5000 do
        test_passed = test_passed and DATA.army[i].destination == 6
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[i].units_current[j] == -14
    end
    end
    for i = 0, 20000 do
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[i].units_target[j] == -17
    end
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].status == 0
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].idle_stance == 1
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].current_free_time_ratio == 17
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].treasury == -6
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].total_upkeep == -14
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].predicted_upkeep == 13
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].supplies == -12
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].supplies_target_days == -3
    end
    for i = 0, 20000 do
        test_passed = test_passed and DATA.warband[i].morale == -5
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_change == -7
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_saved_change == -17
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_spending_by_category[j] == 7
    end
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_income_by_category[j] == -18
    end
    end
    for i = 0, 15000 do
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[i].budget_treasury_change_by_category[j] == -17
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_treasury == 3
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_treasury_target == 3
    end
    for i = 0, 15000 do
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].ratio == -9
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].budget == -5
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].to_be_invested == -19
    end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[i].budget[j].target == -15
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_tax_target == -13
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].budget_tax_collected_this_year == -16
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].r == -19
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].g == -18
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].b == -19
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].primary_race == 11
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].capitol == 8
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].trading_right_cost == -12
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].building_right_cost == -10
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].prepare_attack_flag == true
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_r == 13
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_g == -20
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_base_b == 4
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_r == 17
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_g == -18
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_b == -5
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_r == -11
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_g == -18
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_b == -20
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_r == 2
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_g == 19
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_b == 20
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_background_image == 3
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_foreground_image == 9
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].coa_emblem_image == 10
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].resources[j] == 11
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].production[j] == -19
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].bought[j] == -1
    end
    end
    for i = 0, 15000 do
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[i].sold[j] == 8
    end
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm[i].expected_food_consumption == 15
    end
    for i = 0, 200000 do
        test_passed = test_passed and DATA.building[i].type == 19
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].spent_on_inputs[j].good == 1
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].spent_on_inputs[j].amount == -4
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].earn_from_outputs[j].good == 12
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].earn_from_outputs[j].amount == 19
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_inputs[j].good == 4
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_inputs[j].amount == 10
    end
    end
    for i = 0, 200000 do
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_outputs[j].good == 7
    end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[i].amount_of_outputs[j].amount == -15
    end
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.employment[i].worker_income == 0
    end
    for i = 0, 300000 do
        test_passed = test_passed and DATA.employment[i].job == 3
    end
    for i = 0, 50000 do
        test_passed = test_passed and DATA.warband_unit[i].type == 0
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].wealth_transfer == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].goods_transfer == true
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].warriors_contribution == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].protection == false
    end
    for i = 0, 15000 do
        test_passed = test_passed and DATA.realm_subject_relation[i].local_ruler == false
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.personal_rights[i].can_trade == true
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.personal_rights[i].can_build == false
    end
    for i = 0, 450000 do
        test_passed = test_passed and DATA.popularity[i].value == -4
    end
    print("SAVE_LOAD_TEST_2:")
    if test_passed then print("PASSED") else print("ERROR") end
end
function DATA.test_set_get_2()
    local id = DATA.create_tile()
    local fat_id = DATA.fatten_tile(id)
    fat_id.world_id = 1
    fat_id.is_land = true
    fat_id.is_fresh = true
    fat_id.elevation = 3
    fat_id.grass = -10
    fat_id.shrub = -1
    fat_id.conifer = -4
    fat_id.broadleaf = 18
    fat_id.ideal_grass = -7
    fat_id.ideal_shrub = 18
    fat_id.ideal_conifer = -18
    fat_id.ideal_broadleaf = 17
    fat_id.silt = -10
    fat_id.clay = 7
    fat_id.sand = 20
    fat_id.soil_minerals = 5
    fat_id.soil_organics = 12
    fat_id.january_waterflow = 3
    fat_id.july_waterflow = 14
    fat_id.waterlevel = 8
    fat_id.has_river = false
    fat_id.has_marsh = true
    fat_id.ice = -19
    fat_id.ice_age_ice = 3
    fat_id.debug_r = 9
    fat_id.debug_g = 0
    fat_id.debug_b = 4
    fat_id.real_r = 7
    fat_id.real_g = 13
    fat_id.real_b = -10
    fat_id.pathfinding_index = 17
    fat_id.resource = 5
    fat_id.bedrock = 7
    fat_id.biome = 7
    local test_passed = true
    test_passed = test_passed and fat_id.world_id == 1
    if not test_passed then print("world_id", 1, fat_id.world_id) end
    test_passed = test_passed and fat_id.is_land == true
    if not test_passed then print("is_land", true, fat_id.is_land) end
    test_passed = test_passed and fat_id.is_fresh == true
    if not test_passed then print("is_fresh", true, fat_id.is_fresh) end
    test_passed = test_passed and fat_id.elevation == 3
    if not test_passed then print("elevation", 3, fat_id.elevation) end
    test_passed = test_passed and fat_id.grass == -10
    if not test_passed then print("grass", -10, fat_id.grass) end
    test_passed = test_passed and fat_id.shrub == -1
    if not test_passed then print("shrub", -1, fat_id.shrub) end
    test_passed = test_passed and fat_id.conifer == -4
    if not test_passed then print("conifer", -4, fat_id.conifer) end
    test_passed = test_passed and fat_id.broadleaf == 18
    if not test_passed then print("broadleaf", 18, fat_id.broadleaf) end
    test_passed = test_passed and fat_id.ideal_grass == -7
    if not test_passed then print("ideal_grass", -7, fat_id.ideal_grass) end
    test_passed = test_passed and fat_id.ideal_shrub == 18
    if not test_passed then print("ideal_shrub", 18, fat_id.ideal_shrub) end
    test_passed = test_passed and fat_id.ideal_conifer == -18
    if not test_passed then print("ideal_conifer", -18, fat_id.ideal_conifer) end
    test_passed = test_passed and fat_id.ideal_broadleaf == 17
    if not test_passed then print("ideal_broadleaf", 17, fat_id.ideal_broadleaf) end
    test_passed = test_passed and fat_id.silt == -10
    if not test_passed then print("silt", -10, fat_id.silt) end
    test_passed = test_passed and fat_id.clay == 7
    if not test_passed then print("clay", 7, fat_id.clay) end
    test_passed = test_passed and fat_id.sand == 20
    if not test_passed then print("sand", 20, fat_id.sand) end
    test_passed = test_passed and fat_id.soil_minerals == 5
    if not test_passed then print("soil_minerals", 5, fat_id.soil_minerals) end
    test_passed = test_passed and fat_id.soil_organics == 12
    if not test_passed then print("soil_organics", 12, fat_id.soil_organics) end
    test_passed = test_passed and fat_id.january_waterflow == 3
    if not test_passed then print("january_waterflow", 3, fat_id.january_waterflow) end
    test_passed = test_passed and fat_id.july_waterflow == 14
    if not test_passed then print("july_waterflow", 14, fat_id.july_waterflow) end
    test_passed = test_passed and fat_id.waterlevel == 8
    if not test_passed then print("waterlevel", 8, fat_id.waterlevel) end
    test_passed = test_passed and fat_id.has_river == false
    if not test_passed then print("has_river", false, fat_id.has_river) end
    test_passed = test_passed and fat_id.has_marsh == true
    if not test_passed then print("has_marsh", true, fat_id.has_marsh) end
    test_passed = test_passed and fat_id.ice == -19
    if not test_passed then print("ice", -19, fat_id.ice) end
    test_passed = test_passed and fat_id.ice_age_ice == 3
    if not test_passed then print("ice_age_ice", 3, fat_id.ice_age_ice) end
    test_passed = test_passed and fat_id.debug_r == 9
    if not test_passed then print("debug_r", 9, fat_id.debug_r) end
    test_passed = test_passed and fat_id.debug_g == 0
    if not test_passed then print("debug_g", 0, fat_id.debug_g) end
    test_passed = test_passed and fat_id.debug_b == 4
    if not test_passed then print("debug_b", 4, fat_id.debug_b) end
    test_passed = test_passed and fat_id.real_r == 7
    if not test_passed then print("real_r", 7, fat_id.real_r) end
    test_passed = test_passed and fat_id.real_g == 13
    if not test_passed then print("real_g", 13, fat_id.real_g) end
    test_passed = test_passed and fat_id.real_b == -10
    if not test_passed then print("real_b", -10, fat_id.real_b) end
    test_passed = test_passed and fat_id.pathfinding_index == 17
    if not test_passed then print("pathfinding_index", 17, fat_id.pathfinding_index) end
    test_passed = test_passed and fat_id.resource == 5
    if not test_passed then print("resource", 5, fat_id.resource) end
    test_passed = test_passed and fat_id.bedrock == 7
    if not test_passed then print("bedrock", 7, fat_id.bedrock) end
    test_passed = test_passed and fat_id.biome == 7
    if not test_passed then print("biome", 7, fat_id.biome) end
    print("SET_GET_TEST_2_tile:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_pop()
    local fat_id = DATA.fatten_pop(id)
    fat_id.race = 1
    fat_id.female = true
    fat_id.age = 2
    fat_id.savings = 3
    fat_id.parent = 5
    fat_id.loyalty = 9
    fat_id.life_needs_satisfaction = -4
    fat_id.basic_needs_satisfaction = 18
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].need = 3
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].use_case = 19
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].consumed = -18
    end
    for j = 0, 19 do
        DATA.pop[id].need_satisfaction[j].demanded = 17
    end
    for j = 0, 9 do
        DATA.pop[id].traits[j] = 10
    end
    fat_id.successor = 5
    for j = 0, 99 do
        DATA.pop[id].inventory[j] = 7
    end
    for j = 0, 99 do
        DATA.pop[id].price_memory[j] = 20
    end
    fat_id.forage_ratio = 5
    fat_id.work_ratio = 12
    fat_id.rank = 2
    for j = 0, 19 do
        DATA.pop[id].dna[j] = 14
    end
    local test_passed = true
    test_passed = test_passed and fat_id.race == 1
    if not test_passed then print("race", 1, fat_id.race) end
    test_passed = test_passed and fat_id.female == true
    if not test_passed then print("female", true, fat_id.female) end
    test_passed = test_passed and fat_id.age == 2
    if not test_passed then print("age", 2, fat_id.age) end
    test_passed = test_passed and fat_id.savings == 3
    if not test_passed then print("savings", 3, fat_id.savings) end
    test_passed = test_passed and fat_id.parent == 5
    if not test_passed then print("parent", 5, fat_id.parent) end
    test_passed = test_passed and fat_id.loyalty == 9
    if not test_passed then print("loyalty", 9, fat_id.loyalty) end
    test_passed = test_passed and fat_id.life_needs_satisfaction == -4
    if not test_passed then print("life_needs_satisfaction", -4, fat_id.life_needs_satisfaction) end
    test_passed = test_passed and fat_id.basic_needs_satisfaction == 18
    if not test_passed then print("basic_needs_satisfaction", 18, fat_id.basic_needs_satisfaction) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].need == 3
    end
    if not test_passed then print("need_satisfaction.need", 3, DATA.pop[id].need_satisfaction[0].need) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].use_case == 19
    end
    if not test_passed then print("need_satisfaction.use_case", 19, DATA.pop[id].need_satisfaction[0].use_case) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].consumed == -18
    end
    if not test_passed then print("need_satisfaction.consumed", -18, DATA.pop[id].need_satisfaction[0].consumed) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].need_satisfaction[j].demanded == 17
    end
    if not test_passed then print("need_satisfaction.demanded", 17, DATA.pop[id].need_satisfaction[0].demanded) end
    for j = 0, 9 do
        test_passed = test_passed and DATA.pop[id].traits[j] == 10
    end
    if not test_passed then print("traits", 10, DATA.pop[id].traits[0]) end
    test_passed = test_passed and fat_id.successor == 5
    if not test_passed then print("successor", 5, fat_id.successor) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[id].inventory[j] == 7
    end
    if not test_passed then print("inventory", 7, DATA.pop[id].inventory[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.pop[id].price_memory[j] == 20
    end
    if not test_passed then print("price_memory", 20, DATA.pop[id].price_memory[0]) end
    test_passed = test_passed and fat_id.forage_ratio == 5
    if not test_passed then print("forage_ratio", 5, fat_id.forage_ratio) end
    test_passed = test_passed and fat_id.work_ratio == 12
    if not test_passed then print("work_ratio", 12, fat_id.work_ratio) end
    test_passed = test_passed and fat_id.rank == 2
    if not test_passed then print("rank", 2, fat_id.rank) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.pop[id].dna[j] == 14
    end
    if not test_passed then print("dna", 14, DATA.pop[id].dna[0]) end
    print("SET_GET_TEST_2_pop:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_province()
    local fat_id = DATA.fatten_province(id)
    fat_id.r = -17
    fat_id.g = -15
    fat_id.b = -15
    fat_id.is_land = false
    fat_id.province_id = -10
    fat_id.size = -1
    fat_id.hydration = -4
    fat_id.movement_cost = 18
    fat_id.center = 6
    fat_id.infrastructure_needed = 18
    fat_id.infrastructure = -18
    fat_id.infrastructure_investment = 17
    for j = 0, 399 do
        DATA.province[id].technologies_present[j] = 5
    end
    for j = 0, 399 do
        DATA.province[id].technologies_researchable[j] = 13
    end
    for j = 0, 249 do
        DATA.province[id].buildable_buildings[j] = 20
    end
    for j = 0, 99 do
        DATA.province[id].local_production[j] = 5
    end
    for j = 0, 99 do
        DATA.province[id].local_consumption[j] = 12
    end
    for j = 0, 99 do
        DATA.province[id].local_demand[j] = 3
    end
    for j = 0, 99 do
        DATA.province[id].local_storage[j] = 14
    end
    for j = 0, 99 do
        DATA.province[id].local_prices[j] = 8
    end
    fat_id.local_wealth = 12
    fat_id.trade_wealth = -3
    fat_id.local_income = -18
    fat_id.local_building_upkeep = -19
    fat_id.foragers = 3
    fat_id.foragers_water = 9
    fat_id.foragers_limit = 0
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].output_good = 12
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].output_value = 7
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].amount = 13
    end
    for j = 0, 24 do
        DATA.province[id].foragers_targets[j].forage = 2
    end
    for j = 0, 24 do
        DATA.province[id].local_resources[j].resource = 17
    end
    for j = 0, 24 do
        DATA.province[id].local_resources[j].location = 5
    end
    fat_id.mood = -5
    for j = 0, 19 do
        DATA.province[id].unit_types[j] = 7
    end
    for j = 0, 249 do
        DATA.province[id].throughput_boosts[j] = -19
    end
    for j = 0, 249 do
        DATA.province[id].input_efficiency_boosts[j] = -9
    end
    for j = 0, 249 do
        DATA.province[id].output_efficiency_boosts[j] = 0
    end
    fat_id.on_a_river = true
    fat_id.on_a_forest = true
    local test_passed = true
    test_passed = test_passed and fat_id.r == -17
    if not test_passed then print("r", -17, fat_id.r) end
    test_passed = test_passed and fat_id.g == -15
    if not test_passed then print("g", -15, fat_id.g) end
    test_passed = test_passed and fat_id.b == -15
    if not test_passed then print("b", -15, fat_id.b) end
    test_passed = test_passed and fat_id.is_land == false
    if not test_passed then print("is_land", false, fat_id.is_land) end
    test_passed = test_passed and fat_id.province_id == -10
    if not test_passed then print("province_id", -10, fat_id.province_id) end
    test_passed = test_passed and fat_id.size == -1
    if not test_passed then print("size", -1, fat_id.size) end
    test_passed = test_passed and fat_id.hydration == -4
    if not test_passed then print("hydration", -4, fat_id.hydration) end
    test_passed = test_passed and fat_id.movement_cost == 18
    if not test_passed then print("movement_cost", 18, fat_id.movement_cost) end
    test_passed = test_passed and fat_id.center == 6
    if not test_passed then print("center", 6, fat_id.center) end
    test_passed = test_passed and fat_id.infrastructure_needed == 18
    if not test_passed then print("infrastructure_needed", 18, fat_id.infrastructure_needed) end
    test_passed = test_passed and fat_id.infrastructure == -18
    if not test_passed then print("infrastructure", -18, fat_id.infrastructure) end
    test_passed = test_passed and fat_id.infrastructure_investment == 17
    if not test_passed then print("infrastructure_investment", 17, fat_id.infrastructure_investment) end
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[id].technologies_present[j] == 5
    end
    if not test_passed then print("technologies_present", 5, DATA.province[id].technologies_present[0]) end
    for j = 0, 399 do
        test_passed = test_passed and DATA.province[id].technologies_researchable[j] == 13
    end
    if not test_passed then print("technologies_researchable", 13, DATA.province[id].technologies_researchable[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].buildable_buildings[j] == 20
    end
    if not test_passed then print("buildable_buildings", 20, DATA.province[id].buildable_buildings[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_production[j] == 5
    end
    if not test_passed then print("local_production", 5, DATA.province[id].local_production[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_consumption[j] == 12
    end
    if not test_passed then print("local_consumption", 12, DATA.province[id].local_consumption[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_demand[j] == 3
    end
    if not test_passed then print("local_demand", 3, DATA.province[id].local_demand[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_storage[j] == 14
    end
    if not test_passed then print("local_storage", 14, DATA.province[id].local_storage[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.province[id].local_prices[j] == 8
    end
    if not test_passed then print("local_prices", 8, DATA.province[id].local_prices[0]) end
    test_passed = test_passed and fat_id.local_wealth == 12
    if not test_passed then print("local_wealth", 12, fat_id.local_wealth) end
    test_passed = test_passed and fat_id.trade_wealth == -3
    if not test_passed then print("trade_wealth", -3, fat_id.trade_wealth) end
    test_passed = test_passed and fat_id.local_income == -18
    if not test_passed then print("local_income", -18, fat_id.local_income) end
    test_passed = test_passed and fat_id.local_building_upkeep == -19
    if not test_passed then print("local_building_upkeep", -19, fat_id.local_building_upkeep) end
    test_passed = test_passed and fat_id.foragers == 3
    if not test_passed then print("foragers", 3, fat_id.foragers) end
    test_passed = test_passed and fat_id.foragers_water == 9
    if not test_passed then print("foragers_water", 9, fat_id.foragers_water) end
    test_passed = test_passed and fat_id.foragers_limit == 0
    if not test_passed then print("foragers_limit", 0, fat_id.foragers_limit) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].output_good == 12
    end
    if not test_passed then print("foragers_targets.output_good", 12, DATA.province[id].foragers_targets[0].output_good) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].output_value == 7
    end
    if not test_passed then print("foragers_targets.output_value", 7, DATA.province[id].foragers_targets[0].output_value) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].amount == 13
    end
    if not test_passed then print("foragers_targets.amount", 13, DATA.province[id].foragers_targets[0].amount) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].foragers_targets[j].forage == 2
    end
    if not test_passed then print("foragers_targets.forage", 2, DATA.province[id].foragers_targets[0].forage) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].local_resources[j].resource == 17
    end
    if not test_passed then print("local_resources.resource", 17, DATA.province[id].local_resources[0].resource) end
    for j = 0, 24 do
        test_passed = test_passed and DATA.province[id].local_resources[j].location == 5
    end
    if not test_passed then print("local_resources.location", 5, DATA.province[id].local_resources[0].location) end
    test_passed = test_passed and fat_id.mood == -5
    if not test_passed then print("mood", -5, fat_id.mood) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.province[id].unit_types[j] == 7
    end
    if not test_passed then print("unit_types", 7, DATA.province[id].unit_types[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].throughput_boosts[j] == -19
    end
    if not test_passed then print("throughput_boosts", -19, DATA.province[id].throughput_boosts[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].input_efficiency_boosts[j] == -9
    end
    if not test_passed then print("input_efficiency_boosts", -9, DATA.province[id].input_efficiency_boosts[0]) end
    for j = 0, 249 do
        test_passed = test_passed and DATA.province[id].output_efficiency_boosts[j] == 0
    end
    if not test_passed then print("output_efficiency_boosts", 0, DATA.province[id].output_efficiency_boosts[0]) end
    test_passed = test_passed and fat_id.on_a_river == true
    if not test_passed then print("on_a_river", true, fat_id.on_a_river) end
    test_passed = test_passed and fat_id.on_a_forest == true
    if not test_passed then print("on_a_forest", true, fat_id.on_a_forest) end
    print("SET_GET_TEST_2_province:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_army()
    local fat_id = DATA.fatten_army(id)
    fat_id.destination = 1
    local test_passed = true
    test_passed = test_passed and fat_id.destination == 1
    if not test_passed then print("destination", 1, fat_id.destination) end
    print("SET_GET_TEST_2_army:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband()
    local fat_id = DATA.fatten_warband(id)
    for j = 0, 19 do
        DATA.warband[id].units_current[j] = -17
    end
    for j = 0, 19 do
        DATA.warband[id].units_target[j] = -15
    end
    fat_id.status = 1
    fat_id.idle_stance = 1
    fat_id.current_free_time_ratio = -10
    fat_id.treasury = -1
    fat_id.total_upkeep = -4
    fat_id.predicted_upkeep = 18
    fat_id.supplies = -7
    fat_id.supplies_target_days = 18
    fat_id.morale = -18
    local test_passed = true
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[id].units_current[j] == -17
    end
    if not test_passed then print("units_current", -17, DATA.warband[id].units_current[0]) end
    for j = 0, 19 do
        test_passed = test_passed and DATA.warband[id].units_target[j] == -15
    end
    if not test_passed then print("units_target", -15, DATA.warband[id].units_target[0]) end
    test_passed = test_passed and fat_id.status == 1
    if not test_passed then print("status", 1, fat_id.status) end
    test_passed = test_passed and fat_id.idle_stance == 1
    if not test_passed then print("idle_stance", 1, fat_id.idle_stance) end
    test_passed = test_passed and fat_id.current_free_time_ratio == -10
    if not test_passed then print("current_free_time_ratio", -10, fat_id.current_free_time_ratio) end
    test_passed = test_passed and fat_id.treasury == -1
    if not test_passed then print("treasury", -1, fat_id.treasury) end
    test_passed = test_passed and fat_id.total_upkeep == -4
    if not test_passed then print("total_upkeep", -4, fat_id.total_upkeep) end
    test_passed = test_passed and fat_id.predicted_upkeep == 18
    if not test_passed then print("predicted_upkeep", 18, fat_id.predicted_upkeep) end
    test_passed = test_passed and fat_id.supplies == -7
    if not test_passed then print("supplies", -7, fat_id.supplies) end
    test_passed = test_passed and fat_id.supplies_target_days == 18
    if not test_passed then print("supplies_target_days", 18, fat_id.supplies_target_days) end
    test_passed = test_passed and fat_id.morale == -18
    if not test_passed then print("morale", -18, fat_id.morale) end
    print("SET_GET_TEST_2_warband:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm()
    local fat_id = DATA.fatten_realm(id)
    fat_id.budget_change = -17
    fat_id.budget_saved_change = -15
    for j = 0, 37 do
        DATA.realm[id].budget_spending_by_category[j] = -15
    end
    for j = 0, 37 do
        DATA.realm[id].budget_income_by_category[j] = 3
    end
    for j = 0, 37 do
        DATA.realm[id].budget_treasury_change_by_category[j] = -10
    end
    fat_id.budget_treasury = -1
    fat_id.budget_treasury_target = -4
    for j = 0, 6 do
        DATA.realm[id].budget[j].ratio = 18
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].budget = -7
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].to_be_invested = 18
    end
    for j = 0, 6 do
        DATA.realm[id].budget[j].target = -18
    end
    fat_id.budget_tax_target = 17
    fat_id.budget_tax_collected_this_year = -10
    fat_id.r = 7
    fat_id.g = 20
    fat_id.b = 5
    fat_id.primary_race = 16
    fat_id.capitol = 11
    fat_id.trading_right_cost = 14
    fat_id.building_right_cost = 8
    fat_id.prepare_attack_flag = false
    fat_id.coa_base_r = -18
    fat_id.coa_base_g = -19
    fat_id.coa_base_b = 3
    fat_id.coa_background_r = 9
    fat_id.coa_background_g = 0
    fat_id.coa_background_b = 4
    fat_id.coa_foreground_r = 7
    fat_id.coa_foreground_g = 13
    fat_id.coa_foreground_b = -10
    fat_id.coa_emblem_r = 15
    fat_id.coa_emblem_g = -9
    fat_id.coa_emblem_b = -5
    fat_id.coa_background_image = 7
    fat_id.coa_foreground_image = 0
    fat_id.coa_emblem_image = 5
    for j = 0, 99 do
        DATA.realm[id].resources[j] = 0
    end
    for j = 0, 99 do
        DATA.realm[id].production[j] = -9
    end
    for j = 0, 99 do
        DATA.realm[id].bought[j] = -12
    end
    for j = 0, 99 do
        DATA.realm[id].sold[j] = 12
    end
    fat_id.expected_food_consumption = 12
    local test_passed = true
    test_passed = test_passed and fat_id.budget_change == -17
    if not test_passed then print("budget_change", -17, fat_id.budget_change) end
    test_passed = test_passed and fat_id.budget_saved_change == -15
    if not test_passed then print("budget_saved_change", -15, fat_id.budget_saved_change) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_spending_by_category[j] == -15
    end
    if not test_passed then print("budget_spending_by_category", -15, DATA.realm[id].budget_spending_by_category[0]) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_income_by_category[j] == 3
    end
    if not test_passed then print("budget_income_by_category", 3, DATA.realm[id].budget_income_by_category[0]) end
    for j = 0, 37 do
        test_passed = test_passed and DATA.realm[id].budget_treasury_change_by_category[j] == -10
    end
    if not test_passed then print("budget_treasury_change_by_category", -10, DATA.realm[id].budget_treasury_change_by_category[0]) end
    test_passed = test_passed and fat_id.budget_treasury == -1
    if not test_passed then print("budget_treasury", -1, fat_id.budget_treasury) end
    test_passed = test_passed and fat_id.budget_treasury_target == -4
    if not test_passed then print("budget_treasury_target", -4, fat_id.budget_treasury_target) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].ratio == 18
    end
    if not test_passed then print("budget.ratio", 18, DATA.realm[id].budget[0].ratio) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].budget == -7
    end
    if not test_passed then print("budget.budget", -7, DATA.realm[id].budget[0].budget) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].to_be_invested == 18
    end
    if not test_passed then print("budget.to_be_invested", 18, DATA.realm[id].budget[0].to_be_invested) end
    for j = 0, 6 do
        test_passed = test_passed and DATA.realm[id].budget[j].target == -18
    end
    if not test_passed then print("budget.target", -18, DATA.realm[id].budget[0].target) end
    test_passed = test_passed and fat_id.budget_tax_target == 17
    if not test_passed then print("budget_tax_target", 17, fat_id.budget_tax_target) end
    test_passed = test_passed and fat_id.budget_tax_collected_this_year == -10
    if not test_passed then print("budget_tax_collected_this_year", -10, fat_id.budget_tax_collected_this_year) end
    test_passed = test_passed and fat_id.r == 7
    if not test_passed then print("r", 7, fat_id.r) end
    test_passed = test_passed and fat_id.g == 20
    if not test_passed then print("g", 20, fat_id.g) end
    test_passed = test_passed and fat_id.b == 5
    if not test_passed then print("b", 5, fat_id.b) end
    test_passed = test_passed and fat_id.primary_race == 16
    if not test_passed then print("primary_race", 16, fat_id.primary_race) end
    test_passed = test_passed and fat_id.capitol == 11
    if not test_passed then print("capitol", 11, fat_id.capitol) end
    test_passed = test_passed and fat_id.trading_right_cost == 14
    if not test_passed then print("trading_right_cost", 14, fat_id.trading_right_cost) end
    test_passed = test_passed and fat_id.building_right_cost == 8
    if not test_passed then print("building_right_cost", 8, fat_id.building_right_cost) end
    test_passed = test_passed and fat_id.prepare_attack_flag == false
    if not test_passed then print("prepare_attack_flag", false, fat_id.prepare_attack_flag) end
    test_passed = test_passed and fat_id.coa_base_r == -18
    if not test_passed then print("coa_base_r", -18, fat_id.coa_base_r) end
    test_passed = test_passed and fat_id.coa_base_g == -19
    if not test_passed then print("coa_base_g", -19, fat_id.coa_base_g) end
    test_passed = test_passed and fat_id.coa_base_b == 3
    if not test_passed then print("coa_base_b", 3, fat_id.coa_base_b) end
    test_passed = test_passed and fat_id.coa_background_r == 9
    if not test_passed then print("coa_background_r", 9, fat_id.coa_background_r) end
    test_passed = test_passed and fat_id.coa_background_g == 0
    if not test_passed then print("coa_background_g", 0, fat_id.coa_background_g) end
    test_passed = test_passed and fat_id.coa_background_b == 4
    if not test_passed then print("coa_background_b", 4, fat_id.coa_background_b) end
    test_passed = test_passed and fat_id.coa_foreground_r == 7
    if not test_passed then print("coa_foreground_r", 7, fat_id.coa_foreground_r) end
    test_passed = test_passed and fat_id.coa_foreground_g == 13
    if not test_passed then print("coa_foreground_g", 13, fat_id.coa_foreground_g) end
    test_passed = test_passed and fat_id.coa_foreground_b == -10
    if not test_passed then print("coa_foreground_b", -10, fat_id.coa_foreground_b) end
    test_passed = test_passed and fat_id.coa_emblem_r == 15
    if not test_passed then print("coa_emblem_r", 15, fat_id.coa_emblem_r) end
    test_passed = test_passed and fat_id.coa_emblem_g == -9
    if not test_passed then print("coa_emblem_g", -9, fat_id.coa_emblem_g) end
    test_passed = test_passed and fat_id.coa_emblem_b == -5
    if not test_passed then print("coa_emblem_b", -5, fat_id.coa_emblem_b) end
    test_passed = test_passed and fat_id.coa_background_image == 7
    if not test_passed then print("coa_background_image", 7, fat_id.coa_background_image) end
    test_passed = test_passed and fat_id.coa_foreground_image == 0
    if not test_passed then print("coa_foreground_image", 0, fat_id.coa_foreground_image) end
    test_passed = test_passed and fat_id.coa_emblem_image == 5
    if not test_passed then print("coa_emblem_image", 5, fat_id.coa_emblem_image) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].resources[j] == 0
    end
    if not test_passed then print("resources", 0, DATA.realm[id].resources[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].production[j] == -9
    end
    if not test_passed then print("production", -9, DATA.realm[id].production[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].bought[j] == -12
    end
    if not test_passed then print("bought", -12, DATA.realm[id].bought[0]) end
    for j = 0, 99 do
        test_passed = test_passed and DATA.realm[id].sold[j] == 12
    end
    if not test_passed then print("sold", 12, DATA.realm[id].sold[0]) end
    test_passed = test_passed and fat_id.expected_food_consumption == 12
    if not test_passed then print("expected_food_consumption", 12, fat_id.expected_food_consumption) end
    print("SET_GET_TEST_2_realm:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_negotiation()
    local fat_id = DATA.fatten_negotiation(id)
    local test_passed = true
    print("SET_GET_TEST_2_negotiation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_building()
    local fat_id = DATA.fatten_building(id)
    fat_id.type = 1
    for j = 0, 7 do
        DATA.building[id].spent_on_inputs[j].good = 2
    end
    for j = 0, 7 do
        DATA.building[id].spent_on_inputs[j].amount = -15
    end
    for j = 0, 7 do
        DATA.building[id].earn_from_outputs[j].good = 11
    end
    for j = 0, 7 do
        DATA.building[id].earn_from_outputs[j].amount = -10
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_inputs[j].good = 9
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_inputs[j].amount = -4
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_outputs[j].good = 19
    end
    for j = 0, 7 do
        DATA.building[id].amount_of_outputs[j].amount = -7
    end
    local test_passed = true
    test_passed = test_passed and fat_id.type == 1
    if not test_passed then print("type", 1, fat_id.type) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].spent_on_inputs[j].good == 2
    end
    if not test_passed then print("spent_on_inputs.good", 2, DATA.building[id].spent_on_inputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].spent_on_inputs[j].amount == -15
    end
    if not test_passed then print("spent_on_inputs.amount", -15, DATA.building[id].spent_on_inputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].earn_from_outputs[j].good == 11
    end
    if not test_passed then print("earn_from_outputs.good", 11, DATA.building[id].earn_from_outputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].earn_from_outputs[j].amount == -10
    end
    if not test_passed then print("earn_from_outputs.amount", -10, DATA.building[id].earn_from_outputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_inputs[j].good == 9
    end
    if not test_passed then print("amount_of_inputs.good", 9, DATA.building[id].amount_of_inputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_inputs[j].amount == -4
    end
    if not test_passed then print("amount_of_inputs.amount", -4, DATA.building[id].amount_of_inputs[0].amount) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_outputs[j].good == 19
    end
    if not test_passed then print("amount_of_outputs.good", 19, DATA.building[id].amount_of_outputs[0].good) end
    for j = 0, 7 do
        test_passed = test_passed and DATA.building[id].amount_of_outputs[j].amount == -7
    end
    if not test_passed then print("amount_of_outputs.amount", -7, DATA.building[id].amount_of_outputs[0].amount) end
    print("SET_GET_TEST_2_building:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_ownership()
    local fat_id = DATA.fatten_ownership(id)
    local test_passed = true
    print("SET_GET_TEST_2_ownership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_employment()
    local fat_id = DATA.fatten_employment(id)
    fat_id.worker_income = -17
    fat_id.job = 2
    local test_passed = true
    test_passed = test_passed and fat_id.worker_income == -17
    if not test_passed then print("worker_income", -17, fat_id.worker_income) end
    test_passed = test_passed and fat_id.job == 2
    if not test_passed then print("job", 2, fat_id.job) end
    print("SET_GET_TEST_2_employment:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_building_location()
    local fat_id = DATA.fatten_building_location(id)
    local test_passed = true
    print("SET_GET_TEST_2_building_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_army_membership()
    local fat_id = DATA.fatten_army_membership(id)
    local test_passed = true
    print("SET_GET_TEST_2_army_membership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_leader()
    local fat_id = DATA.fatten_warband_leader(id)
    local test_passed = true
    print("SET_GET_TEST_2_warband_leader:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_recruiter()
    local fat_id = DATA.fatten_warband_recruiter(id)
    local test_passed = true
    print("SET_GET_TEST_2_warband_recruiter:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_commander()
    local fat_id = DATA.fatten_warband_commander(id)
    local test_passed = true
    print("SET_GET_TEST_2_warband_commander:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_location()
    local fat_id = DATA.fatten_warband_location(id)
    local test_passed = true
    print("SET_GET_TEST_2_warband_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_warband_unit()
    local fat_id = DATA.fatten_warband_unit(id)
    fat_id.type = 1
    local test_passed = true
    test_passed = test_passed and fat_id.type == 1
    if not test_passed then print("type", 1, fat_id.type) end
    print("SET_GET_TEST_2_warband_unit:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_character_location()
    local fat_id = DATA.fatten_character_location(id)
    local test_passed = true
    print("SET_GET_TEST_2_character_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_home()
    local fat_id = DATA.fatten_home(id)
    local test_passed = true
    print("SET_GET_TEST_2_home:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_pop_location()
    local fat_id = DATA.fatten_pop_location(id)
    local test_passed = true
    print("SET_GET_TEST_2_pop_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_outlaw_location()
    local fat_id = DATA.fatten_outlaw_location(id)
    local test_passed = true
    print("SET_GET_TEST_2_outlaw_location:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_tile_province_membership()
    local fat_id = DATA.fatten_tile_province_membership(id)
    local test_passed = true
    print("SET_GET_TEST_2_tile_province_membership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_province_neighborhood()
    local fat_id = DATA.fatten_province_neighborhood(id)
    local test_passed = true
    print("SET_GET_TEST_2_province_neighborhood:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_parent_child_relation()
    local fat_id = DATA.fatten_parent_child_relation(id)
    local test_passed = true
    print("SET_GET_TEST_2_parent_child_relation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_loyalty()
    local fat_id = DATA.fatten_loyalty(id)
    local test_passed = true
    print("SET_GET_TEST_2_loyalty:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_succession()
    local fat_id = DATA.fatten_succession(id)
    local test_passed = true
    print("SET_GET_TEST_2_succession:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_armies()
    local fat_id = DATA.fatten_realm_armies(id)
    local test_passed = true
    print("SET_GET_TEST_2_realm_armies:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_guard()
    local fat_id = DATA.fatten_realm_guard(id)
    local test_passed = true
    print("SET_GET_TEST_2_realm_guard:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_overseer()
    local fat_id = DATA.fatten_realm_overseer(id)
    local test_passed = true
    print("SET_GET_TEST_2_realm_overseer:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_leadership()
    local fat_id = DATA.fatten_realm_leadership(id)
    local test_passed = true
    print("SET_GET_TEST_2_realm_leadership:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_subject_relation()
    local fat_id = DATA.fatten_realm_subject_relation(id)
    fat_id.wealth_transfer = true
    fat_id.goods_transfer = true
    fat_id.warriors_contribution = true
    fat_id.protection = false
    fat_id.local_ruler = true
    local test_passed = true
    test_passed = test_passed and fat_id.wealth_transfer == true
    if not test_passed then print("wealth_transfer", true, fat_id.wealth_transfer) end
    test_passed = test_passed and fat_id.goods_transfer == true
    if not test_passed then print("goods_transfer", true, fat_id.goods_transfer) end
    test_passed = test_passed and fat_id.warriors_contribution == true
    if not test_passed then print("warriors_contribution", true, fat_id.warriors_contribution) end
    test_passed = test_passed and fat_id.protection == false
    if not test_passed then print("protection", false, fat_id.protection) end
    test_passed = test_passed and fat_id.local_ruler == true
    if not test_passed then print("local_ruler", true, fat_id.local_ruler) end
    print("SET_GET_TEST_2_realm_subject_relation:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_tax_collector()
    local fat_id = DATA.fatten_tax_collector(id)
    local test_passed = true
    print("SET_GET_TEST_2_tax_collector:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_personal_rights()
    local fat_id = DATA.fatten_personal_rights(id)
    fat_id.can_trade = true
    fat_id.can_build = true
    local test_passed = true
    test_passed = test_passed and fat_id.can_trade == true
    if not test_passed then print("can_trade", true, fat_id.can_trade) end
    test_passed = test_passed and fat_id.can_build == true
    if not test_passed then print("can_build", true, fat_id.can_build) end
    print("SET_GET_TEST_2_personal_rights:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_realm_provinces()
    local fat_id = DATA.fatten_realm_provinces(id)
    local test_passed = true
    print("SET_GET_TEST_2_realm_provinces:")
    if test_passed then print("PASSED") else print("ERROR") end
    local id = DATA.create_popularity()
    local fat_id = DATA.fatten_popularity(id)
    fat_id.value = -17
    local test_passed = true
    test_passed = test_passed and fat_id.value == -17
    if not test_passed then print("value", -17, fat_id.value) end
    print("SET_GET_TEST_2_popularity:")
    if test_passed then print("PASSED") else print("ERROR") end
end
return DATA
