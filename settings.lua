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
            name = "biolum-plant-glow-radius",
            setting_type = "startup",
            default_value = 1,
            minimum_value = 0.1,
            maximum_value = 10,
            order = "r",
        },
})