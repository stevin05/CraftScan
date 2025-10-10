local CraftScan = select(2, ...)

function CraftScan.MakeTextWhite(text)
    return "|cFFFFFFFF" .. text .. "|r";
end

function CraftScan.GameTooltip_AddWhite(left)
    GameTooltip:AddLine(left, 255, 255, 255, true)
end

function CraftScan.GameTooltip_AddDoubleWhite(left, right)
    GameTooltip:AddDoubleLine(left, right, 255, 255, 255, 255, 255, 255)
end
