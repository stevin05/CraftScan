local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local function CreateDropDown(category, variable, name, options, tooltip, onChange)
    local default = CraftScan.CONST.DEFAULT_SETTINGS[variable];
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(default), default);

    setting:SetValue(CraftScan.Utils.GetSetting(variable));
    Settings.SetOnValueChangedCallback(variable, function(event)
        local value = setting:GetValue();
        CraftScan.DB.settings[variable] = value;
        if onChange then onChange(value) end
    end);
    local initializer = Settings.CreateDropDown(category, setting, options, tooltip);
    initializer:AddSearchTags(L(LID.CRAFT_SCAN));
end

local function CreateSlider(category, variable, name, options, tooltip)
    local default = CraftScan.CONST.DEFAULT_SETTINGS[variable];
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(default), default);

    setting:SetValue(CraftScan.Utils.GetSetting(variable));
    Settings.SetOnValueChangedCallback(variable, function(event)
        local value = setting:GetValue();
        CraftScan.DB.settings[variable] = value;
    end);
    local initializer = Settings.CreateSlider(category, setting, options, tooltip);
    initializer:AddSearchTags(L(LID.CRAFT_SCAN));
end

CraftScan.Utils.onLoad(function()
    local category, layout = Settings.RegisterVerticalLayoutCategory(L("CraftScan"));
    Settings.RegisterAddOnCategory(category);

    do
        local function GetOptions()
            local container = Settings.CreateControlTextContainer();
            for _, entry in ipairs(CraftScan.CONST.SOUNDS) do
                container:Add(entry.path, entry.name);
            end
            return container:GetData();
        end

        CreateDropDown(category, "ping_sound", L(LID.PING_SOUND_LABEL), GetOptions, L(LID.PING_SOUND_TOOLTIP),
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

        CreateDropDown(category, "banner_direction", L(LID.BANNER_SIDE_LABEL), GetOptions, L(LID.BANNER_SIDE_TOOLTIP));
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
end)
