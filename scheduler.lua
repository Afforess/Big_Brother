require 'stdlib/event/event'

Scheduler = {}

function Scheduler.add(key, func)
    if not global.scheduled_tasks then
        global.scheduled_tasks = {}
        Scheduler._setup()
    end
    if key then
        for _, task in pairs(global.scheduled_tasks) do
            if task.key == key then
                return false
            end
        end
    end
    table.insert(global.scheduled_tasks, { key = key, func = func })
    return true
end

function Scheduler._tick(event)
    local tasks = global.scheduled_tasks
    if tasks then
        for _, task in pairs(tasks) do
            task.func(event)
        end
        global.scheduled_tasks = nil
        Event.remove(defines.events.on_tick, event._handler)
    end
end

function Scheduler._setup()
    if global.scheduled_tasks then
        Event.register(defines.events.on_tick, Scheduler._tick)
    end
end

Event.register(Event.core_events.load, Scheduler._setup)
