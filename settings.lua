data:extend({
        {
            type = "bool-setting",
            name = "glow-biters",
            setting_type = "startup",
            default_value = true,
            order = "r",
        },
        {
            type = "bool-setting",
            name = "glow-plants",
            setting_type = "startup",
            default_value = true,
            order = "r",
        },
        {
            type = "double-setting",
            name = "plant-density",
            setting_type = "startup",
            default_value = 1,
            order = "r",
        },
        {
            type = "double-setting",
            name = "light-scale",
            setting_type = "startup",
            default_value = 1,
			min_value = 0.85,
			max_value = 20,
            order = "r",
        },
        {
            type = "bool-setting",
            name = "script-lights",
            setting_type = "startup",
            default_value = true,
            order = "r",
        },
})