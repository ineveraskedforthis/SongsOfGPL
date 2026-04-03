local ffi = require("ffi")
---manage dll loading


-- match jit.os to python platform.system() here
local os_patterns = {
    ['linux'] = 'Linux',
    ['windows'] = 'Windows',
}
-- match jit.arch to python platform.machine() here
local arch_patterns = {
    ['x64'] = 'x86_64',
}

SYSTEM = "unknown"
MACHINE = "unknown"

local jit_os = jit.os:lower()
for pattern, name in pairs(os_patterns) do
    if jit_os:match(pattern) then
        SYSTEM = name
        break
    end
end

local jit_arch = jit.arch:lower()
for pattern, name in pairs(arch_patterns) do
    if jit_arch:match(pattern) then
        MACHINE = name
        break
    end
end

print("jit id: " ..  jit.os .. " " .. jit.arch)
print("library path: lib/" .. SYSTEM .. "/" .. MACHINE)

local dll_path = love.filesystem.getSourceBaseDirectory() .. "/lib/" .. SYSTEM .. "/" .. MACHINE

if love.system.getOS() == "Windows" then
	DCON = ffi.load(dll_path .. "/dcon.dll")
else
	DCON = ffi.load(dll_path .. "/dcon.so")
end


-- local dll_path = "C:/_projects/dcon/DataContainer/x64/Debug/"
-- DCON = ffi.load(dll_path .. "lua_dll_build_test.dll")

assert(DCON, "FAILED_TO_LOAD_DLL")

-- SHOULD BE CHANGED TOGETHER WITH ACCORDING VALUE IN cpp FILE
POP_BUY_PRICE_MULTIPLIER = 3

ffi.cdef[[
    void* calloc( size_t num, size_t size );
    void update_vegetation(float);
    void update_economy();

    void apply_biome(int32_t);
    void apply_resource(int32_t);

    float estimate_province_use_price(uint32_t, uint32_t);
    float estimate_building_type_income(int32_t, int32_t, int32_t, bool);
    void dcon_everything_write_file(char const* name);
    void dcon_everything_read_file(char const* name);
    void update_foraging_data(uint32_t world_size);

    void load_state(char const*);
    int32_t dcon_reset();

    void update_map_mode_pointer(uint8_t* map, uint32_t world_size);
    int32_t get_neighbor(int32_t tile_id, uint8_t neighbor_index, uint32_t world_size);

    void ai_update_price_belief(int32_t trader_raw_id);
	void ai_trade(int32_t trader_raw_id);

	// backend time tracking
	void set_world_current_year(uint32_t year);
	uint32_t get_world_current_year(void);
	void set_world_current_tick(uint32_t tick);
	uint32_t get_world_current_tick(void);
	void set_world_tick_definitions(uint32_t minute, uint32_t hour, uint32_t day, uint32_t month);
	uint32_t get_world_ticks_per_minute(void);
	uint32_t get_world_ticks_per_hour(void);
	uint32_t get_world_ticks_per_day(void);
	uint32_t get_world_ticks_per_month(void);
	// birthdate values
	uint32_t birth_month(uint32_t pop_id);
	uint32_t birth_day(uint32_t pop_id);
	uint32_t birth_hour(uint32_t pop_id);
	uint32_t birth_minute(uint32_t pop_id);
	// age calculations
	uint32_t age_ticks(uint32_t pop_id);
	uint32_t age_months(uint32_t pop_id);
	uint32_t age_years(uint32_t pop_id);
	float age_multiplier(uint32_t pop_id);
	float job_efficiency(uint32_t,uint8_t);
    // pop time calculations
	float pop_free_time(uint32_t pop);
	float pop_travel_time(uint32_t pop,float free);
	float pop_forage_time(uint32_t pop,float free,float party);
	float pop_work_time(uint32_t pop,float free,float party,float forage);
	// misc
	bool pop_same_location(uint32_t pop_a,uint32_t pop_b);
    bool is_dependent(uint32_t child);
    bool is_dependent_of(uint32_t child,uint32_t parent);
]]


DATA = require "codegen.output.generated"
require "codegen.helpers"

local state_save_path = love.filesystem.getSaveDirectory() .. "_sote_save.binbeaver"
function SAVE_GAME_STATE()
    DCON.dcon_everything_write_file(state_save_path)
    DATA.save_state()
end
function LOAD_GAME_STATE()
    print("loading dll state")
    local start = love.timer.getTime()
    --DCON.dcon_everything_read_file(state_save_path)
    DCON.load_state(state_save_path)
    print(tostring(love.timer.getTime() - start) .. " seconds")

    print("loading lua state")
    start = love.timer.getTime()
    DATA.load_state()
    print(tostring(love.timer.getTime() - start) .. " seconds")

    print("state loaded, restoring unsaved data")
    start = love.timer.getTime()
    RESTORE_UNSAVED_TILES_DATA()
    REGENERATE_RAWS()
    RECALCULATE_WEIGHTS_TABLE()
    print(tostring(love.timer.getTime() - start) .. " seconds")
end
