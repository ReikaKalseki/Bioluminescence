require "prototypes.plants"

--[[
require "__DragonIndustries__.arrays"
require "__DragonIndustries__.tiles"

---@param name string
---@param seed number
---@return data.NamedNoiseExpression
local function createPlantNoise(name, seed)
  return {
    type = "noise-expression",
    name = name,
    expression = "min(0.4, trees_forest_path_cutout_faded,\z
                      min(0,\z
                          asymmetric_ramps{input=temperature, from_bottom=0, from_top=10, to_top=14, to_bottom=15},\z
                          asymmetric_ramps{input=moisture, from_bottom=0.4, from_top=0.5, to_top=0.7, to_bottom=0.8})\z
                      + min(0, distance/20 - 3)\z
                      - 0.5 + 0.2 * control:biolum_gen:size\z
                      + tree_small_noise * 0.1\z
                      + multioctave_noise{x = x,\z
                                          y = y,\z
                                          persistence = 0.65,\z
                                          seed0 = map_seed,\z
                                          seed1 = " .. seed .. ",\z
                                          octaves = 3,\z
                                          input_scale = 4 * control:biolum_gen:frequency,\z
                                          output_scale = 0.75})"
  }
end

if settings.startup["glow-plants"].value then
    data:extend({
        {
           type = "autoplace-control", 
           name = "biolum_gen",
           order = "tree-biolum",
           category = "terrain",
           can_be_disabled = true,
        },
        createPlantNoise("tree"),
        createPlantNoise("bush"),
        createPlantNoise("reed"),
        createPlantNoise("lily"),
    })
    for name,plant in pairs(BIOLUM_PLANTS) do
        plant.entity.autoplace =
        {
            control = "biolum_gen",
            default_enabled = true,
            order = "z",
            placement_density = 1,
            tile_restriction = plant.landOnly and getAllMatching(data.raw.tile, function(tile) return not isWaterTile(tile) end) or nil,
            --[[
            probability_expression = "max(main_probability, invasion_top_probability)",
            local_expressions = {
                main_box = "min(gleba_select(gleba_aux, 0, 0.5, 0.15, -10, 1), gleba_select(gleba_moisture, 0.25, 0.5, 0.01, -10, 1)) - 1",
                main_probability = "min(0.05, 0.1 * (main_box + gleba_plants_noise - 0.25) * control:biolum_gen:size)", -- bigger patches, denser
                invasion_top_box = "min(gleba_select(gleba_aux, 0, 0.5, 0.15, -10, 1), gleba_select(gleba_moisture, 0.1, 0.25, 0.01, -10, 1)) - 1",
                invasion_top_probability = "min(0.05, 0.1 * (invasion_top_box + gleba_plants_noise - 0.55) * control:biolum_gen:size)", -- smaller patches, sparser
            },
            --]]--[[
        }
    end
end--]]