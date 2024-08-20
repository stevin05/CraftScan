local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan.Frames = {}
CraftScan.Utils = {}
CraftScan.Utils.DIAG_PRINT_ENABLED = true

function CraftScan.Utils.Contains(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

local function DeepCopy_(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[DeepCopy_(key)] = DeepCopy_(value)
        end
        setmetatable(copy, DeepCopy_(getmetatable(original)))
    else -- number, string, boolean, etc.
        copy = original
    end
    return copy
end

function CraftScan.Utils.DeepCopy(original)
    return DeepCopy_(original);
end

function CraftScan.Utils.ColorizeProfessionName(profID, professionName)
    local color = CraftScan.CONST.PROFESSION_COLORS[profID];
    if color then
        return string.format("|%s%s|r", color, professionName)
    end
    return professionName
end

function CraftScan.Utils.SendResponses(responses, customer)
    for _, response in pairs(responses) do
        SendChatMessage(response, "WHISPER", GetDefaultLanguage("player"), customer)
    end
end

function CraftScan.Frames.createLabel(labelText, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, updateDisplay)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(labelText)
    label:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    label:SetTextColor(1, 1, 1)
    label:SetFont("Fonts\\FRIZQT__.TTF", 12, "NONE")

    if updateDisplay then
        label.updateDisplay = function()
            label:SetText(updateDisplay() or "<unset>")
        end
    end
    return label
end

function CraftScan.Frames.createTextInput(name, parent, sizeX, sizeY, labelText, initialValue, template,
                                          onTextChangedCallback, updateDisplay, parentScrollFrame)
    local textFrame = CreateFrame("Frame", nil, parent)
    textFrame:SetSize(sizeX, sizeY + 22)

    local scrollFrame = CreateFrame("ScrollFrame", nil, textFrame, template)
    scrollFrame:SetPoint("TOPLEFT", textFrame, "TOPLEFT", 0, -17)
    scrollFrame:SetSize(sizeX, sizeY)
    scrollFrame.EditBox.Instructions:SetWidth(sizeX);

    local textInput = scrollFrame.EditBox
    textInput:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    textInput:SetSize(sizeX - 20, sizeY)
    textInput:SetAutoFocus(false) -- dont automatically focus
    textInput:SetFontObject("ChatFontNormal")
    textInput:SetText(initialValue or updateDisplay())
    textInput:SetMultiLine(true)
    textInput:SetScript("OnEscapePressed", function()
        textInput:ClearFocus()
    end)
    if onTextChangedCallback then
        textInput:SetScript("OnEditFocusLost", onTextChangedCallback)
    end

    if parentScrollFrame then
        -- When at the limits of the text scroll frame, delegate to the parent scroll frame.
        local function IsScrollLimit(delta)
            if delta < 0 then
                local maxScroll = scrollFrame:GetVerticalScrollRange()
                local currentScroll = scrollFrame:GetVerticalScroll()
                return (maxScroll - currentScroll) <= 0.001;
            else
                return
                    scrollFrame:GetVerticalScroll() == 0;
            end
        end


        local scrollParent = parentScrollFrame:GetScript("OnMouseWheel");
        local scrollText = scrollFrame:GetScript("OnMouseWheel");
        scrollFrame:SetScript("OnMouseWheel", function(_, delta)
            if IsScrollLimit(delta) then
                scrollParent(parentScrollFrame, delta);
            else
                scrollText(scrollFrame, delta);
            end
        end)
    end

    CraftScan.Frames.createLabel(labelText .. ':', textFrame, textFrame, "TOPLEFT", "TOPLEFT", 0, 0)

    if updateDisplay then
        textFrame.updateDisplay = function()
            textInput:SetText(updateDisplay() or "")
        end
    end
    return textFrame
end

local diagPrintFrame = nil
local diagPrint      = nil
local diagText       = ''
function CraftScan.Utils.printTable(label, tbl, indent)
    if not CraftScan.Utils.DIAG_PRINT_ENABLED then
        return
    end

    indent = indent or 0
    local checkedTables = {} -- To keep track of tables we've already printed

    diagText = diagText .. label .. ": "
    local function innerPrint(tbl, indent)
        for k, v in pairs(tbl) do
            -- Check if v is a table and hasn't been printed before
            if type(v) == "table" then
                if checkedTables[v] then
                    diagText = diagText .. string.rep("  ", indent) .. tostring(k) .. " = " .. tostring(v) ..
                        ' (repeat reference)\n'
                else
                    checkedTables[v] = true   -- Mark table as checked
                    diagText = diagText .. string.rep("  ", indent) .. tostring(k) .. " = {" .. '\n'
                    innerPrint(v, indent + 1) -- Recursive call
                    diagText = diagText .. string.rep("  ", indent) .. "}" .. '\n'
                end
            else
                diagText = diagText .. string.rep("  ", indent) .. tostring(k) .. " = " .. tostring(v) .. '\n'
            end
        end
    end

    if type(tbl) == "table" then
        diagText = diagText .. '{' .. '\n'
        innerPrint(tbl, indent + 1)
        diagText = diagText .. '}' .. '\n'
    else
        diagText = diagText .. tostring(tbl) .. '\n'
    end

    if not diagPrint then
        diagPrintFrame = CreateFrame("Frame", "Section", UIParent, "CraftScan_DebugFrame")
        diagPrint = CraftScan.Frames.createTextInput("Frame", diagPrintFrame, 400, 800,
            "https://github.com/stevin05/CraftScan", nil, "CraftScan_Debug",
            nil,
            function()
                return diagText
            end)
        diagPrintFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -250, -115)
        diagPrintFrame:SetTitle("CraftScan Debug Log");
        diagPrint:SetPoint("TOPLEFT", diagPrintFrame, "TOPLEFT", 15, -25)
    else
        diagPrintFrame:Show()
        diagPrint.updateDisplay()
    end
end

function CraftScan.Utils.debug_print(...)
    if CraftScan.Utils.DIAG_PRINT_ENABLED then
        print(...)
    end
end

function CraftScan.Frames.CreateVerticalLayoutOrganizer(anchor, xPadding, yPadding)
    local OrganizerMixin = {
        entries = {}
    };

    xPadding = xPadding or 0;
    yPadding = yPadding or 0;

    function OrganizerMixin:Add(frame, xPadding, yPadding, child)
        table.insert(self.entries, {
            frame = frame,
            child = child,
            xPadding = xPadding or 0,
            yPadding = yPadding or 0
        });
    end

    function OrganizerMixin:Resize(frame)
        local height = frame:GetTop() - self.entries[#self.entries].frame:GetBottom();
        if self.entries[#self.entries].frame.needsExtraYPadding then
            height = height + 16
        end
        if height < 200 then height = 200 end
        frame:SetSize(frame:GetWidth(), height);
        if frame.BackgroundTop then
            frame.BackgroundTop:SetSize(frame:GetWidth() - 20, 100);
            frame.BackgroundBottom:SetSize(frame:GetWidth() - 20, 100);
        end
    end

    function OrganizerMixin:Layout(parentXPadding)
        local anchorA, anchorFrame, anchorB, offsetX, offsetY = anchor:Get()

        local yPosition = 0 - offsetY - yPadding;

        for index, entry in ipairs(self.entries) do
            if entry.child then
                entry.child:Layout(offsetX + xPadding + entry.xPadding)
                entry.child:Resize(entry.frame)
            end

            local xPosition = (parentXPadding or 0) + offsetX + xPadding + entry.xPadding
            yPosition = yPosition - entry.yPadding;

            entry.frame:ClearAllPoints();
            entry.frame:SetPoint(anchorA, anchorFrame, anchorB, xPosition, yPosition)

            yPosition = yPosition - entry.frame:GetHeight()
        end
    end

    return CreateFromMixins(OrganizerMixin);
end

function CraftScan.Frames.createOptionsBlock(titleText, parent, organizer, updateDisplay)
    local options = CreateFrame("Frame", "Section", parent, "CraftScan_SectionTemplate")

    local anchor = AnchorUtil.CreateAnchor("TOPLEFT", options, "TOPLEFT", 0, 50);
    local childOrganizer = CraftScan.Frames.CreateVerticalLayoutOrganizer(anchor, 5, 0);

    if titleText then
        options.Label:SetText(titleText)
    end

    organizer:Add(options, 1, 0, childOrganizer)

    if updateDisplay then
        local function OnDone(text)
            options.Label:SetText(text);
        end
        options.updateDisplay = function()
            local value = updateDisplay(OnDone);
            if value then
                OnDone(value);
                -- else hope they call OnDone.
            end
        end
    end

    return childOrganizer, options
end

function CraftScan.Frames.createCheckBox(labelText, parent, onClickCallback, updateDisplay)
    local checkBox = CreateFrame("CheckButton", nil, parent)
    checkBox:SetSize(25, 25)

    checkBox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkBox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkBox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
    checkBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    checkBox:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");

    if onClickCallback then
        checkBox:SetScript("OnClick", onClickCallback)
    end

    local label = checkBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(labelText)
    label:SetPoint("LEFT", checkBox, "RIGHT", 0, 0) -- Position to the right of the checkbox
    label:SetTextColor(1, 1, 1)
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "NONE")

    if updateDisplay then
        checkBox.updateDisplay = function()
            local checked, shown = updateDisplay()
            checkBox:SetChecked(checked)
            if shown then
                checkBox:Show()
            else
                checkBox:Hide()
            end
        end
    end

    checkBox.needsExtraYPadding = true
    checkBox.label = label;
    return checkBox
end

function CraftScan.Frames.makeMovable(frame)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
end

function CraftScan.Frames.flipTextureHorizontally(texture)
    local ulx, uly, llx, lly, urx, ury, lrx, lry = texture:GetTexCoord()
    texture:SetTexCoord(urx, ury, lrx, lry, ulx, uly, llx, lly)
end

function CraftScan.Frames.flipTextureVertically(texture)
    local ulx, uly, llx, lly, urx, ury, lrx, lry = texture:GetTexCoord()
    texture:SetTexCoord(llx, lly, ulx, uly, lrx, lry, urx, ury)
end

function CraftScan.Utils.saved(parent, child, default)
    if not parent then
        return nil
    end
    if default and not parent[child] then
        parent[child] = default
    end
    return parent[child]
end

function CraftScan.Utils.AddonsAreSaved()
    return CraftScan_DB.saved_addons
end

-- A check to be paired with RegisterEnableDisableCallback to perform actions to
-- enable/disable this addons functionality. The callback arguments should be
-- passed through to this helper.
function CraftScan.Utils.IsScanningEnbled(event)
    return IsResting() and event ~= "CINEMATIC_START" and event ~= "PLAY_MOVIE"
end

function CraftScan.Utils.RegisterEnableDisableCallback(callback)
    CraftScanScannerMenu:RegisterEventCallback("PLAYER_UPDATE_RESTING", callback);
    CraftScanScannerMenu:RegisterEventCallback("ZONE_CHANGED_NEW_AREA", callback);
    CraftScanScannerMenu:RegisterEventCallback("CINEMATIC_START", callback);
    CraftScanScannerMenu:RegisterEventCallback("CINEMATIC_STOP", callback);
    CraftScanScannerMenu:RegisterEventCallback("PLAY_MOVIE", callback);
    CraftScanScannerMenu:RegisterEventCallback("STOP_MOVIE", callback);
end

function CraftScan.Utils.ToggleSavedAddons()
    if CraftScan_DB.saved_addons then
        for _, name in ipairs(CraftScan_DB.saved_addons) do
            C_AddOns.EnableAddOn(name)
        end

        print("Addons enabled. Reload UI.")
        CraftScan_DB.saved_addons = nil

        return;
    end

    local configWhitelist = CraftScan.Utils.saved(CraftScan.DB.settings, 'disabled_addon_whitelist',
        {})
    local whitelist = { CraftScan = true };
    for _, value in ipairs(configWhitelist) do
        whitelist[value] = true;
    end

    CraftScan_DB.saved_addons = {}
    local numAddOns = C_AddOns.GetNumAddOns()
    for i = 1, numAddOns do
        local name, _, _, enabled = C_AddOns.GetAddOnInfo(i)
        if enabled and not whitelist[name] then
            table.insert(CraftScan_DB.saved_addons, name)
        end
    end

    -- Step 2: Disable all addons
    for _, name in ipairs(CraftScan_DB.saved_addons) do
        C_AddOns.DisableAddOn(name)
    end
end

local function UpgradePersistentConfig()
    -- As we make changes to the SavedVariable format, upgrade it here globally
    -- before anything else runs against it so we don't need conditionals
    -- anywhere else.

    -- Upgrade the profession configuration to create a normalized 'parent
    -- profession' node. The professionIDs we usually deal with are 'Dragon
    -- Isles Blacksmithing', but we present most options per parent profession
    -- (e.g. 'Blacksmithing'). Save state directly in the parent profession
    -- instead of the child professions now. Link the children to the parent.
    for _, charConfig in pairs(CraftScan.DB.characters) do
        charConfig['enabled'] = nil
        if charConfig.professions then
            local secondaryProfs = {};
            for profID, profConfig in pairs(charConfig.professions) do
                local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(profID);

                -- 'Supply Shipments' is a profession in the emerald dream. It
                -- is marked as a primary profession, so got through our
                -- filters, but it does not have a parentProfessionID.
                if not profInfo.isPrimaryProfession or not profInfo.parentProfessionID or not CraftScan.CONST.PROFESSION_DEFAULT_KEYWORDS[profInfo.parentProfessionID] then
                    table.insert(secondaryProfs, profID);
                    if profInfo.parentProfessionID then
                        charConfig.parent_professions[profInfo.parentProfessionID] = nil;
                    end
                else
                    local parentProfConfigs = CraftScan.Utils.saved(charConfig, 'parent_professions', {});
                    local parentProfConfig = CraftScan.Utils.saved(parentProfConfigs, profInfo.parentProfessionID,
                        CraftScan.Utils.DeepCopy(CraftScan.CONST.DEFAULT_PPCONFIG));
                    profConfig.parentProfID = profInfo.parentProfessionID;
                    profConfig['scanning_enabled'] = nil
                    profConfig['auto_reply'] = nil

                    -- Moving profession keywords over to the parent profession so
                    -- they are only configured once. An item match will then
                    -- trigger its expansion's greeting, or if a generic match is
                    -- made, we use the primary expansion's greeting.
                    local keywords = profConfig['keywords'];
                    if keywords then
                        if parentProfConfig['keywords'] then
                            if #keywords > #parentProfConfig['keywords'] then
                                parentProfConfig['keywords'] = keywords;
                            end
                        else
                            parentProfConfig['keywords'] = keywords;
                        end
                        profConfig['keywords'] = nil;
                    end
                end
            end
            for _, profID in ipairs(secondaryProfs) do
                -- We were accidentally saving secondary profs in the past. Erase them if found in the persistent config.
                charConfig.professions[profID] = nil;
            end
            if charConfig.primary_expansions then
                for parentProfessionID, professionID in pairs(charConfig.primary_expansions) do
                    charConfig.parent_professions[parentProfessionID].primary_expansion = professionID;
                end
                charConfig['primary_expansions'] = nil
            end
        end
    end

    -- These two were never saving correctly in this location, so it only holds the defaults.
    -- Now located at CraftScan_DB.settings.{inclusions,exclusions}
    CraftScan_DB['inclusions'] = nil;
    CraftScan_DB['exclusions'] = nil;

    -- Now that we have a proper addon whitelist control, erase all the
    -- 'None's that might have snuck into the list.
    do
        local whitelist = CraftScan.DB.settings.disabled_addon_whitelist;
        if whitelist then
            for i = #whitelist, 1, -1 do
                if whitelist[i] == "None" then
                    table.remove(whitelist, i)
                end
            end
        end
    end

    if CraftScan.DB.settings.linked_accounts then
        for _, info in pairs(CraftScan.DB.settings.linked_accounts) do
            if info.backup_char then
                info.backup_chars = {};
                table.insert(info.backup_chars, info.backup_char)
                info.backup_char = nil;
            end
        end
    end
end

function CraftScan.Utils.GetSetting(key)
    local value = CraftScan.DB.settings[key];
    if value then return value end

    return CraftScan.CONST.DEFAULT_SETTINGS[key];
end

CraftScan_RecentUpdatesMixin = {}

local function CompareVersions(version1, version2)
    local function extractVersion(version)
        local numbers = {}
        for num in version:gmatch("%d+") do
            table.insert(numbers, tonumber(num))
        end
        return numbers
    end

    local v1 = extractVersion(version1);
    local v2 = extractVersion(version2);
    for i = 1, 3 do
        if v1[i] < v2[i] then return -1 end
        if v1[i] > v2[i] then return 1 end
    end
    return 0
end

CraftScan.CONST.CURRENT_VERSION = 'v1.2.0';

function CraftScan_RecentUpdatesMixin:OnHide()
    CraftScan.DB.settings.last_loaded_version = CraftScan.CONST.CURRENT_VERSION;
    CraftScanRecentUpdatesFrame = nil;
end

local function NotifyRecentChanges()
    local lastLoadedVersion = CraftScan.Utils.GetSetting('last_loaded_version');
    if type(lastLoadedVersion) ~= 'string' then
        lastLoadedVersion = 'v0.0.0';
    end

    if CompareVersions(CraftScan.CONST.CURRENT_VERSION, lastLoadedVersion) <= 0 then
        return;
    end

    local releaseNotes = {
        {
            version = 'v1.0.0',
            id = LID.RN_WELCOME,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_INITIAL_SETUP,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_INITIAL_TESTING,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_MANAGING_CRAFTERS,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_MANAGING_CUSTOMERS,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_KEYBINDS,
        },
        {
            version = 'v1.0.10',
            id = LID.RN_CLEANUP,
        },
    };

    local anchor = AnchorUtil.CreateAnchor("TOP", CraftScanRecentUpdatesFrame.ScrollFrame.Content, "TOP");
    local organizer = CraftScan.Frames.CreateVerticalLayoutOrganizer(anchor, 0, 0);

    local function CreateSection(section)
        local frame = CreateFrame("Frame", nil, CraftScanRecentUpdatesFrame.ScrollFrame.Content,
            "CraftScan_RecentUpdatesSectionTemplate");
        organizer:Add(frame);

        frame.Header:SetText(L(section.id));
        frame.Version:SetText(string.format("%s %s", L("Version"), section.version));

        local body = L(section.id + 1);
        local i = 2;
        local b = L(section.id + i);
        while b ~= section.id + i do
            body = body .. '\n\n' .. b;
            i = i + 1;
            b = L(section.id + i);
        end
        frame.Body:SetText(body);
        frame:SetSize(360, frame.Body:GetStringHeight() + 40)
    end

    for _, entry in ipairs(releaseNotes) do
        if CompareVersions(entry.version, lastLoadedVersion) > 0 then
            CreateSection(entry);
        end
    end

    organizer:Layout();
    CraftScan.Frames.makeMovable(CraftScanRecentUpdatesFrame)
    CraftScanRecentUpdatesFrame.ScrollFrame:SetScrollChild(CraftScanRecentUpdatesFrame.ScrollFrame.Content)
    CraftScanRecentUpdatesFrame:SetTitle(L("CraftScan Release Notes"));
    CraftScanRecentUpdatesFrame:Show();
end

local once = false
local function doOnce()
    if once then
        return
    end
    -- Things that should happen one time before any other files run their init

    -- Can't seem to internationalize the binding header anymore. Comes as a raw string in Bindings.xml
    -- Can't find a proper API to tag these as search-able, so tossing the name in there.
    BINDING_NAME_CRAFT_SCAN_TOGGLE                   = string.format("%s - %s", L(LID.MAIN_BUTTON_BINDING_NAME),
        L(LID.CRAFT_SCAN));
    BINDING_NAME_CRAFT_SCAN_GREET_CURRENT_CUSTOMER   = string.format("%s - %s", L(LID.GREET_BUTTON_BINDING_NAME),
        L(LID.CRAFT_SCAN));
    BINDING_NAME_CRAFT_SCAN_CHAT_CURRENT_CUSTOMER    = string.format("%s - %s", L(LID.CHAT_BUTTON_BINDING_NAME),
        L(LID.CRAFT_SCAN));
    BINDING_NAME_CRAFT_SCAN_DISMISS_CURRENT_CUSTOMER = string.format("%s - %s", L(LID.DISMISS_BUTTON_BINDING_NAME),
        L(LID.CRAFT_SCAN));

    -- We alias our SavedVariable so we can easily switch to non-persistent mode for testing.
    CraftScan.DB                                     = {}
    local persistentMode                             = true
    if persistentMode then
        CraftScan_DB = CraftScan_DB or {}

        CraftScan.DB.settings = CraftScan.Utils.saved(CraftScan_DB, 'settings', {})
        CraftScan.DB.settings.inclusions = CraftScan.DB.settings.inclusions or L(LID.GLOBAL_INCLUSION_DEFAULT);
        CraftScan.DB.settings.exclusions = CraftScan.DB.settings.exclusions or L(LID.GLOBAL_EXCLUSION_DEFAULT);

        local realmDB = CraftScan.Utils.saved(CraftScan_DB, GetRealmName(), {})
        CraftScan.DB.characters = CraftScan.Utils.saved(realmDB, 'characters', {})
        CraftScan.DB.listed_orders = CraftScan.Utils.saved(realmDB, 'listed_orders', {})
        CraftScan.DB.customers = CraftScan.Utils.saved(realmDB, 'customers', {})

        UpgradePersistentConfig()
    else
        CraftScan.DB.settings = {}
        CraftScan.DB.settings.inclusions = L(LID.GLOBAL_INCLUSION_DEFAULT);
        CraftScan.DB.settings.exclusions = L(LID.GLOBAL_EXCLUSION_DEFAULT);
        CraftScan.DB.characters = {}
        CraftScan.DB.listed_orders = {}
        CraftScan.DB.customers = {}
    end

    CraftScan.STATE = {};

    local prof1, prof2 = GetProfessions()
    CraftScan.CONST.PROFESSIONS = {};
    for _, prof in ipairs({ prof1, prof2 }) do
        local _, icon, _, _, _, _, professionID = GetProfessionInfo(prof);
        local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(professionID);
        CraftScan.STATE.professionID = professionID;
        table.insert(CraftScan.CONST.PROFESSIONS, {
            professionID = professionID,
            icon = icon,
            profession = professionInfo.profession,
        });
    end

    NotifyRecentChanges();

    CraftScanComm:ShareCharacterData();

    once = true
end

CraftScan.Utils.CurrentProfession = function()
    local prof = nil;
    for _, p in ipairs(CraftScan.CONST.PROFESSIONS) do
        if C_TradeSkillUI.IsNearProfessionSpellFocus(p.profession) then
            return p;
        elseif CraftScan.STATE.professionID == p.professionID then
            prof = p
        elseif not prof then
            prof = p
        end
    end
    return prof;
end

local loginFrame = CreateFrame("Frame")
local loadOnLogin = {}
local requiredAddons = { "CraftScan", "Blizzard_Professions" }
function CraftScan.Utils.onLoad(onLoad)
    if not C_AddOns.IsAddOnLoaded("Blizzard_Professions") then
        C_AddOns.LoadAddOn("Blizzard_Professions")
    end

    local count = 0

    local function doLoad()
        count = count + 1
        if (count ~= #requiredAddons) then
            return
        end
        if not IsLoggedIn() then
            table.insert(loadOnLogin, onLoad)
            if not loginFrame:GetScript("OnEvent") then
                -- SavedVariables are not available until the player is logged in.
                loginFrame:RegisterEvent("PLAYER_LOGIN")
                loginFrame:SetScript("OnEvent", function(self, event, ...)
                    if event == "PLAYER_LOGIN" then
                        doOnce()
                        for _, onLoad in ipairs(loadOnLogin) do
                            onLoad()
                        end
                        loginFrame = nil
                    end
                end)
            end
        else
            doOnce()
            onLoad()
        end
    end

    for _, entry in ipairs(requiredAddons) do
        local loaded, fullyLoaded = C_AddOns.IsAddOnLoaded(entry)
        if fullyLoaded then
            doLoad()
        else
            EventUtil.ContinueOnAddOnLoaded(entry, function()
                doLoad()
            end)
        end
    end
end

local function GetMaxTextLeftWidth(tooltipName)
    local tooltip = _G[tooltipName];
    if not tooltip then
        return nil;
    end

    local maxWidth = 0;

    for i = 1, tooltip:GetNumRegions() do
        local region = select(i, tooltip:GetRegions());
        if region and region:GetObjectType() == "FontString" and region:GetName() and region:GetName():match("TextLeft") then
            local width = region:GetStringWidth();
            if width > maxWidth then
                maxWidth = width;
            end
        end
    end

    return maxWidth;
end

-- I want the help text in the top right corner of the tooltip, which uses
-- TextRight. With no TextLeft associated with them, they were vertically
-- overlapping. This method walks the right text of a tooltip and manually
-- spaces it out to look nice.
local function SpaceOutRightText(tooltipName)
    local tooltip = _G[tooltipName];
    if not tooltip then
        return;
    end

    local lastRegion = nil;
    for i = 1, tooltip:GetNumRegions() do
        local region = select(i, tooltip:GetRegions())
        if region and region:GetObjectType() == "FontString" and region:GetName() and region:GetName():match("TextRight") then
            if lastRegion then
                region:SetPoint("TOPRIGHT", lastRegion, "BOTTOMRIGHT", 0, -1);
            end
            lastRegion = region;
        end
    end
end

-- This method is a bit of mess now that we're only ever populating a single %s,
-- but too lazy to fix atm.
CraftScan.Utils.PopulateBinds = function(lid, ...)
    local binds = { ... };
    for i, bind in ipairs(binds) do
        local b = GetBindingKey(bind);
        if b then
            binds[i] = ' |cffffd100(' .. b .. ')|r';
        else
            binds[i] = '';
        end
    end
    if not next(binds) then
        return string.format(L(lid), '');
    end
    return string.format(L(lid), unpack(binds));
end

CraftScan.Utils.ChatHistoryTooltip = {}
CraftScan.Utils.ChatHistoryTooltip.__index = CraftScan.Utils.ChatHistoryTooltip;

function CraftScan.Utils.ChatHistoryTooltip:new()
    local instance = setmetatable({}, CraftScan.Utils.ChatHistoryTooltip);
    instance.tooltip = nil;
    return instance;
end

function CraftScan.Utils.ChatHistoryTooltip:Hide()
    if self.tooltip then self.tooltip:Hide() end
end

function CraftScan.Utils.ChatHistoryTooltip:Show(name, anchor, order, header, includeBinds)
    if not self.tooltip then
        self.tooltip = CreateFrame("GameTooltip", name, UIParent, "GameTooltipTemplate");
        self.tooltip.TextLeft2:SetFontObject(ChatFrame1:GetFontObject());
        self.tooltip.TextRight1:SetFontObject(self.tooltip.TextRight2:GetFontObject());
    end

    local tooltip = self.tooltip;
    tooltip:ClearLines();

    tooltip:SetOwner(anchor, "ANCHOR_TOPLEFT");

    local response = CraftScan.OrderToResponse(order)
    if response.greeting_sent then
        tooltip:AddDoubleLine(header, L("Chat Help"), 1, 1, 1);
    else
        tooltip:AddDoubleLine(header,
            CraftScan.Utils.PopulateBinds(L("Greet Help"), includeBinds and "CRAFT_SCAN_GREET_CURRENT_CUSTOMER"), 1, 1, 1);
        tooltip:AddDoubleLine("",
            CraftScan.Utils.PopulateBinds(L("Chat Override"), includeBinds and "CRAFT_SCAN_CHAT_CURRENT_CUSTOMER"));
    end
    tooltip:AddDoubleLine("",
        CraftScan.Utils.PopulateBinds(L("Dismiss"), includeBinds and "CRAFT_SCAN_DISMISS_CURRENT_CUSTOMER"));

    GameTooltip_AddBlankLineToTooltip(tooltip);

    if not response.greeting_sent then
        tooltip:AddLine(L("Proposed Greeting"), 1, 1, 1);
        local wc = ChatTypeInfo["WHISPER"]
        for _, line in ipairs(response.message) do
            tooltip:AddLine(line, wc.r, wc.g, wc.b, true, 0);
        end

        GameTooltip_AddBlankLineToTooltip(tooltip);
    end

    local customerInfo = CraftScan.OrderToCustomerInfo(order)
    for _, chat in ipairs(customerInfo.chat_history) do
        if chat.args then
            local r, g, b = unpack(chat.args);
            tooltip:AddLine(chat.message, r, g, b, true, 0);
        else
            tooltip:AddLine(chat.message, 1, 1, 1, true, 0);
        end
    end

    SpaceOutRightText(name);

    -- Find the maximum text width so we can make the tooltip look sane. If it's
    -- super long, cap at the chat frame width to match its text wrapping.
    tooltip:SetMinimumWidth(math.min(GetMaxTextLeftWidth(name), ChatFrame1:GetWidth()));

    tooltip:Show();
end
