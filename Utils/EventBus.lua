local CraftScan = select(2, ...)

-- The Registry: ["EVENT_NAME"] = { func1, func2, ... }
local registry = {}

local Events = {}

--- Registers a function to be called when a specific event is emitted.
-- @param eventName string The unique tag for the event.
-- @param func function The callback function.
function Events:Register(eventName, func)
    if type(eventName) == 'table' then
        for _, event in ipairs(eventName) do
            Events:Register(event, func)
        end
        return
    end
    assert(type(func) == "function")
    
    if not registry[eventName] then
        registry[eventName] = {}
    end
    
    table.insert(registry[eventName], func)
end

--- Unregisters a specific function from an event.
-- @param eventName string
-- @param func function
function Events:Unregister(eventName, func)
    if not registry[eventName] then return end
    
    for i, registeredFunc in ipairs(registry[eventName]) do
        if registeredFunc == func then
            table.remove(registry[eventName], i)
            break
        end
    end
end

--- Emits an event, passing all additional arguments to the registered functions.
-- @param eventName string
-- @param ... any Arguments passed to the callbacks.
function Events:Emit(eventName, ...)
    local callbacks = registry[eventName]
    if not callbacks then return end
    
    for _, func in ipairs(callbacks) do
        func(...)
    end
end

-- Attach to the addon namespace
CraftScan.Events = Events