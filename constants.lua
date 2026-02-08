require "__DragonIndustries__.biomecolor"

CHUNK_SIZE = 32

---@class (exact) PlantSpawnRules
---@field chunkChance number
---@field perChunk int
---@field clusterChance number
---@field clusterSize data.RangedValue
---@field clusterRadius data.RangedValue

---@type {string: PlantSpawnRules}
PLANT_SPAWN_RATE = {
	["bush"] = {chunkChance = 0.2, perChunk = 1, clusterChance = 0.2, clusterSize = {4, 9}, clusterRadius = {3, 6}},
	["tree"] = {chunkChance = 0.75, perChunk = 2, clusterChance = 0.3, clusterSize = {3, 6}, clusterRadius = {5, 10}},
	["reed"] = {chunkChance = 0.15, perChunk = 1, clusterChance = 0.15, clusterSize = {2, 4}, clusterRadius = {2, 4}},
	["lily"] = {chunkChance = 0.08, perChunk = 1, clusterChance = 0.1, clusterSize = {2, 2}, clusterRadius = {2, 2}},
}

LIGHT_LAYERS = {
	{radius=4, brightness=1.33},
	{radius=20, brightness=0.67},
	{radius=36, brightness=0.12},
}

---@deprecated
BITER_GLOW_PARAMS = {
	["small"] = {color = {r=0.9 , g=0.7, b=0.3, a=1}, size = 0.4},
	["medium"] = {color = {r=0.93, g=0.4, b=0.4, a=1}, size = 0.7},
	["big"] = {color = {r=0.3, g=0.62, b=0.75, a=1}, size = 1},
	["behemoth"] = {color = {r = 0.4, g = 0.95, b = 0.2, a = 1.000}, size = 1.6}
}

---@type {string: int}
PLANT_VARIATIONS = {

}

for _,color in pairs(ALL_COLORS) do
	PLANT_VARIATIONS[color] = 1
end