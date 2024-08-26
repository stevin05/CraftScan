local CraftScan = select(2, ...)

CraftScan.LOCAL_TW = {}

function CraftScan.LOCAL_TW:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                                 = "製造掃描",
        [LID.CRAFT_SCAN]                              = "製造掃描",
        [LID.CHAT_ORDERS]                             = "聊天指令",
        [LID.DISABLE_ADDONS]                          = "停用插件",
        [LID.RENABLE_ADDONS]                          = "重新啟用插件",
        [LID.DISABLE_ADDONS_TOOLTIP]                  =
        "保存插件清單，然後停用它們，讓您可以快速切換到其他角色。您隨時可以再次點擊此按鈕以重新啟用插件。",
        [LID.GREETING_I_CAN_CRAFT_ITEM]               = "我可以製造%s。", -- 物品連結
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]             = "我的小號%s可以製造%s。", -- 製造者名稱，物品連結
        [LID.GREETING_LINK_BACKUP]                    = "這",
        [LID.GREETING_I_HAVE_PROF]                    = "我會%s。", -- 職業名稱
        [LID.GREETING_ALT_HAS_PROF]                   = "我的小號%s會%s。", -- 製造者名稱，職業名稱
        [LID.GREETING_ALT_SUFFIX]                     = "如果您下訂單，請通知我，我可以轉過去。",
        [LID.MAIN_BUTTON_BINDING_NAME]                = "切換訂單頁面",
        [LID.GREET_BUTTON_BINDING_NAME]               = "問候橫幅客戶",
        [LID.DISMISS_BUTTON_BINDING_NAME]             = "解散橫幅客戶",
        [LID.TOGGLE_CHAT_TOOLTIP]                     = "切換聊天訂單%s", -- 快捷鍵
        [LID.SCANNER_CONFIG_SHOW]                     = "顯示製造掃描",
        [LID.SCANNER_CONFIG_HIDE]                     = "隱藏製造掃描",
        [LID.CRAFT_SCAN_OPTIONS]                      = "製造掃描選項",
        [LID.ITEM_SCAN_CHECK]                         = "掃描聊天以查找此物品",
        [LID.HELP_PROFESSION_KEYWORDS]                =
        "消息必須包含其中一個詞語。例如，要匹配“LF Lariat”，“lariet”應列在此處。要對响應生成Elemental Lariat的物品連結，“lariat”也應包含在Elemental Lariat的物品配置關鍵詞中。",
        [LID.HELP_PROFESSION_EXCLUSIONS]              =
        "如果消息包含其中一個詞語，則將其忽略，即使它本來應該匹配。為了避免在您沒有Lariat配方的情況下對'LF JC Lariat'的回應為'我有珠寶加工'，應將'lariat'列在此處。",
        [LID.HELP_SCAN_ALL]                           = "啟用與所選配方相同擴展中的所有配方的掃描。",
        [LID.HELP_PRIMARY_EXPANSION]                  =
        "當回應一個通用請求時使用此問候，例如'LF Blacksmith'。當新的擴展推出時，您可能希望使用描述您可以製造的物品的問候，而不是聲明您從前一擴展中獲得了最大知識。",
        [LID.HELP_EXPANSION_GREETING]                 =
        "始終生成一個初始介紹，說明您可以製造物品。此文本將附加在其後。允許換行，並將作為單獨的回應發送。如果文本太長，它將分為多個回應發送。",
        [LID.HELP_CATEGORY_KEYWORDS]                  =
        "如果已匹配職業，則檢查這些特定類別的關鍵詞以細化問候。例如，您可以在此處放置'toxic'或'slimy'，以嘗試檢測需要Alter of Decay的皮革工藝配方。",
        [LID.HELP_CATEGORY_GREETING]                  =
        "當檢測到消息中的此類別時，無論是通過關鍵詞還是物品連結，都會在職業問候之後附加此額外的問候。",
        [LID.HELP_CATEGORY_OVERRIDE]                  = "省略職業問候，直接開始類別問候。",
        [LID.HELP_ITEM_KEYWORDS]                      =
        "如果已匹配職業，則檢查這些特定物品的關鍵詞以細化問候。當匹配時，回應將包含物品連結，而不是通用的職業問候。如果'lariat'是職業關鍵詞但不是物品關鍵詞，則回應將說'我有珠寶加工。'如果'lariat'既是職業又是物品關鍵詞，則對'LF Lariat'的回應將是'我可以製造[Elemental Lariat]。'",
        [LID.HELP_ITEM_GREETING]                      =
        "當檢測到消息中的此物品時，無論是通過關鍵詞還是物品連結，都會在職業和類別問候之後附加此額外的問候。",
        [LID.HELP_ITEM_OVERRIDE]                      = "省略職業和類別問候，直接開始物品問候。",
        [LID.HELP_GLOBAL_KEYWORDS]                    = "消息必須包含其中一個詞語。",
        [LID.HELP_GLOBAL_EXCLUSIONS]                  = "如果消息包含其中一個詞語，則將其忽略。",
        [LID.SCAN_ALL_RECIPES]                        = '掃描所有配方',
        [LID.SCANNING_ENABLED]                        = "由於'%s'已勾選，掃描已啟用。", -- SCAN_ALL_RECIPES或ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                       = "掃描已停用。",
        [LID.PRIMARY_KEYWORDS]                        = "主要關鍵詞",
        [LID.HELP_PRIMARY_KEYWORDS]                   =
        "所有消息都通過這些詞語篩選，這些詞語是所有職業都常見的。匹配的消息進一步處理以查找與職業相關的內容。",
        [LID.HELP_CATEGORY_SECTION]                   =
        "類別是包含列表左側的配方的可折疊部分。'Favorites'不是一個類別。這主要用於像製造難度較高的有毒皮革工藝配方。在擴展開始時，當您只能專精於單個類別時，這也可能很有用。",
        [LID.HELP_EXPANSION_SECTION]                  = "知識樹隨擴展而異，因此問候也可能不同。",
        [LID.HELP_PROFESSION_SECTION]                 =
        "從客戶的角度來看，各個擴展之間沒有區別。這些術語與“主要擴展”選項結合使用，以在無法匹配更具體的內容時提供通用問候（例如'我有<職業>。'）。",
        [LID.RECIPE_NOT_LEARNED]                      = "您尚未學習此配方。掃描已停用。",
        [LID.PING_SOUND_LABEL]                        = "警報聲",
        [LID.PING_SOUND_TOOLTIP]                      = "檢測到客戶時播放的聲音。",
        [LID.BANNER_SIDE_LABEL]                       = "橫幅方向",
        [LID.BANNER_SIDE_TOOLTIP]                     = "橫幅將從此按鈕向外擴展的方向。",
        Left                                          = "左",
        Right                                         = "右",
        Minute                                        = "分鐘",
        Minutes                                       = "分鐘",
        Second                                        = "秒",
        Seconds                                       = "秒",
        Millisecond                                   = "毫秒",
        Milliseconds                                  = "毫秒",
        Version                                       = "版本",
        ["CraftScan Release Notes"]                   = "CraftScan 更新日誌",
        [LID.CUSTOMER_TIMEOUT_LABEL]                  = "客戶超時",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]                = "在這麼多分鐘後自動解散客戶。",
        [LID.BANNER_TIMEOUT_LABEL]                    = "橫幅超時",
        [LID.BANNER_TIMEOUT_TOOLTIP]                  =
        "檢測到匹配後，客戶通知橫幅將在此時間後保持顯示。",
        ["All crafters"]                              = "所有製造者",
        ["Crafter Name"]                              = "製造者名稱",
        ["Profession"]                                = "職業",
        ["Customer Name"]                             = "客戶名稱",
        ["Replies"]                                   = "回覆",
        ["Keywords"]                                  = "關鍵詞",
        ["Profession greeting"]                       = "職業問候",
        ["Category greeting"]                         = "類別問候",
        ["Item greeting"]                             = "物品問候",
        ["Primary expansion"]                         = "主要擴展",
        ["Override greeting"]                         = "覆蓋問候",
        ["Excluded keywords"]                         = "排除的關鍵詞",
        [LID.EXCLUSION_INSTRUCTIONS]                  = "不要匹配包含逗號分隔的這些令牌的消息。",
        [LID.KEYWORD_INSTRUCTIONS]                    = "匹配包含逗號分隔的這些關鍵詞的消息。",
        [LID.GREETING_INSTRUCTIONS]                   = "發送給尋找製造的客戶的問候。",
        [LID.GLOBAL_INCLUSION_DEFAULT]                = "LF，LFC，WTB，recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]                = "LFW，WTS，LF work",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]          = "BS，Blacksmith，Armorsmith，Weaponsmith",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]         = "LW，Leatherworking，Leatherworker",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]                = "Alc，Alchemist，Stone",
        [LID.DEFAULT_KEYWORDS_TAILORING]              = "Tailor",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]            = "Engineer，Eng",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]             = "Enchanter，Crest",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]          = "JC，Jewelcrafter",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]            = "Inscription，Inscriptionist，Scribe",

        -- Release notes
        [LID.RN_WELCOME]                              = "歡迎使用 CraftScan！",
        [LID.RN_WELCOME + 1]                          =
        "此插件會掃描聊天中看起來像製造請求的消息。如果配置指示您可以製造所需的物品，則會觸發通知並存儲客戶信息以便進行溝通。",

        [LID.RN_INITIAL_SETUP]                        = "初始設置",
        [LID.RN_INITIAL_SETUP + 1]                    =
        "要開始，打開一個專業技能並點擊底部的新的“顯示製造掃描”按鈕。",
        [LID.RN_INITIAL_SETUP + 2]                    =
        "滾動到此新窗口的底部，然後從底部開始逐步操作。您很少需要更改的事項位於底部，但這些是首先關心的設置。",
        [LID.RN_INITIAL_SETUP + 3]                    =
        "如果您需要對任何輸入進行解釋，請點擊窗口左上角的幫助圖標。",

        [LID.RN_INITIAL_TESTING]                      = "初始測試",
        [LID.RN_INITIAL_TESTING + 1]                  =
        "配置完成後，在/say聊天中輸入一條消息，例如“LF BS”表示製錶，假設您已經添加了“LF”和“BS”關鍵詞。應該會彈出一個通知。",
        [LID.RN_INITIAL_TESTING + 2]                  =
        "點擊通知以立即發送回應，右鍵點擊以解散客戶，或者單擊圓形職業按鈕本身以打開訂單窗口。",
        [LID.RN_INITIAL_TESTING + 3]                  =
        "除非已解散，否則重複通知會被壓制，因此如果要再試一次，請右鍵點擊您的測試通知以解散它。",

        [LID.RN_MANAGING_CRAFTERS]                    = "管理您的製造者",
        [LID.RN_MANAGING_CRAFTERS + 1]                =
        "訂單窗口的左側列出了您的製造者。隨著您登錄各種角色並配置其職業，此列表將填充。您可以選擇任何時候激活哪些角色進行掃描，以及每個製造者的視覺和聽覺通知是否啟用。",

        [LID.RN_MANAGING_CUSTOMERS]                   = "管理客戶",
        [LID.RN_MANAGING_CUSTOMERS + 1]               =
        "訂單窗口的右側將填充在聊天中檢測到的製造訂單。左鍵點擊一行以發送問候，如果您尚未從彈出橫幅中這樣做的話。再次左鍵點擊以向客戶打開密語。右鍵點擊以解散行。",
        [LID.RN_MANAGING_CUSTOMERS + 2]               =
        "此表中的行將跨所有角色保留，因此您可以切換到小號，然後再次單擊客戶以恢復通信。默認情況下，行將在10分鐘後超時。此持續時間可以在主要設置頁面中配置（按Esc -> 選項 -> 插件 -> CraftScan）。",
        [LID.RN_MANAGING_CUSTOMERS + 3]               =
        "希望表中大部分內容都是不言自明的。 '回覆'列有3個圖標。左邊的X或檢查標記表示您是否向客戶發送了消息。右邊的X或檢查標記表示客戶是否已回覆。聊天氣泡是一個按鈕，將打開一個臨時的密語窗口與客戶對話，並將其填充為您的聊天歷史記錄。",

        [LID.RN_KEYBINDS]                             = "快捷鍵",
        [LID.RN_KEYBINDS + 1]                         =
        "可用於打開訂單頁面、回覆最新客戶以及解散最新客戶的快捷鍵。搜索“CraftScan”以查找所有可用設置。",

        [LID.RN_CLEANUP]                              = "配置清理",
        [LID.RN_CLEANUP + 1]                          = "在'聊天訂單'頁面的左側，現在可以右鍵點擊您的工匠，會出現一個上下文選單。使用此選單保持列表整潔，並刪除過時的角色/職業。",
        ["Disable"]                                   = "禁用",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]              =
        "永久刪除任何保存的 %s 的 %s 資料。\n\n在專業頁面上將有一個'啟用 CraftScan'按鈕，可以透過預設設置再次啟用它。\n\n如果您想繼續使用該專業但不想使用 CraftScan 互動（例如，當您在所有小號上都擁有煉金術用於長效藥劑時），請使用此功能。", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]                   = "輸入 'DELETE' 以繼續:",
        [LID.SCANNER_CONFIG_DISABLED]                 = "啟用 CraftScan",

        ["Cleanup"]                                   = "清理",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]             =
        "永久刪除任何保存的 %s 的 %s 資料。\n\n該專業將處於未配置的狀態。再次打開專業會恢復預設配置。\n\n如果您想完全重置一個專業，已刪除角色，或已放棄一個專業，請使用此功能。", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]                  = "輸入 'CLEANUP' 以繼續:",
        ["Primary Crafter"]                           = "主要工匠",
        [LID.PRIMARY_CRAFTER_TOOLTIP]                 = "將 %s 標記為 %s 的主要工匠。如果有多個匹配的請求，該工匠將優先於其他工匠。",
        ["Chat History"]                              = "與 %s 的聊天記錄", -- customer, left-click-help
        ["Greet Help"]                                = "|cffffd100左鍵點擊: 問候顧客%s|r",
        ["Chat Help"]                                 = "|cffffd100左鍵點擊: 打開悄悄話|r",
        ["Chat Override"]                             = "|cffffd100中鍵點擊: 打開悄悄話%s|r",
        ["Dismiss"]                                   = "|cffffd100右鍵點擊: 關閉%s|r",
        ["Proposed Greeting"]                         = "建議的問候語:",
        [LID.CHAT_BUTTON_BINDING_NAME]                = "悄悄話橫幅顧客",
        ["Customer Request"]                          = "%s 的請求",
        [LID.ADDON_WHITELIST_LABEL]                   = "插件白名單",
        [LID.ADDON_WHITELIST_TOOLTIP]                 = "當你按下按鈕暫時禁用所有插件時，保持此處選擇的插件啟用。CraftScan將始終保持啟用。僅保留你有效製作所需的內容。",
        [LID.MULTI_SELECT_BUTTON_TEXT]                = "已選擇%d項", -- Count

        [LID.ACCOUNT_LINK_DESC]                       = "在多個帳戶之間共享製作人。\n\n在登錄或配置更改後，CraftScan會在配置的製作人之間傳播最新信息，以確保連結的帳戶雙方始終保持同步。",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]           = "輸入你其他帳戶中在線角色的名字：",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]            = "為另一個帳戶輸入一個暱稱：",
        ["Link Account"]                              = "連結帳戶",
        ["Linked Accounts"]                           = "已連結帳戶",
        ["Accept Linked Account"]                     = "接受已連結帳戶",
        ["Delete Linked Account"]                     = "刪除已連結帳戶",
        ["OK"]                                        = "確定",
        [LID.VERSION_MISMATCH]                        = "|cFFFF0000錯誤：CraftScan版本不相容。另一個帳戶的版本：%s。您的版本：%s。|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]                  =
        "此角色屬於已連結的帳戶。它只能在其所屬的帳戶上被禁用。你可以通過“清理”完全移除此角色，但你需要在所有已連結的帳戶上手動執行此操作，否則它將在登錄時被已連結的帳戶恢復。",
        [LID.REMOTE_CRAFTER_SUMMARY]                  = "與%s同步。",
        ["proxy_send_enabled"]                        = "代理訂單",
        ["proxy_send_enabled_tooltip"]                = "當檢測到客戶訂單時，將其發送到已連結的帳戶。",
        ["proxy_receive_enabled"]                     = "接收代理訂單",
        ["proxy_receive_enabled_tooltip"]             = "當另一個帳戶檢測到並發送客戶訂單時，此帳戶將接收它。如果需要，CraftScan按鈕將顯示警告橫幅。",
        [LID.LINK_ACTIVE]                             = "|cFF00FF00%s（上次看到%s）|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]                =
        "刪除與'%s'的連結並刪除所有導入的角色。此帳戶將停止與另一方的所有通信。另一方將繼續嘗試建立連接，直到在該處手動刪除連結為止。\n\n將被刪除的導入製作人：\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]                   =
        "默認情況下，你最初連結的角色、任何製作人以及此帳戶在線時登錄的任何角色都為CraftScan所知。添加屬於另一個帳戶的其他角色，以便他們也可以使用。如果他們在線，請使用'/reload'強制與新角色同步。",
        ["Backup characters"]                         = "其他角色",
        ["Unlink account"]                            = "取消連結帳戶",
        ["Add"]                                       = "添加",
        ["Remove"]                                    = "移除",
        ["Rename account"]                            = "重新命名帳戶",
        ["New name"]                                  = "新名字：",

        [LID.RN_LINKED_ACCOUNTS]                      = "已連結帳戶",
        [LID.RN_LINKED_ACCOUNTS + 1]                  = "將多個WoW帳戶連結在一起以共享製作信息並從任何帳戶掃描到任何帳戶。",
        [LID.RN_LINKED_ACCOUNTS + 2]                  = "可選地，發送客戶訂單代理從一個帳戶到其他帳戶，這樣你可以讓測試帳戶在城市中保持不變，而你的主賬戶在外面。",
        [LID.RN_LINKED_ACCOUNTS + 3]                  = "要開始，請點擊CraftScan窗口左下角的“連結帳戶”按鈕，並按照說明操作。",
        [LID.RN_LINKED_ACCOUNTS + 4]                  = "演示：https://www.youtube.com/watch?v=x1JLEph6t_c",
        ["Open Settings"]                             = "打開設置",
        ["Customize Greeting"]                        = "自訂問候語",
        [LID.CUSTOM_GREETING_INFO]                    = "CraftScan 使用這些句子根據情況向客戶發送初始問候語。覆蓋下方的部分或全部內容以創建自己的問候語。",
        ["Default"]                                   = "默認",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS]            = "錯誤: 預期的占位符數量為 %d 或更少。提供的文本中有 %d 個。",
        [LID.WRONG_TYPE_OF_PLACEHOLDERS]              = "錯誤: 僅支持 %s 占位符。",

        ["item link"]                                 = "物品鏈接",
        ["alt name and then item link"]               = "替代名稱和物品鏈接",
        ["profession name"]                           = "職業名稱",
        ["alt name and then profession name"]         = "替代名稱和職業名稱",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS_SUGGESTION] =
        "此文本必須包含 %d 個或更少的 %%s 占位符才能包含 %s。你已經包含了 %d 個。\n\nCraftScan 可以在更少的占位符下工作，但你可能希望為上下文包含它們。",
    }
end
