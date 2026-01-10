local json = require("dkjson")

local target_path = arg[1]
local f_json = io.open("translated_keys.json", "r")
if not f_json then 
    print("No new translations found to inject.")
    os.exit(0) 
end

local new_translations = json.decode(f_json:read("*all"))
f_json:close()

-- Open the locale file in APPEND mode
local f_lua = io.open(target_path, "a")
f_lua:write("\n-- AI Generated Translations\n")

for k, v in pairs(new_translations) do
    -- We assume Gemini returns the raw key values (strings)
    -- This appends to the end of the file
    f_lua:write(string.format("L[%q] = %q\n", k, v))
end

f_lua:close()
print("Injected " .. target_path)