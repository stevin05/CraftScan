local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScanScannerMenuMixin = {}

CraftScanPageButtonMixin = {}

function CraftScanScannerMenuMixin:OnLoad()
    self.pulseLocks = {};
end

-- This is our only always visible frame, so we give it a generic map of
-- callbacks so the entire addon can use it for event registrations that might
-- only fire on a visible frame.
local eventCallbacks = {}
function CraftScanScannerMenuMixin:RegisterEventCallback(event, callback)
    local callbacks = CraftScan.Utils.saved(eventCallbacks, event, {});
    self:RegisterEvent(event);
    table.insert(callbacks, callback);
end

function CraftScanScannerMenuMixin:UnregisterEventCallback(event, callback)
    local callbacks = eventCallbacks[event];
    if callbacks then
        for i, cb in ipairs(callbacks) do
            if cb == callback then
                table.remove(callbacks, i);
                return;
            end
        end
    end
end

local function ToolTipText(lid, ...)
    local binds = { ... };
    for i, bind in ipairs(binds) do
        local b = GetBindingKey(bind);
        if b then
            binds[i] = ' |cffffd100(' .. b .. ')|r';
        else
            binds[i] = '';
        end
    end
    return string.format(L(lid), unpack(binds));
end

function CraftScanPageButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_TOP");
    GameTooltip:SetText(ToolTipText(LID.TOGGLE_CHAT_TOOLTIP, "CRAFT_SCAN_TOGGLE"), 1, 1, 1);
    GameTooltip:Show();
    self.PortraitBorder:SetAtlas("Soulbinds_Tree_Ring");
    self.GlowUp:Show()
end

function CraftScanPageButtonMixin:OnLeave()
    GameTooltip:Hide();
    self.PortraitBorder:SetAtlas("Soulbinds_Tree_Ring_Disabled");
    self.GlowUp:Hide()
end

function CraftScanPageButtonMixin:UpdateIcon(profession)
    -- Set the icon the most appropriate current profession - the one they are
    -- near the table for, the last profession they opened, or as a fallback,
    -- blacksmithing.
    local profession = profession or CraftScan.Utils.CurrentProfession();
    self.Portrait:SetTexture(profession and profession.icon or 4620670);
end

function CraftScanScannerMenuMixin:SetPulseLock(lock, enabled)
    self.pulseLocks[lock] = enabled;
end

function CraftScanScannerMenuMixin:TriggerPulseLock(lock)
    local enabled = true;
    self:SetPulseLock(lock, enabled)
    self.PageButton.MinimapLoopPulseAnim:Play();
end

function CraftScanScannerMenuMixin:HidePulse(lock)
    self:SetPulseLock(lock, false);
    local enabled = false;
    for k, v in pairs(self.pulseLocks) do
        if (v) then
            enabled = true;
            break
        end
    end

    -- If there are no other reasons to show the pulse, hide it
    if (not enabled) then
        self.PageButton.MinimapLoopPulseAnim:Stop();
    end
end

function CraftScanScannerMenuMixin:ClearPulses()
    for k, v in pairs(self.pulseLocks) do
        self.pulseLocks[k] = false;
    end
    self.PageButton.MinimapLoopPulseAnim:Stop();
    self.PageButton.MinimapAlertAnim:Stop()
end

local bannerDirection = nil;
local function UpdateBannerDirection()
    local setting = CraftScan.Utils.GetSetting("banner_direction");

    -- Flip the anchors so the pop-out goes in the desired direction. This will
    -- usually be a no-op unless the setting has changed.
    if setting ~= bannerDirection then
        if bannerDirection ~= nil or setting == CraftScan.CONST.RIGHT then
            CraftScan.Frames.flipTextureHorizontally(CraftScanScannerMenu.PageButton.AlertBG)
        end
        local isLeft = setting == CraftScan.CONST.LEFT;
        local point = isLeft and "RIGHT" or "LEFT";
        local relativePoint = isLeft and "LEFT" or "RIGHT";

        CraftScanScannerMenu.PageButton.AlertBG:ClearAllPoints();
        CraftScanScannerMenu.AlertBGButton:ClearAllPoints();
        CraftScanScannerMenu.PageButton.AlertText:ClearAllPoints();

        CraftScanScannerMenu.PageButton.AlertBG:SetPoint(point, CraftScanScannerMenuButton, "CENTER");
        CraftScanScannerMenu.AlertBGButton:SetPoint(point, CraftScanScannerMenuButton, "CENTER");
        CraftScanScannerMenu.PageButton.AlertText:SetPoint(point, CraftScanScannerMenuButton, relativePoint);
        --isLeft and -4 or 4, 0);

        -- Avoid the wrong justification being cached. Seems to only matter in
        -- testing with the same message repeatedly.
        CraftScanScannerMenu.PageButton.AlertText:SetText("");
        CraftScanScannerMenu.PageButton.AlertText:SetJustifyH(point);
    end
    bannerDirection = setting;
end

local bannerTimeout = nil;
local function UpdateAlertDuration()
    local setting = CraftScan.Utils.GetSetting("banner_timeout");
    if setting ~= bannerTimeout then
        local animation = CraftScanScannerMenu.PageButton.MinimapAlertAnim;
        animation.AlertTextFade:SetStartDelay(setting);
        animation.AlertBGFade:SetStartDelay(setting);
        animation.AlertBGShrink:SetStartDelay(setting);
    end
    bannerTimeout = setting;
end

local activeOrder = nil;
function CraftScanScannerMenuMixin:TriggerAlert(text, order)
    activeOrder = order;
    UpdateBannerDirection();
    UpdateAlertDuration();
    self.PageButton.AlertText:SetText(text);
    self.PageButton.MinimapAlertAnim:Play();
end

function CraftScanScannerMenuMixin:ClearAlert(order)
    if order == activeOrder then
        activeOrder = nil;
        self:ClearPulses()
        self.AlertBGButton.HighlightTexture:Hide()
    end
end

function CraftScanPageButtonMixin:OnClick(button)
    if CraftScan.Frames.OrdersPage:IsShown() then
        HideUIPanel(CraftScan.Frames.OrdersPage);
    else
        ShowUIPanel(CraftScan.Frames.OrdersPage);
    end

    local profession = CraftScan.Utils.CurrentProfession();
    if profession then
        self:UpdateIcon(profession);
    end
end

CraftScanBannerMixin = {}

function CraftScanBannerMixin:OnClick(button)
    if activeOrder then
        CraftScan.GreetCustomer(button, activeOrder)
        self:GetParent():ClearAlert(activeOrder)
    end
end

function CraftScanBannerMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_TOP");
    GameTooltip:SetText(ToolTipText(LID.BANNER_TOOLTIP, "CRAFT_SCAN_GREET_CURRENT_CUSTOMER",
        "CRAFT_SCAN_DISMISS_CURRENT_CUSTOMER"), 1, 1, 1);
    GameTooltip:Show();
    if activeOrder then
        self.HighlightTexture:Show()
    end
end

function CraftScanBannerMixin:OnLeave()
    GameTooltip:Hide();
    self.HighlightTexture:Hide()
end

CraftScan.Utils.onLoad(function()
    local frame = CraftScanScannerMenu
    CraftScan.Frames.MainButton = frame.PageButton;
    CraftScan.Frames.makeMovable(frame.PageButton)

    frame:SetScript("OnEvent", function(self, event, ...)
        local callbacks = eventCallbacks[event];
        if callbacks then
            for _, callback in ipairs(callbacks) do
                callback(...)
            end
        end
    end)

    local function UpdateFrameVisibility()
        if CraftScan.Utils.ShouldShowAlertButton() then
            frame:Show()
        else
            frame:Hide()
        end
    end

    frame:RegisterEventCallback("PLAYER_UPDATE_RESTING", UpdateFrameVisibility)
    frame:RegisterEventCallback("ZONE_CHANGED_NEW_AREA", UpdateFrameVisibility)
    frame:RegisterEventCallback("CINEMATIC_START", UpdateFrameVisibility)
    frame:RegisterEventCallback("CINEMATIC_STOP", UpdateFrameVisibility)

    frame.PageButton:UpdateIcon();

    UpdateFrameVisibility();
end)
