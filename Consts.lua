local CraftScan = select(2, ...)

CraftScan.CONST = {}

CraftScan.CONST.LEFT = 0;
CraftScan.CONST.RIGHT = 1;

---@enum CraftScan.LOCALIZATION_IDS
CraftScan.CONST.TEXT = {
    CRAFT_SCAN                              = 0,
    CHAT_ORDERS                             = 1,
    DISABLE_ADDONS                          = 2,
    RENABLE_ADDONS                          = 3,
    DISABLE_ADDONS_TOOLTIP                  = 4,
    GREETING_I_CAN_CRAFT_ITEM               = 5,
    GREETING_ALT_CAN_CRAFT_ITEM             = 6,
    GREETING_LINK_BACKUP                    = 7,
    GREETING_I_HAVE_PROF                    = 8,
    GREETING_ALT_HAS_PROF                   = 9,
    GREETING_ALT_SUFFIX                     = 10,
    MAIN_BUTTON_BINDING_NAME                = 11,
    GREET_BUTTON_BINDING_NAME               = 12,
    DISMISS_BUTTON_BINDING_NAME             = 13,
    TOGGLE_CHAT_TOOLTIP                     = 14,
    SCANNER_CONFIG_SHOW                     = 16,
    SCANNER_CONFIG_HIDE                     = 17,
    CRAFT_SCAN_OPTIONS                      = 18,
    ITEM_SCAN_CHECK                         = 19,
    HELP_PROFESSION_KEYWORDS                = 20,
    HELP_PROFESSION_EXCLUSIONS              = 21,
    HELP_SCAN_ALL                           = 22,
    HELP_PRIMARY_EXPANSION                  = 23,
    HELP_EXPANSION_GREETING                 = 24,
    HELP_CATEGORY_KEYWORDS                  = 25,
    HELP_CATEGORY_GREETING                  = 26,
    HELP_CATEGORY_OVERRIDE                  = 27,
    HELP_ITEM_KEYWORDS                      = 28,
    HELP_ITEM_GREETING                      = 29,
    HELP_ITEM_OVERRIDE                      = 30,
    HELP_GLOBAL_KEYWORDS                    = 31,
    HELP_GLOBAL_EXCLUSIONS                  = 32,
    SCAN_ALL_RECIPES                        = 34,
    SCANNING_ENABLED                        = 35,
    SCANNING_DISABLED                       = 36,
    PRIMARY_KEYWORDS                        = 37,
    HELP_PRIMARY_KEYWORDS                   = 38,
    HELP_CATEGORY_SECTION                   = 39,
    HELP_EXPANSION_SECTION                  = 40,
    HELP_PROFESSION_SECTION                 = 41,
    RECIPE_NOT_LEARNED                      = 42,
    PING_SOUND_LABEL                        = 43,
    PING_SOUND_TOOLTIP                      = 44,
    BANNER_SIDE_LABEL                       = 45,
    BANNER_SIDE_TOOLTIP                     = 46,
    CUSTOMER_TIMEOUT_LABEL                  = 47,
    CUSTOMER_TIMEOUT_TOOLTIP                = 48,
    BANNER_TIMEOUT_LABEL                    = 49,
    BANNER_TIMEOUT_TOOLTIP                  = 50,
    EXCLUSION_INSTRUCTIONS                  = 51,
    KEYWORD_INSTRUCTIONS                    = 52,
    GREETING_INSTRUCTIONS                   = 53,
    GLOBAL_INCLUSION_DEFAULT                = 54,
    GLOBAL_EXCLUSION_DEFAULT                = 55,
    DEFAULT_KEYWORDS_BLACKSMITHING          = 56,
    DEFAULT_KEYWORDS_LEATHERWORKING         = 57,
    DEFAULT_KEYWORDS_ALCHEMY                = 58,
    DEFAULT_KEYWORDS_TAILORING              = 59,
    DEFAULT_KEYWORDS_ENGINEERING            = 60,
    DEFAULT_KEYWORDS_ENCHANTING             = 61,
    DEFAULT_KEYWORDS_JEWELCRAFTING          = 62,
    DEFAULT_KEYWORDS_INSCRIPTION            = 63,
    ADDON_WHITELIST_LABEL                   = 64,
    ADDON_WHITELIST_TOOLTIP                 = 65,
    SCANNER_CONFIG_DISABLED                 = 66,
    DELETE_CONFIG_TOOLTIP_TEXT              = 67,
    DELETE_CONFIG_CONFIRM                   = 68,
    CLEANUP_CONFIG_TOOLTIP_TEXT             = 69,
    CLEANUP_CONFIG_CONFIRM                  = 70,
    PRIMARY_CRAFTER_TOOLTIP                 = 71,
    CHAT_BUTTON_BINDING_NAME                = 72,
    MULTI_SELECT_BUTTON_TEXT                = 73,
    ACCOUNT_LINK_DESC                       = 74,
    ACCOUNT_LINK_PROMPT_CHARACTER           = 75,
    ACCOUNT_LINK_PROMPT_NICKNAME            = 76,
    ACCOUNT_LINK_ACCEPT_DST_INFO            = 79,
    LINKED_ACCOUNT_REJECTED                 = 80,
    VERSION_MISMATCH                        = 81,
    REMOTE_CRAFTER_TOOLTIP                  = 83,
    REMOTE_CRAFTER_SUMMARY                  = 84,
    LINK_ACTIVE                             = 85,
    ACCOUNT_LINK_DELETE_INFO                = 87,
    ACCOUNT_LINK_ADD_CHAR                   = 88,
    CUSTOM_GREETING_INFO                    = 89,
    WRONG_NUMBER_OF_PLACEHOLDERS            = 90,
    WRONG_TYPE_OF_PLACEHOLDERS              = 91,
    WRONG_NUMBER_OF_PLACEHOLDERS_SUGGESTION = 92,
    ANALYTICS_ITEM_TOOLTIP                  = 93,
    ANALYTICS_PROFESSION_TOOLTIP            = 94,
    ANALYTICS_TOTAL_TOOLTIP                 = 95,
    ANALYTICS_REPEAT_TOOLTIP                = 96,
    ANALYTICS_AVERAGE_TOOLTIP               = 97,
    ANALYTICS_PEAK_TOOLTIP                  = 98,
    ANALYTICS_MEDIAN_TOOLTIP                = 99,
    ANALYTICS_MEDIAN_TOOLTIP_FILTERED       = 100,
    LINKED_ACCOUNT_USER_REJECTED            = 101,
    LINKED_ACCOUNT_PERMISSION_FULL          = 102,
    LINKED_ACCOUNT_PERMISSION_ANALYTICS     = 103,
    ACCOUNT_LINK_PERMISSIONS_DESC           = 104,
    ACCOUNT_LINK_FULL_CONTROL_DESC          = 105,
    ACCOUNT_LINK_ANALYTICS_DESC             = 106,
    ANALYTICS_PROF_MISMATCH                 = 107,
    BUSY_RIGHT_NOW                          = 108,
    GREETING_BUSY                           = 110,
    BUSY_HELP                               = 109,




    -- Release notes have multiple lines that are sequential. Spaced out by hundreds to give more than enough room.
    RN_WELCOME = 10000,
    RN_INITIAL_SETUP = 10100,
    RN_INITIAL_TESTING = 10200,
    RN_MANAGING_CRAFTERS = 10300,
    RN_MANAGING_CUSTOMERS = 10400,
    RN_KEYBINDS = 10500,
    RN_CLEANUP = 10600,
    RN_LINKED_ACCOUNTS = 10700,
    RN_ANALYTICS = 10800,
    RN_ALERT_ICON_ANCHOR = 10900,
}

CraftScan.CONST.LOCALES = {
    EN = "enUS",
    DE = "deDE",
    IT = "itIT",
    RU = "ruRU",
    PT = "ptBR",
    ES = "esES",
    FR = "frFR",
    MX = "esMX",
    KO = "koKR",
    TW = "zhTW",
    CN = "zhCN",
}

-- Stolen from WeakAuras. Presumably also only works if the user has WeakAuras installed to provide the sounds.
local WeakAurasSoundPath = "Interface\\Addons\\WeakAuras\\Media\\Sounds\\";
local PowerAurasSoundPath = "Interface\\Addons\\WeakAuras\\PowerAurasMedia\\Sounds\\";
CraftScan.CONST.SOUNDS = {
    { name = "Robot Blip",             path = WeakAurasSoundPath .. "RobotBlip.ogg" },
    { name = "Batman Punch",           path = WeakAurasSoundPath .. "BatmanPunch.ogg" },
    { name = "Bike Horn",              path = WeakAurasSoundPath .. "BikeHorn.ogg" },
    { name = "Boxing Arena Gong",      path = WeakAurasSoundPath .. "BoxingArenaSound.ogg" },
    { name = "Bleat",                  path = WeakAurasSoundPath .. "Bleat.ogg" },
    { name = "Cartoon Hop",            path = WeakAurasSoundPath .. "CartoonHop.ogg" },
    { name = "Cat Meow",               path = WeakAurasSoundPath .. "CatMeow2.ogg" },
    { name = "Kitten Meow",            path = WeakAurasSoundPath .. "KittenMeow.ogg" },
    { name = "Sharp Punch",            path = WeakAurasSoundPath .. "SharpPunch.ogg" },
    { name = "Water Drop",             path = WeakAurasSoundPath .. "WaterDrop.ogg" },
    { name = "Air Horn",               path = WeakAurasSoundPath .. "AirHorn.ogg" },
    { name = "Applause",               path = WeakAurasSoundPath .. "Applause.ogg" },
    { name = "Banana Peel Slip",       path = WeakAurasSoundPath .. "BananaPeelSlip.ogg" },
    { name = "Blast",                  path = WeakAurasSoundPath .. "Blast.ogg" },
    { name = "Cartoon Voice Baritone", path = WeakAurasSoundPath .. "CartoonVoiceBaritone.ogg" },
    { name = "Cartoon Walking",        path = WeakAurasSoundPath .. "CartoonWalking.ogg" },
    { name = "Cow Mooing",             path = WeakAurasSoundPath .. "CowMooing.ogg" },
    { name = "Ringing Phone",          path = WeakAurasSoundPath .. "RingingPhone.ogg" },
    { name = "Roaring Lion",           path = WeakAurasSoundPath .. "RoaringLion.ogg" },
    { name = "Shotgun",                path = WeakAurasSoundPath .. "Shotgun.ogg" },
    { name = "Squish Fart",            path = WeakAurasSoundPath .. "SquishFart.ogg" },
    { name = "Temple Bell",            path = WeakAurasSoundPath .. "TempleBellHuge.ogg" },
    { name = "Torch",                  path = WeakAurasSoundPath .. "Torch.ogg" },
    { name = "Warning Siren",          path = WeakAurasSoundPath .. "WarningSiren.ogg" },
    { name = "Lich King Apocalypse",   path = 554003 }, -- Sound\Creature\LichKing\IC_Lich King_Special01.ogg
    { name = "Sheep Blerping",         path = WeakAurasSoundPath .. "SheepBleat.ogg" },
    { name = "Rooster Chicken Call",   path = WeakAurasSoundPath .. "RoosterChickenCalls.ogg" },
    { name = "Goat Bleeting",          path = WeakAurasSoundPath .. "GoatBleating.ogg" },
    { name = "Acoustic Guitar",        path = WeakAurasSoundPath .. "AcousticGuitar.ogg" },
    { name = "Synth Chord",            path = WeakAurasSoundPath .. "SynthChord.ogg" },
    { name = "Chicken Alarm",          path = WeakAurasSoundPath .. "ChickenAlarm.ogg" },
    { name = "Xylophone",              path = WeakAurasSoundPath .. "Xylophone.ogg" },
    { name = "Drums",                  path = WeakAurasSoundPath .. "Drums.ogg" },
    { name = "Tada Fanfare",           path = WeakAurasSoundPath .. "TadaFanfare.ogg" },
    { name = "Squeaky Toy Short",      path = WeakAurasSoundPath .. "SqueakyToyShort.ogg" },
    { name = "Error Beep",             path = WeakAurasSoundPath .. "ErrorBeep.ogg" },
    { name = "Oh No",                  path = WeakAurasSoundPath .. "OhNo.ogg" },
    { name = "Double Whoosh",          path = WeakAurasSoundPath .. "DoubleWhoosh.ogg" },
    { name = "Brass",                  path = WeakAurasSoundPath .. "Brass.mp3" },
    { name = "Glass",                  path = WeakAurasSoundPath .. "Glass.mp3" },
    { name = "Voice: Adds",            path = WeakAurasSoundPath .. "Adds.ogg" },
    { name = "Voice: Boss",            path = WeakAurasSoundPath .. "Boss.ogg" },
    { name = "Voice: Circle",          path = WeakAurasSoundPath .. "Circle.ogg" },
    { name = "Voice: Cross",           path = WeakAurasSoundPath .. "Cross.ogg" },
    { name = "Voice: Diamond",         path = WeakAurasSoundPath .. "Diamond.ogg" },
    { name = "Voice: Don't Release",   path = WeakAurasSoundPath .. "DontRelease.ogg" },
    { name = "Voice: Empowered",       path = WeakAurasSoundPath .. "Empowered.ogg" },
    { name = "Voice: Focus",           path = WeakAurasSoundPath .. "Focus.ogg" },
    { name = "Voice: Idiot",           path = WeakAurasSoundPath .. "Idiot.ogg" },
    { name = "Voice: Left",            path = WeakAurasSoundPath .. "Left.ogg" },
    { name = "Voice: Moon",            path = WeakAurasSoundPath .. "Moon.ogg" },
    { name = "Voice: Next",            path = WeakAurasSoundPath .. "Next.ogg" },
    { name = "Voice: Portal",          path = WeakAurasSoundPath .. "Portal.ogg" },
    { name = "Voice: Protected",       path = WeakAurasSoundPath .. "Protected.ogg" },
    { name = "Voice: Release",         path = WeakAurasSoundPath .. "Release.ogg" },
    { name = "Voice: Right",           path = WeakAurasSoundPath .. "Right.ogg" },
    { name = "Voice: Run Away",        path = WeakAurasSoundPath .. "RunAway.ogg" },
    { name = "Voice: Skull",           path = WeakAurasSoundPath .. "Skull.ogg" },
    { name = "Voice: Spread",          path = WeakAurasSoundPath .. "Spread.ogg" },
    { name = "Voice: Square",          path = WeakAurasSoundPath .. "Square.ogg" },
    { name = "Voice: Stack",           path = WeakAurasSoundPath .. "Stack.ogg" },
    { name = "Voice: Star",            path = WeakAurasSoundPath .. "Star.ogg" },
    { name = "Voice: Switch",          path = WeakAurasSoundPath .. "Switch.ogg" },
    { name = "Voice: Taunt",           path = WeakAurasSoundPath .. "Taunt.ogg" },
    { name = "Voice: Triangle",        path = WeakAurasSoundPath .. "Triangle.ogg" },
    { name = "Aggro",                  path = PowerAurasSoundPath .. "aggro.ogg" },
    { name = "Arrow Swoosh",           path = PowerAurasSoundPath .. "Arrow_swoosh.ogg" },
    { name = "Bam",                    path = PowerAurasSoundPath .. "bam.ogg" },
    { name = "Polar Bear",             path = PowerAurasSoundPath .. "bear_polar.ogg" },
    { name = "Big Kiss",               path = PowerAurasSoundPath .. "bigkiss.ogg" },
    { name = "Bite",                   path = PowerAurasSoundPath .. "BITE.ogg" },
    { name = "Burp",                   path = PowerAurasSoundPath .. "burp4.ogg" },
    { name = "Cat",                    path = PowerAurasSoundPath .. "cat2.ogg" },
    { name = "Chant Major 2nd",        path = PowerAurasSoundPath .. "chant2.ogg" },
    { name = "Chant Minor 3rd",        path = PowerAurasSoundPath .. "chant4.ogg" },
    { name = "Chimes",                 path = PowerAurasSoundPath .. "chimes.ogg" },
    { name = "Cookie Monster",         path = PowerAurasSoundPath .. "cookie.ogg" },
    { name = "Electrical Spark",       path = PowerAurasSoundPath .. "ESPARK1.ogg" },
    { name = "Fireball",               path = PowerAurasSoundPath .. "Fireball.ogg" },
    { name = "Gasp",                   path = PowerAurasSoundPath .. "Gasp.ogg" },
    { name = "Heartbeat",              path = PowerAurasSoundPath .. "heartbeat.ogg" },
    { name = "Hiccup",                 path = PowerAurasSoundPath .. "hic3.ogg" },
    { name = "Huh?",                   path = PowerAurasSoundPath .. "huh_1.ogg" },
    { name = "Hurricane",              path = PowerAurasSoundPath .. "hurricane.ogg" },
    { name = "Hyena",                  path = PowerAurasSoundPath .. "hyena.ogg" },
    { name = "Kaching",                path = PowerAurasSoundPath .. "kaching.ogg" },
    { name = "Moan",                   path = PowerAurasSoundPath .. "moan.ogg" },
    { name = "Panther",                path = PowerAurasSoundPath .. "panther1.ogg" },
    { name = "Phone",                  path = PowerAurasSoundPath .. "phone.ogg" },
    { name = "Punch",                  path = PowerAurasSoundPath .. "PUNCH.ogg" },
    { name = "Rain",                   path = PowerAurasSoundPath .. "rainroof.ogg" },
    { name = "Rocket",                 path = PowerAurasSoundPath .. "rocket.ogg" },
    { name = "Ship's Whistle",         path = PowerAurasSoundPath .. "shipswhistle.ogg" },
    { name = "Gunshot",                path = PowerAurasSoundPath .. "shot.ogg" },
    { name = "Snake Attack",           path = PowerAurasSoundPath .. "snakeatt.ogg" },
    { name = "Sneeze",                 path = PowerAurasSoundPath .. "sneeze.ogg" },
    { name = "Sonar",                  path = PowerAurasSoundPath .. "sonar.ogg" },
    { name = "Splash",                 path = PowerAurasSoundPath .. "splash.ogg" },
    { name = "Squeaky Toy",            path = PowerAurasSoundPath .. "Squeakypig.ogg" },
    { name = "Sword Ring",             path = PowerAurasSoundPath .. "swordecho.ogg" },
    { name = "Throwing Knife",         path = PowerAurasSoundPath .. "throwknife.ogg" },
    { name = "Thunder",                path = PowerAurasSoundPath .. "thunder.ogg" },
    { name = "Wicked Male Laugh",      path = PowerAurasSoundPath .. "wickedmalelaugh1.ogg" },
    { name = "Wilhelm Scream",         path = PowerAurasSoundPath .. "wilhelm.ogg" },
    { name = "Wicked Female Laugh",    path = PowerAurasSoundPath .. "wlaugh.ogg" },
    { name = "Wolf Howl",              path = PowerAurasSoundPath .. "wolf5.ogg" },
    { name = "Yeehaw",                 path = PowerAurasSoundPath .. "yeehaw.ogg" },
};

CraftScan.CONST.DEFAULT_SETTINGS = {
    ping_sound = CraftScan.CONST.SOUNDS[1].path,
    banner_direction = CraftScan.CONST.RIGHT,
    customer_timeout = 10,
    banner_timeout = 20,
    last_loaded_version = 0,
    auto_reply_delay = 500,
    disabled_addon_whitelist = "None",
    show_button_height = 0,
    alert_icon_scale = 100,
};

CraftScan.CONST.PROFESSION_COLORS = {
    [164] = 'cffc98e64', -- BS
    [165] = 'cffffaa00', -- LW
    [171] = 'cff8900ff', -- Alc
    [197] = 'cffffff00', -- Tailoring
    [202] = 'cff30aaff', -- Eng
    [333] = 'cff3000ff', -- Enchanting
    [755] = 'cffff0066', -- JC
    [773] = 'cffffff99', -- Inscription
}

-- I can't find an API that provides profession icons unless the current
-- character knows the profession. Hate maintaining things, but  easy enough and
-- we use the parent professions as a backup.
CraftScan.CONST.PARENT_PROFESSION_ICONS = {
    [164] = 136241, -- Blacksmithing
    [165] = 136247, -- Leatherworking
    [171] = 136240, -- Alchemy
    [197] = 136249, -- Tailoring
    [202] = 136244, -- Engineering
    [333] = 136243, -- Enchanting
    [755] = 134071, -- Jewelcrafting
    [773] = 237171, -- Inscription
}

CraftScan.CONST.TWW_PROFESSION_ICONS = {
    [3017] = 136240, -- Alchemy
    [3021] = 136241, -- Blacksmithing
    [3034] = 136244, -- Enchanting
    [3037] = 136245, -- Engineering
    [3040] = 237171, -- Inscription
    [3043] = 134071, -- Jewelcrafting
    [3046] = 136247, -- Leatherworking
    [3049] = 136249, -- Tailoring
};

CraftScan.CONST.PROFESSION_DEFAULT_KEYWORDS = {
    [164] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_BLACKSMITHING,
    [165] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_LEATHERWORKING,
    [171] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_ALCHEMY,
    [197] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_TAILORING,
    [202] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_ENGINEERING,
    [333] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_ENCHANTING,
    [755] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_JEWELCRAFTING,
    [773] = CraftScan.CONST.TEXT.DEFAULT_KEYWORDS_INSCRIPTION,
}

CraftScan.CONST.DEFAULT_PPCONFIG = {
    scanning_enabled = true,
    visual_alert_enabled = true,
    sound_alert_enabled = false,
};
