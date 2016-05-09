data:extend(
{
    {
        type = "technology",
        name = "radar-amplifier",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"military", "optics"},
        unit = {
            count = 25,
            ingredients = {
                {"science-pack-1", 1},
            },
            time = 15
        },
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-2",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-amplifier"},
        unit = {
            count = 25,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
            },
            time = 20
        },
        upgrade = true,
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-3",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-amplifier-2", "circuit-network"},
        unit = {
            count = 50,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
            },
            time = 25
        },
        upgrade = true,
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-4",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-amplifier-3", "modules"},
        unit = {
            count = 80,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
            },
            time = 30
        },
        upgrade = true,
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-5",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"effect-transmission", "radar-amplifier-4"},
        unit = {
            count = 125,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
            },
            time = 35
        },
        upgrade = true,
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-6",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"productivity-module-2", "radar-amplifier-5"},
        unit = {
            count = 75,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 2},
            },
            time = 40
        },
        upgrade = true,
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-7",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"productivity-module-3", "radar-amplifier-6"},
        unit = {
            count = 100,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 1},
                {"alien-science-pack", 2},
            },
            time = 45
        },
        upgrade = true,
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-8",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-amplifier-7"},
        unit = {
            count = 130,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 1},
                {"alien-science-pack", 2},
            },
            time = 50
        },
        upgrade = true,
        order = "e-a-a"
    },
    {
        type = "technology",
        name = "radar-amplifier-9",
        icon = "__Big_Brother__/graphics/icons/radar-amplifier.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-amplifier-8"},
        unit = {
            count = 150,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 1},
                {"alien-science-pack", 2},
            },
            time = 60
        },
        upgrade = true,
        order = "e-a-a"
    },

    {
        type = "technology",
        name = "radar-efficiency",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"military", "optics"},
        unit = {
            count = 25,
            ingredients = {
                {"science-pack-1", 1},
            },
            time = 20
        },
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-2",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency"},
        unit = {
            count = 30,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
            },
            time = 25
        },
        upgrade = true,
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-3",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency-2", "advanced-electronics"},
        unit = {
            count = 100,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
            },
            time = 30
        },
        upgrade = true,
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-4",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency-3", "laser"},
        unit = {
            count = 75,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 2},
            },
            time = 35
        },
        upgrade = true,
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-5",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency-4", "advanced-electronics-2"},
        unit = {
            count = 100,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
            },
            time = 40
        },
        upgrade = true,
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-6",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency-5", "effectivity-module-2"},
        unit = {
            count = 75,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 2},
            },
            time = 45
        },
        upgrade = true,
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-7",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency-6", "effectivity-module-3"},
        unit = {
            count = 100,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 1},
                {"alien-science-pack", 2},
            },
            time = 50
        },
        upgrade = true,
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-8",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency-7"},
        unit = {
            count = 150,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 1},
                {"alien-science-pack", 2},
            },
            time = 60
        },
        upgrade = true,
        order = "e-a-b"
    },
    {
        type = "technology",
        name = "radar-efficiency-9",
        icon = "__Big_Brother__/graphics/icons/radar-efficiency.png",
        icon_size = 128,
        effects = { },
        prerequisites = {"radar-efficiency-8"},
        unit = {
            count = 200,
            ingredients = {
                {"science-pack-1", 4},
                {"science-pack-2", 3},
                {"science-pack-3", 1},
                {"alien-science-pack", 2},
            },
            time = 70
        },
        upgrade = true,
        order = "e-a-b"
    },

    {
        type = "technology",
        name = "surveillance",
        icon = "__Big_Brother__/graphics/icons/tech_surveillance.png",
        icon_size = 128,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "big_brother-surveillance-center"
             }
        },
        prerequisites = {"radar-amplifier-4", "electric-energy-distribution-1"},
        unit = {
            count = 80,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
            },
            time = 60
        },
        order = "e-a-d"
    },
    {
        type = "technology",
        name = "surveillance-2",
        icon = "__Big_Brother__/graphics/icons/tech_surveillance.png",
        icon_size = 128,
        upgrade = true,
        effects = { },
        prerequisites = {"radar-amplifier-5", "surveillance"},
        unit = {
            count = 110,
            ingredients = {
                {"science-pack-1", 2},
                {"science-pack-2", 1},
                {"science-pack-3", 1},
            },
            time = 75
        },
        order = "e-a-e"
    }
}
)
