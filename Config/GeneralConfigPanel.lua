local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT
local function L(id)
    return CraftScan.LOCAL:GetText(id)
end

local panel = nil

function CraftScan.Config.LoadGlobalConfigOptions()
    if not panel then
        panel = CreateFrame(
            'Frame',
            'CraftScanGeneralConfigPanel',
            CraftScanConfigPage.Options,
            'CraftScanGeneralConfigPanelTemplate'
        )
    end
    panel.Matching:Init()
    panel.Greetings:Init()
    return panel
end

CraftScanGeneralConfigPanelMixin = {}

function CraftScanGeneralConfigPanelMixin:TabGroup()
    if not self.tabGroup then
        self.tabGroup = CreateTabGroup()
    end
    return self.tabGroup
end

CraftScanGeneralConfigMatchingMixin = {}

function CraftScanGeneralConfigMatchingMixin:Init()
    self.tabGroup = self:GetParent():TabGroup()
    self.Title:SetText(L('Base Filters'))
    CraftScan.SetupTextInput(self, self.Keywords, 'inclusions')
    CraftScan.SetupTextInput(self, self.Exclusions, 'exclusions')
end

function CraftScanGeneralConfigMatchingMixin:GetConfigValue(keyword)
    return CraftScan.DB.settings[keyword]
end

function CraftScanGeneralConfigMatchingMixin:UpdateConfigValue(keyword, value)
    CraftScan.DB.settings[keyword] = value
end

function CraftScanGeneralConfigMatchingMixin:OnConfigChange()
    CraftScan.Config.OnConfigChange()
end

CraftScanGreetingConfigPanelMixin = {}

function CraftScanGreetingConfigPanelMixin:Init()
    self.tabGroup = self:GetParent():TabGroup()
    self.Title:SetText(L('Customer Greetings'))
    self.greetings = {
        ['GREETING_I_CAN_CRAFT_ITEM'] = { placeholders = { '{crafter}', '{item}' } },
        ['GREETING_I_HAVE_PROF'] = {
            placeholders = { '{crafter}', '{profession}', '{profession_link}' },
        },
        ['GREETING_ALT_CAN_CRAFT_ITEM'] = { placeholders = { '{crafter}', '{item}' } },
        ['GREETING_ALT_HAS_PROF'] = { placeholders = { '{crafter}', '{profession}' } },
        ['GREETING_ALT_SUFFIX'] = { placeholders = { '{crafter}' } },
        ['GREETING_BUSY'] = { placeholders = {} },
    }

    for _, key in pairs({
        'GREETING_I_CAN_CRAFT_ITEM',
        'GREETING_I_HAVE_PROF',
        'GREETING_ALT_CAN_CRAFT_ITEM',
        'GREETING_ALT_HAS_PROF',
        'GREETING_ALT_SUFFIX',
        'GREETING_BUSY',
    }) do
        CraftScan.SetupTextInput(self, self[key], key)
    end
end

function CraftScanGreetingConfigPanelMixin:GetConfigValue(keyword)
    local sv = CraftScan.DB.settings.greeting or {}
    return sv[keyword] or L(LID[keyword])
end

function CraftScanGreetingConfigPanelMixin:UpdateConfigValue(keyword, value)
    local sv = CraftScan.Utils.saved(CraftScan.DB.settings, 'greeting', {})
    if value == '' then
        sv[keyword] = nil
    else
        sv[keyword] = value
    end
    CraftScanComm:ShareCustomGreeting(sv)
end

function CraftScanGreetingConfigPanelMixin:OnConfigChange() end

function CraftScanGreetingConfigPanelMixin:GetDisplayValue(keyword)
    return CraftScan.Config.SubstituteTags(self:GetConfigValue(keyword))
end

function CraftScanGreetingConfigPanelMixin:Validate(keyword, user_value, reporter)
    value = CraftScan.Config.SubstituteTags(user_value)

    local extra_placeholders = {}
    local num_extra_placeholders = 0
    local placeholders = self.greetings[keyword].placeholders
    for placeholder in string.gmatch(value, '%b{}') do
        if not CraftScan.Utils.Contains(placeholders, placeholder) then
            table.insert(extra_placeholders, placeholder)
            num_extra_placeholders = num_extra_placeholders + 1
        end
    end
    local missing_placeholders = {}
    local num_missing_placeholders = 0
    for i, placeholder in ipairs(placeholders) do
        if not value:match(placeholder) then
            table.insert(missing_placeholders, placeholder)
            num_missing_placeholders = num_missing_placeholders + 1
        end
    end

    local messages = {}
    if num_extra_placeholders > 0 then
        table.insert(
            messages,
            string.format(L(LID.EXTRA_PLACEHOLDERS), table.concat(extra_placeholders, ', '))
        )
    end
    if value:match('%%s') then
        table.insert(messages, L(LID.LEGACY_PLACEHOLDERS))
    end
    if num_missing_placeholders > 0 then
        table.insert(
            messages,
            string.format(L(LID.MISSING_PLACEHOLDERS), table.concat(missing_placeholders, ', '))
        )
    end
    local message = table.concat(messages, '\n\n')
    if num_extra_placeholders > 0 then
        reporter:Error(message)
    elseif message ~= '' then
        reporter:Warning(function(tooltip)
            tooltip:SetText(message, 1, 1, 1, 1, true)
            CraftScan.Config.AppendSubstitutionTagTooltip(user_value, tooltip, false)
        end)
    else
        CraftScan.Config.PopulateSubstitutionTagTooltip(user_value, reporter)
    end
end
