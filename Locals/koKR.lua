local CraftScan = select(2, ...)

CraftScan.LOCAL_KO = {}

function CraftScan.LOCAL_KO:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                         = "CraftScan",
        [LID.CRAFT_SCAN]                      = "CraftScan",
        [LID.CHAT_ORDERS]                     = "채팅 주문",
        [LID.DISABLE_ADDONS]                  = "애드온 비활성화",
        [LID.RENABLE_ADDONS]                  = "애드온 다시 활성화",
        [LID.DISABLE_ADDONS_TOOLTIP]          =
        "애드온 목록을 저장한 후, 애드온을 비활성화하여 빠르게 다른 캐릭터로 전환할 수 있습니다. 이 버튼을 다시 클릭하여 언제든지 애드온을 다시 활성화할 수 있습니다.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]       = "%s 제작 가능합니다.", -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]     = "내 대체 캐릭터, %s가 %s를 제작할 수 있습니다.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]            = "이것",
        [LID.GREETING_I_HAVE_PROF]            = "%s을 가지고 있습니다.", -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]           = "내 대체 캐릭터, %s가 %s을 가지고 있습니다.", -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]             = "주문을 보내면 전환해서 확인할 수 있도록 알려주세요.",
        [LID.MAIN_BUTTON_BINDING_NAME]        = "주문 페이지 전환",
        [LID.GREET_BUTTON_BINDING_NAME]       = "인사 배너 고객",
        [LID.DISMISS_BUTTON_BINDING_NAME]     = "배너 고객 닫기",
        [LID.TOGGLE_CHAT_TOOLTIP]             = "채팅 주문 전환%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]             = "CraftScan 표시",
        [LID.SCANNER_CONFIG_HIDE]             = "CraftScan 숨기기",
        [LID.CRAFT_SCAN_OPTIONS]              = "CraftScan 옵션",
        [LID.ITEM_SCAN_CHECK]                 = "이 아이템에 대한 채팅 검색",
        [LID.HELP_PROFESSION_KEYWORDS]        =
        "이 용어 중 하나를 포함해야 합니다. 'LF Lariat'과 같은 메시지를 일치시키려면 여기에 'lariet'를 추가해야 합니다. 응답에 Elemental Lariat에 대한 아이템 링크를 생성하려면 Elemental Lariat에 대한 항목 구성 키워드에 'lariat'를 포함해야 합니다.",
        [LID.HELP_PROFESSION_EXCLUSIONS]      =
        "이 용어 중 하나를 포함하면 메시지가 일치하더라도 무시됩니다. 예를 들어 'LF JC Lariat'에 'lariat'가 포함되어 있지만 Lariat 레시피를 가지고 있지 않을 때 'I have Jewelcrafting'에 'I have Jewelcrafting'을 응답하지 않으려면 여기에 'lariat'를 추가해야 합니다.",
        [LID.HELP_SCAN_ALL]                   = "선택한 레시피와 동일한 확장팩에 모든 레시피를 검색하도록 설정합니다.",
        [LID.HELP_PRIMARY_EXPANSION]          =
        "이것은 'LF Blacksmith'와 같은 일반 요청에 대한 인사에 사용됩니다. 새로운 확장팩이 출시되면 해당 확장팩에서 제작할 수 있는 항목을 나열하는 대신 이전 확장팩에서 최대 지식을 가졌다는 것을 명시하는 것이 좋습니다.",
        [LID.HELP_EXPANSION_GREETING]         =
        "초기 인사는 항상 해당 아이템을 제작할 수 있다는 내용이 포함됩니다. 이 텍스트가 추가됩니다. 여러 줄을 사용할 수 있으며 이는 별도의 응답으로 전송됩니다. 텍스트가 너무 길면 여러 응답으로 분할됩니다.",
        [LID.HELP_CATEGORY_KEYWORDS]          =
        "직업이 일치하면 이러한 카테고리별 특정 키워드를 확인하여 인사를 정확하게 합니다. 예를 들어, 'toxic' 또는 'slimy'와 같은 키워드를 여기에 넣어 Alchemy 패턴을 감지하려고 시도할 수 있습니다.",
        [LID.HELP_CATEGORY_GREETING]          =
        "이 카테고리가 메시지에서 키워드나 아이템 링크를 통해 감지되면 이 추가 인사가 직업 인사 뒤에 추가됩니다.",
        [LID.HELP_CATEGORY_OVERRIDE]          = "직업 인사를 생략하고 카테고리 인사로 시작합니다.",
        [LID.HELP_ITEM_KEYWORDS]              =
        "직업이 일치하면 이러한 항목별 특정 키워드를 확인하여 인사를 정확하게 합니다. 일치하는 경우 응답에 일반적인 직업 인사 대신 아이템 링크가 포함됩니다. 'lariat'가 직업 키워드이지만 항목 키워드가 아닌 경우 응답에 'I have Jewelcrafting.'이라고 표시됩니다. 'lariat'가 항목 키워드 인 경우에만 'LF Lariat'가 직업을 일치시키지 않으며 일치로 간주되지 않되지 않습니다. 'lariat'가 직업 및 항목 키워드인 경우 'LF Lariat'에 대한 응답은 'I can craft [Elemental Lariat].'이 됩니다.",
        [LID.HELP_ITEM_GREETING]              =
        "메시지에서 이 항목이 키워드나 아이템 링크를 통해 감지되면 직업 및 카테고리 인사 뒤에 이 추가 인사가 추가됩니다.",
        [LID.HELP_ITEM_OVERRIDE]              = "직업 및 카테고리 인사를 생략하고 항목 인사로 시작합니다.",
        [LID.HELP_GLOBAL_KEYWORDS]            = "이 용어 중 하나가 메시지에 포함되어야 합니다.",
        [LID.HELP_GLOBAL_EXCLUSIONS]          = "이 용어가 포함된 메시지는 무시됩니다.",
        [LID.SCAN_ALL_RECIPES]                = '모든 레시피 검색',
        [LID.SCANNING_ENABLED]                = "'%s'가 선택되어 있으므로 스캔이 활성화되었습니다.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]               = "스캔이 비활성화되었습니다.",
        [LID.PRIMARY_KEYWORDS]                = "기본 키워드",
        [LID.HELP_PRIMARY_KEYWORDS]           =
        "이 용어로 필터링된 모든 메시지는 모든 직업에 공통입니다. 일치하는 메시지는 직업 관련 콘텐츠를 찾아 추가로 처리됩니다.",
        [LID.HELP_CATEGORY_SECTION]           =
        "카테고리는 왼쪽 목록에 있는 레시피를 포함하는 접히는 섹션입니다. 'Favorites'는 카테고리가 아닙니다. 이것은 주로 제작하기 어려운 독성 가죽 제작 레시피와 같은 것들에 대해 의도되었습니다. 확장팩 시작 시에는 하나의 카테고리에만 전문화할 수 있습니다.",
        [LID.HELP_EXPANSION_SECTION]          = "지식 트리는 확장팩마다 다르므로 인사도 다를 수 있습니다.",
        [LID.HELP_PROFESSION_SECTION]         =
        "고객 관점에서는 확장팩 간에 차이가 없습니다. 이 용어는 새로운 확장팩 출시 시 더 구체적인 것을 일치시키지 못할 때 일반적인 인사를 제공하기 위해 '기본 확장팩' 선택과 결합됩니다.",
        [LID.RECIPE_NOT_LEARNED]              = "이 레시피를 배우지 않았습니다. 스캔이 비활성화되었습니다.",
        [LID.PING_SOUND_LABEL]                = "알림 소리",
        [LID.PING_SOUND_TOOLTIP]              = "고객이 감지되었을 때 재생되는 소리.",
        [LID.BANNER_SIDE_LABEL]               = "배너 방향",
        [LID.BANNER_SIDE_TOOLTIP]             = "배너가 이 방향에서 버튼에서 늘어납니다.",
        Left                                  = "왼쪽",
        Right                                 = "오른쪽",
        Minute                                = "분",
        Minutes                               = "분",
        Second                                = "초",
        Seconds                               = "초",
        Millisecond                           = "밀리초",
        Milliseconds                          = "밀리초",
        Version                               = "신규",
        ["CraftScan Release Notes"]           = "CraftScan 릴리스 노트",
        [LID.CUSTOMER_TIMEOUT_LABEL]          = "고객 시간 초과",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]        = "이 시간(분)이 지나면 고객이 자동으로 해체됩니다.",
        [LID.BANNER_TIMEOUT_LABEL]            = "배너 시간 초과",
        [LID.BANNER_TIMEOUT_TOOLTIP]          =
        "매칭이 감지된 후 이 기간 동안 고객 알림 배너가 표시됩니다.",
        ["All crafters"]                      = "모든 제작자",
        ["Crafter Name"]                      = "제작자 이름",
        ["Profession"]                        = "직업",
        ["Customer Name"]                     = "고객 이름",
        ["Replies"]                           = "답장",
        ["Keywords"]                          = "키워드",
        ["Profession greeting"]               = "직업 인사",
        ["Category greeting"]                 = "카테고리 인사",
        ["Item greeting"]                     = "아이템 인사",
        ["Primary expansion"]                 = "기본 확장팩",
        ["Override greeting"]                 = "인사 덮어쓰기",
        ["Excluded keywords"]                 = "제외된 키워드",
        [LID.EXCLUSION_INSTRUCTIONS]          = "이 쉼표로 구분된 토큰을 포함하는 메시지를 일치시키지 마세요.",
        [LID.KEYWORD_INSTRUCTIONS]            = "이 쉼표로 구분된 키워드 중 하나가 포함된 메시지를 일치시킵니다.",
        [LID.GREETING_INSTRUCTIONS]           = "제작품을 찾는 고객에게 보낼 인사입니다.",
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
        [LID.RN_WELCOME]                      = "CraftScan에 오신 것을 환영합니다!",
        [LID.RN_WELCOME + 1]                  =
        "이 애드온은 제작 요청처럼 보이는 메시지를 채팅에서 스캔합니다. 구성에 따라 요청된 아이템을 제작할 수 있는 경우 알림이 트리거되고 고객 정보가 저장됩니다.",

        [LID.RN_INITIAL_SETUP]                = "초기 설정",
        [LID.RN_INITIAL_SETUP + 1]            =
        "시작하려면 직업을 열고 하단의 새 'CraftScan 표시' 버튼을 클릭하세요.",
        [LID.RN_INITIAL_SETUP + 2]            =
        "이 새 창의 하단부로 스크롤하여 위로 작업하세요. 드물게 변경해야 할 사항은 하단에 있지만, 이것이 먼저 주의해야 할 설정입니다.",
        [LID.RN_INITIAL_SETUP + 3]            =
        "창 왼쪽 상단의 도움말 아이콘을 클릭하여 입력란의 설명을 확인하세요.",

        [LID.RN_INITIAL_TESTING]              = "초기 테스트",
        [LID.RN_INITIAL_TESTING + 1]          =
        "구성한 후 /say 채팅에 'LF BS'와 같은 메시지를 입력하여 테스트하세요(문자는 키워드 'LF' 및 'BS'를 가정함). 알림이 표시됩니다.",
        [LID.RN_INITIAL_TESTING + 2]          =
        "알림을 클릭하여 즉시 응답을 보내려면 클릭하세요. 고객을 해체하려면 오른쪽 클릭하거나 원형 직업 버튼을 클릭하여 주문 창을 열 수 있습니다.",
        [LID.RN_INITIAL_TESTING + 3]          =
        "이미 해체된 것을 제외하고 중복 알림이 억제되므로 테스트 알림을 다시 시도하려면 테스트 알림을 해제하려면 테스트 알림을 해제하세요.",

        [LID.RN_MANAGING_CRAFTERS]            = "제작자 관리",
        [LID.RN_MANAGING_CRAFTERS + 1]        =
        "주문 창의 좌측에는 제작자 목록이 표시됩니다. 이 목록은 다양한 캐릭터에 로그인하고 그들의 직업을 구성하는 대로 채워집니다. 필요에 따라 어느 시점에서든 활성 스캔할 캐릭터를 선택하고 각 제작자에 대한 시각적 및 청각적 알림이 활성화되었는지 선택할 수 있습니다.",

        [LID.RN_MANAGING_CUSTOMERS]           = "고객 관리",
        [LID.RN_MANAGING_CUSTOMERS + 1]       =
        "주문 창의 우측에는 채팅에서 감지된 제작 주문이 표시됩니다. 행을 클릭하여 팝업 배너에서 이미 인사하지 않았다면 인사를 보낼 수 있습니다. 고객에게 새창에 임시 대화 창을 열려면 다시 클릭하세요. 행을 해체하려면 오른쪽 클릭하세요.",
        [LID.RN_MANAGING_CUSTOMERS + 2]       =
        "이 테이블의 행은 모든 캐릭터에 걸쳐 유지되므로 대체 캐릭터로 전환한 다음 고객을 다시 클릭하여 통신을 복원할 수 있습니다. 기본 설정에서 10분 후에 행이 타임아웃됩니다. 이 기간은 주 설정 페이지(Esc -> 옵션 -> 애드온 -> CraftScan)에서 구성할 수 있습니다.",
        [LID.RN_MANAGING_CUSTOMERS + 3]       =
        "테이블의 대부분은 자명합니다. 'Replies' 열에는 3개의 아이콘이 있습니다. 왼쪽 X 또는 확인 표시는 고객에게 메시지를 보냈는지 여부입니다. 오른쪽 X 또는 확인 표시는 고객이 회신했는지 여부입니다. 채팅 말풍선은 고객과 임시로 대화 창을 열며 채팅 기록을 채우는 버튼입니다.",

        [LID.RN_KEYBINDS]                     = "키 설정",
        [LID.RN_KEYBINDS + 1]                 =
        "주문 페이지를 열고 최신 고객에게 응답하거나 최신 고객을 해체하는 키 설정이 있습니다. 사용 가능한 모든 설정을 찾으려면 'CraftScan'을 검색하세요.",

        [LID.RN_CLEANUP]                      = "설정 정리",
        [LID.RN_CLEANUP + 1]                  =
        "'대화 주문' 페이지의 왼쪽에 있는 장인이 이제 오른쪽 클릭 시 컨텍스트 메뉴를 갖습니다. 이 메뉴를 사용하여 목록을 깨끗하게 유지하고 오래된 캐릭터/직업을 제거하세요.",
        ["Disable"]                           = "비활성화",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]      =
        "%s에 대한 모든 저장된 %s 데이터를 영구적으로 삭제합니다.\n\n'CraftScan 활성화' 버튼이 직업 페이지에 표시되어 기본 설정으로 다시 활성화할 수 있습니다.\n\n이 기능은 직업을 계속 사용하고 싶지만 CraftScan 상호작용 없이 사용하고 싶을 때 사용하세요 (예: 모든 부캐릭터에 연금술을 보유하여 긴 플라스크 사용).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]           = "계속하려면 'DELETE'를 입력하세요:",
        [LID.SCANNER_CONFIG_DISABLED]         = "CraftScan 활성화",

        ["Cleanup"]                           = "정리",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]     =
        "%s에 대한 모든 저장된 %s 데이터를 영구적으로 삭제합니다.\n\n직업이 설정되지 않은 상태로 남겨질 것입니다. 직업을 다시 열면 기본 구성이 복원됩니다.\n\n이 기능은 직업을 완전히 초기화하고 싶을 때, 캐릭터를 삭제했거나 직업을 버렸을 때 사용하세요.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]          = "계속하려면 'CLEANUP'을 입력하세요:",
        ["Primary Crafter"]                   = "주요 제작자",
        [LID.PRIMARY_CRAFTER_TOOLTIP]         = "이 %s를 %s의 주요 제작자로 설정합니다. 동일한 요청에 여러 매치가 있는 경우 이 제작자가 우선됩니다.",
        ["Chat History"]                      = "%s와의 채팅 기록", -- customer, left-click-help
        ["Greet Help"]                        = "|cffffd100왼쪽 클릭: 고객에게 인사%s|r",
        ["Chat Help"]                         = "|cffffd100왼쪽 클릭: 귓말 열기|r",
        ["Chat Override"]                     = "|cffffd100가운데 클릭: 귓말 열기%s|r",
        ["Dismiss"]                           = "|cffffd100오른쪽 클릭: 닫기%s|r",
        ["Proposed Greeting"]                 = "제안된 인사말:",
        [LID.CHAT_BUTTON_BINDING_NAME]        = "귓말 배너 고객",
        ["Customer Request"]                  = "%s의 요청",
        [LID.ADDON_WHITELIST_LABEL]           = "애드온 허용 목록",
        [LID.ADDON_WHITELIST_TOOLTIP]         =
        "모든 애드온을 일시적으로 비활성화하는 버튼을 누를 때, 여기에서 선택한 애드온을 유지합니다. CraftScan은 항상 활성화됩니다. 제작에 필요한 것만 유지하세요.",
        [LID.MULTI_SELECT_BUTTON_TEXT]        = "%d 선택됨", -- Count

        [LID.ACCOUNT_LINK_DESC]               =
        "여러 계정 간에 제작자를 공유하세요.\n\n로그인 시 또는 설정 변경 후, CraftScan은 양쪽 계정에 설정된 제작자 간 최신 정보를 전파하여 항상 동기화되도록 합니다.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]   = "다른 계정에 있는 온라인 캐릭터 이름을 입력하세요:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]    = "다른 계정의 별명을 입력하세요:",
        ["Link Account"]                      = "계정 연결",
        ["Linked Accounts"]                   = "연결된 계정",
        ["Accept Linked Account"]             = "연결된 계정 수락",
        ["Delete Linked Account"]             = "연결된 계정 삭제",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]    = "'%s'님이 계정 연결 요청을 보냈습니다.\n\n이 요청을 보내지 않았다면 수락하지 마세요.\n\n다른 계정의 별명을 입력하세요:",
        [LID.ACCOUNT_LINK_ACCEPT_DST_LABEL]   = "|cFF00FF00%s와(과) 계정 연결 요청이 있습니다. 여기 클릭하여 수락하세요.|r",
        ["OK"]                                = "확인",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_INFO]    =
        "계정 연결을 완료하려면 다른 계정에서 요청을 수락해야 합니다. '계정 연결' 버튼이 '연결된 계정 수락' 버튼으로 바뀌어 작업을 완료합니다. 오류가 발생하면 '계정 연결' 버튼 옆에 표시됩니다.",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_LABEL]   = "|cFFFFA500%s님이 계정 연결 요청을 수락할 때까지 기다리는 중입니다.|r",
        [LID.VERSION_MISMATCH]                = "|cFFFF0000오류: CraftScan 버전 불일치. 다른 계정의 버전: %s. 현재 버전: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]          =
        "이 캐릭터는 연결된 계정에 속합니다. 캐릭터가 속한 계정에서만 비활성화할 수 있습니다. '정리'를 통해 이 캐릭터를 완전히 제거할 수 있지만, 모든 연결된 계정에서 수동으로 제거해야 하며, 로그인 시 연결된 계정에 의해 복원됩니다.",
        [LID.REMOTE_CRAFTER_SUMMARY]          = "%s와(과) 동기화됨.",
        ["proxy_send_enabled"]                = "프록시 주문",
        ["proxy_send_enabled_tooltip"]        = "고객 주문이 감지되면, 연결된 계정에 보냅니다.",
        ["proxy_receive_enabled"]             = "프록시 주문 받기",
        ["proxy_receive_enabled_tooltip"]     = "다른 계정이 고객 주문을 감지하고 전송하면 이 계정이 받습니다. 필요한 경우 CraftScan 버튼이 경고 배너를 표시합니다.",
        [LID.LINK_ACTIVE]                     = "|cFF00FF00%s (마지막 접속: %s)|r", -- Crafter, Time
        [LID.LINK_DEAD]                       = "|cFFFF0000오프라인|r",
        [LID.ACCOUNT_LINK_DELETE_INFO]        =
        "'%s'와(과)의 연결을 삭제하고 모든 가져온 캐릭터를 삭제합니다. 이 계정은 다른 계정과의 모든 통신을 중단합니다. 다른 계정은 수동으로 연결을 제거할 때까지 계속 연결을 시도할 것입니다.\n\n삭제될 가져온 제작자:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]           =
        "기본적으로 처음 연결한 캐릭터, 모든 제작자, 이 계정이 온라인 상태일 때 로그인한 모든 캐릭터가 CraftScan에 알려져 있습니다. 다른 계정에 속한 추가 캐릭터를 추가하여 사용할 수 있도록 합니다. 온라인 상태인 경우 '/reload'로 새 캐릭터와 강제로 동기화하세요.",
        ["Backup characters"]                 = "추가 캐릭터",
        ["Unlink account"]                    = "계정 연결 해제",
        ["Add"]                               = "추가",
        ["Remove"]                            = "제거",
        ["Rename account"]                    = "계정 이름 변경",
        ["New name"]                          = "새 이름:",

        [LID.RN_LINKED_ACCOUNTS]              = "연결된 계정",
        [LID.RN_LINKED_ACCOUNTS + 1]          = "제작 정보를 공유하고 모든 계정에서 모든 계정의 스캔을 할 수 있도록 여러 WoW 계정을 연결하세요.",
        [LID.RN_LINKED_ACCOUNTS + 2]          = "원하는 경우 한 계정에서 다른 계정으로 고객 주문을 프록시하여 메인 캐릭터가 외부에 있는 동안 시험 계정을 도시에 주차할 수 있습니다.",
        [LID.RN_LINKED_ACCOUNTS + 3]          = "시작하려면 CraftScan 창의 왼쪽 하단 모서리에 있는 '계정 연결' 버튼을 클릭하고 지침을 따르세요.",
        [LID.RN_LINKED_ACCOUNTS + 4]          = "데모: https://www.youtube.com/watch?v=x1JLEph6t_c",


    }
end
