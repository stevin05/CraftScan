local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT
local function L(id)
    return CraftScan.LOCAL:GetText(id)
end

local panel = nil
function CraftScan.Config.LoadRecipeConfigOptions(configInfo)
    if not panel then
        panel = CreateFrame(
            'Frame',
            'CraftScanRecipeConfigPanel',
            CraftScanConfigPage.Options,
            'CraftScanRecipeConfigPanelTemplate'
        )
    end
    panel:Init(configInfo)
    return panel
end

CraftScanRecipeConfigPanelMixin = {}

function CraftScanRecipeConfigPanelMixin:Init(configInfo)
    self.configInfo = configInfo
    self.Left:Hide()
    self.Right:Hide()

    self.tabGroup = CreateTabGroup()

    self:SetupRecipeIcon()

    -- We present a different config page based on the scan state. For disabled
    -- items, we show only an enable button. For enabled items, we show a disable
    -- button. For pending items we show both an enable and disable button. For
    -- unlearned items, we don't show a button, but do allow pre-configuration.
    if self.configInfo.recipeConfig.scan_state == CraftScan.CONST.RECIPE_STATES.SCANNING_ON then
        self.EnableScanning:Hide()
        self:SetupButton(
            self.DisableScanning,
            CraftScan.CONST.RECIPE_STATES.SCANNING_OFF,
            'disable_scan_state',
            'BOTTOMRIGHT',
            -20,
            00
        )
        -- Fall through to show all other config options.
    elseif
        self.configInfo.recipeConfig.scan_state == CraftScan.CONST.RECIPE_STATES.SCANNING_OFF
    then
        self.DisableScanning:Hide()
        self:SetupButton(
            self.EnableScanning,
            CraftScan.CONST.RECIPE_STATES.SCANNING_ON,
            'enable_scan_state',
            'TOPLEFT',
            10,
            -120
        )
        return -- Don't show other configuration options
    elseif
        self.configInfo.recipeConfig.scan_state == CraftScan.CONST.RECIPE_STATES.PENDING_REVIEW
    then
        self:SetupButton(
            self.EnableScanning,
            CraftScan.CONST.RECIPE_STATES.SCANNING_ON,
            'enable_scan_state',
            'TOPLEFT',
            10,
            -120
        )
        self:SetupButton(
            self.DisableScanning,
            CraftScan.CONST.RECIPE_STATES.SCANNING_OFF,
            'disable_scan_state',
            'TOPLEFT',
            10,
            -148
        )
        return -- Don't show other configuration options
    elseif self.configInfo.recipeConfig.scan_state == CraftScan.CONST.RECIPE_STATES.UNLEARNED then
        self.EnableScanning:Hide()
        self.DisableScanning:Hide()
        -- Fall through to show all other config options.
    end

    self.defaults = {
        keywords = '',
        secondary_keywords = '',
        commission = '',
        greeting = '',
        omit_general = false,
        omit_profession = false,
    }

    CraftScan.SetupTextInput(self, self.Left.Keywords, 'item.keywords')
    CraftScan.SetupTextInput(self, self.Left.SecondaryKeywords, 'item.secondary_keywords')
    CraftScan.SetupTextInput(self, self.Left.Commission, 'item.commission')

    local CHECK_BOX_WIDTH = 240
    CraftScan.SetupTextInput(self, self.Right.Greeting, 'item.greeting')
    CraftScan.SetupCheckBox(self, self.Right.OmitGeneral, 'item.omit_general', CHECK_BOX_WIDTH)
    CraftScan.SetupCheckBox(
        self,
        self.Right.OmitProfession,
        'item.omit_profession',
        CHECK_BOX_WIDTH
    )

    self.Left:Show()
    self.Right:Show()
end

function CraftScanRecipeConfigPanelMixin:SetupButton(button, result_state, keyword, point, x, y)
    button:ClearAllPoints()
    button:SetPoint(point, self, point, x, y)
    CraftScan.SetupButton(button, keyword, function()
        self.configInfo.recipeConfig.scan_state = result_state
        CraftScan.Config.OnRecipeScanStateChange(self.configInfo)
    end)
    button:Show()
end

function CraftScanRecipeConfigPanelMixin:SetupRecipeIcon()
    local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(self.configInfo.recipeID)

    local quality = 0
    if outputItemInfo.hyperlink then
        local item = Item:CreateFromItemLink(outputItemInfo.hyperlink)
        self.item = item
        quality = item:GetItemQuality()

        text = WrapTextInColor(item:GetItemName(), item:GetItemQualityColor().color)

        self.IconLabel:ClearAllPoints()
        self.IconLabel:SetPoint('LEFT', self.RecipeIcon, 'RIGHT', 14, 17)

        self.IconLabel:SetHeight(200)
        self.IconLabel:SetText(text)
        self.IconLabel:SetWidth(500)
        self.IconLabel:SetHeight(self.IconLabel:GetStringHeight())

        self.IconSubLabel:SetText(
            CraftScan.RecipeStateName(self.configInfo.recipeConfig.scan_state)
        )
    end

    self.RecipeIcon.Icon:SetTexture(outputItemInfo.icon)
    self.RecipeIcon:SetScript('OnEnter', function()
        GameTooltip:SetOwner(self.RecipeIcon, 'ANCHOR_RIGHT')
        GameTooltip:SetRecipeResultItem(self.configInfo.recipeID)
    end)
    self.RecipeIcon:SetScript('OnLeave', function()
        GameTooltip_Hide()
    end)

    SetItemButtonQuality(self.RecipeIcon, quality, outputItemInfo.hyperlink)
end

local function KeywordToConfigKey(keyword)
    -- Our config uses short words, but we need longer keywords to distinguish
    -- between localization tags (e.g. prof.greeting vs item.greeting)
    return keyword:sub(6)
end

function CraftScanRecipeConfigPanelMixin:GetConfigValue(keyword)
    return self.configInfo.recipeConfig[KeywordToConfigKey(keyword)]
        or self.defaults[KeywordToConfigKey(keyword)]
end

function CraftScanRecipeConfigPanelMixin:UpdateConfigValue(keyword, value)
    self.configInfo.recipeConfig[KeywordToConfigKey(keyword)] = value
end

function CraftScanRecipeConfigPanelMixin:OnConfigChange()
    CraftScan.Config.OnConfigChange(self.configInfo)
end

function CraftScanRecipeConfigPanelMixin:Validate(keyword, value, reporter) end

function CraftScanRecipeConfigPanelMixin:GetInstructions(keyword)
    local function Wrap(text)
        return '{' .. text .. '}'
    end

    if keyword == 'item.keywords' then
        -- Use the item slot as a very generic terms for each item category
        -- "Two-Hand", "Boots", ect. We default create a substitution tag for
        -- each of these to encourage tag use.
        local slot = _G[self.item:GetInventoryTypeName()]
        local result = ''
        if slot and slot ~= '' then
            result = result .. Wrap(_G[self.item:GetInventoryTypeName()])
        end

        -- The last word in the item is usually what people might say in chat.
        -- The item is "Wonderous awesome magical boots", we grab 'boots' and
        -- use that as a default suggestion.
        local last = self.item:GetItemName():match('([^%s]+)$')
        if result ~= '' then
            result = result .. ', '
        end
        result = result .. last
        return result
    elseif keyword == 'item.secondary_keywords' then
        local quality = self.item:GetItemQuality()
        if quality == Enum.ItemQuality.Uncommon then
            -- The only blue craft-able items lately are the PVP ones, so we
            -- override 'uncommon' to mean PVP by default. chatgpt says 'pvp' is
            -- universal, so we don't bother localizing.
            return Wrap('pvp')
        elseif quality == Enum.ItemQuality.Rare then
            -- There must be a global mapping somewhere, but the only one I can
            -- find depends on opening the AH first, and we only need rare and
            -- epic for the usual blue/spark recipes each expansion.
            return Wrap(ITEM_QUALITY3_DESC)
        elseif quality == Enum.ItemQuality.Epic then
            return Wrap(ITEM_QUALITY4_DESC)
        end
    elseif keyword == 'item.commission' then
        return Wrap(L('Commission'))
    end
    return nil
end

function CraftScanRecipeConfigPanelMixin:GetDisplayValue(keyword)
    return CraftScan.Config.SubstituteTags(self:GetConfigValue(keyword))
end

function CraftScanRecipeConfigPanelMixin:InstructionsAccepted(tag)
    CraftScan.Config.AutoCreateFromDefault(tag)
end

function CraftScanRecipeConfigPanelMixin:Validate(keyword, value, reporter)
    CraftScan.Config.PopulateSubstitutionTagTooltip(value, reporter)
end
