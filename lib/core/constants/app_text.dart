import '../services/locale_controller.dart';

/// Sistema de traducción liviano, basado en claves, que no depende
/// de BuildContext: lee el idioma actual directamente del
/// [LocaleController]. Como toda la app se reconstruye cuando cambia
/// el idioma (ver main.dart), basta con llamar a [tr] dentro de
/// cualquier build() para que el texto se actualice solo.
class AppText {
  AppText._();

  static const Map<String, Map<String, String>> _strings = {
    'es': {
      'nav_home': 'Inicio',
      'nav_subjects_student': 'Mis materias',
      'nav_subjects_teacher': 'Asignaturas',
      'nav_live_class_student': 'Clases en vivo',
      'nav_live_class_teacher': 'Clase en vivo',
      'nav_upload': 'Subir contenido',
      'nav_students': 'Estudiantes',
      'nav_chat_ia': 'LidIA IA',
      'nav_notifications': 'Notificaciones',
      'nav_profile': 'Mi perfil',
      'nav_settings': 'Configuración',
      'logout': 'Cerrar sesión',
      'construction_title': 'Sección en construcción',
      'app_name': 'Aula Lid-IA',

      'settings_title': 'Configuración',
      'settings_account': 'Cuenta',
      'settings_privacy': 'Privacidad',
      'settings_notifications': 'Notificaciones',
      'settings_appearance': 'Apariencia',
      'settings_language': 'Idioma',
      'settings_devices': 'Dispositivos',
      'settings_network': 'Red',
      'settings_about': 'Acerca de',

      'settings_account_desc': 'Gestiona tu información personal',
      'settings_avatar_title': 'Foto de perfil',
      'settings_avatar_subtitle': 'Toca para cambiar tu foto',
      'settings_avatar_subtitle_uploading': 'Subiendo foto...',
      'settings_avatar_error': 'No se pudo actualizar la foto de perfil.',
      'settings_name_title': 'Nombre y usuario',
      'settings_name_edit': 'Edita tu nombre',
      'settings_email_title': 'Correo electrónico',
      'settings_email_subtitle': 'Actualiza tu correo electrónico',
      'settings_password_title': 'Contraseña',
      'settings_password_subtitle': 'Cambia tu contraseña de acceso',
      'settings_linked_title': 'Vinculación de cuentas',
      'settings_linked_subtitle': 'Conecta tu cuenta con otras plataformas',
      'settings_info_secure_title': 'Tu información está segura',
      'settings_info_secure_subtitle':
        'Utilizamos medidas de seguridad para proteger tus datos.',

      'settings_privacy_desc': 'Controla el uso de tu información',
      'settings_privacy_info': 'Guardamos solo la información necesaria '
        'para tu progreso académico: materias, tareas, calificaciones y '
        'clases en vivo. No compartimos tus datos con terceros.',
      'settings_help_title': 'Ayuda y soporte',
      'settings_advanced_privacy_title': 'Controles avanzados de privacidad',
      'settings_advanced_privacy_subtitle': 'Próximamente',

      'settings_notifications_desc': 'Elige cómo quieres que te avisemos',
      'settings_notifications_app_title': 'Notificaciones de la app',
      'settings_notifications_app_subtitle':
        'Alertas de clases, tareas y mensajes',

      'settings_appearance_desc': 'Personaliza cómo se ve la app',
      'theme_light': 'Tema claro',
      'theme_dark': 'Modo oscuro',
      'theme_system': 'Usar el del sistema',
      'theme_active': 'Activo actualmente',
      'settings_accent_color': 'Color de acento',
      'settings_accent_color_subtitle': 'Elige el color principal de la app',
      'settings_custom_color': 'Personalizado',
      'settings_custom_color_hint': 'Ej: #1D9E75',
      'settings_custom_color_apply': 'Aplicar',
      'settings_custom_color_invalid':
        'Código de color no válido. Usa el formato #RRGGBB.',
      'settings_reset_color': 'Restablecer color original',

      'settings_language_desc': 'Idioma de la plataforma',
      'lang_es': 'Español',
      'lang_en': 'English',
      'lang_current': 'Idioma actual',

      'settings_devices_desc': 'Sesiones activas de tu cuenta',
      'settings_this_device': 'Este dispositivo',
      'settings_devices_info': 'La gestión de sesiones en otros '
        'dispositivos estará disponible próximamente.',

      'settings_network_desc': 'Conexión a internet',
      'settings_network_info': 'Aula Lid-IA necesita conexión a internet '
        'para sincronizar tus materias, tareas y clases en vivo. Si algo '
        'no carga, revisa tu conexión y desliza hacia abajo para '
        'actualizar.',

      'settings_about_version': 'Versión',
      'settings_about_contact': 'Contacto',

      'action_save': 'Guardar',
      'action_cancel': 'Cancelar',
      'action_close': 'Cerrar',
    },
    'en': {
      'nav_home': 'Home',
      'nav_subjects_student': 'My subjects',
      'nav_subjects_teacher': 'Subjects',
      'nav_live_class_student': 'Live classes',
      'nav_live_class_teacher': 'Live class',
      'nav_upload': 'Upload content',
      'nav_students': 'Students',
      'nav_chat_ia': 'LidIA AI',
      'nav_notifications': 'Notifications',
      'nav_profile': 'My profile',
      'nav_settings': 'Settings',
      'logout': 'Log out',
      'construction_title': 'Section under construction',
      'app_name': 'Aula Lid-IA',

      'settings_title': 'Settings',
      'settings_account': 'Account',
      'settings_privacy': 'Privacy',
      'settings_notifications': 'Notifications',
      'settings_appearance': 'Appearance',
      'settings_language': 'Language',
      'settings_devices': 'Devices',
      'settings_network': 'Network',
      'settings_about': 'About',

      'settings_account_desc': 'Manage your personal information',
      'settings_avatar_title': 'Profile picture',
      'settings_avatar_subtitle': 'Tap to change your picture',
      'settings_avatar_subtitle_uploading': 'Uploading picture...',
      'settings_avatar_error': 'Could not update your profile picture.',
      'settings_name_title': 'Name and username',
      'settings_name_edit': 'Edit your name',
      'settings_email_title': 'Email',
      'settings_email_subtitle': 'Update your email address',
      'settings_password_title': 'Password',
      'settings_password_subtitle': 'Change your login password',
      'settings_linked_title': 'Linked accounts',
      'settings_linked_subtitle': 'Connect your account with other platforms',
      'settings_info_secure_title': 'Your information is safe',
      'settings_info_secure_subtitle':
        'We use security measures to protect your data.',

      'settings_privacy_desc': 'Control how your information is used',
      'settings_privacy_info': 'We only keep the information needed for '
        'your academic progress: subjects, tasks, grades and live '
        'classes. We never share your data with third parties.',
      'settings_help_title': 'Help and support',
      'settings_advanced_privacy_title': 'Advanced privacy controls',
      'settings_advanced_privacy_subtitle': 'Coming soon',

      'settings_notifications_desc': 'Choose how we should notify you',
      'settings_notifications_app_title': 'App notifications',
      'settings_notifications_app_subtitle':
        'Alerts for classes, tasks and messages',

      'settings_appearance_desc': 'Customize how the app looks',
      'theme_light': 'Light theme',
      'theme_dark': 'Dark mode',
      'theme_system': 'Use system setting',
      'theme_active': 'Currently active',
      'settings_accent_color': 'Accent color',
      'settings_accent_color_subtitle': "Choose the app's main color",
      'settings_custom_color': 'Custom',
      'settings_custom_color_hint': 'E.g.: #1D9E75',
      'settings_custom_color_apply': 'Apply',
      'settings_custom_color_invalid':
        'Invalid color code. Use the #RRGGBB format.',
      'settings_reset_color': 'Reset to original color',

      'settings_language_desc': 'Platform language',
      'lang_es': 'Español',
      'lang_en': 'English',
      'lang_current': 'Current language',

      'settings_devices_desc': 'Active sessions on your account',
      'settings_this_device': 'This device',
      'settings_devices_info': 'Managing sessions on other devices will '
        'be available soon.',

      'settings_network_desc': 'Internet connection',
      'settings_network_info': 'Aula Lid-IA needs an internet connection '
        'to sync your subjects, tasks and live classes. If something '
        "doesn't load, check your connection and pull down to refresh.",

      'settings_about_version': 'Version',
      'settings_about_contact': 'Contact',

      'action_save': 'Save',
      'action_cancel': 'Cancel',
      'action_close': 'Close',
    },
  };

  static String get(String key) {
    final code = LocaleController.instance.locale.languageCode;
    final map = _strings[code] ?? _strings['es']!;
    return map[key] ?? _strings['es']![key] ?? key;
  }
}

/// Atajo global: `tr('settings_title')` en vez de
/// `AppText.get('settings_title')`.
String tr(String key) => AppText.get(key);