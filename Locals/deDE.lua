local CraftScan = select(2, ...)

CraftScan.LOCAL_DE = {}

function CraftScan.LOCAL_DE:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
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

        [LID.RN_CLEANUP]                              = "Konfigurationsbereinigung",
        [LID.RN_CLEANUP + 1]                          =
        "Ihre Handwerker auf der linken Seite der 'Chat-Aufträge'-Seite haben jetzt ein Kontextmenü, wenn Sie mit der rechten Maustaste klicken. Verwenden Sie dieses Menü, um die Liste sauber zu halten und veraltete Charaktere/Berufe zu entfernen.",

        ["Disable"]                                   = "Deaktivieren",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]              =
        "Löschen Sie dauerhaft alle gespeicherten %s-Daten für %s.\n\nEine Schaltfläche 'CraftScan aktivieren' wird auf der Berufsseite angezeigt, um es wieder mit den Standardeinstellungen zu aktivieren.\n\nVerwenden Sie dies, wenn Sie den Beruf weiter nutzen möchten, aber ohne CraftScan-Interaktion (z.B. wenn Sie Alchemie auf jedem Twink für lange Fläschchen haben).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]                   = "Geben Sie 'DELETE' ein, um fortzufahren:",
        [LID.SCANNER_CONFIG_DISABLED]                 = "CraftScan aktivieren",

        ["Cleanup"]                                   = "Bereinigen",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]             =
        "Löschen Sie dauerhaft alle gespeicherten %s-Daten für %s.\n\nDer Beruf wird in einem Zustand zurückgelassen, als wäre er nie konfiguriert worden. Einfaches Öffnen des Berufs wird eine Standardkonfiguration wiederherstellen.\n\nVerwenden Sie dies, wenn Sie einen Beruf komplett zurücksetzen möchten, den Charakter gelöscht haben oder den Beruf abgelegt haben.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]                  = "Geben Sie 'CLEANUP' ein, um fortzufahren:",

        ["Primary Crafter"]                           = "Haupt-Handwerker",
        [LID.PRIMARY_CRAFTER_TOOLTIP]                 =
        "Markiere %s als deinen Haupt-Handwerker für %s. Dieser Handwerker wird Vorrang vor anderen haben, wenn es mehrere Übereinstimmungen mit derselben Anfrage gibt.",
        ["Chat History"]                              = "Chatverlauf mit %s", -- customer, left-click-help
        ["Greet Help"]                                = "|cffffd100Linksklick: Kunde begrüßen%s|r",
        ["Chat Help"]                                 = "|cffffd100Linksklick: Flüstern öffnen|r",
        ["Chat Override"]                             = "|cffffd100Mittelklick: Flüstern öffnen%s|r",
        ["Dismiss"]                                   = "|cffffd100Rechtsklick: Verwerfen%s|r",
        ["Proposed Greeting"]                         = "Vorgeschlagene Begrüßung:",
        [LID.CHAT_BUTTON_BINDING_NAME]                = "Flüster-Banner-Kunde",
        ["Customer Request"]                          = "Anfrage von %s",

        [LID.ADDON_WHITELIST_LABEL]                   = "Addon-Whitelist",
        [LID.ADDON_WHITELIST_TOOLTIP]                 =
        "Wenn du den Button drückst, um alle Addons vorübergehend zu deaktivieren, bleiben die hier ausgewählten Addons aktiviert. CraftScan bleibt immer aktiviert. Behalte nur das, was du zum effektiven Handwerk benötigst.",
        [LID.MULTI_SELECT_BUTTON_TEXT]                = "%d ausgewählt", -- Count

        [LID.ACCOUNT_LINK_DESC]                       =
        "Teile Handwerker zwischen mehreren Accounts.\n\nBeim Einloggen oder nach einer Konfigurationsänderung wird CraftScan die neuesten Informationen zwischen den konfigurierten Accounts synchronisieren, um sicherzustellen, dass beide Seiten eines verlinkten Accounts immer auf dem neuesten Stand sind.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]           = "Gib den Namen eines Charakters auf deinem anderen Account ein:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]            = "Gib einen Spitznamen für den anderen Account ein:",
        ["Link Account"]                              = "Account verlinken",
        ["Linked Accounts"]                           = "Verlinkte Accounts",
        ["Accept Linked Account"]                     = "Verlinkten Account akzeptieren",
        ["Delete Linked Account"]                     = "Verlinkten Account löschen",
        ["OK"]                                        = "OK",
        [LID.VERSION_MISMATCH]                        =
        "|cFFFF0000Fehler: CraftScan-Version nicht kompatibel. Andere Account-Version: %s. Deine Version: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]                  =
        "Dieser Charakter gehört zu einem verlinkten Account. Er kann nur auf dem Account, dem er gehört, deaktiviert werden. Du kannst diesen Charakter vollständig über 'Bereinigung' entfernen, musst dies jedoch manuell auf allen verlinkten Accounts tun, sonst wird er beim Einloggen wiederhergestellt.",
        [LID.REMOTE_CRAFTER_SUMMARY]                  = "Synchronisiert mit %s.",
        ["proxy_send_enabled"]                        = "Proxy-Aufträge",
        ["proxy_send_enabled_tooltip"]                = "Wenn eine Kundenbestellung erkannt wird, sende sie an verlinkte Accounts.",
        ["proxy_receive_enabled"]                     = "Proxy-Aufträge empfangen",
        ["proxy_receive_enabled_tooltip"]             =
        "Wenn ein anderer Account eine Kundenbestellung erkennt und sendet, empfängt dieser Account sie. Der CraftScan-Button wird angezeigt, um bei Bedarf das Benachrichtigungsbanner zu zeigen.",
        [LID.LINK_ACTIVE]                             = "|cFF00FF00%s (zuletzt gesehen %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]                =
        "Lösche die Verlinkung zu '%s' und alle importierten Charaktere. Dieser Account wird jegliche Kommunikation mit der anderen Seite einstellen. Die andere Seite wird weiterhin versuchen, Verbindungen herzustellen, bis die Verlinkung auch dort manuell entfernt wird.\n\nEntfernte importierte Handwerker:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]                   =
        "Standardmäßig sind der Charakter, den du zunächst verlinkt hast, alle Handwerker und alle Charaktere, die eingeloggt waren, während dieser Account online war, bei CraftScan bekannt. Füge weitere Charaktere des anderen Accounts hinzu, damit sie ebenfalls verwendet werden können. '/reload', um die Synchronisierung mit dem neuen Charakter zu erzwingen, wenn dieser online ist.",
        ["Backup characters"]                         = "Zusätzliche Charaktere",
        ["Unlink account"]                            = "Account entkoppeln",
        ["Add"]                                       = "Hinzufügen",
        ["Remove"]                                    = "Entfernen",
        ["Rename account"]                            = "Account umbenennen",
        ["New name"]                                  = "Neuer Name:",

        [LID.RN_LINKED_ACCOUNTS]                      = "Verlinkte Accounts",
        [LID.RN_LINKED_ACCOUNTS + 1]                  =
        "Verlinke mehrere WoW-Accounts, um Handwerksinformationen zu teilen und von jedem Account aus zu scannen.",
        [LID.RN_LINKED_ACCOUNTS + 2]                  =
        "Optional: Proxy-Kundenaufträge von einem Account zu den anderen senden, damit du einen Testaccount in der Stadt parken kannst, während dein Hauptcharakter unterwegs ist.",
        [LID.RN_LINKED_ACCOUNTS + 3]                  =
        "Um loszulegen, klicke auf den 'Account verlinken'-Button in der unteren linken Ecke des CraftScan-Fensters und folge den Anweisungen.",
        [LID.RN_LINKED_ACCOUNTS + 4]                  = "Demo: https://www.youtube.com/watch?v=x1JLEph6t_c",

        ["Open Settings"]                             = "Einstellungen öffnen",
        ["Customize Greeting"]                        = "Begrüßung anpassen",
        [LID.CUSTOM_GREETING_INFO]                    =
        "CraftScan verwendet diese Sätze, um die anfängliche Begrüßung je nach Situation an Kunden zu senden. Überschreiben Sie unten einige oder alle, um Ihre eigene Begrüßung zu erstellen.",
        ["Default"]                                   = "Standard",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS]            =
        "Fehler: Erwartet %d oder weniger %%s Platzhalter. Der bereitgestellte Text enthält %d.",
        [LID.WRONG_TYPE_OF_PLACEHOLDERS]              = "Fehler: Nur %s Platzhalter werden unterstützt.",

        ["item link"]                                 = "Gegenstandslink",
        ["alt name and then item link"]               = "alternativer Name und dann Gegenstandslink",
        ["profession name"]                           = "Berufsname",
        ["alt name and then profession name"]         = "alternativer Name und dann Berufsname",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS_SUGGESTION] =
        "Dieser Text muss %d oder weniger %%s Platzhalter enthalten, um das %s zu halten. Sie haben %d eingefügt.\n\nCraftScan funktioniert mit weniger Platzhaltern, aber Sie möchten sie wahrscheinlich für den Kontext einfügen.",



    }
end
