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
    elseif button == "MiddleButton" then
        -- Middle button to begin chat without the generated greeting
        response.greeting_sent = true
        ChatFrame_SendTell(order.customerName, DEFAULT_CHAT_FRAME)
    elseif button == "RightButton" then
        removeOrder(CraftScan.DB.listed_orders, order)
        CraftScanCraftingOrderPage:ShowGeneric()
    end
end

function CraftScanCrafterOrderListElementMixin:OnClick(button)
    CraftScan.GreetCustomer(button, self.order)
end

local chatTooltip = CraftScan.Utils.ChatHistoryTooltip:new();
function CraftScanCrafterOrderListElementMixin:OnLineEnter()
    self.HighlightTexture:Show();

    -- If the request has a specific item, toss up the item tooltip just like
    -- the real crafting order page.
    local response = CraftScan.OrderToResponse(self.order)
    if response.recipeID then
        local reagents = {};
        local qualityIDs = C_TradeSkillUI.GetQualitiesForRecipe(response.recipeID);
        local qualityIdx = qualityIDs and #qualityIDs or 0;
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetRecipeResultItem(response.recipeID, reagents, nil, nil, qualityIDs and qualityIDs[qualityIdx]);
    end

    -- In addition, pop up a tooltip that looks like the chat window. We copy
    -- the chat window width (up to a limit that fits over the crafting window),
    -- and the primary chat window's font settings. This seems to make the text
    -- wrapping match and overall it looks pretty close to the real chat window
    -- to give an easy refresher on prior interactions without popping out the
    -- dedicated chat frame.
    chatTooltip:Show("CraftScanChatHistoryTooltip", self, self.order,
        string.format(L("Chat History"), CraftScan.NameAndRealmToName(self.order.customerName)));
end

function CraftScanCrafterOrderListElementMixin:OnLineLeave()
    self.HighlightTexture:Hide();

    GameTooltip:Hide();
    chatTooltip:Hide();
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
    self.BrowseFrame.LeftPanel.CrafterList.FilterButton.ResetButton:SetShown(
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

-- States: 0 - all unchecked
--         1 - all checked
--         2 - indeterminate

local function ForEachProfession(op)
    local allTrue = true;
    local allFalse = true;
    for _, crafterConfig in pairs(CraftScan.DB.characters) do
        for _, ppConfig in pairs(crafterConfig.parent_professions) do
            if not ppConfig.character_disabled then
                local result = op(ppConfig);
                if result then
                    allFalse = false;
                else
                    allTrue = false;
                end
            end
        end
    end
    return allTrue and 1 or allFalse and 0 or 2;
end

local function ForEachCrafterFrame(op)
    for _, frame in pairs(CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList.ScrollBox:GetFrames()) do
        op(frame)
    end
end

-- We re-use the same template for the header that we use for the rows. The
-- callbacks check if they are the header and act on the whole list if so.
local crafterListAll = nil
local function IsAll(self)
    return self:GetParent() == crafterListAll
end

local function UpdateAllCheckBox(checkbox)
    local stateBefore = checkbox.state;
    checkbox.state =
        ForEachProfession(function(ppConfig)
            return ppConfig[checkbox.ppconfig_key];
        end);
    checkbox:UpdateAllCheckBoxDisplay();
    if stateBefore == 2 and checkbox.state ~= 2 then
        -- If we're applying the remote state, it has already taken the snapshot
        -- for us, so we skip that step here.
        if not CraftScanComm.applying_remote_state then
            checkbox:RememberAllUserState();
        end
    end
end

local function InitAllCheckBox(checkbox)
    if not checkbox.checked_texture then
        checkbox.indeterminate_texture = checkbox:CreateTexture();
        checkbox.indeterminate_texture:SetSize(12, 12);
        checkbox.indeterminate_texture:SetAllPoints(checkbox);
        checkbox.indeterminate_texture:SetAtlas(checkbox.indeterminate_atlas);
        checkbox.indeterminate_texture:Hide();

        checkbox.checked_texture = checkbox:GetCheckedTexture();
    end

    UpdateAllCheckBox(checkbox);
end

CraftScan_CrafterToggleMixin = {}

function CraftScan_CrafterToggleMixin:UpdateAllCheckBoxDisplay()
    self.indeterminate_texture:Hide();
    if self.state == 0 then
        self:SetChecked(false);
    elseif self.state == 1 then
        self:SetCheckedTexture(self.checked_texture);
        self:SetChecked(true);
    else
        self.indeterminate_texture:Show();
        self:SetCheckedTexture(self.indeterminate_texture);
        self:SetChecked(true);
    end
end

function CraftScan_CrafterToggleMixin:RememberAllUserState()
    -- Remember the most recent user specified state so we can restore it when
    -- clicking through to the indeterminate state.
    ForEachProfession(function(ppConfig)
        ppConfig[self.ppconfig_key .. "_last"] = ppConfig[self.ppconfig_key];
    end)
end

function CraftScan_CrafterToggleMixin:OnClick(button)
    if IsAll(self) then
        if self.state == 2 then
            -- Moving from indeterminate to all disabled. Remember the user
            -- configured states of each box so we can click back to
            -- indeterminate to restore it.
            self:RememberAllUserState();
            self.state = 0;
        elseif self.state == 1 then
            local rememberedState = ForEachProfession(function(ppConfig) return ppConfig[self.ppconfig_key .. "_last"]; end);
            if rememberedState == 2 then
                self.state = 2;
            else
                self.state = 0;
            end
        else
            self.state = 1;
        end

        if self.state ~= 2 then
            -- Manually moving everything to all on or all off.
            local checked = self.state == 1;
            ForEachProfession(function(ppConfig)
                ppConfig[self.ppconfig_key] = checked;
            end)

            ForEachCrafterFrame(function(frame)
                frame[self:GetName()]:SetChecked(checked);
            end)

            -- Push only the ppConfig of all characters across
            CraftScanComm:ShareAllPpCharacterModifications();
        else
            -- When moving to the indeterminate state manually, reapply the last
            -- user state.
            ForEachProfession(function(ppConfig)
                ppConfig[self.ppconfig_key] = ppConfig[self.ppconfig_key .. "_last"];
            end)

            -- And update the display to match the saved config.
            ForEachCrafterFrame(function(frame)
                frame[self:GetName()]:InitState();
            end)

            -- Push only the ppConfig of all characters across
            CraftScanComm:ShareAllPpCharacterModifications();
        end

        self:UpdateAllCheckBoxDisplay();
    else
        local crafterInfo = self:GetParent().crafterInfo;
        ParentProfessionConfig(crafterInfo)[self.ppconfig_key] = self:GetChecked();
        UpdateAllCheckBox(crafterListAll[self:GetName()])

        local ppChangeOnly = true;
        CraftScan.Utils.printTable("crafterInfo", crafterInfo);
        CraftScanComm:ShareCharacterModification(crafterInfo.name, crafterInfo.parentProfessionID, ppChangeOnly);
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

CraftScan_CrafterListMixin = {}

function CraftScan_CrafterListMixin:SetupCrafterList()
    crafterListAll = self.CrafterListAllButton;

    InitAllCheckBox(crafterListAll.EnabledCheckBox)
    InitAllCheckBox(crafterListAll.SoundAlertCheckBox)
    InitAllCheckBox(crafterListAll.VisualAlertCheckBox)

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
        frame:RegisterForClicks("AnyUp");

        local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(crafterInfo.parentProfessionID);
        frame.ProfessionName:SetText(CraftScan.Utils.ColorizeProfessionName(profInfo.professionID,
            profInfo.professionName))

        if CraftScan.DB.characters[crafterInfo.name].parent_professions[crafterInfo.parentProfessionID].primary_crafter then
            frame.PrimaryCrafterIcon:Show();
        else
            frame.PrimaryCrafterIcon:Hide();
        end
        frame.LinkedAccountIcon:Init(frame.crafterInfo);
    end

    view:SetElementFactory(function(factory)
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
        for parentProfessionID, ppInfo in pairs(info.parent_professions) do
            if not ppInfo.character_disabled then
                table.insert(crafterRows, {
                    name = name,
                    parentProfessionID = parentProfessionID,
                })
            end
        end
    end

    -- Sort characters so all primary crafters appear first, then alphabetically within the two groups.
    table.sort(crafterRows, function(lhs, rhs)
        local lhsPpConfig = CraftScan.DB.characters[lhs.name].parent_professions[lhs.parentProfessionID];
        local rhsPpConfig = CraftScan.DB.characters[rhs.name].parent_professions[rhs.parentProfessionID];

        local secondarySort = function()
            if lhs.name ~= rhs.name then
                return lhs.name < rhs.name
            end

            local lhsProfInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(lhs.parentProfessionID);
            local rhsProfInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(rhs.parentProfessionID);

            return lhsProfInfo.professionName < rhsProfInfo.professionName
        end

        if lhsPpConfig.primary_crafter then
            if rhsPpConfig.primary_crafter then
                return secondarySort()
            end
            return true;
        end

        if rhsPpConfig.primary_crafter then
            return false;
        end

        return secondarySort()
    end)

    local dataProvider = CreateDataProvider(crafterRows)
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function CraftScan_CrafterListMixin:OnShow()
    self:SetupCrafterList();
end

CraftScanCrafterListElementMixin = {}

function CraftScanCrafterListElementMixin:OnEnter()
    self.HoverBackground:Show();
end

function CraftScanCrafterListElementMixin:OnLeave()
    self.HoverBackground:Hide();
end

function CraftScan.OnCrafterListModified()
    if CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList:IsShown() then
        -- Refresh the list to display the change.
        CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList:SetupCrafterList();
    end

    -- Reload the scanner data to apply the change.
    CraftScan.Scanner.LoadConfig()
end

-- Provide common properties for our various confirmations.
local function SetupPopupDialog(key, config)
    local popup = {
        button2 = "Cancel",
        OnCancel = nil,
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, -- Avoid UI taint issues by using a higher index
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            parent.button1:Click() -- Simulate a click on the Confirm button
        end,
        EditBoxOnEscapePressed = function(self)
            local parent = self:GetParent()
            parent.button2:Click() -- Simulate a click on the Cancel button
        end,
    };
    for key, value in pairs(config) do
        popup[key] = value;
    end
    StaticPopupDialogs[key] = popup;
end

function CraftScan.RemoveChildProfessions(charConfig, ppID)
    local pConfigs = charConfig.professions;
    for profID, config in pairs(pConfigs) do
        if config.parentProfID == ppID then
            pConfigs[profID] = nil;
        end
    end
end

-- The confirmation dialog to 'disable' a profession for a specific character.
SetupPopupDialog("CRAFT_SCAN_CONFIRM_CONFIG_DELETE", {
    text = L(LID.DELETE_CONFIG_TOOLTIP_TEXT) .. '\n\n' .. L(LID.DELETE_CONFIG_CONFIRM),
    button1 = "Delete",
    OnAccept = function(self, crafterInfo)
        local userInput = self.editBox:GetText()
        if string.lower(userInput) == "delete" then
            local charConfig = CraftScan.DB.characters[crafterInfo.name];

            -- Flag the profession as disabled. We don't fully delete it
            -- because we want to remember that the user disabled it so
            -- we don't keep re-enabling it when they open the
            -- profession window.
            local parentProfID = crafterInfo.parentProfessionID;

            -- Wipe the ppConfig to a clean slate.
            local rev = charConfig.parent_professions[parentProfID].rev;
            charConfig.parent_professions[parentProfID] = CraftScan.Utils.DeepCopy(CraftScan.CONST.DEFAULT_PPCONFIG);
            local ppConfig = charConfig.parent_professions[parentProfID];
            ppConfig.rev = rev; -- The revision needs to persist through disable/enable cycles so we know which side wins.
            ppConfig.character_disabled = true;

            -- Delete all details about the expansion level professions.
            CraftScan.RemoveChildProfessions(charConfig, parentProfID);

            -- Send the modification to any linked accounts.
            local ppChangeOnly = true;
            CraftScanComm:ShareCharacterModification(crafterInfo.name, parentProfID, ppChangeOnly);

            CraftScan.OnCrafterListModified();
        else
            print("CraftScan confirmation failed.")
        end
    end
})

-- The confirmation dialog to 'cleanup' a profession for a specific character.
SetupPopupDialog("CRAFT_SCAN_CONFIRM_CONFIG_CLEANUP", {
    text = L(LID.CLEANUP_CONFIG_TOOLTIP_TEXT) .. '\n\n' .. L(LID.CLEANUP_CONFIG_CONFIRM),
    button1 = "Cleanup",
    OnAccept = function(self, crafterInfo)
        local userInput = self.editBox:GetText()
        if string.lower(userInput) == "cleanup" then
            local charConfig = CraftScan.DB.characters[crafterInfo.name];

            -- Fully delete the parent profession and all references to it
            local parentProfID = crafterInfo.parentProfessionID;
            charConfig.parent_professions[parentProfID] = nil;

            local pConfigs = charConfig.professions;
            for profID, config in pairs(pConfigs) do
                if config.parentProfID == parentProfID then
                    pConfigs[profID] = nil;
                end
            end

            CraftScan.OnCrafterListModified();
        else
            print("CraftScan confirmation failed.")
        end
    end
})

CraftScan_PrimaryCrafterIconMixin = {}

function CraftScan_PrimaryCrafterIconMixin:OnShow()
    local linkedAccount = self:GetParent().LinkedAccountIcon;
    linkedAccount:ClearAllPoints()
    linkedAccount:SetPoint("LEFT", self, "RIGHT", 2, 0)
end

function CraftScan_PrimaryCrafterIconMixin:OnHide()
    local linkedAccount = self:GetParent().LinkedAccountIcon;
    if linkedAccount then
        linkedAccount:ClearAllPoints()
        linkedAccount:SetPoint("LEFT", self:GetParent().CrafterName, "RIGHT", 2, 0)
    end
end

CraftScan_LinkedAccountIconMixin = {}

function CraftScan_LinkedAccountIconMixin:Init(crafterInfo)
    -- GetParent() doesn't return during OnLoad, so we have a manual init call
    -- to receive the crafterInfo directly.
    local charConfig = CraftScan.DB.characters[crafterInfo.name];
    if charConfig.sourceID and charConfig.sourceID ~= CraftScan.DB.settings.my_uuid then
        self:Show();
    else
        self:Hide();
    end
end

function CraftScan_LinkedAccountIconMixin:OnEnter()
    local crafter = self:GetParent().crafterInfo.name;
    local sourceID = CraftScan.DB.characters[crafter].sourceID;
    local nickname = CraftScan.DB.settings.linked_accounts[sourceID].nickname;

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(string.format(L(LID.REMOTE_CRAFTER_SUMMARY), nickname));
    GameTooltip:Show()
end

function CraftScan_LinkedAccountIconMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan_ProxyEnabledMixin = {}

function CraftScan_ProxyEnabledMixin:OnLoad()
    local value = CraftScan.DB.settings[self.key] or false;
    self:SetChecked(value);
    self.Text:SetText(L(self.key));
end

function CraftScan_ProxyEnabledMixin:OnClick()
    CraftScan.DB.settings[self.key] = not CraftScan.DB.settings[self.key];

    -- If disabled out in the world, we need a kick to hide the button.
    CraftScanScannerMenu:UpdateFrameVisibility();
end

function CraftScan_ProxyEnabledMixin:OnEnter()
end

function CraftScan_ProxyEnabledMixin:OnLeave()
end

CraftScan_LinkAccountButtonMixin = {}

function CraftScan_LinkAccountButtonMixin:Reset()
    if CraftScanComm:HavePendingPeerRequest() then
        self.PendingAlert:SetText(string.format(L(LID.ACCOUNT_LINK_ACCEPT_DST_LABEL),
            CraftScanComm:GetPendingPeerRequestCharacter()));
        self:SetText(L("Accept Linked Account"));
        self.PendingAlert:Show();
    else
        self:SetText(L("Link Account"));
        self.PendingAlert:Hide();
    end

    self:FitToText();
end

function CraftScan_LinkAccountButtonMixin:OnShow()
    self:Reset();
end

function CraftScan_LinkAccountButtonMixin:OnLoad()
    self:Reset();
end

function CraftScan_LinkAccountButtonMixin:OnClick()
    if CraftScanComm:HavePendingPeerRequest() then
        local OnAccept = function(nickname)
            CraftScanComm:AcceptPeerRequest(nickname);
        end

        CraftScan.Dialog.Show({

            title = L("Accept Linked Account"),
            submit = L("Accept Linked Account"),
            OnAccept = OnAccept,
            elements = {
                {
                    type = CraftScan.Dialog.Element.Text,
                    text = string.format(L(LID.ACCOUNT_LINK_ACCEPT_DST_INFO),
                        CraftScanComm:GetPendingPeerRequestCharacter()),
                },
                {
                    type = CraftScan.Dialog.Element.EditBox,
                },
            },
        })
    else
        local OnAccept = function(character, nickname)
            self.PendingAlert:SetText(string.format(L(LID.ACCOUNT_LINK_ACCEPT_SRC_LABEL), character));
            self.PendingAlert:Show();

            CraftScan.Dialog.Show({
                title = L("Accept Linked Account"),
                submit = L("OK"),
                elements = {
                    {
                        type = CraftScan.Dialog.Element.Text,
                        text = L(LID.ACCOUNT_LINK_ACCEPT_SRC_INFO),
                    },
                },
            })

            CraftScanComm:SendHandshake(character, nickname);
        end
        local elements = {
            {
                type = CraftScan.Dialog.Element.Text,
                text = L(LID.ACCOUNT_LINK_DESC),
            },
            {
                type = CraftScan.Dialog.Element.Text,
                text = L(LID.ACCOUNT_LINK_PROMPT_CHARACTER),
                padding = 10,
            },
            {
                type = CraftScan.Dialog.Element.EditBox,
            },
            {
                type = CraftScan.Dialog.Element.Text,
                text = L(LID.ACCOUNT_LINK_PROMPT_NICKNAME),
                padding = 10,
            },
            {
                type = CraftScan.Dialog.Element.EditBox,
            },
        }
        CraftScan.Dialog.Show({
            title = L("Link Account"),
            submit = L("Link Account"),
            OnAccept = OnAccept,
            elements = elements,
        })
    end
end

function CraftScan.OnPendingPeerAdded()
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkAccountControls.LinkAccountButton:Reset();
end

function CraftScan.OnPendingPeerRejected(reason)
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkAccountControls.LinkAccountButton:Reset();

    self.PendingAlert:SetText(reason);
    self.PendingAlert:Show();
end

function CraftScan.OnPendingPeerAccepted()
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkAccountControls.LinkAccountButton:Reset();
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();

    CraftScan.Utils.printTable("my_uuid", CraftScan.DB.settings.my_uuid)
    CraftScan.Utils.printTable("linked_accounts", CraftScan.DB.settings.linked_accounts)
end

CraftScan_LinkedAccountListMixin = {}

function CraftScan_LinkedAccountListMixin:OnShow()
    self:Init();
end

function FormatTimeAgo(pastTime)
    local currentTime = time()
    local diff = currentTime - pastTime

    if diff < 60 then
        return diff .. "s"
    elseif diff < 3600 then
        local minutes = math.floor(diff / 60)
        return minutes .. "m"
    else
        local hours = math.floor(diff / 3600)
        return hours .. "h"
    end
end

function CraftScan_LinkedAccountListMixin:Init()
    -- If there are linked accounts, show additional controls for them.
    -- Otherwise, we only show the button to create a link.
    local showList = CraftScan.DB.settings.linked_accounts and next(CraftScan.DB.settings.linked_accounts);

    local linkAccountControls = self:GetParent().LinkAccountControls;
    if showList then
        linkAccountControls:SetHeight(70)
        linkAccountControls.ProxyReceiveEnabled:Show();
        linkAccountControls.ProxySendEnabled:Show();
    else
        linkAccountControls:SetHeight(35)
        linkAccountControls.ProxyReceiveEnabled:Hide();
        linkAccountControls.ProxySendEnabled:Hide();
    end

    local crafterList = self:GetParent().CrafterList;
    crafterList:ClearAllPoints();
    crafterList:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 0, 0);
    crafterList:SetPoint("BOTTOMLEFT", linkAccountControls, "TOPLEFT", 0, showList and 105 or 0);

    if not showList then
        self:Hide();
        return;
    end

    self.Title:SetText(L("Linked Accounts"));

    local topPadding = 3;
    local leftPadding = 4;
    local rightPadding = 2;
    local spacing = 1;
    local view = CreateScrollBoxListLinearView(topPadding, 0, leftPadding, rightPadding, spacing);

    local function FrameInitializer(frame, linkedAccount)
        frame.linkedAccount = linkedAccount;
        frame.AccountName:SetText(linkedAccount.info.nickname);
        frame.UpdateDisplay = function(frame)
            local linkedAccount = frame.linkedAccount;
            local connectedTo, lastSeen = CraftScanComm:LinkState(linkedAccount.sourceID);
            frame.LinkState:SetText(connectedTo and
                string.format(L(LID.LINK_ACTIVE), connectedTo, FormatTimeAgo(lastSeen)) or
                FRIENDS_LIST_OFFLINE);

            frame.StatusIcon:SetTexture(connectedTo and FRIENDS_TEXTURE_ONLINE or FRIENDS_TEXTURE_OFFLINE);
        end
        frame.UpdateDisplay(frame);
    end

    view:SetElementFactory(function(factory)
        factory("CraftScan_LinkedAccountListElementTemplate", FrameInitializer);
    end);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    -- Highly unlikely to ever need a scroll bar, so hide it unless needed.
    -- Tested one time with 20 dummy characters in the config and the scroll
    -- bar did appear and was usable.
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, nil,
        nil);

    local linkedAccounts = {}
    for sourceID, info in pairs(CraftScan.DB.settings.linked_accounts) do
        table.insert(linkedAccounts, {
            sourceID = sourceID,
            info = info
        });
    end

    -- Sort characters so all primary crafters appear first, then alphabetically within the two groups.
    table.sort(linkedAccounts, function(lhs, rhs)
        return lhs.info.nickname < rhs.info.nickname;
    end)

    local dataProvider = CreateDataProvider(linkedAccounts)
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

    local function UpdateDisplay()
        if CraftScanCraftingOrderPage:IsShown() then
            for _, frame in pairs(CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList.ScrollBox:GetFrames()) do
                frame.UpdateDisplay(frame);
            end

            C_Timer.After(5, self.UpdateDisplay)
        end
    end

    if self.UpdateDisplay then
        self.UpdateDisplay:Cancel();
    end
    self.UpdateDisplay = C_FunctionContainers.CreateCallback(UpdateDisplay);
    UpdateDisplay();

    self:Show();
end

CraftScan_LinkedAccountListElementMixin = {}

function CraftScan_LinkedAccountListElementMixin:OnClick()
    local linkedAccount = self.linkedAccount;
    CraftScan.Utils.printTable("linkedAccount", linkedAccount)
    MenuUtil.CreateContextMenu(owner, function(owner, rootDescription)
        local crafterList = {}
        for char, charConfig in pairs(CraftScan.DB.characters) do
            if charConfig.sourceID == linkedAccount.sourceID then
                table.insert(crafterList, CraftScan.NameAndRealmToName(char));
            end
        end


        do
            rootDescription:CreateTitle(linkedAccount.info.nickname);
        end
        do
            rootDescription:QueueDivider();
            rootDescription:QueueTitle(L("Backup characters"));
            local OnClick = function(char)
                for i, backup_char in ipairs(linkedAccount.info.backup_chars) do
                    if char == backup_char then
                        table.remove(linkedAccount.info.backup_chars, i)
                        break;
                    end
                end
            end

            for _, char in ipairs(linkedAccount.info.backup_chars) do
                local popoutButton = rootDescription:CreateButton(char);
                popoutButton:CreateButton(L("Remove"), OnClick, char);
            end

            do
                local OnClick = function()
                    local function AddChar(char)
                        table.insert(CraftScan.DB.settings.linked_accounts[linkedAccount.sourceID].backup_chars, char);
                    end
                    CraftScan.Dialog.Show({
                        title = L("Add character"),
                        submit = L("Add character"),
                        OnAccept = AddChar,
                        elements = {
                            {
                                type = CraftScan.Dialog.Element.Text,
                                text = string.format(L(LID.ACCOUNT_LINK_ADD_CHAR)),
                            },
                            {
                                type = CraftScan.Dialog.Element.EditBox,
                            },
                        },
                    });
                end

                local button = rootDescription:CreateButton(L("Add"), OnClick, nil)
            end
        end
        rootDescription:QueueDivider();
        do
            local function DoRename(nickname)
                CraftScan.DB.settings.linked_accounts[linkedAccount.sourceID].nickname = nickname;
                CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();
            end

            local OnClick = function()
                CraftScan.Dialog.Show({
                    title = L("Rename account"),
                    submit = L("Rename account"),
                    OnAccept = DoRename,
                    elements = {
                        {
                            type = CraftScan.Dialog.Element.Text,
                            text = L("New name"),
                        },
                        {
                            type = CraftScan.Dialog.Element.EditBox,
                        },
                    },
                });
            end

            local button = rootDescription:CreateButton(L("Rename account"), OnClick, nil)
            --button:SetTooltip(SetTooltipWithTitle);
        end

        do
            local function DoDelete()
                for char, charConfig in pairs(CraftScan.DB.characters) do
                    if charConfig.sourceID == linkedAccount.sourceID then
                        CraftScan.DB.characters[char] = nil;
                    end
                end
                CraftScan.DB.settings.linked_accounts[linkedAccount.sourceID] = nil;

                CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();
                CraftScan.OnCrafterListModified();
            end

            local OnClick = function()
                CraftScan.Dialog.Show({
                    title = L("Delete Linked Account"),
                    submit = L("Delete Linked Account"),
                    OnAccept = DoDelete,
                    elements = {
                        {
                            type = CraftScan.Dialog.Element.Text,
                            text = string.format(L(LID.ACCOUNT_LINK_DELETE_INFO), linkedAccount.info.nickname,
                                table.concat(crafterList, "\n")),
                        },
                    },
                });
            end

            local button = rootDescription:CreateButton(L("Unlink account"), OnClick, nil)
            --button:SetTooltip(SetTooltipWithTitle);
        end
    end);
end

function CraftScan_LinkedAccountListElementMixin:OnEnter()
    self.HoverBackground:Show();
end

function CraftScan_LinkedAccountListElementMixin:OnLeave()
    self.HoverBackground:Hide();
end

function CraftScan.OnLinkedAccountStateChange()
    if CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:IsShown() then
        CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.LinkedAccountList:Init();
    end
end

local function ProcessPrimaryCrafterUpdate(crafterInfo, ppConfig)
    -- We can only have one primary crafter for a given profession, so walk the
    -- list and turn off the others.
    if not ppConfig.primary_crafter then
        return
    end

    for char, charConfig in pairs(CraftScan.DB.characters) do
        if char ~= crafterInfo.name then
            for parentProfID, parentProfConfig in pairs(charConfig.parent_professions) do
                if parentProfID == crafterInfo.parentProfessionID and parentProfConfig.primary_crafter then
                    parentProfConfig.primary_crafter = false;

                    local ppChangeOnly = true;
                    CraftScanComm:ShareCharacterModification(char, parentProfID, ppChangeOnly);

                    return; -- There can only be one.
                end
            end
        end
    end
end

local function SetTooltipWithTitle(tooltip, elementDescription)
    local data = elementDescription:GetData();
    GameTooltip_SetTitle(tooltip, data.tooltipTitle or MenuUtil.GetElementText(elementDescription));
    GameTooltip_AddNormalLine(tooltip, data.tooltipText);
end;


-- We only register for RightButton on the individual character rows, not the
-- 'All Crafters' row, so we don't need to filter it out.
function CraftScanCrafterListElementMixin:OnClick(button)
    if button == 'LeftButton' then
        self.EnabledCheckBox:SetChecked(not self.EnabledCheckBox:GetChecked())
        self.EnabledCheckBox:OnClick()
        return
    end

    -- Create a context menu to operate on the character's saved
    -- configuration. This allows easily cleanup of an alt army. Any
    -- destructive operations have confirmations since it is easy to
    -- accidentally click something in a context menu.
    local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(self.crafterInfo.parentProfessionID);
    local profName = CraftScan.Utils.ColorizeProfessionName(profInfo.professionID,
        profInfo.professionName);
    local crafter = CraftScan.NameAndRealmToName(self.crafterInfo.name);

    local charConfig = CraftScan.DB.characters[self.crafterInfo.name];
    local ppConfig = charConfig.parent_professions[self.crafterInfo.parentProfessionID];

    MenuUtil.CreateContextMenu(owner, function(owner, rootDescription)
        local isRemoteCrafter = charConfig.sourceID and charConfig.sourceID ~= CraftScan.DB.settings.my_uuid;
        do
            local title = rootDescription:CreateTitle(CraftScan.NameAndRealmToName(self.crafterInfo.name));
            if isRemoteCrafter then
                title:SetTooltip(function(tooltip)
                    --GameTooltip_SetTitle(tooltip, data.tooltipTitle or MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddNormalLine(tooltip, L(LID.REMOTE_CRAFTER_TOOLTIP));
                end);
            end
        end
        do
            local onClick = function()
                StaticPopup_Show("CRAFT_SCAN_CONFIRM_CONFIG_DELETE", profName, crafter, self.crafterInfo)
            end
            local data = {
                tooltipText = string.format(L(LID.DELETE_CONFIG_TOOLTIP_TEXT), profName, crafter)
            };
            local button = rootDescription:CreateButton(L("Disable"), onClick, data)

            if isRemoteCrafter then
                button:SetEnabled(false);
            else
                button:SetTooltip(SetTooltipWithTitle);
            end
        end
        do
            local onClick = function()
                StaticPopup_Show("CRAFT_SCAN_CONFIRM_CONFIG_CLEANUP", profName, crafter, self.crafterInfo)
            end
            local data = {
                tooltipText = string.format(L(LID.CLEANUP_CONFIG_TOOLTIP_TEXT), profName, crafter),
            };
            local button = rootDescription:CreateButton(L("Cleanup"), onClick, data)
            button:SetTooltip(SetTooltipWithTitle);
        end
        do
            local IsSelected = function()
                return ppConfig.primary_crafter;
            end
            local SetSelected = function()
                ppConfig.primary_crafter = not ppConfig.primary_crafter;
                ProcessPrimaryCrafterUpdate(self.crafterInfo, ppConfig)
                CraftScan.OnCrafterListModified();

                local ppChangeOnly = true;
                CraftScanComm:ShareCharacterModification(self.crafterInfo.name, self.crafterInfo.parentProfessionID,
                    ppChangeOnly);
            end
            local data = {
                tooltipText = string.format(L(LID.PRIMARY_CRAFTER_TOOLTIP), crafter, profName),
            };
            local button = rootDescription:CreateCheckbox(L("Primary Crafter"), IsSelected, SetSelected, data)
            button:SetTooltip(SetTooltipWithTitle);
        end
    end);
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
    CraftScanCraftingOrderPage.BrowseFrame.LeftPanel.CrafterList.AutoReplyButton:SetButtonText();
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

CraftScan_OpenSettingsButtonMixin = {}

function CraftScan_OpenSettingsButtonMixin:OnLoad()
    self:SetText(L("Open Settings"))
end

function CraftScan_OpenSettingsButtonMixin:OnClick()
    CraftScan.Settings:Open();
end

CraftScan.Utils.onLoad(function()
    local frame = CraftScanCraftingOrderPage
    CraftScan.Frames.OrdersPage = frame
    table.insert(UISpecialFrames, "CraftScanCraftingOrderPage"); -- Make 'esc' close the frame
    UIPanelWindows["CraftScanCraftingOrderPage"] = { area = "doublewide", pushable = 1, whileDead = 1 }

    frame.BrowseFrame.AddonToggleButton:SetButtonText();
    frame.BrowseFrame.AutoReplyButton:SetButtonText();

    frame.BrowseFrame.LeftPanel.LinkedAccountList:Init();

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
