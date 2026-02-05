require "constants"
require "functions"

require "__DragonIndustries__.arrays"

---@class (exact) BiolumPlant
---@field category string
---@field entity data.SimpleEntityPrototype|data.TreePrototype
---@field color Color

BIOLUM_PLANTS = {} ---@type {[string]: BiolumPlant}

---@param base Color
---@return [Color]
local function generateColorVariations(base)
	local colors = {}
	for i = 1,8 do
		table.insert(colors, permuteColor(base, math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)))
	end
	return colors
end

---@param typename string
---@param color string
---@param i int
---@param r number
---@param landOnly boolean
---@param pictures data.SpriteVariations
---@return data.SimpleEntityPrototype
local function createBasicPlantPrototype(typename, color, i, r, landOnly, pictures)
	local bname = "glowing-" .. typename .. "-" .. color .. "-" .. i
	return {
          type = "simple-entity",
          name = bname,
          icon = "__Bioluminescence__/graphics/icons/" .. typename .. ".png",
		  icon_size = 32,
          subgroup = "glowing-" .. typename,
          order = bname,
		  localised_name = {"glowing-plants.glowing-bush", {"glowing-color-name." .. color}},
          selection_box = {{-r, -r}, {r, r}},
		  collision_mask = {colliding_with_tiles_only=true, layers=landOnly and {water_tile=true} or {}},
          flags = {"placeable-neutral", "placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable"},
          selectable_in_game = true,
			destructible = false,
          render_layer = "object",
          pictures = pictures,
		  stateless_visualisation_variations = {

		  }
	}
end

---@param lightcolor Color
local function tree_stateless_visualisation(lightcolor)
  -- higher intensity -> overlapping doesn't have much effect
  -- max brightness -> maximum glow intensity
  local max_brightness = 1-- 0.4
  return
  {
    min_count = 1,
    max_count = 2,

    render_layer = "object",
    adjust_animation_speed_by_base_scale = true,
    scale = { 0.2, 0.6 },

    light =
    {
      intensity = 0.4, --0.7,
      size = 32*settings.startup["biolum-plant-glow-radius"].value,
      color = {lightcolor.r * max_brightness, lightcolor.g * max_brightness, lightcolor.b * max_brightness},
      flicker_interval = 90,
      flicker_min_modifier = 0.8,
      flicker_max_modifier = 1.2,
      offset_flicker = true
    },
  }
end

---@param color string
function createGlowingPlants(color)
	fmtlog("Adding glowing plants for color %s", color)
	for i = 1,PLANT_VARIATIONS[color] do
		local ename = "glowing-tree-" .. color .. "-" .. i
		local render = RENDER_COLORS[color]
		local light = convertColor(render, true)

		local vars = data.raw.tree["tree-02"].variations
		local tree = createDerivative(data.raw.tree["tree-02"], {
			name = ename,
			localised_name = {"glowing-plants.glowing-tree", {"glowing-color-name." .. color}},
			subgroup = "glowing-tree",
			colors = generateColorVariations(convertColor(render, false)),
			minable = {
				results = "nil",
			},
			stateless_visualisation_variations = getArrayOfCopies(tree_stateless_visualisation(light), #vars)
		})

		addMineableDropToEntity(tree, {type = "item", name = "glowing-sapling-" .. ename, amount = 1})
		local treeitem = {
			type = "item",
			name = "glowing-sapling-" .. ename,
			icon = tree.icon,
			icon_size = tree.icon_size,
			icon_mipmaps = tree.icon_mipmaps,
			subgroup = tree.subgroup,
			order = "a[" .. ename .. "]",
			place_result = ename,
			stack_size = 50
		}
		
		local bush = createBasicPlantPrototype("bush", color, i, 0.7, true, {
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
		)

		local lily = createBasicPlantPrototype("lily", color, i, 0.7, false, {
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
		)

		local reed = createBasicPlantPrototype("reed", color, i, 0.7, false, {
            {
              filename = "__Bioluminescence__/graphics/entity/reeds/v1/" .. color .. ".png",
              width = 128,
              height = 96,
			  scale = 1,
			  shift = {0.35, -0.1}
            }
          }
		)
		
		data:extend({
			tree,
			treeitem,
			bush,
			lily,
			reed
		})
	end
end

if settings.startup["glow-plants"].value then
	data:extend({
	  {
		type = "item-group",
		name = "glowing-plants",
		order = "g",
		icon = "__Bioluminescence__/graphics/item-group.png",
		icon_size = 64,
	  },
	  {
		type = "item-subgroup",
		name = "glowing-tree",
		group = "glowing-plants",
		order = "g"
	  },
	  {
		type = "item-subgroup",
		name = "glowing-bush",
		group = "glowing-plants",
		order = "g"
	  },
	  {
		type = "item-subgroup",
		name = "glowing-lily",
		group = "glowing-plants",
		order = "g"
	  },
	  {
		type = "item-subgroup",
		name = "glowing-reed",
		group = "glowing-plants",
		order = "g"
	  },
	})
	for color,render in pairs(RENDER_COLORS) do
		createGlowingPlants(color)
	end
end