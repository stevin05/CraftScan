local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

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

local function ReceiveShareCharacterData(sender, data)
    -- After receiving a revision to which one side has more recent data, it
    -- will reply with the full character information. This block imports it on
    -- the side that was found out of date.
    local characters = data.characters;
    for char, charInfo in pairs(characters) do
        local localCharInfo = CraftScan.DB.characters[char];
        if not localCharInfo.character_disabled and not localCharInfo.rev or charInfo.rev > localCharInfo.rev then
            CraftScan.Utils.printTable("Importing character:", char)
            charInfo.imported = true;
            CraftScan.DB.characters[char] = charInfo;
        end
    end

    -- An abbreviated 'revision' info is sent as a check/request for updated
    -- information. If we receive a revision check and we have more recent data,
    -- we send it back in the 'characters' block to be processed above on the
    -- other side.
    local responseCharacters = {}
    local revisions = data.revisions;
    CraftScan.Utils.printTable("Received revisions:", revisions)
    for revChar, revCharInfo in pairs(revisions) do
        local localCharInfo = CraftScan.DB.characters[revChar];
        if not localCharInfo.character_disabled and revCharInfo.rev > (localCharInfo.rev or 0) then
            localCharInfo.rev = localCharInfo.rev or 0; -- Initialize revisions when we start sharing data
            responseCharacters[char] = localCharInfo;
        end
    end

    if next(responseCharacters) then
        CraftScanComm:Transmit({ characters = responseCharacters }, CraftScanComm.Operations.ShareCharacterData, sender);
    end

    if next(characters) then
        CraftScan.OnCrafterListModified();
    end
end

local function CreateRevisions()
    local revisions = {};
    for char, charInfo in pairs(CraftScan.DB.characters) do
        if not charInfo.character_disabled then
            revisions[char] = {
                rev = charInfo.rev or 0
            }
        end
    end
    return revisions;
end

function CraftScanComm:ShareCharacterData()
    local receivers = {}
    for char, charInfo in pairs(CraftScan.DB.characters) do
        if not charInfo.disabled_character and charInfo.imported then
            table.insert(receivers, char);
        end
    end

    if not next(receivers) then return; end

    local revisions = CreateRevisions();
    CraftScan.Utils.printTable("Sending revisions:", revisions)
    for _, receiver in ipairs(receiver) do
        CraftScanComm:Transmit({ revisions = revisions }, CraftScanComm.Operations.ShareCharacterData, receiver);
    end
end

function CraftScanComm:SendHandshake(target)
    local function GenerateUniqueNumber()
        -- ChatGPT... looks unique enough for this.
        local timePart = os.clock() * 1000000
        local randomPart = math.random(100000);
        return tonumber(timePart .. randomPart)
    end

    local peerID = GenerateUniqueNumber();

    CraftScanComm:Transmit({ peerID = peerID, version = CraftScan.CONSTS.CURRENT_VERSION },
        CraftScanComm.Operations.Handshake, target);
end

function CraftScanComm:ReceiveHandshake(data, sender)
    CraftScan.pending_peers = CraftScan.pending_peers or {};
    CraftScan.pending_peers[data.peerID] = sender;
    CraftScan.OnPendingPeerAdded();
end

-- With compression (recommended):
function CraftScanComm:Transmit(data, operation, target)
    local msg = {
        operation = operation,
        data = data,
    };
    local serialized = LibSerialize:Serialize(msg)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    self:SendCommMessage(CRAFT_SCAN_COMM_PREFIX, encoded, "WHISPER", target)
end

function CraftScanComm:OnCommReceived(prefix, payload, distribution, sender)
    if prefix ~= CRAFT_SCAN_COMM_PREFIX then return end
    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
    if not decoded then return end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return end
    local success, msg = LibSerialize:Deserialize(decompressed)
    if not success then return end

    if msg.operation == CraftScanComm.Operations.ShareCharacterData then
        ReceiveShareCharacterData(sender, msg.data);
    elseif msg.operation == CraftScanComm.Operations.Handshake then
    end
end
