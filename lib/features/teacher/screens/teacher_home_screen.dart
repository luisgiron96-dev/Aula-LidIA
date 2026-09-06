import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../live_class/screens/live_class_screen.dart';
import '../../live_class/screens/create_live_class_screen.dart';
import '../../tasks/screens/teacher_tasks_screen.dart';
import '../controllers/teacher_controller.dart';
import 'upload_content_screen.dart';
import 'students_list_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  final String userName;
  const TeacherHomeScreen({super.key, this.userName = 'Docente'});
  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _tabIndex = 0;
  bool _loading = true;
  int _studentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final students = await TeacherController.fetchStudents();
      if (!mounted) return;
      setState(() {
        _studentsCount = students.length;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando estadísticas: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.school, color: Colors.white, size: 18)),
          const SizedBox(width: 8),
          const Text('Aula Lid-IA · Docente',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
            onPressed: () {}),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.teacherColor,
            child: Text('MP',
              style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.accent))),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Banner docente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF185FA5), Color(0xFF0D3D6B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Hola, ${widget.userName}! 👋',
                        style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        _loading
                          ? 'Cargando...'
                          : '$_studentsCount estudiantes en la plataforma',
                        style: const TextStyle(fontSize: 12,
                          color: Colors.white70)),
                    ]),
                  const Text('👩🏽‍🏫', style: TextStyle(fontSize: 36)),
                ]),
            ),
            const SizedBox(height: 16),

            // Accesos rápidos (van directo a las pantallas reales)
            const Text('Accesos rápidos',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: [
                _QuickAction(
                  icon: Icons.upload_outlined,
                  label: 'Subir contenido',
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const UploadContentScreen()))),
                _QuickAction(
                  icon: Icons.videocam_outlined,
                  label: 'Clase en vivo',
                  color: AppColors.accent,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) =>
                        const LiveClassesScreen(role: 'teacher')))),
                _QuickAction(
                  icon: Icons.people_outline,
                  label: 'Estudiantes',
                  color: const Color(0xFF534AB7),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const StudentsListScreen()))),
                _QuickAction(
                  icon: Icons.checklist_outlined,
                  label: 'Tareas',
                  color: const Color(0xFFEF9F27),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const TeacherTasksScreen()))),
              ],
            ),
            const SizedBox(height: 16),

            // Programar clase en vivo (acceso directo adicional)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const CreateLiveClassScreen())),
                icon: const Icon(Icons.calendar_month_outlined, size: 16),
                label: const Text('Programar clase en vivo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: Colors.grey.shade300))),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
            style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary))),
          Icon(Icons.chevron_right, size: 16,
            color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}