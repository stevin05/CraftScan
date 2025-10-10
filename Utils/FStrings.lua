local CraftScan = select(2, ...)

local function f(s, dict)
    return (s:gsub("{(.-)}", function(key)
        return dict[key] or "{"..key.."}"
    end))
end

CraftScan.Utils.FString = f;