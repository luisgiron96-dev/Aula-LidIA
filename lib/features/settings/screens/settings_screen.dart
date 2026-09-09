import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../student/screens/change_password_screen.dart';
import '../../student/screens/edit_profile_screen.dart';
import 'update_email_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SettingsScreen({super.key, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selected = 0;
  String _displayName = '';
  bool _loadingName = true;
  bool _notificationsOn = true;

  final List<_Category> _categories = const [
    _Category(Icons.person_outline, 'Cuenta'),
    _Category(Icons.shield_outlined, 'Privacidad'),
    _Category(Icons.notifications_outlined, 'Notificaciones'),
    _Category(Icons.palette_outlined, 'Apariencia'),
    _Category(Icons.language_outlined, 'Idioma'),
    _Category(Icons.devices_outlined, 'Dispositivos'),
    _Category(Icons.wifi_outlined, 'Red'),
    _Category(Icons.info_outline, 'Acerca de'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final name = await SupabaseService.getUserName();
      final notif = await SupabaseService.getNotificationsEnabled();
      if (!mounted) return;
      setState(() {
        _displayName = name;
        _notificationsOn = notif;
        _loadingName = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando configuración: $e');
      if (!mounted) return;
      setState(() => _loadingName = false);
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$feature estará disponible próximamente.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context)),
        title: const Text('Configuración',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        if (_loadingName) {
          return const Center(child: CircularProgressIndicator(
            color: AppColors.primary));
        }
        return isWide ? _buildWideLayout() : _buildNarrowLayout();
      }),
    );
  }

  // ── ESCRITORIO / TABLET ANCHA: lista + panel lado a lado ──
  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 260, child: _buildCategoryList(pushOnTap: false)),
        const SizedBox(width: 20),
        Expanded(child: SingleChildScrollView(
          child: _buildDetail(_categories[_selected].label))),
      ]),
    );
  }

  // ── MÓVIL: solo la lista, cada item abre su propia pantalla ──
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildCategoryList(pushOnTap: true),
    );
  }

  Widget _buildCategoryList({required bool pushOnTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: List.generate(_categories.length, (i) {
        final cat = _categories[i];
        final active = !pushOnTap && _selected == i;
        return InkWell(
          onTap: () {
            if (pushOnTap) {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: const Color(0xFFF5F5F5),
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: Text(cat.label,
                      style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary))),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildDetail(cat.label)))));
            } else {
              setState(() => _selected = i);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: active
                ? AppColors.primary.withValues(alpha: 0.10)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(cat.icon, size: 19,
                color: active ? AppColors.primary
                  : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(child: Text(cat.label,
                style: TextStyle(fontSize: 13.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? AppColors.primaryDark
                    : AppColors.textPrimary))),
              Icon(Icons.chevron_right, size: 18,
                color: Colors.grey.shade400),
            ]),
          ),
        );
      })),
    );
  }

  Widget _buildDetail(String category) {
    switch (category) {
      case 'Cuenta': return _accountSection();
      case 'Privacidad': return _privacySection();
      case 'Notificaciones': return _notificationsSection();
      case 'Apariencia': return _appearanceSection();
      case 'Idioma': return _languageSection();
      case 'Dispositivos': return _devicesSection();
      case 'Red': return _networkSection();
      default: return _aboutSection();
    }
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 12,
            color: AppColors.textSecondary)),
        ])),
    ]);
  }

  // ── CUENTA ──────────────────────────────────────────
  Widget _accountSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.person_outline, 'Cuenta',
        'Gestiona tu información personal'),
      const SizedBox(height: 16),
      _actionTile(
        icon: Icons.image_outlined, color: const Color(0xFF9B7FE0),
        title: 'Foto de perfil',
        subtitle: 'Cambia tu foto de perfil',
        onTap: () => _showComingSoon('La foto de perfil')),
      _actionTile(
        icon: Icons.badge_outlined, color: const Color(0xFF5B9BD9),
        title: 'Nombre y usuario',
        subtitle: _displayName.isEmpty
          ? 'Edita tu nombre' : _displayName,
        onTap: () async {
          final newName = await Navigator.push<String>(context,
            MaterialPageRoute(builder: (_) =>
              EditProfileScreen(currentName: _displayName)));
          if (newName != null && newName.isNotEmpty) {
            setState(() => _displayName = newName);
          }
        }),
      _actionTile(
        icon: Icons.email_outlined, color: AppColors.primary,
        title: 'Correo electrónico',
        subtitle: SupabaseService.currentUser?.email
          ?? 'Actualiza tu correo electrónico',
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const UpdateEmailScreen()))),
      _actionTile(
        icon: Icons.lock_outline, color: const Color(0xFFEFC24B),
        title: 'Contraseña',
        subtitle: 'Cambia tu contraseña de acceso',
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) =>
            const ChangePasswordScreen()))),
      _actionTile(
        icon: Icons.link, color: const Color(0xFFE0607E),
        title: 'Vinculación de cuentas',
        subtitle: 'Conecta tu cuenta con otras plataformas',
        onTap: () => _showComingSoon('La vinculación de cuentas')),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.verified_user_outlined,
            color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tu información está segura',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
              Text('Utilizamos medidas de seguridad para proteger '
                'tus datos.',
                style: TextStyle(fontSize: 11.5,
                  color: AppColors.textSecondary)),
            ])),
          const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
        ]),
      ),
    ]);
  }

  // ── PRIVACIDAD ──────────────────────────────────────
  Widget _privacySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.shield_outlined, 'Privacidad',
        'Controla el uso de tu información'),
      const SizedBox(height: 16),
      _infoCard(
        'Guardamos solo la información necesaria para tu progreso '
        'académico: materias, tareas, calificaciones y clases en vivo. '
        'No compartimos tus datos con terceros.'),
      const SizedBox(height: 12),
      _actionTile(
        icon: Icons.help_outline, color: AppColors.primary,
        title: 'Ayuda y soporte',
        subtitle: 'soporte@aulalidia.com',
        onTap: () => showDialog(context: context, builder: (ctx) =>
          AlertDialog(
            title: const Text('Ayuda y soporte'),
            content: const Text(
              'Si tienes dudas sobre el manejo de tu información, '
              'escríbenos a soporte@aulalidia.com'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'))]))),
      _actionTile(
        icon: Icons.tune_outlined, color: const Color(0xFF9B7FE0),
        title: 'Controles avanzados de privacidad',
        subtitle: 'Próximamente',
        onTap: () => _showComingSoon('Los controles avanzados')),
    ]);
  }

  // ── NOTIFICACIONES ──────────────────────────────────
  Widget _notificationsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.notifications_outlined, 'Notificaciones',
        'Elige cómo quieres que te avisemos'),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6),
          child: Row(children: [
            const Icon(Icons.notifications_active_outlined,
              size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notificaciones de la app',
                  style: TextStyle(fontSize: 13,
                    color: AppColors.textPrimary)),
                Text('Alertas de clases, tareas y mensajes',
                  style: TextStyle(fontSize: 10.5,
                    color: AppColors.textSecondary)),
              ])),
            Switch(
              value: _notificationsOn,
              activeThumbColor: AppColors.primary,
              onChanged: (v) async {
                setState(() => _notificationsOn = v);
                try {
                  await SupabaseService.setNotificationsEnabled(v);
                } catch (e) {
                  // ignore: avoid_print
                  print('Error guardando preferencia: $e');
                }
              }),
          ]),
        ),
      ),
    ]);
  }

  // ── APARIENCIA ───────────────────────────────────────
  Widget _appearanceSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.palette_outlined, 'Apariencia',
        'Personaliza cómo se ve la app'),
      const SizedBox(height: 16),
      _staticOptionTile('Tema claro', 'Activo actualmente', selected: true),
      _staticOptionTile('Modo oscuro', 'Próximamente'),
    ]);
  }

  // ── IDIOMA ───────────────────────────────────────────
  Widget _languageSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.language_outlined, 'Idioma',
        'Idioma de la plataforma'),
      const SizedBox(height: 16),
      _staticOptionTile('Español', 'Idioma actual', selected: true),
      _staticOptionTile('English', 'Próximamente'),
    ]);
  }

  // ── DISPOSITIVOS ─────────────────────────────────────
  Widget _devicesSection() {
    final platform = Theme.of(context).platform.name;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.devices_outlined, 'Dispositivos',
        'Sesiones activas de tu cuenta'),
      const SizedBox(height: 16),
      _staticOptionTile('Este dispositivo', platform, selected: true),
      const SizedBox(height: 4),
      _infoCard('La gestión de sesiones en otros dispositivos estará '
        'disponible próximamente.'),
    ]);
  }

  // ── RED ──────────────────────────────────────────────
  Widget _networkSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.wifi_outlined, 'Red',
        'Conexión a internet'),
      const SizedBox(height: 16),
      _infoCard('Aula Lid-IA necesita conexión a internet para '
        'sincronizar tus materias, tareas y clases en vivo. Si algo no '
        'carga, revisa tu conexión y desliza hacia abajo para '
        'actualizar.'),
    ]);
  }

  // ── ACERCA DE ────────────────────────────────────────
  Widget _aboutSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.info_outline, 'Acerca de',
        'Información de la aplicación'),
      const SizedBox(height: 16),
      _staticOptionTile('Aula Lid-IA', 'Aprender sin distancia'),
      _staticOptionTile('Versión', '1.0.0'),
      _actionTile(
        icon: Icons.mail_outline, color: AppColors.primary,
        title: 'Contacto',
        subtitle: 'soporte@aulalidia.com',
        onTap: () {}),
    ]);
  }

  // ── WIDGETS BASE ─────────────────────────────────────
  Widget _actionTile({
    required IconData icon, required Color color,
    required String title, required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 19)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
                Text(subtitle, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5,
                    color: AppColors.textSecondary)),
              ])),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ]),
        ),
      ),
    );
  }

  Widget _staticOptionTile(String title, String subtitle,
      {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary.withValues(alpha: 0.4)
            : Colors.grey.shade200)),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13.5,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 11.5,
              color: AppColors.textSecondary)),
          ])),
        if (selected)
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
      ]),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200)),
      child: Text(text, style: const TextStyle(fontSize: 12,
        color: AppColors.textSecondary, height: 1.4)),
    );
  }
}

class _Category {
  final IconData icon;
  final String label;
  const _Category(this.icon, this.label);
}
