local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT
local function L(id)
    return CraftScan.LOCAL:GetText(id)
end

local defaults = {
    [INVTYPE_HEAD] = false,
    [INVTYPE_NECK] = false,
    [INVTYPE_SHOULDER] = false,
    [INVTYPE_BODY] = false,
    [INVTYPE_CHEST] = false,
    [INVTYPE_WAIST] = false,
    [INVTYPE_LEGS] = false,
    [INVTYPE_FEET] = false,
    [INVTYPE_WRIST] = false,
    [INVTYPE_HAND] = false,
    [INVTYPE_FINGER] = false,
    [INVTYPE_TRINKET] = false,
    [INVTYPE_WEAPON] = false,
    [INVTYPE_SHIELD] = false,
    [INVTYPE_RANGED] = false,
    [INVTYPE_CLOAK] = false,
    [INVTYPE_2HWEAPON] = false,
    [INVTYPE_BAG] = false,
    [INVTYPE_TABARD] = false,
    [INVTYPE_ROBE] = false,
    [INVTYPE_WEAPONMAINHAND] = false,
    [INVTYPE_WEAPONOFFHAND] = false,
    [INVTYPE_HOLDABLE] = false,
    [INVTYPE_AMMO] = false,
    [INVTYPE_THROWN] = false,
    [INVTYPE_RANGEDRIGHT] = false,
    [INVTYPE_QUIVER] = false,
    [INVTYPE_RELIC] = false,
    [INVTYPE_PROFESSION_TOOL] = false,
    [INVTYPE_PROFESSION_GEAR] = false,
    [ITEM_QUALITY3_DESC] = false, -- rare
    [ITEM_QUALITY4_DESC] = false, -- epic
    ['pvp'] = false, -- needs no translation
}

function CraftScan.Config.GetSuggestions(text)
    local result = {}
    text = text:lower()
    local tags = CraftScan.Utils.saved(CraftScan.DB.settings, 'substitution_tags', {})
    for tag, _ in pairs(tags) do
        local lowered = tag:lower()
        if lowered:sub(1, #text) == text then
            table.insert(result, tag)
        end
    end
    return result
end

function CraftScan.Config.SubstitutionTagExists(key)
    local settings = CraftScan.DB.settings
    if settings.substitution_tags and settings.substitution_tags[key] then
        return true
    end
    if defaults[key] ~= nil then
        return true
        -- We auto-complete default tags, so automatically generate a tag for
        -- them on first use.
    end
    return false
end

function CraftScan.Config.ContainsSubstitutionTags(text)
    return text:find('{')
end

function CraftScan.Config.AppendSubstitutionTagTooltip(text, tooltip, asTitle)
    local tags = CraftScan.Utils.saved(CraftScan.DB.settings, 'substitution_tags', {})
    local contains = {}
    for key in text:gmatch('{(.-)}') do
        if tags[key] then
            table.insert(contains, key)
        end
    end
    if #contains ~= 0 then
        if asTitle then
            tooltip:SetText(L('dialog.contains_substitution_tags.tooltip.title'))
        else
            tooltip:AddLine(' ')
            tooltip:AddLine(L('dialog.contains_substitution_tags.tooltip.title'), 1, 1, 1)
        end
        tooltip:AddLine(' ')
        tooltip:AddLine(L('dialog.contains_substitution_tags.tooltip.body'), 1, 1, 1)
        tooltip:AddLine(' ')
        for _, key in ipairs(contains) do
            tooltip:AddLine('{' .. key .. '}: ' .. tags[key], 1, 1, 1)
        end
    end
end

function CraftScan.Config.PopulateSubstitutionTagTooltip(text, reporter)
    local tags = CraftScan.Utils.saved(CraftScan.DB.settings, 'substitution_tags', {})
    for key in text:gmatch('{(.-)}') do
        if tags[key] then
            reporter:Info(function(tooltip)
                CraftScan.Config.AppendSubstitutionTagTooltip(text, tooltip, true)
            end)
            return
        end
    end

    reporter:Clear()
end
-- There don't seem to be globals for these, so we'll add the profession names
-- to the default map on first use.
local dynamic_defaults_loaded = false
local LoadDynamicDefaults = function()
    if dynamic_defaults_loaded then
        return
    end

    defaults[L('Commission')] = L(LID.DEFAULT_COMMISSION)

    local professionIDs = C_TradeSkillUI.GetAllProfessionTradeSkillLines()
    for _, id in ipairs(professionIDs) do
        if CraftScan.Utils.IsCurrentExpansion(id) then
            local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(id)
            if info.parentProfessionID then
                defaults[info.parentProfessionName] =
                    L(CraftScan.CONST.PROFESSION_DEFAULT_KEYWORDS[info.parentProfessionID])
            end
        end
    end

    dynamic_defaults_loaded = true
end

function CraftScan.Config.AutoCreateFromDefault(text)
    LoadDynamicDefaults()

    -- Auto create any tags in the above default list that don't already exist
    local tags = CraftScan.Utils.saved(CraftScan.DB.settings, 'substitution_tags', {})
    for key in text:gmatch('{(.-)}') do
        if defaults[key] ~= nil and not tags[key] then
            -- Default to just the key again except for professions where we
            -- already have default keywords for each
            tags[key] = defaults[key] or key
        end
    end
end

function CraftScan.Config.SubstituteTags(text)
    local tags = CraftScan.DB.settings.substitution_tags or {}
    return CraftScan.Utils.FString(text, tags)
end

local panel = nil
function CraftScan.Config.LoadSubstitutionTagConfigOptions(configInfo)
    if not panel then
        panel = CreateFrame(
            'Frame',
            'CraftScanTagConfigPanel',
            CraftScanConfigPage.Options,
            'CraftScanTagConfigPanelTemplate'
        )
    end
    panel:Init()
    return panel
end

CraftScanTagConfigPanelMixin = {}

function CraftScanTagConfigPanelMixin:OnLoad()
    local padLeft = 0
    local pad = 5
    local spacing = 1
    local view = CreateScrollBoxListLinearView(pad, pad, padLeft, pad, spacing)
    view:SetElementFactory(function(factory, node)
        local function Initializer(element, node)
            element:Init(node)
        end

        factory('CraftScanExistingTagEntryTemplate', Initializer)
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil, nil)
end

function CraftScanTagConfigPanelMixin:Init()
    self.tags = CraftScan.Utils.saved(CraftScan.DB.settings, 'substitution_tags', {})

    self:SetupNewTagInputs()

    local dataProvider = CreateDataProvider()
    dataProvider:SetSortComparator(function(lhs, rhs)
        return strcmputf8i(lhs.key, rhs.key) < 0
    end)
    for key, value in pairs(self.tags) do
        dataProvider:Insert({
            key = key,
            value = value,
        })
    end
    self.ScrollBox:SetDataProvider(dataProvider)
    self.dataProvider = dataProvider
end

local function StripTag(tag)
    return tag:gsub('[{}]', '')
end

function CraftScanTagConfigPanelMixin:NewTagInvalid(value)
    -- If they include {} syntax, only allow one at the start and end, and they
    -- must match if used.
    local _, opens = value:gsub('{', '')
    if opens > 1 or (opens == 1 and value:sub(1, 1) ~= '{') then
        return L('tag.invalid.braces')
    end

    local _, closes = value:gsub('}', '')
    if closes > 1 or (closes == 1 and value:sub(-1) ~= '}') then
        -- } not at the end of the string
        CraftScan.Debug.Print(2, 'NewTagInvalid')
        CraftScan.Debug.Print(closes, 'closes')
        CraftScan.Debug.Print(value:sub(-1), 'sub')
        return L('tag.invalid.braces')
    end

    if opens ~= closes then
        CraftScan.Debug.Print(2, 'NewTagInvalid')
        return L('tag.invalid.braces')
    end

    -- Make sure the tag doesn't already exist
    if self.tags[StripTag(value)] ~= nil then
        return L('tag.invalid.unique')
    end

    return nil
end

function CraftScanTagConfigPanelMixin:SetupNewTagInputs()
    self.defaults = {
        ['tag.autocomplete_enabled'] = true,
    }
    CraftScan.SetupTextInput(self, self.AddTag, 'tag.new')
    CraftScan.SetupCheckBox(self, self.AutoCompleteEnabled, 'tag.autocomplete_enabled')

    -- Set tab and enter to auto-unfocus the text input. Enter creates the entry.
    self.AddTag.Expression.EditBox:SetScript('OnTabPressed', function(editBox)
        editBox:ClearFocus()
    end)
    self.AddTag.Expression.EditBox:SetScript('OnEnterPressed', function(editBox)
        editBox:ClearFocus()
        self.AddTagButton:Click()
        editBox:SetFocus()
    end)
    self.AddTagButton:ClearAllPoints()
    self.AddTagButton:SetPoint('LEFT', self.AddTag, 'RIGHT', 0, -15)
    CraftScan.SetupButton(self.AddTagButton, 'tag.new.button', function()
        if self:NewTagInvalid(self.new_tag) then
            -- Only happens in the above OnEnterPressed hook, when we send the
            -- click internally.
            self.AddTagButton:SetEnabled(false)
            return
        end
        self.tags[StripTag(self.new_tag)] = ''
        self.dataProvider:Insert({
            key = StripTag(self.new_tag),
            value = '',
        })
        self.new_tag = nil
        self.AddTag.Expression.EditBox:SetText('')
        self.AddTagButton:SetEnabled(false)
        self:OnConfigChange()
    end)
    self.AddTagButton:SetEnabled(false)

    self.DeleteTagHelp:SetPoint('LEFT', self.AddTagButton, 'RIGHT', 6, 0)
    self.DeleteTagHelp:SetText(L('dialog.tag.delete.help'))

    self.KeyHeader:SetText(L('dialog.tag.header.key'))
    self.ValueHeader:SetText(L('dialog.tag.header.value'))
    self.ValueHeader:SetWidth(0) -- Autosize

    CraftScan.SetupInfoIcon(self.HeaderInfo, 'tag.header')
end

function CraftScanTagConfigPanelMixin:Validate(keyword, value, reporter)
    local invalid = self:NewTagInvalid(value)
    if invalid then
        reporter:Error(function(tooltip)
            GameTooltip:SetText(invalid, 1, 0, 0, 1, true)
        end)
    else
        reporter:Clear()
    end
end

function CraftScanTagConfigPanelMixin:GetConfigValue(keyword)
    if keyword == 'tag.new' then
        return self.new_tag or ''
    end

    return CraftScan.DB.settings[keyword] or self.defaults[keyword]
end

function CraftScanTagConfigPanelMixin:UpdateConfigValue(keyword, value)
    if keyword == 'tag.new' then
        if value ~= '' and self:NewTagInvalid(value) == nil then
            self.new_tag = value
            self.AddTagButton:SetEnabled(true)
        end
        return
    end

    CraftScan.DB.settings[keyword] = value
end

function CraftScanTagConfigPanelMixin:OnConfigChange()
    CraftScan.Config.OnConfigChange()
end

CraftScanExistingTagEntryMixin = {}

function CraftScanExistingTagEntryMixin:Init(node)
    self.tags = CraftScan.Utils.saved(CraftScan.DB.settings, 'substitution_tags', {})
    self.key = node.key
    self.KeyRegion.Key:SetText('{' .. node.key .. '}')
    CraftScan.SetupTextInput(self, self.Value, 'tag_value')
    self.Value.Expression.EditBox:SetScript('OnTabPressed', function(self)
        self:ClearFocus()
    end)

    CraftScan.Utils.SetupParentChildScrolling(self.Value.Expression, panel.ScrollBox)

    self.KeyRegion:SetScript('OnClick', function()
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
            rootDescription:CreateButton(string.format(L('dialog.tag.copy'), self.key), function()
                panel.AddTag.Expression.EditBox:SetText('{' .. self.key .. '}')
                panel.AddTag.Expression.EditBox:SetFocus()
                panel.AddTag.Expression.EditBox:HighlightText(0, -1)
            end)
            rootDescription:QueueDivider()
            rootDescription:CreateButton(string.format(L('dialog.tag.delete'), self.key), function()
                self.tags[self.key] = nil
                panel.dataProvider:RemoveByPredicate(function(node)
                    return self.key == node.key
                end)
            end)
        end)
    end)
end

function CraftScanExistingTagEntryMixin:GetConfigValue(keyword)
    return self.tags[self.key]
end

function CraftScanExistingTagEntryMixin:UpdateConfigValue(keyword, value)
    self.tags[self.key] = value
end

function CraftScanExistingTagEntryMixin:OnConfigChange()
    CraftScan.Config.OnConfigChange()
end
