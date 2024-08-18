local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local saved = CraftScan.Utils.saved

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- With compression (recommended):
function CraftScan.Utils:Export(data)
    CraftScan.Utils.printTable("data", data);
    local serialized = LibSerialize:Serialize(data)
    --CraftScan.Utils.printTable("serialized", serialized);
    local compressed = LibDeflate:CompressDeflate(serialized)
    --CraftScan.Utils.printTable("compressed", compressed);
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

CraftScanComm = LibStub("AceAddon-3.0"):NewAddon("CraftScan", "AceComm-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

local CRAFT_SCAN_COMM_PREFIX = "CRAFT_SCAN"
function CraftScanComm:OnEnable()
    self:RegisterComm(CRAFT_SCAN_COMM_PREFIX)
end

-- When a player comes online, it sends a NotifyCharacterDataRev to all of its
-- imported characters with the revision number of all of its characters. If the
-- other account is online, it responds with all its characters that have a
-- higher revision number, and a request for any of its characters with a lower
-- revision number than it received. Imports/exports in this fashion do not
-- increment revision numbers, so the back and forth will settle down after each
-- side receives the most recent data. Accounts do report non-local revision
-- information so that information can be daisy chained to keep every account as
-- up to date as possibe.


CraftScanComm.Operations = {
    ShareCharacterData = 'share_char_data',
    Handshake = 'handshake',
}

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

local function MyPeers()
    local peers = {};
    for peer, _ in pairs(CraftScan.DB.settings.linked_accounts) do
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

-- Sharing has 3 phases. The first side sends an InitialInquiry with their
-- current profession revisions. The other side immediately responds with a
-- ResponseInquiry with its revisions. (We could potentially be smarter here
-- since we have a view of the other side already, but this data is small and
-- this keeps it clean an easy.) The side that received the InitialInquirty then
-- falls through and starts is ResponseData phase. While the originating side
-- responds to the ResponseInquiry with its ResponseData phase. By the end, both
-- sides will have received any out of date profession information that the
-- other side has.
--
-- We do this full flow when establishing peers and when a character logs in to
-- catch up on any changes it missed while offline.
--
-- When individual profession changes are made, they are pushed across directly
-- with the ResponseData phase since we know the other side is out of date.
local SharingState = {
    InitialInquiry = 1,
    ResponseInquiry = 2,
    ResponseData = 3,
}

-- TODO: This information will rarely change, so may be worth caching. It
-- shouldn't be run that often and it's not really expensive, so not bothering.
local function CreateReceivers()
    -- We don't know who is online on the other account, so walk our list of
    -- characters and group them by account so we can try to message all
    -- possible online characters.
    local receivers = {};
    for char, charConfig in pairs(CraftScan.DB.characters) do
        if charConfig.sourceID ~= nil and charConfig.sourceID ~= CraftScan.DB.settings.my_uuid then
            receivers[charConfig.sourceID] = receivers[charConfig.sourceID] or {}
            table.insert(receivers[charConfig.sourceID], char);
        end
    end
    if CraftScan.DB.settings.linked_accounts then
        for remoteID, info in pairs(CraftScan.DB.settings.linked_accounts) do
            -- It's possible we have receiving accounts with no crafters configured.
            -- If so, send to the one character we were peered with intially since
            -- that's the only character we know about.
            if not receivers[remoteID] then
                CraftScan.Utils.printTable("backup_char needed", info);
                receivers[remoteID] = { info.backup_char };
            end
        end
    end
    return receivers;
end

local function SendToReceivers(receivers, data)
    if type(receivers) ~= "table" then
        CraftScan.Utils.printTable("Single receiver", receivers)
        CraftScanComm:Transmit(data, CraftScanComm.Operations.ShareCharacterData, receivers);
    else
        for sourceID, characters in pairs(receivers) do
            CraftScan.Utils.printTable("Bulk send to", characters)
            CraftScanComm:Transmit(data, CraftScanComm.Operations.ShareCharacterData, characters);
        end
    end
end

local function SendResponseCharacterDataToReceivers(receivers, characters)
    SendToReceivers(receivers, { characters = characters, state = SharingState.ResponseData });
end

local function ShareCharacterData_(state, receiver)
    if not receiver then
        receiver = CreateReceivers();
    end

    if type(receiver) == "table" and not next(receiver) then return; end

    local revisions = CreateRevisions();
    local peers = MyPeers();
    local data = { revisions = revisions, peers = peers, state = state };
    SendToReceivers(receiver, data);
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

                        -- In case primary crafter was swapped while out of
                        -- communication, respect the side that wins and disable
                        -- others. It's possible that's the only modification
                        -- and both sides are at the same revision, in which
                        -- case they will stay out of sync until another
                        -- modification triggers another revision increment.
                        local skipReplication = true;
                        CraftScan.ProcessPrimaryCrafterUpdate({ name = char, parentProfID = ppID },
                            localCharConfig.parent_professions[ppID], skipReplication);
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

        if next(responseCharacters) then
            SendResponseCharacterDataToReceivers(sender, responseCharacters);
        end
    end
end

function CraftScanComm:ShareCharacterData()
    ShareCharacterData_(SharingState.InitialInquiry)
end

local function AddOnePpMsg(msgCharacters, char, charConfig, ppID, ppConfig, ppChangeOnly)
    ppConfig.rev = (ppConfig.rev or 0) + 1;

    local mc = saved(msgCharacters, char, {})
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
    local receivers = CreateReceivers();
    if not next(receivers) then return; end

    local msgCharacters = {};
    local ppChangeOnly = true;
    for char, charConfig in pairs(CraftScan.DB.characters) do
        for ppID, ppConfig in pairs(charConfig.parent_professions) do
            AddOnePpMsg(msgCharacters, char, charConfig, ppID, ppConfig, ppChangeOnly)
        end
    end

    SendResponseCharacterDataToReceivers(receivers, msgCharacters);
end

function CraftScanComm:ShareCharacterModification(char, ppID, ppChangeOnly)
    local receivers = CreateReceivers();
    if not next(receivers) then return; end

    local msgCharacters = {};

    local charConfig = CraftScan.DB.characters[char];
    local ppConfig = charConfig.parent_professions[ppID];
    AddOnePpMsg(msgCharacters, char, charConfig, ppID, ppConfig, ppChangeOnly)

    SendResponseCharacterDataToReceivers(receivers, msgCharacters);
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
    local linkedAccounts = saved(CraftScan.DB.settings, 'linked_accounts', {});
    linkedAccounts[pending.remoteID] = {
        nickname = pending.nickname,
        backup_char = pending.character,
    }
    CraftScan.Utils.printTable("linkedAccounts:", linkedAccounts)
end

function CraftScanComm:ReceiveHandshake(sender, data)
    print("Received handshake from", sender)
    if data.result then
        print("data.result");
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
        print("version mismatch");
        CraftScanComm:Transmit(
            {
                result = CraftScanComm.Result.VersionMismatch,
                result_data =
                    CraftScan.CONST.CURRENT_VERSION
            },
            CraftScanComm.Operations.Handshake, sender);
        return;
    end

    print("Updating UI");
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
    print("Setting nickname:", nickname);
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

local function TransmitToAllTargets(encoded, targets)
    for i, target in ipairs(targets) do
        CraftScan.Utils.printTable("Sending request to", target)
        SendMessage(encoded, target);
    end
end


-- There is weirdly no way to test if a player is online, so our 'test' is
-- to put a chat filter in place to ignore the 'player not found' message,
-- fire off the message to everyone, and hopefully detect which character is
-- online and remember it for next time. If we have a prior online
-- character, we try that one first. If it doesn't match our filter after a
-- few seconds, we assume the send was successful. If it does match our
-- filter, the character has logged off and we try everyone again.
local onlineCharacters = {};

local IgnoreOfflineMessages = {}
IgnoreOfflineMessages.__index = IgnoreOfflineMessages;

function IgnoreOfflineMessages:new(targets)
    local self = setmetatable({}, IgnoreOfflineMessages);

    local onlineIndex = nil;
    for i, target in ipairs(targets) do
        -- If we've messaged a target successfully already, we try that
        -- target first and test for success before sending to others.
        if onlineCharacters[target] ~= nil then
            self.lastOnline = target;
            onlineIndex = i;
            self.targets = targets;
        else
            self.filtered = self.filtered or {};
            local msg = ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%%s", CraftScan.NameAndRealmToName(target));
            self.filtered[target] = {
                msg = msg,
                online = true, -- Assume true, flip to false if we filter an offline warning.
            }
        end
    end

    if onlineIndex then
        table.remove(targets, onlineIndex)
    end

    local function CreateOfflineChatFilter(filtered)
        CraftScan.Utils.printTable("Created chat filter. Ignoring:", filtered)
        return function(self, event, msg)
            for char, filter in pairs(filtered) do
                if msg == filter.msg then
                    filter.online = false;
                    return true;
                end
            end
        end
    end

    self.filter = CreateOfflineChatFilter(self.lastOnline and onlineCharacters or self.filtered);

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.filter)

    return self;
end

function IgnoreOfflineMessages:Clear()
    local function ClearFilter()
        local function RemoveFilter()
            ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.filter)
        end

        if self.lastOnline then
            if not onlineCharacters[self.lastOnline].online then
                onlineCharacters[self.lastOnline] = nil;
                self.lastOnline = nil;

                -- Try again by sending to all the targets
                TransmitToAllTargets(encoded, targets, self);
                self:Clear();
            else
                -- We successfully sent to the last online target, so we're done.
                CraftScan.Utils.printTable("Send successful", self.lastOnline)
                RemoveFilter();
            end

            return
        end

        CraftScan.Utils.printTable("Filter timeout. Results", self.filtered)
        for char, filter in pairs(self.filtered) do
            if filter.online then
                onlineCharacters[char] = filter;
            end
        end
        CraftScan.Utils.printTable("Online characters", onlineCharacters)
        RemoveFilter();
    end

    -- If we're testing a character known to be online, we only wait 2 seconds
    -- since it should be a single send and is hopefully fast. If that fails, we
    -- fall back to the full list of targets and allow 10 seconds for all the
    -- attempts. Addon messages are throttled, so it takes some time.
    local timeout = self.lastOnline and 2 or 10;
    C_Timer.After(timeout, ClearFilter);
end

local function TransmitSerialized(serialized, targets)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

    local filter = IgnoreOfflineMessages:new(targets);

    if filter.lastOnline then
        SendMessage(encoded, filter.lastOnline);
    else
        TransmitToAllTargets(encoded, targets);
    end

    filter:Clear();
end

local asyncPool = CreateFramePool("Frame", UIParent);

function CraftScanComm:Transmit(data, operation, targets)
    if type(targets) ~= "table" then
        -- Normalize our input to keep it simple. We support either a single
        -- character or an array of characters.
        targets = { targets };
    end


    local msg = {
        operation = operation,
        data = data,
        senderID = CraftScan.DB.settings.my_uuid,
    };

    local handler = LibSerialize:SerializeAsync(msg)

    local processing = asyncPool:Acquire();
    processing:SetScript("OnUpdate", function()
        local completed, serialized = handler()
        if completed then
            processing:SetScript("OnUpdate", nil)
            asyncPool:Release(processing);
            TransmitSerialized(serialized, targets);
        end
    end)

    -- OnUpdate won't fire if the frame is hidden, which is is by default when
    -- fetched from the pool.
    processing:Show();
end

local function ReceiveDeserialized(msg, sender)
    CraftScan.Utils.printTable("msg", msg);

    if msg.operation == CraftScanComm.Operations.Handshake then
        self:ReceiveHandshake(sender, msg.data);
    else
        local linkedAccounts = CraftScan.DB.settings.linked_accounts;
        if not linkedAccounts or not linkedAccounts[msg.senderID] then
            CraftScan.Utils.printTable("Ignoring message from unlinked account.", nil)
            return;
        end
        if msg.operation == CraftScanComm.Operations.ShareCharacterData then
            ReceiveShareCharacterData(sender, msg.data, msg.senderID);
        end
    end
end

function CraftScanComm:OnCommReceived(prefix, payload, distribution, sender)
    CraftScan.Utils.printTable("Received packet", prefix);

    if prefix ~= CRAFT_SCAN_COMM_PREFIX then return; end

    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload);
    if not decoded then return; end
    CraftScan.Utils.printTable("decoded", true);

    local decompressed = LibDeflate:DecompressDeflate(decoded);
    if not decompressed then return; end
    CraftScan.Utils.printTable("decompressed", true);

    local handler = LibSerialize:DeserializeAsync(decompressed);
    local processing = asyncPool:Acquire();
    processing:SetScript("OnUpdate", function()
        local completed, success, deserialized = handler()
        if completed then
            CraftScan.Utils.printTable("deserialize_complete", true);

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
