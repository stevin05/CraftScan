local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan_CustomExplanationsButtonMixin = {}

function CraftScan_CustomExplanationsButtonMixin:OnLoad()
    self:SetText(L("Custom Explanations"))
    self:FitToText();
end

local function MakeTextWhite(text)
    return "|cFFFFFFFF" .. text .. "|r";
end

local function OnCreate()
    local explanations = CraftScan.DB.settings.explanations;

    local Validator = function(index, label)
        if label == 'rev' then
            return { error = "'rev' is a reserved label" };
        end
        if explanations and explanations[label] then
            return { error = L(LID.EXPLANATION_DUPLICATE_LABEL) };
        end
    end

    local OnAccept = function(label, text)
        explanations[label] = text;
        CraftScanComm:ShareCustomExplanations(explanations);
    end

    local elements = {
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.EXPLANATION_LABEL_DESC),
        },
        {
            type = CraftScan.Dialog.Element.EditBox,
            Validator = Validator,
        },
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.EXPLANATION_TEXT_DESC),
        },
        {
            type = CraftScan.Dialog.Element.EditBox,
            multiline = true,
        },
    }
    CraftScan.Dialog.Show({
        key = "custom_explanations",
        title = L("Create an Explanation"),
        submit = L("Save"),
        OnAccept = OnAccept,
        elements = elements,
        width = 450,
    })
end

local function OnModify(label, text)
    local explanations = CraftScan.DB.settings.explanations;

    local Validator = function(index, newLabel)
        if label ~= newLabel and explanations and explanations[newLabel] then
            return { error = L(LID.EXPLANATION_DUPLICATE_LABEL) };
        end
    end

    local OnAccept = function(newLabel, text)
        if newLabel ~= label then
            explanations[label] = nil;
        end
        explanations[newLabel] = text;
        CraftScanComm:ShareCustomExplanations(explanations);
    end

    local elements = {
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.EXPLANATION_LABEL_DESC),
        },
        {
            type = CraftScan.Dialog.Element.EditBox,
            Validator = Validator,
            initial_text = label,
            default_text = label,
            default_label = L("Reset"),
        },
        {
            type = CraftScan.Dialog.Element.Text,
            text = L(LID.EXPLANATION_TEXT_DESC),
        },
        {
            type = CraftScan.Dialog.Element.EditBox,
            initial_text = text,
            default_text = text,
            default_label = L("Reset"),
            multiline = true,
        },
    }
    CraftScan.Dialog.Show({
        key = "custom_explanations",
        title = L("Create an Explanation"),
        submit = L("Save"),
        OnAccept = OnAccept,
        elements = elements,
        width = 450,
    })
end

local function OnDelete(label)
    local explanations = CraftScan.DB.settings.explanations;
    explanations[label] = nil;
    CraftScanComm:ShareCustomExplanations(explanations);
end

function CraftScan_CustomExplanationsButtonMixin:Init()
    if not CraftScan.DB.settings.explanations then
        CraftScan.DB.settings.explanations = {};
    end

    -- Sort the explanations so we aren't getting random dictionary order.
    local CreateUIExplanations = function()
        local explanations = {};

        for label, text in pairs(CraftScan.DB.settings.explanations) do
            if label ~= 'rev' then
                table.insert(explanations, { label = label, text = text });
            end
        end
        table.sort(explanations, function(a, b) return a.label < b.label; end)

        return explanations;
    end

    -- The drop down button used to configure explanations
    self:SetupMenu(function(owner, rootDescription)
        local explanations = CreateUIExplanations();
        for _, entry in ipairs(explanations) do
            local label = entry.label;
            local text = entry.text;
            local subMenu = rootDescription:CreateButton(label);
            subMenu:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_AddNormalLine(tooltip, MakeTextWhite(text));
            end);
            subMenu:CreateButton(L("Modify"), function() OnModify(label, text) end);
            subMenu:CreateButton(L("Delete"), function() OnDelete(label) end);
        end

        rootDescription:CreateButton(L("Create"), OnCreate);
    end)

    -- Inject our buttons on the right click of a name in chat.
    Menu.ModifyMenu("MENU_UNIT_FRIEND", function(owner, rootDescription, contextData)
        rootDescription:CreateDivider();
        local title = rootDescription:CreateTitle(L("CraftScan") .. " - " .. L(LID.MANUAL_MATCHING_TITLE));
        title:SetTooltip(function(tooltip, elementDescription)
            GameTooltip_AddNormalLine(tooltip, MakeTextWhite(L(LID.MANUAL_MATCHING_DESC)));
        end);

        local crafterRows = CraftScan.GetSortedCrafters();
        for _, crafterInfo in ipairs(crafterRows) do
            local char = crafterInfo.name;
            local charConfig = CraftScan.DB.characters[char];
            local ppID = crafterInfo.parentProfessionID;
            local ppConfig = charConfig.parent_professions[ppID];

            if ppConfig.scanning_enabled and not ppConfig.character_disabled then
                local profName = CraftScan.Utils.ProfessionNameByID(ppID);
                rootDescription:CreateButton(
                    string.format(L(LID.MANUAL_MATCH), CraftScan.ColorizeCrafterName(char),
                        CraftScan.Utils.ColorizeProfessionName(ppID, profName)),
                    function()
                        -- Force the message through as if it were a match for the specified profession.
                        local customer = contextData.chatTarget;
                        local message = C_ChatInfo.GetChatLineText(contextData.lineID)
                        local customerGuid = C_ChatInfo.GetChatLineSenderGUID(contextData.lineID)
                        CraftScan.OnMessage(nil, message, customer, customerGuid, {
                            crafter = char,
                            parentProfID = ppID,
                        });
                    end);
            end
        end

        if next(CraftScan.DB.settings.explanations) then
            rootDescription:CreateDivider();
            rootDescription:CreateTitle(L("CraftScan") .. " - " .. L("Custom Explanations"));
            local explanations = CreateUIExplanations();
            for _, entry in ipairs(explanations) do
                local label = entry.label;
                local text = entry.text;
                local button = rootDescription:CreateButton(label, function()
                    local message = CraftScan.Utils.SplitResponse(text);
                    CraftScan.Utils.SendResponses(message, contextData.chatTarget)
                end);

                button:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddNormalLine(tooltip, MakeTextWhite(text));
                end);
            end
        end
    end);
end
