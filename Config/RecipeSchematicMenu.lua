local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT
local function L(id)
    return CraftScan.LOCAL:GetText(id)
end

local function IsDecor(itemInfo)
    if not itemInfo then
        return false
    end

    local tryGetOwnedInfo = false
    return C_HousingCatalog.GetCatalogEntryInfoByItem(itemInfo, tryGetOwnedInfo) ~= nil
end
CraftScan.IsDecor = IsDecor

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

-- Define the valid profession enum lookup table
local SCANNABLE_PROFESSIONS = {
    [164] = true, -- "Blacksmithing",
    [165] = true, -- "Leatherworking",
    [171] = true, -- "Alchemy",
    [197] = true, -- "Tailoring",
    [202] = true, -- "Engineering",
    [333] = true, -- "Enchanting",
    [755] = true, -- "Jewelcrafting",
    [773] = true, -- "Inscription",
}

local function PlayerKnowsProfession(baseProfessionID)
    local learnedProfs = { GetProfessions() }
    for _, index in pairs(learnedProfs) do
        local _, _, _, _, _, _, learnedID = GetProfessionInfo(index)
        if learnedID == baseProfessionID then
            return true
        end
    end

    return false
end

local function SaveConcentrationData(skillLineID, profConfig)
    if C_ProfSpecs.SkillLineHasSpecialization(skillLineID) then
        local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID)
        local concentrationData = CraftScan.ConcentrationData(currencyID)
        profConfig.concentration = concentrationData:Serialize()
    end
end

local function GetValidatedPPInfo()
    if
        not C_TradeSkillUI.IsTradeSkillReady()
        or C_TradeSkillUI.IsTradeSkillGuild()
        or C_TradeSkillUI.IsTradeSkillLinked()
        or C_TradeSkillUI.IsNPCCrafting()
        or C_TradeSkillUI.IsRuneforging()
    then
        return nil
    end

    local ppInfo = C_TradeSkillUI.GetBaseProfessionInfo()

    -- Make extremely sure that we don't scan in anything that isn't one of the
    -- main professions. We've had problems with this in the past due to random
    -- professions like the Emerald Dream Supply Crate system.
    if
        not ppInfo
        or not ppInfo.isPrimaryProfession
        or not ppInfo.professionID
        or not SCANNABLE_PROFESSIONS[ppInfo.professionID]
        or not PlayerKnowsProfession(ppInfo.professionID)
    then
        return nil
    end

    return ppInfo
end

local function GetParentContext()
    local ppInfo = GetValidatedPPInfo()
    if not ppInfo then
        return nil
    end

    local name = CraftScan.GetPlayerName(true)
    local updated = false

    -- Create the character entry if this is the first time we're seeing it.
    local db = CraftScan.DB.characters[name]
    if not db then
        db = {
            professions = {},
            parent_professions = {},
            sourceID = CraftScan.DB.settings.my_uuid,
        }
        CraftScan.DB.characters[name] = db
    end

    local ppID = ppInfo.professionID
    local dbPP = db.parent_professions[ppID]

    if dbPP and dbPP.character_disabled then
        return { ppInfo = ppInfo, dbPP = dbPP, name = name, db = db }
    end

    if not dbPP then
        dbPP = CraftScan.Utils.DeepCopy(CraftScan.CONST.DEFAULT_PPCONFIG)
        db.parent_professions[ppID] = dbPP
        updated = true
    end

    return {
        ppInfo = ppInfo,
        name = name,
        db = db,
        dbPP = dbPP,
        updated = updated,
    }
end

local function AddProfessionContext(ctxt)
    if ctxt.currentExpID then
        -- Make ourselves idempotent for convenience
        return ctxt
    end

    local profInfos = C_TradeSkillUI.GetChildProfessionInfos()
    if not profInfos or #profInfos == 0 then
        return nil
    end

    ctxt.db.professions = ctxt.db.professions or {}

    local currentExpID = 0
    for _, info in ipairs(profInfos) do
        local expID = info.professionID

        -- Track the highest ID to determine the "Current Expansion"
        if expID > currentExpID then
            currentExpID = expID
        end

        if not ctxt.db.professions[expID] then
            local entry = {
                recipes = {},
                parentProfID = ctxt.ppInfo.professionID,
            }
            SaveConcentrationData(expID, entry)
            ctxt.db.professions[expID] = entry
            ctxt.updated = true
        end
    end

    -- Attach expansion data to the context
    ctxt.profInfos = profInfos
    ctxt.currentExpID = currentExpID
    ctxt.dbCurrentExp = ctxt.db.professions[currentExpID]

    local selectedRecipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    local selectedProfession = selectedRecipeInfo
            and C_TradeSkillUI.GetProfessionInfoByRecipeID(selectedRecipeInfo.recipeID)
        or C_TradeSkillUI.GetChildProfessionInfo()

    ctxt.selectedExpProfInfo = selectedProfession
    ctxt.dbSelectedExp = ctxt.db.professions[selectedProfession.professionID]

    return ctxt
end

local function GetContext()
    local ctxt = GetParentContext()
    if ctxt then
        return AddProfessionContext(ctxt)
    end
    return nil
end

CraftScan.Events:Register('CONCENTRATION_UPDATED', function()
    local ctxt = GetContext()
    if ctxt then
        SaveConcentrationData(ctxt.selectedExpProfInfo.professionID, ctxt.dbSelectedExp)
    end
end)

local scanned = {}
local function AllScanned(profInfos)
    for _, info in ipairs(profInfos) do
        if not scanned[info.professionID] then
            return false
        end
    end
    return true
end

local function ScanAllRecipes(OnScanComplete, forceScan)
    local ctxt = GetParentContext()
    if not ctxt or ctxt.dbPP.character_disabled then
        return
    end

    ctxt = AddProfessionContext(ctxt)
    if not ctxt then
        return
    end

    if forceScan then
        for _, info in ipairs(ctxt.profInfos) do
            scanned[info.professionID] = nil
        end
    elseif AllScanned(ctxt.profInfos) then
        return
    end
    CraftScan.Events:Emit('PROFESSION_SCAN_BEGIN')

    local professions = {}
    local waitGroup = CraftScan.WaitGroup(function()
        for _, info in ipairs(ctxt.profInfos) do
            scanned[info.professionID] = true
        end

        -- Once all items are done processing, we update the tree view
        if ctxt.updated then
            for id, config in pairs(professions) do
                CraftScan.Config.UpdateProfession(ctxt.name, id, config)
            end

            -- Seed the profession on any linked accounts
            CraftScanComm:ShareCharacterData()
        end

        -- We intentionally do not pass ctxt here. It is not always 100% correct
        -- in the button context because we loaded it based on a TRADESKILL
        -- event, not a RECIPE_SELECTED event. Let the button re-generate a new
        -- context based on the currently selected recipe.
        CraftScan.Events:Emit('PROFESSION_SCAN_COMPLETE')

        if OnScanComplete then
            OnScanComplete()
        end
    end)

    local function ProcessRecipe(unused, id)
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
        local profInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(id)
        if not profInfo.parentProfessionID then
            -- Some shadowlands recipes report an unknown expansion and have no
            -- parent professionID. We just ignore them.
            return
        end

        local item = nil
        if not recipeInfo.isRecraft and recipeInfo.hyperlink then
            item = Item:CreateFromItemLink(recipeInfo.hyperlink)
        end

        local profConfig = ctxt.db.professions[profInfo.professionID]
        if not profConfig then
            -- This is to fix #86, but no idea how it happened. The prior ctxt
            -- setup should have ensured that any profession we're scanning in
            -- has a place to go.
            return
        end
        local recipes = profConfig.recipes

        professions[profInfo.professionID] = profConfig

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
                    if isDecor and ctxt.currentExpID ~= profInfo.professionID and recipes[id] then
                        -- We already saved decor into legacy expansion
                        -- configs, so if we find it there, move it to the
                        -- current expansion config. Decor is expansion-less in
                        -- terms of usefulness, so we store it all in the
                        -- current expansion for convenience.
                        recipeConfig = recipes[id]
                        recipes[id] = nil
                        ctxt.dbCurrentExp.recipes[id] = recipeConfig
                        context.updated = true
                    else
                        recipeConfig = isDecor and ctxt.dbCurrentExp.recipes[id] or recipes[id]
                        if not recipeConfig then
                            ctxt.updated = true
                            recipeConfig = {
                                scan_state = recipeInfo.learned
                                        and CraftScan.CONST.RECIPE_STATES.PENDING_REVIEW
                                    or CraftScan.CONST.RECIPE_STATES.UNLEARNED,
                            }
                            if isDecor then
                                ctxt.dbCurrentExp.recipes[id] = recipeConfig
                            else
                                recipes[id] = recipeConfig
                            end
                        end
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

    local perFrame = 5
    CraftScan.TimeSlice(C_TradeSkillUI.GetAllRecipeIDs(), perFrame, ProcessRecipe, OnFinish)
end
CraftScan.Events:Register('TRADESKILL_OPENED', ScanAllRecipes)

local function CreateMenuShownButton()
    local button = CreateFrame(
        'Button',
        'CraftScanToggleScannerConfigButton',
        ProfessionsFrame.CraftingPage.SchematicForm,
        'CraftScan_ScannerConfigButtonTemplate'
    )

    CraftScan.Events:Register({
        'RECIPE_SELECTED',
        'PROFESSION_SCAN_BEGIN',
        'PROFESSION_SCAN_COMPLETE',
        'CHARACTER_ENABLED',
        'TETHER_CHANGED',
    }, function(...)
        button:Setup(...)
    end)

    CraftScan.Events:Register('CONFIG_PAGE_MAXIMIZED', function(...)
        button.tethered = false
        button:Setup(...)
    end)

    CraftScan.Events:Register('BUTTON_HEIGHT', function(...)
        button:UpdateHeight(...)
    end)
    button:UpdateHeight()

    CraftScan.Events:Register('UPDATE_RECIPE_LABEL', function(...)
        button:UpdateRecipeLabel(...)
    end)

    CraftScan.Events:Register('CHARACTER_DISABLED', function(name)
        local ctxt = GetParentContext()
        if ctxt and ctxt.name == name then
            button:Setup(ctxt)
        end
    end)

    ProfessionsFrame:HookScript('OnHide', function()
        if button.tethered then
            CraftScanConfigPage:Hide()
        end
    end)
end

local function OpenRecipe()
    local ctxt = GetContext()
    if not ctxt then
        return
    end

    local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    local profession = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeInfo.recipeID)

    local isDecor = IsDecor(recipeInfo.hyperlink)
    local profID = isDecor and ctxt.currentExpID or profession.professionID
    local profConfig = isDecor and ctxt.dbCurrentExp or ctxt.dbSelectedExp
    if profConfig.recipes[recipeInfo.recipeID] then
        CraftScan.Events:Emit('OPEN_RECIPE', ctxt.name, profID, recipeInfo.recipeID)
    end
end

CraftScan_ScannerConfigButtonMixin = {}

function CraftScan_ScannerConfigButtonMixin:Setup(ctxt)
    ctxt = ctxt or GetParentContext()
    if not ctxt then
        self:Hide()
        return
    end

    if ctxt.dbPP.character_disabled then
        self:SetText(L(LID.SCANNER_CONFIG_DISABLED))
        self.ScanningLabel:Hide()
        self:SetEnabled(true)
        self:Show()
        self.character_disabled = true
        if self.tethered then
            self.tethered = false
            CraftScanConfigPage:Hide()
        end
        return
    end

    ctxt = AddProfessionContext(ctxt)
    if not ctxt then
        self:Hide()
        return
    end

    self:SetEnabled(AllScanned(ctxt.profInfos))
    self:UpdateRecipeLabel(nil, ctxt)
    if not AllScanned(ctxt.profInfos) then
        self:SetText(L('Loading...'))
    else
        if ProfessionsFrame.CraftingPage.SchematicForm:IsShown() then
            if self.tethered == true then
                self:SetText(L('Hide CraftScan'))
                OpenRecipe()
            else
                self:SetText(L('Open in CraftScan'))
            end
        end
    end
    self:Show()
end

function CraftScan_ScannerConfigButtonMixin:UpdateHeight()
    local offset = CraftScan.DB.settings.show_button_height or 0
    self:SetPoint(
        'TOPLEFT',
        ProfessionsFrame.CraftingPage.SchematicForm,
        'BOTTOMLEFT',
        2,
        -4 + offset
    )
end

function CraftScan_ScannerConfigButtonMixin:UpdateRecipeLabel(recipeID, ctxt)
    self.ScanningLabel:Hide()

    if ctxt then
        ctxt = AddProfessionContext(ctxt)
    else
        ctxt = GetContext()
    end
    if not ctxt then
        return
    end

    local selectedRecipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    if not selectedRecipeInfo then
        -- We aren't displaying a recipe, so nothing to update.
        return
    end

    if not recipeID then
        recipeID = selectedRecipeInfo.recipeID
    elseif selectedRecipeInfo.recipeID ~= recipeID then
        -- We aren't displaying the selected recipe, so nothing to update.
        return
    end

    -- We look in the current profession and the current expansion in case the
    -- recipe is a decor item.
    local profConfig = ctxt.dbSelectedExp
    local recipeConfig = profConfig.recipes[recipeID]
    if not recipeConfig then
        profConfig = ctxt.dbCurrentExp
        recipeConfig = profConfig.recipes[recipeID]
    end

    if recipeConfig then
        self.ScanningLabel:SetText(CraftScan.RecipeStateName(recipeConfig, profConfig))
    else
        self.ScanningLabel:SetText(L('Not supported'))
        if self.tethered then
            CraftScanConfigPage:Hide()
        end
    end
    self.ScanningLabel:Show()
end

function CraftScan_ScannerConfigButtonMixin:OnClick(button)
    if self.character_disabled then
        local ctxt = GetParentContext()
        if ctxt then
            self.character_disabled = nil
            ctxt.dbPP.character_disabled = nil
            local OnScanComplete = function()
                CraftScan.Events:Emit('CHARACTER_ENABLED', ctxt)
            end
            local forceScan = true
            ScanAllRecipes(OnScanComplete, forceScan)
        end
        return
    end

    self.tethered = not self.tethered
    if not self.tethered then
        CraftScanConfigPage:SetMenuCollapsed(false)
    end
    CraftScan.Events:Emit('TETHER_CHANGED')
end

local function OnRecipeSelected()
    -- Some other addons trigger this without actually showing the frame, then
    -- our setup fails because it's trying to position elements on a hidden
    -- frame.
    if not ProfessionsFrame.CraftingPage.SchematicForm:IsShown() then
        return
    end

    local ctxt = GetParentContext()
    if ctxt then
        CraftScan.DoOnce(CreateMenuShownButton)

        CraftScan.State.professionID = ctxt.ppInfo.professionID
        CraftScan.Frames.MainButton:UpdateIcon()
    end

    CraftScan.Events:Emit('RECIPE_SELECTED', ctxt)
end

CraftScan.Utils.onLoad(function()
    hooksecurefunc(ProfessionsFrame.CraftingPage, 'SelectRecipe', OnRecipeSelected)
end)
