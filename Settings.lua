local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local function CreateDropdown(category, variable, key, name, options, tooltip, onChange)
    local default = CraftScan.CONST.DEFAULT_SETTINGS[key];

    local setting = Settings.RegisterAddOnSetting(category, variable, key, CraftScan.DB.settings, type(default), name,
        default);

    if onChange then
        setting:SetValueChangedCallback(function(setting, value)
            onChange(value)
        end);
    end
    local initializer = Settings.CreateDropdown(category, setting, options, tooltip);
    initializer:AddSearchTags(L(LID.CRAFT_SCAN));
end

-- No built in support for a multiple selection drop down, and I want to keep
-- everything in Blizzard style, so as you select one, generate another and the
-- multiple-ness is spread across multiple drop downs. The user can select the
-- same thing multiple times, but we'll dedupe it here ever reload.
-- 'variable' in this case is an array. We register a separate drop down for
-- each entry in the array, using the variable named 'variable<N>', where N is
-- the index in the array. Don't see a way to clean up a setting in real time, so
-- we just leave around extra defaults until a reload.
local function CreateMultiSelectDropdown(category, variable, name, options, tooltip, default)
    local db = CraftScan.Utils.saved(CraftScan.DB.settings, variable, {})
    local displayed = {};

    local seen = {}
    for i, value in ipairs(db) do
        if seen[value] then
            db[i] = default;
        end
        seen[value] = true;
    end

    local function FirstAvailableSequentialSetting()
        for i, value in ipairs(db) do
            if value == default then return i end
        end
        return #db + 1;
    end

    local function VariableNToN(variableN)
        return tonumber(string.sub(variableN, #variable + 1));
    end

    -- Create a new drop down. When its value changes to a non-default value,
    -- create another one if no non-default value boxes are already present.
    local function CreateOneDropdown(index, value)
        displayed[index] = true;
        local variableN = variable .. index;
        local setting = Settings.RegisterAddOnSetting(category, variableN, VariableNToN(variableN), db, type(default),
            name, default);

        setting:SetValueChangedCallback(function(setting, value)
            local available = FirstAvailableSequentialSetting();
            if value ~= default and not displayed[available] then
                CreateOneDropdown(available, default);
            end
        end);
        local initializer = Settings.CreateDropdown(category, setting, options, tooltip);
        initializer:AddSearchTags(L(LID.CRAFT_SCAN));
    end

    for i, value in ipairs(db) do
        if value ~= default then
            CreateOneDropdown(i, value)
        end
    end
    CreateOneDropdown(FirstAvailableSequentialSetting(), default)
end

local function CreateSlider(category, variable, name, options, tooltip)
    local default = CraftScan.CONST.DEFAULT_SETTINGS[variable];
    local setting = Settings.RegisterAddOnSetting(category, variable, variable, CraftScan.DB.settings, type(default),
        name, default);
    local initializer = Settings.CreateSlider(category, setting, options, tooltip);
    initializer:AddSearchTags(L(LID.CRAFT_SCAN));
end

local craftScanCategory = nil;
CraftScan.Utils.onLoad(function()
    local category, layout = Settings.RegisterVerticalLayoutCategory(L("CraftScan"));
    craftScanCategory = category;

    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer();
            for _, entry in ipairs(CraftScan.CONST.SOUNDS) do
                container:Add(entry.path, entry.name);
            end
            return container:GetData();
        end

        CreateDropdown(category, "CRAFT_SCAN_PING_SOUND", "ping_sound", L(LID.PING_SOUND_LABEL), GetOptions,
            L(LID.PING_SOUND_TOOLTIP),
            function(path)
                PlaySoundFile(path, "Master");
            end
        );
    end
    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer();
            container:Add(CraftScan.CONST.LEFT, L("Left"));
            container:Add(CraftScan.CONST.RIGHT, L("Right"));
            return container:GetData();
        end

        CreateDropdown(category, "CRAFT_SCAN_BANNER_DIRECTION", "banner_direction", L(LID.BANNER_SIDE_LABEL), GetOptions,
            L(LID.BANNER_SIDE_TOOLTIP));
    end
    do
        local options = Settings.CreateSliderOptions(1, 10, 1);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' ' .. (value == 1 and L("Minute") or L("Minutes")) end);
        CreateSlider(category, "customer_timeout", L(LID.CUSTOMER_TIMEOUT_LABEL), options,
            L(LID.CUSTOMER_TIMEOUT_TOOLTIP));
    end
    do
        local options = Settings.CreateSliderOptions(1, 60, 1);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' ' .. (value == 1 and L("Second") or L("Seconds")) end);
        CreateSlider(category, "banner_timeout", L(LID.BANNER_TIMEOUT_LABEL), options,
            L(LID.BANNER_TIMEOUT_TOOLTIP));
    end
    if CraftScan.CONST.AUTO_REPLIES_SUPPORTED then
        local options = Settings.CreateSliderOptions(250, 2000, 100);
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(value) return value .. ' ' .. (value == 1 and L("Millisecond") or L("Milliseconds")) end);
        CreateSlider(category, "auto_reply_delay", "Auto reply delay", options,
            "When auto replies are enabled, wait this long before replying to make youself seem a little less bot-like.");
    end

    do
        local variable = 'disabled_addon_whitelist';
        local default = CraftScan.CONST.DEFAULT_SETTINGS[variable];

        local function GetOptions()
            local container = Settings.CreateControlTextContainer();
            container:Add(default, default);

            local numAddOns = C_AddOns.GetNumAddOns()
            for i = 1, numAddOns do
                local name, _, _, enabled = C_AddOns.GetAddOnInfo(i)
                if name ~= 'CraftScan' then
                    container:Add(name, name);
                end
            end
            return container:GetData();
        end

        CreateMultiSelectDropdown(category, variable, L(LID.ADDON_WHITELIST_LABEL), GetOptions,
            L(LID.ADDON_WHITELIST_TOOLTIP), default
        );
    end

    Settings.RegisterAddOnCategory(category);
end)

CraftScan.Settings = {}

function CraftScan.Settings:Open()
    Settings.OpenToCategory(craftScanCategory:GetID());
end
