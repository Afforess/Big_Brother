require 'stdlib/game'
require 'stdlib/area/area'
require 'stdlib/area/position'
require 'stdlib/area/surface'
require 'stdlib/entity/entity'
require 'stdlib/event/event'
require 'stdlib/utils/string'
require 'stdlib/utils/table'
require 'scheduler'

Event.register({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
    local entity = event.created_entity
    local type = entity.type
    local name = entity.name
    if name == 'radar' then
        track_entity('radars', upgrade_radar_entity(entity))
    elseif name == 'big-electric-pole' then
        track_entity('power_poles', entity)
        if entity.force.technologies['surveillance-2'].researched then
            update_surveillance(entity, false)
        end
    elseif type == 'car' then
        track_entity('vehicles', entity)
        update_surveillance(entity, true)
    elseif type == 'locomotive' then
        track_entity('trains', entity)
        update_surveillance(entity, true)
    elseif name == 'big_brother-surveillance-center' then
        entity.backer_name = ''
        track_entity('surveillance_centers', entity)
        update_all_surveillance(entity.force)
    elseif type == 'entity-ghost' then
        if entity.ghost_name == 'big_brother-blueprint-radar' then
            entity.surface.create_entity({name = name, position = entity.position, force = entity.force, inner_name = 'radar'})
            entity.destroy()
        end
    end
end)

Event.register({defines.events.on_entity_died, defines.events.on_robot_pre_mined, defines.events.on_player_mined_entity}, function(event)
    local entity = event.entity
    local type = entity.type
    local name = entity.name
    if name == 'big-electric-pole' then
        if entity.force.technologies['surveillance-2'].researched then
            remove_surveillance(entity, false)
        end
    elseif type == 'car' then
        remove_surveillance(entity, true)
    elseif type == 'locomotive' then
        remove_surveillance(entity, true)
    elseif name == 'big_brother-surveillance-center' then
        local force = entity.force
        Scheduler.add(nil, function(event)
            update_all_surveillance(force)
        end)
    elseif type == 'radar' then
        local radar_data = Entity.set_data(entity, nil)
        if radar_data and radar_data.blueprint_radar and radar_data.blueprint_radar.valid then
            radar_data.blueprint_radar.destroy()
        end
    end
end)

Event.register({defines.events.on_player_setup_blueprint, defines.events.on_player_configured_blueprint}, function(event)
    local player = game.players[event.player_index]
    if not player.valid then return end

    local stack = player.blueprint_to_setup
    if not stack.valid or not stack.valid_for_read then
        stack = player.cursor_stack
        if not stack.valid or not stack.valid_for_read then
            return
        end
    end

    if stack.name ~= "blueprint" then return end

    local entities = stack.get_blueprint_entities()
    if not entities then return end

    local modified = false
    for _, entity in pairs (entities) do
        if entity.name == 'big_brother-blueprint-radar' then
            entity.name = 'radar'
            modified = true
        end
    end

    if modified then
        stack.set_blueprint_entities(entities)
    end
end)

-- Scan the map once if the mod is updated
Event.register({Event.core_events.init, Event.core_events.configuration_changed}, function(event)
    -- start tracking all important entities
    table.each(game.surfaces, function(surface)
        -- track all radars
        local radars = surface.find_entities_filtered({name = 'radar'})
        table.each(radars, function(entity) track_entity('radars', entity) end)

        -- track all vehicles
        local vehicles = surface.find_entities_filtered({type = 'car'})
        table.each(vehicles, function(entity) track_entity('vehicles', entity) end)

        -- track all trains
        local trains = surface.find_entities_filtered({type = 'locomotive'})
        table.each(trains, function(entity) track_entity('trains', entity) end)

        -- track all big-electric-poles
        local power_poles = surface.find_entities_filtered({name = 'big-electric-pole'})
        table.each(power_poles, function(entity) track_entity('power_poles', entity) end)
    end)

    -- upgrade radars
    table.each(game.forces, upgrade_radars)
end)

Event.register(defines.events.on_research_finished, function(event)
    local tech_name = event.research.name
    local force = event.research.force
    if tech_name:starts_with('radar-amplifier') or tech_name:starts_with('radar-efficiency') then
        Scheduler.add(force.name, function(event)
            upgrade_radars(force)
        end)
    elseif tech_name == 'surveillance-2' then
        if global.power_poles and global.surveillance_centers then
            update_all_surveillance(force)
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
        chart_locomotive(entity)
    else
        local surface = entity.surface
        table.each(train.cargo_wagons, function(wagon)
            entity.force.chart(surface, Position.expand_to_area(wagon.position, 1))
        end)
    end
end

function chart_locomotive(entity)
    local pos = entity.position

    local x = pos.x + 16 * math.sin(2 * math.pi * entity.orientation)
    local y = pos.y - 16 * math.cos(2 * math.pi * entity.orientation)
    entity.force.chart(entity.surface, Area.normalize({Position.construct(x, y), pos}))
end

function upgrade_radar_entity(radar, radar_efficiency_level, radar_amplifier_level)
    if not radar.valid then return nil end

    local force = radar.force
    local radar_efficiency_level = radar_efficiency_level or calculate_tech_level(force, 'radar-efficiency', 9)
    local radar_amplifier_level = radar_amplifier_level or calculate_tech_level(force, 'radar-amplifier', 9)
    local radar_name = 'big_brother-radar_ra-' .. radar_amplifier_level .. '_re-' .. radar_efficiency_level
    local pos = radar.position
    local direction = radar.direction
    local health = radar.health
    local surface = radar.surface
    local radar_data = Entity.set_data(radar, nil)
    radar.destroy()

    if not radar_data then
        local blueprint_radar = surface.create_entity({ name = 'big_brother-blueprint-radar', position = pos, direction = direction, force = force})
        Entity.set_frozen(blueprint_radar)
        Entity.set_indestructible(blueprint_radar)
        radar_data = { blueprint_radar = blueprint_radar }
    end
    local new_radar = surface.create_entity({ name = radar_name, position = pos, direction = direction, force = force})
    new_radar.health = health
    Entity.set_data(new_radar, radar_data)

    return new_radar
end

function upgrade_radars(force)
    if not global.radars then return end

    local radar_efficiency_level = calculate_tech_level(force, 'radar-efficiency', 9)
    local radar_amplifier_level = calculate_tech_level(force, 'radar-amplifier', 9)
    local radar_name = 'big_brother-radar_ra-' .. radar_amplifier_level .. '_re-' .. radar_efficiency_level
    for i = #global.radars, 1, -1 do
        local radar = global.radars[i]
        if not radar.valid then
            table.remove(global.radars, i)
        elseif radar.force == force then
            global.radars[i] = upgrade_radar_entity(radar, radar_efficiency_level, radar_amplifier_level)
        end
    end
end

function calculate_tech_level(force, tech_name, max_levels)
    local techs = force.technologies
    for i = max_levels, 1, -1 do
        local full_tech_name = tech_name
        if i > 1 then
            full_tech_name = tech_name .. '-' .. i
        end

        if techs[full_tech_name].researched then
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
                Entity.set_indestructible(surveillance)
                Entity.set_data(entity, { surveillance = surveillance })
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
    return nil
end

function track_entity(category, entity)
    if not entity then return end

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
