local CraftScan = select(2, ...)

CraftScanCrafterOrderListElementMixin = CreateFromMixins(TableBuilderRowMixin);

CraftScan.LIVE = {}
CraftScan.LIVE.customers = {}

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

function CraftScanCrafterOrderListElementMixin:Init(elementData)
    self.order = elementData.order
    -- self.browseType = elementData.browseType;
    self.pageFrame = elementData.pageFrame;
    self.contextMenu = elementData.contextMenu;
end

local function removeOrder(orders, order)
    local customerInfo = CraftScan.OrderToCustomerInfo(order)
    local response = customerInfo.responses[order.responseID]
    local orderID = CraftScan.OrderToOrderID(order)
    local order = orders[orderID]

    -- Wipe out any less granular reponses related to this one
    local response = customerInfo.responses[order.responseID];
    if not response then
        -- A less_granular child that was already wiped out. Nothing left to do.
        return
    end

    if response.less_granular then
        for _, child in ipairs(response.less_granular) do
            customerInfo.responses[child] = nil
        end
    end
    customerInfo.responses[order.responseID] = nil

    if not next(customerInfo.responses) then
        -- No more orders with this customer, so close out the frames related to them.
        local liveCustomerInfo = CraftScan.LIVE.customers[order.customerName]
        if liveCustomerInfo then
            if liveCustomerInfo.chatFrame then
                FCF_Close(liveCustomerInfo.chatFrame)
                liveCustomerInfo.chatFrame = nil
            end
            CraftScan.LIVE.customers[order.customerName] = nil
        end
        CraftScan.DB.customers[order.customerName] = nil
    end

    -- Remove ourselves from the global list of displayed orders
    orders[orderID] = nil
end

function CraftScan.GreetCustomer(button, order)
    CraftScanScannerMenu:ClearAlert(order)

    local response = CraftScan.OrderToResponse(order)
    if button == "LeftButton" then
        if not response.greeting_sent then
            CraftScan.Utils.SendResponses(response.message, order.customerName)
            response.greeting_sent = true
            -- TODO: More efficient way to update the display?
            CraftScanCraftingOrderPage:ShowGeneric()
        else
            -- After sending the initial greeting, subsequent clicks open a chat with the customer.
            ChatFrame_SendTell(order.customerName, DEFAULT_CHAT_FRAME)
        end
    elseif button == "RightButton" then
        removeOrder(CraftScan.DB.listed_orders, order)
        CraftScanCraftingOrderPage:ShowGeneric()
    end
end

function CraftScanCrafterOrderListElementMixin:OnClick(button)
    CraftScan.GreetCustomer(button, self.order)
end

function CraftScanCrafterOrderListElementMixin:OnLineEnter()
    self.HighlightTexture:Show();

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

    local response = CraftScan.OrderToResponse(self.order)
    if response.recipeID then
        local reagents = {};
        local qualityIDs = C_TradeSkillUI.GetQualitiesForRecipe(response.recipeID);
        local qualityIdx = #qualityIDs; -- self.option.minQuality or 1;
        GameTooltip:SetRecipeResultItem(response.recipeID, reagents, nil, nil, qualityIDs and qualityIDs[qualityIdx]);
    end
end

function CraftScanCrafterOrderListElementMixin:OnLineLeave()
    self.HighlightTexture:Hide();

    GameTooltip:Hide();
    ResetCursor();
end

CraftScanCraftingOrderPageMixin = {} --CreateFromMixins(ProfessionsRecipeListPanelMixin);

function CraftScanCraftingOrderPageMixin:InitOrderListTable()
    local pad = 5;
    local spacing = 1;
    local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
    view:SetElementInitializer("CraftScanCrafterOrderListElementTemplate", function(button, elementData)
        button:Init(elementData);
    end);
    ScrollUtil.InitScrollBoxListWithScrollBar(self.BrowseFrame.OrderList.ScrollBox,
        self.BrowseFrame.OrderList.ScrollBar, view);

    UIDropDownMenu_SetInitializeFunction(self.BrowseFrame.OrderList.ContextMenu,
        GenerateClosure(self.InitContextMenu, self));
    UIDropDownMenu_SetDisplayMode(self.BrowseFrame.OrderList.ContextMenu, "MENU");
end

--function CraftScanCraftingOrderPageMixin:InitButtons()
-- self.BrowseFrame.SearchButton:SetScript("OnClick", function()
-- local selectedRecipe = nil;
-- local searchFavorites = false;
-- local initialNonPublicSearch = false;
-- self:RequestOrders(selectedRecipe, searchFavorites, initialNonPublicSearch);
-- end);

-- self.BrowseFrame.BackButton:SetScript("OnClick", function()
-- if self.lastBucketRequest then
-- self:ResetSortOrder();
-- self:SendOrderRequest(self.lastBucketRequest);
-- end
-- end);
--end

function CraftScanCraftingOrderPageMixin:UpdateFilterResetVisibility()
    self.BrowseFrame.CrafterList.FilterButton.ResetButton:SetShown(
        not CraftScan.IsUsingDefaultFilters(ignoreSkillLine));
end

function CraftScanCraftingOrderPageMixin:GetDesiredPageWidth()
    return 1105;
end

function CraftScanCraftingOrderPageMixin:OnLoad()
    self:ResetSortOrder() -- self.InitButtons()
    self:InitOrderListTable()
    self:SetupOrderListTable()
end

function CraftScanCraftingOrderPageMixin:OnShow()
    CraftScanScannerMenu:ClearPulses()
    self:ShowGeneric()

    local profession = CraftScan.Utils.CurrentProfession();
    self:SetPortraitToAsset(profession and profession.icon or 4620670);
end

function CraftScanCraftingOrderPageMixin:OnHide()
end

local function getOrderName(response)
    if response.itemID then
        local item = Item:CreateFromItemID(response.itemID);
        return item:GetItemName()
    else
        return response.professionName;
    end
end

local function ApplySortOrder(sortOrder, lhsOrder, rhsOrder)
    -- CraftScan.ChatOrderSortOrder = EnumUtil.MakeEnum("CustomerName", "CrafterName", "ProfessionName", "ItemName", "Interaction"); -- , "Sent");
    local lhs = CraftScan.OrderToResponse(lhsOrder);
    local rhs = CraftScan.OrderToResponse(rhsOrder);
    if sortOrder == CraftScan.ChatOrderSortOrder.ItemName then
        local lhsName = getOrderName(lhs)
        local rhsName = getOrderName(rhs)
        return SortUtil.CompareUtf8i(lhsName, rhsName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.CustomerName then
        return SortUtil.CompareUtf8i(lhsOrder.customerName, rhsOrder.customerName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.CrafterName then
        return SortUtil.CompareUtf8i(lhs.crafterName, rhs.crafterName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.ProfessionName then
        return SortUtil.CompareUtf8i(lhs.professionName, rhs.professionName)
    elseif sortOrder == CraftScan.ChatOrderSortOrder.Time then
        local now = time()
        local lhsAge = math.floor(now - lhs.time)
        local rhsAge = math.floor(now - rhs.time)
        return SortUtil.CompareNumeric(lhsAge, rhsAge)
    end
    return false
end

local function PurgeOldOrders()
    local orders = CraftScan.DB.listed_orders

    local now = time()
    local old = {}
    local timeout = CraftScan.Utils.GetSetting('customer_timeout') * 60;
    for orderID, order in pairs(orders) do
        local response = CraftScan.OrderToResponse(order)
        if not response or now - response.time > timeout then
            table.insert(old, order)
        end
    end

    for _, order in ipairs(old) do
        removeOrder(orders, order)
    end

    return #old ~= 0
end

local function UpdateCells()
    for customer, customerInfo in pairs(CraftScan.LIVE.customers) do
        for _, response in pairs(customerInfo.responses) do
            if response.updateAge then
                response.updateAge()
            end
        end
    end

    if PurgeOldOrders() then
        CraftScanCraftingOrderPage:ShowGeneric()
    else
        C_Timer.After(5, UpdateCells)
    end
end

function CraftScanCraftingOrderPageMixin:ShowGeneric()
    self.BrowseFrame.OrderList.LoadingSpinner:Hide();
    self.BrowseFrame.OrderList.ScrollBox:Show();

    local dataProvider = CreateDataProvider();
    self.BrowseFrame.OrderList.ScrollBox:SetDataProvider(dataProvider);

    local orders = {}
    for _, order in pairs(CraftScan.DB.listed_orders) do
        table.insert(orders, order)
    end

    table.sort(orders, function(lhs, rhs)
        local cmp = ApplySortOrder(self.primarySort.order, lhs, rhs);

        if cmp ~= 0 then
            if self.primarySort.ascending then
                return cmp < 0
            else
                return cmp > 0
            end
        end

        if self.secondarySort then
            cmp = ApplySortOrder(self.secondarySort.order, lhs, rhs);
            if self.secondarySort.ascending then
                return cmp < 0
            else
                return cmp > 0
            end
        end

        return false;
    end);

    if #orders == 0 then
        self.BrowseFrame.OrderList.ResultsText:SetText(PROFESSIONS_CUSTOMER_NO_ORDERS);
        self.BrowseFrame.OrderList.ResultsText:Show();
    else
        self.BrowseFrame.OrderList.ResultsText:Hide();
    end

    for i, order in ipairs(orders) do
        dataProvider:Insert({
            order = order,
            -- browseType = OrderBrowseType.Flat,
            pageFrame = self,
            contextMenu = self.BrowseFrame.OrderList.ContextMenu
        });
    end
    self.BrowseFrame.OrderList.ScrollBox:SetDataProvider(dataProvider);
    -- else
    -- dataProvider = self.BrowseFrame.OrderList.ScrollBox:GetDataProvider();
    -- for idx = offset + 1, #orders do
    -- local order = orders[idx];
    -- dataProvider:Insert({option = order, browseType = browseType, pageFrame = self, contextMenu = self.BrowseFrame.OrderList.ContextMenu});
    -- end
    -- end
    -- self.numOrders = #orders;

    C_Timer.After(5, UpdateCells)
end

function CraftScanCraftingOrderPageMixin:SortOrderIsValid(sortOrder)
    return sortOrder == CraftScan.ChatOrderSortOrder.ItemName or sortOrder == CraftScan.ChatOrderSortOrder.CustomerName
end

function CraftScanCraftingOrderPageMixin:ResetSortOrder()
    self.primarySort = {
        order = CraftScan.ChatOrderSortOrder.Time,
        ascending = false
    };

    self.secondarySort = nil;

    if self.tableBuilder then
        for frame in self.tableBuilder:EnumerateHeaders() do
            frame:UpdateArrow();
        end
    end
end

function CraftScanCraftingOrderPageMixin:GetSortOrder()
    return self.primarySort.order, self.primarySort.ascending;
end

function CraftScanCraftingOrderPageMixin:SetSortOrder(sortOrder)
    if self.primarySort.order == sortOrder then
        self.primarySort.ascending = not self.primarySort.ascending;
    else
        self.secondarySort = CopyTable(self.primarySort);
        self.primarySort = {
            order = sortOrder,
            ascending = true
        };
    end

    if self.tableBuilder then
        for frame in self.tableBuilder:EnumerateHeaders() do
            frame:UpdateArrow();
        end
    end

    self:ShowGeneric()
    -- if self.lastRequest then
    -- self.lastRequest.offset = 0; -- Get a fresh page of sorted results
    -- self:SendOrderRequest(self.lastRequest);
    -- end
end

function CraftScanCraftingOrderPageMixin:SetupOrderListTable()
    if not self.tableBuilder then
        self.tableBuilder = CreateTableBuilder(nil, CraftScanTableBuilderMixin);
        local function ElementDataTranslator(elementData)
            return elementData;
        end
        ScrollUtil.RegisterTableBuilder(self.BrowseFrame.OrderList.ScrollBox, self.tableBuilder, ElementDataTranslator);

        local function ElementDataProvider(elementData)
            return elementData;
        end
        self.tableBuilder:SetDataProvider(ElementDataProvider);
    end

    self.tableBuilder:Reset();
    self.tableBuilder:SetColumnHeaderOverlap(2);
    self.tableBuilder:SetHeaderContainer(self.BrowseFrame.OrderList.HeaderContainer);
    self.tableBuilder:SetTableMargins(-3, 5);
    self.tableBuilder:SetTableWidth(777);

    local PTC = CraftScanTableConstants;

    self.tableBuilder:AddFillColumn(self, PTC.NoPadding, 1.0, 8, PTC.ItemName.RightCellPadding,
        CraftScan.ChatOrderSortOrder.ItemName, "CraftScanCrafterTableCellItemNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.CustomerName.Width, PTC.CustomerName.LeftCellPadding,
        PTC.CustomerName.RightCellPadding, CraftScan.ChatOrderSortOrder.CustomerName,
        "CraftScanCrafterTableCellCustomerNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.CrafterName.Width, PTC.CrafterName.LeftCellPadding,
        PTC.CrafterName.RightCellPadding, CraftScan.ChatOrderSortOrder.CrafterName,
        "CraftScanCrafterTableCellCrafterNameTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.ProfessionName.Width,
        PTC.ProfessionName.LeftCellPadding, PTC.ProfessionName.RightCellPadding,
        CraftScan.ChatOrderSortOrder.ProfessionName,
        "CraftScanCrafterTableCellProfessionNameTemplate");

    self.tableBuilder:AddUnsortableFixedWidthColumn(self, PTC.NoPadding, PTC.Interaction.Width,
        PTC.Interaction.LeftCellPadding, PTC.Interaction.RightCellPadding, L("Replies"),
        "CraftScanCrafterTableCellInteractionTemplate");

    self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Time.Width, PTC.Time.LeftCellPadding,
        PTC.Time.RightCellPadding, CraftScan.ChatOrderSortOrder.Time, "CraftScanCrafterTableCellTimeTemplate");

    -- AddUnsortableFixedWidthColumn

    -- self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Tip.Width, PTC.Tip.LeftCellPadding,
    -- PTC.Tip.RightCellPadding, CraftScanSortOrder.Tip, "CraftScanCrafterTableCellActualCommissionTemplate");
    -- self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Reagents.Width, PTC.Reagents.LeftCellPadding,
    -- PTC.Reagents.RightCellPadding, CraftScanSortOrder.Reagents, "CraftScanCrafterTableCellReagentsTemplate");
    -- self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Expiration.Width, PTC.Expiration.LeftCellPadding,
    -- PTC.Expiration.RightCellPadding, CraftScanSortOrder.Expiration,
    -- "CraftScanCrafterTableCellExpirationTemplate");

    self.tableBuilder:Arrange();
end

local function ParentProfessionConfig(crafterInfo)
    return CraftScan.DB.characters[crafterInfo.name].parent_professions[crafterInfo.parentProfessionID];
end

local function ForEachProfession(op, passthrough)
    for _, crafterConfig in pairs(CraftScan.DB.characters) do
        for _, ppConfig in pairs(crafterConfig.parent_professions) do
            if not op(ppConfig) and passthrough then
                return false;
            end
        end
    end
    return true;
end

local function ForEachCrafterFrame(op)
    for _, frame in pairs(CraftScanCraftingOrderPage.BrowseFrame.CrafterList.ScrollBox:GetFrames()) do
        op(frame)
    end
end

-- We re-use the same template for the header that we use for the rows. The
-- callbacks check if they are the header and act on the whole list if so.
local crafterListAll = nil
local function IsAll(self)
    return self:GetParent() == crafterListAll
end

local function UpdateAllCheckBox(checkbox, ppconfig_key)
    checkbox:SetChecked(
        ForEachProfession(function(ppConfig)
            return ppConfig[ppconfig_key];
        end, true))
end

CraftScan_CrafterToggleMixin = {}

function CraftScan_CrafterToggleMixin:OnClick(button)
    if IsAll(self) then
        ForEachProfession(function(ppConfig)
            ppConfig[self.ppconfig_key] = self:GetChecked();
        end)
        ForEachCrafterFrame(function(frame)
            frame[self:GetName()]:SetChecked(self:GetChecked());
        end)
    else
        ParentProfessionConfig(self:GetParent().crafterInfo)[self.ppconfig_key] = self:GetChecked();
        UpdateAllCheckBox(crafterListAll[self:GetName()], self.ppconfig_key)
    end
    if GameTooltip:IsShown() then
        self:SetTooltip();
    end
end

function CraftScan_CrafterToggleMixin:InitState()
    self:SetChecked(ParentProfessionConfig(self:GetParent().crafterInfo)[self.ppconfig_key])
end

function CraftScan_CrafterToggleMixin:SetTooltip()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    if self:GetChecked() then
        GameTooltip:SetText(self.enabled_tooltip);
    else
        GameTooltip:SetText(self.disabled_tooltip);
    end
end

function CraftScan_CrafterToggleMixin:OnEnter()
    self:GetParent().HoverBackground:Show();
    self:SetTooltip();
end

function CraftScan_CrafterToggleMixin:OnLeave()
    self:GetParent().HoverBackground:Hide();
    GameTooltip:Hide();
end

CraftScanCrafterListMixin = {}

function CraftScanCrafterListMixin:OnLoad()
    -- Using AzeriteEssenceUI as a guide

    CraftScan.Utils.onLoad(function()
        crafterListAll = CraftScanCraftingOrderPage.BrowseFrame.CrafterList.CrafterListAllButton;

        UpdateAllCheckBox(crafterListAll.EnabledCheckBox, 'scanning_enabled')
        UpdateAllCheckBox(crafterListAll.SoundAlertCheckBox, 'sound_alert_enabled')
        UpdateAllCheckBox(crafterListAll.VisualAlertCheckBox, 'visual_alert_enabled')

        -- TODO Make this big and find a better texture
        crafterListAll.CrafterName:SetText(L("All crafters"))
        crafterListAll:Show();

        local topPadding = 3;
        local leftPadding = 4;
        local rightPadding = 2;
        local spacing = 1;
        local view = CreateScrollBoxListLinearView(topPadding, 0, leftPadding, rightPadding, spacing);

        local function FrameInitializer(frame, crafterInfo)
            local crafterName = CraftScan.NameAndRealmToName(crafterInfo.name)
            if crafterName == UnitName("PLAYER") then
                crafterName = '|cff00ff00' .. crafterName .. '|r'
            end
            frame.CrafterName:SetText(crafterName)
            frame.crafterInfo = crafterInfo
            frame.EnabledCheckBox:InitState()
            frame.SoundAlertCheckBox:InitState()
            frame.VisualAlertCheckBox:InitState()
            frame.ProfessionIcon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(crafterInfo.parentProfessionID))

            local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(crafterInfo.parentProfessionID);
            frame.ProfessionName:SetText(CraftScan.Utils.ColorizeProfessionName(profInfo.professionID,
                profInfo.professionName))
        end

        view:SetElementFactory(function(factory, essenceInfo)
            factory("CraftScanCrafterListElementTemplate", FrameInitializer);
        end);

        ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

        -- Highly unlikely to ever need a scroll bar, so hide it unless needed.
        -- Tested one time with 20 dummy characters in the config and the scroll
        -- bar did appear and was usable.
        ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil,
            nil);


        local crafterRows = {}
        for name, info in pairs(CraftScan.DB.characters) do
            for parentProfessionID, _ in pairs(info.parent_professions) do
                table.insert(crafterRows, {
                    name = name,
                    parentProfessionID = parentProfessionID,
                })
            end
        end
        local dataProvider = CreateDataProvider(crafterRows)
        self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
    end)
end

CraftScanCrafterListElementMixin = {}

function CraftScanCrafterListElementMixin:OnEnter()
    self.HoverBackground:Show();
end

function CraftScanCrafterListElementMixin:OnLeave()
    self.HoverBackground:Hide();
end

function CraftScanCrafterListElementMixin:OnClick()
    self.EnabledCheckBox:SetChecked(not self.EnabledCheckBox:GetChecked())
    self.EnabledCheckBox:OnClick()
end

CraftScan_CrafterListAllButtonMixin = {}

function CraftScan_CrafterListAllButtonMixin:OnEnter()
    self.HoverBackground:Show();
end

function CraftScan_CrafterListAllButtonMixin:OnLeave()
    self.HoverBackground:Hide();
end

function CraftScan_CrafterListAllButtonMixin:OnClick()
    self.EnabledCheckBox:SetChecked(not self.EnabledCheckBox:GetChecked())
    self.EnabledCheckBox:OnClick()
end

CraftScan_AddonToggleButtonMixin = {}

function CraftScan_AddonToggleButtonMixin:OnClick(button)
    CraftScan.Utils.ToggleSavedAddons()
    self:SetButtonText()
end

function CraftScan_AddonToggleButtonMixin:SetButtonText()
    self:SetText(CraftScan.Utils.AddonsAreSaved() and L(LID.RENABLE_ADDONS) or L(LID.DISABLE_ADDONS))
end

function CraftScan_AddonToggleButtonMixin:OnEnter()
    if not CraftScan.Utils.AddonsAreSaved() then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(L(LID.DISABLE_ADDONS_TOOLTIP), 1, 1, 1, 1, true)
        GameTooltip:Show()
    end
end

function CraftScan_AddonToggleButtonMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan_TabButtonMixin = {}

function CraftScan_TabButtonMixin:UpdateTabWidth()
    self:SetWidth(self.Text:GetStringWidth() + 25);
end

function CraftScan_TabButtonMixin:OnShow()
    self:SetTabSelected(false);
    self.Text:SetPoint("CENTER", self, "CENTER", 0, -3);
end

function CraftScan_TabButtonMixin:Init()
    self:HandleRotation();
    self:SetButtonText();
    self:UpdateTabWidth();
end

CraftScan_OpenProfessionButtonMixin = {}

function CraftScan_OpenProfessionButtonMixin:OnClick(button)
    -- With TWW update, this hide is no longer automatic.
    HideUIPanel(CraftScan.Frames.OrdersPage);

    C_TradeSkillUI.OpenTradeSkill(self.profession.professionID);
    self:SetTabSelected(false);
    self.Text:SetPoint("CENTER", self, "CENTER", 0, 0);
end

function CraftScan_OpenProfessionButtonMixin:SetButtonText()
    local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(self.profession.professionID);
    self:SetText(professionInfo.professionName);
    self:UpdateTabWidth();
end

CraftScan_OpenChatOrdersButtonMixin = {}

function CraftScan_OpenChatOrdersButtonMixin:OnClick(button)
    -- With TWW update, this hide is no longer automatic.
    HideUIPanel(ProfessionsFrame);

    ShowUIPanel(CraftScan.Frames.OrdersPage);
end

function CraftScan_OpenChatOrdersButtonMixin:SetButtonText()
    self.Text:SetText(L(LID.CHAT_ORDERS));
end

local autoReplyConfirmationFrame = nil

local function ResetAutoReplyTimeouts()
    if autoReplyConfirmationFrame then
        if autoReplyConfirmationFrame.timeout then
            autoReplyConfirmationFrame.timeout:Cancel()
            autoReplyConfirmationFrame.timeout = nil;
        end
        if autoReplyConfirmationFrame.displayTimeout then
            autoReplyConfirmationFrame.displayTimeout:Cancel()
            autoReplyConfirmationFrame.displayTimeout = nil;
        end
    end
end

local function IsSupportedPlayer()
    local bit = bit or bit32

    local function FNV1aHash(str)
        local prime = 16777619
        local hash = 2166136261

        for i = 1, #str do
            hash = bit.bxor(hash, str:byte(i))
            hash = bit.band((hash * prime), 0xFFFFFFFF)
        end

        return hash
    end

    --[[
    local supported_players_clear = {
        -- Auto-replies might be against ToS and are not available by default. If you
        -- find this, please don't tell anyone because mis-use will likely ruin it for
        -- all of us.
    }

    local hashed_players = {}
    for i, player in ipairs(supported_players_clear) do
        hashed_players[i] = FNV1aHash(player)
    end

    if next(supported_players_clear) then
        CraftScan.Utils.printTable("Players", hashed_players);
    end
 ]]

    local supportedPlayers =
    {
        -- Myself
        [139713656] = 1,
        [3499597080] = 1,
        [966756688] = 1,
        [609189344] = 1,
        [3276845976] = 1,
        [3119649560] = 1,
        [4169972888] = 1,
        [1989399756] = 1,
        [1720786156] = 1,
        [1480692192] = 1,
        [1986072520] = 1,

        -- Guild crafters
        [2693742840] = 1,
        [6574920] = 1,
        [1344568737] = 1,
        [914132312] = 1,
    }

    local me = UnitName("player") .. '-' .. GetRealmName();
    return supportedPlayers[FNV1aHash(me)] ~= nil;
end


-- Timeout auto-replies after 5 minutes of not moving. Movement every minute
-- will reset the timeout back to 5 minutes.
CraftScan.CONST.AUTO_REPLIES_SUPPORTED = IsSupportedPlayer();
local auto_replies_supported = CraftScan.CONST.AUTO_REPLIES_SUPPORTED;
local auto_reply_timeout = 300;
local auto_reply_confirm_timeout = 15;
local auto_reply_refresh_interval = 60;

local function AutoReplyTimeout()
    CraftScan.auto_replies_enabled = false;
    CraftScanCraftingOrderPage.BrowseFrame.CrafterList.AutoReplyButton:SetButtonText();
    ResetAutoReplyTimeouts();
    autoReplyConfirmationFrame:Hide();
    autoReplyConfirmationFrame = nil;

    CraftScanScannerMenu:UnregisterEventCallback("PLAYER_STARTED_MOVING", OnPlayerMoved);
end

local function DisplayAutoReplyConfirmation()
    autoReplyConfirmationFrame.displayTimeout = nil;
    if autoReplyConfirmationFrame.timeout then
        autoReplyConfirmationFrame.timeout:Cancel()
    end
    autoReplyConfirmationFrame.timeout = C_FunctionContainers.CreateCallback(AutoReplyTimeout);

    if CraftScan.auto_replies_enabled == true then
        C_Timer.After(auto_reply_confirm_timeout, autoReplyConfirmationFrame.timeout)
        autoReplyConfirmationFrame:Show();
    end
end

local function SetAutoReplyTimeout()
    ResetAutoReplyTimeouts();
    if not CraftScan.auto_replies_enabled then
        return
    end

    if not autoReplyConfirmationFrame then
        autoReplyConfirmationFrame = CreateFrame("Frame", "AutoReplyConfirmation", UIParent,
            "CraftScan_AutoReplyConfirmationTemplate")
        autoReplyConfirmationFrame:SetScript("OnKeyDown", function(self, key)
            if autoReplyConfirmationFrame:IsShown() then
                if key == "ESCAPE" then
                    -- ESC ends auto-reply
                    AutoReplyTimeout();
                elseif key == "ENTER" then
                    -- Enter  extends auto-reply
                    autoReplyConfirmationFrame:Hide();
                    SetAutoReplyTimeout()
                end
            end
            return false;
        end)
        local lastReset = time()

        local function OnPlayerMoved()
            if CraftScan.auto_replies_enabled and time() - lastReset > auto_reply_refresh_interval then
                -- Hitting any key resets the timeout.
                lastReset = time();
                SetAutoReplyTimeout();
            end
        end

        CraftScanScannerMenu:RegisterEventCallback("PLAYER_STARTED_MOVING", OnPlayerMoved);
    end

    autoReplyConfirmationFrame.displayTimeout = C_FunctionContainers.CreateCallback(DisplayAutoReplyConfirmation);
    C_Timer.After(auto_reply_timeout, autoReplyConfirmationFrame.displayTimeout);
end

CraftScan_AutoReplyKeepEnabledMixin = {}

function CraftScan_AutoReplyKeepEnabledMixin:OnClick()
    autoReplyConfirmationFrame:Hide();
    SetAutoReplyTimeout()
end

CraftScan_AutoReplyDisableMixin = {}

function CraftScan_AutoReplyDisableMixin:OnClick()
    AutoReplyTimeout();
end

CraftScan_AutoReplyButtonMixin = {}

function CraftScan_AutoReplyButtonMixin:OnLoad()
    if not auto_replies_supported then
        self:Hide();
    end
end

function CraftScan_AutoReplyButtonMixin:SetButtonText()
    self:SetText(
        CraftScan.auto_replies_enabled and "Disable Auto Replies" or "Enable Auto Replies")
end

function CraftScan_AutoReplyButtonMixin:OnClick()
    CraftScan.auto_replies_enabled = not CraftScan.auto_replies_enabled;
    self:SetButtonText();

    -- After enabling auto-replies, we start a timer to confirm that they should
    -- still be enabled. Hopefully, this prevents accidental AFKs. When the
    -- timer expires, a confirmation is requested. Failure to hit the
    -- confirmation will disable auto replies.
    SetAutoReplyTimeout();
end

function CraftScan_AutoReplyButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    if not CraftScan.auto_replies_enabled then
        GameTooltip:SetText(
            "Auto replies are disabled. Auto replies will quickly,\nbut not instantly, auto-reply to crafts you\ncan do for the character you are currently playing.")
    else
        GameTooltip:SetText(
            "Auto replies are enabled.");
    end
    GameTooltip:Show()
end

function CraftScan_AutoReplyButtonMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan.Utils.onLoad(function()
    local frame = CraftScanCraftingOrderPage
    CraftScan.Frames.OrdersPage = frame
    table.insert(UISpecialFrames, "CraftScanCraftingOrderPage"); -- Make 'esc' close the frame
    UIPanelWindows["CraftScanCraftingOrderPage"] = { area = "doublewide", pushable = 1, whileDead = 1 }

    frame.BrowseFrame.CrafterList.AddonToggleButton:SetButtonText();
    frame.BrowseFrame.CrafterList.AutoReplyButton:SetButtonText();

    local lastButton = nil;
    for i, profession in ipairs(CraftScan.CONST.PROFESSIONS) do
        local profButton = CreateFrame("Button", "OpenChatOrdersButton" .. i, frame,
            "CraftScan_OpenProfessionButtonTemplate");
        profButton.profession = profession;
        if lastButton then
            profButton:SetPoint("TOPLEFT", lastButton, "TOPRIGHT", 2, 0);
        else
            profButton:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, 2);
        end
        profButton:Init();
        lastButton = profButton;
    end

    PurgeOldOrders()

    local initialized = false;
    ProfessionsFrame:HookScript("OnShow", function()
        if not initialized then
            local openChatOrdersFrame = CreateFrame("Button", "OpenChatOrdersButton", ProfessionsFrame,
                "CraftScan_OpenChatOrdersButtonTemplate");
            openChatOrdersFrame:Init();
            openChatOrdersFrame:SetPoint("TOPLEFT", ProfessionsFrame.TabSystem, "TOPRIGHT", 2, 0);

            initialized = true;
        end
    end)
end)
