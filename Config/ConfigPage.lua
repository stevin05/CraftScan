local CraftScan = select(2, ...)

local C = CraftScan.CONST
local LID = C.TEXT
local function L(id)
    return CraftScan.LOCAL:GetText(id)
end

local AceConfig = LibStub('AceConfig-3.0')
local AceConfigCmd = LibStub('AceConfigCmd-3.0') -- handles slash -> options mapping

local configOption = {
    type = 'execute',
    name = 'Config',
    desc = 'Toggle the config page',
    func = function()
        CraftScanConfigPage:ToggleVisibility()
    end,
}

local ordersOption = {
    type = 'execute',
    name = 'Orders',
    desc = 'Toggle the order page',
    func = function()
        if CraftScanConfigPage:IsShown() then
            CraftScanConfigPage:Hide()
        else
            CraftScanConfigPage:Show()
        end
    end,
}

local debugOption = {
    type = 'toggle',
    name = 'Debug',
    desc = 'Toggle debug mode (requires DevTool)',
    get = function()
        return CraftScan.Debug.IsEnabled()
    end,
    set = function(_, value)
        CraftScan.Debug.Enable(value)
    end,
}

-- Define your slash commands and subcommands
local options = {
    type = 'group',
    name = 'CraftScan',
    args = {
        config = configOption,
        c = configOption,
        orders = ordersOption,
        o = ordersOption,
        debug = debugOption,
        d = debugOption,
    },
}

-- Register the options table
AceConfig:RegisterOptionsTable('CraftScan', options)

-- Register the slash command to use the AceConfigCmd handler
AceConfigCmd:CreateChatCommand('craftscan', 'CraftScan')
AceConfigCmd:CreateChatCommand('cs', 'CraftScan')

table.insert(UISpecialFrames, 'CraftScanConfigPage')

local function IsEmptyNode(node)
    for _, child in ipairs(node:GetNodes()) do
        if child.data and (child.data.configInfo or child.data.headerInfo) then
            return false
        end
    end
    return true
end

local function EraseEmptyParents(node)
    if IsEmptyNode(node) then
        local parent = node:GetParent()
        CraftScan.Debug.Print(node, 'removed')
        parent:Remove(node)
        CraftScan.Debug.Print(node.data.parentKey, 'parentKey')
        parent[node.data.parentKey] = nil
        EraseEmptyParents(parent)
    end
end

local function IsConcentrationDependent(recipeConfig)
    return C.RECIPE_STATES.SCANNING_ON == recipeConfig.scan_state
        and recipeConfig.required_concentration
        and recipeConfig.required_concentration ~= 0
end

local function HasRequiredConcentration(recipeConfig, profConfig)
    if not profConfig.concentration then
        return true -- Don't know concentration, so err on the side of scanning.
    end

    local concentration = CraftScan.ConcentrationData:Deserialize(profConfig.concentration)
    return recipeConfig.required_concentration <= concentration:GetCurrentAmount()
end

local function ConcentrationScanningSuffix(r, g, state)
    return ' - ' .. CreateColor(r, g, 0):WrapTextInColorCode(L(C.RECIPE_STATE_NAMES[state]))
end

local function ConcentrationScanningOnText()
    return L('Concentration Dependent')
        .. ConcentrationScanningSuffix(0, 1, C.RECIPE_STATES.SCANNING_ON)
end

local function ConcentrationScanningOffText()
    return L('Concentration Dependent')
        .. ConcentrationScanningSuffix(1, 0, C.RECIPE_STATES.SCANNING_OFF)
end

function CraftScan.RecipeStateName(recipeConfig, profConfig)
    if IsConcentrationDependent(recipeConfig) then
        if HasRequiredConcentration(recipeConfig, profConfig) then
            return ConcentrationScanningOnText()
        end
        return ConcentrationScanningOffText()
    end
    return L(C.RECIPE_STATE_NAMES[recipeConfig.scan_state])
end

local function GetScanStateDisplayOrder(recipeConfig, profConfig)
    local state = recipeConfig.scan_state
    local states = CraftScan.CONST.RECIPE_STATES
    if IsConcentrationDependent(recipeConfig) then
        if HasRequiredConcentration(recipeConfig, profConfig) then
            return 2
        end
        return 3
    elseif states.PENDING_REVIEW == state then
        return 1
    elseif states.SCANNING_ON == state then
        return 4
    elseif states.SCANNING_OFF == state then
        return 5
    elseif states.UNLEARNED == state then
        return 6
    end
end

function CraftScan.SaveConcentrationData()
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    if C_ProfSpecs.SkillLineHasSpecialization(skillLineID) then
        local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID)
        local concentrationData = CraftScan.ConcentrationData(currencyID)
        local char = CraftScan.GetPlayerName(true)
        local profConfig = CraftScan.DB.characters[char].professions[skillLineID]
        profConfig.concentration = concentrationData:Serialize()
    end
end

local function MakeProfessionNodeFactory(root)
    local db = {}

    local function SetSortComparator(node, comparator)
        local affectChildren = false
        local skipSort = false

        local function OrderComparatorWrapper(lhs, rhs)
            local lhsOrder = lhs.data.order
            local rhsOrder = rhs.data.order
            if lhsOrder ~= rhsOrder then
                return lhsOrder < rhsOrder
            end

            if comparator then
                return comparator(lhs, rhs)
            end
            return false
        end

        node:SetSortComparator(OrderComparatorWrapper, affectChildren, skipSort)
    end

    local function SortByItemLabel(lhs, rhs)
        return strcmputf8i(lhs.data.configInfo.label, rhs.data.configInfo.label) < 0
    end

    local function SortByHeaderLabel(lhs, rhs)
        return strcmputf8i(lhs.data.headerInfo.label, rhs.data.headerInfo.label) < 0
    end

    local function GetProfessionNode(char, profID, profConfig)
        local isCurrent = CraftScan.Utils.IsCurrentExpansion(profID)
        if not db[isCurrent] then
            local expansionNode = root:Insert({
                order = 0,
                headerInfo = {
                    label = L(isCurrent and 'Crafters' or 'Legacy Crafters'),
                    startCollapsed = not isCurrent,
                },
            })
            SetSortComparator(expansionNode, SortByHeaderLabel)
            db[isCurrent] = expansionNode
        end

        if not db[isCurrent][char] then
            local GetCrafterNameColor = function()
                local color = CraftScan.GetCrafterNameColor(char)
                if color.r ~= 0 then
                    -- We color the current character green. Usually the
                    -- others are white, but since the rest of the menu
                    -- colors entries yellow, we swap to that.
                    return CreateColor(GameFontNormal_NoShadow:GetTextColor())
                end
                return color
            end
            local charNode = db[isCurrent]:Insert({
                parentKey = char,
                order = 0,
                headerInfo = {
                    GetLabelColor = GetCrafterNameColor,
                    label = CraftScan.NameAndRealmToName(char, true),
                },
            })

            SetSortComparator(charNode, SortByHeaderLabel)
            charNode:Insert({ order = 1, bottomPadding = true })
            db[isCurrent][char] = charNode
        end

        if not db[isCurrent][char][profID] then
            local professionName = CraftScan.Utils.ProfessionNameByID(profConfig.parentProfID)
            if not isCurrent then
                professionName = CraftScan.Utils.ProfessionNameByID(profID)
            end
            local GetProfessionNameColor = function()
                return CraftScan.Utils.ProfessionColor(profConfig.parentProfID)
            end

            local profNode = db[isCurrent][char]:Insert({
                parentKey = profID,
                order = 0,
                headerInfo = {
                    -- TODO Add a 'refresh' style button to read in the profession on the current character.
                    GetLabelColor = GetProfessionNameColor,
                    label = professionName,
                    startCollapsed = true,
                },
                configInfo = {
                    char = char,
                    profID = profID,
                    profConfig = profConfig,
                    parentProfID = profConfig.parentProfID,
                    ppConfig = CraftScan.DB.characters[char].parent_professions[profConfig.parentProfID],
                    LoadOptions = CraftScan.Config.LoadProfessionConfigOptions,
                },
            })
            SetSortComparator(profNode)
            -- Scan_state is set as order, so 1-4 for pending/on/off/unlearned.
            -- Add some bottom padding by setting order higher than that - 10.
            profNode:Insert({ order = 10, bottomPadding = true })
            db[isCurrent][char][profID] = profNode
        end
        return db[isCurrent][char][profID]
    end

    local function GetRecipeParentNode(char, profID, profConfig, recipeConfig)
        local profNode = GetProfessionNode(char, profID, profConfig)
        local recipeScanState = GetScanStateDisplayOrder(recipeConfig, profConfig)
        if not profNode[recipeScanState] then
            local sectionNode = profNode:Insert({
                parentKey = recipeScanState,
                order = recipeScanState,
                headerInfo = {
                    label = CraftScan.RecipeStateName(recipeConfig, profConfig),
                    startCollapsed = true,
                },
            })
            SetSortComparator(sectionNode, SortByItemLabel)
            sectionNode:Insert({ order = 1, bottomPadding = true })
            profNode[recipeScanState] = sectionNode
        end

        return profNode[recipeScanState]
    end

    local function ExpandToNode(root, configInfo)
        local char = configInfo.char
        local profID = configInfo.profID
        local recipeConfig = configInfo.recipeConfig

        local isCurrent = CraftScan.Utils.IsCurrentExpansion(profID)
        local recipeScanState = GetScanStateDisplayOrder(recipeConfig, configInfo.profConfig)

        -- Expand the root
        root:SetCollapsed(
            false,
            TreeDataProviderConstants.RetainChildCollapse,
            TreeDataProviderConstants.SkipInvalidation
        )

        -- And then expand down the tree until we've expanded the exact node
        -- containing the recipe.
        local node = db
        for _, key in ipairs({ isCurrent, char, profID, recipeScanState }) do
            node = node[key]
            node:SetCollapsed(
                false,
                TreeDataProviderConstants.RetainChildCollapse,
                TreeDataProviderConstants.SkipInvalidation
            )
        end
    end

    local function InsertRecipeNode(parentNode, char, profID, profConfig, recipeInfo, recipeConfig)
        parentNode:Insert({
            order = 0,
            configInfo = {
                label = recipeInfo.name,
                char = char,
                profID = profID,
                profConfig = profConfig,
                recipeID = recipeInfo.recipeID,
                recipeConfig = recipeConfig,
                LoadOptions = CraftScan.Config.LoadRecipeConfigOptions,
            },
        })
    end

    local function PopulateProfessionNode(char, profID, profConfig, existingRecipeIDs)
        for recipeID, recipeConfig in pairs(profConfig.recipes) do
            if not existingRecipeIDs or not existingRecipeIDs[recipeID] then
                local parentNode = GetRecipeParentNode(char, profID, profConfig, recipeConfig)
                local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                InsertRecipeNode(parentNode, char, profID, profConfig, recipeInfo, recipeConfig)
            end
        end
    end

    local function UpdateProfessionNode(char, profID, profConfig)
        -- This is all  overkill. We should simply wipe out the tree and reload
        -- from the current state, but I want to play with the tree update
        -- functions and try to get them right.
        --
        -- We might have learned recipes that were previously marked as
        -- unlearned, so we need to move those to the correct spot. We might
        -- have also read in completely new recipes that didn't exist on last
        -- login, so check for those as well.
        --
        -- Create a list of nodes that need to be moved and a hash of existing
        -- nodes so we don't add duplicates.
        local profNode = GetProfessionNode(char, profID, profConfig)
        local scanStateChanges = {}
        local existingRecipeIDs = {}
        for _, scanStateNode in ipairs(profNode:GetNodes()) do
            for _, recipeNode in ipairs(scanStateNode:GetNodes()) do
                if recipeNode.data.configInfo then
                    local configInfo = recipeNode.data.configInfo
                    if
                        GetScanStateDisplayOrder(configInfo.recipeConfig, configInfo.profConfig)
                        ~= scanStateNode.data.order
                    then
                        table.insert(scanStateChanges, recipeNode.data.configInfo)
                    end
                    existingRecipeIDs[configInfo.recipeID] = true
                end
            end
        end

        -- Move any nodes in the wrong place.
        for _, configInfo in ipairs(scanStateChanges) do
            local skipReload = true
            CraftScan.Config.OnRecipeScanStateChange(configInfo, skipReload)
        end

        --  At this point, we know all nodes are in the correct spot, now we
        --  just need to insert any new recipes that weren't present the last
        --  time the profession was loaded.
        PopulateProfessionNode(char, profID, profConfig, existingRecipeIDs)

        profNode:Invalidate()
    end

    local function RemoveMissingProfessionNodes(char)
        local profConfigs = CraftScan.DB.characters[char].professions

        for _, isCurrent in ipairs({ true, false }) do
            local toBeRemoved = {}
            local charNode = db[isCurrent] and db[isCurrent][char]
            if charNode then
                for _, profNode in ipairs(charNode:GetNodes()) do
                    if
                        profNode.data.configInfo
                        and not profConfigs[profNode.data.configInfo.profID]
                    then
                        table.insert(toBeRemoved, profNode)
                    end
                end
            end
            for _, profNode in ipairs(toBeRemoved) do
                charNode:Remove(profNode)
                charNode[profNode.data.configInfo.profID] = nil
                EraseEmptyParents(charNode)
            end
        end

        -- Minor bug - we leave the character node even if it's empty. Not going
        -- to worry about it.
    end

    return GetRecipeParentNode,
        PopulateProfessionNode,
        UpdateProfessionNode,
        RemoveMissingProfessionNodes,
        ExpandToNode
end

CraftScanConfigPageMixin = {}

function CraftScanConfigPageMixin:OnShow()
    local icon = CraftScan.Utils.GetCurrentProfessionIcon()
    self:SetPortraitToAsset(icon or 4620670)
end

function CraftScanConfigPageMixin:ToggleVisibility()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function CraftScanConfigPageMixin:SelectRecipe(char, profID, recipeID)
    local menu = self.Menu

    -- Find the tree node containing what we need.
    local node = self.Menu.dataProvider:FindElementDataByPredicate(function(node)
        local data = node:GetData()
        return data.configInfo
            and data.configInfo.recipeID
            and data.configInfo.recipeID == recipeID
            and data.configInfo.char == char
            and data.configInfo.profID == profID
    end, TreeDataProviderConstants.IncludeCollapsed)

    if node then
        menu.ExpandToNode(menu.dataProvider:GetRootNode(), node:GetData().configInfo)
        menu.selectionBehavior:SelectElementData(node)
        menu.dataProvider:Invalidate()
        menu.ScrollBox:ScrollToElementData(node)
    end
end

function CraftScanConfigPageMixin:OnLoad()
    CraftScan.Frames.ConfigPage = self

    self:SetMovable(true)
    self:EnableMouse(true)
    self:RegisterForDrag('LeftButton')
    self:SetScript('OnDragStart', self.StartMoving)
    self:SetScript('OnDragStop', self.StopMovingOrSizing)

    self:SetTitle(L('CraftScan'))

    self:SetUserPlaced(true)
end

CraftScanConfigMenuMixin = {}

function CraftScanConfigMenuMixin:OnLoad()
    local indent = 10
    local padLeft = 0
    local pad = 5
    local spacing = 1
    local view = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing)

    view:SetElementFactory(function(factory, node)
        local elementData = node:GetData()

        if elementData.headerInfo then
            local function Initializer(button, node)
                button:Init(node)

                button:SetScript('OnClick', function(button, buttonName)
                    node:ToggleCollapsed()
                    button:SetCollapseState(node:IsCollapsed())

                    if elementData.configInfo then
                        self.selectionBehavior:Select(button)
                    end
                end)

                if elementData.configInfo then
                    local selected = self.selectionBehavior:IsElementDataSelected(node)
                    button:SetSelected(selected)
                end
            end

            factory('CraftScanConfigMenuHeaderTemplate', Initializer)
        elseif elementData.configInfo then
            local function Initializer(button, node)
                button:Init(node)
                elementData.configInfo.treeNode = node
                button:SetLabelFontColors(button:GetLabelColor())

                button:SetScript('OnClick', function(button, buttonName, down)
                    self.selectionBehavior:Select(button)
                end)

                local selected = self.selectionBehavior:IsElementDataSelected(node)
                button:SetSelected(selected)
            end

            factory('CraftScanConfigMenuItemTemplate', Initializer)
        elseif elementData.recipeInfo then
        else
            factory('Frame')
        end
    end)

    view:SetElementExtentCalculator(function(dataIndex, node)
        local elementData = node:GetData()
        local baseElementHeight = 20
        local categoryPadding = 5

        if elementData.configInfo then
            return baseElementHeight
        end

        if elementData.headerInfo then
            return baseElementHeight + categoryPadding
        end

        if elementData.dividerHeight then
            return elementData.dividerHeight
        end

        if elementData.topPadding then
            return 1
        end

        if elementData.bottomPadding then
            return 10
        end
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil, nil)

    local function OnSelectionChanged(o, elementData, selected)
        local button = self.ScrollBox:FindFrame(elementData)
        if button then
            button:SetSelected(selected)
        end

        if selected then
            local configInfo = elementData.data.configInfo
            if configInfo then
                if self.activeOptions then
                    self.activeOptions:Hide()
                end
                CraftScanConfigPage.Options:Hide()

                self.activeOptions = configInfo.LoadOptions(configInfo)
                self.activeOptions:Show()
                --CraftScanConfigPage.Options:SetScrollChild(self.activeOptions)
                CraftScanConfigPage.Options:Show()
            end
        end
    end

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox)
    self.selectionBehavior:RegisterCallback(
        SelectionBehaviorMixin.Event.OnSelectionChanged,
        OnSelectionChanged,
        self
    )

    -- Some legacy code in RecipeSchematicMenu reads in full professions the
    -- first time a profession window is open. There is a
    -- 'TRADESKILL_LIST_UPDATE' event, but it can change constantly based
    -- on sorting while the profession window is open, so don't want to rely on
    -- it. This event should allow us to move recipes from Unlearned over to
    -- Pending as they are learned.
    self:RegisterEvent('NEW_RECIPE_LEARNED')
    self:RegisterEvent('TRADE_SKILL_ITEM_CRAFTED_RESULT')
    self:SetScript('OnEvent', function(self, event, ...)
        if event == 'NEW_RECIPE_LEARNED' then
            local recipeID, recipeLevel, baseRecipeID = ...
            local profInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
            local char = CraftScan.GetPlayerName(true)
            local profConfig = CraftScan.DB.characters[char].professions[profInfo.professionID]
            if profConfig then
                local recipeConfig =
                    CraftScan.DB.characters[char].professions[profInfo.professionID].recipes[recipeID]
                recipeConfig.scan_state = CraftScan.CONST.RECIPE_STATES.PENDING_REVIEW
                CraftScan.Config.UpdateProfession(char, profInfo.professionID, profConfig)

                -- else, just trained a new profession and need to open it to ScanAllRecipes
            end
        elseif event == 'TRADE_SKILL_ITEM_CRAFTED_RESULT' then
            local resultData = ...
            if resultData.concentrationSpent and resultData.concentrationSpent ~= 0 then
                CraftScan.SaveConcentrationData()
            end
        end
    end)
end

local function OnConfigChange(configInfo)
    -- We used to attempt to keep a clean database here and only reference
    -- scanning enabled recipes. With the new cross-character functionality, we
    -- store all recipes of all known professions all the time so that we can
    -- easily pre-configure items we will learn and reference items from other
    -- crafters.
    if configInfo then
        CraftScanComm:ShareCharacterModification(
            configInfo.char,
            configInfo.profConfig.parentProfID
        )
    end

    -- TODO - Need to replicate tags

    CraftScan.Scanner.LoadConfig()
end

CraftScan.Config = {}
CraftScan.Config.OnConfigChange = OnConfigChange

local menuInitialized = false
function CraftScanConfigMenuMixin:OnShow()
    if menuInitialized then
        return
    end
    menuInitialized = true

    local dataProvider = CreateTreeDataProvider()
    self.dataProvider = dataProvider

    local node = dataProvider:GetRootNode()

    node:Insert({
        configInfo = {
            label = L('General'),
            LoadOptions = CraftScan.Config.LoadGlobalConfigOptions,
        },
    })

    node:Insert({
        configInfo = {
            label = L('dialog.tag.header'),
            LoadOptions = CraftScan.Config.LoadSubstitutionTagConfigOptions,
        },
    })

    node:Insert({ bottomPadding = true })

    self.GetRecipeParentNode, self.PopulateProfessionNode, self.UpdateProfessionNode, self.RemoveMissingProfessionNodes, self.ExpandToNode =
        MakeProfessionNodeFactory(node)
    for char, charConfig in pairs(CraftScan.DB.characters) do
        for profID, profConfig in pairs(charConfig.professions) do
            self.PopulateProfessionNode(char, profID, profConfig)
        end
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    -- Processing startCollapsed in headerInfo's Init does not work, but this seems to.
    dataProvider:ForEach(function(node)
        local elementData = node:GetData()
        if elementData.headerInfo and elementData.headerInfo.startCollapsed then
            node:SetCollapsed(true)

            -- The button is sometimes not initialized yet? Maybe elements that
            -- haven't been rendered haven't been init'ed yet?
            if elementData.headerInfo.button then
                elementData.headerInfo.button:SetCollapseState(true)
            end
        end
    end, true)
end

CraftScanConfigMenuHeaderMixin = {}

function CraftScanConfigMenuHeaderMixin:Init(node)
    local elementData = node:GetData()
    local headerInfo = elementData.headerInfo
    headerInfo.button = self
    if headerInfo.GetLabelColor then
        self.GetLabelColor = headerInfo.GetLabelColor
    else
        self.GetLabelColor = self.GetDefaultLabelColor
    end
    self.selectable = elementData.configInfo and true or false
    self.Label:SetText(headerInfo.label)
    self:SetLabelFontColors(self:GetLabelColor())

    self:SetCollapseState(node:IsCollapsed())
    self:SetSelected(false)
end

function CraftScanConfigMenuHeaderMixin:SetLabelFontColors(color)
    self.Label:SetVertexColor(color:GetRGB())
end

function CraftScanConfigMenuHeaderMixin:GetDefaultLabelColor()
    return CreateColor(GameFontNormal_NoShadow:GetTextColor())
end

function CraftScanConfigMenuHeaderMixin:OnEnter()
    self:SetLabelFontColors(HIGHLIGHT_FONT_COLOR)
    if not self.selectable then
        self.HighlightOverlay:SetShown(false)
    end
end

function CraftScanConfigMenuHeaderMixin:OnLeave()
    self:SetLabelFontColors(self:GetLabelColor())
end

function CraftScanConfigMenuHeaderMixin:SetCollapseState(collapsed)
    local atlas = collapsed and 'Professions-recipe-header-expand'
        or 'Professions-recipe-header-collapse'
    self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
    self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
end

function CraftScanConfigMenuHeaderMixin:SetSelected(selected)
    self.SelectedOverlay:SetShown(selected)
    self.HighlightOverlay:SetShown(not selected)
end

CraftScanConfigMenuItemMixin = {}

function CraftScanConfigMenuItemMixin:Init(node)
    local elementData = node:GetData()
    local configInfo = elementData.configInfo
    self.Label:SetText(configInfo.label)

    if configInfo.recipeConfig then
        self.enabled = configInfo.recipeConfig.scan_state ~= CraftScan.CONST.RECIPE_STATES.UNLEARNED
    else
        self.enabled = true
    end
end

function CraftScanConfigMenuItemMixin:SetLabelFontColors(color)
    self.Label:SetVertexColor(color:GetRGB())
end

function CraftScanConfigMenuItemMixin:OnEnter()
    self:SetLabelFontColors(HIGHLIGHT_FONT_COLOR)
end

function CraftScanConfigMenuItemMixin:GetLabelColor()
    if self.data and self.data.headerInfo and self.data.headerInfo.GetLabelColor then
        return self.data.headerInfo.GetLabelColor()
    end
    return self.enabled and PROFESSION_RECIPE_COLOR or DISABLED_FONT_COLOR
end

function CraftScanConfigMenuItemMixin:OnLeave()
    self:SetLabelFontColors(self:GetLabelColor())
end

function CraftScanConfigMenuItemMixin:SetSelected(selected)
    self.SelectedOverlay:SetShown(selected)
    self.HighlightOverlay:SetShown(not selected)
end

function CraftScan.Config.OnRecipeScanStateChange(configInfo, skipReload)
    local menu = CraftScanConfigPage.Menu
    local newParent = menu.GetRecipeParentNode(
        configInfo.char,
        configInfo.profID,
        configInfo.profConfig,
        configInfo.recipeConfig
    )
    local oldParent = configInfo.treeNode:GetParent()
    newParent:MoveNode(configInfo.treeNode)
    EraseEmptyParents(oldParent)

    if not skipReload then
        -- TreeNodeMixin:InsertNode does invalidate prior to sort, so the node shows up
        -- at the end of the list. Fire off another Invalidate() so it shows in the
        -- right spot immediately.
        newParent:Invalidate()

        -- Update the Options panel based on the new state.
        configInfo.LoadOptions(configInfo)
    end
end

function CraftScan.Config.UpdateProfession(char, profID, profConfig)
    local menu = CraftScanConfigPage.Menu
    if menu.UpdateProfessionNode then
        menu.UpdateProfessionNode(char, profID, profConfig)
    end
end

function CraftScan.Config.RemoveMissingProfessionNodes(char)
    local menu = CraftScanConfigPage.Menu
    if menu.RemoveMissingProfessionNodes then
        menu.RemoveMissingProfessionNodes(char)
        if menu.activeOptions then
            -- Not perfect. There's no guarantee the user has a config page
            -- within the profession open, but this ensures we don't leave a
            -- dangling config page referencing a deleted recipeConfig.
            menu.activeOptions:Hide()
        end
    end
end
