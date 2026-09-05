import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../features/student/screens/student_home_screen.dart';
import '../../features/student/screens/student_profile_screen.dart';
import '../../features/subjects/screens/subjects_list_screen.dart';
import '../../features/teacher/screens/teacher_home_screen.dart';
import '../../features/teacher/screens/teacher_profile_screen.dart';
import '../../features/teacher/screens/students_list_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/chat_ia/screens/chat_ia_screen.dart';
import '../../features/live_class/screens/live_class_screen.dart';
import '../../features/auth/screens/login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SupabaseService.getUserName();
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
          iconActive: Icons.home, label: 'Inicio'),
        _NavItem(icon: Icons.menu_book_outlined,
          iconActive: Icons.menu_book, label: 'Mis materias'),
        _NavItem(icon: Icons.videocam_outlined,
          iconActive: Icons.videocam, label: 'Clases en vivo'),
        _NavItem(icon: Icons.smart_toy_outlined,
          iconActive: Icons.smart_toy, label: 'LidIA IA'),
        _NavItem(icon: Icons.notifications_outlined,
          iconActive: Icons.notifications, label: 'Notificaciones'),
        _NavItem(icon: Icons.person_outline,
          iconActive: Icons.person, label: 'Mi perfil'),
      ];
    } else {
      return [
        _NavItem(icon: Icons.home_outlined,
          iconActive: Icons.home, label: 'Inicio'),
        _NavItem(icon: Icons.upload_outlined,
          iconActive: Icons.upload, label: 'Subir contenido'),
        _NavItem(icon: Icons.videocam_outlined,
          iconActive: Icons.videocam, label: 'Clase en vivo'),
        _NavItem(icon: Icons.people_outline,
          iconActive: Icons.people, label: 'Estudiantes'),
        _NavItem(icon: Icons.smart_toy_outlined,
          iconActive: Icons.smart_toy, label: 'LidIA IA'),
        _NavItem(icon: Icons.notifications_outlined,
          iconActive: Icons.notifications, label: 'Notificaciones'),
        _NavItem(icon: Icons.person_outline,
          iconActive: Icons.person, label: 'Mi perfil'),
      ];
    }
  }

  int get _notificationsIndex =>
    _items.indexWhere((i) => i.label == 'Notificaciones');
  int get _profileIndex =>
    _items.indexWhere((i) => i.label == 'Mi perfil');

  List<int> get _mobileNavIndices =>
    List.generate(_items.length, (i) => i)
      .where((i) => i != _notificationsIndex && i != _profileIndex)
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
        case 3: return const ChatIAScreen();
        case 4: return const NotificationsScreen();
        case 5: return StudentProfileScreen(userName: _userName);
        default: return _PlaceholderScreen(
          label: _items[_selectedIndex].label);
      }
    } else {
      switch (_selectedIndex) {
        case 0: return TeacherHomeScreen(userName: _userName);
        case 2: return const LiveClassesScreen(role: 'teacher');
        case 3: return const StudentsListScreen();
        case 4: return const ChatIAScreen();
        case 5: return const NotificationsScreen();
        case 6: return TeacherProfileScreen(userName: _userName);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.school,
              color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          const Text('Aula Lid-IA',
            style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
        ]),
        actions: [
          IconButton(
            icon: Icon(
              _selectedIndex == _notificationsIndex
                ? Icons.notifications
                : Icons.notifications_outlined,
              color: AppColors.textSecondary),
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
                child: Text(_avatarText,
                  style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: avatarTextColor))))),
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
                    color: AppColors.primary,
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
                  child: Text(_avatarText,
                    style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: avatarTextColor))),
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
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: active
                          ? Border.all(color: AppColors.primary
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
                              ? AppColors.primaryLight
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
                      const Text('Cerrar sesión',
                        style: TextStyle(
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
  final String label;
  const _NavItem({required this.icon,
    required this.iconActive, required this.label});
}

class _MobileBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final List<int> realIndices;
  final int selectedRealIndex;
  final ValueChanged<int> onTap;

  const _MobileBottomNav({
    required this.items,
    required this.realIndices,
    required this.selectedRealIndex,
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
                          ? AppColors.primaryLight
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined,
              size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(label,
              style: const TextStyle(fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Sección en construcción',
              style: TextStyle(fontSize: 14,
                color: AppColors.textSecondary)),
          ]),
      ),
    );
  }
}