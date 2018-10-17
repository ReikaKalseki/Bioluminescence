require "config"
require "constants"
require "functions"

local function controlChunk(surface, area)
	if not Config.glowPlants then return end
	
	local rand = game.create_random_generator()
	local x = (area.left_top.x+area.right_bottom.x)/2
	local y = (area.left_top.y+area.right_bottom.y)/2
	local seed = createSeed(surface, x, y)
	rand.re_seed(seed)
	local f1 = rand(0, 2147483647)/2147483647
	--game.print("Chunk at " .. x .. ", " .. y .. " with chance " .. f .. " / " .. f1)
	--if f1 < f then
		--game.print("Genning Chunk at " .. x .. ", " .. y)
		x = x-16+rand(0, 32)
		y = y-16+rand(0, 32)
		local count = rand(1, PLANT_SPAWN_RATE)
		count = math.max(1, math.ceil(count*Config.density))
		--game.print("Chunk at " .. x .. ", " .. y .. " attempting " .. count)
		for i = 1, count do
			local r = CHUNK_SIZE/2
			local dx = x-r+rand(0, r*2)
			local dy = y-r+rand(0, r*2)
			placeIfCan(surface, dx, dy, rand)
		end
	--end
end

script.on_event(defines.events.on_chunk_generated, function(event)
	--controlChunk(event.surface, event.area)
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