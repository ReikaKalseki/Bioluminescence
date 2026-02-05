require "prototypes.plants"

if settings.startup["glow-plants"].value and settings.startup["plant-density"].value > 0 then
    for type,plant in pairs(BIOLUM_PLANTS) do
        plant.entity.autoplace = ?
    end
end