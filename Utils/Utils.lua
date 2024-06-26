local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan.Frames = {}
CraftScan.Utils = {}
CraftScan.Utils.DIAG_PRINT_ENABLED = true

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

local diagPrint = nil
local diagText = ''
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
        diagText = diagText .. "Not a table:" .. tostring(tbl) .. '\n'
    end

    if not diagPrint then
        diagPrint = CraftScan.Frames.createTextInput(nil, UIParent, 400, 800, "Diag Table Info", nil, "CraftScan_Debug",
            nil,
            function()
                return diagText
            end)
        diagPrint:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -250, -115)
    else
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

function CraftScan.Utils.ShouldShowAlertButton()
    return IsResting() and not InCinematic() and not IsInCinematicScene();
end

function CraftScan.Utils.ToggleSavedAddons()
    if CraftScan_DB.saved_addons then
        for _, name in ipairs(CraftScan_DB.saved_addons) do
            EnableAddOn(name)
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
    local numAddOns = GetNumAddOns()
    for i = 1, numAddOns do
        local name, _, _, enabled = GetAddOnInfo(i)
        if enabled and not whitelist[name] then
            table.insert(CraftScan_DB.saved_addons, name)
        end
    end

    -- Step 2: Disable all addons
    for _, name in ipairs(CraftScan_DB.saved_addons) do
        DisableAddOn(name)
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
            for profID, profConfig in pairs(charConfig.professions) do
                local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(profID);
                local parentProfConfigs = CraftScan.Utils.saved(charConfig, 'parent_professions', {});
                local parentProfConfig = CraftScan.Utils.saved(parentProfConfigs, profInfo.parentProfessionID, {
                    scanning_enabled = true,
                    visual_alert_enabled = true,
                    sound_alert_enabled = false,
                })
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
            if charConfig.primary_expansions then
                for parentProfessionID, professionID in pairs(charConfig.primary_expansions) do
                    charConfig.parent_professions[parentProfessionID].primary_expansion = professionID;
                end
                charConfig['primary_expansions'] = nil
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
    local v1, v2 = {}, {}
    for i = 1, 3 do
        v1[i], v2[i] = tonumber(version1:match("(%d+)", i + 1)), tonumber(version2:match("(%d+)", i + 1))
    end
    for i = 1, 3 do
        if v1[i] < v2[i] then return -1 end
        if v1[i] > v2[i] then return 1 end
    end
    return 0
end

local currentVersion = 'v1.0.0'

function CraftScan_RecentUpdatesMixin:OnHide()
    CraftScan.DB.settings.last_loaded_version = currentVersion;
    CraftScanRecentUpdatesFrame = nil;
end

local function NotifyRecentChanges()
    local lastLoadedVersion = CraftScan.Utils.GetSetting('last_loaded_version');
    if type(lastLoadedVersion) ~= 'string' then
        lastLoadedVersion = 'v0.0.0';
    end

    if CompareVersions(currentVersion, lastLoadedVersion) <= 0 then
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
        while b do
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
    BINDING_NAME_CRAFT_SCAN_DISMISS_CURRENT_CUSTOMER = string.format("%s - %s", L(LID.DISMISS_BUTTON_BINDING_NAME),
        L(LID.CRAFT_SCAN));

    -- We alias our SavedVariable so we can easily switch to non-persistent mode for testing.
    CraftScan.DB                                     = {}
    local persistentMode                             = true
    if persistentMode then
        CraftScan_DB = CraftScan_DB or {}

        CraftScan.DB.settings = CraftScan.Utils.saved(CraftScan_DB, 'settings', {})

        local realmDB = CraftScan.Utils.saved(CraftScan_DB, GetRealmName(), {})
        CraftScan.DB.characters = CraftScan.Utils.saved(realmDB, 'characters', {})
        CraftScan.DB.listed_orders = CraftScan.Utils.saved(realmDB, 'listed_orders', {})
        CraftScan.DB.customers = CraftScan.Utils.saved(realmDB, 'customers', {})
        CraftScan.DB.inclusions = CraftScan.Utils.saved(realmDB, 'inclusions', L(LID.GLOBAL_INCLUSION_DEFAULT));
        CraftScan.DB.exclusions = CraftScan.Utils.saved(realmDB, 'exclusions', L(LID.GLOBAL_EXCLUSION_DEFAULT));

        UpgradePersistentConfig()
    else
        CraftScan.DB.settings = {}
        CraftScan.DB.characters = {}
        CraftScan.DB.listed_orders = {}
        CraftScan.DB.customers = {}
        CraftScan.DB.inclusions = L(LID.GLOBAL_INCLUSION_DEFAULT);
        CraftScan.DB.exclusions = L(LID.GLOBAL_EXCLUSION_DEFAULT);
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
    if not IsAddOnLoaded("Blizzard_Professions") then
        LoadAddOn("Blizzard_Professions")
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
        local loaded, fullyLoaded = IsAddOnLoaded(entry)
        if fullyLoaded then
            doLoad()
        else
            EventUtil.ContinueOnAddOnLoaded(entry, function()
                doLoad()
            end)
        end
    end
end
