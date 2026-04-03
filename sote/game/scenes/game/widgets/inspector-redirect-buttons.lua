local ui = require "engine.ui"
local ut = require "game.ui-utils"

local strings = require "engine.string"

local rank_name = require "game.raws.ranks.localisation"

local ib = {}

---checks if player and knows of province
---@param province_id any
---@param player_id any
---@return boolean
function ib.is_visible_to_player(province_id, player_id)
    if player_id ~= INVALID_ID then
        local player_realm = WORLD:player_realm()
        if DATA.realm_get_known_provinces(player_realm)[province_id] then
            return true
        end
        return false
    end
    return true
end

---@param gamescene GameScene
---@param rect Rect
function ib.icon_button_to_close(gamescene, rect)
    if ut.color_icon_button("cancel.png",1,0,0,1,rect) then
        gamescene.inspector = nil
    end
end

---@param gamescene GameScene
---@param realm Realm
---@param rect Rect
---@param tooltip string?
function ib.icon_button_to_realm(gamescene, realm, rect, tooltip)
    local player = WORLD.player_character

    ui.panel(rect:copy():shrink(1), 2, true)
    local center = rect:copy():shrink(2):centered_square()
    if realm ~= INVALID_ID then
        local province_id = DATA.realm_get_capitol(realm)
        if province_id ~= INVALID_ID and ib.is_visible_to_player(province_id,player) then
            if ut.coa(realm, center) then
                gamescene.selected.realm = realm
                gamescene.inspector = "realm"
            end
        else
            ut.coa(realm, center)
        end
    else
        ut.icon_button(ASSETS.icons["uncertainty.png"],center,"Unknown realm!",false)
    end
    if tooltip then
        ui.tooltip(tooltip .. CLICK_STRING,rect)
    end
end

---@param gamescene GameScene
---@param character Character
---@param rect Rect
---@param tooltip string?
function ib.icon_button_to_character(gamescene, character, rect, tooltip)
    require "game.scenes.game.widgets.portrait"(rect, character)
    if ui.invisible_button(rect) then
        gamescene.selected.character = character
        gamescene.inspector = "character"
    end
    if tooltip then
        ui.tooltip(tooltip .. CLICK_STRING, rect)
    end
end

---@param gamescene GameScene
---@param character Character
---@param rect Rect
---@param text string
---@param tooltip string?
function ib.text_button_to_character(gamescene, character, rect, text, tooltip, potential, active)
    if ut.text_button(text, rect, tooltip, potential, active) then
        gamescene.selected.character = character
        gamescene.inspector = "character"
    end
end

---@param gamescene GameScene
---@param tile_id tile_id
---@param rect Rect
---@param tooltip string?
function ib.text_button_to_province_tile(gamescene, tile_id, rect, tooltip)
    if tooltip == nil then
        tooltip = ""
    end
    local player = WORLD.player_character
    local potential = true
    local province = TILE_PROVINCE(tile_id)
    if province ~= INVALID_ID then
        if player ~= INVALID_ID and not ib.is_visible_to_player(province,player) then
            potential = false
        end
        if ut.text_button(PROVINCE_NAME(province), rect, tooltip .. CLICK_STRING, potential) then
            gamescene.selected.province = province
            gamescene.selected.tile = tile_id
            gamescene.inspector = "tile"
        end
    else
        ut.text_button("Unknown", rect, tooltip)
    end
end

---@param gamescene GameScene
---@param estate estate_id
---@param building building_id
---@param rect Rect
---@param tooltip string?
function ib.text_button_to_estate(gamescene, estate, building, rect, text, tooltip)
    local player = WORLD.player_character
    local potential = true
    if estate ~= INVALID_ID then
        local province = ESTATE_PROVINCE(estate)
        if player ~= INVALID_ID and not ib.is_visible_to_player(province,player) then
            potential = false
        end
        if ut.text_button(text, rect, tooltip .. CLICK_STRING, potential) then
            gamescene.selected.building = building
            gamescene.selected.estate = estate
            gamescene.inspector = "building"
        end
    else
        ut.text_button(text,rect,tooltip,false)
    end
end

---@param gamescene GameScene
---@param estate estate_id
---@param building building_id
---@param rect Rect
---@param tooltip string?
function ib.icon_button_to_estate(gamescene, estate, building, rect, tooltip)
    local player = WORLD.player_character
    local potential = true
    if estate ~= INVALID_ID then
        local province = ESTATE_PROVINCE(estate)
        if player ~= INVALID_ID and not ib.is_visible_to_player(province,player) then
            potential = false
        end
        if ut.icon_button(ASSETS.icons["village.png"], rect, tooltip .. CLICK_STRING, potential) then
            gamescene.selected.building = building
            gamescene.selected.estate = estate
            gamescene.inspector = "building"
        end
    else
        ut.icon_button(ASSETS.icon["uncertainty.png"],rect,tooltip,false)
    end
end

function ib.icon_button_to_building(gamescene,building_id,rect,tooltip,potential,active)
    local player = WORLD.player_character
    local potential = true
    if building_id ~= INVALID_ID then
        local estate_id = BUILDING_ESTATE(building_id)
        local province = ESTATE_PROVINCE(estate_id)
        if player ~= INVALID_ID and not ib.is_visible_to_player(province,player) then
            potential = false
        end
        local building_type = DATA.building_get_current_type(building_id)
        if ut.color_icon_button(
            DATA.building_type_get_icon(building_type),
            DATA.building_type_get_r(building_type),
            DATA.building_type_get_g(building_type),
            DATA.building_type_get_b(building_type),
            1, rect,tooltip .. CLICK_STRING,potential)
        then
            gamescene.selected.building = building_id
            gamescene.selected.estate = estate_id
            gamescene.inspector = "building"
        end
    else
        ut.icon_button(ASSETS.icons["uncertainty.png"],rect,tooltip .. CLICK_STRING,false)
    end
end

---@param gamescene GameScene
---@param party_id estate_id
---@param rect Rect
---@param tooltip string?
function ib.text_button_to_party(gamescene, party_id, rect, tooltip)
    local warband_utils = require "game.entities.warband"
    local player = WORLD.player_character
    local potential = true
    if party_id ~= INVALID_ID then
        local province = TILE_PROVINCE(ESTATE_TILE(party_id))
        if player ~= INVALID_ID and not ib.is_visible_to_player(province,player) then
            potential = false
        end
        if ut.text_button(ESTATE_NAME(party_id) or party_id,rect,tooltip .. CLICK_STRING,potential) then
            gamescene.selected.estate = party_id
            gamescene.inspector = "warband"
        end
    else
        ut.text_button(ESTATE_NAME(party_id),rect,tooltip,false)
    end
end

---renders text and square close button to the right
---@param game GameScene
---@param rect Rect
---@param inspector_name string
function ib.render_inspector_header(game,rect,inspector_name)
    ui.panel(rect,2,true,true)
    ui.text(inspector_name, rect:subrect(0,0,rect.width-rect.height,rect.height,"left","up"),"left","center")
    -- add a back (last inspector and target) button?
    ib.icon_button_to_close(game,rect:subrect(0,0,rect.height,rect.height,"right","up"))
end

---renders clickable portrait redirect with additional icons and tooltips on top
---@param rect Rect
---@param pop_id pop_id
---@param tooltip string?
function ib.render_portrait_with_overlay(game, rect, pop_id, tooltip)
    local player_id = WORLD.player_character
    -- first validate that pop_id is valid
    if pop_id == INVALID_ID then
        return
    -- should have DATA validate calls for all objects
    elseif not DCON.dcon_pop_is_valid(pop_id-1) then
        return
    end

    local left_up_rect = rect:subrect(0,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"left","up")
    local center_up_rect = rect:subrect(0,0,rect.width,ut.BASE_HEIGHT,"center","up")
    local right_up_rect  = rect:subrect(0,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"right","up")
    local right_center_rect  = rect:subrect(0,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"right","center")
    local left_center_rect  = rect:subrect(0,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"left","center")
    local left_down_rect  = rect:subrect(0,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"left","down")
    local center_down_rect  = rect:subrect(0,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"center","down")
    local right_down_rect   = rect:subrect(0,0,ut.BASE_HEIGHT,ut.BASE_HEIGHT,"right","down")

    local pop_name = NAME(pop_id)

    -- draw portrait
    ib.icon_button_to_character(game,pop_id,rect,tooltip)

    -- draw over portrait
    require "game.scenes.game.widgets.pop-ui-widgets".render_age(center_up_rect,pop_id)
    local realm_id = REALM(pop_id)
    ib.icon_button_to_realm(game, realm_id, right_down_rect, pop_name .. " is a " .. rank_name(pop_id)
        .. " of " .. DATA.realm_get_name(realm_id) .. ".")
    if DATA.pop_get_busy(pop_id) then
        ut.render_icon(right_up_rect,"stopwatch.png",.8,.8,.8,1,true)
        ui.tooltip(pop_name .. " is currently busy.",left_up_rect)
    end
    -- only draw loyalty and blood if player
    if player_id and player_id ~= INVALID_ID then
		local character_loyalty = LOYAL_TO(pop_id)
        local player_loyalty = LOYAL_TO(player_id)
        if character_loyalty ~= INVALID_ID and character_loyalty == player_id then
            ut.render_icon(left_down_rect,"kneeling.png",0,1,0,1,true)
            ui.tooltip(pop_name .. " has sorn loyalty to me.",left_down_rect)
        elseif player_loyalty ~= INVALID_ID and player_loyalty == pop_id then
            ut.render_icon(left_down_rect,"despair.png",0,1,0,1,true)
            ui.tooltip("I have sworn loyalty to " .. pop_name .. ".",left_down_rect)
        end
		-- blood relationship
        if player_id == pop_id then
            ut.render_icon(center_down_rect,"self-love.png",0.72,0.13,0.27,1,true)
            ui.tooltip("This is me!",center_down_rect)
		else -- only check for relations and not looking at player character
			local is_child, is_parent, is_sibling = false, false, false
			local parent = PARENT(pop_id)
			if parent ~= INVALID_ID and parent == player_id then
				is_parent = true
			end
            local player_parent = PARENT(player_id)
			if player_parent ~= INVALID_ID then
                if player_parent == pop_id then
				    is_child = true
                else -- check player parent to see if any of its children
                    DATA.for_each_parent_child_relation_from_parent(player_parent, function (item)
                        local child = DATA.parent_child_relation_get_child(item)
                        if child == pop_id then
                            is_sibling = true
                        end
                    end)
                end
			end
			-- draw blood relation only if there is one
			if is_parent then
				ut.render_icon(center_down_rect,"droplets.png",0.72,0.13,0.27,1,true)
                ui.tooltip(pop_name .. " is my child",center_down_rect)
            elseif is_child then
				ut.render_icon(center_down_rect,"minions.png",0.72,0.13,0.27,1,true)
                ui.tooltip(pop_name .. " is my parent",center_down_rect)
            elseif is_sibling then
				ut.render_icon(center_down_rect,"ages.png",0.72,0.13,0.27,1,true)
                ui.tooltip(pop_name .. " is my " .. (FEMALE(pop_id) and "sister" or "brother"),center_down_rect)
			end
        end
    end
    local border_width = math.max(1, math.floor(math.min(rect.height, rect.width) / ut.BASE_HEIGHT))
    left_up_rect:shrink(border_width/2)
    left_up_rect.x = left_up_rect.x + border_width
    left_up_rect.y = left_up_rect.y + border_width
    require "game.scenes.game.widgets.pop-ui-widgets".render_female_icon(left_up_rect,pop_id)
end

return ib