require "constants"
require "config"

function cantorCombine(a, b)
	--a = (a+1024)%16384
	--b = b%16384
	local k1 = a*2
	local k2 = b*2
	if a < 0 then
		k1 = a*-2-1
	end
	if b < 0 then
		k2 = b*-2-1
	end
	return 0.5*(k1 + k2)*(k1 + k2 + 1) + k2
end

function createSeed(surface, x, y) --Used by Minecraft MapGen
	local seed = surface.map_gen_settings.seed
	if Config.seedMixin ~= 0 then
		seed = bit32.band(cantorCombine(seed, Config.seedMixin), 2147483647)
	end
	return bit32.band(cantorCombine(seed, cantorCombine(x, y)), 2147483647)
end

function getRandomColorForTile(tile, rand)
	local colors,water = getColorsForTile(tile)
	if colors == nil or #colors == 0 then return nil end
	return colors[rand(1, #colors)], water
end

function isWaterEdge(surface, x, y)
	if surface.get_tile{x-1, y}.valid and surface.get_tile{x-1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x+1, y}.valid and surface.get_tile{x+1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y-1}.valid and surface.get_tile{x, y-1}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y+1}.valid and surface.get_tile{x, y+1}.prototype.layer == "water-tile" then
		return true
	end
end

function isInChunk(x, y, chunk)
	local minx = math.min(chunk.left_top.x, chunk.right_bottom.x)
	local miny = math.min(chunk.left_top.y, chunk.right_bottom.y)
	local maxx = math.max(chunk.left_top.x, chunk.right_bottom.x)
	local maxy = math.max(chunk.left_top.y, chunk.right_bottom.y)
	return x >= minx and x <= maxx and y >= miny and y <= maxy
end

local function tryPlaceBush(surface, x, y, color, rand)
	local ename = "glowing-bush-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} and not isWaterEdge(surface, x, y) then
		local entity = surface.create_entity{name = ename, position = {x+0.125, y}, force = game.forces.neutral}
		if entity then
			surface.create_entity{name = "glowing-plant-light-" .. color, position = {x, y}, force = game.forces.neutral}
			--entity.graphics_variation = math.random(1, game.entity_prototypes[ename].)
			return true
		end
	end
end

local function tryPlaceLily(surface, x, y, color, rand)
	local ename = "glowing-lily-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} then
		local entity = surface.create_entity{name = ename, position = {x, y}, force = game.forces.neutral}
		if entity then
			surface.create_entity{name = "glowing-water-plant-light-" .. color, position = {x, y}, force = game.forces.neutral}
			--entity.graphics_variation = math.random(1, game.entity_prototypes[ename].)
			return true
		end
	end
end

local function tryPlaceReed(surface, x, y, color, rand)
	local ename = "glowing-reed-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} then
		local entity = surface.create_entity{name = ename, position = {x-0.35, y}, force = game.forces.neutral}
		if entity then
			surface.create_entity{name = "glowing-water-plant-light-" .. color, position = {x, y}, force = game.forces.neutral}
			--entity.graphics_variation = math.random(1, game.entity_prototypes[ename].)
			return true
		end
	end
end

local function tryPlaceTree(surface, x, y, color, rand)
	local ename = "glowing-tree-" .. color .. "-" .. rand(1, PLANT_VARIATIONS[color])
	if --[[isInChunk(dx, dy, chunk) and ]]surface.can_place_entity{name = ename, position = {x, y}} and not isWaterEdge(surface, x, y) and #surface.find_entities_filtered({type = "tree", area = {{x-4, y-4}, {x+4, y+4}}}) > 1 then
		local entity = surface.create_entity{name = ename, position = {x, y}, force = game.forces.neutral}
		if entity then
			for d = 0.5,2.5,1 do
				local rx = (rand(0, 10)-5)/10
				local ry = (rand(0, 10)-5)/10
				surface.create_entity{name = "glowing-plant-light-" .. color, position = {x+rx, y-d+ry}, force = game.forces.neutral}
			end
			entity.tree_color_index = math.random(1, 9)
			--entity.graphics_variation = math.random(1, game.entity_prototypes[ename].)
			return true
		end
	end
end

function placeIfCan(surface, x, y, rand, class)
	local tile = surface.get_tile(x, y)
	local color,water = getRandomColorForTile(tile, rand) --need some way to prevent rainbow water
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

--------------

local function createEmptyAnimation()
	return
	{
	  filename = "__core__/graphics/empty.png",
	  priority = "high",
	  width = 1,
	  height = 1,
	  frame_count = 1,
	  direction_count = 1,
	}
end

function convertColor(argb, divideBy)
	local blue = bit32.band(argb, 255)
	local green = bit32.band(bit32.rshift(argb, 8), 255)
	local red = bit32.band(bit32.rshift(argb, 16), 255)
	if divideBy then
		red = red/255
		green = green/255
		blue = blue/255
	end
	return {r = red, g = green, b = blue}
end

local function permuteColor(clr, dr, dg, db)
	clr = table.deepcopy(clr)
	clr.r = math.max(0, math.min(255, clr.r+dr))
	clr.g = math.max(0, math.min(255, clr.g+dg))
	clr.b = math.max(0, math.min(255, clr.b+db))
	return clr
end

local function generateColorVariations(colors)
	local base = colors[1]
	for i = 1,8 do
		table.insert(colors, permuteColor(base, math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)))
	end
	return colors
end

local function createLight(name, br, size, clr, collision)
	return {
		type = "rail-chain-signal",
		name = name,
		icon_size = 32,
		flags = {"placeable-off-grid", "not-on-map"},
		max_health = 10,
		destructible = false,
		corpse = "small-remnants",
		--selectable_in_game = false,
		collision_mask = collision,
		animation = createEmptyAnimation(),
		selection_box_offsets =
		{
		  {0, 0},
		  {0, 0},
		  {0, 0},
		  {0, 0},
		  {0, 0},
		  {0, 0},
		  {0, 0},
		  {0, 0}
		},
		rail_piece = createEmptyAnimation(),
		green_light = {intensity = br, size = size, color=clr},
		orange_light = {intensity = br, size = size, color=clr},
		red_light = {intensity = br, size = size, color=clr},
		blue_light = {intensity = br, size = size, color=clr},
	}
end

function createGlowingPlants(color, nvars)
	for i = 1,PLANT_VARIATIONS[color] do
		local ename = "glowing-tree-" .. color .. "-" .. i
		
		local tree = table.deepcopy(data.raw.tree["tree-02"])
		tree.name = ename
		local render = RENDER_COLORS[color]
		tree.colors = {convertColor(render, false)}
		local light = convertColor(render, true)
		tree.localised_name = {"glowing-plants.glowing-tree", {"glowing-color-name." .. color}}
        tree.subgroup = "glowing-tree"
		
		math.randomseed(render)
		tree.colors = generateColorVariations(tree.colors)
		local b = 1--2
		local s = 5--6
		
		local r = 0.7
		
		local bname = "glowing-bush-" .. color .. "-" .. i
		
		local bush = {
          type = "simple-entity",
          name = bname,
          flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable"},
          selectable_in_game = true,
		  minable = nil,
          icon = "__Bioluminescence__/graphics/icons/bush.png",
		  icon_size = 32,
          subgroup = "glowing-bush",
          order = bname,
          selection_box = {{-r, -r}, {r, r}},
		  collision_mask = {"water-tile"},
          render_layer = "decorative",
		  localised_name = {"glowing-plants.glowing-bush", {"glowing-color-name." .. color}},
          pictures =
          {
            {
              filename = "__Bioluminescence__/graphics/entity/bush/v2/" .. color .. "-01.png",
              width = 180,
              height = 128,
			  scale = 0.75,
			  shift = {0.5, 0}
            },
            {
              filename = "__Bioluminescence__/graphics/entity/bush/v2/" .. color .. "-02.png",
              width = 96,
              height = 64,
			  scale = 1,
			  shift = {0.4, 0}
            },
            {
              filename = "__Bioluminescence__/graphics/entity/bush/v2/" .. color .. "-03.png",
              width = 96,
              height = 64,
			  scale = 1,
			  shift = {0.2, 0.2}
            }
          }
		}
		
		local lname = "glowing-lily-" .. color .. "-" .. i
		
		local lily = {
          type = "simple-entity",
          name = lname,
          flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable"},
          selectable_in_game = true,
		  minable = nil,
          icon = "__Bioluminescence__/graphics/icons/lily.png",
		  icon_size = 32,
          subgroup = "glowing-lily",
          order = lname,
          selection_box = {{-r, -r}, {r, r}},
		  collision_mask = {},
          render_layer = "decorative",
		  localised_name = {"glowing-plants.glowing-lily", {"glowing-color-name." .. color}},
          pictures =
          {
            {
              filename = "__Bioluminescence__/graphics/entity/lily/lily-01.png",
              width = 64,
              height = 64,
			  scale = 1,
			  tint = light,
			  shift = {0.08, -0.2}
            },
            {
              filename = "__Bioluminescence__/graphics/entity/lily/lily-02.png",
              width = 64,
              height = 64,
			  scale = 1,
			  tint = light,
			  shift = {0.08, -0.2}
            }
          }
		}
		
		local rname = "glowing-reed-" .. color .. "-" .. i
		
		local reed = {
          type = "simple-entity",
          name = rname,
          flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable"},
          selectable_in_game = true,
		  minable = nil,
          icon = "__Bioluminescence__/graphics/icons/reeds.png",
		  icon_size = 32,
          subgroup = "glowing-reed",
          order = rname,
          selection_box = {{-r, -r}, {r, r}},
		  collision_mask = {},
          render_layer = "decorative",
		  localised_name = {"glowing-plants.glowing-reed", {"glowing-color-name." .. color}},
          pictures =
          {
            {
              filename = "__Bioluminescence__/graphics/entity/reeds/v1/" .. color .. ".png",
              width = 128,
              height = 96,
			  scale = 1,
			  shift = {0.35, -0.1}
            }
          }
		}
		
		log("Adding glowing plants for color " .. color)
		
		data:extend({
			tree,
			bush,
			lily,
			reed,
			createLight("glowing-plant-light-" .. color, b, s, light, {"water-tile"}),
			createLight("glowing-water-plant-light-" .. color, b, s, light, {}),
		})
	end
end