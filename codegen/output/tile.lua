local ffi = require("ffi")
----------tile----------


---tile: LSP types---

---Unique identificator for tile entity
---@class (exact) tile_id : table
---@field is_tile number
---@class (exact) fat_tile_id
---@field id tile_id Unique tile id
---@field world_id number 
---@field is_land boolean 
---@field is_fresh boolean 
---@field is_border boolean 
---@field is_coast boolean 
---@field has_river boolean 
---@field has_marsh boolean 
---@field x number 
---@field y number 
---@field z number 
---@field elevation number 
---@field slope number 
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
---@field january_rain number 
---@field january_temperature number 
---@field july_waterflow number 
---@field july_rain number 
---@field july_temperature number 
---@field waterlevel number 
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
---@field foragers_limit number combined plant game and marine foraging limits
---@field infrastructure_needed number 
---@field infrastructure number 
---@field infrastructure_investment number 
---@field infrastructure_efficiency number 

---@class struct_tile
---@field world_id number 
---@field is_land boolean 
---@field is_fresh boolean 
---@field is_border boolean 
---@field is_coast boolean 
---@field has_river boolean 
---@field has_marsh boolean 
---@field x number 
---@field y number 
---@field z number 
---@field elevation number 
---@field slope number 
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
---@field january_rain number 
---@field january_temperature number 
---@field july_waterflow number 
---@field july_rain number 
---@field july_temperature number 
---@field waterlevel number 
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
---@field foragers_limit number combined plant game and marine foraging limits
---@field foragers_targets table<FORAGE_RESOURCE, struct_forage_container> 
---@field infrastructure_needed number 
---@field infrastructure number 
---@field infrastructure_investment number 
---@field infrastructure_efficiency number 


ffi.cdef[[
void dcon_tile_set_world_id(int32_t, uint32_t);
uint32_t dcon_tile_get_world_id(int32_t);
void dcon_tile_set_is_land(int32_t, bool);
bool dcon_tile_get_is_land(int32_t);
void dcon_tile_set_is_fresh(int32_t, bool);
bool dcon_tile_get_is_fresh(int32_t);
void dcon_tile_set_is_border(int32_t, bool);
bool dcon_tile_get_is_border(int32_t);
void dcon_tile_set_is_coast(int32_t, bool);
bool dcon_tile_get_is_coast(int32_t);
void dcon_tile_set_has_river(int32_t, bool);
bool dcon_tile_get_has_river(int32_t);
void dcon_tile_set_has_marsh(int32_t, bool);
bool dcon_tile_get_has_marsh(int32_t);
void dcon_tile_set_x(int32_t, float);
float dcon_tile_get_x(int32_t);
void dcon_tile_set_y(int32_t, float);
float dcon_tile_get_y(int32_t);
void dcon_tile_set_z(int32_t, float);
float dcon_tile_get_z(int32_t);
void dcon_tile_set_elevation(int32_t, float);
float dcon_tile_get_elevation(int32_t);
void dcon_tile_set_slope(int32_t, float);
float dcon_tile_get_slope(int32_t);
void dcon_tile_set_grass(int32_t, float);
float dcon_tile_get_grass(int32_t);
void dcon_tile_set_shrub(int32_t, float);
float dcon_tile_get_shrub(int32_t);
void dcon_tile_set_conifer(int32_t, float);
float dcon_tile_get_conifer(int32_t);
void dcon_tile_set_broadleaf(int32_t, float);
float dcon_tile_get_broadleaf(int32_t);
void dcon_tile_set_ideal_grass(int32_t, float);
float dcon_tile_get_ideal_grass(int32_t);
void dcon_tile_set_ideal_shrub(int32_t, float);
float dcon_tile_get_ideal_shrub(int32_t);
void dcon_tile_set_ideal_conifer(int32_t, float);
float dcon_tile_get_ideal_conifer(int32_t);
void dcon_tile_set_ideal_broadleaf(int32_t, float);
float dcon_tile_get_ideal_broadleaf(int32_t);
void dcon_tile_set_silt(int32_t, float);
float dcon_tile_get_silt(int32_t);
void dcon_tile_set_clay(int32_t, float);
float dcon_tile_get_clay(int32_t);
void dcon_tile_set_sand(int32_t, float);
float dcon_tile_get_sand(int32_t);
void dcon_tile_set_soil_minerals(int32_t, float);
float dcon_tile_get_soil_minerals(int32_t);
void dcon_tile_set_soil_organics(int32_t, float);
float dcon_tile_get_soil_organics(int32_t);
void dcon_tile_set_january_waterflow(int32_t, float);
float dcon_tile_get_january_waterflow(int32_t);
void dcon_tile_set_january_rain(int32_t, float);
float dcon_tile_get_january_rain(int32_t);
void dcon_tile_set_january_temperature(int32_t, float);
float dcon_tile_get_january_temperature(int32_t);
void dcon_tile_set_july_waterflow(int32_t, float);
float dcon_tile_get_july_waterflow(int32_t);
void dcon_tile_set_july_rain(int32_t, float);
float dcon_tile_get_july_rain(int32_t);
void dcon_tile_set_july_temperature(int32_t, float);
float dcon_tile_get_july_temperature(int32_t);
void dcon_tile_set_waterlevel(int32_t, float);
float dcon_tile_get_waterlevel(int32_t);
void dcon_tile_set_ice(int32_t, float);
float dcon_tile_get_ice(int32_t);
void dcon_tile_set_ice_age_ice(int32_t, float);
float dcon_tile_get_ice_age_ice(int32_t);
void dcon_tile_set_debug_r(int32_t, float);
float dcon_tile_get_debug_r(int32_t);
void dcon_tile_set_debug_g(int32_t, float);
float dcon_tile_get_debug_g(int32_t);
void dcon_tile_set_debug_b(int32_t, float);
float dcon_tile_get_debug_b(int32_t);
void dcon_tile_set_real_r(int32_t, float);
float dcon_tile_get_real_r(int32_t);
void dcon_tile_set_real_g(int32_t, float);
float dcon_tile_get_real_g(int32_t);
void dcon_tile_set_real_b(int32_t, float);
float dcon_tile_get_real_b(int32_t);
void dcon_tile_set_pathfinding_index(int32_t, uint32_t);
uint32_t dcon_tile_get_pathfinding_index(int32_t);
void dcon_tile_set_resource(int32_t, int32_t);
int32_t dcon_tile_get_resource(int32_t);
void dcon_tile_set_bedrock(int32_t, int32_t);
int32_t dcon_tile_get_bedrock(int32_t);
void dcon_tile_set_biome(int32_t, int32_t);
int32_t dcon_tile_get_biome(int32_t);
void dcon_tile_set_foragers_limit(int32_t, float);
float dcon_tile_get_foragers_limit(int32_t);
void dcon_tile_resize_foragers_targets(uint32_t);
forage_container* dcon_tile_get_foragers_targets(int32_t, int32_t);
void dcon_tile_set_infrastructure_needed(int32_t, float);
float dcon_tile_get_infrastructure_needed(int32_t);
void dcon_tile_set_infrastructure(int32_t, float);
float dcon_tile_get_infrastructure(int32_t);
void dcon_tile_set_infrastructure_investment(int32_t, float);
float dcon_tile_get_infrastructure_investment(int32_t);
void dcon_tile_set_infrastructure_efficiency(int32_t, float);
float dcon_tile_get_infrastructure_efficiency(int32_t);
int32_t dcon_create_tile();
bool dcon_tile_is_valid(int32_t);
void dcon_tile_resize(uint32_t sz);
uint32_t dcon_tile_size();
]]

---tile: FFI arrays---

---tile: LUA bindings---

DATA.tile_size = 1500000
DCON.dcon_tile_resize_foragers_targets(8)
---@return tile_id
function DATA.create_tile()
    ---@type tile_id
    local i  = DCON.dcon_create_tile() + 1
    return i --[[@as tile_id]] 
end
---@param func fun(item: tile_id) 
function DATA.for_each_tile(func)
    ---@type number
    local range = DCON.dcon_tile_size()
    for i = 0, range - 1 do
        func(i + 1 --[[@as tile_id]])
    end
end
---@param func fun(item: tile_id):boolean 
---@return table<tile_id, tile_id> 
function DATA.filter_tile(func)
    ---@type table<tile_id, tile_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_tile_size()
    for i = 0, range - 1 do
        if func(i + 1 --[[@as tile_id]]) then t[i + 1 --[[@as tile_id]]] = t[i + 1 --[[@as tile_id]]] end
    end
    return t
end

---@param tile_id tile_id valid tile id
---@return number world_id 
function DATA.tile_get_world_id(tile_id)
    return DCON.dcon_tile_get_world_id(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_world_id(tile_id, value)
    DCON.dcon_tile_set_world_id(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_world_id(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_world_id(tile_id - 1)
    DCON.dcon_tile_set_world_id(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return boolean is_land 
function DATA.tile_get_is_land(tile_id)
    return DCON.dcon_tile_get_is_land(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_is_land(tile_id, value)
    DCON.dcon_tile_set_is_land(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@return boolean is_fresh 
function DATA.tile_get_is_fresh(tile_id)
    return DCON.dcon_tile_get_is_fresh(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_is_fresh(tile_id, value)
    DCON.dcon_tile_set_is_fresh(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@return boolean is_border 
function DATA.tile_get_is_border(tile_id)
    return DCON.dcon_tile_get_is_border(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_is_border(tile_id, value)
    DCON.dcon_tile_set_is_border(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@return boolean is_coast 
function DATA.tile_get_is_coast(tile_id)
    return DCON.dcon_tile_get_is_coast(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_is_coast(tile_id, value)
    DCON.dcon_tile_set_is_coast(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@return boolean has_river 
function DATA.tile_get_has_river(tile_id)
    return DCON.dcon_tile_get_has_river(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_has_river(tile_id, value)
    DCON.dcon_tile_set_has_river(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@return boolean has_marsh 
function DATA.tile_get_has_marsh(tile_id)
    return DCON.dcon_tile_get_has_marsh(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value boolean valid boolean
function DATA.tile_set_has_marsh(tile_id, value)
    DCON.dcon_tile_set_has_marsh(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@return number x 
function DATA.tile_get_x(tile_id)
    return DCON.dcon_tile_get_x(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_x(tile_id, value)
    DCON.dcon_tile_set_x(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_x(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_x(tile_id - 1)
    DCON.dcon_tile_set_x(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number y 
function DATA.tile_get_y(tile_id)
    return DCON.dcon_tile_get_y(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_y(tile_id, value)
    DCON.dcon_tile_set_y(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_y(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_y(tile_id - 1)
    DCON.dcon_tile_set_y(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number z 
function DATA.tile_get_z(tile_id)
    return DCON.dcon_tile_get_z(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_z(tile_id, value)
    DCON.dcon_tile_set_z(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_z(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_z(tile_id - 1)
    DCON.dcon_tile_set_z(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number elevation 
function DATA.tile_get_elevation(tile_id)
    return DCON.dcon_tile_get_elevation(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_elevation(tile_id, value)
    DCON.dcon_tile_set_elevation(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_elevation(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_elevation(tile_id - 1)
    DCON.dcon_tile_set_elevation(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number slope 
function DATA.tile_get_slope(tile_id)
    return DCON.dcon_tile_get_slope(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_slope(tile_id, value)
    DCON.dcon_tile_set_slope(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_slope(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_slope(tile_id - 1)
    DCON.dcon_tile_set_slope(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number grass 
function DATA.tile_get_grass(tile_id)
    return DCON.dcon_tile_get_grass(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_grass(tile_id, value)
    DCON.dcon_tile_set_grass(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_grass(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_grass(tile_id - 1)
    DCON.dcon_tile_set_grass(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number shrub 
function DATA.tile_get_shrub(tile_id)
    return DCON.dcon_tile_get_shrub(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_shrub(tile_id, value)
    DCON.dcon_tile_set_shrub(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_shrub(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_shrub(tile_id - 1)
    DCON.dcon_tile_set_shrub(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number conifer 
function DATA.tile_get_conifer(tile_id)
    return DCON.dcon_tile_get_conifer(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_conifer(tile_id, value)
    DCON.dcon_tile_set_conifer(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_conifer(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_conifer(tile_id - 1)
    DCON.dcon_tile_set_conifer(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number broadleaf 
function DATA.tile_get_broadleaf(tile_id)
    return DCON.dcon_tile_get_broadleaf(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_broadleaf(tile_id, value)
    DCON.dcon_tile_set_broadleaf(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_broadleaf(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_broadleaf(tile_id - 1)
    DCON.dcon_tile_set_broadleaf(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number ideal_grass 
function DATA.tile_get_ideal_grass(tile_id)
    return DCON.dcon_tile_get_ideal_grass(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_grass(tile_id, value)
    DCON.dcon_tile_set_ideal_grass(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_grass(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_ideal_grass(tile_id - 1)
    DCON.dcon_tile_set_ideal_grass(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number ideal_shrub 
function DATA.tile_get_ideal_shrub(tile_id)
    return DCON.dcon_tile_get_ideal_shrub(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_shrub(tile_id, value)
    DCON.dcon_tile_set_ideal_shrub(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_shrub(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_ideal_shrub(tile_id - 1)
    DCON.dcon_tile_set_ideal_shrub(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number ideal_conifer 
function DATA.tile_get_ideal_conifer(tile_id)
    return DCON.dcon_tile_get_ideal_conifer(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_conifer(tile_id, value)
    DCON.dcon_tile_set_ideal_conifer(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_conifer(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_ideal_conifer(tile_id - 1)
    DCON.dcon_tile_set_ideal_conifer(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number ideal_broadleaf 
function DATA.tile_get_ideal_broadleaf(tile_id)
    return DCON.dcon_tile_get_ideal_broadleaf(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ideal_broadleaf(tile_id, value)
    DCON.dcon_tile_set_ideal_broadleaf(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ideal_broadleaf(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_ideal_broadleaf(tile_id - 1)
    DCON.dcon_tile_set_ideal_broadleaf(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number silt 
function DATA.tile_get_silt(tile_id)
    return DCON.dcon_tile_get_silt(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_silt(tile_id, value)
    DCON.dcon_tile_set_silt(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_silt(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_silt(tile_id - 1)
    DCON.dcon_tile_set_silt(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number clay 
function DATA.tile_get_clay(tile_id)
    return DCON.dcon_tile_get_clay(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_clay(tile_id, value)
    DCON.dcon_tile_set_clay(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_clay(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_clay(tile_id - 1)
    DCON.dcon_tile_set_clay(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number sand 
function DATA.tile_get_sand(tile_id)
    return DCON.dcon_tile_get_sand(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_sand(tile_id, value)
    DCON.dcon_tile_set_sand(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_sand(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_sand(tile_id - 1)
    DCON.dcon_tile_set_sand(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number soil_minerals 
function DATA.tile_get_soil_minerals(tile_id)
    return DCON.dcon_tile_get_soil_minerals(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_soil_minerals(tile_id, value)
    DCON.dcon_tile_set_soil_minerals(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_soil_minerals(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_soil_minerals(tile_id - 1)
    DCON.dcon_tile_set_soil_minerals(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number soil_organics 
function DATA.tile_get_soil_organics(tile_id)
    return DCON.dcon_tile_get_soil_organics(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_soil_organics(tile_id, value)
    DCON.dcon_tile_set_soil_organics(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_soil_organics(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_soil_organics(tile_id - 1)
    DCON.dcon_tile_set_soil_organics(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number january_waterflow 
function DATA.tile_get_january_waterflow(tile_id)
    return DCON.dcon_tile_get_january_waterflow(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_january_waterflow(tile_id, value)
    DCON.dcon_tile_set_january_waterflow(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_january_waterflow(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_january_waterflow(tile_id - 1)
    DCON.dcon_tile_set_january_waterflow(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number january_rain 
function DATA.tile_get_january_rain(tile_id)
    return DCON.dcon_tile_get_january_rain(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_january_rain(tile_id, value)
    DCON.dcon_tile_set_january_rain(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_january_rain(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_january_rain(tile_id - 1)
    DCON.dcon_tile_set_january_rain(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number january_temperature 
function DATA.tile_get_january_temperature(tile_id)
    return DCON.dcon_tile_get_january_temperature(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_january_temperature(tile_id, value)
    DCON.dcon_tile_set_january_temperature(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_january_temperature(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_january_temperature(tile_id - 1)
    DCON.dcon_tile_set_january_temperature(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number july_waterflow 
function DATA.tile_get_july_waterflow(tile_id)
    return DCON.dcon_tile_get_july_waterflow(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_july_waterflow(tile_id, value)
    DCON.dcon_tile_set_july_waterflow(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_july_waterflow(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_july_waterflow(tile_id - 1)
    DCON.dcon_tile_set_july_waterflow(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number july_rain 
function DATA.tile_get_july_rain(tile_id)
    return DCON.dcon_tile_get_july_rain(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_july_rain(tile_id, value)
    DCON.dcon_tile_set_july_rain(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_july_rain(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_july_rain(tile_id - 1)
    DCON.dcon_tile_set_july_rain(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number july_temperature 
function DATA.tile_get_july_temperature(tile_id)
    return DCON.dcon_tile_get_july_temperature(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_july_temperature(tile_id, value)
    DCON.dcon_tile_set_july_temperature(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_july_temperature(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_july_temperature(tile_id - 1)
    DCON.dcon_tile_set_july_temperature(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number waterlevel 
function DATA.tile_get_waterlevel(tile_id)
    return DCON.dcon_tile_get_waterlevel(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_waterlevel(tile_id, value)
    DCON.dcon_tile_set_waterlevel(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_waterlevel(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_waterlevel(tile_id - 1)
    DCON.dcon_tile_set_waterlevel(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number ice 
function DATA.tile_get_ice(tile_id)
    return DCON.dcon_tile_get_ice(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ice(tile_id, value)
    DCON.dcon_tile_set_ice(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ice(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_ice(tile_id - 1)
    DCON.dcon_tile_set_ice(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number ice_age_ice 
function DATA.tile_get_ice_age_ice(tile_id)
    return DCON.dcon_tile_get_ice_age_ice(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_ice_age_ice(tile_id, value)
    DCON.dcon_tile_set_ice_age_ice(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_ice_age_ice(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_ice_age_ice(tile_id - 1)
    DCON.dcon_tile_set_ice_age_ice(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number debug_r between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_debug_r(tile_id)
    return DCON.dcon_tile_get_debug_r(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_debug_r(tile_id, value)
    DCON.dcon_tile_set_debug_r(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_debug_r(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_debug_r(tile_id - 1)
    DCON.dcon_tile_set_debug_r(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number debug_g between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_debug_g(tile_id)
    return DCON.dcon_tile_get_debug_g(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_debug_g(tile_id, value)
    DCON.dcon_tile_set_debug_g(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_debug_g(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_debug_g(tile_id - 1)
    DCON.dcon_tile_set_debug_g(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number debug_b between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_debug_b(tile_id)
    return DCON.dcon_tile_get_debug_b(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_debug_b(tile_id, value)
    DCON.dcon_tile_set_debug_b(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_debug_b(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_debug_b(tile_id - 1)
    DCON.dcon_tile_set_debug_b(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number real_r between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_real_r(tile_id)
    return DCON.dcon_tile_get_real_r(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_real_r(tile_id, value)
    DCON.dcon_tile_set_real_r(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_real_r(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_real_r(tile_id - 1)
    DCON.dcon_tile_set_real_r(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number real_g between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_real_g(tile_id)
    return DCON.dcon_tile_get_real_g(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_real_g(tile_id, value)
    DCON.dcon_tile_set_real_g(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_real_g(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_real_g(tile_id - 1)
    DCON.dcon_tile_set_real_g(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number real_b between 0 and 1, as per Love2Ds convention...
function DATA.tile_get_real_b(tile_id)
    return DCON.dcon_tile_get_real_b(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_real_b(tile_id, value)
    DCON.dcon_tile_set_real_b(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_real_b(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_real_b(tile_id - 1)
    DCON.dcon_tile_set_real_b(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number pathfinding_index 
function DATA.tile_get_pathfinding_index(tile_id)
    return DCON.dcon_tile_get_pathfinding_index(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_pathfinding_index(tile_id, value)
    DCON.dcon_tile_set_pathfinding_index(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_pathfinding_index(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_pathfinding_index(tile_id - 1)
    DCON.dcon_tile_set_pathfinding_index(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return resource_id resource 
function DATA.tile_get_resource(tile_id)
    return DCON.dcon_tile_get_resource(tile_id - 1) + 1
end
---@param tile_id tile_id valid tile id
---@param value resource_id valid resource_id
function DATA.tile_set_resource(tile_id, value)
    DCON.dcon_tile_set_resource(tile_id - 1, value - 1)
end
---@param tile_id tile_id valid tile id
---@return bedrock_id bedrock 
function DATA.tile_get_bedrock(tile_id)
    return DCON.dcon_tile_get_bedrock(tile_id - 1) + 1
end
---@param tile_id tile_id valid tile id
---@param value bedrock_id valid bedrock_id
function DATA.tile_set_bedrock(tile_id, value)
    DCON.dcon_tile_set_bedrock(tile_id - 1, value - 1)
end
---@param tile_id tile_id valid tile id
---@return biome_id biome 
function DATA.tile_get_biome(tile_id)
    return DCON.dcon_tile_get_biome(tile_id - 1) + 1
end
---@param tile_id tile_id valid tile id
---@param value biome_id valid biome_id
function DATA.tile_set_biome(tile_id, value)
    DCON.dcon_tile_set_biome(tile_id - 1, value - 1)
end
---@param tile_id tile_id valid tile id
---@return number foragers_limit combined plant game and marine foraging limits
function DATA.tile_get_foragers_limit(tile_id)
    return DCON.dcon_tile_get_foragers_limit(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_foragers_limit(tile_id, value)
    DCON.dcon_tile_set_foragers_limit(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_foragers_limit(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_foragers_limit(tile_id - 1)
    DCON.dcon_tile_set_foragers_limit(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid
---@return forage_resource_id foragers_targets 
function DATA.tile_get_foragers_targets_resource(tile_id, index)
    assert(index ~= 0)
    return DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].resource
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid
---@return number foragers_targets 
function DATA.tile_get_foragers_targets_limit(tile_id, index)
    assert(index ~= 0)
    return DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].limit
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid
---@return number foragers_targets 
function DATA.tile_get_foragers_targets_amount(tile_id, index)
    assert(index ~= 0)
    return DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].amount
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid
---@return number foragers_targets 
function DATA.tile_get_foragers_targets_efficiency(tile_id, index)
    assert(index ~= 0)
    return DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].efficiency
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid index
---@param value forage_resource_id valid forage_resource_id
function DATA.tile_set_foragers_targets_resource(tile_id, index, value)
    DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].resource = value
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid index
---@param value number valid number
function DATA.tile_set_foragers_targets_limit(tile_id, index, value)
    DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].limit = value
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid index
---@param value number valid number
function DATA.tile_inc_foragers_targets_limit(tile_id, index, value)
    ---@type number
    local current = DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].limit
    DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].limit = current + value
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid index
---@param value number valid number
function DATA.tile_set_foragers_targets_amount(tile_id, index, value)
    DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].amount = value
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid index
---@param value number valid number
function DATA.tile_inc_foragers_targets_amount(tile_id, index, value)
    ---@type number
    local current = DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].amount
    DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].amount = current + value
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid index
---@param value number valid number
function DATA.tile_set_foragers_targets_efficiency(tile_id, index, value)
    DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].efficiency = value
end
---@param tile_id tile_id valid tile id
---@param index FORAGE_RESOURCE valid index
---@param value number valid number
function DATA.tile_inc_foragers_targets_efficiency(tile_id, index, value)
    ---@type number
    local current = DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].efficiency
    DCON.dcon_tile_get_foragers_targets(tile_id - 1, index)[0].efficiency = current + value
end
---@param tile_id tile_id valid tile id
---@return number infrastructure_needed 
function DATA.tile_get_infrastructure_needed(tile_id)
    return DCON.dcon_tile_get_infrastructure_needed(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_infrastructure_needed(tile_id, value)
    DCON.dcon_tile_set_infrastructure_needed(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_infrastructure_needed(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_infrastructure_needed(tile_id - 1)
    DCON.dcon_tile_set_infrastructure_needed(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number infrastructure 
function DATA.tile_get_infrastructure(tile_id)
    return DCON.dcon_tile_get_infrastructure(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_infrastructure(tile_id, value)
    DCON.dcon_tile_set_infrastructure(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_infrastructure(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_infrastructure(tile_id - 1)
    DCON.dcon_tile_set_infrastructure(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number infrastructure_investment 
function DATA.tile_get_infrastructure_investment(tile_id)
    return DCON.dcon_tile_get_infrastructure_investment(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_infrastructure_investment(tile_id, value)
    DCON.dcon_tile_set_infrastructure_investment(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_infrastructure_investment(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_infrastructure_investment(tile_id - 1)
    DCON.dcon_tile_set_infrastructure_investment(tile_id - 1, current + value)
end
---@param tile_id tile_id valid tile id
---@return number infrastructure_efficiency 
function DATA.tile_get_infrastructure_efficiency(tile_id)
    return DCON.dcon_tile_get_infrastructure_efficiency(tile_id - 1)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_set_infrastructure_efficiency(tile_id, value)
    DCON.dcon_tile_set_infrastructure_efficiency(tile_id - 1, value)
end
---@param tile_id tile_id valid tile id
---@param value number valid number
function DATA.tile_inc_infrastructure_efficiency(tile_id, value)
    ---@type number
    local current = DCON.dcon_tile_get_infrastructure_efficiency(tile_id - 1)
    DCON.dcon_tile_set_infrastructure_efficiency(tile_id - 1, current + value)
end

local fat_tile_id_metatable = {
    __index = function (t,k)
        if (k == "world_id") then return DATA.tile_get_world_id(t.id) end
        if (k == "is_land") then return DATA.tile_get_is_land(t.id) end
        if (k == "is_fresh") then return DATA.tile_get_is_fresh(t.id) end
        if (k == "is_border") then return DATA.tile_get_is_border(t.id) end
        if (k == "is_coast") then return DATA.tile_get_is_coast(t.id) end
        if (k == "has_river") then return DATA.tile_get_has_river(t.id) end
        if (k == "has_marsh") then return DATA.tile_get_has_marsh(t.id) end
        if (k == "x") then return DATA.tile_get_x(t.id) end
        if (k == "y") then return DATA.tile_get_y(t.id) end
        if (k == "z") then return DATA.tile_get_z(t.id) end
        if (k == "elevation") then return DATA.tile_get_elevation(t.id) end
        if (k == "slope") then return DATA.tile_get_slope(t.id) end
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
        if (k == "january_rain") then return DATA.tile_get_january_rain(t.id) end
        if (k == "january_temperature") then return DATA.tile_get_january_temperature(t.id) end
        if (k == "july_waterflow") then return DATA.tile_get_july_waterflow(t.id) end
        if (k == "july_rain") then return DATA.tile_get_july_rain(t.id) end
        if (k == "july_temperature") then return DATA.tile_get_july_temperature(t.id) end
        if (k == "waterlevel") then return DATA.tile_get_waterlevel(t.id) end
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
        if (k == "foragers_limit") then return DATA.tile_get_foragers_limit(t.id) end
        if (k == "infrastructure_needed") then return DATA.tile_get_infrastructure_needed(t.id) end
        if (k == "infrastructure") then return DATA.tile_get_infrastructure(t.id) end
        if (k == "infrastructure_investment") then return DATA.tile_get_infrastructure_investment(t.id) end
        if (k == "infrastructure_efficiency") then return DATA.tile_get_infrastructure_efficiency(t.id) end
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
        if (k == "is_border") then
            DATA.tile_set_is_border(t.id, v)
            return
        end
        if (k == "is_coast") then
            DATA.tile_set_is_coast(t.id, v)
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
        if (k == "x") then
            DATA.tile_set_x(t.id, v)
            return
        end
        if (k == "y") then
            DATA.tile_set_y(t.id, v)
            return
        end
        if (k == "z") then
            DATA.tile_set_z(t.id, v)
            return
        end
        if (k == "elevation") then
            DATA.tile_set_elevation(t.id, v)
            return
        end
        if (k == "slope") then
            DATA.tile_set_slope(t.id, v)
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
        if (k == "january_rain") then
            DATA.tile_set_january_rain(t.id, v)
            return
        end
        if (k == "january_temperature") then
            DATA.tile_set_january_temperature(t.id, v)
            return
        end
        if (k == "july_waterflow") then
            DATA.tile_set_july_waterflow(t.id, v)
            return
        end
        if (k == "july_rain") then
            DATA.tile_set_july_rain(t.id, v)
            return
        end
        if (k == "july_temperature") then
            DATA.tile_set_july_temperature(t.id, v)
            return
        end
        if (k == "waterlevel") then
            DATA.tile_set_waterlevel(t.id, v)
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
        if (k == "foragers_limit") then
            DATA.tile_set_foragers_limit(t.id, v)
            return
        end
        if (k == "infrastructure_needed") then
            DATA.tile_set_infrastructure_needed(t.id, v)
            return
        end
        if (k == "infrastructure") then
            DATA.tile_set_infrastructure(t.id, v)
            return
        end
        if (k == "infrastructure_investment") then
            DATA.tile_set_infrastructure_investment(t.id, v)
            return
        end
        if (k == "infrastructure_efficiency") then
            DATA.tile_set_infrastructure_efficiency(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id tile_id
---@return fat_tile_id fat_id
function DATA.fatten_tile(id)
    local result = {id = id}
    setmetatable(result, fat_tile_id_metatable)
    return result --[[@as fat_tile_id]]
end
