local CraftScan = select(2, ...)

CraftScan.LOCAL_FR = {}

function CraftScan.LOCAL_FR:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                         = "CraftScan",
        [LID.CRAFT_SCAN]                      = "CraftScan",
        [LID.CHAT_ORDERS]                     = "Commandes de discussion",
        [LID.DISABLE_ADDONS]                  = "Désactiver les addons",
        [LID.RENABLE_ADDONS]                  = "Réactiver les addons",
        [LID.DISABLE_ADDONS_TOOLTIP]          =
        "Enregistrez votre liste d'addons, puis désactivez-les, permettant un changement rapide vers un personnage alternatif. Ce bouton peut être cliqué à nouveau pour réactiver les addons à tout moment.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]       = "Je peux fabriquer %s.",             -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]     = "Mon alter, %s, peut fabriquer %s.", -- Nom du fabriquant, ItemLink
        [LID.GREETING_LINK_BACKUP]            = "ça",
        [LID.GREETING_I_HAVE_PROF]            = "J'ai %s.",                          -- Nom du métier
        [LID.GREETING_ALT_HAS_PROF]           = "Mon alter, %s, a %s.",              -- Nom du fabriquant, Nom du métier
        [LID.GREETING_ALT_SUFFIX]             = "Faites-le moi savoir si vous envoyez une commande pour que je puisse me connecter.",
        [LID.MAIN_BUTTON_BINDING_NAME]        = "Basculer la page de commande",
        [LID.GREET_BUTTON_BINDING_NAME]       = "Saluer le client de la bannière",
        [LID.DISMISS_BUTTON_BINDING_NAME]     = "Rejeter le client de la bannière",
        [LID.TOGGLE_CHAT_TOOLTIP]             = "Basculer les commandes de discussion%s", -- Raccourci
        [LID.SCANNER_CONFIG_SHOW]             = "Afficher CraftScan",
        [LID.SCANNER_CONFIG_HIDE]             = "Masquer CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]              = "Options de CraftScan",
        [LID.ITEM_SCAN_CHECK]                 = "Analyser la discussion pour cet objet",
        [LID.HELP_PROFESSION_KEYWORDS]        =
        "Un message doit contenir l'un de ces termes. Pour faire correspondre un message tel que 'LF Lariat', 'lariet' doit être répertorié ici. Pour générer un lien d'objet pour le Lariat élémentaire dans la réponse, 'lariat' doit également être inclus dans les mots-clés de configuration de l'objet pour le Lariat élémentaire.",
        [LID.HELP_PROFESSION_EXCLUSIONS]      =
        "Un message sera ignoré s'il contient l'un de ces termes, même s'il serait autrement une correspondance. Pour éviter de répondre à 'LF JC Lariat' avec 'J'ai la joaillerie' lorsque vous n'avez pas la recette du Lariat, 'lariat' doit être répertorié ici.",
        [LID.HELP_SCAN_ALL]                   =
        "Activer la numérisation pour toutes les recettes de la même extension que la recette sélectionnée.",
        [LID.HELP_PRIMARY_EXPANSION]          =
        "Utilisez cette salutation lors de la réponse à une demande générique telle que 'LF Forgeron'. Lors du lancement d'une nouvelle extension, vous voudrez probablement une salutation décrivant les objets que vous pouvez fabriquer au lieu de déclarer que vous avez une connaissance maximale de l'extension précédente.",
        [LID.HELP_EXPANSION_GREETING]         =
        "Une introduction initiale est toujours générée indiquant que vous pouvez fabriquer l'objet. Ce texte est ajouté à celui-ci. Les sauts de ligne sont autorisés et seront envoyés en tant que réponse distincte. Si le texte est trop long, il sera découpé en plusieurs réponses.",
        [LID.HELP_CATEGORY_KEYWORDS]          =
        "Si un métier a été trouvé, vérifiez ces mots-clés spécifiques à la catégorie pour affiner la salutation. Par exemple, vous pouvez mettre 'toxique' ou 'visqueux' ici pour tenter de détecter les patrons de travail du cuir nécessitant l'Autel de la décomposition.",
        [LID.HELP_CATEGORY_GREETING]          =
        "Lorsque cette catégorie est détectée dans un message, via un mot-clé ou un lien d'objet, cette salutation supplémentaire sera ajoutée après la salutation du métier.",
        [LID.HELP_CATEGORY_OVERRIDE]          = "Omettez la salutation du métier et commencez par la salutation de la catégorie.",
        [LID.HELP_ITEM_KEYWORDS]              =
        "Si un métier a été trouvé, vérifiez ces mots-clés spécifiques à l'objet pour affiner la salutation. Lorsqu'une correspondance est trouvée, la réponse inclura le lien d'objet au lieu de la salutation générique du métier. Si 'lariat' est un mot-clé de métier, mais pas un mot-clé d'objet, la réponse indiquera 'J'ai la joaillerie.' Si 'lariat' est uniquement un mot-clé d'objet, 'LF Lariat' ne correspondra pas à un métier et ne sera pas considéré comme une correspondance. Si 'lariat' est à la fois un mot-clé de métier et d'objet, la réponse à 'LF Lariat' sera 'Je peux fabriquer [Lariat élémentaire].'",
        [LID.HELP_ITEM_GREETING]              =
        "Lorsque cet objet est détecté dans un message, via un mot-clé ou un lien d'objet, cette salutation supplémentaire sera ajoutée après la salutation du métier et de la catégorie.",
        [LID.HELP_ITEM_OVERRIDE]              =
        "Omettez la salutation du métier et de la catégorie et commencez par la salutation de l'objet.",
        [LID.HELP_GLOBAL_KEYWORDS]            = "Un message doit inclure l'un de ces termes.",
        [LID.HELP_GLOBAL_EXCLUSIONS]          = "Un message sera ignoré s'il contient l'un de ces termes.",
        [LID.SCAN_ALL_RECIPES]                = 'Scanner toutes les recettes',
        [LID.SCANNING_ENABLED]                = "La numérisation est activée car '%s' est cochée.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]               = "La numérisation est désactivée.",
        [LID.PRIMARY_KEYWORDS]                = "Mots-clés primaires",
        [LID.HELP_PRIMARY_KEYWORDS]           =
        "Tous les messages sont filtrés par ces termes, qui sont communs à tous les métiers. Un message correspondant est ensuite traité pour rechercher du contenu lié au métier.",
        [LID.HELP_CATEGORY_SECTION]           =
        "La catégorie est la section pliable contenant la recette dans la liste à gauche. 'Favoris' n'est pas une catégorie. Cela est principalement destiné aux recettes de travail du cuir toxiques qui sont plus difficiles à fabriquer. Cela pourrait également être utile au début des extensions lorsque vous ne pouvez vous spécialiser que dans une seule catégorie.",
        [LID.HELP_EXPANSION_SECTION]          =
        "Les arbres de connaissances diffèrent par extension, donc la salutation peut également différer.",
        [LID.HELP_PROFESSION_SECTION]         =
        "Du point de vue du client, il n'y a pas de différence entre les extensions. Ces termes se combinent avec la sélection de 'l'expansion primaire' pour fournir une salutation générique (par exemple 'J'ai <métier>.') lorsque nous ne pouvons pas faire correspondre quelque chose de plus spécifique.",
        [LID.RECIPE_NOT_LEARNED]              = "Vous n'avez pas appris cette recette. La numérisation est désactivée.",
        [LID.PING_SOUND_LABEL]                = "Son d'alerte",
        [LID.PING_SOUND_TOOLTIP]              = "Le son qui se joue lorsqu'un client est détecté.",
        [LID.BANNER_SIDE_LABEL]               = "Direction de la bannière",
        [LID.BANNER_SIDE_TOOLTIP]             = "La bannière se développera depuis le bouton dans cette direction.",
        Left                                  = "Gauche",
        Right                                 = "Droite",
        Minute                                = "Minute",
        Minutes                               = "Minutes",
        Second                                = "Seconde",
        Seconds                               = "Secondes",
        Millisecond                           = "Milliseconde",
        Milliseconds                          = "Millisecondes",
        Version                               = "Nouveau dans",
        ["CraftScan Release Notes"]           = "Notes de version de CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]          = "Délai d'attente client",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]        = "Renvoie automatiquement les clients après ce nombre de minutes.",
        [LID.BANNER_TIMEOUT_LABEL]            = "Délai d'attente de la bannière",
        [LID.BANNER_TIMEOUT_TOOLTIP]          =
        "La bannière de notification client restera affichée pendant cette durée après qu'une correspondance ait été détectée.",
        ["All crafters"]                      = "Tous les fabricants",
        ["Crafter Name"]                      = "Nom du fabricant",
        ["Profession"]                        = "Métier",
        ["Customer Name"]                     = "Nom du client",
        ["Replies"]                           = "Réponses",
        ["Keywords"]                          = "Mots-clés",
        ["Profession greeting"]               = "Salutation du métier",
        ["Category greeting"]                 = "Salutation de la catégorie",
        ["Item greeting"]                     = "Salutation de l'objet",
        ["Primary expansion"]                 = "Expansion primaire",
        ["Override greeting"]                 = "Remplacement de la salutation",
        ["Excluded keywords"]                 = "Mots-clés exclus",
        [LID.EXCLUSION_INSTRUCTIONS]          =
        "Ne faites pas correspondre les messages contenant ces jetons séparés par des virgules.",
        [LID.KEYWORD_INSTRUCTIONS]            =
        "Faites correspondre les messages contenant l'un de ces mots-clés séparés par des virgules.",
        [LID.GREETING_INSTRUCTIONS]           = "Une salutation à envoyer aux clients recherchant une fabrication.",
        [LID.GLOBAL_INCLUSION_DEFAULT]        = "LF, LFC, WTB, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]        = "LFW, WTS, LF work",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]  = "BS, Forgeron, Armurier, Forgeron d'armes",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING] = "TC, Travail du cuir, Travailleur du cuir",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]        = "Alch, Alchimiste, Pierre",
        [LID.DEFAULT_KEYWORDS_TAILORING]      = "Tailleur",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]    = "Ingénieur, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]     = "Enchanteur, Blason",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]  = "JJ, Joaillier",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]    = "Calligraphie, Calligraphe, Scribe",

        -- Notes de version
        [LID.RN_WELCOME]                      = "Bienvenue dans CraftScan!",
        [LID.RN_WELCOME + 1]                  =
        "Cet addon analyse la discussion à la recherche de messages ressemblant à des demandes de fabrication. Si la configuration indique que vous pouvez fabriquer l'objet demandé, une notification sera déclenchée et les informations du client seront stockées pour faciliter la communication.",

        [LID.RN_INITIAL_SETUP]                = "Configuration initiale",
        [LID.RN_INITIAL_SETUP + 1]            =
        "Pour commencer, ouvrez un métier et cliquez sur le nouveau bouton 'Afficher CraftScan' en bas.",
        [LID.RN_INITIAL_SETUP + 2]            =
        "Faites défiler jusqu'au bas de cette nouvelle fenêtre et remontez. Les choses que vous avez rarement besoin de changer sont en bas, mais ce sont les réglages auxquels il faut d'abord faire attention.",
        [LID.RN_INITIAL_SETUP + 3]            =
        "Cliquez sur l'icône d'aide dans le coin supérieur gauche de la fenêtre si vous avez besoin d'explications sur une entrée quelconque.",

        [LID.RN_INITIAL_TESTING]              = "Tests initiaux",
        [LID.RN_INITIAL_TESTING + 1]          =
        "Une fois configuré, saisissez un message dans le chat /dire, tel que 'LF BS' pour la forge, en supposant que les mots-clés 'LF' et 'BS' sont activés. Une notification devrait apparaître.",
        [LID.RN_INITIAL_TESTING + 2]          =
        "Cliquez sur la notification pour envoyer immédiatement une réponse, cliquez avec le bouton droit pour rejeter le client, ou cliquez sur le bouton de métier circulaire lui-même pour ouvrir la fenêtre des commandes.",
        [LID.RN_INITIAL_TESTING + 3]          =
        "Les notifications en double sont supprimées sauf si elles ont déjà été rejetées, alors cliquez avec le bouton droit sur votre notification de test pour la rejeter si vous souhaitez réessayer.",

        [LID.RN_MANAGING_CRAFTERS]            = "Gestion de vos fabricants",
        [LID.RN_MANAGING_CRAFTERS + 1]        =
        "La liste de gauche de la fenêtre des commandes répertorie vos fabricants. Cette liste se remplira au fur et à mesure que vous vous connecterez à vos différents personnages et configurerez leurs métiers. Vous pouvez sélectionner quels personnages doivent être scannés en permanence, ainsi que si les notifications visuelles et auditives sont activées pour chacun de vos fabricants.",

        [LID.RN_MANAGING_CUSTOMERS]           = "Gestion des clients",
        [LID.RN_MANAGING_CUSTOMERS + 1]       =
        "La partie droite de la fenêtre des commandes se remplira avec les commandes de fabrication détectées dans la discussion. Cliquez sur une ligne pour envoyer la salutation si vous ne l'avez pas déjà fait à partir de la bannière contextuelle. Cliquez à nouveau pour ouvrir un chuchotement au client. Cliquez avec le bouton droit pour rejeter la ligne.",
        [LID.RN_MANAGING_CUSTOMERS + 2]       =
        "Les lignes de ce tableau persisteront sur tous les personnages, vous pouvez donc passer à un alter et cliquer à nouveau sur le client pour restaurer la communication. Les lignes expirent après 10 minutes par défaut. Cette durée peut être configurée dans la page de paramètres principale (Échap -> Options -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]       =
        "Espérons que la plupart du tableau est explicite. La colonne 'Réponses' dispose de 3 icônes. La coche ou la croix de gauche indique si vous avez envoyé un message au client. La coche ou la croix de droite indique si le client a répondu. La bulle de discussion est un bouton qui ouvrira une fenêtre de chuchotement temporaire avec le client et la remplira avec votre historique de discussion.",

        [LID.RN_KEYBINDS]                     = "Raccourcis clavier",
        [LID.RN_KEYBINDS + 1]                 =
        "Des raccourcis clavier sont disponibles pour ouvrir la page des commandes, répondre au dernier client et rejeter le dernier client. Recherchez 'CraftScan' pour trouver tous les paramètres disponibles.",

        [LID.RN_CLEANUP]                      = "Nettoyage de la Configuration",
        [LID.RN_CLEANUP + 1]                  =
        "Vos artisans sur le côté gauche de la page 'Ordres de Chat' ont maintenant un menu contextuel lorsque vous faites un clic droit. Utilisez ce menu pour garder la liste propre et supprimer les personnages/métiers obsolètes.",
        ["Disable"]                           = "Désactiver",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]      =
        "Supprimez définitivement toutes les données %s enregistrées pour %s.\n\nUn bouton 'Activer CraftScan' sera présent sur la page du métier pour l'activer à nouveau avec les paramètres par défaut.\n\nUtilisez ceci si vous souhaitez continuer à utiliser le métier, mais sans l'interaction de CraftScan (par exemple, lorsque vous avez l'Alchimie sur tous les rerolls pour les flacons longs).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]           = "Tapez 'DELETE' pour continuer :",
        [LID.SCANNER_CONFIG_DISABLED]         = "Activer CraftScan",

        ["Cleanup"]                           = "Nettoyer",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]     =
        "Supprimez définitivement toutes les données %s enregistrées pour %s.\n\nLe métier sera laissé dans un état comme s'il n'avait jamais été configuré. Il suffit d'ouvrir à nouveau le métier pour restaurer une configuration par défaut.\n\nUtilisez ceci si vous souhaitez réinitialiser complètement un métier, avez supprimé le personnage ou avez abandonné un métier.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]          = "Tapez 'CLEANUP' pour continuer :",
        ["Primary Crafter"]                   = "Artisan Principal",
        [LID.PRIMARY_CRAFTER_TOOLTIP]         =
        "Marquez %s comme votre artisan principal pour %s. Cet artisan sera priorisé sur les autres s'il y a plusieurs correspondances avec la même demande.",
        ["Chat History"]                      = "Historique de chat avec %s", -- customer, left-click-help
        ["Greet Help"]                        = "|cffffd100Clic gauche : Saluer le client%s|r",
        ["Chat Help"]                         = "|cffffd100Clic gauche : Ouvrir un chuchotement|r",
        ["Chat Override"]                     = "|cffffd100Clic du milieu : Ouvrir un chuchotement%s|r",
        ["Dismiss"]                           = "|cffffd100Clic droit : Ignorer%s|r",
        ["Proposed Greeting"]                 = "Salutation proposée :",
        [LID.CHAT_BUTTON_BINDING_NAME]        = "Client Bannière Chuchotement",
        ["Customer Request"]                  = "Demande de %s",

    }
end
