local CraftScan = select(2, ...)

local function L(id)
    return CraftScan.LOCAL:GetText(id)
end

function CraftScan.SetupButton(field, keyword, OnClick)
    field:SetScript('OnClick', OnClick)
    local title = L('dialog.' .. keyword)
    field:SetText(title)
    field:FitToText()

    local tooltip = L('dialog.' .. keyword .. '.tooltip.body')
    field:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(title, nil, nil, nil, nil, true)
        GameTooltip:AddLine(tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    field:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)
end

function CraftScan.SetupCheckBox(panel, field, keyword, size)
    local title = L('dialog.' .. keyword)
    field.Title:SetText(title)

    field.Act:SetChecked(panel:GetConfigValue(keyword))

    field.Act:SetScript('OnClick', function(element)
        panel:UpdateConfigValue(keyword, element:GetChecked())
        panel:OnConfigChange()
    end)
    if size then
        field:SetWidth(size)
    end
    local tooltip = L('dialog.' .. keyword .. '.tooltip.body')
    field:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(title, nil, nil, nil, nil, true)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(tooltip, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    field:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)
end

local function GetDisplayValue(panel, keyword)
    if type(panel.GetDisplayValue) == 'function' then
        return panel:GetDisplayValue(keyword)
    end
    return panel:GetConfigValue(keyword)
end

function CraftScan.SetupInfoIcon(info, keyword)
    info:SetAlpha(0.25)
    info:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(L('dialog.' .. keyword))
        GameTooltip:AddLine(' ')
        CraftScan.GameTooltip_AddWhite(L('dialog.' .. keyword .. '.tooltip.body'))
        GameTooltip:Show()
    end)
    info:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)
end

function CraftScan.SetupTextInput(panel, field, keyword)
    InputScrollFrame_OnLoad(field.Expression)

    if field.Title then
        field.Title:SetText(L('dialog.' .. keyword))
    end
    local value = GetDisplayValue(panel, keyword)
    field.Expression.EditBox:SetText(value)

    -- Pre-validate to display any warnings that existed in the prior state
    if type(panel.Validate) == 'function' then
        panel:Validate(keyword, panel:GetConfigValue(keyword), field.Expression.ValidationIcon)
    end

    local fontFile, _, fontFlags = CraftScanConfigPage.TitleContainer.TitleText:GetFont()
    local FONT_SIZE = 12
    field.Expression.EditBox.Instructions:SetFont(fontFile, FONT_SIZE, fontFlags)

    local instructions = nil
    if type(panel.GetInstructions) == 'function' then
        -- Panels can provide more context sensitive instructions. These are
        -- returned pre-localized.
        instructions = panel:GetInstructions(keyword)
    end
    if not instructions then
        -- If default instructions exist, use them
        instructions = 'dialog.' .. keyword .. '.instructions'
        if CraftScan.LOCAL:Exists(instructions) then
            instructions = L(instructions)
        else
            instructions = nil
        end
    end

    if instructions then
        field.Expression.EditBox.Instructions:SetText(instructions)
    end

    field.Expression.EditBox:SetFont(fontFile, FONT_SIZE, fontFlags)
    field.Expression.EditBox:SetScript('OnTextChanged', InputScrollFrame_OnTextChanged)
    field.Expression.EditBox:SetScript('OnEscapePressed', InputScrollFrame_OnEscapePressed)
    field.Expression.EditBox:SetScript('OnEditFocusGained', function(self)
        if CraftScan.Config.ContainsSubstitutionTags(panel:GetConfigValue(keyword)) then
            -- When the user starts editing, switch back to displaying placeholders.
            self:SetText(panel:GetConfigValue(keyword))
        end
        if self.EnableAutoComplete then
            self.auto_completed = nil
            self:EnableAutoComplete()
        end
    end)
    field.Expression.EditBox:SetScript('OnEditFocusLost', function(self)
        if self.DisableAutoComplete then
            self:DisableAutoComplete()
        end
        local function DoUpdate()
            panel:UpdateConfigValue(keyword, self:GetText())
            panel:OnConfigChange()

            if CraftScan.Config.ContainsSubstitutionTags(self:GetText()) then
                -- When the user is done editing and we've saved their input,
                -- update the text to display with substitutions.
                self:SetText(GetDisplayValue(panel, keyword))
            end
        end
        if type(panel.Validate) == 'function' then
            panel:Validate(keyword, self:GetText(), field.Expression.ValidationIcon)
            if field.Expression.ValidationIcon:OK() then
                DoUpdate()
            end
        else
            DoUpdate()
        end
    end)
    if field.Info then
        CraftScan.SetupInfoIcon(field.Info, keyword)
    end

    if panel.tabGroup then
        panel.tabGroup:AddFrame(field.Expression.EditBox)
    end

    if CraftScan.DB.settings['tag.autocomplete_enabled'] ~= false then
        local OnTextChanged_Base = field.Expression.EditBox:GetScript('OnTextChanged')
        local OnCursorChanged_Base = field.Expression.EditBox:GetScript('OnCursorChanged')

        local function AutoCompleteTag(self, BaseFn, ...)
            if BaseFn then
                BaseFn(self, ...)
            end

            local cursor = self:GetCursorPosition()
            local before = self:GetText():sub(1, cursor)
            local tagPrefix = before:match('.*{(.*)')
            if not tagPrefix or tagPrefix == '' or string.find(tagPrefix, '}') then
                return
            end

            local after = self:GetText():sub(cursor + 1)
            local tagSuffix = after:match('^([^ %}]+)')

            local suggestions = CraftScan.Config.GetSuggestions(tagPrefix)

            if #suggestions then
                local function DoAutoComplete(editBox, tag, force)

                    editBox.auto_completed = editBox.auto_completed or {}
                    if not force and editBox.auto_completed[tag] then
                        return
                    end
                    editBox.auto_completed[tag] = true

                    local close = '}'
                    if #after and after:sub(1, 1) == '}' then
                        close = ''
                    end

                    text = before:sub(1, #before - #tagPrefix) .. tag .. close .. after
                    editBox:DisableAutoComplete()
                    editBox:SetText(text)
                    editBox:EnableAutoComplete()
                    editBox:SetCursorPosition(#before - #tagPrefix + #tag + 1)

                    -- There has to be a close menu function somewhere,
                    -- but I can't seem to find one that works. Creating
                    -- a new empty menu closes the old one and doesn't
                    -- display anything though, so that's what we go with.
                    MenuUtil.CreateContextMenu(self, function(owner, rootDescription) end)
                end

                if #suggestions == 1 then
                    if not tagSuffix then
                        DoAutoComplete(self, suggestions[1])
                        return
                    end
                end

                MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
                    for _, suggestion in ipairs(suggestions) do
                        rootDescription:CreateButton(suggestion, function()
                            field.Expression.EditBox:SetFocus()

                            local force = true
                            DoAutoComplete(field.Expression.EditBox, suggestion, force)

                            return MenuResponse.Close
                        end)
                    end
                end)
            end
        end

        local OnCursorChanged_AutoComplete = function(self, ...)
            AutoCompleteTag(self, OnCursorChanged_Base, ...)
        end
        local OnTextChanged_AutoComplete = function(self, ...)
            AutoCompleteTag(self, OnTextChanged_Base, ...)
        end

        field.Expression.EditBox.EnableAutoComplete = function()
            field.Expression.EditBox:SetScript('OnCursorChanged', OnCursorChanged_AutoComplete)
            field.Expression.EditBox:SetScript('OnTextChanged', OnTextChanged_AutoComplete)
        end

        field.Expression.EditBox.DisableAutoComplete = function()
            field.Expression.EditBox:SetScript('OnCursorChanged', OnCursorChanged_Base)
            field.Expression.EditBox:SetScript('OnTextChanged', OnTextChanged_Base)
        end
    end

    field.Expression.EditBox:SetScript('OnTabPressed', function(self)
        if instructions then
            if self:GetText() == '' then
                self:SetText(instructions)
                if type(panel.InstructionsAccepted) == 'function' then
                    panel:InstructionsAccepted(instructions)
                    return -- Don't tab out of the form; let them continue editing
                end
            end
        end
        if panel.tabGroup then
            panel.tabGroup:OnTabPressed()
        end
    end)
end

CraftScanTextInputValidationIconMixin = {}

local function ColorTextInputBorder(textInput, r, g, b, a)
    for _, tex in ipairs({
        'TopLeftTex',
        'TopRightTex',
        'TopTex',
        'BottomLeftTex',
        'BottomRightTex',
        'BottomTex',
        'LeftTex',
        'RightTex',
        'MiddleTex',
    }) do
        textInput[tex]:SetVertexColor(r, g, b, a)
    end
end

function CraftScanTextInputValidationIconMixin:Error(error)
    self:Clear()
    ColorTextInputBorder(self:GetParent(), 1, 0, 0, 1)
    self:SetAtlas('common-icon-redx')
    self.error = error
    self:Show()
    self:OnEnter()
end

function CraftScanTextInputValidationIconMixin:Warning(warning)
    self:Clear()
    self:SetAtlas('Garr_Building-AddFollowerPlus')
    self:SetAlpha(0.5)
    self.warning = warning
    self:Show()
    self:OnEnter()
end

function CraftScanTextInputValidationIconMixin:Info(info)
    self:Clear()
    self:SetAtlas('Garr_Building-AddFollowerPlus')
    self:SetVertexColor(0, 1, 0, 1)
    self:SetAlpha(0.5)
    self.info = info
    self:Show()
end

function CraftScanTextInputValidationIconMixin:Clear()
    ColorTextInputBorder(self:GetParent(), 1, 1, 1, 1)
    self:SetAlpha(1)
    self:SetVertexColor(1, 1, 1, 1)
    self.error = nil
    self.warning = nil
    self.info = nil
    self:OnLeave()
    self:Hide()
end

function CraftScanTextInputValidationIconMixin:OK()
    return self.error == nil
end

function CraftScanTextInputValidationIconMixin:OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    if self.error then
        if type(self.error) ~= 'function' then
            GameTooltip:SetText(L('Unsaved Changes'), 1, 0, 0, 1)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(self.error, 1, 0, 0, 1, true)
        else
            self.error(GameTooltip)
        end
    elseif self.warning then
        if type(self.warning) ~= 'function' then
            GameTooltip:SetText(self.warning, 1, 1, 1, 1, true)
        else
            self.warning(GameTooltip)
        end
    else
        if type(self.info) ~= 'function' then
            GameTooltip:SetText(self.info, 1, 1, 1, 1, true)
        else
            self.info(GameTooltip)
        end
    end
    GameTooltip:Show()
end

function CraftScanTextInputValidationIconMixin:OnLeave()
    GameTooltip:Hide()
end
