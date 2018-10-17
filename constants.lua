require "config"

CHUNK_SIZE = 32

PLANT_SPAWN_RATE = 5

RENDER_COLORS = {}

local ALL_COLORS = {}

PLANT_VARIATIONS = {}

local COLORS_LOOKUP = {}

local COLORS_PRIMARY = {}

local COLORS_SECONDARY = {}

PLANT_CHOICE_CHANCES = {
	["bush"] = 60,
	["tree"] = 85,
	["reed"] = 94,
	["lily"] = 100,
}

local function calculateColor(tile)
	local colors = {}
	for part in string.gmatch(tile.name, "[^%-]+") do		
		local li = COLORS_PRIMARY[part]
		if li and #li > 0 then
			for _,color in pairs(li) do
				table.insert(colors, color)
			end
		end
		
		if #colors == 0 then --only go to secondary if there are no primaries
			li = COLORS_SECONDARY[part]
			if li and #li > 0 then
				for _,color in pairs(li) do
					table.insert(colors, color)
				end
			end	
		end
	end
	COLORS_LOOKUP[tile.name] = colors
end

function getColorsForTile(tile)
	if string.find(tile.name, "water") then
		return ALL_COLORS,true
	end
	
	if not COLORS_LOOKUP[tile.name] then
		calculateColor(tile)
	end
	return COLORS_LOOKUP[tile.name]
end

local function addColor(color, render, plantCount, tiles1, tiles2)
	for _,tile in pairs(tiles1) do
		if COLORS_PRIMARY[tile] == nil then COLORS_PRIMARY[tile] = {} end
		table.insert(COLORS_PRIMARY[tile], color)
	end
	
	if tiles2 then
		for _,tile in pairs(tiles2) do
			if COLORS_SECONDARY[tile] == nil then COLORS_SECONDARY[tile] = {} end
			table.insert(COLORS_SECONDARY[tile], color)
		end
	end
	
	PLANT_VARIATIONS[color] = plantCount
	table.insert(ALL_COLORS, color)
	RENDER_COLORS[color] = render
end

addColor("red", 0xff0000, 1, {"red", "dustyrose"})
addColor("orange", 0xFF7F00, 1, {"orange", "brown"}, {"desert", "dirt"})
addColor("yellow", 0xffD800, 1, {"yellow", "tan", "beige", "cream", "olive"}, {"desert", "sand"})
addColor("green", 0x00ff00, 1, {"green"}, {"grass"})
addColor("cyan", 0x00ffff, 1, {"ice", "frozen", "turqoise"})
addColor("argon", 0x4CCCFF, 1, {"blue", "turqoise"})
addColor("blue", 0x0045ff, 1, {"blue"})
addColor("purple", 0xA426FF, 1, {"purple", "mauve", "aubergine"})
addColor("magenta", 0xFF00FF, 1, {"purple", "violet"})
addColor("white", 0xffffff, 1, {"snow", "white", "black", "beige", "grey", "gray"})

function initModifiers(isInit)

end