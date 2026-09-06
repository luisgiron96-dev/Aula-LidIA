import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/models/student_summary_model.dart';
import '../../live_class/controllers/live_class_controller.dart';
import '../../live_class/screens/live_class_screen.dart';
import '../../live_class/screens/create_live_class_screen.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../tasks/screens/teacher_tasks_screen.dart';
import '../controllers/teacher_controller.dart';
import 'upload_content_screen.dart';
import 'student_grades_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  final String userName;
  const TeacherHomeScreen({super.key, this.userName = 'Docente'});
  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _tabIndex = 0;
  bool _loading = true;

  List<StudentSummaryModel> _students = [];
  int _lessonsCount = 0;
  int _tasksCreated = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final students = await TeacherController.fetchStudents();

      final userId = SupabaseService.currentUser?.id;
      int lessonsCount = 0;
      if (userId != null) {
        final data = await SupabaseService.client
          .from('lessons')
          .select('id')
          .eq('teacher_id', userId);
        lessonsCount = (data as List).length;
      }

      final tasks = await TaskController.fetchTasksForTeacher();

      if (!mounted) return;
      setState(() {
        _students = students;
        _lessonsCount = lessonsCount;
        _tasksCreated = tasks.length;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando datos del docente: $e');
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
      body: _loading
        ? const Center(child: CircularProgressIndicator(
            color: AppColors.primary))
        : RefreshIndicator(
            onRefresh: _loadAll,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                            Text('${_students.length} estudiantes en la plataforma',
                              style: const TextStyle(fontSize: 12,
                                color: Colors.white70)),
                          ]),
                        const Text('👩🏽‍🏫', style: TextStyle(fontSize: 36)),
                      ]),
                  ),
                  const SizedBox(height: 16),

                  // Estadísticas (datos reales)
                  Row(children: [
                    _StatCard(number: '${_students.length}',
                      label: 'Estudiantes',
                      icon: Icons.people_outline,
                      color: AppColors.primary),
                    const SizedBox(width: 8),
                    _StatCard(number: '$_lessonsCount',
                      label: 'Videos subidos',
                      icon: Icons.video_library_outlined,
                      color: AppColors.accent),
                    const SizedBox(width: 8),
                    _StatCard(number: '$_tasksCreated',
                      label: 'Tareas creadas',
                      icon: Icons.assignment_outlined,
                      color: const Color(0xFF534AB7)),
                  ]),
                  const SizedBox(height: 16),

                  // Pestañas
                  Row(children: [
                    _TabBtn(label: 'Subir contenido',
                      icon: Icons.upload_outlined,
                      active: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0)),
                    const SizedBox(width: 8),
                    _TabBtn(label: 'Clase en vivo',
                      icon: Icons.videocam_outlined,
                      active: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1)),
                    const SizedBox(width: 8),
                    _TabBtn(label: 'Estudiantes',
                      icon: Icons.people_outline,
                      active: _tabIndex == 2,
                      onTap: () => setState(() => _tabIndex = 2)),
                    const SizedBox(width: 8),
                    _TabBtn(label: 'Tareas',
                      icon: Icons.checklist_outlined,
                      active: _tabIndex == 3,
                      onTap: () => setState(() => _tabIndex = 3)),
                  ]),
                  const SizedBox(height: 12),

                  if (_tabIndex == 0) const _UploadTab(),
                  if (_tabIndex == 1) const _LiveTab(),
                  if (_tabIndex == 2) _StudentsTab(students: _students),
                  if (_tabIndex == 3) const _TasksTab(),
                ],
              ),
            ),
          ),
    );
  }
}

// ── PESTAÑA SUBIR CONTENIDO (real: lista de tus videos/actividades) ──
class _UploadTab extends StatefulWidget {
  const _UploadTab();
  @override
  State<_UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<_UploadTab> {
  List<Map<String, dynamic>> _content = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;
      final data = await SupabaseService.client
        .from('lessons')
        .select('*, subjects(name, icon)')
        .eq('teacher_id', userId)
        .order('created_at', ascending: false)
        .limit(10);
      if (!mounted) return;
      setState(() {
        _content = List<Map<String, dynamic>>.from(data as List);
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando contenido: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5)),
        child: Column(children: [
          const Icon(Icons.cloud_upload_outlined,
            size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          const Text('Sube tu próximo video o actividad',
            style: TextStyle(fontSize: 13,
              color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('MP4 · AVI · MOV · PDF · PPTX · hasta 2 GB',
            style: TextStyle(fontSize: 11,
              color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => const UploadContentScreen()));
              _load();
            },
            icon: const Icon(Icons.upload, size: 14),
            label: const Text('Ir a subir contenido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36))),
        ]),
      ),
      const SizedBox(height: 16),
      const Text('Contenido reciente',
        style: TextStyle(fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      if (_loading)
        const Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: AppColors.primary)))
      else if (_content.isEmpty)
        const Text('Todavía no has subido contenido.',
          style: TextStyle(fontSize: 12,
            color: AppColors.textSecondary))
      else
        ..._content.map((c) {
          final subject = c['subjects'] as Map<String, dynamic>?;
          return _VideoItem(
            title: c['title'] as String? ?? 'Sin título',
            subject: '${subject?['name'] ?? "General"} · '
              '${c['duration_minutes'] ?? 0} min',
            icon: Icons.play_circle_outline);
        }),
    ]);
  }
}

// ── PESTAÑA CLASE EN VIVO (real) ─────────────────────
class _LiveTab extends StatefulWidget {
  const _LiveTab();
  @override
  State<_LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<_LiveTab> {
  List<dynamic> _classes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final classes = await LiveClassController.fetchUpcoming();
      if (!mounted) return;
      setState(() { _classes = classes; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (_loading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: AppColors.primary))
      else if (_classes.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200)),
          child: const Text('No tienes clases programadas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12,
              color: AppColors.textSecondary)))
      else
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tu próxima clase',
                style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(_classes.first.title as String,
                style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w500)),
            ])),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (_) =>
                  const LiveClassesScreen(role: 'teacher'))),
            icon: const Icon(Icons.videocam_outlined, size: 16),
            label: const Text('Ver mis clases'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44)))),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => const CreateLiveClassScreen()));
            _load();
          },
          icon: const Icon(Icons.calendar_month_outlined, size: 16),
          label: const Text('Programar'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: Colors.grey.shade300))),
      ]),
    ]);
  }
}

// ── PESTAÑA ESTUDIANTES (real, con navegación a notas) ────
class _StudentsTab extends StatelessWidget {
  final List<StudentSummaryModel> students;
  const _StudentsTab({required this.students});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
        child: const Text('No hay estudiantes registrados todavía.',
          style: TextStyle(fontSize: 12,
            color: AppColors.textSecondary)));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: students.map((s) => _StudentRow(
          student: s,
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => StudentGradesScreen(
              studentId: s.id, studentName: s.fullName))),
        )).toList(),
      ),
    );
  }
}

// ── PESTAÑA TAREAS ────────────────────────────────────
class _TasksTab extends StatelessWidget {
  const _TasksTab();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        const Icon(Icons.checklist_outlined,
          size: 40, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        const Text('Crea y califica las tareas de tus estudiantes',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13,
            color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => const TeacherTasksScreen())),
          icon: const Icon(Icons.checklist_outlined, size: 16),
          label: const Text('Ver mis tareas'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44))),
      ]),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.number, required this.label,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(number, style: TextStyle(fontSize: 22,
          fontWeight: FontWeight.w500, color: color)),
        Text(label, style: const TextStyle(fontSize: 10,
          color: AppColors.textSecondary),
          textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.icon,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
            ? AppColors.primaryLight.withValues(alpha: 0.3)
            : Colors.white,
          border: Border.all(
            color: active ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
            color: active ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12,
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

class _VideoItem extends StatelessWidget {
  final String title;
  final String subject;
  final IconData icon;
  const _VideoItem({required this.title, required this.subject,
    required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(
          width: 44, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: AppColors.primaryDark, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
            Text(subject, style: const TextStyle(fontSize: 10,
              color: AppColors.textSecondary)),
          ])),
      ]),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentSummaryModel student;
  final VoidCallback onTap;
  const _StudentRow({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progressPct = (student.progress * 100).toInt();
    final isLow = progressPct < 50;
    final initials = student.fullName.trim().isEmpty
      ? '?'
      : student.fullName.trim().split(' ')
          .map((p) => p.isNotEmpty ? p[0] : '')
          .take(2).join().toUpperCase();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100))),
        child: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(initials,
              style: const TextStyle(fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark))),
          const SizedBox(width: 10),
          Expanded(child: Text(student.fullName,
            style: const TextStyle(fontSize: 12,
              color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isLow
                ? const Color(0xFFFAEEDA)
                : const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(10)),
            child: Text('$progressPct% ${isLow ? "⚠" : "✓"}',
              style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isLow
                  ? const Color(0xFF633806)
                  : AppColors.primaryDark))),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 16,
            color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}