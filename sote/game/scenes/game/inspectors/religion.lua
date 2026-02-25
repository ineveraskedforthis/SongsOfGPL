local ui = require "engine.ui"
local ut = require "game.ui-utils"
local string = require "engine.string"
local spirit_module = require "game.entities.spirit" -- <-- Importar el módulo

local religion = {}

-- Calcula el rect del inspector de religión
local function get_rect()
    local fs = ui.fullscreen()
    return fs:subrect(ut.BASE_HEIGHT*2, ut.BASE_HEIGHT * 11, ut.BASE_HEIGHT * 16, fs.height, "left", "up")
end

-- Mask para cerrar al clicar fuera
function religion.mask()
    if ui.trigger(get_rect()) then return false end
    return true
end

--- Dibuja el inspector de religión
---@param gam GameScene
---@param rect Rect
function religion.draw(gam, rect)
    -- Si no nos pasan rect, lo calculamos
    rect = rect or get_rect()

    local pid = WORLD.player_character
    --print(pid)

    local pop = DATA.fatten_pop(pid)

    local fid = pop.faith      -- número (faith_id)
    --print(fid)

    local faith = DATA.fatten_faith(fid)

    local nombre_fe   = faith.name
    --print(nombre_fe)

    local rites_id = faith.burial_rites        -- valor de tipo BURIAL_RITES
    --print(rites_id)
    local rite_string = BURIAL_NAMES[rites_id] or "DESCONOCIDO"
    --print(rite_string)
    --[[
    local br = DATA.fatten_burial_rites(rites_id)
    local nombre_rito = br.name               -- string
    local desc_rito   = br.description        -- string

    print(nombre_rito)
    print(desc_rito)
    ]]--

    -- Obtener la religión padre desde la fe
    local religion_id = faith.religion  -- <- Nueva línea
    local religion_name = DATA.religion_get_name(religion_id) or "Desconocida"  -- Asume que existe DATA.religion_get_name

    -- Panel de fondo
    ui.panel(rect)
    local unit = ut.BASE_HEIGHT

    -- Título del inspector
    local title_panel = rect:subrect(0, 0, rect.width, unit, "left", "up"):shrink(5)
    ui.centered_text("Religion Inspector", title_panel)

    -- Área de contenido
    local content = rect:subrect(0, unit, rect.width, rect.height - unit, "left", "up"):shrink(5)
    local layout = ui.layout_builder()
        :vertical()
        :position(content.x, content.y)
        :spacing(unit)
        :build()

    -- Sección: Faith
    local faith_panel = layout:next(content.width, unit)
    ut.data_entry("Faith: ", nombre_fe, faith_panel, "TODO: cargar y mostrar la fe del personaje")

    -- Sección: Religion
    local rel_panel = layout:next(content.width, unit)
    ut.data_entry("Religion: ", religion_name, rel_panel, "TODO: cargar y mostrar la religión")

    -- Sección: Burial Rites
    local rites_panel = layout:next(content.width, unit)
    ut.data_entry("Burial Rites: ", rite_string, rites_panel, "TODO: cargar y mostrar el rito funerario")

        -- Obtener nombres de los ritos
    local birth_rite = BIRTH_NAMES[faith.birth_rites] or "Desconocido"
    local passage_rite = PASSAGE_NAMES[faith.passage_rites] or "Desconocido"
    local disease_rite = DISEASE_NAMES[faith.disease_rites] or "Desconocido"
    
    -- Mostrar en UI
    local rites_1 = layout:next(content.width, unit)
    local rites_2 = layout:next(content.width, unit)
    local rites_3 = layout:next(content.width, unit)

    ut.data_entry("Ritos de Nacimiento:", birth_rite, rites_1,"")
    ut.data_entry("Ritos de Paso:", passage_rite, rites_2, "")
    ut.data_entry("Ritos de Enfermedad:", disease_rite, rites_3,"")

    -- En religion.draw()
    local spirit_name = "Ninguno"
    local spirit_domain = "Desconocido"
    local spirit_rank = "N/A"

    if faith.spirit ~= nil then
        spirit_name = spirit_module.get_name(faith.spirit)
        spirit_domain = spirit_module.get_domain(faith.spirit)
        spirit_rank = spirit_module.get_rank(faith.spirit)
    end

    -- Mostrar en UI
    local spirit_panel_1 = layout:next(content.width, unit)
    local spirit_panel_2 = layout:next(content.width, unit)
    local spirit_panel_3 = layout:next(content.width, unit)

    ut.data_entry("Espíritu principal: ", spirit_name, spirit_panel_1, "Espíritu asociado a esta fe")
    ut.data_entry("Dominio: ", spirit_domain, spirit_panel_2, "Espíritu asociado a esta fe")
    ut.data_entry("Spirit Rank: ", spirit_rank, spirit_panel_3, "Espíritu asociado a esta fe")




    end

return religion

