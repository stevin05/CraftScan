local CraftScan = select(2, ...)

CraftScan.LOCAL = {}

-- Swap this with the real implementation so anything not localized will stand
-- out as not ~'s.
--[[
---@param ID CraftScan.LOCALIZATION_IDS
function CraftScan.LOCAL:GetText(ID)
    local result = CraftScan.L[ID]
    if result then
        return string.rep("~", #result)
    end
    return nil;
end
]]

function CraftScan.LOCAL:Exists(ID)
    return CraftScan.L[ID] ~= nil
end

function CraftScan.LOCAL:GetText(ID)
    return CraftScan.L[ID] or ID
end
