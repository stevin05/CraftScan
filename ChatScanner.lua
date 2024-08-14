local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local saved = CraftScan.Utils.saved

CraftScan.MessageType = EnumUtil.MakeEnum("General", "Whisper");

-- Split and normalize a comma separated list of strings
local function ParseStringList(list)
    if not list then return {} end;

    local items = { strsplit(",", list) }
    for i, item in ipairs(items) do
        items[i] = string.lower(item:gsub("^%s*(.-)%s*$", "%1"))
    end
    return items
end

-- Split a string on newlines, then further split each line to ensure
-- it fits in a whisper.
local function SplitResponse(raw_response)
    local result = {}
    for _, response in ipairs({ strsplit('\n', raw_response) }) do
        while #response > 255 do
            local split = 255
            for i = 255, 1, -1 do
                if response:sub(i, i) == ' ' then
                    split = i
                    break
                end
            end
            table.insert(result, response:sub(1, split))
            response = response:sub(split + 1, #response)
        end
        table.insert(result, response)
    end
    return result
end

-- Given a string and a list of string tokens, return if the string
-- contains one of the tokens, delimited by spaces, start/end, or
-- the [] of an item link.]
local function HasMatch(message, tokens)
    for _, token in pairs(tokens) do
        local b, e = string.find(message, token)
        if b and e and (b == 1 or message:sub(b - 1, b - 1) == ' ' or (b > 2 and message:sub(b - 2, b - 1) == '|r')) and
            (e == #message or message:sub(e + 1, e + 1) == ' ' or message:sub(e + 1, e + 1) == '|') then
            return true
        end
    end
    return false
end

local function TableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end


local function FindByField(array, value, field)
    for _, val in ipairs(array) do
        if value == val[field] then
            return val
        end
    end
    return nil
end

local config = {}
local function resetConfig()
    config = {
        -- The message must match an inclusion and either a prof_keyword or an item
        exclusions = {},
        inclusions = {},
        prof_keywords = {},
        items = {},
    }
end

--[[
"characters": {
    "name-realm": {
        "professions": {
            <id>: {
                "recipes": {
                    "recipeID": {
                        "enabled": <true|false>
                        "keywords": "<keywords>",
                        "greeting": "<greeting>",
                        "override": <true|false>
                    }
                },
                "categories": {
                    "categoryID": {
                        "keywords": "<keywords>",
                        "greeting": "<greeting>",
                        "override": <true|false>
                    }
                }
                "keywords": "<keywords>",
                "greeting": "<greeting>",
                "all_enabled": <true|false>
            }
        },
        "primary_expansion": <profID>
    }

}
]]

CraftScan.Scanner = {}

CraftScan.Utils.GetOutputItems = function(recipeInfo)
    if recipeInfo.qualityItemIDs then
        -- If included, we already have the itemIDs we need.
        -- This appears to be how reagant style crafts, like
        -- gems are represented, and we get a separate itemID for
        -- each quality level. Armor pieces are not found here.
        return recipeInfo.qualityItemIDs
    else
        -- Things like recraft don't have an outputItemID, and we don't want to detect those anyway.
        local schematic = C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false)
        if schematic.outputItemID then
            return { schematic.outputItemID }
        end
    end

    return nil
end

-- The usage of this method is *very* inefficient. On any profession
-- configuration change, we reload the whole thing. AddonUsage shows that
-- during config changes, we shoot up to #1 on memory usage of any addon.
-- Tossing a manual 'collectgarbage()' call into resetConfig() makes it so we
-- stay low at all times, but makes every button click hang for a second.
--
-- This config should change very rarely, so was more concerned with correctness
-- over efficiency, and didn't want to code special case updates for each
-- different button option.
function CraftScan.Scanner.LoadConfig()
    resetConfig()

    config.exclusions = ParseStringList(CraftScan.DB.settings.exclusions)
    config.inclusions = ParseStringList(CraftScan.DB.settings.inclusions)

    -- Sort professions by 'primary_crafter' so that when we scan for generic
    -- keyword matches, we find the primary crafter first. We also ignore
    -- duplicate recipes from crafters that aren't the primary. These could be
    -- considered a misconfig since the user has to enable scanning for the same
    -- item on two characters, but that's bound to happen.
    local parentProfessions = {};
    for crafter, crafterConfig in pairs(CraftScan.DB.characters) do
        for parentProfID, parentProf in pairs(crafterConfig.parent_professions) do
            if not parentProf.character_disabled then
                local professions = {};
                for profID, prof in pairs(crafterConfig.professions) do
                    if prof.parentProfID == parentProfID then
                        table.insert(professions, {
                            profID = profID,
                            profession = prof,
                        })
                    end
                end
                table.insert(parentProfessions, {
                    crafter = crafter,
                    parentProfID = parentProfID,
                    parentProfession = parentProf,
                    professions = professions,
                })
            end
        end
    end

    table.sort(parentProfessions, function(lhs, rhs)
        if lhs.parentProfession.primary_crafter then
            if rhs.parentProfession.primary_crafter then
                return false;
            end
            return true;
        end
        return false;
    end)

    -- Flatten the keywords, storing the path back to their source so we can
    -- find the greeting after getting a match.
    --
    -- Convert recipeIDs to itemIDs, which is what we will find in chat message
    -- links.
    for _, entry in ipairs(parentProfessions) do
        local crafter = entry.crafter;
        local parentProf = entry.parentProfession;
        local parentProfID = entry.parentProfID;
        local professions = entry.professions;

        local keywords = parentProf.keywords or L(CraftScan.CONST.PROFESSION_DEFAULT_KEYWORDS[parentProfID])
        table.insert(config.prof_keywords, {
            keywords = ParseStringList(keywords),
            exclusions = ParseStringList(parentProf.exclusions or ''),
            crafter = crafter,
            parentProfID = parentProfID,
        })

        for _, pEntry in ipairs(professions) do
            local prof = pEntry.profession;
            if prof.recipes then
                local profID = pEntry.profID;
                for recipeID, recipe in pairs(prof.recipes) do
                    if prof.all_enabled or recipe.enabled then
                        -- Look up the itemIDs associated with the recipe
                        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                        local itemIDs = CraftScan.Utils.GetOutputItems(recipeInfo)
                        if itemIDs then
                            for _, itemID in ipairs(itemIDs) do
                                if not config.items[itemID] then
                                    config.items[itemID] = {
                                        crafter = crafter,
                                        profID = profID,
                                        recipeID = recipeID
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function ParentProfessionConfig(crafterInfo)
    local crafterConfig = CraftScan.DB.characters[crafterInfo.crafter];
    local profConfig = crafterConfig.professions[crafterInfo.profID];
    return crafterConfig.parent_professions[profConfig.parentProfID];
end

local function IsScanningEnabled(crafterInfo)
    local ppConfig = ParentProfessionConfig(crafterInfo)
    return ppConfig.scanning_enabled;
end

local function idForKeywords(message, profConfig, section)
    local sectionConfig = profConfig[section]
    if not sectionConfig then
        return nil
    end

    for id, config in pairs(sectionConfig) do
        if config.keywords then
            if HasMatch(message, ParseStringList(config.keywords)) then
                return id
            end
        end
    end
    return nil
end

local function getRequestIDs(message, crafterInfo, profConfig)
    local recipeID = crafterInfo.recipeID or idForKeywords(message, profConfig, 'recipes')
    if recipeID then
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo then
            return recipeInfo, recipeInfo.categoryID
        end
    end

    local categoryID = idForKeywords(message, profConfig, 'categories')
    return nil, categoryID
end

-- There does not appear to be any reverse look up from itemID to whether the
-- item is crafted or not. The onyl option I've found is the reverse direction,
-- but then we'd need a mapping of every craftable item in the game to determine
-- if a given itemID is crafted. Instead, we're going to depend on the fact that
-- players don't really have easy access to item links that don't have a
-- crafting 'quality' embedded in the link itself. (We generate such links, but
-- without an addon all items clicked from a profession or the order page have a
-- quality.)
local function GetItemIDsFromQualityLinks(inputString)
    local itemIDs = nil;

    local pattern = "item:(%d+)"
    local qualityPattern = "professions%-chaticon%-quality%-tier"
    for itemLink in string.gmatch(inputString, "item:%d+%:%S+") do
        if string.find(itemLink, qualityPattern) then
            local itemID = itemLink:match(pattern)
            if itemID then
                if not itemIDs then itemIDs = {}; end
                table.insert(itemIDs, tonumber(itemID))
            end
        end
    end

    return itemIDs
end

-- Return array with the front n elements removed.
local function RemoveFront(array, n)
    local result = {};
    for i = n + 1, #array, 1 do
        print("Copying element", n, #array, i)
        table.insert(result, array[i]);
    end
    return result;
end

local function RemoveBack(array, n)
    for _ = 1, n do
        table.remove(array);
    end
end

CraftScan.Analytics = {};

function CraftScan.Analytics:GetTimeStamp(timeEntry)
    if type(timeEntry) == "table" then return timeEntry.t end
    return timeEntry;
end

-- Remove entries older than timeout for the given itemID.
function CraftScan.Analytics:ClearAnalyticsForItem(itemID, range)
    local timeout = range.seconds;

    local items = CraftScan.DB.analytics.seen_items;
    if timeout == nil then
        items[itemID] = nil;
    else
        local recent = range.recent;
        local itemInfo = items[itemID];
        local now = time();
        for i, timeInfo in ipairs(itemInfo.times) do
            if CraftScan.Analytics:GetTimeStamp(timeInfo) + timeout > now then
                if recent then
                    local count = #itemInfo.times - i + 1;
                    if count == 0 then
                        -- Don't need to refresh the display
                        return false;
                    end

                    RemoveBack(itemInfo.times, count);
                else
                    local count = i - 1;
                    if count == 0 then
                        -- Don't need to refresh the display
                        return false;
                    end

                    itemInfo.times = RemoveFront(itemInfo.times, i - 1);
                end
                if #itemInfo.times == 0 then items[itemID] = nil; end;
                return true;
            end
        end
        if not recent then
            items[itemID] = nil;
            return true;
        end
    end
    return false;
end

local function CleanRecentAnalytics()
    if not CraftScan.DB.analytics.seen_items then return end

    local timeout = 10; -- TODO 3600
    local now = time();
    for _, itemInfo in pairs(CraftScan.DB.analytics.seen_items) do
        for i, timeInfo in ipairs(itemInfo.times) do
            if type(timeInfo) == "table" and timeInfo.t + timeout < now then
                if timeInfo.c ~= nil then
                    -- Save the count, but erase the customer to save some space.
                    timeInfo['customer'] = nil;
                else
                    -- No duplicates from this customer, so replace the dictionary with the raw time.
                    itemInfo.times[i] = timeInfo.t;
                end
            end
        end
    end

    -- On login and every hour after that, clean up any recent records to save space.
    C_Timer.After(timeout, CleanRecentAnalytics);
end

local function AddTimeToAnalytics(customer, item)
    -- For recent requests, we track the customer, allowing us to detect
    -- duplicate requests for the same item from the same person. This helps us
    -- find items that are difficult to get crafted, which might indicate a good
    -- item to invest in learning to craft.
    local times = item.times;

    --  Track repeat requests for up to an hour. This aligns with our 'peak per
    --  hour', so duplicate requests don't artificially inflate the peak requests.
    local timeout = 10; -- TODO 3600
    local now = time();
    for i = #times, 1, -1 do
        local entry = times[i]
        if type(entry) == "table" then
            if entry.t + timeout < now then
                break;
            end

            if entry.customer == customer then
                entry.c = (entry.c or 1) + 1;
                return;
            end
        else
            -- After an hour, a garbage collector converts entries from
            -- dictionaries to values if they don't contain a duplicate request
            -- count, so hitting a non-dictionary value means we are done
            -- looking for recent orders.
            break
        end
    end
    table.insert(item.times, { t = time(), customer = customer });

    CraftScanCraftingOrderPage:UpdateAnalytics()
end

local function AddMessageToAnalytics(message)
    local itemIDs = GetItemIDsFromQualityLinks(message);
    if not itemIDs then return; end

    local seen = saved(CraftScan.DB.analytics, "seen_items", {});
    for _, itemID in ipairs(itemIDs) do
        local item = saved(seen, itemID, { times = {} });
        AddTimeToAnalytics(customer, item);
    end
end

local function AddItemToAnalytics(customer, itemID, parentProfID)
    local seen = saved(CraftScan.DB.analytics, "seen_items", {});
    local item = saved(seen, itemID, { times = {}, ppID = parentProfID });
    AddTimeToAnalytics(customer, item);
    if not item.ppID then item.ppID = parentProfID end
end

-- Because we can't reverse look up from item link to crafting profession, we do
-- the translation when a profession is opened scan any saved items and see if
-- they are related to this profession.
function CraftScan.Scanner.UpdateAnalyticsProfIDs(customer, parentProfID)
    if not CraftScan.DB.analytics.seen_items then return end

    local itemIDs = nil;
    for itemID, itemInfo in pairs(CraftScan.DB.analytics.seen_items) do
        if not itemInfo.ppID then
            if not itemIDs then
                itemIDs = {};
                -- On the first analytics item without profession info, grab the
                -- full list, convert it to all itemIDs created by the
                -- profession, then check if we have a match.
                for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
                    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
                    local itemIDs = CraftScan.Utils.GetOutputItems(recipeInfo)
                    if itemIDs then
                        for _, itemID in ipairs(itemIDs) do
                            itemIDs[itemID] = true;
                        end
                    end
                end
            end

            if itemIDs[itemID] then
                itemInfo.ppID = parentProfID;
            end
        end
    end
end

local function getCrafterForMessage(customer, message)
    message = string.lower(message)
    if HasMatch(message, config.exclusions) then
        return nil
    end

    if not HasMatch(message, config.inclusions) then
        return nil
    end

    -- Determine the profession via the item link or keywords in the message
    local itemFound, _, itemID = string.find(message, "item:(%d+):")

    if itemFound then
        itemID = tonumber(itemID)
        local crafterInfo = config.items[itemID];
        if crafterInfo then
            local profConfig = CraftScan.DB.characters[crafterInfo.crafter].professions[crafterInfo.profID];
            AddItemToAnalytics(customer, itemID, profConfig.parentProfID);
            if IsScanningEnabled(crafterInfo) then
                local recipeInfo, categoryID = getRequestIDs(message, crafterInfo, profConfig);
                return crafterInfo, itemID, recipeInfo, categoryID;
            end
        else
            -- We can't craft this item, but save that some one requested it for future analysis
            AddMessageToAnalytics(customer, message);
        end

        return nil
    end

    for _, crafterInfo in ipairs(config.prof_keywords) do
        if HasMatch(message, crafterInfo.keywords) and not HasMatch(message, crafterInfo.exclusions) then
            -- For profession keywords, we store the parent profession ID,
            -- and need to determine which expansion's profession we should
            -- report. We check the sub-configurations for a category or recipe
            -- match, and if not found, return the largest profession ID, which
            -- presumable refers to the latest expansion.
            local crafterConfig = CraftScan.DB.characters[crafterInfo.crafter];
            local ppConfig = crafterConfig.parent_professions[crafterInfo.parentProfID];
            if ppConfig.scanning_enabled then
                local maxProfID = 0;
                for pID, pConfig in pairs(crafterConfig.professions) do
                    if pConfig.parentProfID == crafterInfo.parentProfID then
                        local recipeInfo, categoryID = getRequestIDs(message, crafterInfo, pConfig)
                        if recipeInfo or categoryID then
                            return { crafter = crafterInfo.crafter, profID = pID }, nil, recipeInfo,
                                categoryID;
                        end

                        if pID > maxProfID then
                            maxProfID = pID;
                        end
                    end
                end

                local profID = maxProfID;
                if ppConfig.primary_expansion then
                    profID = ppConfig.primary_expansion;
                end

                if profID ~= nil then
                    return { crafter = crafterInfo.crafter, profID = profID };
                end -- Else keep looking for other crafters
            end
        end
    end

    return nil;
end

local function concatGreetings(lhs, rhs)
    if lhs then
        if rhs then
            return lhs .. ' ' .. rhs
        end
        return lhs
    end
    return rhs
end

local function sectionGreeting(profConfig, section, sectionID)
    if sectionID and profConfig[section] then
        local config = profConfig[section][sectionID]
        return config and config.greeting, config and config.override
    end
    return nil, nil
end

local function profGreeting(recipeID, categoryID, profConfig)
    local recipeGreeting, recipeOverride = sectionGreeting(profConfig, 'recipes', recipeID)
    if recipeOverride then
        return recipeGreeting
    end

    local catGreeting, catOverride = sectionGreeting(profConfig, 'categories', categoryID)
    local greeting = concatGreetings(catGreeting, recipeGreeting)
    if catOverride then
        return greeting
    end
    return concatGreetings(profConfig.greeting, greeting)
end

CraftScan.OrderToCustomerInfo = function(order)
    local customers = CraftScan.DB.customers
    if not customers then
        return nil
    end
    return customers[order.customerName]
end

CraftScan.OrderToResponse = function(order)
    local customers = CraftScan.DB.customers
    return customers[order.customerName].responses[order.responseID]
end

CraftScan.OrderToLiveCustomerInfo = function(order, default)
    local customers = saved(CraftScan.LIVE, 'customers', default and {})
    if not customers then
        return nil
    end
    return saved(customers, order.customerName, default and {})
end

CraftScan.OrderToLiveResponses = function(order, default)
    local customerInfo = CraftScan.OrderToLiveCustomerInfo(order, default)
    if not customerInfo then
        return nil
    end
    return saved(customerInfo, 'responses', default and {})
end

CraftScan.OrderToLiveResponse = function(order, default)
    local responses = CraftScan.OrderToLiveResponses(order, default)
    if not responses then
        return nil
    end
    return saved(responses, order.responseID, default and {})
end

CraftScan.OrderToOrderID = function(order)
    return order.customerName .. '-' .. order.responseID
end

CraftScan.NameAndRealmToName = function(name)
    return name:match("^([^-]+)")
end

CraftScan.ColorizePlayerName = function(name, guid)
    name = CraftScan.NameAndRealmToName(name)
    local _, class = GetPlayerInfoByGUID(guid)
    local cc = RAID_CLASS_COLORS[class];
    if cc then
        return string.format("|cff%02x%02x%02x%s|r", cc.r * 255, cc.g * 255, cc.b * 255, name);
    end
    return name
end

CraftScan.ColorizeCrafterName = function(name)
    if name ~= UnitName("player") then return name end
    return '|cff00ff00' .. name .. '|r'
end

local lastChatFrameMessage = { message = '', args = nil };

local function MakeChatHistoryEntry(customer, message)
    -- We've hacked together the ChatFrame and the CHAT_MSG_ events, but they
    -- are not guaranteed to line up with eachother because we depend on the
    -- message appearing on ChatFrame1 but it could appear on any (or no) chat
    -- frame. We listen to all channels even if they aren't displayed in any
    -- window. If we didn't see the message in a window, then we won't have any
    -- history on it, so we return the raw text without the nice formatting from
    -- the chat window.

    -- You can test this out by leaving 'Say' chat, then saying an order for
    -- yourself.
    if string.find(lastChatFrameMessage.message, CraftScan.NameAndRealmToName(customer)) then
        return {
            message = lastChatFrameMessage.message,
            args = lastChatFrameMessage.args,
        }
    end

    return {
        message = message,
        args = nil,
    }
end

local function handleResponse(message, customer, crafterInfo, itemID, recipeInfo, categoryID, item)
    -- At this point, we have everything we need to generate a response to the message.
    local itemLink = item and item:GetItemLink() or nil

    -- We keep a history of our customers to avoid spamming the same person repeatedly.
    local customerInfo = CraftScan.DB.customers[customer]

    -- Be as specific as possible about what we're responding to.
    local profID = crafterInfo.profID
    local recipeID = recipeInfo and recipeInfo.recipeID
    local responseID = recipeID or categoryID or profID

    local responses = saved(customerInfo, "responses", {})
    local response = saved(responses, responseID, {})
    local firstInteraction = not next(response)
    if response.greeting_sent then
        -- We already messaged the customer about this craft
        return
    end

    local profInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(profID)

    local crafter = crafterInfo.crafter:match("^([^-]+)")
    local alt_craft = crafter ~= UnitName("player")

    local greeting = '';
    if alt_craft then
        if itemID then
            greeting = string.format(L(LID.GREETING_ALT_CAN_CRAFT_ITEM), crafter, itemLink or L(LID.GREETING_LINK_BACKUP));
        else
            greeting = string.format(L(LID.GREETING_ALT_HAS_PROF), crafter, profInfo.parentProfessionName);
        end
        greeting = greeting .. ' ' .. L(LID.GREETING_ALT_SUFFIX);
    else
        if itemID then
            greeting = string.format(L(LID.GREETING_I_CAN_CRAFT_ITEM), itemLink or L(LID.GREETING_LINK_BACKUP));
        else
            greeting = string.format(L(LID.GREETING_I_HAVE_PROF), profInfo.parentProfessionName);
        end
    end

    local profConfig = CraftScan.DB.characters[crafterInfo.crafter].professions[profID]
    greeting = concatGreetings(greeting, profGreeting(recipeID, categoryID, profConfig))

    response.message = SplitResponse(greeting)
    local chat_history = saved(customerInfo, 'chat_history', {})
    table.insert(chat_history, MakeChatHistoryEntry(customer, message));

    if categoryID then
        -- Save the request at higher granularities as well so that we don't
        -- respond to someone a second time for something more generic. E.g. we
        -- responded to 'lf bs <item>', they didn't take the offer, then they
        -- requested 'lf bs'. We don't want to message that person again after
        -- they rejected us offering the exact item they wanted.
        if recipeID then
            if not responses[categoryID] then
                responses[categoryID] = response
                local children = saved(response, "less_granular", {})
                table.insert(children, categoryID)
            end
        end
        if not responses[profID] then
            responses[profID] = response
            local children = saved(response, "less_granular", {})
            table.insert(children, profID)
        end
    end

    local greeting_queued = not alt_craft and CraftScan.auto_replies_enabled;
    if greeting_queued then
        C_Timer.After(CraftScan.Utils.GetSetting('auto_reply_delay') / 1000, function()
            CraftScan.Utils.SendResponses(response.message, customer, reason)
            response.greeting_sent = true
        end)
    end

    local now = time()

    response.crafterName = crafter;
    response.professionID = profID;
    response.parentProfID = profInfo.parentProfessionID;
    response.professionName = profInfo.parentProfessionName;
    response.itemID = itemID;
    response.recipeID = recipeID;
    response.time = now;
    response.responseID = responseID;

    if firstInteraction then
        local order = {
            customerName = customer,
            responseID = responseID
        }
        CraftScan.DB.listed_orders[CraftScan.OrderToOrderID(order)] = order

        local ppConfig = ParentProfessionConfig(crafterInfo);

        if ppConfig.visual_alert_enabled then
            FlashClientIcon()

            if not greeting_queued then
                CraftScanScannerMenu:TriggerAlert(string.format("%s\n%s (%s)",
                        CraftScan.ColorizePlayerName(customer, customerInfo.guid),
                        itemLink or
                        CraftScan.Utils.ColorizeProfessionName(profInfo.parentProfessionID, profInfo
                            .parentProfessionName),
                        CraftScan.ColorizeCrafterName(crafter)),
                    order)

                if not CraftScanCraftingOrderPage:IsShown() then
                    CraftScanScannerMenu:TriggerPulseLock("scanned")
                end
            end
        end

        if ppConfig.sound_alert_enabled then
            PlaySoundFile(CraftScan.Utils.GetSetting("ping_sound"), "Master");
        end

        CraftScanCraftingOrderPage:ShowGeneric()
    end
end

local function OnMessage(self, event, ...)
    local message, customer = ...
    if not message or not customer then
        return false
    end

    local customerInfo = CraftScan.DB.customers[customer]

    if event == "CHAT_MSG_WHISPER_INFORM" then
        if customerInfo then
            local chat_history = saved(customerInfo, 'chat_history', {})
            table.insert(chat_history, MakeChatHistoryEntry(customer, message));
        end
        return false
    end

    if event == "CHAT_MSG_WHISPER" and customerInfo then
        local chat_history = saved(customerInfo, 'chat_history', {})
        table.insert(chat_history, MakeChatHistoryEntry(customer, message));

        for _, response in pairs(customerInfo.responses) do
            if response.greeting_sent then
                response.customer_answered = true
            end
        end
        CraftScanCraftingOrderPage:ShowGeneric()
        FlashClientIcon()
        return false
    end

    local crafterInfo, itemID, recipeInfo, categoryID = getCrafterForMessage(customer, message)
    if not crafterInfo then
        return false
    end

    local customerInfo = saved(CraftScan.DB.customers, customer, {})
    customerInfo.guid = select(12, ...)

    if itemID or recipeInfo then
        if not itemID then
            -- We didn't find an item in the message, but if the message
            -- matched an item by keyword, we can still find it.
            local itemIDs = CraftScan.Utils.GetOutputItems(recipeInfo)
            itemID = itemIDs and itemIDs[1]
        end

        if itemID then
            local item = Item:CreateFromItemID(itemID)
            item:ContinueOnItemLoad(function()
                handleResponse(message, customer, crafterInfo, itemID, recipeInfo, categoryID, item)
            end)
            return false
        end
    end

    handleResponse(message, customer, crafterInfo, itemID, recipeInfo, categoryID, nil)

    return false
end

local frame = CreateFrame("frame")

-- Can't unhook, so we disable it without the table allocation at least.
local registered = false
local disableHook = false
local function CaptureChatMessage(chatFrame, message, ...)
    if disableHook then return end

    -- For Prat integration, we grab the historyBuffer value, which has
    -- the timestamp separately added. 'message' does not include it.
    lastChatFrameMessage.message = chatFrame.historyBuffer:GetEntryAtIndex(1).message;
    lastChatFrameMessage.args = SafePack(...);
end

local function UpdateScannerEventRegistry(...)
    -- For our chat history feature, we want to replicate what we saw in the
    -- chat window. The CHAT_MSG events give us the message text, but not what
    -- appeared in the window. I haven't found any way to correlate a CHAT_MSG
    -- with the history buffer of the chat windows. Instead, we record each
    -- AddMessage call on the main window, and then when we process a CHAT_MSG
    -- event that matches, we grab the last message recorded here to get the
    -- full ChatFrame format.
    if CraftScan.Utils.IsScanningEnbled(...) then
        disableHook = false;

        if not registered then
            frame:RegisterEvent("CHAT_MSG_SAY")
            frame:RegisterEvent("CHAT_MSG_PARTY")
            frame:RegisterEvent("CHAT_MSG_CHANNEL")
            frame:RegisterEvent("CHAT_MSG_GUILD")
            frame:RegisterEvent("CHAT_MSG_WHISPER")
            frame:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
            registered = true;
        end
    else
        disableHook = true;
        if registered then
            registered = false;
            frame:UnregisterEvent("CHAT_MSG_SAY")
            frame:UnregisterEvent("CHAT_MSG_PARTY")
            frame:UnregisterEvent("CHAT_MSG_CHANNEL")
            frame:UnregisterEvent("CHAT_MSG_GUILD")
            frame:UnregisterEvent("CHAT_MSG_WHISPER")
            frame:UnregisterEvent("CHAT_MSG_WHISPER_INFORM")
        end
    end
end

CraftScan.Utils.onLoad(function()
    CraftScan.Scanner.LoadConfig()

    frame:SetScript("OnEvent", OnMessage)

    CraftScan.Utils.RegisterEnableDisableCallback(UpdateScannerEventRegistry)
    hooksecurefunc(_G.ChatFrame1, "AddMessage", CaptureChatMessage);
    UpdateScannerEventRegistry();

    CleanRecentAnalytics();
end)
