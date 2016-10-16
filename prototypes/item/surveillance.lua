data:extend({
    {
        type = "item",
        name = "big_brother-surveillance-center",
        icon = "__Big_Brother__/graphics/icons/surveillance.png",
        flags = {"goes-to-main-inventory"},
        subgroup = "defensive-structure",
        order = "d[radar]-a[surveillance]",
        place_result = "big_brother-surveillance-center",
        stack_size = 1
    },
    {
        type = "item",
        name = "big_brother-blueprint-radar",
        localised_name = {"item-name.radar"},
        icon = "__base__/graphics/icons/radar.png",
        flags = {"goes-to-main-inventory"},
        subgroup = "defensive-structure",
        order = "d[radar]-a[surveillance]",
        place_result = "big_brother-blueprint-radar",
        stack_size = 1
    }
})
