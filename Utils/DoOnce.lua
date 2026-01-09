local CraftScan = select(2, ...)

-- Internal registries
local runHistory = setmetatable({}, { __mode = "k" })
local taggedHistory = {} -- Format: [tag] = { [func] = true }

--- Runs a function exactly once per session.
local function DoOnce(func, ...)
    if runHistory[func] then return end
    runHistory[func] = true
    return func(...)
end

--- Runs a function exactly once per specific tag (e.g. PlayerName or ProfID).
local function DoOnceForTag(tag, func, ...)
    if not tag then return DoOnce(func, ...) end -- Fallback if tag is missing
    
    if not taggedHistory[tag] then
        -- We make the inner table weak so we don't hold onto functions forever
        taggedHistory[tag] = setmetatable({}, { __mode = "k" })
    end

    if taggedHistory[tag][func] then return end
    
    taggedHistory[tag][func] = true
    return func(...)
end

-- Export to addon namespace
CraftScan.DoOnce = DoOnce
CraftScan.DoOnceForTag = DoOnceForTag