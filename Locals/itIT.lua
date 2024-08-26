local CraftScan = select(2, ...)

CraftScan.LOCAL_IT = {}

function CraftScan.LOCAL_IT:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                                 = "CraftScan",
        [LID.CRAFT_SCAN]                              = "CraftScan",
        [LID.CHAT_ORDERS]                             = "Ordini Chat",
        [LID.DISABLE_ADDONS]                          = "Disabilita Addon",
        [LID.RENABLE_ADDONS]                          = "Riabilita Addon",
        [LID.DISABLE_ADDONS_TOOLTIP]                  =
        "Salva la lista dei tuoi addon e disabilitali, consentendo uno scambio rapido ad un alt. Questo pulsante può essere premuto nuovamente per riabilitare gli addon in qualsiasi momento.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]               = "Posso creare %s.",         -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]             = "Il mio alter, %s, può creare %s.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                    = "quello",
        [LID.GREETING_I_HAVE_PROF]                    = "Ho %s.",                   -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]                   = "Il mio alter, %s, ha %s.", -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                     = "Fammi sapere se invii un ordine così posso cambiare personaggio.",
        [LID.MAIN_BUTTON_BINDING_NAME]                = "Mostra Pagina Ordini",
        [LID.GREET_BUTTON_BINDING_NAME]               = "Saluta Cliente",
        [LID.DISMISS_BUTTON_BINDING_NAME]             = "Rimuovi Cliente",
        [LID.TOGGLE_CHAT_TOOLTIP]                     = "Attiva/Disattiva ordini chat%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                     = "Mostra CraftScan",
        [LID.SCANNER_CONFIG_HIDE]                     = "Nascondi CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]                      = "Opzioni CraftScan",
        [LID.ITEM_SCAN_CHECK]                         = "Scansiona chat per questo oggetto",
        [LID.HELP_PROFESSION_KEYWORDS]                =
        "Un messaggio deve contenere uno di questi termini. Per corrispondere a un messaggio come 'LF Lariat', 'lariet' dovrebbe essere elencato qui. Per generare un link dell'oggetto per il Lariat Elementale nella risposta, 'lariat' dovrebbe essere incluso anche nei termini di configurazione dell'oggetto per il Lariat Elementale.",
        [LID.HELP_PROFESSION_EXCLUSIONS]              =
        "Un messaggio verrà ignorato se contiene uno di questi termini, anche se altrimenti sarebbe una corrispondenza. Per evitare di rispondere a 'LF JC Lariat' con 'Ho la Gioielleria' quando non hai la ricetta del Lariat, 'lariat' dovrebbe essere elencato qui.",
        [LID.HELP_SCAN_ALL]                           =
        "Abilita la scansione per tutte le ricette nella stessa espansione della ricetta selezionata.",
        [LID.HELP_PRIMARY_EXPANSION]                  =
        "Usa questo saluto quando rispondi a una richiesta generica come 'LF Blacksmith'. Quando viene lanciata una nuova espansione, probabilmente desidererai un saluto che descriva quali oggetti puoi creare anziché affermare di avere conoscenze massime dall'espansione precedente.",
        [LID.HELP_EXPANSION_GREETING]                 =
        "Viene sempre generata un'introduzione iniziale affermando che puoi creare l'oggetto. Questo testo viene aggiunto. Le nuove righe sono consentite e verranno inviate come risposta separata. Se il testo è troppo lungo, verrà diviso in più risposte.",
        [LID.HELP_CATEGORY_KEYWORDS]                  =
        "Se una professione viene abbinata, controlla questi termini specifici della categoria per raffinare il saluto. Ad esempio, potresti mettere 'toxic' o 'slimy' qui per tentare di rilevare schemi di Conciatura che richiedono l'Altare del Decadimento.",
        [LID.HELP_CATEGORY_GREETING]                  =
        "Quando viene rilevata questa categoria in un messaggio, tramite una parola chiave o un link all'oggetto, questo saluto aggiuntivo verrà aggiunto dopo il saluto della professione.",
        [LID.HELP_CATEGORY_OVERRIDE]                  = "Ometti il saluto della professione e inizia con il saluto della categoria.",
        [LID.HELP_ITEM_KEYWORDS]                      =
        "Se una professione viene abbinata, controlla questi termini specifici dell'oggetto per raffinare il saluto. Quando viene abbinato, la risposta includerà il link all'oggetto invece del saluto generico della professione. Se 'lariat' è una parola chiave della professione, ma non una parola chiave dell'oggetto, la risposta dirà 'Ho la Gioielleria'. Se 'lariat' è solo una parola chiave dell'oggetto, 'LF Lariat' non corrisponderà a una professione e non è considerato un abbinamento. Se 'lariat' è sia una parola chiave della professione che dell'oggetto, la risposta a 'LF Lariat' sarà 'Posso creare [Lariat Elementale].'",
        [LID.HELP_ITEM_GREETING]                      =
        "Quando viene rilevato questo oggetto in un messaggio, tramite una parola chiave o il link all'oggetto, questo saluto aggiuntivo verrà aggiunto dopo i saluti della professione e della categoria.",
        [LID.HELP_ITEM_OVERRIDE]                      =
        "Ometti il saluto della professione e della categoria e inizia con il saluto dell'oggetto.",
        [LID.HELP_GLOBAL_KEYWORDS]                    = "Un messaggio deve includere uno di questi termini.",
        [LID.HELP_GLOBAL_EXCLUSIONS]                  = "Un messaggio verrà ignorato se contiene uno di questi termini.",
        [LID.SCAN_ALL_RECIPES]                        = 'Scansiona tutte le ricette',
        [LID.SCANNING_ENABLED]                        = "La scansione è abilitata perché '%s' è selezionato.", -- SCAN_ALL_RECIPES o ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                       = "La scansione è disabilitata.",
        [LID.PRIMARY_KEYWORDS]                        = "Parole chiave primarie",
        [LID.HELP_PRIMARY_KEYWORDS]                   =
        "Tutti i messaggi sono filtrati da questi termini, che sono comuni a tutte le professioni. Un messaggio corrispondente viene ulteriormente elaborato per cercare contenuti correlati alla professione.",
        [LID.HELP_CATEGORY_SECTION]                   =
        "La categoria è la sezione espandibile che contiene la ricetta nell'elenco a sinistra. 'Preferiti' non è una categoria. È destinato principalmente a cose come le ricette di Conciatura tossiche che sono più difficili da creare. Potrebbe anche essere utile all'inizio delle espansioni quando puoi solo specializzarti in una singola categoria.",
        [LID.HELP_EXPANSION_SECTION]                  =
        "I rami della conoscenza differiscono per espansione, quindi il saluto può anche differire.",
        [LID.HELP_PROFESSION_SECTION]                 =
        "Dal punto di vista del cliente, non c'è differenza tra le espansioni. Questi termini si combinano con la selezione della 'Espansione primaria' per fornire un saluto generico (ad es. 'Ho <professione>.') quando non possiamo corrispondere a qualcosa di più specifico.",
        [LID.RECIPE_NOT_LEARNED]                      = "Non hai appreso questa ricetta. La scansione è disabilitata.",
        [LID.PING_SOUND_LABEL]                        = "Suono di avviso",
        [LID.PING_SOUND_TOOLTIP]                      = "Il suono che si attiva quando viene rilevato un cliente.",
        [LID.BANNER_SIDE_LABEL]                       = "Direzione del banner",
        [LID.BANNER_SIDE_TOOLTIP]                     = "Il banner si espanderà dal pulsante in questa direzione.",
        Sinistra                                      = "Sinistra",
        Destra                                        = "Destra",
        Minuto                                        = "Minuto",
        Minuti                                        = "Minuti",
        Secondo                                       = "Secondo",
        Secondi                                       = "Secondi",
        Millisecondo                                  = "Millisecondo",
        Millisecondi                                  = "Millisecondi",
        Versione                                      = "Nuovo in",
        ["Note sulla versione di CraftScan"]          = "Note sulla versione di CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]                  = "Timeout cliente",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]                = "Rimuovi automaticamente i clienti dopo questo numero di minuti.",
        [LID.BANNER_TIMEOUT_LABEL]                    = "Timeout del banner",
        [LID.BANNER_TIMEOUT_TOOLTIP]                  =
        "Il banner di notifica del cliente rimarrà visualizzato per questa durata dopo che è stata rilevata una corrispondenza.",
        ["Tutti i creatori"]                          = "Tutti i creatori",
        ["Nome del creatore"]                         = "Nome del creatore",
        ["Professione"]                               = "Professione",
        ["Nome del cliente"]                          = "Nome del cliente",
        ["Risposte"]                                  = "Risposte",
        ["Parole chiave"]                             = "Parole chiave",
        ["Saluto della professione"]                  = "Saluto della professione",
        ["Saluto della categoria"]                    = "Saluto della categoria",
        ["Saluto dell'oggetto"]                       = "Saluto dell'oggetto",
        ["Espansione primaria"]                       = "Espansione primaria",
        ["Saluto di override"]                        = "Saluto di override",
        ["Parole chiave escluse"]                     = "Parole chiave escluse",
        [LID.EXCLUSION_INSTRUCTIONS]                  = "Non corrispondere ai messaggi contenenti questi token separati da virgola.",
        [LID.KEYWORD_INSTRUCTIONS]                    =
        "Corrispondere ai messaggi contenenti una di queste parole chiave separate da virgola.",
        [LID.GREETING_INSTRUCTIONS]                   = "Un saluto da inviare ai clienti in cerca di una creazione.",
        [LID.GLOBAL_INCLUSION_DEFAULT]                = "LF, LFC, WTB, ricreare",
        [LID.GLOBAL_EXCLUSION_DEFAULT]                = "LFW, WTS, LF lavoro",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]          = "BS, Fabbro, Fabbro d'armature, Fabbro d'armi",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]         = "LW, Conciatura, Conciatore",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]                = "Alc, Alchimista, Pietra",
        [LID.DEFAULT_KEYWORDS_TAILORING]              = "Sarto",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]            = "Ingegnere, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]             = "Incantatore, Cresta",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]          = "GC, Gioielliere",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]            = "Iscrip, Iscrizione, Iscrivano",

        -- Note sulla versione
        [LID.RN_WELCOME]                              = "Benvenuto in CraftScan!",
        [LID.RN_WELCOME + 1]                          =
        "Questo addon analizza la chat per messaggi che sembrano richieste di creazioni. Se la configurazione indica che puoi creare l'oggetto richiesto, verrà attivata una notifica e le informazioni sul cliente verranno memorizzate per facilitare la comunicazione.",

        [LID.RN_INITIAL_SETUP]                        = "Impostazione iniziale",
        [LID.RN_INITIAL_SETUP + 1]                    =
        "Per iniziare, apri una professione e clicca sul nuovo pulsante 'Mostra CraftScan' lungo il fondo.",
        [LID.RN_INITIAL_SETUP + 2]                    =
        "Scorri fino in fondo a questa nuova finestra e procedi dall'alto verso il basso. Le cose che raramente devi cambiare sono in fondo, ma quelle sono le impostazioni a cui devi prestare attenzione per prima cosa.",
        [LID.RN_INITIAL_SETUP + 3]                    =
        "Clicca sull'icona di aiuto nell'angolo in alto a sinistra della finestra se hai bisogno di spiegazioni su qualsiasi input.",

        [LID.RN_INITIAL_TESTING]                      = "Test iniziale",
        [LID.RN_INITIAL_TESTING + 1]                  =
        "Una volta configurato, digita un messaggio nella chat /say, come 'LF BS' per la Fabbro, assumendo di aver lasciato le parole chiave 'LF' e 'BS'. Dovrebbe apparire una notifica.",

        [LID.RN_INITIAL_TESTING + 2]                  =
        "Clicca sulla notifica per inviare immediatamente una risposta, clicca con il tasto destro per rimuovere il cliente, o clicca sul pulsante circolare della professione per aprire la finestra degli ordini.",
        [LID.RN_INITIAL_TESTING + 3]                  =
        "Le notifiche duplicate vengono soppresso a meno che non siano già state rimosse, quindi clicca con il tasto destro sulla tua notifica di test per rimuoverla se vuoi riprovare.",

        [LID.RN_MANAGING_CRAFTERS]                    = "Gestione dei tuoi creatori",
        [LID.RN_MANAGING_CRAFTERS + 1]                =
        "Nella parte sinistra della finestra degli ordini sono elencati i tuoi creatori. Questo elenco verrà popolato man mano che accedi ai tuoi vari personaggi e configuri le loro professioni. Puoi selezionare quali personaggi devono essere attivamente scannerizzati in qualsiasi momento, nonché se le notifiche visive e uditive sono abilitate per ciascuno dei tuoi creatori.",

        [LID.RN_MANAGING_CUSTOMERS]                   = "Gestione dei clienti",
        [LID.RN_MANAGING_CUSTOMERS + 1]               =
        "Nella parte destra della finestra degli ordini verranno elencati gli ordini di creazione rilevati nella chat. Fai clic sinistro su una riga per inviare il saluto se non lo hai già fatto dal banner a comparsa. Fai clic sinistro nuovamente per aprire un sussurro al cliente. Fai clic destro per rimuovere la riga.",
        [LID.RN_MANAGING_CUSTOMERS + 2]               =
        "Le righe in questa tabella persistono tra tutti i personaggi, quindi puoi passare ad un alter e quindi fare nuovamente clic sul cliente per ripristinare la comunicazione. Le righe scadono dopo 10 minuti per impostazione predefinita. Questa durata può essere configurata nella pagina delle impostazioni principali (Esc -> Opzioni -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]               =
        "Si spera che la maggior parte della tabella sia autoesplicativa. La colonna 'Risposte' ha 3 icone. La spunta o la X sinistra indica se hai inviato un messaggio al cliente. La spunta o la X destra indica se il cliente ha risposto. La bolla di chat è un pulsante che aprirà una finestra di sussurro temporanea con il cliente e la popolerà con la tua cronologia delle chat.",

        [LID.RN_KEYBINDS]                             = "Tasti di scelta rapida",
        [LID.RN_KEYBINDS + 1]                         =
        "I tasti di scelta rapida sono disponibili per aprire la pagina degli ordini, rispondere all'ultimo cliente e rimuovere l'ultimo cliente. Cerca 'CraftScan' per trovare tutte le impostazioni disponibili.",

        [LID.RN_CLEANUP]                              = "Pulizia della Configurazione",
        [LID.RN_CLEANUP + 1]                          =
        "I tuoi artigiani sul lato sinistro della pagina 'Ordini Chat' hanno ora un menu contestuale quando fai clic con il pulsante destro del mouse. Usa questo menu per mantenere pulita la lista e rimuovere personaggi/professioni obsolete.",
        ["Disable"]                                   = "Disabilita",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]              =
        "Elimina permanentemente qualsiasi dato %s salvato per %s.\n\nUn pulsante 'Abilita CraftScan' sarà presente nella pagina della professione per abilitarlo nuovamente con le impostazioni predefinite.\n\nUsa questo se vuoi continuare a utilizzare la professione, ma senza l'interazione di CraftScan (ad esempio, quando hai l'Alchimia su tutti i personaggi secondari per le pozioni lunghe).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]                   = "Digita 'DELETE' per procedere:",
        [LID.SCANNER_CONFIG_DISABLED]                 = "Abilita CraftScan",

        ["Cleanup"]                                   = "Pulizia",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]             =
        "Elimina permanentemente qualsiasi dato %s salvato per %s.\n\nLa professione verrà lasciata in uno stato come se non fosse mai stata configurata. Semplicemente aprendo di nuovo la professione verrà ripristinata una configurazione predefinita.\n\nUsa questo se vuoi resettare completamente una professione, hai eliminato il personaggio o hai abbandonato una professione.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]                  = "Digita 'CLEANUP' per procedere:",

        ["Primary Crafter"]                           = "Artigiano Principale",
        [LID.PRIMARY_CRAFTER_TOOLTIP]                 =
        "Segna %s come il tuo artigiano principale per %s. Questo artigiano avrà la priorità sugli altri se ci sono più corrispondenze con la stessa richiesta.",
        ["Chat History"]                              = "Cronologia chat con %s", -- customer, left-click-help
        ["Greet Help"]                                = "|cffffd100Clic sinistro: Saluta il cliente%s|r",
        ["Chat Help"]                                 = "|cffffd100Clic sinistro: Apri sussurro|r",
        ["Chat Override"]                             = "|cffffd100Clic centrale: Apri sussurro%s|r",
        ["Dismiss"]                                   = "|cffffd100Clic destro: Ignora%s|r",
        ["Proposed Greeting"]                         = "Saluto proposto:",
        [LID.CHAT_BUTTON_BINDING_NAME]                = "Cliente Banner Sussurro",
        ["Customer Request"]                          = "Richiesta da %s",
        [LID.ADDON_WHITELIST_LABEL]                   = "Lista bianca degli addon",
        [LID.ADDON_WHITELIST_TOOLTIP]                 =
        "Quando premi il pulsante per disattivare temporaneamente tutti gli addon, mantieni attivi gli addon selezionati qui. CraftScan rimarrà sempre attivo. Mantieni solo ciò che ti serve per craftare efficacemente.",
        [LID.MULTI_SELECT_BUTTON_TEXT]                = "%d selezionati", -- Count

        [LID.ACCOUNT_LINK_DESC]                       =
        "Condividi gli artigiani tra più account.\n\nAl login o dopo una modifica della configurazione, CraftScan propaga le ultime informazioni tra gli artigiani configurati su entrambi gli account per garantire che entrambi i lati di un account collegato siano sempre sincronizzati.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]           = "Inserisci il nome di un personaggio online sull'altro tuo account:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]            = "Inserisci un soprannome per l'altro account:",
        ["Link Account"]                              = "Collega Account",
        ["Linked Accounts"]                           = "Account Collegati",
        ["Accept Linked Account"]                     = "Accetta Account Collegato",
        ["Delete Linked Account"]                     = "Elimina Account Collegato",
        ["OK"]                                        = "OK",
        [LID.VERSION_MISMATCH]                        =
        "|cFFFF0000Errore: versione di CraftScan non compatibile. Versione dell'altro account: %s. La tua versione: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]                  =
        "Questo personaggio appartiene a un account collegato. Può essere disattivato solo sull'account a cui appartiene. Puoi rimuovere completamente questo personaggio tramite 'Pulizia', ma dovrai farlo manualmente su tutti gli account collegati, altrimenti sarà ripristinato da un account collegato al login.",
        [LID.REMOTE_CRAFTER_SUMMARY]                  = "Sincronizzato con %s.",
        ["proxy_send_enabled"]                        = "Ordini Proxy",
        ["proxy_send_enabled_tooltip"]                = "Quando viene rilevato un ordine cliente, invialo agli account collegati.",
        ["proxy_receive_enabled"]                     = "Ricevi Ordini Proxy",
        ["proxy_receive_enabled_tooltip"]             =
        "Quando un altro account rileva e invia un ordine cliente, questo account lo riceverà. Il pulsante CraftScan sarà visualizzato per mostrare l'avviso se necessario.",
        [LID.LINK_ACTIVE]                             = "|cFF00FF00%s (visto l'ultima volta %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]                =
        "Elimina il collegamento con '%s' e tutti i personaggi importati. Questo account cesserà ogni comunicazione con l'altro lato. L'altro lato continuerà a tentare di stabilire connessioni fino a quando il collegamento non sarà eliminato manualmente anche lì.\n\nArtigiani importati che saranno eliminati:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]                   =
        "Per impostazione predefinita, il personaggio che hai inizialmente collegato, qualsiasi artigiano e qualsiasi personaggio che si è connesso mentre questo account era online sono conosciuti da CraftScan. Aggiungi personaggi aggiuntivi appartenenti all'altro account in modo che possano essere utilizzati anche loro. '/reload' per forzare la sincronizzazione con il nuovo personaggio se è online.",
        ["Backup characters"]                         = "Personaggi Aggiuntivi",
        ["Unlink account"]                            = "Scollega Account",
        ["Add"]                                       = "Aggiungi",
        ["Remove"]                                    = "Rimuovi",
        ["Rename account"]                            = "Rinomina Account",
        ["New name"]                                  = "Nuovo Nome:",

        [LID.RN_LINKED_ACCOUNTS]                      = "Account Collegati",
        [LID.RN_LINKED_ACCOUNTS + 1]                  =
        "Collega più account WoW insieme per condividere informazioni di crafting e scannerizzare da qualsiasi account.",
        [LID.RN_LINKED_ACCOUNTS + 2]                  =
        "Facoltativamente, invia ordini cliente per proxy da un account agli altri così puoi lasciare un account di prova in città mentre il tuo main è in giro.",
        [LID.RN_LINKED_ACCOUNTS + 3]                  =
        "Per iniziare, clicca sul pulsante 'Collega Account' nell'angolo in basso a sinistra della finestra di CraftScan e segui le istruzioni.",
        [LID.RN_LINKED_ACCOUNTS + 4]                  = "Demo: https://www.youtube.com/watch?v=x1JLEph6t_c",
        ["Open Settings"]                             = "Apri Impostazioni",
        ["Customize Greeting"]                        = "Personalizza Saluto",
        [LID.CUSTOM_GREETING_INFO]                    =
        "CraftScan utilizza queste frasi per creare il saluto iniziale inviato ai clienti a seconda della situazione. Sovrascrivi alcune o tutte qui sotto per creare il tuo saluto.",
        ["Default"]                                   = "Predefinito",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS]            =
        "Errore: Sono previsti %d o meno segnaposto %%s. Il testo fornito ne contiene %d.",
        [LID.WRONG_TYPE_OF_PLACEHOLDERS]              = "Errore: Sono supportati solo segnaposto %s.",

        ["item link"]                                 = "link dell'oggetto",
        ["alt name and then item link"]               = "nome alternativo e poi link dell'oggetto",
        ["profession name"]                           = "nome della professione",
        ["alt name and then profession name"]         = "nome alternativo e poi nome della professione",
        [LID.WRONG_NUMBER_OF_PLACEHOLDERS_SUGGESTION] =
        "Questo testo deve contenere %d segnaposto %%s o meno per contenere il %s. Ne hai inclusi %d.\n\nCraftScan funzionerà con meno segnaposto, ma probabilmente vorrai includerli per il contesto.",


    }
end
