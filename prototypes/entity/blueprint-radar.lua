
-- dummy item for blueprints
local radar = table.deepcopy(data.raw['radar']['radar'])
radar.name = 'big_brother-blueprint-radar'
radar.max_distance_of_sector_revealed = 0
radar.max_distance_of_nearby_sector_revealed = 0
radar.energy_per_sector = "0kJ"
radar.energy_per_nearby_scan = "0kJ"
radar.energy_usage = "1kW"
radar.order ="d-c"
radar.localised_name = {"entity-name.radar"}
radar.pictures = {
    filename = "__base__/graphics/entity/radar/radar.png",
    priority = "low",
    width = 0,
    height = 0,
    apply_projection = false,
    direction_count = 1,
    line_length = 1,
    shift = {0.0, 0.0}
}
radar.integration_patch = nil
radar.radius_minimap_visualisation_color = nil

data:extend({radar})
