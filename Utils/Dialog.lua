local CraftScan = select(2, ...)


local dialogPool = CreateFramePool("Frame", UIParent, "CraftScanDialogTemplate")
local textPool = CreateFramePool("Frame", nil, "CraftScanDialogTextTemplate")
local editBoxPool = CreateFramePool("EditBox", nil, "CraftScanDialogTextInputTemplate")

CraftScan.Dialog = {}

CraftScan.Dialog.Element = {
    EditBox = 1,
    Text = 2,
};

CraftScanDialogMixin = {};

function CraftScanDialogMixin:CheckEnableSubmit()
    for _, frame in ipairs(self.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            if frame:GetText() == "" then
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

function CraftScanDialogTextInputMixin:OnTextChanged()
    self:GetParent():CheckEnableSubmit();
end

function LayoutFramesVertically(frames, parent, padding)
    local lastFrame;
    local totalHeight = 0;
    for _, frame in ipairs(frames) do
        frame:ClearAllPoints(); -- Clear any previous points to avoid conflicts
        local totalPadding = (frame.padding or 0) + padding;
        if lastFrame then
            frame:SetPoint("TOP", lastFrame, "BOTTOM", 0, -totalPadding);
        else
            frame:SetPoint("TOP", parent, "TOP", 0, -totalPadding - 28);
        end
        lastFrame = frame;
        totalHeight = totalHeight + frame:GetHeight() + totalPadding;
    end
    return totalHeight;
end

function CraftScan.Dialog.Show(config)
    local dialog = dialogPool:Acquire();

    local firstEditBox = nil;
    dialog.frames = {};
    for _, entry in ipairs(config.elements) do
        local frame;
        if entry.type == CraftScan.Dialog.Element.EditBox then
            frame = editBoxPool:Acquire();
            if not firstEditBox then
                firstEditBox = frame;
            end
            submitEnabled = false;
        elseif entry.type == CraftScan.Dialog.Element.Text then
            frame = textPool:Acquire();
            frame.Text:SetHeight(9999); -- ALlow textwrapping to work, then resize to fit
            frame.Text:SetText(entry.text);
            frame.Text:SetHeight(frame.Text:GetStringHeight());
            frame:SetHeight(frame.Text:GetStringHeight());
        end
        frame.type = entry.type;
        frame.padding = entry.padding;
        frame:Show();
        frame:SetParent(dialog);
        table.insert(dialog.frames, frame);
    end

    dialog:SetHeight(80 + LayoutFramesVertically(dialog.frames, dialog, 0));
    dialog:SetTitle(config.title);
    dialog.SubmitButton:SetText(config.submit);
    dialog.SubmitButton:FitToText();
    dialog.SubmitButton:SetEnabled(firstEditBox == nil);
    dialog.OnAccept = config.OnAccept;


    CraftScan.Frames.makeMovable(dialog);
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    dialog:Show();

    if firstEditBox then
        firstEditBox:SetFocus();
    end
end
