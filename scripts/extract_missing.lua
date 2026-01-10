local json = require("dkjson")

-- 1. Create the Addon Object (The namespace)
local CraftScan = {} 

-- 2. Execute Consts.lua
-- We pass the table as the second arg to satisfy: local CraftScan = select(2, ...)
local consts_chunk = assert(loadfile("Consts.lua"))
consts_chunk("CraftScan", CraftScan)

-- 3. Function to load Locale and "sniff" for the L table
local function get_locale_table(path)
    local f = loadfile(path)
    if not f then return nil end

    -- Run the locale file with the same CraftScan environment
    f("CraftScan", CraftScan)

    -- The file does: CraftScan.LOCAL_XX = L
    -- We find that specific key and extract the table
    for key, val in pairs(CraftScan) do
        if type(key) == "string" and key:find("^LOCAL_") then
            local found_table = val
            -- Important: Clear it so the NEXT file (target) doesn't see it
            CraftScan[key] = nil 
            return found_table
        end
    end
end

-- 4. Compare and Export
local target_file = arg[1]
local en_table = get_locale_table("Locales/enUS.lua")
local target_table = get_locale_table(target_file) or {}

if not en_table then
    print("Error: Could not load enUS.lua")
    os.exit(1)
end

local missing = {}
for k, v in pairs(en_table) do
    if not target_table[k] then
        missing[k] = v
    end
end

-- 5. Write to JSON
local out = io.open("missing_keys.json", "w")
out:write(json.encode(missing, { indent = true }))
out:close()