local CraftScan = select(2, ...)
CraftScan.LOCAL_MX = {}

function CraftScan.LOCAL_MX:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                         = "CraftScan",
        [LID.CRAFT_SCAN]                      = "CraftScan",
        [LID.CHAT_ORDERS]                     = "Órdenes de Chat",
        [LID.DISABLE_ADDONS]                  = "Desactivar Addons",
        [LID.RENABLE_ADDONS]                  = "Reactivar Addons",
        [LID.DISABLE_ADDONS_TOOLTIP]          =
        "Guarda tu lista de addons y luego desactívalos, permitiendo un cambio rápido a un alter. Este botón puede ser pulsado de nuevo para reactivar los addons en cualquier momento.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]       = "Puedo fabricar %s.",               -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]     = "Mi alter, %s, puede fabricar %s.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]            = "eso",
        [LID.GREETING_I_HAVE_PROF]            = "Tengo %s.",                        -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]           = "Mi alter, %s, tiene %s.",          -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]             = "Avísame si envías una orden para que pueda cambiar de personaje.",
        [LID.MAIN_BUTTON_BINDING_NAME]        = "Alternar Página de Órdenes",
        [LID.GREET_BUTTON_BINDING_NAME]       = "Saludar al Cliente del Banner",
        [LID.DISMISS_BUTTON_BINDING_NAME]     = "Despedir al Cliente del Banner",
        [LID.TOGGLE_CHAT_TOOLTIP]             = "Alternar órdenes de chat%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]             = "Mostrar CraftScan",
        [LID.SCANNER_CONFIG_HIDE]             = "Ocultar CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]              = "Opciones de CraftScan",
        [LID.ITEM_SCAN_CHECK]                 = "Escanear chat para este ítem",
        [LID.HELP_PROFESSION_KEYWORDS]        =
        "Un mensaje debe contener uno de estos términos. Para coincidir con un mensaje como 'LF Lariat', 'lariat' debe estar listado aquí. Para generar un enlace de ítem para el Lazo Elemental en la respuesta, 'lariat' también debe incluirse en las palabras clave de configuración del ítem para el Lazo Elemental.",
        [LID.HELP_PROFESSION_EXCLUSIONS]      =
        "Un mensaje será ignorado si contiene uno de estos términos, incluso si de otra manera sería una coincidencia. Para evitar responder a 'LF JC Lariat' con 'Tengo Joyería' cuando no tienes la receta de Lazo, 'lariat' debe estar listado aquí.",
        [LID.HELP_SCAN_ALL]                   =
        "Habilitar escaneo para todas las recetas en la misma expansión que la receta seleccionada.",
        [LID.HELP_PRIMARY_EXPANSION]          =
        "Usa este saludo al responder a una solicitud genérica como 'LF Herrero'. Cuando se lance una nueva expansión, probablemente querrás un saludo que describa los ítems que puedes fabricar en lugar de indicar que tienes el máximo conocimiento de la expansión anterior.",
        [LID.HELP_EXPANSION_GREETING]         =
        "Siempre se genera una introducción inicial que indica que puedes fabricar el ítem. Este texto se agrega a ella. Se permiten nuevas líneas y se enviarán como una respuesta separada. Si el texto es demasiado largo, se dividirá en múltiples respuestas.",
        [LID.HELP_CATEGORY_KEYWORDS]          =
        "Si se ha coincidido con una profesión, verifica estas palabras clave específicas de la categoría para refinar el saludo. Por ejemplo, podrías poner 'tóxico' o 'viscoso' aquí para intentar detectar patrones de Peletería que requieren el Altar de la Decadencia.",
        [LID.HELP_CATEGORY_GREETING]          =
        "Cuando se detecta esta categoría en un mensaje, ya sea mediante una palabra clave o un enlace de ítem, este saludo adicional se agregará después del saludo de la profesión.",
        [LID.HELP_CATEGORY_OVERRIDE]          = "Omitir el saludo de la profesión y comenzar con el saludo de la categoría.",
        [LID.HELP_ITEM_KEYWORDS]              =
        "Si se ha coincidido con una profesión, verifica estas palabras clave específicas del ítem para refinar el saludo. Cuando coincidan, la respuesta incluirá el enlace del ítem en lugar del saludo genérico de la profesión. Si 'lariat' es una palabra clave de profesión, pero no una palabra clave de ítem, la respuesta dirá 'Tengo Joyería.' Si 'lariat' es solo una palabra clave de ítem, 'LF Lariat' no coincidirá con una profesión y no se considerará una coincidencia. Si 'lariat' es tanto una palabra clave de profesión como de ítem, la respuesta a 'LF Lariat' será 'Puedo fabricar [Lazo Elemental].'",
        [LID.HELP_ITEM_GREETING]              =
        "Cuando se detecta este ítem en un mensaje, ya sea mediante una palabra clave o el enlace del ítem, este saludo adicional se agregará después de los saludos de profesión y categoría.",
        [LID.HELP_ITEM_OVERRIDE]              = "Omitir el saludo de la profesión y la categoría y comenzar con el saludo del ítem.",
        [LID.HELP_GLOBAL_KEYWORDS]            = "Un mensaje debe incluir uno de estos términos.",
        [LID.HELP_GLOBAL_EXCLUSIONS]          = "Un mensaje será ignorado si contiene uno de estos términos.",
        [LID.SCAN_ALL_RECIPES]                = "Escanear todas las recetas",
        [LID.SCANNING_ENABLED]                = "El escaneo está habilitado porque '%s' está marcado.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]               = "El escaneo está deshabilitado.",
        [LID.PRIMARY_KEYWORDS]                = "Palabras clave primarias",
        [LID.HELP_PRIMARY_KEYWORDS]           =
        "Todos los mensajes se filtran por estos términos, que son comunes a todas las profesiones. Un mensaje coincidente se procesa más para buscar contenido relacionado con la profesión.",
        [LID.HELP_CATEGORY_SECTION]           =
        "La categoría es la sección colapsable que contiene la receta en la lista a la izquierda. 'Favoritos' no es una categoría. Esto está destinado principalmente a cosas como las recetas tóxicas de Peletería que son más difíciles de fabricar. También podría ser útil al inicio de expansiones cuando solo puedes especializarte en una categoría.",
        [LID.HELP_EXPANSION_SECTION]          =
        "Los árboles de conocimiento difieren por expansión, por lo que el saludo también puede diferir.",
        [LID.HELP_PROFESSION_SECTION]         =
        "Desde el punto de vista del cliente, no hay diferencia entre expansiones. Estos términos se combinan con la selección de 'expansión primaria' para proporcionar un saludo genérico (por ejemplo, 'Tengo <profesión>.') cuando no podemos coincidir con algo más específico.",
        [LID.RECIPE_NOT_LEARNED]              = "No has aprendido esta receta. El escaneo está deshabilitado.",
        [LID.PING_SOUND_LABEL]                = "Sonido de alerta",
        [LID.PING_SOUND_TOOLTIP]              = "El sonido que se reproduce cuando se detecta un cliente.",
        [LID.BANNER_SIDE_LABEL]               = "Dirección del banner",
        [LID.BANNER_SIDE_TOOLTIP]             = "El banner crecerá desde el botón en esta dirección.",
        Left                                  = "Izquierda",
        Right                                 = "Derecha",
        Minute                                = "Minuto",
        Minutes                               = "Minutos",
        Second                                = "Segundo",
        Seconds                               = "Segundos",
        Millisecond                           = "Milisegundo",
        Milliseconds                          = "Milisegundos",
        Version                               = "Nuevo en",
        ["CraftScan Release Notes"]           = "Notas de la Versión de CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]          = "Tiempo de espera del cliente",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]        = "Despedir automáticamente a los clientes después de estos minutos.",
        [LID.BANNER_TIMEOUT_LABEL]            = "Tiempo de espera del banner",
        [LID.BANNER_TIMEOUT_TOOLTIP]          =
        "El banner de notificación del cliente permanecerá mostrado por esta duración después de que se detecte una coincidencia.",
        ["All crafters"]                      = "Todos los artesanos",
        ["Crafter Name"]                      = "Nombre del Artesano",
        ["Profession"]                        = "Profesión",
        ["Customer Name"]                     = "Nombre del Cliente",
        ["Replies"]                           = "Respuestas",
        ["Keywords"]                          = "Palabras clave",
        ["Profession greeting"]               = "Saludo de la profesión",
        ["Category greeting"]                 = "Saludo de la categoría",
        ["Item greeting"]                     = "Saludo del ítem",
        ["Primary expansion"]                 = "Expansión primaria",
        ["Override greeting"]                 = "Sobrescribir saludo",
        ["Excluded keywords"]                 = "Palabras clave excluidas",
        [LID.EXCLUSION_INSTRUCTIONS]          = "No coincidir mensajes que contengan estos tokens separados por comas.",
        [LID.KEYWORD_INSTRUCTIONS]            = "Coincidir mensajes que contengan una de estas palabras clave separadas por comas.",
        [LID.GREETING_INSTRUCTIONS]           = "Un saludo para enviar a los clientes que buscan un oficio.",
        [LID.GLOBAL_INCLUSION_DEFAULT]        = "LF, LFC, WTB, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]        = "LFW, WTS, LF trabajo",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]  = "BS, Herrero, Forjador de Armaduras, Forjador de Armas",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING] = "LW, Peletería, Peletero",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]        = "Alc, Alquimista, Piedra",
        [LID.DEFAULT_KEYWORDS_TAILORING]      = "Sastre",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]    = "Ingeniero, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]     = "Encantador, Cresta",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]  = "JC, Joyero",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]    = "Inscripción, Inscripcionista, Escriba",

        -- Release notes
        [LID.RN_WELCOME]                      = "¡Bienvenido a CraftScan!",
        [LID.RN_WELCOME + 1]                  =
        "Este addon escanea el chat en busca de mensajes que parezcan solicitudes de fabricación. Si la configuración indica que puedes fabricar el ítem solicitado, se activará una notificación y se almacenará la información del cliente para facilitar la comunicación.",

        [LID.RN_INITIAL_SETUP]                = "Configuración Inicial",
        [LID.RN_INITIAL_SETUP + 1]            =
        "Para empezar, abre una profesión y haz clic en el nuevo botón 'Mostrar CraftScan' en la parte inferior.",
        [LID.RN_INITIAL_SETUP + 2]            =
        "Desplázate hasta el final de esta nueva ventana y trabaja hacia arriba. Las cosas que necesitas cambiar raramente están al final, pero esas son las configuraciones de las que preocuparse primero.",
        [LID.RN_INITIAL_SETUP + 3]            =
        "Haz clic en el ícono de ayuda en la esquina superior izquierda de la ventana si necesitas una explicación de cualquier entrada.",

        [LID.RN_INITIAL_TESTING]              = "Pruebas Iniciales",
        [LID.RN_INITIAL_TESTING + 1]          =
        "Una vez configurado, escribe un mensaje en el chat /decir, como 'LF BS' para Herrería, asumiendo que has dejado las palabras clave 'LF' y 'BS'. Debería aparecer una notificación.",
        [LID.RN_INITIAL_TESTING + 2]          =
        "Haz clic en la notificación para enviar una respuesta inmediatamente, haz clic derecho para despedir al cliente, o haz clic en el botón circular de la profesión para abrir la ventana de órdenes.",
        [LID.RN_INITIAL_TESTING + 3]          =
        "Las notificaciones duplicadas se suprimen a menos que ya hayan sido descartadas, así que haz clic derecho en tu notificación de prueba para descartarla si quieres intentarlo de nuevo.",

        [LID.RN_MANAGING_CRAFTERS]            = "Gestionando Tus Artesanos",
        [LID.RN_MANAGING_CRAFTERS + 1]        =
        "El lado izquierdo de la ventana de órdenes lista a tus artesanos. Esta lista se llenará a medida que inicies sesión en tus varios personajes y configures sus profesiones. Puedes seleccionar qué personajes deben ser escaneados activamente en cualquier momento, así como si las notificaciones visuales y auditivas están habilitadas para cada uno de tus artesanos.",

        [LID.RN_MANAGING_CUSTOMERS]           = "Gestionando Clientes",
        [LID.RN_MANAGING_CUSTOMERS + 1]       =
        "El lado derecho de la ventana de órdenes se llenará con órdenes de fabricación detectadas en el chat. Haz clic izquierdo en una fila para enviar el saludo si no lo hiciste ya desde el banner emergente. Haz clic izquierdo de nuevo para abrir un susurro al cliente. Haz clic derecho para descartar la fila.",
        [LID.RN_MANAGING_CUSTOMERS + 2]       =
        "Las filas en esta tabla persistirán en todos los personajes, por lo que puedes cambiar a un alter y luego hacer clic en el cliente nuevamente para restaurar la comunicación. Las filas se agotan después de 10 minutos por defecto. Esta duración se puede configurar en la página principal de configuraciones (Esc -> Opciones -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]       =
        "Esperemos que la mayor parte de la tabla sea autoexplicativa. La columna 'Respuestas' tiene 3 íconos. La X o marca de verificación izquierda es si has enviado un mensaje al cliente. La X o marca de verificación derecha es si el cliente ha respondido. La burbuja de chat es un botón que abrirá una ventana de susurro temporal con el cliente y la llenará con tu historial de chat.",

        [LID.RN_KEYBINDS]                     = "Atajos de Teclado",
        [LID.RN_KEYBINDS + 1]                 =
        "Hay atajos de teclado disponibles para abrir la página de órdenes, responder al último cliente y despedir al último cliente. Busca 'CraftScan' para encontrar todas las configuraciones disponibles.",

        [LID.RN_CLEANUP]                      = "Limpieza de Configuración",
        [LID.RN_CLEANUP + 1]                  =
        "Tus artesanos en el lado izquierdo de la página 'Órdenes de Chat' ahora tienen un menú contextual al hacer clic derecho. Usa este menú para mantener la lista limpia y eliminar personajes/profesiones obsoletos.",
        ["Disable"]                           = "Desactivar",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]      =
        "Elimina permanentemente cualquier dato %s guardado para %s.\n\nUn botón 'Habilitar CraftScan' estará presente en la página de la profesión para habilitarlo nuevamente con la configuración predeterminada.\n\nUsa esto si deseas continuar usando la profesión, pero sin la interacción de CraftScan (por ejemplo, cuando tienes Alquimia en todos los personajes secundarios para frascos largos).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]           = "Escribe 'DELETE' para continuar:",
        [LID.SCANNER_CONFIG_DISABLED]         = "Habilitar CraftScan",

        ["Cleanup"]                           = "Limpiar",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]     =
        "Elimina permanentemente cualquier dato %s guardado para %s.\n\nLa profesión quedará en un estado como si nunca hubiera sido configurada. Simplemente abrir la profesión nuevamente restaurará una configuración predeterminada.\n\nUsa esto si deseas restablecer completamente una profesión, has eliminado el personaje o has abandonado la profesión.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]          = "Escribe 'CLEANUP' para continuar:",

        ["Primary Crafter"]                   = "Artesano Principal",
        [LID.PRIMARY_CRAFTER_TOOLTIP]         =
        "Marca %s como tu artesano principal para %s. Este artesano tendrá prioridad sobre otros si hay varias coincidencias con la misma solicitud.",
        ["Chat History"]                      = "Historial de chat con %s", -- customer, left-click-help
        ["Greet Help"]                        = "|cffffd100Clic izquierdo: Saludar al cliente%s|r",
        ["Chat Help"]                         = "|cffffd100Clic izquierdo: Abrir susurro|r",
        ["Chat Override"]                     = "|cffffd100Clic medio: Abrir susurro%s|r",
        ["Dismiss"]                           = "|cffffd100Clic derecho: Descartar%s|r",
        ["Proposed Greeting"]                 = "Saludo propuesto:",
        [LID.CHAT_BUTTON_BINDING_NAME]        = "Susurro al Cliente de la Bandera",
        ["Customer Request"]                  = "Solicitud de %s",


    }
end
