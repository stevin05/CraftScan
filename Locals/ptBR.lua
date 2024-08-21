local CraftScan = select(2, ...)

CraftScan.LOCAL_PT = {}

function CraftScan.LOCAL_PT:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                         = "CraftScan",
        [LID.CRAFT_SCAN]                      = "CraftScan",
        [LID.CHAT_ORDERS]                     = "Ordens no Chat",
        [LID.DISABLE_ADDONS]                  = "Desativar Addons",
        [LID.RENABLE_ADDONS]                  = "Reativar Addons",
        [LID.DISABLE_ADDONS_TOOLTIP]          =
        "Salve sua lista de addons e, em seguida, desative-os, permitindo uma troca rápida para um personagem alternativo. Este botão pode ser clicado novamente para reativar os addons a qualquer momento.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]       = "Posso criar %s.",                                -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]     = "Meu personagem alternativo, %s, pode criar %s.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]            = "isso",
        [LID.GREETING_I_HAVE_PROF]            = "Eu tenho %s.",                                   -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]           = "Meu personagem alternativo, %s, tem %s.",        -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]             = "Me avise se você enviar um pedido para que eu possa fazer login.",
        [LID.MAIN_BUTTON_BINDING_NAME]        = "Alternar Página de Pedido",
        [LID.GREET_BUTTON_BINDING_NAME]       = "Saudar Cliente com Banner",
        [LID.DISMISS_BUTTON_BINDING_NAME]     = "Dispensar Cliente com Banner",
        [LID.TOGGLE_CHAT_TOOLTIP]             = "Alternar ordens no chat%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]             = "Mostrar CraftScan",
        [LID.SCANNER_CONFIG_HIDE]             = "Esconder CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]              = "Opções do CraftScan",
        [LID.ITEM_SCAN_CHECK]                 = "Verificar chat para este item",
        [LID.HELP_PROFESSION_KEYWORDS]        =
        "Uma mensagem deve conter um destes termos. Para coincidir com uma mensagem como 'LF Lariat', 'lariet' deve estar listado aqui. Para gerar um link de item para o Elemental Lariat na resposta, 'lariat' também deve ser incluído nas palavras-chave de configuração do item para o Elemental Lariat.",
        [LID.HELP_PROFESSION_EXCLUSIONS]      =
        "Uma mensagem será ignorada se contiver um destes termos, mesmo que fosse uma coincidência. Para evitar responder a 'LF JC Lariat' com 'Eu tenho Joalheria' quando você não tem a receita Lariat, 'lariat' deve ser listado aqui.",
        [LID.HELP_SCAN_ALL]                   = "Ativar verificação para todas as receitas na mesma expansão que a receita selecionada.",
        [LID.HELP_PRIMARY_EXPANSION]          =
        "Use esta saudação ao responder a uma solicitação genérica como 'LF Ferreiro'. Quando uma nova expansão é lançada, você provavelmente desejará uma saudação descrevendo quais itens você pode criar em vez de declarar que possui conhecimento máximo da expansão anterior.",
        [LID.HELP_EXPANSION_GREETING]         =
        "Uma introdução inicial é sempre gerada afirmando que você pode criar o item. Este texto é adicionado a ele. Novas linhas são permitidas e serão enviadas como uma resposta separada. Se o texto for muito longo, ele será dividido em várias respostas.",
        [LID.HELP_CATEGORY_KEYWORDS]          =
        "Se uma profissão foi encontrada, verifique estas palavras-chave específicas da categoria para refinar a saudação. Por exemplo, você pode colocar 'tóxico' ou 'viscoso' aqui para tentar detectar padrões de Couraria que requerem o Altar da Decomposição.",
        [LID.HELP_CATEGORY_GREETING]          =
        "Quando esta categoria é detectada em uma mensagem, seja por palavra-chave ou um link de item, esta saudação adicional será adicionada após a saudação da profissão.",
        [LID.HELP_CATEGORY_OVERRIDE]          = "Omita a saudação da profissão e comece com a saudação da categoria.",
        [LID.HELP_ITEM_KEYWORDS]              =
        "Se uma profissão foi encontrada, verifique estas palavras-chave específicas do item para refinar a saudação. Quando coincidir, a resposta incluirá o link do item em vez da saudação genérica da profissão. Se 'lariat' for uma palavra-chave da profissão, mas não uma palavra-chave do item, a resposta dirá 'Eu tenho Joalheria.' Se 'lariat' for apenas uma palavra-chave do item, 'LF Lariat' não corresponderá a uma profissão e não será considerado uma coincidência. Se 'lariat' for uma palavra-chave tanto da profissão quanto do item, a resposta para 'LF Lariat' será 'Posso criar [Lariat Elemental].'",
        [LID.HELP_ITEM_GREETING]              =
        "Quando este item é detectado em uma mensagem, seja por palavra-chave ou pelo link do item, esta saudação adicional será adicionada após as saudações da profissão e da categoria.",
        [LID.HELP_ITEM_OVERRIDE]              = "Omita a saudação da profissão e da categoria e comece com a saudação do item.",
        [LID.HELP_GLOBAL_KEYWORDS]            = "Uma mensagem deve incluir um destes termos.",
        [LID.HELP_GLOBAL_EXCLUSIONS]          = "Uma mensagem será ignorada se contiver um destes termos.",
        [LID.SCAN_ALL_RECIPES]                = 'Verificar todas as receitas',
        [LID.SCANNING_ENABLED]                = "A verificação está ativada porque '%s' está marcado.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]               = "A verificação está desativada.",
        [LID.PRIMARY_KEYWORDS]                = "Palavras-chave Primárias",
        [LID.HELP_PRIMARY_KEYWORDS]           =
        "Todas as mensagens são filtradas por esses termos, que são comuns em todas as profissões. Uma mensagem correspondente é posteriormente processada para buscar conteúdo relacionado à profissão.",
        [LID.HELP_CATEGORY_SECTION]           =
        "A categoria é a seção expansível que contém a receita na lista à esquerda. 'Favoritos' não é uma categoria. Isso é destinado principalmente para coisas como as receitas de Couraria tóxicas que são mais difíceis de criar. Também pode ser útil no início das expansões, quando você só pode se especializar em uma única categoria.",
        [LID.HELP_EXPANSION_SECTION]          =
        "As árvores de conhecimento diferem por expansão, então a saudação também pode diferir.",
        [LID.HELP_PROFESSION_SECTION]         =
        "Do ponto de vista do cliente, não há diferença entre expansões. Esses termos se combinam com a seleção 'Expansão primária' para fornecer uma saudação genérica (por exemplo, 'Eu tenho <profissão>.') quando não podemos corresponder a algo mais específico.",
        [LID.RECIPE_NOT_LEARNED]              = "Você não aprendeu esta receita. A verificação está desativada.",
        [LID.PING_SOUND_LABEL]                = "Som de Alerta",
        [LID.PING_SOUND_TOOLTIP]              = "O som que toca quando um cliente é detectado.",
        [LID.BANNER_SIDE_LABEL]               = "Direção do Banner",
        [LID.BANNER_SIDE_TOOLTIP]             = "O banner crescerá do botão nesta direção.",
        Left                                  = "Esquerda",
        Right                                 = "Direita",
        Minute                                = "Minuto",
        Minutes                               = "Minutos",
        Second                                = "Segundo",
        Seconds                               = "Segundos",
        Millisecond                           = "Milissegundo",
        Milliseconds                          = "Milissegundos",
        Version                               = "Novo em",
        ["CraftScan Release Notes"]           = "Notas da Versão do CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]          = "Tempo Limite do Cliente",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]        = "Dispensar clientes automaticamente após tantos minutos.",
        [LID.BANNER_TIMEOUT_LABEL]            = "Tempo Limite do Banner",
        [LID.BANNER_TIMEOUT_TOOLTIP]          =
        "O banner de notificação do cliente permanecerá exibido por esta duração após uma correspondência ser detectada.",
        ["All crafters"]                      = "Todos os Criadores",
        ["Crafter Name"]                      = "Nome do Criador",
        ["Profession"]                        = "Profissão",
        ["Customer Name"]                     = "Nome do Cliente",
        ["Replies"]                           = "Respostas",
        ["Keywords"]                          = "Palavras-chave",
        ["Profession greeting"]               = "Saudação da Profissão",
        ["Category greeting"]                 = "Saudação da Categoria",
        ["Item greeting"]                     = "Saudação do Item",
        ["Primary expansion"]                 = "Expansão Primária",
        ["Override greeting"]                 = "Saudação de Substituição",
        ["Excluded keywords"]                 = "Palavras-chave Excluídas",
        [LID.EXCLUSION_INSTRUCTIONS]          = "Não corresponder a mensagens contendo esses tokens separados por vírgula.",
        [LID.KEYWORD_INSTRUCTIONS]            = "Corresponder a mensagens contendo uma destas palavras-chave separadas por vírgula.",
        [LID.GREETING_INSTRUCTIONS]           = "Uma saudação para enviar aos clientes que procuram uma criação.",
        [LID.GLOBAL_INCLUSION_DEFAULT]        = "LF, LFC, Compra, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]        = "LFW, Venda, LF trabalho",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]  = "FE, Ferraria, Ferreiro de Armaduras, Ferreiro de Armas",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING] = "Couraria, Curtidor",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]        = "Alquimia, Alquimista, Pedra",
        [LID.DEFAULT_KEYWORDS_TAILORING]      = "Costureiro",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]    = "Engenheiro, Eng",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]     = "Encantador, Emblema",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]  = "JC, Joalheiro",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]    = "Inscrição, Escriba, Calígrafo",

        -- Notas de Versão
        [LID.RN_WELCOME]                      = "Bem-vindo ao CraftScan!",
        [LID.RN_WELCOME + 1]                  =
        "Este addon escaneia o chat em busca de mensagens que parecem pedidos de criação. Se a configuração indicar que você pode criar o item solicitado, uma notificação será acionada e as informações do cliente serão armazenadas para facilitar a comunicação.",

        [LID.RN_INITIAL_SETUP]                = "Configuração Inicial",
        [LID.RN_INITIAL_SETUP + 1]            =
        "Para começar, abra uma profissão e clique no novo botão 'Mostrar CraftScan' na parte inferior.",
        [LID.RN_INITIAL_SETUP + 2]            =
        "Role até o final desta nova janela e vá subindo. As coisas que você raramente muda estão no final, mas essas são as configurações a se preocupar primeiro.",
        [LID.RN_INITIAL_SETUP + 3]            =
        "Clique no ícone de ajuda no canto superior esquerdo da janela se precisar de uma explicação de qualquer entrada.",

        [LID.RN_INITIAL_TESTING]              = "Teste Inicial",
        [LID.RN_INITIAL_TESTING + 1]          =
        "Depois de configurado, digite uma mensagem no chat /dizer, como 'LF FE' para Ferraria, assumindo que você tenha as palavras-chave 'LF' e 'FE'. Uma notificação deve aparecer.",
        [LID.RN_INITIAL_TESTING + 2]          =
        "Clique na notificação para enviar imediatamente uma resposta, clique com o botão direito para dispensar o cliente ou clique no próprio botão circular da profissão para abrir a janela de pedidos.",
        [LID.RN_INITIAL_TESTING + 3]          =
        "Notificações duplicadas são suprimidas a menos que já tenham sido dispensadas, então clique com o botão direito na sua notificação de teste para dispensá-la se quiser tentar novamente.",

        [LID.RN_MANAGING_CRAFTERS]            = "Gerenciando Seus Criadores",

        [LID.RN_MANAGING_CRAFTERS + 1]        =
        "O lado esquerdo da janela de pedidos lista seus criadores. Esta lista será preenchida à medida que você fizer login em seus vários personagens e configurar suas profissões. Você pode selecionar quais personagens devem ser escaneados ativamente a qualquer momento, bem como se as notificações visuais e auditivas estão habilitadas para cada um de seus criadores.",

        [LID.RN_MANAGING_CUSTOMERS]           = "Gerenciando Clientes",
        [LID.RN_MANAGING_CUSTOMERS + 1]       =
        "O lado direito da janela de pedidos será preenchido com pedidos de criação detectados no chat. Clique com o botão esquerdo em uma linha para enviar a saudação se você ainda não o fez pelo banner pop-up. Clique novamente para abrir um sussurro para o cliente. Clique com o botão direito para dispensar a linha.",
        [LID.RN_MANAGING_CUSTOMERS + 2]       =
        "As linhas nesta tabela persistirão em todos os personagens, então você pode fazer login em um personagem alternativo e depois clicar no cliente novamente para restaurar a comunicação. As linhas expiram após 10 minutos por padrão. Esta duração pode ser configurada na página de configurações principais (Esc -> Opções -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]       =
        "Esperançosamente, a maior parte da tabela é autoexplicativa. A coluna 'Respostas' possui 3 ícones. O X ou marca de seleção à esquerda é se você enviou uma mensagem para o cliente. O X ou marca de seleção à direita é se o cliente respondeu. O balão de chat é um botão que abrirá uma janela de sussurro temporária com o cliente e a preencherá com seu histórico de bate-papo.",

        [LID.RN_KEYBINDS]                     = "Atalhos de Teclado",
        [LID.RN_KEYBINDS + 1]                 =
        "Atalhos de teclado estão disponíveis para abrir a página de pedidos, responder ao último cliente e dispensar o último cliente. Procure por 'CraftScan' para encontrar todas as configurações disponíveis.",

        [LID.RN_CLEANUP]                      = "Limpeza de Configuração",
        [LID.RN_CLEANUP + 1]                  =
        "Seus artesãos no lado esquerdo da página 'Ordens de Chat' agora têm um menu de contexto ao clicar com o botão direito. Use este menu para manter a lista limpa e remover personagens/profissões desatualizados.",
        ["Disable"]                           = "Desativar",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]      =
        "Exclua permanentemente qualquer dado %s salvo para %s.\n\nUm botão 'Habilitar CraftScan' estará presente na página da profissão para habilitá-lo novamente com as configurações padrão.\n\nUse isso se você quiser continuar usando a profissão, mas sem a interação do CraftScan (por exemplo, quando você tem Alquimia em todos os alts para frascos longos).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]           = "Digite 'DELETE' para continuar:",
        [LID.SCANNER_CONFIG_DISABLED]         = "Habilitar CraftScan",

        ["Cleanup"]                           = "Limpeza",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]     =
        "Exclua permanentemente qualquer dado %s salvo para %s.\n\nA profissão será deixada em um estado como se nunca tivesse sido configurada. Simplesmente abrir a profissão novamente restaurará uma configuração padrão.\n\nUse isso se você quiser redefinir completamente uma profissão, excluiu o personagem ou abandonou a profissão.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]          = "Digite 'CLEANUP' para continuar:",
        ["Primary Crafter"]                   = "Artesão Principal",
        [LID.PRIMARY_CRAFTER_TOOLTIP]         =
        "Marque %s como seu artesão principal para %s. Este artesão terá prioridade sobre os outros se houver várias correspondências com a mesma solicitação.",
        ["Chat History"]                      = "Histórico de bate-papo com %s", -- customer, left-click-help
        ["Greet Help"]                        = "|cffffd100Clique esquerdo: Cumprimentar o cliente%s|r",
        ["Chat Help"]                         = "|cffffd100Clique esquerdo: Abrir sussurro|r",
        ["Chat Override"]                     = "|cffffd100Clique do meio: Abrir sussurro%s|r",
        ["Dismiss"]                           = "|cffffd100Clique direito: Dispensar%s|r",
        ["Proposed Greeting"]                 = "Cumprimento proposto:",
        [LID.CHAT_BUTTON_BINDING_NAME]        = "Cliente do Banner Sussurro",
        ["Customer Request"]                  = "Pedido de %s",
        [LID.ADDON_WHITELIST_LABEL]           = "Lista branca de addons",
        [LID.ADDON_WHITELIST_TOOLTIP]         =
        "Ao pressionar o botão para desativar temporariamente todos os addons, mantenha os addons selecionados aqui ativados. CraftScan sempre permanecerá ativado. Mantenha apenas o que você precisa para fabricar de forma eficiente.",
        [LID.MULTI_SELECT_BUTTON_TEXT]        = "%d selecionados", -- Count

        [LID.ACCOUNT_LINK_DESC]               =
        "Compartilhe artesãos entre várias contas.\n\nAo entrar ou após uma alteração na configuração, o CraftScan irá propagar as informações mais recentes para e dos artesãos configurados em ambas as contas para garantir que ambos os lados de uma conta vinculada estejam sempre sincronizados.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]   = "Digite o nome de um personagem online em sua outra conta:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]    = "Digite um apelido para a outra conta:",
        ["Link Account"]                      = "Vincular Conta",
        ["Linked Accounts"]                   = "Contas Vinculadas",
        ["Accept Linked Account"]             = "Aceitar Conta Vinculada",
        ["Delete Linked Account"]             = "Excluir Conta Vinculada",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]    =
        "'%s' enviou uma solicitação para vincular contas.\n\nNÃO ACEITE SE VOCÊ NÃO ENVIOU.\n\nDigite um apelido para a outra conta:",
        [LID.ACCOUNT_LINK_ACCEPT_DST_LABEL]   =
        "|cFF00FF00Você tem uma solicitação pendente para vincular contas com %s. Clique aqui para aceitar.|r",
        ["OK"]                                = "OK",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_INFO]    =
        "Para completar a vinculação de contas, você deve aceitar a solicitação na outra conta. O botão 'Vincular Conta' será substituído por um botão 'Aceitar Conta Vinculada' para completar a operação. Se houver um erro, ele será exibido ao lado do botão 'Vincular Conta'.",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_LABEL]   = "|cFFFFA500Aguardando %s aceitar a solicitação de vinculação de conta.|r",
        [LID.VERSION_MISMATCH]                =
        "|cFFFF0000Erro: incompatibilidade de versão do CraftScan. Versão da outra conta: %s. Sua versão: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]          =
        "Este personagem pertence a uma conta vinculada. Ele só pode ser desativado na conta à qual pertence. Você pode remover completamente este personagem via 'Limpeza', mas precisará fazê-lo manualmente em todas as contas vinculadas, ou ele será restaurado por uma conta vinculada ao entrar.",
        [LID.REMOTE_CRAFTER_SUMMARY]          = "Sincronizado com %s.",
        ["proxy_send_enabled"]                = "Pedidos por Proxy",
        ["proxy_send_enabled_tooltip"]        = "Quando um pedido de cliente é detectado, envie-o para contas vinculadas.",
        ["proxy_receive_enabled"]             = "Receber Pedidos por Proxy",
        ["proxy_receive_enabled_tooltip"]     =
        "Quando outra conta detectar e enviar um pedido de cliente, esta conta o receberá. O botão CraftScan será exibido para mostrar o banner de alerta se necessário.",
        [LID.LINK_ACTIVE]                     = "|cFF00FF00%s (visto por último %s)|r", -- Crafter, Time
        [LID.LINK_DEAD]                       = "|cFFFF0000Offline|r",
        [LID.ACCOUNT_LINK_DELETE_INFO]        =
        "Excluir a vinculação com '%s' e todos os personagens importados. Esta conta cessará todas as comunicações com a outra parte. A outra parte ainda tentará estabelecer conexões até que a vinculação seja removida manualmente também lá.\n\nArtesãos importados que serão removidos:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]           =
        "Por padrão, o personagem que você inicialmente vinculou, qualquer artesão e qualquer personagem que tenha feito login enquanto esta conta estava online são conhecidos pelo CraftScan. Adicione personagens adicionais pertencentes à outra conta para que possam ser usados também. '/reload' para forçar a sincronização com o novo personagem, se estiver online.",
        ["Backup characters"]                 = "Personagens Adicionais",
        ["Unlink account"]                    = "Desvincular Conta",
        ["Add"]                               = "Adicionar",
        ["Remove"]                            = "Remover",
        ["Rename account"]                    = "Renomear Conta",
        ["New name"]                          = "Novo Nome:",

        [LID.RN_LINKED_ACCOUNTS]              = "Contas Vinculadas",
        [LID.RN_LINKED_ACCOUNTS + 1]          =
        "Vincule várias contas WoW juntas para compartilhar informações de fabricação e escanear qualquer conta de qualquer conta.",
        [LID.RN_LINKED_ACCOUNTS + 2]          =
        "Opcionalmente, envie pedidos de clientes de uma conta para as outras para que você possa estacionar uma conta de teste na cidade enquanto seu personagem principal está fora.",
        [LID.RN_LINKED_ACCOUNTS + 3]          =
        "Para começar, clique no botão 'Vincular Conta' no canto inferior esquerdo da janela CraftScan e siga as instruções.",
        [LID.RN_LINKED_ACCOUNTS + 4]          = "Demo: https://www.youtube.com/watch?v=x1JLEph6t_c",


    }
end
