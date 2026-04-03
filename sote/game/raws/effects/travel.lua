local travel_effects = {}


---@param party estate_id
---@param target tile_id
function travel_effects.move_party(party, target)
	local location =  DATA.get_estate_location_from_estate(party)
	DATA.estate_location_set_tile(location, target)
end

---commenting
---@param character Character
function travel_effects.exit_settlement(character)
end

---commenting
---@param character Character
function travel_effects.enter_settlement(character)
end

return travel_effects