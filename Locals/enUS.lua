local CraftScan = select(2, ...)

CraftScan.LOCAL_EN = {}

function CraftScan.LOCAL_EN:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        -- I eventually got tired of the whole LID enum tedium copy/pasted from
        -- CraftSim, so newer short ones are just the raw English string as the
        -- key, which is easier to read in the code anyway.
        ["CraftScan"]                         = "CraftScan",
        [LID.CRAFT_SCAN]                      = "CraftScan",
        [LID.CHAT_ORDERS]                     = "Chat Orders",
        [LID.DISABLE_ADDONS]                  = "Disable Addons",
        [LID.RENABLE_ADDONS]                  = "Re-enable Addons",
        [LID.DISABLE_ADDONS_TOOLTIP]          =
        "Save your list of addons, and then disable them, allowing for a quick swap to an alt. This button can be clicked again to re-enable the addons at any time.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]       = "I can craft %s.",           -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]     = "My alt, %s, can craft %s.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]            = "that",
        [LID.GREETING_I_HAVE_PROF]            = "I have %s.",                -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]           = "My alt, %s, has %s.",       -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]             = "Let me know if you send an order so I can log over.",
        [LID.MAIN_BUTTON_BINDING_NAME]        = "Toggle Order Page",
        [LID.GREET_BUTTON_BINDING_NAME]       = "Greet Banner Customer",
        [LID.DISMISS_BUTTON_BINDING_NAME]     = "Dismiss Banner Customer",
        [LID.TOGGLE_CHAT_TOOLTIP]             = "Toggle chat orders%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]             = "Show CraftScan",
        [LID.SCANNER_CONFIG_HIDE]             = "Hide CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]              = "CraftScan Options",
        [LID.ITEM_SCAN_CHECK]                 = "Scan chat for this item",
        [LID.HELP_PROFESSION_KEYWORDS]        =
        "A message must contain one of these terms. To match a message such as 'LF Lariat', 'lariet' should be listed here. To generate an item link for the Elemental Lariat in the response, 'lariat' should also be included in the item configuration keywords for the Elemental Lariat.",
        [LID.HELP_PROFESSION_EXCLUSIONS]      =
        "A message will be ignored if it contains one of these terms, even if it would otherwise be a match. To avoid responding to 'LF JC Lariat' with 'I have Jewelcrafting' when you do not have the Lariat recipe, 'lariat' should be listed here.",
        [LID.HELP_SCAN_ALL]                   = "Enable scanning for all recipes in the same expansion as the selected recipe.",
        [LID.HELP_PRIMARY_EXPANSION]          =
        "Use this greeting when responding to a generic request such as 'LF Blacksmith'. When a new expansion launches, you will likely want a greeting describing what items you can craft instead of stating that you have max knowledge from the prior expansion.",
        [LID.HELP_EXPANSION_GREETING]         =
        "An initial intro is always generated stating that you can craft the item. This text is appended to it. New lines are allowed and will be sent as a separate response. If the text is too long, it will be broken into multiple responses.",
        [LID.HELP_CATEGORY_KEYWORDS]          =
        "If a profession has been matched, check for these category specific keywords to refine the greeting. For example, you could put 'toxic' or 'slimy' here to attempt to detect Leatherworking patterns that require the Alter of Decay.",
        [LID.HELP_CATEGORY_GREETING]          =
        "When this category is detected in a message, via either a keyword or an item link, this additional greeting will appended after the profession greeting.",
        [LID.HELP_CATEGORY_OVERRIDE]          = "Omit the profession greeting and start with the category greeting.",
        [LID.HELP_ITEM_KEYWORDS]              =
        "If a profession has been matched, check for these item specific keywords to refine the greeting. When matched, the response will include the item link instead of the generic profession greeting. If 'lariat' is a profession keyword, but not an item keyword, the response will says 'I have Jewelcrafting.' If 'lariat' is only an item keyword, 'LF Lariat' will not match a profession and is not considered a match. If 'lariat' is both a profession and item keyword, the response to 'LF Lariat' will be 'I can craft [Elemental Lariat].'",
        [LID.HELP_ITEM_GREETING]              =
        "When this item is detected in a message, via either a keyword or the item link, this additional greeting will be appended after the profession and category greetings.",
        [LID.HELP_ITEM_OVERRIDE]              = "Omit the profession and category greeting and start with the item greeting.",
        [LID.HELP_GLOBAL_KEYWORDS]            = "A message must include one of these terms.",
        [LID.HELP_GLOBAL_EXCLUSIONS]          = "A message will be ignored if it contains one of these terms.",
        [LID.SCAN_ALL_RECIPES]                = 'Scan all recipes',
        [LID.SCANNING_ENABLED]                = "Scanning is enabled because '%s' is checked.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]               = "Scanning is disabled.",
        [LID.PRIMARY_KEYWORDS]                = "Primary Keywords",
        [LID.HELP_PRIMARY_KEYWORDS]           =
        "All messages are filtered by these terms, which are common across all professions. A matching message is further processed to look for profession related content.",
        [LID.HELP_CATEGORY_SECTION]           =
        "The category is the collapsible section containing the recipe in the list to the left. 'Favorites' is not a category. This is intended mainly for things like the toxic Leatherworking recipes that are more difficult to craft. It might also be useful at the start of expansions when you can only specialize in a single category.",
        [LID.HELP_EXPANSION_SECTION]          = "Knowledge trees differ per expansion, so the greeting can also differ.",
        [LID.HELP_PROFESSION_SECTION]         =
        "From a customer point of view, there is no difference between expansions. These terms combine with the 'Primary expansion' selection to provide a generic greeting (e.g. 'I have <profession>.') when we can not match something more specific.",
        [LID.RECIPE_NOT_LEARNED]              = "You have not learned this recipe. Scanning is disabled.",
        [LID.PING_SOUND_LABEL]                = "Alert sound",
        [LID.PING_SOUND_TOOLTIP]              = "The sound that plays when a customer has been detected.",
        [LID.BANNER_SIDE_LABEL]               = "Banner direction",
        [LID.BANNER_SIDE_TOOLTIP]             = "The banner will grow from the button in this direction.",
        Left                                  = "Left",
        Right                                 = "Right",
        Minute                                = "Minute",
        Minutes                               = "Minutes",
        Second                                = "Second",
        Seconds                               = "Seconds",
        Millisecond                           = "Millisecond",
        Milliseconds                          = "Milliseconds",
        Version                               = "New in",
        ["CraftScan Release Notes"]           = "CraftScan Release Notes",
        [LID.CUSTOMER_TIMEOUT_LABEL]          = "Customer timeout",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]        = "Automatically dismiss customers after this many minutes.",
        [LID.BANNER_TIMEOUT_LABEL]            = "Banner timeout",
        [LID.BANNER_TIMEOUT_TOOLTIP]          =
        "The customer notification banner will remain displayed for this duration after a match is detected.",
        ["All crafters"]                      = "All crafters",
        ["Crafter Name"]                      = "Crafter Name",
        ["Profession"]                        = "Profession",
        ["Customer Name"]                     = "Customer Name",
        ["Replies"]                           = "Replies",
        ["Keywords"]                          = "Keywords",
        ["Profession greeting"]               = "Profession greeting",
        ["Category greeting"]                 = "Category greeting",
        ["Item greeting"]                     = "Item greeting",
        ["Primary expansion"]                 = "Primary expansion",
        ["Override greeting"]                 = "Override greeting",
        ["Excluded keywords"]                 = "Excluded keywords",
        [LID.EXCLUSION_INSTRUCTIONS]          = "Do not match messages containing these comma separated tokens.",
        [LID.KEYWORD_INSTRUCTIONS]            = "Match messages containing one of these comma separated keywords.",
        [LID.GREETING_INSTRUCTIONS]           = "A greeting to send to customers looking for a craft.",
        [LID.GLOBAL_INCLUSION_DEFAULT]        = "LF, LFC, WTB, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]        = "LFW, WTS, LF work",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]  = "BS, Blacksmith, Armorsmith, Weaponsmith",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING] = "LW, Leatherworking, Leatherworker",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]        = "Alc, Alchemist, Stone",
        [LID.DEFAULT_KEYWORDS_TAILORING]      = "Tailor",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]    = "Engineer, Eng",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]     = "Enchanter, Crest",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]  = "JC, Jewelcrafter",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]    = "Inscription, Inscriptionist, Scribe",
        [LID.ADDON_WHITELIST_LABEL]           = "Whitelist addon",
        [LID.ADDON_WHITELIST_TOOLTIP]         =
        "When you hit the button to temporarily disable all addons, keep this one enabled. To remove an addon, set it back to 'None'. CraftScan will always stay enabled. Keep only what you need to craft effectively. XXX: This is a little bugged - a new 'None' should pop up after making a selection. If it doesn't go to a different menu tab then come back and it should be there.",

        -- Release notes
        [LID.RN_WELCOME]                      = "Welcome to CraftScan!",
        [LID.RN_WELCOME + 1]                  =
        "This addon scans chat for messages that look like requests for crafting. If the configuration indicates you can craft the requested item, a notification will be triggered and the customer information stored to facilitate communication.",

        [LID.RN_INITIAL_SETUP]                = "Initial Setup",
        [LID.RN_INITIAL_SETUP + 1]            =
        "To get started, open a profession and click the new 'Show CraftScan' button along the bottom.",
        [LID.RN_INITIAL_SETUP + 2]            =
        "Scroll to the bottom of this new window and work your way up. The things you need to rarely change are at the bottom, but those are the setting to care about first.",
        [LID.RN_INITIAL_SETUP + 3]            =
        "Click the help icon in the top left corner of the window if you need an explanation of any input.",

        [LID.RN_INITIAL_TESTING]              = "Initial Testing",
        [LID.RN_INITIAL_TESTING + 1]          =
        "Once configured, type a message in /say chat, such as 'LF BS' for Blacksmithing, assuming you have left the 'LF' and 'BS' keywords. A notification should pop up.",
        [LID.RN_INITIAL_TESTING + 2]          =
        "Click the notification to immediately send a response, right click it to dismiss the customer, or click on the circular profession button itself to open the orders window.",
        [LID.RN_INITIAL_TESTING + 3]          =
        "Duplicate notifications are suppressed unless they have already been dismissed, so right click your test notification to dismiss it if you want to try again.",

        [LID.RN_MANAGING_CRAFTERS]            = "Managing Your Crafters",
        [LID.RN_MANAGING_CRAFTERS + 1]        =
        "The left hand side of the orders window lists your crafters. This list will be populated as you log in to your various characters and configure their professions. You can select which characters should be actively scanned at any time, as well as whether the visual and auditory notifications are enabled for each of your crafters.",

        [LID.RN_MANAGING_CUSTOMERS]           = "Managing Customers",
        [LID.RN_MANAGING_CUSTOMERS + 1]       =
        "The right hand side of the orders window will populate with crafting orders detected in chat. Left click a row to send the greeting if you did not already do so from the pop-up banner. Left click again to open a whisper to the customer. Right click to dismiss the row.",
        [LID.RN_MANAGING_CUSTOMERS + 2]       =
        "Rows in this table will persist across all characters, so you can log over to an alt and then click the customer again to restore communication. Rows time out after 10 minutes by default. This duration can be configured in the main settings page (Esc -> Options -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]       =
        "Hopefully most the table is self explanatory. The 'Replies' column has 3 icons. The left X or check mark is whether you have sent a message to the customer. The right X or check mark is whether the customer has replied. The chat bubble is a button that will open a temporary whisper window with the customer, and populate it with your chat history.",

        [LID.RN_KEYBINDS]                     = "Keybinds",
        [LID.RN_KEYBINDS + 1]                 =
        "Keybinds are available for opening the orders page, responding to the latest customer, and dismissing the latest customer. Search for 'CraftScan' to find all available settings.",

        [LID.RN_CLEANUP]                      = "Configuration Cleanup",
        [LID.RN_CLEANUP + 1]                  =
        "Your crafters on the left hand side of the 'Chat Orders' page now have a context menu when right clicked. Use this menu to keep the list clean and remove stale characters/professions.",

        ["Disable"]                           = "Disable",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]      =
        "Permanently delete any saved %s data for %s.\n\nAn 'Enable CraftScan' button will be present on the profession page to enable it again with default settings.\n\nUse this if you want to continue using the profession, but with no CraftScan interaction (e.g. when you have Alchemy on every alt for long flasks).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]           = "Type 'DELETE' to proceed:",
        [LID.SCANNER_CONFIG_DISABLED]         = "Enable CraftScan",

        ["Cleanup"]                           = "Cleanup",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]     =
        "Permanently delete any saved %s data for %s.\n\nThe profession will be left in a state as if it was never configured. Simply opening the profession again will restore a default configuration.\n\nUse this if you want to completely reset a profession, have deleted the character, or have dropped a profession.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]          = "Type 'CLEANUP' to proceed:",

        -- Translations complete above this line
        ["Primary Crafter"]                   = "Primary Crafter",
        [LID.PRIMARY_CRAFTER_TOOLTIP]         =
        "Flag %s as your primary crafter for %s. This crafter will be given priority over others if there are multiple matches to the same request.",
        ["Chat History"]                      = "Chat history with %s", -- customer
        ["Greet Help"]                        = "|cffffd100Left click: Greet customer%s|r",
        ["Chat Help"]                         = "|cffffd100Left click: Open whisper|r",
        ["Chat Override"]                     = "|cffffd100Middle click: Open whisper%s|r",
        ["Dismiss"]                           = "|cffffd100Right click: Dismiss%s|r",
        ["Proposed Greeting"]                 = "Proposed greeting:",
        [LID.CHAT_BUTTON_BINDING_NAME]        = "Whisper Banner Customer",
        ["Customer Request"]                  = "Request from %s",

        ["Total Seen"]                        = "Total Seen",
        ["Avg Per Day"]                       = "Avg/Day",
        ["Peak Per Hour"]                     = "Peak/Hour",




    }
end
