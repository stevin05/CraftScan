local CraftScan = select(2, ...)

local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local dialogPool = CreateFramePool("Frame", UIParent, "CraftScanDialogTemplate")
local textPool = CreateFramePool("Frame", nil, "CraftScanDialogTextTemplate")
local editBoxPool = CreateFramePool("EditBox", nil, "CraftScanDialogTextInputTemplate")
local defaultButtonPool = CreateFramePool("Button", nil, "CraftScan_DialogDefaultButtonTemplate")

CraftScan.Dialog = {}

CraftScan.Dialog.Element = {
    EditBox = 1,
    Text = 2,
};

CraftScan_DialogDefaultButtonMixin = {}

function CraftScan_DialogDefaultButtonMixin:OnClick()
    self.EditBox:SetText(self.default_text);
    self.EditBox:OnEditFocusLost();
    self:SetEnabled(false);
end

function CraftScan_DialogDefaultButtonMixin:Refresh()
    if self.EditBox:GetText() == self.default_text then
        self:SetEnabled(false);
    else
        self:SetEnabled(true);
    end
end

CraftScanDialogMixin = {};

function CraftScanDialogMixin:CheckEnableSubmit()
    for _, frame in ipairs(self.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            if frame:GetText() == "" or frame.error == true then
                self.SubmitButton:SetEnabled(false);
                return;
            end
        end
    end
    self.SubmitButton:SetEnabled(true);
end

function CraftScanDialogMixin:OnHide()
    for _, frame in ipairs(self.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            editBoxPool:Release(frame);
        else
            textPool:Release(frame);
        end
    end
    self.frames = nil;
    dialogPool:Release(self);
end

CraftScanDialogSubmitMixin = {};

function CraftScanDialogSubmitMixin:OnClick()
    local dialog = self:GetParent();
    if dialog.OnAccept then
        local args = {};
        for _, frame in ipairs(dialog.frames) do
            if frame.type == CraftScan.Dialog.Element.EditBox then
                table.insert(args, frame:GetText());
            end
        end
        dialog.OnAccept(unpack(args));
    end
    dialog:Hide();
end

CraftScan_DialogTextInputAlertIconMixin = {}

function CraftScan_DialogTextInputAlertIconMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if self.error then
        GameTooltip:SetText(self.error, 1, 0, 0, 1, true)
    else
        GameTooltip:SetText(self.warning, 1, 0.647, 0, 1, true)
    end
    GameTooltip:Show()
end

function CraftScan_DialogTextInputAlertIconMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScanDialogTextInputMixin = {};

function CraftScanDialogTextInputMixin:OnLoad()
    self:SetAutoFocus(false);
end

function CraftScanDialogTextInputMixin:OnEscapePressed()
    self:ClearFocus();
end

function CraftScanDialogTextInputMixin:OnTabPressed()
    local next = false;
    local dialog = self:GetParent();
    for _, frame in ipairs(dialog.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            if next then
                frame:SetFocus(true);
                return;
            end
            if frame == self then
                next = true;
            end
        end
    end
    self:ClearFocus();
end

function CraftScanDialogTextInputMixin:OnEnterPressed()
    self:ClearFocus();

    local dialog = self:GetParent();
    if dialog.SubmitButton:IsEnabled() then
        dialog.SubmitButton:OnClick();
    else
        self:OnTabPressed();
    end
end

function CraftScanDialogTextInputMixin:OnEditFocusLost(...)
    local text = self:GetText()

    if self.DefaultButton then
        self.DefaultButton:Refresh();
    end
    if self.Validator then
        local result = self.Validator(self.index, text);
        self.error = false;
        if result ~= nil then
            if result.error then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(result.error, 1, 0, 0, 1, true)
                GameTooltip:Show()
                self.InvalidInput:SetAtlas("common-icon-redx")
                self.InvalidInput.error = result.error;
                self.InvalidInput:Show();
                self.InvalidInput:OnEnter();
                self.error = true;

                self:GetParent().SubmitButton:SetEnabled(false);
                return;
            end
            if result.warning then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                self.InvalidInput:SetAtlas("UI-HUD-MicroMenu-Questlog-Mouseover")
                self.InvalidInput.warning = result.warning;
                self.InvalidInput:Show();
                self.InvalidInput:OnEnter();
            end
        else
            GameTooltip:Hide();
            self.InvalidInput:Hide();
        end
    end
    self:GetParent():CheckEnableSubmit();
end

function LayoutFramesVertically(frames, parent, padding)
    local lastFrame;
    local totalHeight = 0;
    for _, frame in ipairs(frames) do
        frame:ClearAllPoints(); -- Clear any previous points to avoid conflicts
        local totalPadding = (frame.padding or 0) + padding;
        if frame.alignLeft then
            frame.alignLeft = nil;
            frame:SetPoint("TOPLEFT", parent, frame.relativePoint or "TOPLEFT", 25,
                -totalHeight - totalPadding - 28);
        else
            frame:SetPoint("TOP", parent, "TOP", 0, -totalHeight - totalPadding - 28);
        end
        lastFrame = frame;
        totalHeight = totalHeight + frame:GetHeight() + totalPadding;
    end
    return totalHeight;
end

function CraftScan.Dialog.Show(config)
    local dialog = dialogPool:Acquire();
    if config.width then
        dialog:SetWidth(config.width);
    end

    local elementWidth = dialog:GetWidth() - 40;

    local firstEditBox = nil;
    local editBoxIndex = 1;
    dialog.frames = {};
    for _, entry in ipairs(config.elements) do
        local widthAdjust = 0;
        local frame;
        if entry.type == CraftScan.Dialog.Element.EditBox then
            frame = editBoxPool:Acquire();
            if not firstEditBox then
                firstEditBox = frame;
            end
            submitEnabled = false;

            frame.Validator = entry.Validator;
            frame.index = editBoxIndex;
            editBoxIndex = editBoxIndex + 1;

            if entry.initial_text then
                frame:SetText(entry.initial_text);
            end
            if entry.default_text then
                local defaultButton = defaultButtonPool:Acquire();
                defaultButton:SetParent(frame);
                defaultButton:SetText(L("Default"));
                defaultButton:FitToText();
                defaultButton:SetPoint("LEFT", frame, "RIGHT", 3);
                defaultButton.EditBox = frame;
                frame.DefaultButton = defaultButton;
                defaultButton.default_text = entry.default_text;
                defaultButton:Refresh();
                defaultButton:Show();
                widthAdjust = -defaultButton:GetWidth();
                frame.alignLeft = true;
            end
        elseif entry.type == CraftScan.Dialog.Element.Text then
            frame = textPool:Acquire();
            frame.Text:SetHeight(1000); -- ALlow textwrapping to work, then resize to fit
            frame:SetHeight(1000);      -- ALlow textwrapping to work, then resize to fit
            frame.Text:SetText(entry.text);
            local height = frame.Text:GetStringHeight() + 25;
            frame.Text:SetHeight(height);
            frame:SetHeight(height);
        end
        frame.type = entry.type;
        frame.padding = entry.padding;
        frame:SetWidth(elementWidth + widthAdjust)
        frame:Show();
        frame:SetParent(dialog);
        table.insert(dialog.frames, frame);
    end

    dialog:SetHeight(80 + LayoutFramesVertically(dialog.frames, dialog, 0));
    dialog:SetTitle(config.title);
    dialog.SubmitButton:SetText(config.submit);
    dialog.SubmitButton:FitToText();
    dialog:CheckEnableSubmit();
    dialog.OnAccept = config.OnAccept;


    for _, frame in ipairs(dialog.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            if frame.Validator and #frame:GetText() then
                frame:OnEditFocusLost();
            end
        end
    end

    CraftScan.Frames.makeMovable(dialog);
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    dialog:Show();

    if firstEditBox then
        firstEditBox:SetFocus();
    end
end
