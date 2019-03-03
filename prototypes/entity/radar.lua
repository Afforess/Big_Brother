local radars = {}

for radar_amplification_type = 0, 9 do
    for radar_efficiency_type = 0, 9 do
        local max_distance_of_sector_revealed = data.raw['radar']['radar'].max_distance_of_sector_revealed + radar_amplification_type * 3
        local max_distance_of_nearby_sector_revealed = data.raw['radar']['radar'].max_distance_of_nearby_sector_revealed + radar_amplification_type * 2
        local extra_energy_cost = 75 * radar_amplification_type

        -- base time to scan is ~40s
        local energy_per_sector = (10000 + extra_energy_cost * 40) / (1 + math.pow(radar_efficiency_type, 1.5))

        local radar = table.deepcopy(data.raw['radar']['radar'])
        radar.name = 'big_brother-radar_ra-' .. radar_amplification_type .. '_re-' .. radar_efficiency_type
        radar.max_distance_of_sector_revealed = max_distance_of_sector_revealed
        radar.max_distance_of_nearby_sector_revealed = max_distance_of_nearby_sector_revealed
        radar.energy_per_sector = energy_per_sector .. "kJ"
        radar.energy_usage = (300 + extra_energy_cost) .. "kW"
        radar.order ="d-c"
        radar.localised_name = {"entity-name.radar"}

        table.insert(radars, radar)
    end
end

data:extend(radars)

-- dummy item for blueprints
local radar = table.deepcopy(data.raw['radar']['radar'])
radar.name = 'big_brother-blueprint-radar'
radar.max_distance_of_sector_revealed = 0
radar.max_distance_of_nearby_sector_revealed = 0
radar.energy_per_sector = "1kJ"
radar.energy_per_nearby_scan = "0kJ"
radar.energy_usage = "1kW"
radar.order ="d-c"
radar.localised_name = {"entity-name.radar"}
radar.pictures = {
    filename = "__base__/graphics/entity/radar/radar.png",
    priority = "low",
    width = 1,
    height = 1,
    apply_projection = false,
    direction_count = 1,
    line_length = 1,
    shift = {0.0, 0.0}
}
radar.integration_patch = nil
radar.radius_minimap_visualisation_color = nil

data:extend({radar})
