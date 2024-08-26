local CraftScan = select(2, ...)

local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local dialogPool = CreateFramePool("Frame", UIParent, "CraftScanDialogTemplate")
local textPool = CreateFramePool("Frame", nil, "CraftScanDialogTextTemplate")
local editBoxPool = CreateFramePool("EditBox", nil, "CraftScanDialogTextInputTemplate")
local defaultButtonPool = CreateFramePool("Button", nil, "CraftScan_DialogDefaultButtonTemplate")
local checkButtonPool = CreateFramePool("CheckButton", nil, "CraftScanDialogCheckButtonTemplate")

CraftScan.Dialog = {}

CraftScan.Dialog.Element = {
    EditBox = 1,
    Text = 2,
    CheckButton = 3,

    DefaultButton = 4,
};

CraftScan_DialogCheckButtonMixin = {}

function CraftScan_DialogCheckButtonMixin:OnClick()
    self:GetParent():CheckEnableSubmit()
end

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

local function CreateArgs(dialog)
    local args = {};
    for _, frame in ipairs(dialog.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            table.insert(args, frame:GetText());
        end
        if frame.type == CraftScan.Dialog.Element.CheckButton then
            table.insert(args, frame:GetChecked())
        end
    end
    return unpack(args);
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

    local enabled = true;
    if self.Validator then
        enabled = self.Validator(CreateArgs(self));
    end

    self.SubmitButton:SetEnabled(enabled);
end

local uniq = {};

function CraftScanDialogMixin:OnHide()
    if self.initialized then
        if not self.accepted and self.OnReject then
            self.OnReject();
        end

        if self.frames then
            for _, frame in ipairs(self.frames) do
                if frame.type == CraftScan.Dialog.Element.EditBox then
                    frame:SetText("");
                    editBoxPool:Release(frame);
                elseif frame.type == CraftScan.Dialog.Element.DefaultButton then
                    defaultButtonPool:Release(frame);
                elseif frame.type == CraftScan.Dialog.Element.CheckButton then
                    checkButtonPool:Release(frame);
                else
                    textPool:Release(frame);
                end
            end
            self.frames = nil;
        end
        self.accepted = nil;
        self.initialized = nil;
        if self.key then
            uniq[self.key] = nil;
        end
        CraftScan.Utils.printTable("Hiding dialog", self.key);
        self.key = nil;
        self.OnAccept = nil;
        self.OnReject = nil;
        self.Validator = nil;
        dialogPool:Release(self);
    end
end

CraftScanDialogSubmitMixin = {};

function CraftScanDialogSubmitMixin:OnClick()
    local dialog = self:GetParent();
    if dialog.OnAccept then
        dialog.OnAccept(CreateArgs(dialog));
    end
    dialog.accepted = true;
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
    local totalHeight = 0;
    for _, frame in ipairs(frames) do
        if frame.type ~= CraftScan.Dialog.Element.DefaultButton then
            frame:ClearAllPoints(); -- Clear any previous points to avoid conflicts
            local totalPadding = (frame.padding or 0) + padding;
            if frame.alignLeft then
                frame.alignLeft = nil;
                frame:SetPoint("TOPLEFT", parent, frame.relativePoint or "TOPLEFT", 25,
                    -totalHeight - totalPadding - 28);
            else
                frame:SetPoint("TOP", parent, "TOP", 0, -totalHeight - totalPadding - 28);
            end
            totalHeight = totalHeight + frame:GetHeight() + totalPadding;
        end
    end
    return totalHeight;
end

function CraftScan.Dialog.Show(config)
    if config.key and uniq[config.key] then
        return;
    end

    local dialog = dialogPool:Acquire();

    dialog:SetWidth(config.width or 300);

    local elementWidth = dialog:GetWidth() - 40;

    local firstEditBox = nil;
    local editBoxIndex = 1;
    dialog.frames = {};
    local nextPadding = 0;
    for _, entry in ipairs(config.elements) do
        local np = nextPadding;
        nextPadding = 0;

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
                defaultButton.type = CraftScan.Dialog.Element.DefaultButton;
                table.insert(dialog.frames, defaultButton);
            end
        elseif entry.type == CraftScan.Dialog.Element.CheckButton then
            frame = checkButtonPool:Acquire();
            frame.Text:SetText(entry.text);
            frame:SetChecked(entry.default or false);
            if entry.description then
                frame.Description:SetHeight(1000); -- ALlow textwrapping to work, then resize to fit
                frame.Description:SetWidth(elementWidth - 35);
                frame.Description:SetJustifyH("LEFT");
                frame.Description:SetText(entry.description);
                local height = frame.Description:GetStringHeight();
                frame.Description:SetHeight(height + 25);
                nextPadding = height + 10;
            else
                frame:SetHeight(18);
            end
            frame.alignLeft = true;
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
        if entry.padding or np ~= 0 then
            frame.padding = (entry.padding or 0) + np;
        end
        if entry.type ~= CraftScan.Dialog.Element.CheckButton then
            frame:SetWidth(elementWidth + widthAdjust)
        end
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
    dialog.OnReject = config.OnReject;
    dialog.Validator = config.Validator;


    for _, frame in ipairs(dialog.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            if frame.Validator and #frame:GetText() then
                frame:OnEditFocusLost();
            end
        end
    end

    CraftScan.Frames.makeMovable(dialog);
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    dialog.initialized = true;
    dialog.key = config.key;
    uniq[config.key] = dialog;
    CraftScan.Utils.printTable("Showing dialog", config.key);
    dialog:Show();

    if firstEditBox then
        firstEditBox:SetFocus();
    end
end
