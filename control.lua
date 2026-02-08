require "constants"
require "functions"

require "__DragonIndustries__.strings"
require "__DragonIndustries__.mathhelper"
require "__DragonIndustries__.world"
require "__DragonIndustries__.biomecolor"

local ranTick = false
local retrogenDistance = -1

---@param surface LuaSurface
---@param x int
---@param y int
---@param color string
---@param rand LuaRandomGenerator
---@return boolean
local function tryPlaceBush(surface, x, y, color, rand)
	local ename = "glowing-bush-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if surface.can_place_entity{name = ename, position = {x, y}} and not isWaterEdge(surface, x, y) then
		local entity = surface.create_entity{name = ename, position = {x+0.125, y}, force = game.forces.neutral}
		return entity ~= nil and entity.valid
	end
	return false
end

---@param surface LuaSurface
---@param x int
---@param y int
---@param color string
---@param rand LuaRandomGenerator
---@return boolean
local function tryPlaceLily(surface, x, y, color, rand)
	local ename = "glowing-lily-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if surface.can_place_entity{name = ename, position = {x, y}} then
		local entity = surface.create_entity{name = ename, position = {x, y}, force = game.forces.neutral}
		return entity ~= nil and entity.valid
	end
	return false
end

---@param surface LuaSurface
---@param x int
---@param y int
---@param color string
---@param rand LuaRandomGenerator
---@return boolean
local function tryPlaceReed(surface, x, y, color, rand)
	local ename = "glowing-reed-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if surface.can_place_entity{name = ename, position = {x, y}} then
		local entity = surface.create_entity{name = ename, position = {x-0.35, y}, force = game.forces.neutral}
		return entity ~= nil and entity.valid
	end
	return false
end

---@param surface LuaSurface
---@param x int
---@param y int
---@param color string
---@param rand LuaRandomGenerator
---@return boolean
local function tryPlaceTree(surface, x, y, color, rand)
	local ename = "glowing-tree-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if surface.can_place_entity{name = ename, position = {x, y}} and not isWaterEdge(surface, x, y) and surface.count_entities_filtered({type = "tree", area = {{x-6, y-6}, {x+6, y+6}}}) > 1 then
		local entity = surface.create_entity{name = ename, position = {x, y}, force = game.forces.neutral}
		if entity and entity.valid then
			entity.tree_color_index = math.random(1, 8)
			return true
		end
	end
	return false
end

---@param surface LuaSurface
---@param x int
---@param y int
---@param rand LuaRandomGenerator
---@param class string
---@return boolean
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

---@param surface LuaSurface
---@param area BoundingBox
local function controlChunk(surface, area)
	local fac = settings.startup["biolum-plant-density"].value
	if fac <= 0 or not settings.startup["glow-plants"].value then return end
	
	local rand = game.create_random_generator()
	local seed = createSeed(surface, area.left_top.x, area.left_top.y) --[[@as uint]]
	rand.re_seed(seed)
	for class,rate in pairs(PLANT_SPAWN_RATE) do
		local f1 = rand(0, 2147483647)/2147483647
		--game.print("Chunk at " .. serpent.block(area) .. " with chance " .. f .. " / " .. f1)
		if f1 <= rate.chunkChance then
			local f2 = rand(0, 2147483647)/2147483647
			--game.print("Genning Chunk with " .. class .. " at " .. serpent.block(area))
			local count = rand(1, rate.perChunk)
			count = math.max(1, math.ceil(count*fac))
			--game.print("Chunk at " .. serpent.block(area) .. " attempting " .. count)
			for i = 1, count do
				local dx = rand(area.left_top.x, area.right_bottom.x)
				local dy = rand(area.left_top.y, area.right_bottom.y)
				if f2 <= rate.clusterChance then
					local f3 = rand(0, 2147483647)/2147483647
					local s = math.floor(rate.clusterSize[1]+f3*(rate.clusterSize[2]-rate.clusterSize[1])+0.5)
					local r = math.floor(rate.clusterRadius[1]+f3*(rate.clusterRadius[2]-rate.clusterRadius[1])+0.5)
					for k = 1, s do
						local ddx = rand(dx-r, dx+r)
						local ddy = rand(dy-r, dy+r)
						placeIfCan(surface, ddx, ddy, rand, class)
					end
				else
					placeIfCan(surface, dx, dy, rand, class)
				end
			end
		end
	end
end

script.on_event(defines.events.on_chunk_generated, function(event)
	controlChunk(event.surface, event.area)
end)

script.on_event(defines.events.on_tick, function(event)	
	if not ranTick and retrogenDistance >= 0 then
		local surface = game.surfaces["nauvis"]
		for chunk in surface.get_chunks() do
			local x = chunk.x
			local y = chunk.y
			if surface.is_chunk_generated({x, y}) then
				local area = {
					left_top = {
						x = x*CHUNK_SIZE,
						y = y*CHUNK_SIZE
					},
					right_bottom = {
						x = (x+1)*CHUNK_SIZE,
						y = (y+1)*CHUNK_SIZE
					}
				}
				local dx = x*CHUNK_SIZE+CHUNK_SIZE/2
				local dy = y*CHUNK_SIZE+CHUNK_SIZE/2
				local dist = math.sqrt(dx*dx+dy*dy)
				if dist >= retrogenDistance then
					controlChunk(surface, area)
				end
			end
		end
		ranTick = true
		for name,force in pairs(game.forces) do
			force.rechart()
		end
		--game.print("Ran load code")
	end
end)