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
        radar.energy_per_sector = energy_per_sector .. "KJ"
        radar.energy_usage = (300 + extra_energy_cost) .. "kW"
        radar.order ="d-c"

        local file_names = {}
        for i = 1, 64 do
            table.insert(file_names, "__Big_Brother__/graphics/entity/radar/tile_" .. i .. ".png")
        end
        radar.pictures = {
            apply_projection = false,
            direction_count = #file_names,
            filenames = file_names,
            height = 262,
            line_length = 1,
            lines_per_file = 1,
            priority = "low",
            scale = 0.5,
            shift = {0.875, -0.34375},
            width = 306,
        }
        table.insert(radars, radar)
    end
end

data:extend(radars)
