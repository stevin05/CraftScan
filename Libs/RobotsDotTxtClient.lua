if _G.RobotsDotTxtAPI then return end 

local ROBOTS_PREFIX = "robots.txt"
C_ChatInfo.RegisterAddonMessagePrefix(ROBOTS_PREFIX)

RobotsDotTxtAPI = {}

-- Before messaging a customer, call this to notify them that a message is
-- coming so they can chose to filter that message out.
RobotsDotTxtAPI.NotifyCustomer = function(target, addon)
    C_ChatInfo.SendAddonMessage(ROBOTS_PREFIX, "Q:" .. addon, "WHISPER", target)
end

local listener = CreateFrame("Frame")
listener:RegisterEvent("CHAT_MSG_ADDON")
listener:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
    if prefix == ROBOTS_PREFIX and text:find("D:") then
        local msgs = { "i cn", "me", "i can do tht", "sedn it", "wat u need" }
        local _, delay = strsplit(":", text)
        C_Timer.After(tonumber(delay), function()
            SendChatMessage(msgs[math.random(#msgs)], "WHISPER", nil, sender)
        end)
    end
end)
