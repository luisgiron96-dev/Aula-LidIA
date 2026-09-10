import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../core/services/avatar_controller.dart';
import '../../core/services/locale_controller.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/theme_color_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../features/student/screens/student_home_screen.dart';
import '../../features/student/screens/student_profile_screen.dart';
import '../../features/subjects/screens/subjects_list_screen.dart';
import '../../features/teacher/screens/teacher_home_screen.dart';
import '../../features/teacher/screens/teacher_profile_screen.dart';
import '../../features/teacher/screens/students_list_screen.dart';
import '../../features/teacher/screens/subjects_screen.dart';
import '../../features/teacher/screens/upload_content_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/chat_ia/screens/chat_ia_screen.dart';
import '../../features/live_class/screens/live_class_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

const double kMobileBreakpoint = 700;

class MainLayout extends StatefulWidget {
  final String role;
  const MainLayout({super.key, required this.role});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex  = 0;
  bool _sidebarExpanded = true;
  String _userName    = '';

  final _theme = ThemeColorController.instance;
  final _locale = LocaleController.instance;
  final _avatar = AvatarController.instance;
  AppThemeColors get _c => AppThemeColors(_theme.isDark);

  @override
  void initState() {
    super.initState();
    _theme.addListener(_onSettingsChanged);
    _locale.addListener(_onSettingsChanged);
    _avatar.addListener(_onSettingsChanged);
    _loadUserData();
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

  Future<void> _loadUserData() async {
    final name = await SupabaseService.getUserName();
    final avatar = await SupabaseService.getAvatarUrl();
    if (avatar != null) _avatar.setAvatarUrl(avatar);
    if (mounted) {
      setState(() {
        _userName = name.isNotEmpty
          ? name
          : (widget.role == 'student' ? 'Estudiante' : 'Docente');
      });
    }
  }

  List<_NavItem> get _items {
    if (widget.role == 'student') {
      return [
        _NavItem(icon: Icons.home_outlined,
          iconActive: Icons.home, navKey: 'nav_home'),
        _NavItem(icon: Icons.menu_book_outlined,
          iconActive: Icons.menu_book, navKey: 'nav_subjects_student'),
        _NavItem(icon: Icons.videocam_outlined,
          iconActive: Icons.videocam, navKey: 'nav_live_class_student'),
        _NavItem(icon: Icons.smart_toy_outlined,
          iconActive: Icons.smart_toy, navKey: 'nav_chat_ia'),
        _NavItem(icon: Icons.notifications_outlined,
          iconActive: Icons.notifications, navKey: 'nav_notifications'),
        _NavItem(icon: Icons.person_outline,
          iconActive: Icons.person, navKey: 'nav_profile'),
        _NavItem(icon: Icons.settings_outlined,
          iconActive: Icons.settings, navKey: 'nav_settings'),
      ];
    } else {
      return [
        _NavItem(icon: Icons.home_outlined,
          iconActive: Icons.home, navKey: 'nav_home'),
        _NavItem(icon: Icons.upload_outlined,
          iconActive: Icons.upload, navKey: 'nav_upload'),
        _NavItem(icon: Icons.videocam_outlined,
          iconActive: Icons.videocam, navKey: 'nav_live_class_teacher'),
        _NavItem(icon: Icons.people_outline,
          iconActive: Icons.people, navKey: 'nav_students'),
        _NavItem(icon: Icons.menu_book_outlined,
          iconActive: Icons.menu_book, navKey: 'nav_subjects_teacher'),
        _NavItem(icon: Icons.smart_toy_outlined,
          iconActive: Icons.smart_toy, navKey: 'nav_chat_ia'),
        _NavItem(icon: Icons.notifications_outlined,
          iconActive: Icons.notifications, navKey: 'nav_notifications'),
        _NavItem(icon: Icons.person_outline,
          iconActive: Icons.person, navKey: 'nav_profile'),
        _NavItem(icon: Icons.settings_outlined,
          iconActive: Icons.settings, navKey: 'nav_settings'),
      ];
    }
  }

  int get _notificationsIndex =>
    _items.indexWhere((i) => i.navKey == 'nav_notifications');
  int get _profileIndex =>
    _items.indexWhere((i) => i.navKey == 'nav_profile');
  int get _settingsIndex =>
    _items.indexWhere((i) => i.navKey == 'nav_settings');

  List<int> get _mobileNavIndices =>
    List.generate(_items.length, (i) => i)
      .where((i) => i != _notificationsIndex
        && i != _profileIndex && i != _settingsIndex)
      .toList();

  String get _avatarText {
    if (_userName.isEmpty) {
      return widget.role == 'student' ? 'VA' : 'MP';
    }
    final parts = _userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _userName[0].toUpperCase();
  }

  Widget get _currentScreen {
    if (widget.role == 'student') {
      switch (_selectedIndex) {
        case 0: return StudentHomeScreen(userName: _userName);
        case 1: return const SubjectsListScreen();
        case 2: return const LiveClassesScreen(role: 'student');
        case 3: return const ChatIAScreen(role: 'student');
        case 4: return const NotificationsScreen();
        case 5: return StudentProfileScreen(userName: _userName);
        case 6: return const SettingsScreen();
        default: return _PlaceholderScreen(
          label: _items[_selectedIndex].label);
      }
    } else {
      switch (_selectedIndex) {
        case 0: return TeacherHomeScreen(userName: _userName);
        case 1: return const UploadContentScreen();
        case 2: return const LiveClassesScreen(role: 'teacher');
        case 3: return const StudentsListScreen();
        case 4: return const TeacherSubjectsScreen();
        case 5: return const ChatIAScreen(role: 'teacher');
        case 6: return const NotificationsScreen();
        case 7: return TeacherProfileScreen(userName: _userName);
        case 8: return const SettingsScreen();
        default: return _PlaceholderScreen(
          label: _items[_selectedIndex].label);
      }
    }
  }

  Future<void> _logout() async {
    await SupabaseService.logout();
    if (mounted) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < kMobileBreakpoint;
        return isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context);
      },
    );
  }

  // ── LAYOUT MÓVIL ─────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    final isStudent = widget.role == 'student';
    final avatarColor = isStudent
      ? AppColors.studentColor : AppColors.teacherColor;
    final avatarTextColor = isStudent
      ? AppColors.primaryDark : AppColors.accent;

    return Scaffold(
      backgroundColor: _c.background,
      appBar: AppBar(
        backgroundColor: _c.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: _theme.accentColor,
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.school,
              color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Text('Aula Lid-IA',
            style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _c.textPrimary)),
        ]),
        actions: [
          IconButton(
            icon: Icon(
              _selectedIndex == _notificationsIndex
                ? Icons.notifications
                : Icons.notifications_outlined,
              color: _c.textSecondary),
            onPressed: () => setState(() =>
              _selectedIndex = _notificationsIndex)),
          GestureDetector(
            onTap: () => setState(
              () => _selectedIndex = _profileIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: avatarColor,
                backgroundImage: _avatar.avatarUrl != null
                  ? NetworkImage(_avatar.avatarUrl!) : null,
                child: _avatar.avatarUrl == null
                  ? Text(_avatarText,
                      style: TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: avatarTextColor))
                  : null))),
          IconButton(
            icon: Icon(
              _selectedIndex == _settingsIndex
                ? Icons.settings
                : Icons.settings_outlined,
              color: _c.textSecondary, size: 20),
            onPressed: () => setState(() =>
              _selectedIndex = _settingsIndex)),
          IconButton(
            icon: const Icon(Icons.logout,
              color: AppColors.error, size: 20),
            onPressed: _logout),
        ],
      ),
      body: _currentScreen,
      bottomNavigationBar: _MobileBottomNav(
        items: _mobileNavIndices.map((i) => _items[i]).toList(),
        selectedRealIndex: _selectedIndex,
        realIndices: _mobileNavIndices,
        accentColor: _theme.accentColor,
        onTap: (realIndex) =>
          setState(() => _selectedIndex = realIndex),
      ),
    );
  }

  // ── LAYOUT ESCRITORIO ─────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    final isStudent = widget.role == 'student';
    final avatarColor = isStudent
      ? AppColors.studentColor : AppColors.teacherColor;
    final avatarTextColor = isStudent
      ? AppColors.primaryDark : AppColors.accent;
    final userRole = isStudent ? 'Estudiante' : 'Docente';

    return Scaffold(
      body: Row(children: [

        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: _sidebarExpanded ? 220 : 64,
          color: const Color(0xFF0D3D2B),
          child: Column(children: [

            // Logo
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 18),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _theme.accentColor,
                    borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.school,
                    color: Colors.white, size: 18)),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aula Lid-IA',
                          style: TextStyle(color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                        Text('Aprender sin distancia',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9)),
                      ])),
                ],
                GestureDetector(
                  onTap: () => setState(() =>
                    _sidebarExpanded = !_sidebarExpanded),
                  child: Icon(
                    _sidebarExpanded
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                    color: Colors.white54, size: 20)),
              ]),
            ),

            // Perfil mini
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: avatarColor,
                  backgroundImage: _avatar.avatarUrl != null
                    ? NetworkImage(_avatar.avatarUrl!) : null,
                  child: _avatar.avatarUrl == null
                    ? Text(_avatarText,
                        style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: avatarTextColor))
                    : null),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                      Text(userRole,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9)),
                    ])),
                ],
              ]),
            ),
            const SizedBox(height: 8),

            Divider(color: Colors.white12,
              height: 1, indent: 10, endIndent: 10),
            const SizedBox(height: 8),

            // Navegación
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  final active = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () =>
                      setState(() => _selectedIndex = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: _sidebarExpanded ? 12 : 0,
                        vertical: 10),
                      decoration: BoxDecoration(
                        color: active
                          ? _theme.accentColor.withValues(alpha: 0.25)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: active
                          ? Border.all(color: _theme.accentColor
                              .withValues(alpha: 0.4))
                          : null),
                      child: Row(
                        mainAxisAlignment: _sidebarExpanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                        children: [
                          Icon(
                            active ? item.iconActive : item.icon,
                            color: active
                              ? _theme.accentColor
                              : Colors.white54,
                            size: 20),
                          if (_sidebarExpanded) ...[
                            const SizedBox(width: 10),
                            Text(item.label,
                              style: TextStyle(
                                fontSize: 13,
                                color: active
                                  ? Colors.white
                                  : Colors.white60,
                                fontWeight: active
                                  ? FontWeight.w500
                                  : FontWeight.normal)),
                          ],
                        ]),
                    ),
                  );
                }),
            ),

            // Cerrar sesión
            Divider(color: Colors.white12,
              height: 1, indent: 10, endIndent: 10),
            GestureDetector(
              onTap: _logout,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(
                  horizontal: _sidebarExpanded ? 12 : 0,
                  vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: _sidebarExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout,
                      color: Colors.red, size: 18),
                    if (_sidebarExpanded) ...[
                      const SizedBox(width: 10),
                      Text(tr('logout'),
                        style: const TextStyle(
                          color: Colors.red, fontSize: 13)),
                    ],
                  ]),
              )),
            const SizedBox(height: 8),
          ]),
        ),

        Expanded(child: _currentScreen),
      ]),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData iconActive;
  final String navKey;
  const _NavItem({required this.icon,
    required this.iconActive, required this.navKey});
  String get label => tr(navKey);
}

class _MobileBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final List<int> realIndices;
  final int selectedRealIndex;
  final Color accentColor;
  final ValueChanged<int> onTap;

  const _MobileBottomNav({
    required this.items,
    required this.realIndices,
    required this.selectedRealIndex,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D3D2B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2)),
        ]),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final realIndex = realIndices[i];
              final active = selectedRealIndex == realIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(realIndex),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? item.iconActive : item.icon,
                        color: active
                          ? accentColor
                          : Colors.white54,
                        size: 22),
                      const SizedBox(height: 3),
                      Text(item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: active
                            ? Colors.white
                            : Colors.white54,
                          fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.normal)),
                    ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeColorController.instance.isDark;
    final c = AppThemeColors(isDark);
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_outlined,
              size: 48, color: c.textSecondary),
            const SizedBox(height: 12),
            Text(label,
              style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w500,
                color: c.textPrimary)),
            const SizedBox(height: 8),
            Text(tr('construction_title'),
              style: TextStyle(fontSize: 14,
                color: c.textSecondary)),
          ]),
      ),
    );
  }
}