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
        [LID.GREETING_I_CAN_CRAFT_ITEM]               = "Ich kann {item} herstellen.",             -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]             = "Mein Twink, {crafter}, kann {item} herstellen.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                    = "das",
        [LID.GREETING_I_HAVE_PROF]                    = "Ich habe {profession}.",                        -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]                   = "Mein Twink, {crafter}, hat {profession}.",             -- Crafter Name, Profession Name
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
        ["OK"]                                        = "OK",
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
        [LID.MISSING_PLACEHOLDERS]            =
        "No has incluido %s. CraftScan funcionará con menos marcadores de posición, pero probablemente quieras incluirlos para contexto.",
        [LID.EXTRA_PLACEHOLDERS]              = "Error: %s no son marcadores de posición válidos.",
       
        ["Pixels"]                                    = "Píxeles",
        ["Show button height"]                        = "Mostrar altura del botón",
        ["Alert icon scale"]                          = "Escala del ícono de alerta",
        ["Total"]                                     = "Total",
        ["Repeat"]                                    = "Repetir",
        ["Avg Per Day"]                               = "Promedio/Día",
        ["Peak Per Hour"]                             = "Pico/Hora",
        ["Median Per Customer"]                       = "Mediana/Cliente",
        ["Median Per Customer Filtered"]              = "Mediana/Cliente Filtrado",
        ["No analytics data"]                         = "No hay datos analíticos",
        ["Reset Analytics"]                           = "Restablecer análisis",
        ["Analytics Options"]                         = "Opciones de análisis",

        ["1 minute"]                                  = "1 minuto",
        ["15 minutes "]                               = "15 minutos",
        ["1 hour"]                                    = "1 hora",
        ["1 day"]                                     = "1 día",
        ["1 week "]                                   = "1 semana",
        ["30 days"]                                   = "30 días",
        ["180 days"]                                  = "180 días",
        ["1 year"]                                    = "1 año",
        ["Clear recent data"]                         = "Borrar datos recientes",
        ["Newer than"]                                = "Más reciente que",
        ["Clear old data"]                            = "Borrar datos antiguos",
        ["Older than"]                                = "Más antiguo que",
        ["1 Minute Bins"]                             = "Intervalos de 1 minuto",
        ["5 Minute Bins"]                             = "Intervalos de 5 minutos",
        ["10 Minute Bins"]                            = "Intervalos de 10 minutos",
        ["30 Minute Bins"]                            = "Intervalos de 30 minutos",
        ["1 Hour Bins"]                               = "Intervalos de 1 hora",
        ["6 Hour Bins"]                               = "Intervalos de 6 horas",
        ["12 Hour Bins"]                              = "Intervalos de 12 horas",
        ["24 Hour Bins"]                              = "Intervalos de 24 horas",
        ["1 Week Bins"]                               = "Intervalos de 1 semana",

        [LID.ANALYTICS_ITEM_TOOLTIP]                  =
        "Los ítems se emparejan asegurando que un mensaje coincida con las palabras clave de inclusión y exclusión globales, y luego buscando el ícono de calidad en un enlace de ítem. No hay una lista global de ítems creados ni forma de determinar si un itemID es creado, así que esto es lo mejor que podemos hacer.",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]            =
        "No hay una búsqueda inversa de un ítem al oficio que lo crea. Si uno de tus personajes puede crear el ítem, se asigna automáticamente el oficio. Cuando se abre un oficio, se asignan los ítems desconocidos pertenecientes a ese oficio. También puedes asignar manualmente el oficio.",
        [LID.ANALYTICS_TOTAL_TOOLTIP]                 =
        "El número total de veces que se ha solicitado este ítem. Las solicitudes duplicadas del mismo cliente dentro de la misma hora no se incluyen.",
        [LID.ANALYTICS_REPEAT_TOOLTIP]                =
        "El número total de veces que este ítem ha sido solicitado por el mismo cliente múltiples veces dentro de la misma hora.\n\nSi este valor está cerca del total, probablemente falta suministro para este ítem.\n\nSe ignoran las solicitudes duplicadas dentro de los 15 segundos de la solicitud inicial.",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]               = "El número promedio de solicitudes totales para este ítem por día.",
        [LID.ANALYTICS_PEAK_TOOLTIP]                  = "El número máximo de solicitudes para este ítem por hora.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]                =
        "El número mediano de veces que el mismo cliente ha solicitado el mismo ítem dentro de la misma hora.\n\nUn valor de 1 indica que al menos la mitad de todas las solicitudes están siendo satisfechas por alguien y la demanda de este ítem probablemente está cubierta.\n\nSi este valor es alto, probablemente sea un buen ítem para considerar fabricar.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]       =
        "El número mediano de veces que el mismo cliente ha solicitado el mismo ítem dentro de la misma hora, filtrado para solo aquellas solicitudes donde el solicitante preguntó múltiples veces.\n\nSi este valor no es 1 pero la mediana sin filtrar es 1, eso indica que hay momentos en que la demanda no se está satisfaciendo.",
        ["Request Count"]                             = "Contador de Solicitudes",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]            =
        "'%s' ha enviado una solicitud para vincular cuentas.\n\nSe solicitaron los siguientes permisos:\n\n%s\n\nNo aceptes permisos completos a menos que tú hayas enviado la solicitud.\n\nIngresa un apodo para la otra cuenta:",
        [LID.LINKED_ACCOUNT_REJECTED]                 = "CraftScan: La solicitud de cuenta vinculada falló. Razón: %s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]            = "La cuenta objetivo rechazó la solicitud.",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]          = "Control Total",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS]     = "Sincronización de Análisis",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]           = "Solicita los siguientes permisos con la cuenta vinculada.",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]          =
        "Sincroniza todos los datos del personaje y admite todos los demás permisos también.",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]             =
        "Sincroniza solo datos analíticos entre las dos cuentas manualmente a través del menú de la cuenta. Cualquiera de las cuentas puede iniciar una sincronización bidireccional en cualquier momento. Nunca se hace automáticamente. Como no se importan personajes, solo sincronizarás con el personaje especificado aquí. Puedes agregar manualmente más alts de la cuenta vinculada desde el menú de la cuenta.",
        ["Sync Analytics"]                            = "Sincronizar Análisis",
        ["Sync Recent Analytics"]                     = "Sincronizar Análisis Recientes",
        [LID.ANALYTICS_PROF_MISMATCH]                 =
        "|cFFFF0000CraftScan: Advertencia: Desajuste de profesión de análisis. Ítem: %s. Profesión local: %s. Profesión vinculada: %s.|r",
        [LID.RN_ANALYTICS]                            = "Análisis",
        [LID.RN_ANALYTICS + 1]                        =
        "CraftScan ahora escanea el chat en busca de cualquier ítem creado combinado con tus palabras clave globales (por ejemplo, LF, recraft, etc.), incluso si no puedes crear el ítem. El tiempo se registra y los ítems detectados se muestran debajo de los pedidos habituales encontrados en el chat.",
        [LID.RN_ANALYTICS + 2]                        =
        "El concepto de 'repeticiones' se utiliza para determinar si un ítem carece de suministro. CraftScan recuerda quién solicitó qué durante la última hora, y si vuelven a solicitar lo mismo, se registra como una repetición. Los encabezados de columna de la nueva cuadrícula tienen tooltips que explican su intención.",
        [LID.RN_ANALYTICS + 3]                        =
        "Con un personaje estacionado en el chat comercial el tiempo suficiente, esto debería construir una buena visión de qué ramas del árbol de profesión valen la pena la inversión.",
        [LID.RN_ANALYTICS + 4]                        =
        "Los análisis se pueden sincronizar entre múltiples cuentas. Puedes estacionar una cuenta de prueba en el comercio todo el día para recopilar datos y luego sincronizarlos con tu cuenta principal. También puedes crear un enlace de cuenta solo para análisis con un amigo, apoyando una sincronización bidireccional que fusiona tus análisis. Una vez que la colección sea grande, hay una opción para sincronizar solo los datos desde la última vez que se sincronizaron las cuentas.",
        [LID.RN_ALERT_ICON_ANCHOR]                    = "Actualizaciones de Anclaje de Ícono de Alerta",
        [LID.RN_ALERT_ICON_ANCHOR + 1]                =
        "El ícono de alerta ahora se ocultará correctamente cuando la interfaz de usuario esté oculta. El cambio movió y escaló ligeramente el ícono en mi pantalla. Si el botón se ha movido fuera de tu pantalla debido a esto, hay una opción de reinicio si haces clic derecho en el botón 'Abrir Configuración' en la parte superior derecha de la página de pedidos del chat.",
        [LID.BUSY_RIGHT_NOW]                          = "Modo Ocupado",
        [LID.GREETING_BUSY]                           = "Estoy ocupado ahora, pero puedo fabricarlo más tarde si lo envías.",
        [LID.BUSY_HELP]                               =
        "|cFFFFFFFFCuando se selecciona, agrega la saludo ocupado en tu respuesta. Edita tu saludo ocupado con el botón de abajo.\n\nEsto está destinado a ser utilizado con una segunda cuenta que procura pedidos para que puedas capturar pedidos mientras estás afuera con tu cuenta principal.\n\nSaludo ocupado actual: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                       = "Explicaciones Personalizadas",
        ["Create"]                                    = "Crear",
        ["Modify"]                                    = "Modificar",
        ["Delete"]                                    = "Eliminar",
        [LID.EXPLANATION_LABEL_DESC]                  =
        "Ingresa una etiqueta que verás al hacer clic derecho en el nombre del cliente en el chat.",
        [LID.EXPLANATION_DUPLICATE_LABEL]             = "Esta etiqueta ya está en uso.",
        [LID.EXPLANATION_TEXT_DESC]                   =
        "Ingresa un mensaje para enviar al cliente cuando se haga clic en la etiqueta. Las nuevas líneas se envían como mensajes separados. Las líneas largas se dividen para ajustarse a la longitud máxima del mensaje.",
        ["Create an Explanation"]                     = "Crear una Explicación",
        ["Save"]                                      = "Guardar",
        ["Reset"]                                     = "Restablecer",
        [LID.MANUAL_MATCHING_TITLE]                   = "Coincidencia Manual",
        [LID.MANUAL_MATCH]                            = "%s - %s", -- creador, profesión
        [LID.MANUAL_MATCHING_DESC]                    =
        "Ignora palabras clave primarias y fuerza una coincidencia para este mensaje. CraftScan intentará encontrar el creador correcto basado en el mensaje, pero si no se encuentran coincidencias, se utilizará el saludo predeterminado para el creador especificado. La coincidencia se informa a través de los medios habituales, permitiéndote hacer clic en el banner o en la fila de la tabla para enviar el saludo.",

        [LID.RN_MANUAL_MATCH]                         = "Coincidencia Manual",
        [LID.RN_MANUAL_MATCH + 1]                     =
        "El menú contextual al hacer clic derecho en un nombre de jugador en el chat ahora incluye opciones de CraftScan.",
        [LID.RN_MANUAL_MATCH + 2]                     =
        "Este menú incluye todos tus creadores y profesiones. Hacer clic en uno de estos forzará otro paso en el mensaje para buscar una coincidencia sin considerar las 'Palabras Clave Primarias' (por ejemplo, LF, WTB, recraft, etc.), en caso de que el cliente esté utilizando terminología no estándar.",
        [LID.RN_MANUAL_MATCH + 3]                     =
        "Si el mensaje aún no coincide, se forzará una coincidencia con el saludo predeterminado para el creador y la profesión que seleccionaste.",
        [LID.RN_MANUAL_MATCH + 4]                     =
        "Este clic no enviará automáticamente un mensaje al cliente. Genera la coincidencia de la manera habitual, y luego puedes inspeccionar la respuesta generada y decidir si deseas enviarla o no.",
        [LID.RN_MANUAL_MATCH + 5]                     = "(Lo siento, no hay aprendizaje automático.)",
        [LID.RN_CUSTOM_EXPLANATIONS]                  = "Explicaciones Personalizadas",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]              =
        "La página 'Pedidos de Chat' ahora incluye un botón de 'Explicaciones Personalizadas'. Las explicaciones configuradas aquí también aparecen en el menú contextual del chat, y hacer clic en ellas enviará inmediatamente la explicación.",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]              =
        "Las explicaciones se ordenan alfabéticamente, por lo que puedes numerarlas para forzar un orden deseado.",
        [LID.RN_BUSY_MODE]                            = "Modo Ocupado",
        [LID.RN_BUSY_MODE + 1]                        =
        "Esto ha estado presente durante algunas versiones, pero nunca se explicó. Hay una nueva casilla de verificación 'Modo Ocupado' en la página 'Pedidos de Chat'. Cuando se activa, agrega el saludo ocupado en tu respuesta. Edita tu saludo ocupado con el botón 'Personalizar Saludo'.",
        [LID.RN_BUSY_MODE + 2]                        =
        "Esto está destinado a ser utilizado con una segunda cuenta que proxy pedidos para que puedas recibir pedidos mientras estás fuera con tu cuenta principal, y el cliente sabrá que no puedes fabricarlo de inmediato.",
        ["Release Notes"]                             = "Notas de la Versión",
        ["Secondary Keywords"]                        = "Palabras clave secundarias",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]          =
        "Por ejemplo: 'pvp, 610, algari' o '606, 610, 636' o '590', para diferenciar la misma palabra clave en varios objetos.",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]            =
        "Después de coincidir con una palabra clave anterior, busca palabras clave secundarias para refinar la coincidencia, permitiendo diferenciar las varias artesanías del mismo tipo de objeto.",
        [LID.RN_SECONDARY_KEYWORDS]                   = "Palabras clave secundarias",
        [LID.RN_SECONDARY_KEYWORDS + 1]               =
        "Ahora los objetos admiten palabras clave secundarias para refinar una coincidencia. Cada tipo de objeto generalmente tiene una versión de Chispa, PVP y Azul. Las palabras clave secundarias pueden configurarse para diferenciarlas.",
        [LID.RN_SECONDARY_KEYWORDS + 2]               = "Ejemplo de palabras clave secundarias:",
        [LID.RN_SECONDARY_KEYWORDS + 3]               = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]               = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]               = "590",
        ["Find Crafter"]                              = "Encontrar Artesano",
        ["No Crafters Found"]                         = "No se encontraron artesanos",
        [LID.FOUND_CRAFTER_NAME_ENTRY]                = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                     = "|cffffd100Clic izquierdo: Solicitar fabricación|r",
        ["Crafter Greeting"]                          = "|cFFFFFFFFSaludo del artesano|r",
        [LID.BUSY_ICON]                               =
        "|cFFFFFFFFEl artesano ha indicado que está ocupado, pero puede fabricar el objeto más tarde.\n\nVerifica su saludo para más detalles.|r",
        ["Potential Crafters"]                        = "Artesanos potenciales",
        [LID.FOUND_VIA_CRAFT_SCAN]                    =
        "Te encontré a través de CraftScan y vi tu saludo. ¿Puedes fabricar %s para mí ahora?",
        [LID.COMMISSION_INSTRUCTIONS]                 =
        "Ej. '10000g', Predeterminado: 'Cualquiera'\nEste texto aparece en la tabla 'Encontrar artesano' del cliente.",
        ["Commission"]                                = "Comisión",
        ["Crafter [Currently Playing]"]               = "Artesano [Actualmente jugando]",
        ["Profession commission"]                     = "Comisión de profesión",
        [LID.DEFAULT_COMMISSION]                      = "Cualquiera",
        [LID.HELP_ITEM_COMMISSION]                    =
        "CraftScan ofrece a los clientes un botón de 'Encontrar artesano' en órdenes personales. Tu nombre, saludo y esta comisión aparecerán en la tabla junto con otros artesanos. La longitud está limitada a 12 caracteres para ajustarse en la tabla del cliente.",
        ["Discoverable"]                              = "Visible para los clientes",
        [LID.DISCOVERABLE_SETTING]                    =
        "Cuando está activado, cuando un cliente pulsa 'Encontrar artesano', tu nombre aparecerá en la tabla generada si puedes fabricar el objeto.",
        [LID.RN_CUSTOMER_SEARCH]                      = "Encontrar artesano",
        [LID.RN_CUSTOMER_SEARCH + 1]                  =
        "La página para enviar una orden personal ahora tiene un botón de 'Encontrar artesano'. Este botón envía una solicitud a todos los usuarios de CraftScan para ver quién puede fabricar el objeto y presenta los resultados en una tabla con la comisión configurada del artesano.",
        [LID.RN_CUSTOMER_SEARCH + 2]                  =
        "Cada profesión y objeto ahora tiene un cuadro de 'Comisión' para configurar lo que se mostrará en esta tabla, y el texto está limitado a 12 caracteres para caber en la tabla.",
        [LID.RN_CUSTOMER_SEARCH + 3]                  =
        "Te has unido al canal 'CraftScan', pero no necesitas activarlo ni ver mensajes en el canal. Existe para permitir que CraftScan envíe solicitudes privadas como normalmente se hace en el chat de Comercio.",
        [LID.RN_CUSTOMER_SEARCH + 4]                  =
        "Como artesano, ahora podrías recibir susurros no solicitados de clientes que ya saben lo que puedes fabricar.",
        [LID.RN_CUSTOMER_SEARCH + 5]                  =
        "Este es un poco difícil de probar ya que las cuentas de prueba no tienen acceso a la tabla de fabricación. Si encuentras algún problema, puedes desactivar la función hasta que pueda solucionarlo.",
        [LID.RN_CUSTOMER_SEARCH + 6]                  =
        "Puedes optar por no estar incluido en esta tabla a través de la nueva configuración de 'Visible' en el menú principal de configuración de Blizzard.",
        [LID.RN_CUSTOMER_SEARCH + 7]                  =
        "Dado que los clientes podrían empezar a usar el addon, la función de Análisis se puede desactivar por completo, y ahora está desactivada por defecto. Si ya has recopilado datos, seguirá habilitada."




    }
end
