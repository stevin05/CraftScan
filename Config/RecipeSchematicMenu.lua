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
    showMenuButton:SetText(L(LID.SCANNER_CONFIG_SHOW))
    CraftScan.UpdateShowButtonHeight()
    showMenuButtonInitialized = true
end

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

function ScanAllRecipes(profession)
    -- TBD - Is this cheap enough to run the first time a profession is opened every login?

    -- This returns all recipes for all expansions. There must be a better way
    -- to filter it to only the current expansion, but not finding it, so we
    -- manually look up the profession of each recipe and ignore those that
    -- don't match the current expansion profession.
    for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
        local profInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(id)
        if profInfo.professionID == profession.professionID then
            local recipeConfig = saved(db_recipes, id, {
                scan_state = recipeInfo.learned and CraftScan.CONST.RECIPE_STATES.PENDING_REVIEW
                    or CraftScan.CONST.RECIPE_STATES.UNLEARNED,
            })
            if
                recipeInfo.learned
                and recipeConfig.scan_state == CraftScan.CONST.RECIPE_STATES.UNLEARNED
            then
                -- Flip recently learned recipes over to pending review in case
                -- we missed learned event.
                recipeConfig.scan_state = CraftScan.CONST.RECIPE_STATES.PENDING_REVIEW
            end
        end
    end
    CraftScan.Config.UpdateProfession(playerNameWithRealm, profession.professionID, db_prof)
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

    if not seen_profs[profession.parentProfessionID] then
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

    db_recipes = saved(db_prof, 'recipes', {})

    CraftScan.State.professionID = profession.parentProfessionID
    CraftScan.Frames.MainButton:UpdateIcon()

    if is_new then
        -- Seed the profession on any linked accounts
        CraftScanComm:ShareCharacterData()
    end

    if db_parent_prof.character_disabled then
        showMenuButton:SetDisabled()
    elseif is_new or not update_scan_complete[profession.professionID] then
        ScanAllRecipes(profession)
        update_scan_complete[profession.professionID] = true
    end
end

CraftScan_ScannerConfigButtonMixin = { isSelected = false, isEnabled = true }

function CraftScan_ScannerConfigButtonMixin:SetDisabled()
    self.isSelected = false
    self.isEnabled = false
    self:SetText(L(LID.SCANNER_CONFIG_DISABLED))
    self:Show()
end

function CraftScan_ScannerConfigButtonMixin:OnClick(button)
    local recipe = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    local profession = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipe.recipeID)

    if not self.isEnabled then
        self.isEnabled = true
        self.isSelected = true
        db_parent_prof.character_disabled = false

        ScanAllRecipes(profession)

        local playerNameWithRealm = CraftScan.GetPlayerName(true)
        CraftScanComm:ShareCharacterModification(playerNameWithRealm, profession.parentProfessionID)
    else
        self.isSelected = not self.isSelected
    end

    if self.isSelected then
        CraftScanConfigPage:Show()
        CraftScanConfigPage:SelectRecipe(
            CraftScan.GetPlayerName(true),
            profession.professionID,
            recipe.recipeID
        )
        self:SetText(L(LID.SCANNER_CONFIG_HIDE))
    else
        self:SetText(L(LID.SCANNER_CONFIG_SHOW))
        CraftScanConfigPage:Hide()
    end
end

CraftScan.Utils.onLoad(function()
    hooksecurefunc(ProfessionsFrame.CraftingPage, 'SelectRecipe', OnRecipeSelected)
end)
