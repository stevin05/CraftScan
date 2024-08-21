local CraftScan = select(2, ...)

CraftScan.LOCAL_ES = {}

function CraftScan.LOCAL_ES:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        -- I eventually got tired of the whole LID enum tedium copy/pasted from
        -- CraftSim, so newer short ones are just the raw English string as the
        -- key, which is easier to read in the code anyway.
        ["CraftScan"]                                 = "CraftScan",
        [LID.CRAFT_SCAN]                              = "CraftScan",
        [LID.CHAT_ORDERS]                             = "Chat-Aufträge",
        [LID.DISABLE_ADDONS]                          = "Addons deaktivieren",
        [LID.RENABLE_ADDONS]                          = "Addons reaktivieren",
        [LID.DISABLE_ADDONS_TOOLTIP]                  =
        "Speichern Sie Ihre Addon-Liste und deaktivieren Sie sie dann, um schnell zu einem anderen Charakter zu wechseln. Dieser Button kann erneut geklickt werden, um die Addons jederzeit wieder zu aktivieren.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]               = "Ich kann %s herstellen.",     -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]             = "Mein Twink, %s, kann %s herstellen.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                    = "das",
        [LID.GREETING_I_HAVE_PROF]                    = "Ich habe %s.",                -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]                   = "Mein Twink, %s, hat %s.",     -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                     = "Lassen Sie es mich wissen, wenn Sie einen Auftrag senden, damit ich umloggen kann.",
        [LID.MAIN_BUTTON_BINDING_NAME]                = "Auftragsseite umschalten",
        [LID.GREET_BUTTON_BINDING_NAME]               = "Kunden begrüßen",
        [LID.DISMISS_BUTTON_BINDING_NAME]             = "Kunden ablehnen",
        [LID.TOGGLE_CHAT_TOOLTIP]                     = "Chat-Aufträge umschalten%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                     = "CraftScan anzeigen",
        [LID.SCANNER_CONFIG_HIDE]                     = "CraftScan ausblenden",
        [LID.CRAFT_SCAN_OPTIONS]                      = "CraftScan-Optionen",
        [LID.ITEM_SCAN_CHECK]                         = "Chat nach diesem Gegenstand durchsuchen",
        [LID.HELP_PROFESSION_KEYWORDS]                =
        "Eine Nachricht muss einen dieser Begriffe enthalten. Um eine Nachricht wie 'LF Lariat' zu erkennen, sollte 'lariet' hier aufgelistet sein. Um einen Gegenstandslink für den Elementar-Lariat in der Antwort zu erzeugen, sollte 'lariat' auch in den Gegenstandskonfigurations-Keywords für den Elementar-Lariat enthalten sein.",
        [LID.HELP_PROFESSION_EXCLUSIONS]              =
        "Eine Nachricht wird ignoriert, wenn sie einen dieser Begriffe enthält, auch wenn sie ansonsten übereinstimmt. Um zu vermeiden, auf 'LF JC Lariat' mit 'Ich habe Juwelenschleifen' zu antworten, wenn Sie das Lariat-Rezept nicht haben, sollte 'lariat' hier aufgeführt sein.",
        [LID.HELP_SCAN_ALL]                           = "Scannen aller Rezepte derselben Erweiterung wie das ausgewählte Rezept aktivieren.",
        [LID.HELP_PRIMARY_EXPANSION]                  =
        "Verwenden Sie diese Begrüßung, wenn Sie auf eine allgemeine Anfrage wie 'LF Schmied' antworten. Wenn eine neue Erweiterung erscheint, möchten Sie wahrscheinlich eine Begrüßung, die beschreibt, welche Gegenstände Sie herstellen können, anstatt zu sagen, dass Sie das maximale Wissen aus der vorherigen Erweiterung haben.",
        [LID.HELP_EXPANSION_GREETING]                 =
        "Ein anfängliches Intro wird immer generiert, das besagt, dass Sie den Gegenstand herstellen können. Dieser Text wird daran angehängt. Neue Zeilen sind erlaubt und werden als separate Antwort gesendet. Wenn der Text zu lang ist, wird er in mehrere Antworten aufgeteilt.",
        [LID.HELP_CATEGORY_KEYWORDS]                  =
        "Wenn ein Beruf erkannt wurde, überprüfen Sie diese kategoriespezifischen Keywords, um die Begrüßung zu verfeinern. Zum Beispiel könnten Sie 'giftig' oder 'schleimig' hier eintragen, um Lederverarbeitungsmuster zu erkennen, die den Altar der Verwesung erfordern.",
        [LID.HELP_CATEGORY_GREETING]                  =
        "Wenn diese Kategorie in einer Nachricht erkannt wird, sei es durch ein Keyword oder einen Gegenstandslink, wird diese zusätzliche Begrüßung nach der Berufsbegrüßung angehängt.",
        [LID.HELP_CATEGORY_OVERRIDE]                  =
        "Lassen Sie die Berufsbegrüßung weg und beginnen Sie mit der Kategoriespezifischen Begrüßung.",
        [LID.HELP_ITEM_KEYWORDS]                      =
        "Wenn ein Beruf erkannt wurde, überprüfen Sie diese gegenstandsspezifischen Keywords, um die Begrüßung zu verfeinern. Wenn sie übereinstimmen, enthält die Antwort den Gegenstandslink anstelle der allgemeinen Berufsbegrüßung. Wenn 'lariat' ein Berufsschlüsselwort, aber kein Gegenstandsschlüsselwort ist, sagt die Antwort 'Ich habe Juwelenschleifen.' Wenn 'lariat' nur ein Gegenstandsschlüsselwort ist, wird 'LF Lariat' nicht als Beruf erkannt und nicht als Treffer gewertet. Wenn 'lariat' sowohl ein Berufs- als auch ein Gegenstandsschlüsselwort ist, lautet die Antwort auf 'LF Lariat' 'Ich kann [Elementar-Lariat] herstellen.'",
        [LID.HELP_ITEM_GREETING]                      =
        "Wenn dieser Gegenstand in einer Nachricht erkannt wird, sei es durch ein Keyword oder den Gegenstandslink, wird diese zusätzliche Begrüßung nach der Berufs- und Kategoriespezifischen Begrüßung angehängt.",
        [LID.HELP_ITEM_OVERRIDE]                      =
        "Lassen Sie die Berufs- und Kategoriespezifische Begrüßung weg und beginnen Sie mit der Gegenstandsspezifischen Begrüßung.",
        [LID.HELP_GLOBAL_KEYWORDS]                    = "Eine Nachricht muss einen dieser Begriffe enthalten.",
        [LID.HELP_GLOBAL_EXCLUSIONS]                  = "Eine Nachricht wird ignoriert, wenn sie einen dieser Begriffe enthält.",
        [LID.SCAN_ALL_RECIPES]                        = 'Alle Rezepte scannen',
        [LID.SCANNING_ENABLED]                        = "Das Scannen ist aktiviert, weil '%s' ausgewählt ist.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                       = "Das Scannen ist deaktiviert.",
        [LID.PRIMARY_KEYWORDS]                        = "Primäre Schlüsselwörter",
        [LID.HELP_PRIMARY_KEYWORDS]                   =
        "Alle Nachrichten werden durch diese Begriffe gefiltert, die für alle Berufe gemeinsam sind. Eine übereinstimmende Nachricht wird weiterverarbeitet, um berufsbezogene Inhalte zu suchen.",
        [LID.HELP_CATEGORY_SECTION]                   =
        "Die Kategorie ist der zusammenklappbare Abschnitt, der das Rezept in der Liste links enthält. 'Favoriten' ist keine Kategorie. Dies ist hauptsächlich für Dinge wie die giftigen Lederverarbeitungsrezepte gedacht, die schwieriger herzustellen sind. Es könnte auch nützlich sein zu Beginn von Erweiterungen, wenn Sie sich nur auf eine Kategorie spezialisieren können.",
        [LID.HELP_EXPANSION_SECTION]                  =
        "Wissensbäume unterscheiden sich je nach Erweiterung, daher kann auch die Begrüßung unterschiedlich sein.",
        [LID.HELP_PROFESSION_SECTION]                 =
        "Aus Kundensicht gibt es keinen Unterschied zwischen Erweiterungen. Diese Begriffe kombinieren sich mit der Auswahl der 'Primären Erweiterung', um eine allgemeine Begrüßung zu bieten (z.B. 'Ich habe <Beruf>.'), wenn wir nichts Spezifischeres erkennen können.",
        [LID.RECIPE_NOT_LEARNED]                      = "Sie haben dieses Rezept nicht gelernt. Das Scannen ist deaktiviert.",
        [LID.PING_SOUND_LABEL]                        = "Alarmton",
        [LID.PING_SOUND_TOOLTIP]                      = "Der Ton, der abgespielt wird, wenn ein Kunde erkannt wird.",
        [LID.BANNER_SIDE_LABEL]                       = "Banner-Richtung",
        [LID.BANNER_SIDE_TOOLTIP]                     = "Das Banner wird von der Schaltfläche in diese Richtung wachsen.",
        Left                                          = "Links",
        Right                                         = "Rechts",
        Minute                                        = "Minute",
        Minutes                                       = "Minuten",
        Second                                        = "Sekunde",
        Seconds                                       = "Sekunden",
        Millisecond                                   = "Millisekunde",
        Milliseconds                                  = "Millisekunden",
        Version                                       = "Neu in",
        ["CraftScan Release Notes"]                   = "CraftScan Release Notes",
        [LID.CUSTOMER_TIMEOUT_LABEL]                  = "Kunden-Timeout",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]                = "Kunden automatisch nach dieser Anzahl von Minuten abweisen.",
        [LID.BANNER_TIMEOUT_LABEL]                    = "Banner-Timeout",
        [LID.BANNER_TIMEOUT_TOOLTIP]                  =
        "Das Kundenbenachrichtigungsbanner bleibt für diese Dauer nach Erkennung eines Treffers angezeigt.",
        ["All crafters"]                              = "Alle Handwerker",
        ["Crafter Name"]                              = "Handwerkername",
        ["Profession"]                                = "Beruf",
        ["Customer Name"]                             = "Kundenname",
        ["Replies"]                                   = "Antworten",
        ["Keywords"]                                  = "Schlüsselwörter",
        ["Profession greeting"]                       = "Berufsbegrüßung",
        ["Category greeting"]                         = "Kategoriebegrüßung",
        ["Item greeting"]                             = "Gegenstandsbegrüßung",
        ["Primary expansion"]                         = "Primäre Erweiterung",
        ["Override greeting"]                         = "Begrüßung überschreiben",
        ["Excluded keywords"]                         = "Ausgeschlossene Schlüsselwörter",
        [LID.EXCLUSION_INSTRUCTIONS]                  =
        "Nachrichten, die diese durch Kommas getrennten Tokens enthalten, nicht übereinstimmen.",
        [LID.KEYWORD_INSTRUCTIONS]                    =
        "Nachrichten, die eines dieser durch Kommas getrennten Schlüsselwörter enthalten, übereinstimmen.",
        [LID.GREETING_INSTRUCTIONS]                   = "Eine Begrüßung, die an Kunden gesendet wird, die eine Herstellung suchen.",
        [LID.GLOBAL_INCLUSION_DEFAULT]                = "LF, LFC, WTB, neuherstellen",
        [LID.GLOBAL_EXCLUSION_DEFAULT]                = "LFW, WTS, LF Arbeit",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]          = "BS, Schmied, Waffenschmied, Rüstungsschmied",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]         = "LW, Lederverarbeitung, Lederarbeiter",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]                = "Alch, Alchemist, Stein",
        [LID.DEFAULT_KEYWORDS_TAILORING]              = "Schneider",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]            = "Ingenieur, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]             = "Verzauberer, Wappen",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]          = "JC, Juwelenschleifer",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]            = "Inschriftenkunde, Schreiber",

        -- Release notes
        [LID.RN_WELCOME]                              = "Willkommen bei CraftScan!",
        [LID.RN_WELCOME + 1]                          =
        "Dieses Addon scannt den Chat nach Nachrichten, die wie Anfragen für das Herstellen aussehen. Wenn die Konfiguration anzeigt, dass Sie den gewünschten Gegenstand herstellen können, wird eine Benachrichtigung ausgelöst und die Kundeninformation gespeichert, um die Kommunikation zu erleichtern.",

        [LID.RN_INITIAL_SETUP]                        = "Erste Einrichtung",
        [LID.RN_INITIAL_SETUP + 1]                    =
        "Um zu beginnen, öffnen Sie einen Beruf und klicken Sie auf die neue Schaltfläche 'CraftScan anzeigen' unten.",
        [LID.RN_INITIAL_SETUP + 2]                    =
        "Scrollen Sie bis zum unteren Rand dieses neuen Fensters und arbeiten Sie sich nach oben. Die Dinge, die Sie selten ändern müssen, befinden sich unten, aber diese Einstellungen sind zuerst wichtig.",
        [LID.RN_INITIAL_SETUP + 3]                    =
        "Klicken Sie auf das Hilfe-Symbol in der oberen linken Ecke des Fensters, wenn Sie eine Erklärung zu einem Eingabefeld benötigen.",

        [LID.RN_INITIAL_TESTING]                      = "Erste Tests",
        [LID.RN_INITIAL_TESTING + 1]                  =
        "Sobald Sie konfiguriert sind, geben Sie eine Nachricht im /say-Chat ein, wie 'LF BS' für Schmiedekunst, vorausgesetzt, Sie haben die 'LF' und 'BS' Schlüsselwörter beibehalten. Eine Benachrichtigung sollte erscheinen.",
        [LID.RN_INITIAL_TESTING + 2]                  =
        "Klicken Sie auf die Benachrichtigung, um sofort eine Antwort zu senden, klicken Sie mit der rechten Maustaste, um den Kunden abzulehnen, oder klicken Sie auf die runde Berufsschaltfläche selbst, um das Auftragsfenster zu öffnen.",
        [LID.RN_INITIAL_TESTING + 3]                  =
        "Doppelte Benachrichtigungen werden unterdrückt, es sei denn, sie wurden bereits abgelehnt, daher klicken Sie mit der rechten Maustaste auf Ihre Testbenachrichtigung, um sie abzulehnen, wenn Sie es erneut versuchen möchten.",

        [LID.RN_MANAGING_CRAFTERS]                    = "Verwalten Ihrer Handwerker",
        [LID.RN_MANAGING_CRAFTERS + 1]                =
        "Die linke Seite des Auftragsfensters listet Ihre Handwerker auf. Diese Liste wird gefüllt, während Sie sich bei Ihren verschiedenen Charakteren einloggen und deren Berufe konfigurieren. Sie können jederzeit auswählen, welche Charaktere aktiv gescannt werden sollen und ob die visuellen und akustischen Benachrichtigungen für jeden Ihrer Handwerker aktiviert sind.",

        [LID.RN_MANAGING_CUSTOMERS]                   = "Verwalten der Kunden",
        [LID.RN_MANAGING_CUSTOMERS + 1]               =
        "Die rechte Seite des Auftragsfensters wird mit im Chat erkannten Herstellungsaufträgen gefüllt. Klicken Sie auf eine Zeile, um die Begrüßung zu senden, wenn Sie dies nicht bereits über das Pop-up-Banner getan haben. Klicken Sie erneut, um ein Flüstern an den Kunden zu öffnen. Klicken Sie mit der rechten Maustaste, um die Zeile abzulehnen.",
        [LID.RN_MANAGING_CUSTOMERS + 2]               =
        "Zeilen in dieser Tabelle bleiben über alle Charaktere hinweg erhalten, sodass Sie zu einem Twink umloggen und dann erneut auf den Kunden klicken können, um die Kommunikation wiederherzustellen. Zeilen laufen standardmäßig nach 10 Minuten ab. Diese Dauer kann auf der Hauptseite der Einstellungen konfiguriert werden (Esc -> Optionen -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]               =
        "Hoffentlich ist die Tabelle weitgehend selbsterklärend. Die 'Antworten'-Spalte hat 3 Symbole. Das linke X oder Häkchen zeigt an, ob Sie dem Kunden eine Nachricht gesendet haben. Das rechte X oder Häkchen zeigt an, ob der Kunde geantwortet hat. Die Sprechblase ist eine Schaltfläche, die ein temporäres Flüsterfenster mit dem Kunden öffnet und es mit Ihrem Chatverlauf füllt.",

        [LID.RN_KEYBINDS]                             = "Tastenkombinationen",
        [LID.RN_KEYBINDS + 1]                         =
        "Tastenkombinationen sind verfügbar, um die Auftragsseite zu öffnen, auf den neuesten Kunden zu antworten und den neuesten Kunden abzulehnen. Suchen Sie nach 'CraftScan', um alle verfügbaren Einstellungen zu finden.",
        [LID.RN_CLEANUP]                              = "Limpieza de Configuración",
        [LID.RN_CLEANUP + 1]                          =
        "Tus artesanos en el lado izquierdo de la página 'Órdenes de Chat' ahora tienen un menú contextual al hacer clic derecho. Usa este menú para mantener la lista limpia y eliminar personajes/profesiones obsoletos.",
        ["Disable"]                                   = "Desactivar",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]              =
        "Elimina permanentemente cualquier dato %s guardado para %s.\n\nUn botón 'Habilitar CraftScan' estará presente en la página de la profesión para habilitarlo nuevamente con la configuración predeterminada.\n\nUsa esto si deseas continuar usando la profesión, pero sin la interacción de CraftScan (por ejemplo, cuando tienes Alquimia en todos los personajes secundarios para frascos largos).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]                   = "Escribe 'DELETE' para continuar:",
        [LID.SCANNER_CONFIG_DISABLED]                 = "Habilitar CraftScan",

        ["Cleanup"]                                   = "Limpiar",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]             =
        "Elimina permanentemente cualquier dato %s guardado para %s.\n\nLa profesión quedará en un estado como si nunca hubiera sido configurada. Simplemente abrir la profesión nuevamente restaurará una configuración predeterminada.\n\nUsa esto si deseas restablecer completamente una profesión, has eliminado el personaje o has abandonado la profesión.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]                  = "Escribe 'CLEANUP' para continuar:",

        ["Primary Crafter"]                           = "Artesano Principal",
        [LID.PRIMARY_CRAFTER_TOOLTIP]                 =
        "Marca %s como tu artesano principal para %s. Este artesano tendrá prioridad sobre otros si hay varias coincidencias con la misma solicitud.",
        ["Chat History"]                              = "Historial de chat con %s", -- customer, left-click-help
        ["Greet Help"]                                = "|cffffd100Clic izquierdo: Saludar al cliente%s|r",
        ["Chat Help"]                                 = "|cffffd100Clic izquierdo: Abrir susurro|r",
        ["Chat Override"]                             = "|cffffd100Clic medio: Abrir susurro%s|r",
        ["Dismiss"]                                   = "|cffffd100Clic derecho: Descartar%s|r",
        ["Proposed Greeting"]                         = "Saludo propuesto:",
        [LID.CHAT_BUTTON_BINDING_NAME]                = "Susurro al Cliente de la Bandera",
        ["Customer Request"]                          = "Solicitud de %s",

        [LID.ADDON_WHITELIST_LABEL]                   = "Lista blanca de addons",
        [LID.ADDON_WHITELIST_TOOLTIP]                 =
        "Cuando presionas el botón para desactivar temporalmente todos los addons, mantén los addons seleccionados aquí activados. CraftScan siempre estará habilitado. Mantén solo lo que necesitas para fabricar eficazmente.",
        [LID.MULTI_SELECT_BUTTON_TEXT]                = "%d seleccionados", -- Count

        [LID.ACCOUNT_LINK_DESC]                       =
        "Comparte artesanos entre varias cuentas.\n\nAl iniciar sesión o después de un cambio de configuración, CraftScan propagará la información más reciente entre los artesanos configurados en cualquiera de las cuentas para garantizar que ambos lados de una cuenta vinculada estén siempre sincronizados.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]           = "Introduce el nombre de un personaje en línea en tu otra cuenta:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]            = "Introduce un apodo para la otra cuenta:",
        ["Link Account"]                              = "Vincular cuenta",
        ["Linked Accounts"]                           = "Cuentas vinculadas",
        ["Accept Linked Account"]                     = "Aceptar cuenta vinculada",
        ["Delete Linked Account"]                     = "Eliminar cuenta vinculada",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]            =
        "'%s' ha enviado una solicitud para vincular cuentas.\n\nNO ACEPTES ESTO SI NO LO ENVIASTE TÚ.\n\nIntroduce un apodo para la otra cuenta:",
        [LID.ACCOUNT_LINK_ACCEPT_DST_LABEL]           =
        "|cFF00FF00Tienes una solicitud pendiente para vincular cuentas con %s. Haz clic aquí para aceptarla.|r",
        ["OK"]                                        = "OK",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_INFO]            =
        "Para completar la vinculación de cuentas, debes aceptar la solicitud en la otra cuenta. El botón 'Vincular cuenta' se reemplazará con un botón 'Aceptar cuenta vinculada' para completar la operación. Si hay un error, se mostrará junto al botón 'Vincular cuenta'.",
        [LID.ACCOUNT_LINK_ACCEPT_SRC_LABEL]           =
        "|cFFFFA500Esperando que %s acepte la solicitud de vinculación de cuentas.|r",
        [LID.VERSION_MISMATCH]                        =
        "|cFFFF0000Error: incompatibilidad de versión de CraftScan. Versión de la otra cuenta: %s. Tu versión: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]                  =
        "Este personaje pertenece a una cuenta vinculada. Solo puede deshabilitarse en la cuenta a la que pertenece. Puedes eliminar completamente este personaje a través de 'Limpieza', pero necesitarás hacerlo manualmente en todas las cuentas vinculadas, o será restaurado por una cuenta vinculada al iniciar sesión.",
        [LID.REMOTE_CRAFTER_SUMMARY]                  = "Sincronizado con %s.",
        ["proxy_send_enabled"]                        = "Órdenes proxy",
        ["proxy_send_enabled_tooltip"]                = "Cuando se detecta un pedido de cliente, envíalo a cuentas vinculadas.",
        ["proxy_receive_enabled"]                     = "Recibir órdenes proxy",
        ["proxy_receive_enabled_tooltip"]             =
        "Cuando otra cuenta detecta y envía un pedido de cliente, esta cuenta lo recibirá. El botón CraftScan se mostrará para mostrar la alerta si es necesario.",
        [LID.LINK_ACTIVE]                             = "|cFF00FF00%s (visto por última vez %s)|r", -- Crafter, Time
        [LID.LINK_DEAD]                               = "|cFFFF0000Desconectado|r",
        [LID.ACCOUNT_LINK_DELETE_INFO]                =
        "Elimina el enlace a '%s' y todos los personajes importados. Esta cuenta dejará de comunicarse con la otra parte. La otra parte seguirá intentando establecer conexiones hasta que el enlace también se elimine manualmente allí.\n\nArtesanos importados que se eliminarán:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]                   =
        "Por defecto, el personaje que vinculaste inicialmente, cualquier artesano y cualquier personaje que haya iniciado sesión mientras esta cuenta estaba en línea son conocidos por CraftScan. Agrega personajes adicionales propiedad de la otra cuenta para que también puedan usarse. '/reload' para forzar la sincronización con el nuevo personaje si está en línea.",
        ["Backup characters"]                         = "Personajes adicionales",
        ["Unlink account"]                            = "Desvincular cuenta",
        ["Add"]                                       = "Agregar",
        ["Remove"]                                    = "Eliminar",
        ["Rename account"]                            = "Renombrar cuenta",
        ["New name"]                                  = "Nuevo nombre:",

        [LID.RN_LINKED_ACCOUNTS]                      = "Cuentas vinculadas",
        [LID.RN_LINKED_ACCOUNTS + 1]                  =
        "Vincula varias cuentas de WoW para compartir información de fabricación y escanear desde cualquier cuenta.",
        [LID.RN_LINKED_ACCOUNTS + 2]                  =
        "Opcionalmente, envía pedidos de clientes por proxy de una cuenta a las otras para que puedas estacionar una cuenta de prueba en la ciudad mientras tu personaje principal está fuera.",
        [LID.RN_LINKED_ACCOUNTS + 3]                  =
        "Para comenzar, haz clic en el botón 'Vincular cuenta' en la esquina inferior izquierda de la ventana de CraftScan y sigue las instrucciones.",
        [LID.RN_LINKED_ACCOUNTS + 4]                  = "Demostración: https://www.youtube.com/watch?v=x1JLEph6t_c",
        ["Open Settings"]                             = "Abrir configuración",
        ["Customize Greeting"]                        = "Personalizar saludo",
        [LID.CUSTOM_GREETING_INFO]                    =
        "CraftScan utiliza estas frases para crear el saludo inicial enviado a los clientes dependiendo de la situación. Sobrescriba algunas o todas a continuación para crear su propio saludo.",
        ["Default"]                                   = "Predeterminado",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS]            =
        "Error: Se esperaban %d o menos marcadores de posición %%s. El texto proporcionado tiene %d.",
        [LID.WRONG_TYPE_OF_PLACEHOLDERS]              = "Error: Solo se admiten marcadores de posición %s.",

        ["item link"]                                 = "enlace del objeto",
        ["alt name and then item link"]               = "nombre alternativo y luego enlace del objeto",
        ["profession name"]                           = "nombre de la profesión",
        ["alt name and then profession name"]         = "nombre alternativo y luego el nombre de la profesión",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS_SUGGESTION] =
        "Este texto debe contener %d o menos marcadores de posición %%s para contener el %s. Has incluido %d.\n\nCraftScan funcionará con menos marcadores de posición, pero probablemente quieras incluirlos para contexto.",

    }
end
