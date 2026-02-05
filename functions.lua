require "constants"

require "__DragonIndustries__.mathhelper"
require "__DragonIndustries__.items"
require "__DragonIndustries__.world"
require "__DragonIndustries__.strings"
require "__DragonIndustries__.color"

local function tryPlaceBush(surface, x, y, color, rand)
	local ename = "glowing-bush-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} and not isWaterEdge(surface, x, y) then
		local entity = surface.create_entity{name = ename, position = {x+0.125, y}, force = game.forces.neutral}
		return entity ~= nil and entity.valid
	end
	return false
end

local function tryPlaceLily(surface, x, y, color, rand)
	local ename = "glowing-lily-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} then
		local entity = surface.create_entity{name = ename, position = {x, y}, force = game.forces.neutral}
		return entity ~= nil and entity.valid
	end
	return false
end

local function tryPlaceReed(surface, x, y, color, rand)
	local ename = "glowing-reed-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} then
		local entity = surface.create_entity{name = ename, position = {x-0.35, y}, force = game.forces.neutral}
		return entity ~= nil and entity.valid
	end
	return false
end

local function tryPlaceTree(surface, x, y, color, rand)
	local ename = "glowing-tree-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} and not isWaterEdge(surface, x, y) and #surface.find_entities_filtered({type = "tree", area = {{x-4, y-4}, {x+4, y+4}}}) > 1 then
		local entity = surface.create_entity{name = ename, position = {x, y}, force = game.forces.neutral}
		if entity and entity.valid then
			entity.tree_color_index = math.random(1, 9)
			return true
		end
	end
	return false
end

function placeIfCan(surface, x, y, rand, class)
	local tile = surface.get_tile(x, y)
	local color,water = getRandomColorForTile(tile, rand)
	if color then
		if class == "bush" and (not water) then
			return tryPlaceBush(surface, x, y, color, rand)
		elseif class == "tree" and (not water) then
			return tryPlaceTree(surface, x, y, color, rand)
		elseif class == "reed" then
			return tryPlaceReed(surface, x, y, color, rand)
		elseif class == "lily" and water then
			return tryPlaceLily(surface, x, y, color, rand)
		end
	end
	return false
end