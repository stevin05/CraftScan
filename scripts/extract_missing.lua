local json = require('dkjson')

local CraftScan = {}
local target_locales = {}

-- Collect all locales from command line arguments
for i = 1, #arg do
    table.insert(target_locales, arg[i])
end

if #target_locales == 0 then
    print("❌ Usage: lua extract_missing.lua <lang1> <lang2> ...")
    os.exit(1)
end

-- Load Constants once
local consts_path = 'Consts.lua'
local consts_chunk, err = loadfile(consts_path)
if not consts_chunk then
    print('FAILED to load Consts.lua: ' .. tostring(err))
    os.exit(1)
end
consts_chunk('CraftScan', CraftScan)

-- Setup Reverse Lookup Table (Common for all languages)
local ReverseLID = {}
local RN_Bases = {}
for key, value in pairs(CraftScan.CONST.TEXT) do
    ReverseLID[value] = 'LID.' .. key
    if key:find('^RN_') then
        table.insert(RN_Bases, { name = 'LID.' .. key, value = value })
    end
end
table.sort(RN_Bases, function(a, b) return a.value < b.value end)

local function get_key_name(key)
    if type(key) ~= 'number' then return key end
    if ReverseLID[key] then return ReverseLID[key] end
    local best_base = nil
    for _, base in ipairs(RN_Bases) do
        if key > base.value then best_base = base else break end
    end
    if best_base and best_base.name:find('RN_') then
        local offset = key - best_base.value
        if offset < 10 then return string.format('%s + %d', best_base.name, offset) end
    end
    return tostring(key)
end

local function get_locale_table(path)
    local f, err = loadfile(path)
    if not f then return nil end
    f('CraftScan', CraftScan)
    local L = CraftScan.L
    CraftScan.L = {} -- Clean load of the next language
    return L
end

-- Process each locale
local en_table = get_locale_table('Locales/enUS.lua')
if not en_table then os.exit(1) end

for _, locale in ipairs(target_locales) do
    print('🔍 Extracting: ' .. locale)
    local target_table = get_locale_table('Locales/' .. locale .. '.lua') or {}
    local missing = {}
    local count = 0
    
    for k, v in pairs(en_table) do
        if not target_table[k] then
            missing[get_key_name(k)] = v
            count = count + 1
        end
    end

    local out_path = 'missing_keys_' .. locale .. '.json'
    local out = io.open(out_path, 'w')
    if out then
        out:write(json.encode(missing, { indent = true }))
        out:close()
        print('✅ Saved ' .. count .. ' keys to ' .. out_path)
    end
end
