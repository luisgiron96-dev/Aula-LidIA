import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/student/screens/student_home_screen.dart';
import '../../features/teacher/screens/teacher_home_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/chat_ia/screens/chat_ia_screen.dart';
import '../../features/auth/screens/login_screen.dart';

class MainLayout extends StatefulWidget {
  final String role; // 'student' | 'teacher'
  const MainLayout({super.key, required this.role});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

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

  Widget get _currentScreen {
    if (widget.role == 'student') {
      switch (_selectedIndex) {
        case 0: return const StudentHomeScreen();
        case 3: return const ChatIAScreen();
        case 4: return const NotificationsScreen();
        default: return _PlaceholderScreen(
          label: _items[_selectedIndex].label);
      }
    } else {
      switch (_selectedIndex) {
        case 0: return const TeacherHomeScreen();
        case 4: return const ChatIAScreen();
        case 5: return const NotificationsScreen();
        default: return _PlaceholderScreen(
          label: _items[_selectedIndex].label);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == 'student';
    final avatarColor = isStudent
      ? AppColors.studentColor
      : AppColors.teacherColor;
    final avatarText = isStudent ? 'VA' : 'MP';
    final avatarTextColor = isStudent
      ? AppColors.primaryDark
      : AppColors.accent;
    final userName = isStudent
      ? 'Valentina A.' : 'Prof. Mariela P.';
    final userRole = isStudent ? 'Estudiante · 7°' : 'Docente · Matemáticas';

    return Scaffold(
      body: Row(children: [

        // ── SIDEBAR ──────────────────────────────────
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
                  child: Text(avatarText,
                    style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: avatarTextColor))),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
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

            // Divisor
            Divider(color: Colors.white12,
              height: 1, indent: 10, endIndent: 10),
            const SizedBox(height: 8),

            // Items de navegación
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  final active = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: _sidebarExpanded ? 12 : 0,
                        vertical: 10),
                      decoration: BoxDecoration(
                        color: active
                          ? AppColors.primary.withOpacity(0.25)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: active
                          ? Border.all(
                              color: AppColors.primary.withOpacity(0.4))
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
              onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen())),
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

        // ── CONTENIDO PRINCIPAL ───────────────────────
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