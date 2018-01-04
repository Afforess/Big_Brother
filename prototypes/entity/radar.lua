require('stdlib/utils/string')
local radars = {}

-- update all radar prototypes (e.g radar-2 and radar-3 in bob's warfare, or any other radars)
for _, radar_prototype in pairs(data.raw['radar']) do
    -- ignore big brother blueprint radar
    if not radar_prototype.name:starts_with("big_brother") then
        for radar_amplification_type = 0, 9 do
            for radar_efficiency_type = 0, 9 do
                local max_distance_of_sector_revealed = radar_prototype.max_distance_of_sector_revealed + radar_amplification_type * 3
                local max_distance_of_nearby_sector_revealed = radar_prototype.max_distance_of_nearby_sector_revealed + radar_amplification_type * 2
                local extra_energy_cost = 75 * radar_amplification_type

                -- base time to scan is ~40s
                local energy_per_sector = (10000 + extra_energy_cost * 40) / (1 + math.pow(radar_efficiency_type, 1.5))

                local radar = table.deepcopy(radar_prototype)
                radar.name = 'big_brother-' .. radar_prototype.name .. '_ra-' .. radar_amplification_type .. '_re-' .. radar_efficiency_type
                radar.max_distance_of_sector_revealed = max_distance_of_sector_revealed
                radar.max_distance_of_nearby_sector_revealed = max_distance_of_nearby_sector_revealed
                radar.energy_per_sector = energy_per_sector .. "kJ"
                radar.energy_usage = (300 + extra_energy_cost) .. "kW"
                radar.order ="upgradable" -- HACK: I'm abusing this field to make control.lua code simpler
                radar.localised_name = {"entity-name." .. radar_prototype.name}

                table.insert(radars, radar)
            end
        end
    end
end

data:extend(radars)
