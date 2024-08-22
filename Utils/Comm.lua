local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local saved = CraftScan.Utils.saved

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- We don't use this yet, but if we ever want a manual import/export process, use these:
--[[
function CraftScan.Utils:Export(data)
    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForPrint(compressed);
    return encoded;
end

function CraftScan.Utils:Import(encoded)
    local decoded = LibDeflate:DecodeForPrint(encoded);
    if not decoded then return end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return end
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then return end
    return data;
end
]]

CraftScanComm = LibStub("AceAddon-3.0"):NewAddon("CraftScan", "AceComm-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

local CRAFT_SCAN_COMM_PREFIX = "CRAFT_SCAN"
function CraftScanComm:OnEnable()
    self:RegisterComm(CRAFT_SCAN_COMM_PREFIX)
end

CraftScanComm.Operations = {
    ShareCharacterData  = 'share_char_data',
    Handshake           = 'handshake',
    ShareCustomerOrder  = 'share_customer_order',
    ShareCustomGreeting = 'share_custom_greeting'
}

-- A flag to send the request to all known linked accounts
local TARGET_ALL = nil;

-- Accounts that respond to the initial sharing phase are stored here. From then
-- on, we keep this updated with who is talking to us, and we only talk back to
-- them. If a new remote account comes online, their sharing phase will replace
-- any prior entry from that account.
local remoteTargets = nil;

local function HaveTarget()
    if remoteTargets then
        for _, target in pairs(remoteTargets) do
            if next(target) then
                return true;
            end
        end
    end

    -- We either have no one to talk to, or we haven't sent our greeting yet.
    -- The greeting syncs in both directions, so it's fine to skip updates
    -- before then. It's likely impossible in practice to sneak something into
    -- this window.
    return false;
end

local function LinkedAccountsConfigured()
    if not CraftScan.DB.realm.linked_accounts or not next(CraftScan.DB.realm.linked_accounts) then
        return false;
    end
    return true;
end

local function CreateInitialTargets()
    local targets = {};

    for char, charConfig in pairs(CraftScan.DB.characters) do
        if charConfig.sourceID ~= nil and charConfig.sourceID ~= CraftScan.DB.settings.my_uuid then
            targets[charConfig.sourceID] = targets[charConfig.sourceID] or {}
            targets[charConfig.sourceID][char] = true;
        end
    end

    for sourceID, info in pairs(CraftScan.DB.realm.linked_accounts) do
        targets[sourceID] = targets[sourceID] or {}
        for _, char in ipairs(info.backup_chars) do
            targets[sourceID][char] = true;
        end
    end

    return targets;
end

-- Sharing has 3 phases. The first side sends an InitialInquiry with their
-- current profession revisions. The other side immediately responds with a
-- ResponseInquiry with its revisions. (We could potentially be smarter here
-- since we have a view of the other side already, but this data is small and
-- this keeps it clean and easy.) The side that received the InitialInquiry then
-- falls through and starts is ResponseData phase. When the originating side
-- receives the ResponseInquiry, it moves directly to the ResponseData phase
-- (without infinitely recursing on more ResponseInquiries). By the end, both
-- sides will have received any out of date profession information that the
-- other side has.
--
-- We do this full flow when establishing a linked account and when a character
-- logs in to catch up on any changes it missed while offline. This message is
-- also the only one we allow through while 'remoteTargets' is not initialized.
-- This initial sharing phase is also used to seed the remoteTargets so we know
-- who is online for future messages.
--
-- When individual profession changes are made, they are pushed across directly
-- with the ResponseData phase since we know the other side is out of date.
local SharingState = {
    InitialInquiry = 1,
    ResponseInquiry = 2,
    ResponseData = 3,
}

-- Filter our character list to only the revisions to send a small amount of
-- data in our greeting to other accounts.
local function CreateRevisions()
    local revisions = {};
    for char, charConfig in pairs(CraftScan.DB.characters) do
        for ppID, ppConfig in pairs(charConfig.parent_professions) do
            local ppRev = saved(revisions, char, {})
            ppRev[ppID] = ppConfig.rev or 0;
        end
    end
    return revisions;
end

-- Linked accounts can update eachother about a 3rd account, but only if the 3rd
-- account is also a linked such that the receiver can see it directly.
-- Inquiries include the requester's peer list so the response can be filtered.
local function MyPeers()
    local peers = {};
    for peer, _ in pairs(CraftScan.DB.realm.linked_accounts) do
        table.insert(peers, peer);
    end
    return peers;
end

local function CharacterInPeers(charConfig, peers)
    for _, peer in ipairs(peers) do
        if charConfig.sourceID == peer then return true; end
    end

    return false;
end

local function GreetingRevision()
    local greeting = CraftScan.DB.settings.greeting;
    return greeting and greeting.rev or 0;
end

local function SendShareCharacterData(target, data)
    CraftScanComm:Transmit(data, CraftScanComm.Operations.ShareCharacterData, target);
end

local function SendResponseCharacterData(target, characters, greeting)
    SendShareCharacterData(target, { characters = characters, greeting = greeting, state = SharingState.ResponseData });
end

local function ShareCharacterData_(state, target)
    if not LinkedAccountsConfigured() then return; end

    local revisions = CreateRevisions();
    local peers = MyPeers();
    local data = { revisions = revisions, peers = peers, greeting_revision = GreetingRevision(), state = state };
    SendShareCharacterData(target, data);
end

local function ReceiveShareCustomGreeting_(greeting)
    if not CraftScan.DB.settings.greeting or CraftScan.DB.settings.greeting.rev < greeting.rev then
        CraftScan.DB.settings.greeting = greeting;
    end
end

local function ReceiveShareCharacterData(sender, data, senderID)
    if data.state == SharingState.InitialInquiry then
        -- The other side is requesting data, so we do the same to make sure
        -- everything is in sync.
        ShareCharacterData_(SharingState.ResponseInquiry, sender);
    end

    local characters = data.characters;
    if characters then
        -- Process a reply with more up to date profession information. We verify
        -- one last time here that we only import more recent data.
        for char, charConfig in pairs(characters) do
            local localCharConfig = CraftScan.DB.characters[char];
            if not localCharConfig then
                CraftScan.DB.characters[char] = charConfig;
            else
                if not localCharConfig.sourceID then
                    localCharConfig.sourceID = charConfig.sourceID;
                end
                for ppID, ppConfig in pairs(charConfig.parent_professions) do
                    if not localCharConfig.parent_professions[ppID] or ((localCharConfig.parent_professions[ppID].rev or 0) < (ppConfig.rev or 0)) or ppConfig.character_disabled then
                        localCharConfig.parent_professions[ppID] = ppConfig;
                        if ppConfig.character_disabled then
                            -- The other side can't send the lack of something
                            -- without a special payload, so we handle the
                            -- character_disabled flag specially to copy the
                            -- parent side behavior of wiping out child
                            -- professions.
                            CraftScan.RemoveChildProfessions(localCharConfig, parentProfID);
                        elseif charConfig.professions then -- Can be excluded for parent only changes
                            for id, config in pairs(charConfig.professions) do
                                if config.parentProfID == ppID then
                                    localCharConfig.professions[id] = config;
                                end
                            end
                        end
                    end
                end
            end
        end
        if next(characters) then
            CraftScanComm.applying_remote_state = true;
            CraftScan.OnCrafterListModified();
            CraftScanComm.applying_remote_state = false;
        end
    end

    if data.greeting then
        ReceiveShareCustomGreeting_(data.greeting);
    end

    if data.state ~= SharingState.ResponseData then
        -- We were given revisions. Respond with any character data that is
        -- either newer than or not included in the revisions, filtered by what
        -- the peer told us they are allowed to see.
        local revisions = data.revisions;
        local responseCharacters = {}
        local peers = data.peers;
        for char, localCharConfig in pairs(CraftScan.DB.characters) do
            local characterOwnedByPeer = localCharConfig.sourceID == senderID;
            if CharacterInPeers(localCharConfig, peers) or characterOwnedByPeer then
                local remoteCharConfig = revisions[char];
                if not remoteCharConfig then
                    if next(localCharConfig.parent_professions) then
                        responseCharacters[char] = localCharConfig;
                    end
                else
                    -- Both sides have the character, walk the professions and
                    -- return only what the other side has out of date.
                    for ppID, ppConfig in pairs(localCharConfig.parent_professions) do
                        if not remoteCharConfig[ppID] or ((remoteCharConfig[ppID] or 0) < (ppConfig.rev or 0)) then
                            local rc = saved(responseCharacters, char, {});
                            local pps = saved(rc, 'parent_professions', {});
                            pps[ppID] = ppConfig;

                            -- Only the character owning account has access to
                            -- modify professions, so we don't need to worry
                            -- about sending them.
                            if not characterOwnedByPeer then
                                for id, config in pairs(localCharConfig.professions) do
                                    if config.parentProfID == ppID then
                                        local profs = saved(rc, 'professions', {});
                                        profs[id] = config;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local greetingResponse = nil;
        local greetingRevision = GreetingRevision();
        if data.greeting_revision and data.greeting_revision < greetingRevision then
            greetingResponse = CraftScan.DB.settings.greeting;
        end

        if next(responseCharacters) or greetingResponse then
            SendResponseCharacterData(sender, responseCharacters, greetingResponse);
        end
    end
end

function CraftScanComm:ShareCharacterData()
    ShareCharacterData_(SharingState.InitialInquiry)
end

local function AddOnePpMsg(msgCharacters, char, charConfig, ppID, ppConfig, ppChangeOnly)
    local mc = saved(msgCharacters, char, {})
    mc.sourceID = charConfig.sourceID;

    local pps = saved(mc, 'parent_professions', {})
    pps[ppID] = ppConfig;

    if not ppChangeOnly then
        for id, config in pairs(charConfig.professions) do
            if config.parentProfID == ppID then
                local profs = saved(mc, 'professions', {});
                profs[id] = config;
            end
        end
    end
end

-- For the toggle-all buttons at the top of the character list, do a bulk push
-- of all parent professions with no child profession data.
function CraftScanComm:ShareAllPpCharacterModifications()
    if not LinkedAccountsConfigured() then return; end

    for _, charConfig in pairs(CraftScan.DB.characters) do
        for _, ppConfig in pairs(charConfig.parent_professions) do
            ppConfig.rev = (ppConfig.rev or 0) + 1;
        end
    end

    if not HaveTarget() then return; end

    local msgCharacters = {};
    local ppChangeOnly = true;
    for char, charConfig in pairs(CraftScan.DB.characters) do
        for ppID, ppConfig in pairs(charConfig.parent_professions) do
            AddOnePpMsg(msgCharacters, char, charConfig, ppID, ppConfig, ppChangeOnly)
        end
    end

    SendResponseCharacterData(TARGET_ALL, msgCharacters);
end

-- A single modification to the profession. We don't get specific - if they
-- changed anything, toss the whole profession across.
function CraftScanComm:ShareCharacterModification(char, ppID, ppChangeOnly)
    if not LinkedAccountsConfigured() then return; end

    local charConfig = CraftScan.DB.characters[char];
    local ppConfig = charConfig.parent_professions[ppID];
    ppConfig.rev = (ppConfig.rev or 0) + 1;

    if not HaveTarget() then return; end

    local msgCharacters = {};

    AddOnePpMsg(msgCharacters, char, charConfig, ppID, ppConfig, ppChangeOnly)

    SendResponseCharacterData(TARGET_ALL, msgCharacters);
end

function CraftScanComm:ShareCustomerOrder(message, customer, customerGuid, lastChatFrameMessage)
    if not HaveTarget() or not LinkedAccountsConfigured() then return; end
    if CraftScanComm.applying_remote_state then return; end          -- Block infinite recursion
    if not CraftScan.DB.settings.proxy_send_enabled then return; end -- We're disabled

    local data = {
        message = message,
        customer = customer,
        customerGuid = customerGuid,
        lastChatFrameMessage = CraftScan.Utils.DeepCopy(lastChatFrameMessage),
    };

    -- Trying to send a function crashes serialization. Only seen this in testing at args[9]
    if data.lastChatFrameMessage and data.lastChatFrameMessage.args and type(data.lastChatFrameMessage.args[9]) == "function" then
        data.lastChatFrameMessage.args[9] = nil;
        data.lastChatFrameMessage.args['n'] = data.lastChatFrameMessage.args['n'] - 1;
    end

    CraftScanComm:Transmit(data, CraftScanComm.Operations.ShareCustomerOrder, TARGET_ALL);
end

local function ReceiveShareCustomerOrder(sender, data, senderID)
    if not CraftScan.DB.settings.proxy_receive_enabled then return; end
    if not CraftScan.InjectLastChatFrameMessage(data.customer, data.message, data.lastChatFrameMessage) then return; end

    -- We pull the formatted message from a rotating chat log buffer, so
    -- inject the raw chat frame into that so it can be found.
    CraftScanComm.applying_remote_state = true;

    -- Make sure the button is showing so the banner can be shown.
    CraftScanScannerMenu:Show()

    -- The sending side only sends after they get a match, but the minimum
    -- amount of data to send is simply the message itself and the customer. We
    -- have all the same config on this side, so we can process it in the same
    -- way. This is more work on this side, but it minimizes both the sent data and
    -- the differences between a received message and a naturally detected message.
    CraftScan.OnMessage("CHAT_MSG_CHANNEL", data.message, data.customer, data.customerGuid);

    CraftScanComm.applying_remote_state = false;
end

function CraftScanComm:ShareCustomGreeting(greeting)
    if not LinkedAccountsConfigured() then return; end

    greeting.rev = (greeting.rev or 0) + 1;

    if not HaveTarget() then return; end
    if CraftScanComm.applying_remote_state then return; end -- Block infinite recursion

    CraftScanComm:Transmit(greeting, CraftScanComm.Operations.ShareCustomGreeting, TARGET_ALL);
end

local function ReceiveShareCustomGreeting(sender, data, senderID)
    ReceiveShareCustomGreeting_(data);
end

local function InitMyUUID()
    if not CraftScan.DB.settings.my_uuid then
        local random = math.random
        local function MakeUUID()
            local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
            return string.gsub(template, '[xy]', function(c)
                local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                return string.format('%x', v)
            end)
        end
        local myUuid = MakeUUID();
        CraftScan.DB.settings.my_uuid = myUuid;
        for char, charConfig in pairs(CraftScan.DB.characters) do
            charConfig.sourceID = myUuid;
        end
    end
end

function CraftScanComm:SendHandshake(target, nickname)
    CraftScan.pending_peer_accept = {
        character = target,
        nickname = nickname,
    };

    InitMyUUID();
    CraftScanComm:Transmit({ remoteID = CraftScan.DB.settings.my_uuid, version = CraftScan.CONST.CURRENT_VERSION },
        CraftScanComm.Operations.Handshake, target);
end

CraftScanComm.Result = {
    OK = 1,
    VersionMismatch = 1,
};

local function GetRejectionMessage(result, data)
    if result == CraftScanComm.Result.VersionMismatch then
        return string.format(L(LID.VERSION_MISMATCH), data, CraftScan.CONST.CURRENT_VERSION);
    end

    return "Received unknown error code: " .. result .. ". Argument: " .. (data or "none");
end

local function AcceptPeerRequest_(pending)
    local linkedAccounts = saved(CraftScan.DB.realm, 'linked_accounts', {});
    linkedAccounts[pending.remoteID] = {
        nickname = pending.nickname,
        backup_chars = { pending.character },
    }

    if not remoteTargets then
        -- If this is the first time we're linking to anyone, we didn't
        -- initialize remoteTargets. We know who we're talking to already, so we
        -- can fully initialize it.
        remoteTargets = {
            [pending.remoteID] = { [pending.character] = time() },
        };
    end

    CraftScan.Utils.printTable("linkedAccounts:", linkedAccounts)
end

function ReceiveHandshake(sender, data)
    if data.result then
        if data.result == CraftScanComm.Result.OK then
            CraftScan.pending_peer_accept.remoteID = data.result_data.remoteID;
            AcceptPeerRequest_(CraftScan.pending_peer_accept);
            CraftScan.pending_peer_accept = nil;
            CraftScan.OnPendingPeerAccepted();

            -- Now that we know about the peer, kick off the initial sharing, which is
            -- necessary to identify some characters on the other side so we can use
            -- them to stay in sync.
            ShareCharacterData_(SharingState.InitialInquiry, sender);
        else
            CraftScan.OnPendingPeerRejected(GetRejectionMessage(data.result, data.result_data));
        end
        return;
    end

    if data.version ~= CraftScan.CONST.CURRENT_VERSION then
        CraftScanComm:Transmit(
            {
                result = CraftScanComm.Result.VersionMismatch,
                result_data = CraftScan.CONST.CURRENT_VERSION
            },
            CraftScanComm.Operations.Handshake, sender);
        return;
    end

    CraftScan.pending_peer_request = {
        remoteID = data.remoteID,
        character = sender,
    }
    CraftScan.OnPendingPeerAdded();
end

function CraftScanComm:HavePendingPeerRequest()
    return CraftScan.pending_peer_request ~= nil;
end

function CraftScanComm:GetPendingPeerRequestCharacter()
    return CraftScan.pending_peer_request.character;
end

function CraftScanComm:AcceptPeerRequest(nickname)
    CraftScan.pending_peer_request.nickname = nickname;
    AcceptPeerRequest_(CraftScan.pending_peer_request);

    InitMyUUID();
    CraftScanComm:Transmit(
        {
            result = CraftScanComm.Result.OK,
            result_data = {
                remoteID = CraftScan.DB.settings.my_uuid,
            }
        },
        CraftScanComm.Operations.Handshake,
        CraftScan.pending_peer_request.character);

    CraftScan.pending_peer_request = nil;
    CraftScan.OnPendingPeerAccepted();
end

local function SendMessage(encoded, target)
    CraftScanComm:SendCommMessage(CRAFT_SCAN_COMM_PREFIX, encoded, "WHISPER", target)
end

-- There is weirdly no way to test if a player is online. Originally, we tested
-- if characters were online by the lack of an error message when sending a
-- message. Unfortunately, it seems that at least in Aug 2024, you can
-- successfully send messages to your own characters that have been offline for
-- hours, so that test is out the window. The solution is actually better
-- though. Since we always ping around the latest information on login, and we
-- know only one character per account can be logged in, we can group our
-- characters by account and know that the last one that sent us a message is
-- the one that is online. If that one doesn't work any more, that's fine - when
-- another logs in, it will tell us and we'll save that. The only time we need
-- to ping multiple remote targets is on login when we are announcing ourselves
-- and waiting for replies.
local IgnoreOfflineMessages = {}
IgnoreOfflineMessages.__index = IgnoreOfflineMessages;

function IgnoreOfflineMessages:new(targets, encoded)
    local self = setmetatable({}, IgnoreOfflineMessages);

    for _, accountTargets in pairs(targets) do
        for target, _ in pairs(accountTargets) do
            -- If we've messaged a target successfully already, we try that
            -- target first and test for success before sending to others.
            self.filtered = self.filtered or {};

            local filter = 
                ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%%s", target);
            self.filtered[target] = { filter };

                -- On non-connected realms, something below us auto-removes the
                -- realm name from the target. It even happens on connected
                -- realms if the the characters are on the same realm, so we do
                -- this unconditionally.
                filter = ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%%s", CraftScan.NameAndRealmToName(target));
                table.insert(self.filtered[target], filter);
        end
    end

    local function CreateOfflineChatFilter(filtered)
        CraftScan.Utils.printTable("Created chat filter. Ignoring", filtered)
        return function(self, event, msg)
            for char, filter in pairs(filtered) do
                for _, f in ipairs(filter) do
                    if msg == f then
                        return true;
                    end
                end
            end
        end
    end

    self.filter = CreateOfflineChatFilter(self.filtered);

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.filter)

    return self;
end

function IgnoreOfflineMessages:Clear()
    -- 30 is hopefully overkill here, but it's not really harmful as people are
    -- not likely to message their own offline alts manually.
    C_Timer.After(30, function() ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.filter) end);
end

local function TransmitSerialized(serialized, target)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

    -- In responses, we're given an explicit character to send to, so we use it.
    -- Otherwise, generate a list of tarets based on our linked accounts. The
    -- offline message filter will hopefully be able to narrow that down to a
    -- character we already communicated with first so we don't have to send to
    -- every character every time.
    local targets = {};
    if target then
        table.insert(targets, { [target] = true });
    else
        if not remoteTargets then
            targets = CreateInitialTargets();
            remoteTargets = {};
        else
            targets = remoteTargets;
        end
    end

    CraftScan.Utils.printTable("targets", targets);

    local filter = IgnoreOfflineMessages:new(targets, encoded);

    for _, accountTargets in pairs(targets) do
        for target, _ in pairs(accountTargets) do
            CraftScan.Utils.printTable("Sending request to", target)
            SendMessage(encoded, target);
        end
    end

    filter:Clear();
end

local asyncPool = CreateFramePool("Frame", UIParent);

function CraftScanComm:Transmit(data, operation, target)
    local msg = {
        operation = operation,
        version = CraftScan.CONST.CURRENT_VERSION,
        data = data,
        senderID = CraftScan.DB.settings.my_uuid,
    };
    CraftScan.Utils.printTable("Sending msg", msg)

    local handler = LibSerialize:SerializeAsync(msg)

    local processing = asyncPool:Acquire();
    processing:SetScript("OnUpdate", function()
        local completed, serialized = handler()
        if completed then
            processing:SetScript("OnUpdate", nil)
            asyncPool:Release(processing);
            TransmitSerialized(serialized, target);
        end
    end)

    -- OnUpdate won't fire if the frame is hidden, which is is by default when
    -- fetched from the pool.
    processing:Show();
end

local function ReceiveRemoteTarget(senderID, sender)
    remoteTargets[senderID] = { [sender] = time() };
    CraftScan.OnLinkedAccountStateChange()

    -- TODO: Connected realms - does sender come with the realm name?
    local nameAndRealm = sender .. "-" .. GetRealmName();

    -- If we are receiving from a character that is not a crafter, save the name
    -- as a backup so we can find it again during future discovery phases.
    local backupChars = CraftScan.DB.realm.linked_accounts[senderID].backup_chars;
    if not CraftScan.DB.characters[nameAndRealm] and not CraftScan.Utils.Contains(backupChars, sender) then
        table.insert(backupChars, sender);
        CraftScan.Utils.printTable("Updated backupChars", backupChars);
    end

    CraftScan.Utils.printTable("Updated remoteTargets", remoteTargets);
end

local function ReceiveDeserialized(msg, sender)
    CraftScan.Utils.printTable("Received msg", msg);

    if msg.operation == CraftScanComm.Operations.Handshake then
        ReceiveHandshake(sender, msg.data);
    else
        if msg.version ~= CraftScan.CONST.CURRENT_VERSION then
            print(string.format(L(LID.VERSION_MISMATCH), msg.version, CraftScan.CONST.CURRENT_VERSION));
            return;
        end

        local linkedAccounts = CraftScan.DB.realm.linked_accounts;
        if not linkedAccounts or not linkedAccounts[msg.senderID] then
            CraftScan.Utils.printTable("Ignoring message from unlinked account.", nil)
            return;
        end

        if remoteTargets then
            ReceiveRemoteTarget(msg.senderID, sender)
        end

        if msg.operation == CraftScanComm.Operations.ShareCharacterData then
            ReceiveShareCharacterData(sender, msg.data, msg.senderID);
        end
        if msg.operation == CraftScanComm.Operations.ShareCustomerOrder then
            ReceiveShareCustomerOrder(sender, msg.data, msg.senderID);
        end
        if msg.operation == CraftScanComm.Operations.ShareCustomGreeting then
            ReceiveShareCustomGreeting(sender, msg.data, msg.senderID);
        end
    end
end

function CraftScanComm:OnCommReceived(prefix, payload, distribution, sender)
    CraftScan.Utils.printTable("Received from", sender);
    CraftScan.Utils.printTable("distribution", distribution);
    if not CraftScan.State.realmID or string.find(sender, '-') == nil then
        -- We're not on a connected realm, so hardcode the sender's realm to our
        -- own. I'm hitting some weird cases where my chat auto-completes the
        -- character name to a character of mine by the same name on a different
        -- realm. On connected realms, we just have to hope the infra puts the
        -- realm in the sender name already, which it seems to.
        --
        -- Even on connected realms, it seems that the sender realm is erased if
        -- it's the same realm, and then we can't even send a reply, so we also
        -- check for -
        sender = CraftScan.GetUnitName(sender, true);
    end

    if prefix ~= CRAFT_SCAN_COMM_PREFIX then return; end

    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload);
    if not decoded then return; end

    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then return; end

    local handler = LibSerialize:DeserializeAsync(decompressed);
    local processing = asyncPool:Acquire();
    processing:SetScript("OnUpdate", function()
        local completed, success, deserialized = handler()
        if completed then
            processing:SetScript("OnUpdate", nil)
            asyncPool:Release(processing);
            if not success then return end
            ReceiveDeserialized(deserialized, sender);
        end
    end)

    -- OnUpdate won't fire if the frame is hidden, which is is by default when
    -- fetched from the pool.
    processing:Show();
end

function CraftScanComm:LinkState(sourceID)
    if not remoteTargets or remoteTargets[sourceID] == nil then
        return nil;
    end
    return next(remoteTargets[sourceID]);
end
