local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan.AnalyticsTableSortOrder = EnumUtil.MakeEnum("ItemName", "ProfessionName", "TotalSeen", "AveragePerDay",
    "PeakPerHour");

CraftScanAnalyticsTableConstants = {};
CraftScanAnalyticsTableConstants.StandardPadding = 10;
CraftScanAnalyticsTableConstants.NoPadding = 0;
CraftScanAnalyticsTableConstants.ItemName = {
    Width = 330,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.ProfessionName = {
    Width = 200,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
}
CraftScanAnalyticsTableConstants.TotalSeen = {
    Width = 80,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.AveragePerDay = {
    Width = 80,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.PeakPerHour = {
    Width = 80,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};

CraftScanAnalyticsTableBuilderMixin = CreateFromMixins(CraftScanTableBuilderMixin);

function CraftScanAnalyticsTableBuilderMixin:GetHeaderNameFromSortOrder(sortOrder)
    if sortOrder == CraftScan.AnalyticsTableSortOrder.ItemName then
        return PROFESSIONS_COLUMN_HEADER_ITEM;
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.ProfessionName then
        return L("Profession");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.TotalSeen then
        return L("Total Seen");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.AveragePerDay then
        return L("Avg Per Day");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.PeakPerHour then
        return L("Peak Per Hour");
    end
end

CraftScanAnalyticsCellItemNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsCellItemNameMixin:Populate(rowData)
    local itemInfo = rowData.item;

    -- The item is already loaded because we loaded it to generate this table row's source data.
    local item = Item:CreateFromItemID(itemInfo.itemID);
    local icon = item:GetItemIcon();
    self.Icon:SetTexture(icon);

    local qualityColor = item:GetItemQualityColor().color;
    local itemName = qualityColor:WrapTextInColorCode(item:GetItemName());
    self.Text:SetText(itemName);
end

CraftScanAnalyticsTableCellProfessionNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellProfessionNameMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.profession);
end

CraftScanAnalyticsTableCellTotalSeenMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellTotalSeenMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.totalSeen);
end

CraftScanAnalyticsTableCellAveragePerDayMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellAveragePerDayMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(string.format("%.2f", itemInfo.averagePerDay));
end

CraftScanAnalyticsTableCellPeakPerHourMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellPeakPerHourMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.peakPerHour);
end
