require 'defines'
require 'stdlib/string'
require 'stdlib/surface'
require 'stdlib/table'
require 'stdlib/event/event'
require 'stdlib/log/logger'
require 'stdlib/area/position'
require 'stdlib/entity/entity'

LOGGER = Logger.new('Big_Brother', 'main', true)
MAX_SURVEILLANCE_DISTANCE = 25000
MAX_SURVEILLANCE_DISTANCE_SQUARED = MAX_SURVEILLANCE_DISTANCE * MAX_SURVEILLANCE_DISTANCE

Event.register({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity
    local name = entity.name
    if name == 'radar' then
        track_entity('radars', entity)
        upgrade_radars(entity.force)
    elseif name == 'big-electric-pole' then
        track_entity('power_poles', entity)
        if entity.force.technologies['surveillance-2'].researched then
            update_surveillance(entity, false)
        end
    elseif entity.type == 'car' then
        track_entity('vehicles', entity)
        update_surveillance(entity, true)
    elseif entity.type == 'locomotive' then
        track_entity('trains', entity)
        update_surveillance(entity, true)
    elseif entity.name == 'big_brother-surveillance-center' then
        entity.backer_name = ''
        track_entity('surveillance_centers', entity)
        if global.vehicles then
            for _, vehicle in pairs(global.vehicles) do
                update_surveillance(vehicle, true)
            end
        end
        if global.trains then
            for _, train in pairs(global.trains) do
                update_surveillance(train, true)
            end
        end
    end
end)

-- Scan the map once if the mod has never been loaded (then deregister on_tick)
Event.register(defines.events.on_tick, function(event)
    if not global.scanned_map then
        if not global.map_scan_countdown then global.map_scan_countdown = 120 end
        global.map_scan_countdown = global.map_scan_countdown - 1
        if global.map_scan_countdown <= 0 then
            Event.remove(defines.events.on_tick, event._handler)
            -- track all radars
            local radars = Surface.find_all_entities({name = 'radar'})
            for i = 1, #radars do
                track_entity('radars', radars[i])
            end
            for _, force in pairs(game.forces) do
                upgrade_radars(force)
            end

            -- track all vehicles
            local vehicles = Surface.find_all_entities({type = 'car'})
            for i = 1, #vehicles do
                track_entity('vehicles', vehicles[i])
            end

            -- track all trains
            local trains = Surface.find_all_entities({type = 'locomotive'})
            LOGGER.log("Locomotives found: " .. #trains)
            for i = 1, #trains do
                track_entity('trains', trains[i])
            end

            -- track all big-electric-poles
            local power_poles = Surface.find_all_entities({name = 'big-electric-pole'})
            for i = 1, #power_poles do
                track_entity('power_poles', power_poles[i])
            end

            global.map_scan_countdown = nil
            global.scanned_map = true
        end
    end
end)

Event.register(defines.events.on_research_finished, function(event)
    local tech_name = event.research.name
    if tech_name:starts_with('radar-amplifier') or tech_name:starts_with('radar-efficiency') then
        -- update radars in 1 tick
        local force = event.research.force
        Event.register(defines.events.on_tick, function(event)
            upgrade_radars(force)

            Event.remove(defines.events.on_tick, event._handler)
        end)
    elseif tech_name == 'surveillance-2' then
        if global.power_poles and global.surveillance_centers then
            local power_poles = global.power_poles
            for i = #power_poles, 1, -1 do
                local entity = power_poles[i]
                if entity.valid then
                    update_surveillance(entity, false)
                else
                    table.remove(power_poles, i)
                end
            end
        end
    end
end)

Event.register(defines.events.on_sector_scanned, function(event)
    if not global.following then return end
    if event.radar.name == 'big_brother-surveillance-center' then
        for i = #global.following, 1, -1 do
            local entity = global.following[i]
            if not entity.valid then
                table.remove(global.following, i)
            else
                if entity.type == 'locomotive' then
                    local train = entity.train
                    local speed = train.speed
                    if math.abs(speed) > 0.05 then
                        chart_locomotive(entity, speed)
                    else
                        for _, wagon in pairs(train.cargo_wagons) do
                            entity.force.chart(entity.surface, Position.expand_to_area(wagon.position, 1))
                        end
                    end
                else
                    entity.force.chart(entity.surface, Position.expand_to_area(pos, 1))
                end
            end
        end
    end
end)

function chart_locomotive(entity, speed)
    local pos = entity.position

    local x = pos.x + 16 * math.sin(2 * math.pi * entity.orientation)
    local y = pos.y - 16 * math.cos(2 * math.pi * entity.orientation)
    local area = {{x = x, y = y}, pos}
    if pos.x < x then
        area[1].x = pos.x
        area[2].x = x
    end
    if pos.y < y then
        area[1].y = pos.y
        area[2].y = y
    end
    entity.force.chart(entity.surface, area)
end

function upgrade_radars(force)
    if not global.radars then return end

    local radar_efficiency_level = calculate_tech_level(force, 'radar-efficiency', 9)
    local radar_amplifier_level = calculate_tech_level(force, 'radar-amplifier', 9)
    local radar_name = 'big_brother-radar_ra-' .. radar_amplifier_level .. '_re-' .. radar_efficiency_level
    LOGGER.log("Upgrading " .. force.name .. "'s radars to " .. radar_name)
    for i = #global.radars, 1, -1 do
        local radar = global.radars[i]
        if not radar.valid then
            table.remove(global.radars, i)
        elseif radar.force == force then
            local pos = radar.position
            local direction = radar.direction
            local health = radar.health
            local surface = radar.surface

            LOGGER.log("Upgrading radar {" .. radar.name .. "} at " .. serpent.line(pos, {comment=false}))

            radar.destroy()
            local new_radar = surface.create_entity({ name = radar_name, position = pos, direction = direction, force = force})
            new_radar.health = health

            global.radars[i] = new_radar
        end
    end
end

function calculate_tech_level(force, tech_name, max_levels)
    for i = max_levels, 1, -1 do
        local full_tech_name = tech_name
        if i > 1 then
            full_tech_name = tech_name .. '-' .. i
        end

        if force.technologies[full_tech_name].researched then
            return i
        end
    end
    return 0
end

function update_surveillance(entity, follow)
    local surv_center = get_nearest_surveillance_center(entity.position, entity.surface, entity.force)
    if surv_center then
        local data = Entity.get_data(entity)
        if not data then
            if not follow then
                local surveillance = entity.surface.create_entity({name = 'big_brother-surveillance-small', position = entity.position, force = entity.force})
                surveillance.destructible = false
                surveillance.operable = false
                surveillance.minable = false
                data = { surveillance = surveillance }
                Entity.set_data(entity, data)
            else
                track_entity('following', entity)
            end
        end
    else
        if follow then
            if not global.following then return end
            for i = #global.following, 1, -1 do
                local data = global.following[i]
                if data.entity == entity then
                    table.remove(global.following, i)
                end
            end
        else
            local data = Entity.get_data(entity)
            if data and data.surveillance and data.surveillance.valid then
                data.surveillance.destroy()
                Entity.set_data(entity, nil)
            end
        end
    end
end

function get_nearest_surveillance_center(position, surface, force)
    if global.surveillance_centers then
        global.surveillance_centers = table.filter(global.surveillance_centers, Game.VALID_FILTER)
        local list = table.filter(global.surveillance_centers, function(entity)
            return entity.surface == surface and entity.force == force
        end)
        table.sort(list, function(a, b)
            return Position.distance_squared(a.position, position) < Position.distance_squared(b.position, position)
        end)
        local nearest = table.first(list)
        if nearest and Position.distance_squared(nearest.position, position) < MAX_SURVEILLANCE_DISTANCE_SQUARED then
            return nearest
        end
    end
end

function track_entity(category, entity)
    if not global[category] then global[category] = {} end
    local entity_list = global[category]
    for i = #entity_list, 1, -1 do
        local e = entity_list[i]
        if not e.valid then
            table.remove(entity_list, i)
        elseif e == entity then
            return false
        end
    end

    table.insert(entity_list, entity)
    return true
end
