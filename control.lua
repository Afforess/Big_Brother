require 'stdlib/string'
require 'stdlib/surface'
require 'stdlib/table'
require 'stdlib/event/event'
require 'stdlib/log/logger'
require 'stdlib/area/position'
require 'stdlib/entity/entity'

LOGGER = Logger.new('Big_Brother', 'main', false)

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
        update_all_surveillance(entity.force)
    end
end)

Event.register({defines.events.on_entity_died, defines.events.on_robot_pre_mined, defines.events.on_preplayer_mined_item}, function(event)
    local entity = event.entity
    local name = entity.name
    if name == 'big-electric-pole' then
        if entity.force.technologies['surveillance-2'].researched then
            remove_surveillance(entity, false)
        end
    elseif entity.type == 'car' then
        remove_surveillance(entity, true)
    elseif entity.type == 'locomotive' then
        remove_surveillance(entity, true)
    elseif entity.name == 'big_brother-surveillance-center' then
        local force = entity.force
        Event.register(defines.events.on_tick, function(event)
            update_all_surveillance(force)

            Event.remove(defines.events.on_tick, event._handler)
        end)
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
            table.each(radars, function(entity) track_entity('radars', entity) end)

            -- upgrade radars
            table.each(game.forces, upgrade_radars)

            -- track all vehicles
            local vehicles = Surface.find_all_entities({type = 'car'})
            table.each(vehicles, function(entity) track_entity('vehicles', entity) end)

            -- track all trains
            local trains = Surface.find_all_entities({type = 'locomotive'})
            table.each(trains, function(entity) track_entity('trains', entity) end)

            -- track all big-electric-poles
            local power_poles = Surface.find_all_entities({name = 'big-electric-pole'})
            table.each(power_poles, function(entity) track_entity('power_poles', entity) end)

            global.map_scan_countdown = nil
            global.scanned_map = true
        end
    end
end)

Event.register(defines.events.on_research_finished, function(event)
    local tech_name = event.research.name
    local force = event.research.force
    if tech_name:starts_with('radar-amplifier') or tech_name:starts_with('radar-efficiency') then
        -- update radars in 1 tick
        Event.register(defines.events.on_tick, function(event)
            upgrade_radars(force)
            Event.remove(defines.events.on_tick, event._handler)
        end)
    elseif tech_name == 'surveillance-2' then
        if global.power_poles and global.surveillance_centers then
            Event.register(defines.events.on_tick, function(event)
                update_all_surveillance(force)
                Event.remove(defines.events.on_tick, event._handler)
            end)
        end
    end
end)

Event.register(defines.events.on_sector_scanned, function(event)
    if not global.following then return end
    if event.radar.name == 'big_brother-surveillance-center' then
        global.following = table.each(table.filter(global.following, Game.VALID_FILTER), function(entity)
            if entity.type == 'locomotive' then
                chart_train(entity)
            else
                entity.force.chart(entity.surface, Position.expand_to_area(entity.position, 1))
            end
        end)
    end
end)

function update_all_surveillance(force)
    table.each(table.filter(global.vehicles or {}, Game.VALID_FILTER), function(vehicle) update_surveillance(vehicle, true) end)
    table.each(table.filter(global.trains or {}, Game.VALID_FILTER), function(train) update_surveillance(train, true) end)

    if global.power_poles and force.technologies['surveillance-2'].researched then
        global.power_poles = table.each(table.filter(global.power_poles, Game.VALID_FILTER), function(entity)
            update_surveillance(entity, false)
        end)
    end
end

function chart_train(entity)
    local train = entity.train
    local speed = train.speed
    if math.abs(speed) > 0.05 then
        chart_locomotive(entity, speed)
    else
        table.each(train.cargo_wagons, function(wagon)
            entity.force.chart(entity.surface, Position.expand_to_area(wagon.position, 1))
        end)
    end
end

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
        remove_surveillance(entity, follow)
    end
end

function remove_surveillance(entity, follow)
    if follow then
        global.following = table.filter(global.following or {}, function(followed) return followed ~= entity end)
    else
        local data = Entity.get_data(entity)
        if data and data.surveillance and data.surveillance.valid then
            data.surveillance.destroy()
            Entity.set_data(entity, nil)
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
        return table.first(list)
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
