require "constants"
require "functions"
require "prototypes.colorkeys"

require "__DragonIndustries__.strings"
require "__DragonIndustries__.mathhelper"

local function controlChunk(surface, area)
	if not Config.glowPlants then return end
	
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
			count = math.max(1, math.ceil(count*Config.density))
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

--[[
local function onEntitySpawned(event)	
	local entity = event.entity
	
	if entity.type == "unit" and settings.startup["glow-biters"].value then
		if string.find(entity.name, "biter", 1, true) or string.find(entity.name, "spitter", 1, true) then
			local key = literalReplace(entity.name, "-biter", "")
			key = literalReplace(key, "-spitter", "")
			--game.print(key)
			local params = BITER_GLOW_PARAMS[key]
			if params then
				rendering.draw_light{sprite="utility/light_medium", scale=params.size, intensity=1, color=params.color, target=entity, surface=entity.surface}
			end
		end
	end
end

script.on_event(defines.events.on_entity_spawned, onEntitySpawned)
--]]