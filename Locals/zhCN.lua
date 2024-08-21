local CraftScan = select(2, ...)

CraftScan.LOCAL_CN = {}

function CraftScan.LOCAL_CN:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                         = "CraftScan",
        [LID.CRAFT_SCAN]                      = "CraftScan",
        [LID.CHAT_ORDERS]                     = "聊天订单",
        [LID.DISABLE_ADDONS]                  = "禁用插件",
        [LID.RENABLE_ADDONS]                  = "重新启用插件",
        [LID.DISABLE_ADDONS_TOOLTIP]          =
        "保存插件列表，然后禁用它们，以便快速切换到另一个角色。此按钮可再次点击以随时重新启用插件。",
        [LID.GREETING_I_CAN_CRAFT_ITEM]       = "我可以制作 %s.", -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]     = "我的小号，%s可以制作 %s.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]            = "那个",
        [LID.GREETING_I_HAVE_PROF]            = "我有 %s.", -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]           = "我的小号，%s，有 %s.", -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]             = "如果您发送订单，请告诉我，我可以切换过去。",
        [LID.MAIN_BUTTON_BINDING_NAME]        = "切换订单页面",
        [LID.GREET_BUTTON_BINDING_NAME]       = "打招呼横幅顾客",
        [LID.DISMISS_BUTTON_BINDING_NAME]     = "解雇横幅顾客",
        [LID.TOGGLE_CHAT_TOOLTIP]             = "切换聊天订单%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]             = "显示CraftScan",
        [LID.SCANNER_CONFIG_HIDE]             = "隐藏CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]              = "CraftScan 选项",
        [LID.ITEM_SCAN_CHECK]                 = "扫描聊天记录以查找此物品",
        [LID.HELP_PROFESSION_KEYWORDS]        =
        "消息必须包含其中一个词语。要匹配 'LF 缰绳' 这样的消息，'lariet' 应该在这里列出。为了在响应中生成元素缰绳的物品链接，'lariat' 也应该包含在元素缰绳的物品配置关键字中。",
        [LID.HELP_PROFESSION_EXCLUSIONS]      =
        "如果消息包含其中一个词语，即使它在其他方面是匹配的，也将被忽略。为了避免在您没有缰绳配方时响应 'LF JC Lariat' 为 '我有珠宝加工'，'lariat' 应该在这里列出。",
        [LID.HELP_SCAN_ALL]                   = "启用对同一扩展中所选配方的所有配方的扫描。",
        [LID.HELP_PRIMARY_EXPANSION]          =
        "在回应通用请求（例如 'LF Blacksmith'）时使用此问候语。当新的扩展推出时，您可能希望使用描述您可以制作的物品，而不是说明您拥有先前扩展的最大知识的问候语。",
        [LID.HELP_EXPANSION_GREETING]         =
        "始终生成一个初始介绍，说明您可以制作该物品。此文本将附加在其后。允许新的行，并将作为单独的响应发送。如果文本太长，将分为多个响应。",
        [LID.HELP_CATEGORY_KEYWORDS]          =
        "如果匹配了一个专业，检查这些类别特定的关键词以细化问候。例如，您可以在这里放置 '有毒' 或 '粘滑'，以尝试检测需要腐朽法阵的制革图案。",
        [LID.HELP_CATEGORY_GREETING]          =
        "当检测到此类别的消息时，无论是通过关键字还是项目链接，此附加问候将在职业问候之后附加。",
        [LID.HELP_CATEGORY_OVERRIDE]          = "省略职业问候，从类别问候开始。",
        [LID.HELP_ITEM_KEYWORDS]              =
        "如果匹配了一个专业，检查这些项目特定的关键字以细化问候。当匹配时，响应将包含项目链接，而不是通用的职业问候。",
        [LID.HELP_ITEM_GREETING]              =
        "当检测到此类别的消息时，无论是通过关键字还是项目链接，此附加问候将在职业和类别问候之后附加。",
        [LID.HELP_ITEM_OVERRIDE]              = "省略职业和类别问候，从项目问候开始。",
        [LID.HELP_GLOBAL_KEYWORDS]            = "消息必须包含其中一个词语。",
        [LID.HELP_GLOBAL_EXCLUSIONS]          = "如果消息包含其中一个词语，消息将被忽略。",
        [LID.SCAN_ALL_RECIPES]                = '扫描所有配方',
        [LID.SCANNING_ENABLED]                = "由于已选中'%s'，因此启用了扫描。", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]               = "扫描已禁用。",
        [LID.PRIMARY_KEYWORDS]                = "主要关键词",
        [LID.HELP_PRIMARY_KEYWORDS]           =
        "所有消息都由这些词语筛选，这些词语是所有专业共同的。匹配的消息将进一步处理，以查找与专业相关的内容。",
        [LID.HELP_CATEGORY_SECTION]           =
        "该类别是左侧列表中包含配方的可折叠部分。'Favorites' 不是一个类别。这主要用于像更难制作的有毒制革配方这样的东西。当您只能专注于单个类别时，这也可能很有用。",
        [LID.HELP_EXPANSION_SECTION]          = "由于知识树因扩展而异，因此问候语也可能不同。",
        [LID.HELP_PROFESSION_SECTION]         =
        "从客户的角度来看，扩展之间没有区别。这些术语与“主要扩展”选择相结合，以在无法匹配更具体的内容时提供通用的问候语（例如 '我有 <专业>.'）。",
        [LID.RECIPE_NOT_LEARNED]              = "您尚未学习此配方。扫描已禁用。",
        [LID.PING_SOUND_LABEL]                = "警报音",
        [LID.PING_SOUND_TOOLTIP]              = "检测到顾客后播放的声音。",
        [LID.BANNER_SIDE_LABEL]               = "横幅方向",
        [LID.BANNER_SIDE_TOOLTIP]             = "横幅将从此按钮向外扩展。",
        Left                                  = "左",
        Right                                 = "右",
        Minute                                = "分钟",
        Minutes                               = "分钟",
        Second                                = "秒",
        Seconds                               = "秒",
        Millisecond                           = "毫秒",
        Milliseconds                          = "毫秒",
        Version                               = "新版本",
        ["CraftScan Release Notes"]           = "CraftScan 发布说明",
        [LID.CUSTOMER_TIMEOUT_LABEL]          = "顾客超时",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]        = "在此多少分钟后自动解雇顾客。",
        [LID.BANNER_TIMEOUT_LABEL]            = "横幅超时",
        [LID.BANNER_TIMEOUT_TOOLTIP]          =
        "顾客通知横幅将在匹配检测到后保持显示此时间段。",
        ["All crafters"]                      = "所有制作者",
        ["Crafter Name"]                      = "制作者名称",
        ["Profession"]                        = "专业",
        ["Customer Name"]                     = "顾客名称",
        ["Replies"]                           = "回复",
        ["Keywords"]                          = "关键词",
        ["Profession greeting"]               = "专业问候",
        ["Category greeting"]                 = "类别问候",
        ["Item greeting"]                     = "物品问候",
        ["Primary expansion"]                 = "主要扩展",
        ["Override greeting"]                 = "覆盖问候",
        ["Excluded keywords"]                 = "排除的关键词",
        [LID.EXCLUSION_INSTRUCTIONS]          = "不要匹配包含这些逗号分隔的令牌的消息。",
        [LID.KEYWORD_INSTRUCTIONS]            = "匹配包含其中一个逗号分隔关键词的消息。",
        [LID.GREETING_INSTRUCTIONS]           = "发送给寻求制作的顾客的问候语。",
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
        -- Release notes
        [LID.RN_WELCOME]                      = "欢迎使用CraftScan！",
        [LID.RN_WELCOME + 1]                  =
        "此插件会扫描聊天消息中看起来像制作请求的内容。如果配置指示您可以制作所请求的物品，则会触发通知，并存储顾客信息以便于沟通。",

        [LID.RN_INITIAL_SETUP]                = "初始设置",
        [LID.RN_INITIAL_SETUP + 1]            =
        "要开始，请打开专业并单击底部的新的“显示CraftScan”按钮。",
        [LID.RN_INITIAL_SETUP + 2]            =
        "向下滚动到此新窗口的底部，然后从底部开始操作。您需要很少更改的内容位于底部，但这些是首先关心的设置。",
        [LID.RN_INITIAL_SETUP + 3]            =
        "如果您需要解释任何输入，请单击窗口左上角的帮助图标。",

        [LID.RN_INITIAL_TESTING]              = "初始测试",
        [LID.RN_INITIAL_TESTING + 1]          =
        "配置完成后，在/say聊天频道中键入消息，例如 'LF BS' 表示铁匠，假设您留下了 'LF' 和 'BS' 关键词。将会弹出通知。",
        [LID.RN_INITIAL_TESTING + 2]          =
        "单击通知以立即发送响应，右键单击以解雇顾客，或单击悬浮窗口本身的圆形专业按钮以打开订单窗口。",
        [LID.RN_INITIAL_TESTING + 3]          =
        "重复的通知会被抑制，除非它们已经被解雇，因此右键单击测试通知以解雇它，如果您想再试一次。",

        [LID.RN_MANAGING_CRAFTERS]            = "管理您的制作者",
        [LID.RN_MANAGING_CRAFTERS + 1]        =
        "订单窗口的左侧列出了您的制作者。当您登录各种角色并配置其专业时，此列表将被填充。您可以随时选择哪些角色应处于活动扫描状态，并且您每个制作者的视觉和听觉通知是否启用。",

        [LID.RN_MANAGING_CUSTOMERS]           = "管理顾客",
        [LID.RN_MANAGING_CUSTOMERS + 1]       =
        "订单窗口的右侧将填充在聊天中检测到的制作订单。单击行以发送问候（如果您尚未从弹出横幅中发送），左键再次以打开与顾客的悄悄话。右键单击以解雇行。",
        [LID.RN_MANAGING_CUSTOMERS + 2]       =
        "此表中的行将在所有角色之间保持持续，因此您可以切换到一个小号，然后再次单击顾客以恢复通信。默认情况下，此持续时间为10分钟。此持续时间可以在主设置页面中配置（Esc->选项->插件->CraftScan）。",
        [LID.RN_MANAGING_CUSTOMERS + 3]       =
        "希望大部分表都是不言自明的。'回复' 列有3个图标。左侧的 X 或√ 是您是否向客户发送了消息。右侧的 X 或√ 是客户是否已回复。聊天气泡是一个按钮，将打开一个临时的悄悄话窗口与客户，并将其填充为您的聊天历史记录。",

        [LID.RN_KEYBINDS]                     = "键位绑定",
        [LID.RN_KEYBINDS + 1]                 =
        "可以使用键位绑定来打开订单页面，回复最新顾客以及解雇最新顾客。搜索 'CraftScan' 以查找所有可用设置。",

        [LID.RN_CLEANUP]                      = "配置清理",
        [LID.RN_CLEANUP + 1]                  = "在'聊天订单'页面的左侧，现在可以右键单击您的工匠，会出现一个上下文菜单。使用此菜单保持列表整洁，并删除过时的角色/职业。",
        ["Disable"]                           = "禁用",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]      =
        "永久删除任何保存的 %s 的 %s 数据。\n\n在职业页面上将有一个'启用 CraftScan'按钮，可以通过默认设置再次启用它。\n\n如果您想继续使用该职业但不想使用 CraftScan 互动（例如，当您在所有小号上都拥有炼金术用于长效药剂时），请使用此功能。", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]           = "输入 'DELETE' 以继续:",
        [LID.SCANNER_CONFIG_DISABLED]         = "启用 CraftScan",

        ["Cleanup"]                           = "清理",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]     =
        "永久删除任何保存的 %s 的 %s 数据。\n\n该职业将处于未配置的状态。再次打开职业会恢复默认配置。\n\n如果您想完全重置一个职业，已删除角色，或已放弃一个职业，请使用此功能。", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]          = "输入 'CLEANUP' 以继续:",
        ["Primary Crafter"]                   = "主工匠",
        [LID.PRIMARY_CRAFTER_TOOLTIP]         = "将 %s 标记为 %s 的主工匠。如果有多个匹配的请求，该工匠将优先于其他工匠。",
        ["Chat History"]                      = "与 %s 的聊天记录", -- customer, left-click-help
        ["Greet Help"]                        = "|cffffd100左键点击: 问候客户%s|r",
        ["Chat Help"]                         = "|cffffd100左键点击: 打开密语|r",
        ["Chat Override"]                     = "|cffffd100中键点击: 打开密语%s|r",
        ["Dismiss"]                           = "|cffffd100右键点击: 关闭%s|r",
        ["Proposed Greeting"]                 = "建议的问候:",
        [LID.CHAT_BUTTON_BINDING_NAME]        = "密语横幅客户",
        ["Customer Request"]                  = "%s的请求",
        [LID.ADDON_WHITELIST_LABEL]           = "插件白名单",
        [LID.ADDON_WHITELIST_TOOLTIP]         = "当你按下按钮暂时禁用所有插件时，保持这里选择的插件启用状态。CraftScan将始终保持启用。只保留你有效制作所需的内容。",
        [LID.MULTI_SELECT_BUTTON_TEXT]        = "已选择%d项", -- Count

        [LID.ACCOUNT_LINK_DESC]               = "在多个帐户之间共享制造者。\n\n在登录时或配置更改后，CraftScan会在配置的制造者之间传播最新信息，以确保链接的帐户的双方始终保持同步。",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]   = "输入你其他帐户中在线角色的名字：",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]    = "为另一个帐户输入一个昵称：",
        ["Link Account"]                      = "链接帐户",
        ["Linked Accounts"]                   = "已链接帐户",
        ["Accept Linked Account"]             = "接受已链接帐户",
        ["Delete Linked Account"]             = "删除已链接帐户",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]    = "'%s'发出了链接帐户的请求。\n\n如果您没有发送此请求，请勿接受。\n\n为另一个帐户输入一个昵称：",
        [LID.ACCOUNT_LINK_ACCEPT_DST_LABEL]   = "|cFF00FF00你有一个挂起的请求与%s链接帐户。点击此处接受。|r",
        ["OK"]                                = "确定",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_INFO]    = "要完成帐户链接，你需要在另一个帐户上接受请求。'链接帐户'按钮将被'接受已链接帐户'按钮替换以完成操作。如果有错误，它将显示在'链接帐户'按钮旁边。",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_LABEL]   = "|cFFFFA500正在等待%s接受帐户链接请求。|r",
        [LID.VERSION_MISMATCH]                = "|cFFFF0000错误：CraftScan版本不兼容。另一个帐户的版本：%s。您的版本：%s。|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]          =
        "此角色属于已链接的帐户。它只能在其所属的帐户上被禁用。你可以通过“清理”完全移除此角色，但你需要在所有已链接的帐户上手动执行此操作，否则它将在登录时被已链接的帐户恢复。",
        [LID.REMOTE_CRAFTER_SUMMARY]          = "与%s同步。",
        ["proxy_send_enabled"]                = "代理订单",
        ["proxy_send_enabled_tooltip"]        = "当检测到客户订单时，将其发送到已链接的帐户。",
        ["proxy_receive_enabled"]             = "接收代理订单",
        ["proxy_receive_enabled_tooltip"]     = "当另一个帐户检测到并发送客户订单时，此帐户将接收它。如果需要，CraftScan按钮将显示警告横幅。",
        [LID.LINK_ACTIVE]                     = "|cFF00FF00%s（上次看到%s）|r", -- Crafter, Time
        [LID.LINK_DEAD]                       = "|cFFFF0000离线|r",
        [LID.ACCOUNT_LINK_DELETE_INFO]        =
        "删除与'%s'的链接并删除所有导入的角色。此帐户将停止与另一方的所有通信。另一方将继续尝试建立连接，直到在该处手动删除链接为止。\n\n将被删除的导入制造者：\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]           =
        "默认情况下，你最初链接的角色、任何制造者以及此帐户在线时登录的任何角色都为CraftScan所知。添加属于另一个帐户的其他角色，以便他们也可以使用。如果他们在线，请使用'/reload'强制与新角色同步。",
        ["Backup characters"]                 = "其他角色",
        ["Unlink account"]                    = "取消链接帐户",
        ["Add"]                               = "添加",
        ["Remove"]                            = "移除",
        ["Rename account"]                    = "重命名帐户",
        ["New name"]                          = "新名字：",

        [LID.RN_LINKED_ACCOUNTS]              = "已链接帐户",
        [LID.RN_LINKED_ACCOUNTS + 1]          = "将多个WoW帐户链接在一起以共享制造信息并从任何帐户扫描到任何帐户。",
        [LID.RN_LINKED_ACCOUNTS + 2]          = "可选地，发送客户订单代理从一个帐户到其他帐户，这样你可以让测试帐户在城市中保持不变，而你的主账户在外面。",
        [LID.RN_LINKED_ACCOUNTS + 3]          = "要开始，请点击CraftScan窗口左下角的“链接帐户”按钮，并按照说明操作。",
        [LID.RN_LINKED_ACCOUNTS + 4]          = "演示：https://www.youtube.com/watch?v=x1JLEph6t_c",
    }
end
