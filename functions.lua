require "constants"

require "__DragonIndustries__.mathhelper"
require "__DragonIndustries__.items"
require "__DragonIndustries__.world"
require "__DragonIndustries__.strings"
require "__DragonIndustries__.color"

---@param lightcolor Color
---@param intensity number
---@param radiusFactor number
---@param varScale? number
---@param offset? Vector
---@return data.StatelessVisualisation
function createGlowVis(lightcolor, intensity, radiusFactor, varScale, offset)
  -- higher intensity -> overlapping doesn't have much effect
  -- max brightness -> maximum glow intensity
  if not varScale then varScale = 1 end
  local ret = {
	nested_visualisations = {}
  }
  
  for _,params in pairs(LIGHT_LAYERS) do
	table.insert(ret.nested_visualisations, 
	{
		count = 1,
		render_layer = "object",
		--adjust_animation_speed_by_base_scale = true,
		--scale = { 0.2, 0.6 },

		offset_x = offset and offset[1] or nil,
		offset_y = offset and offset[2] or nil,

		light =
		{
			type = "basic",
		intensity = 0.6, --0.7,
		minimum_darkness = 0,
		size = radiusFactor*params.radius*settings.startup["biolum-plant-glow-radius"].value,
		color = {math.min(255, lightcolor.r * params.brightness * intensity), math.min(255, lightcolor.g * params.brightness * intensity), math.min(255, lightcolor.b * params.brightness * intensity)},
		flicker_interval = 255,
		flicker_min_modifier = 1-0.25*varScale,
		flicker_max_modifier = 1+0.25*varScale,
		offset_flicker = true
		},
	})
  end
	return ret
end