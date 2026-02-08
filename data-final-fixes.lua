require "functions"
require "constants"

---@param biter data.UnitPrototype
---@return Color
local function getBiterColor(biter)
	return biter.run_animation.layers[3].tint
end

---@param biter data.UnitPrototype
---@return number
local function getBiterGlowSize(biter)
	return 1.75+biter.run_animation.layers[3].scale*12 --was 1.25 and 7.5
end

if settings.startup["glow-biters"].value then
	for name,biter in pairs(data.raw.unit) do
		if string.find(name, "biter") or string.find(name, "spitter") then
			--[[
			if biter.stateless_visualisation == nil then
				biter.stateless_visualisation = {}
			end
			if biter.stateless_visualisation.light or biter.stateless_visualisation.nested_visualisations or biter.stateless_visualisation.animation then --single vis
				biter.stateless_visualisation = {biter.stateless_visualisation}
			end
			--]]
			local r = getBiterGlowSize(biter)
			local clr = getBiterColor(biter)
			fmtlog("Identified biter type '%s' to be given light: %s x %s", name, r, clr)
			biter.light = {
                type = "basic",
                intensity = 1.25,
                size = r,
                color=clr,
                --flicker_interval = 64,
                --flicker_min_modifier = 0.75,
                --flicker_max_modifier = 1.25,
                --offset_flicker = false,
            }
			--[[
			table.insert(biter.stateless_visualisation, createDerivative(createGlowVis(clr, 1, r), {
				render_layer = "higher-object-above",
				light = {
					flicker_interval = "nil",
					flicker_min_modifier = "nil",
					flicker_max_modifier = "nil",
				}
			}))
			--]]
		end
	end
end
