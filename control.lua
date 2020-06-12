require "config"
require "constants"
require "functions"
require "prototypes.colorkeys"

require "__DragonIndustries__.strings"
require "__DragonIndustries__.mathhelper"

addCommands()

script.on_configuration_changed(function()
	reloadAllLights()
end)

local function controlChunk(surface, area)
	if not Config.glowPlants then return end
	
	local rand = game.create_random_generator()
	local seed = createSeed(surface, area.left_top.x, area.left_top.y)
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

script.on_event(defines.events.on_chunk_generated, function(event)
	controlChunk(event.surface, event.area)
end)

script.on_event(defines.events.on_tick, function(event)	
	if not ranTick and Config.retrogenDistance >= 0 then
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
				if dist >= Config.retrogenDistance then
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
	
	--local pos=game.players[1].position
	--for k,v in pairs(game.surfaces.nauvis.find_entities_filtered{area={{pos.x-1,pos.y-1},{pos.x+1,pos.y+1}}, type="resource"}) do v.destroy() end
end)

local function onEntityRemoved(event)	
	local entity = event.entity
	--[[
	if string.find(entity.name, "glowing-tree", 1, true) then
		--game.print(entity.name)
		local pos = entity.position
		local lights = entity.surface.find_entities_filtered{type = "rail-chain-signal", area = {{pos.x-1, pos.y-3.5}, {pos.x+1, pos.y+0.5}}}
		for _,light in pairs(lights) do
			if string.find(light.name, "glowing-plant", 1, true) then
				light.destroy()
			end
		end
	end
	--]]
end

local function onEntityAdded(event)	
	local entity = event.created_entity
	if string.find(entity.name, "glowing-tree", 1, true) then
		createTreeLightSimple(entity)
	end
end

local function onEntitySpawned(event)	
	local entity = event.entity
	
	if entity.type == "unit" and Config.glowBiters then
		--[[
		if string.find(entity.name, "biter", 1, true) or string.find(entity.name, "spitter", 1, true) then
			local key = literalReplace(entity.name, "-biter", "")
			key = literalReplace(key, "-spitter", "")
			--game.print(key)
			local params = BITER_GLOW_PARAMS[key]
			if params then
				rendering.draw_light{sprite="utility/light_medium", scale=params.size, intensity=1, color=params.color, target=entity, surface=entity.surface}
			end
		end
		--]]
		createBiterLight(entity)
	end
end

script.on_event(defines.events.on_entity_died, onEntityRemoved)
script.on_event(defines.events.script_raised_destroy, onEntityRemoved)
script.on_event(defines.events.on_player_mined_entity, onEntityRemoved)
script.on_event(defines.events.on_robot_mined_entity, onEntityRemoved)

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)

script.on_event(defines.events.on_entity_spawned, onEntitySpawned)