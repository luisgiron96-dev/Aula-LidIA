import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_text.dart';
import '../../../core/services/theme_color_controller.dart';
import '../../../core/services/locale_controller.dart';
import '../../../core/services/avatar_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
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
  String? _avatarUrl;
  bool _loadingName = true;
  bool _notificationsOn = true;
  bool _uploadingAvatar = false;

  final _theme = ThemeColorController.instance;
  final _locale = LocaleController.instance;
  final _avatar = AvatarController.instance;

  List<_Category> get _categories => [
    _Category(Icons.person_outline, tr('settings_account')),
    _Category(Icons.shield_outlined, tr('settings_privacy')),
    _Category(Icons.notifications_outlined, tr('settings_notifications')),
    _Category(Icons.palette_outlined, tr('settings_appearance')),
    _Category(Icons.language_outlined, tr('settings_language')),
    _Category(Icons.devices_outlined, tr('settings_devices')),
    _Category(Icons.wifi_outlined, tr('settings_network')),
    _Category(Icons.info_outline, tr('settings_about')),
  ];

  AppThemeColors get _c => AppThemeColors(_theme.isDark);

  @override
  void initState() {
    super.initState();
    _theme.addListener(_onSettingsChanged);
    _locale.addListener(_onSettingsChanged);
    _avatar.addListener(_onSettingsChanged);
    _load();
  }

  @override
  void dispose() {
    _theme.removeListener(_onSettingsChanged);
    _locale.removeListener(_onSettingsChanged);
    _avatar.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final name = await SupabaseService.getUserName();
      final notif = await SupabaseService.getNotificationsEnabled();
      final avatar = await SupabaseService.getAvatarUrl();
      if (!mounted) return;
      setState(() {
        _displayName = name;
        _notificationsOn = notif;
        _avatarUrl = avatar;
        _loadingName = false;
      });
      if (avatar != null) _avatar.setAvatarUrl(avatar);
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

  // ── FOTO DE PERFIL ───────────────────────────────────
  Future<void> _pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      setState(() => _uploadingAvatar = true);

      final url = await StorageService.uploadAvatar(
        bytes, file.extension ?? 'jpg');
      await SupabaseService.updateAvatarUrl(url);

      if (!mounted) return;
      setState(() {
        _avatarUrl = url;
        _uploadingAvatar = false;
      });
      _avatar.setAvatarUrl(url);
    } catch (e) {
      // ignore: avoid_print
      print('Error subiendo foto de perfil: $e');
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('settings_avatar_error'))));
    }
  }

  // ── COLOR PERSONALIZADO ──────────────────────────────
  static const List<Color> _presetColors = [
    Color(0xFF1D9E75), // verde original
    Color(0xFF378ADD), // azul
    Color(0xFF9B7FE0), // morado
    Color(0xFFE0607E), // rosa
    Color(0xFFEF9F27), // naranja
    Color(0xFFE24B4A), // rojo
    Color(0xFF2BB3A3), // turquesa
    Color(0xFF6B7280), // gris
  ];

  Future<void> _openColorPicker() async {
    final hexCtrl = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: _c.surface,
          title: Text(tr('settings_accent_color'),
            style: TextStyle(color: _c.textPrimary)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final color in _presetColors)
                    GestureDetector(
                      onTap: () {
                        _theme.setAccentColor(color);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle,
                          border: Border.all(
                            color: _theme.accentColor.toARGB32() ==
                                color.toARGB32()
                              ? Colors.white : Colors.transparent,
                            width: 3),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3)]),
                      ),
                    ),
                ]),
                const SizedBox(height: 20),
                Text(tr('settings_custom_color'),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _c.textPrimary)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(
                    controller: hexCtrl,
                    style: TextStyle(color: _c.textPrimary),
                    decoration: InputDecoration(
                      hintText: tr('settings_custom_color_hint'),
                      isDense: true,
                      filled: true,
                      fillColor: _c.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12)))),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final parsed = _parseHexColor(hexCtrl.text);
                      if (parsed == null) {
                        setDialogState(() =>
                          error = tr('settings_custom_color_invalid'));
                        return;
                      }
                      _theme.setAccentColor(parsed);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _theme.accentColor,
                      minimumSize: const Size(0, 44)),
                    child: Text(tr('settings_custom_color_apply'))),
                ]),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(
                    color: Colors.red, fontSize: 11.5)),
                ],
              ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _theme.resetAccentColor();
                Navigator.pop(ctx);
              },
              child: Text(tr('settings_reset_color'))),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('action_close'))),
          ],
        ),
      ),
    );
  }

  Color? _parseHexColor(String input) {
    var hex = input.trim().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _c.background,
      appBar: AppBar(
        backgroundColor: _c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _c.textPrimary),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context)),
        title: Text(tr('settings_title'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
            color: _c.textPrimary)),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        if (_loadingName) {
          return Center(child: CircularProgressIndicator(
            color: _theme.accentColor));
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
          child: _buildDetail(_selected))),
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
    final categories = _categories;
    return Container(
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border)),
      child: Column(children: List.generate(categories.length, (i) {
        final cat = categories[i];
        final active = !pushOnTap && _selected == i;
        return InkWell(
          onTap: () {
            if (pushOnTap) {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: _c.background,
                  appBar: AppBar(
                    backgroundColor: _c.surface,
                    elevation: 0,
                    title: Text(cat.label,
                      style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _c.textPrimary))),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildDetail(i)))));
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
                ? _theme.accentColor.withValues(alpha: 0.10)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(cat.icon, size: 19,
                color: active ? _theme.accentColor : _c.textSecondary),
              const SizedBox(width: 12),
              Expanded(child: Text(cat.label,
                style: TextStyle(fontSize: 13.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? _theme.accentColor : _c.textPrimary))),
              Icon(Icons.chevron_right, size: 18,
                color: Colors.grey.shade400),
            ]),
          ),
        );
      })),
    );
  }

  Widget _buildDetail(int index) {
    switch (index) {
      case 0: return _accountSection();
      case 1: return _privacySection();
      case 2: return _notificationsSection();
      case 3: return _appearanceSection();
      case 4: return _languageSection();
      case 5: return _devicesSection();
      case 6: return _networkSection();
      default: return _aboutSection();
    }
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: _theme.accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: _theme.accentColor, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.w700, color: _c.textPrimary)),
          Text(subtitle, style: TextStyle(fontSize: 12,
            color: _c.textSecondary)),
        ])),
    ]);
  }

  // ── CUENTA ──────────────────────────────────────────
  Widget _accountSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.person_outline, tr('settings_account'),
        tr('settings_account_desc')),
      const SizedBox(height: 16),
      _actionTile(
        leading: _uploadingAvatar
          ? const SizedBox(width: 40, height: 40,
              child: Padding(padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2)))
          : CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF9B7FE0).withValues(alpha: 0.14),
              backgroundImage: _avatarUrl != null
                ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null
                ? const Icon(Icons.image_outlined,
                    color: Color(0xFF9B7FE0), size: 19)
                : null),
        title: tr('settings_avatar_title'),
        subtitle: _uploadingAvatar
          ? tr('settings_avatar_subtitle_uploading')
          : tr('settings_avatar_subtitle'),
        onTap: _uploadingAvatar ? () {} : _pickAndUploadAvatar),
      _actionTile(
        icon: Icons.badge_outlined, color: const Color(0xFF5B9BD9),
        title: tr('settings_name_title'),
        subtitle: _displayName.isEmpty
          ? tr('settings_name_edit') : _displayName,
        onTap: () async {
          final newName = await Navigator.push<String>(context,
            MaterialPageRoute(builder: (_) =>
              EditProfileScreen(currentName: _displayName)));
          if (newName != null && newName.isNotEmpty) {
            setState(() => _displayName = newName);
          }
        }),
      _actionTile(
        icon: Icons.email_outlined, color: _theme.accentColor,
        title: tr('settings_email_title'),
        subtitle: SupabaseService.currentUser?.email
          ?? tr('settings_email_subtitle'),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const UpdateEmailScreen()))),
      _actionTile(
        icon: Icons.lock_outline, color: const Color(0xFFEFC24B),
        title: tr('settings_password_title'),
        subtitle: tr('settings_password_subtitle'),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) =>
            const ChangePasswordScreen()))),
      _actionTile(
        icon: Icons.link, color: const Color(0xFFE0607E),
        title: tr('settings_linked_title'),
        subtitle: tr('settings_linked_subtitle'),
        onTap: () => _showComingSoon(tr('settings_linked_title'))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _theme.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(Icons.verified_user_outlined,
            color: _theme.accentColor, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('settings_info_secure_title'),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: _c.textPrimary)),
              Text(tr('settings_info_secure_subtitle'),
                style: TextStyle(fontSize: 11.5,
                  color: _c.textSecondary)),
            ])),
          Icon(Icons.check_circle, color: _theme.accentColor, size: 22),
        ]),
      ),
    ]);
  }

  // ── PRIVACIDAD ──────────────────────────────────────
  Widget _privacySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.shield_outlined, tr('settings_privacy'),
        tr('settings_privacy_desc')),
      const SizedBox(height: 16),
      _infoCard(tr('settings_privacy_info')),
      const SizedBox(height: 12),
      _actionTile(
        icon: Icons.help_outline, color: _theme.accentColor,
        title: tr('settings_help_title'),
        subtitle: 'soporte@aulalidia.com',
        onTap: () => showDialog(context: context, builder: (ctx) =>
          AlertDialog(
            backgroundColor: _c.surface,
            title: Text(tr('settings_help_title'),
              style: TextStyle(color: _c.textPrimary)),
            content: Text(
              'Si tienes dudas sobre el manejo de tu información, '
              'escríbenos a soporte@aulalidia.com',
              style: TextStyle(color: _c.textSecondary)),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text(tr('action_close')))]))),
      _actionTile(
        icon: Icons.tune_outlined, color: const Color(0xFF9B7FE0),
        title: tr('settings_advanced_privacy_title'),
        subtitle: tr('settings_advanced_privacy_subtitle'),
        onTap: () => _showComingSoon(tr('settings_advanced_privacy_title'))),
    ]);
  }

  // ── NOTIFICACIONES ──────────────────────────────────
  Widget _notificationsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.notifications_outlined,
        tr('settings_notifications'), tr('settings_notifications_desc')),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _c.border)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6),
          child: Row(children: [
            Icon(Icons.notifications_active_outlined,
              size: 18, color: _c.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('settings_notifications_app_title'),
                  style: TextStyle(fontSize: 13,
                    color: _c.textPrimary)),
                Text(tr('settings_notifications_app_subtitle'),
                  style: TextStyle(fontSize: 10.5,
                    color: _c.textSecondary)),
              ])),
            Switch(
              value: _notificationsOn,
              activeThumbColor: _theme.accentColor,
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
      _sectionHeader(Icons.palette_outlined, tr('settings_appearance'),
        tr('settings_appearance_desc')),
      const SizedBox(height: 16),
      _themeTile(ThemeMode.light, Icons.light_mode_outlined,
        tr('theme_light')),
      _themeTile(ThemeMode.dark, Icons.dark_mode_outlined,
        tr('theme_dark')),
      _themeTile(ThemeMode.system, Icons.settings_suggest_outlined,
        tr('theme_system')),
      const SizedBox(height: 8),
      _actionTile(
        icon: Icons.color_lens_outlined, color: _theme.accentColor,
        title: tr('settings_accent_color'),
        subtitle: tr('settings_accent_color_subtitle'),
        trailing: Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: _theme.accentColor,
            shape: BoxShape.circle,
            border: Border.all(color: _c.border)),
        ),
        onTap: _openColorPicker),
    ]);
  }

  Widget _themeTile(ThemeMode mode, IconData icon, String label) {
    final selected = _theme.themeMode == mode;
    return InkWell(
      onTap: () => _theme.setThemeMode(mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
              ? _theme.accentColor.withValues(alpha: 0.5)
              : _c.border)),
        child: Row(children: [
          Icon(icon, size: 18,
            color: selected ? _theme.accentColor : _c.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13.5,
                fontWeight: FontWeight.w600, color: _c.textPrimary)),
              if (selected)
                Text(tr('theme_active'), style: TextStyle(fontSize: 11.5,
                  color: _c.textSecondary)),
            ])),
          if (selected)
            Icon(Icons.check_circle, color: _theme.accentColor, size: 20),
        ]),
      ),
    );
  }

  // ── IDIOMA ───────────────────────────────────────────
  Widget _languageSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.language_outlined, tr('settings_language'),
        tr('settings_language_desc')),
      const SizedBox(height: 16),
      _languageTile('es', tr('lang_es')),
      _languageTile('en', tr('lang_en')),
    ]);
  }

  Widget _languageTile(String code, String label) {
    final selected = _locale.locale.languageCode == code;
    return InkWell(
      onTap: () => _locale.setLocale(Locale(code)),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
              ? _theme.accentColor.withValues(alpha: 0.5)
              : _c.border)),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13.5,
                fontWeight: FontWeight.w600, color: _c.textPrimary)),
              if (selected)
                Text(tr('lang_current'), style: TextStyle(fontSize: 11.5,
                  color: _c.textSecondary)),
            ])),
          if (selected)
            Icon(Icons.check_circle, color: _theme.accentColor, size: 20),
        ]),
      ),
    );
  }

  // ── DISPOSITIVOS ─────────────────────────────────────
  Widget _devicesSection() {
    final platform = Theme.of(context).platform.name;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.devices_outlined, tr('settings_devices'),
        tr('settings_devices_desc')),
      const SizedBox(height: 16),
      _staticOptionTile(tr('settings_this_device'), platform, selected: true),
      const SizedBox(height: 4),
      _infoCard(tr('settings_devices_info')),
    ]);
  }

  // ── RED ──────────────────────────────────────────────
  Widget _networkSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.wifi_outlined, tr('settings_network'),
        tr('settings_network_desc')),
      const SizedBox(height: 16),
      _infoCard(tr('settings_network_info')),
    ]);
  }

  // ── ACERCA DE ────────────────────────────────────────
  Widget _aboutSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.info_outline, tr('settings_about'),
        'Información de la aplicación'),
      const SizedBox(height: 16),
      _staticOptionTile('Aula Lid-IA', 'Aprender sin distancia'),
      _staticOptionTile(tr('settings_about_version'), '1.0.0'),
      _actionTile(
        icon: Icons.mail_outline, color: _theme.accentColor,
        title: tr('settings_about_contact'),
        subtitle: 'soporte@aulalidia.com',
        onTap: () {}),
    ]);
  }

  // ── WIDGETS BASE ─────────────────────────────────────
  Widget _actionTile({
    IconData? icon, Color? color, Widget? leading,
    required String title, required String subtitle,
    required VoidCallback onTap, Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
          child: Row(children: [
            leading ?? Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (color ?? _theme.accentColor)
                  .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color ?? _theme.accentColor,
                size: 19)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _c.textPrimary)),
                Text(subtitle, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5,
                    color: _c.textSecondary)),
              ])),
            trailing ?? Icon(Icons.chevron_right, size: 18,
              color: Colors.grey.shade400),
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
        color: _c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
            ? _theme.accentColor.withValues(alpha: 0.4)
            : _c.border)),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13.5,
              fontWeight: FontWeight.w600, color: _c.textPrimary)),
            Text(subtitle, style: TextStyle(fontSize: 11.5,
              color: _c.textSecondary)),
          ])),
        if (selected)
          Icon(Icons.check_circle, color: _theme.accentColor, size: 20),
      ]),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.border)),
      child: Text(text, style: TextStyle(fontSize: 12,
        color: _c.textSecondary, height: 1.4)),
    );
  }
}

class _Category {
  final IconData icon;
  final String label;
  const _Category(this.icon, this.label);
}
