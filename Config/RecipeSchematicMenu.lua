local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT
local function L(id)
    return CraftScan.LOCAL:GetText(id)
end

-- References to our saved variables. These are populated as we get the
-- information needed to populate them.
local playerNameWithRealm = nil
local db_player = nil
local db_prof = nil
local db_parent_prof = nil
local db_recipes = nil
local db_current_expansion_recipes = nil
local currentExpansionProfID = nil
local selectedRecipeID = nil

local saved = CraftScan.Utils.saved

local showMenuButton = nil
function CraftScan.UpdateShowButtonHeight()
    if showMenuButton then
        if CraftScan.DB.settings.show_button_height then
            showMenuButton:SetPoint(
                'TOPLEFT',
                ProfessionsFrame.CraftingPage.SchematicForm,
                'BOTTOMLEFT',
                2,
                -4 + CraftScan.DB.settings.show_button_height
            )
        else
            showMenuButton:SetPoint(
                'TOPLEFT',
                ProfessionsFrame.CraftingPage.SchematicForm,
                'BOTTOMLEFT',
                2,
                -4
            )
        end
    end
end

local showMenuButtonInitialized = false
local function CreateMenuShownButton()
    if showMenuButtonInitialized then
        return
    end
    showMenuButton = CreateFrame(
        'Button',
        'CraftScanToggleScannerConfigButton',
        ProfessionsFrame.CraftingPage.SchematicForm,
        'CraftScan_ScannerConfigButtonTemplate'
    )
    showMenuButton:SetText(L('Open in CraftScan'))
    CraftScan.UpdateShowButtonHeight()
    showMenuButtonInitialized = true
end

local function IsDecor(itemInfo)
    local tryGetOwnedInfo = false
    return C_HousingCatalog.GetCatalogEntryInfoByItem(itemInfo, tryGetOwnedInfo) ~= nil
end
CraftScan.IsDecor = IsDecor

local function PlayerKnowsProfession(profession)
    for _, prof in ipairs(CraftScan.CONST.PROFESSIONS) do
        if prof.professionID == profession.parentProfessionID then
            return true
        end
    end

    return false
end

local function IsPlayerProfession(profession)
    -- Ignore Cooking, Fishing, gathering professions (we don't have
    -- default keywords for them), and weird 'professions' like Emerald
    -- Dream rep boxes (no parentProfessionID).
    return profession.isPrimaryProfession
        and profession.parentProfessionID
        and CraftScan.CONST.PROFESSION_DEFAULT_KEYWORDS[profession.parentProfessionID]
        and not C_TradeSkillUI.IsTradeSkillGuild()
        and not C_TradeSkillUI.IsTradeSkillLinked()
        and PlayerKnowsProfession(profession)
end

local function DeleteNonOrderRecipe(recipes, recipeID)
    -- Upgrade-style code that can be removed at some point. We
    -- originally scanned in all recipes. Delete unconfigured
    -- recipes that are not bind-able.
    --
    -- We initialize a recipe with only its scan_state. If that's still the only
    -- value and the item has no binding (BoE/BoP), then it will never be sent
    -- in a crafting order.
    local deleteIt = true
    for key, _ in pairs(recipes[recipeID]) do
        if key ~= 'scan_state' then
            deleteIt = false
            break
        end
    end
    if deleteIt then
        recipes[recipeID] = nil
    end
end

local function ScanAllRecipes()
    -- Once all items are done processing, we update the tree view
    local professions = {}
    local waitGroup = CraftScan.WaitGroup(function()
        for id, config in pairs(professions) do
            CraftScan.Config.UpdateProfession(playerNameWithRealm, id, config)
        end
    end)

    local perFrame = 1

    local function ProcessRecipe(unused, id)
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
        local profInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(id)

        local item = nil
        if not recipeInfo.isRecraft and recipeInfo.hyperlink then
            item = Item:CreateFromItemLink(recipeInfo.hyperlink)
        end

        local profConfig = saved(db_player.professions, profInfo.professionID, {})
        profConfig.parentProfID = profInfo.parentProfessionID
        professions[profInfo.professionID] = profConfig

        local recipes = saved(profConfig, 'recipes', {})

        if item and not item:IsItemEmpty() then
            waitGroup:Add()
            item:ContinueOnItemLoad(function()
                -- Not finding an enum to use for this. Non-binding items will
                -- likely never be requested via crafting.
                -- https://wowpedia.fandom.com/wiki/LE_ITEM_BIND
                local bindType = select(14, GetItemInfo(item:GetItemLink()))
                if bindType ~= 0 then
                    local isDecor = IsDecor(item:GetItemID())

                    local recipeConfig = nil
                    if
                        isDecor
                        and currentExpansionProfID ~= profInfo.professionID
                        and recipes[id]
                    then
                        -- We already saved decor into legacy expansion
                        -- configs, so if we find it there, move it to the
                        -- current expansion config. Decor is expansion-less in
                        -- terms of usefulness, so we store it all in the
                        -- current expansion for convenience.
                        recipeConfig = recipes[id]
                        recipes[id] = nil
                        db_current_expansion_recipes[id] = recipeConfig
                    else
                        recipeConfig =
                            saved(isDecor and db_current_expansion_recipes or recipes, id, {
                                scan_state = recipeInfo.learned
                                        and CraftScan.CONST.RECIPE_STATES.PENDING_REVIEW
                                    or CraftScan.CONST.RECIPE_STATES.UNLEARNED,
                            })
                    end

                    if
                        recipeInfo.learned
                        and recipeConfig.scan_state == CraftScan.CONST.RECIPE_STATES.UNLEARNED
                    then
                        -- Flip recently learned recipes over to pending review in case
                        -- we missed learned event.
                        recipeConfig.scan_state = CraftScan.CONST.RECIPE_STATES.PENDING_REVIEW
                    end
                elseif recipes[id] then
                    DeleteNonOrderRecipe(recipes, id)
                end

                waitGroup:Done()
            end)
        elseif recipes[id] then
            DeleteNonOrderRecipe(recipes, id)
        end
    end

    local OnFinish = function()
        waitGroup:Close()
    end
    CraftScan.TimeSlice(C_TradeSkillUI.GetAllRecipeIDs(), perFrame, ProcessRecipe, OnFinish)
end

CraftScan.RecipeSchematicMenu = {}
CraftScan.RecipeSchematicMenu.UpdateLabelText = function(recipeID)
    if showMenuButton then
        if db_parent_prof.character_disabled then
            showMenuButton.ScanningLabel:Hide()
        else
            if recipeID == selectedRecipeID then
                if db_recipes[recipeID] or db_current_expansion_recipes[recipeID] then
                    showMenuButton.ScanningLabel:SetText(
                        CraftScan.RecipeStateName(
                            db_recipes[recipeID] or db_current_expansion_recipes[recipeID],
                            db_prof
                        )
                    )
                    showMenuButton.ScanningLabel:Show()
                else
                    showMenuButton.ScanningLabel:SetText(L('Not supported'))
                end
            end
        end
    end
end

local seen_profs = {}
local update_scan_complete = {}
local function OnRecipeSelected()
    if not C_TradeSkillUI.IsTradeSkillReady() then
        return
    end

    -- Some other addons trigger this without actually showing the frame, then
    -- our setup fails because it's trying to position elements on a hidden
    -- frame.
    if not ProfessionsFrame.CraftingPage.SchematicForm:IsShown() then
        return
    end

    local recipe = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    local profession = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipe.recipeID)
    if not IsPlayerProfession(profession) then
        return
    end

    CreateMenuShownButton()

    local seen = seen_profs[profession.parentProfessionID]
    if not seen then
        seen_profs[profession.parentProfessionID] = true
        CraftScan.Scanner.UpdateAnalyticsProfIDs(profession.parentProfessionID)
    end

    -- At this point, the player has opened a tradeskill window, so it makes
    -- sense to start tracking that character. Initialize the saved variables.
    playerNameWithRealm = CraftScan.GetPlayerName(true)
    db_player = saved(CraftScan.DB.characters, playerNameWithRealm, {})

    -- my_uuid is initialized when linked to a new account, at which point all
    -- current characters are tagged. If this character is added after account
    -- linking, tag it as well.
    if not db_player.sourceID and CraftScan.DB.settings.my_uuid then
        db_player.sourceID = CraftScan.DB.settings.my_uuid
    end

    db_player.parent_professions = db_player.parent_professions or {}
    db_parent_prof = db_player.parent_professions[profession.parentProfessionID]
    local is_new = not db_parent_prof
    if is_new then
        db_parent_prof = CraftScan.Utils.DeepCopy(CraftScan.CONST.DEFAULT_PPCONFIG)
        db_player.parent_professions[profession.parentProfessionID] = db_parent_prof
    end

    db_player.professions = db_player.professions or {}

    db_prof = saved(db_player.professions, profession.professionID, {})
    db_prof.parentProfID = profession.parentProfessionID

    CraftScan.SaveConcentrationData()

    db_recipes = saved(db_prof, 'recipes', {})

    CraftScan.State.professionID = profession.parentProfessionID
    CraftScan.Frames.MainButton:UpdateIcon()

    if is_new then
        -- Seed the profession on any linked accounts
        CraftScanComm:ShareCharacterData()
    end

    -- Decor is an expansion-less system, so we aggregate
    -- decor items from all expansions into the primary
    -- config for each profession.
    --
    -- The current expansion will always be the maximum
    -- value profession ID with the same parent profession
    -- ID.
    db_current_expansion_recipes = db_recipes
    currentExpansionProfID = profession.professionID
    for profID, prof in pairs(db_player.professions) do
        if prof.parentProfID == db_prof.parentProfID and currentExpansionProfID < profID then
            currentExpansionProfID = profID
            db_current_expansion_recipes = prof.recipes
        end
    end

    if db_parent_prof.character_disabled then
        showMenuButton:SetDisabled()
    elseif is_new or not seen then
        ScanAllRecipes()
    end

    selectedRecipeID = recipe.recipeID
    CraftScan.RecipeSchematicMenu.UpdateLabelText(selectedRecipeID)
end

CraftScan_ScannerConfigButtonMixin = {}

function CraftScan_ScannerConfigButtonMixin:SetDisabled()
    self:SetText(L(LID.SCANNER_CONFIG_DISABLED))
    self:Show()
end

function CraftScan_ScannerConfigButtonMixin:OnClick(button)
    local recipe = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    local profession = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipe.recipeID)

    if db_parent_prof.character_disabled then
        db_parent_prof.character_disabled = false

        ScanAllRecipes()

        local playerNameWithRealm = CraftScan.GetPlayerName(true)
        CraftScanComm:ShareCharacterModification(playerNameWithRealm, profession.parentProfessionID)

        showMenuButton:SetText(L('Open in CraftScan'))
    end

    local isDecor = IsDecor(recipe.hyperlink)

    CraftScanConfigPage:Show()
    CraftScanConfigPage:SelectRecipe(
        CraftScan.GetPlayerName(true),
        isDecor and currentExpansionProfID or profession.professionID,
        recipe.recipeID
    )
end

CraftScan.Utils.onLoad(function()
    hooksecurefunc(ProfessionsFrame.CraftingPage, 'SelectRecipe', OnRecipeSelected)
end)
