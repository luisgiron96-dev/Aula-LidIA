import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/models/subject_model.dart';
import '../../auth/screens/login_screen.dart';
import '../../subjects/controllers/subject_controller.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../live_class/controllers/live_class_controller.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final String userName;
  const StudentProfileScreen({super.key, this.userName = 'Estudiante'});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late String _displayName;
  bool _notificationsOn = true;
  bool _offlineModeOn = true; // función futura, aún no implementada

  bool _loading = true;
  List<SubjectModel> _subjects = [];
  Map<String, double> _progress = {};
  int _viewedLessons = 0;
  int _tasksSubmitted = 0;
  int _tasksPending = 0;
  int _upcomingClasses = 0;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _loadAll();
  }

  String get _avatarText {
    if (_displayName.isEmpty) return 'VA';
    final parts = _displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _displayName[0].toUpperCase();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final subjects = await SubjectController.fetchSubjects();
      final progressList = await Future.wait(
        subjects.map((s) => SubjectController.fetchSubjectProgress(s.id)));
      final progressMap = <String, double>{};
      for (var i = 0; i < subjects.length; i++) {
        progressMap[subjects[i].id] = progressList[i];
      }

      int viewedLessons = 0;
      final userId = SupabaseService.currentUser?.id;
      if (userId != null) {
        final data = await SupabaseService.client
          .from('lesson_progress')
          .select('id')
          .eq('student_id', userId)
          .eq('viewed', true);
        viewedLessons = (data as List).length;
      }

      final tasks = await TaskController.fetchTasksForStudent();
      final submitted = tasks.where(
        (t) => t.mySubmission?.submittedAt != null).length;
      final pending = tasks.where(
        (t) => t.status == 'Pendiente' || t.status == 'Atrasada').length;

      final upcoming = await LiveClassController.fetchUpcoming();

      final notificationsEnabled =
        await SupabaseService.getNotificationsEnabled();

      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _progress = progressMap;
        _viewedLessons = viewedLessons;
        _tasksSubmitted = submitted;
        _tasksPending = pending;
        _upcomingClasses = upcoming.length;
        _notificationsOn = notificationsEnabled;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando perfil: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  double get _overallProgress {
    if (_progress.isEmpty) return 0;
    final sum = _progress.values.fold<double>(0, (a, b) => a + b);
    return sum / _progress.length;
  }

  Future<void> _showHelpDialog() async {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Ayuda y soporte'),
      content: const Text(
        'Si tienes algún problema con la plataforma, escríbenos a:\n\n'
        'soporte@aulalidia.com\n\n'
        'Te responderemos lo antes posible.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar')),
      ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Mi perfil',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final newName = await Navigator.push<String>(context,
                MaterialPageRoute(builder: (_) =>
                  EditProfileScreen(currentName: _displayName)));
              if (newName != null && newName.isNotEmpty) {
                setState(() => _displayName = newName);
              }
            },
            icon: const Icon(Icons.edit_outlined,
              size: 16, color: AppColors.primary),
            label: const Text('Editar',
              style: TextStyle(fontSize: 13,
                color: AppColors.primary))),
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

                  // Banner perfil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D9E75), Color(0xFF085041)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(_avatarText,
                          style: const TextStyle(fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
                      const SizedBox(height: 12),
                      Text(_displayName,
                        style: const TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20)),
                        child: const Text('Estudiante',
                          style: TextStyle(fontSize: 12,
                            color: Colors.white))),
                    ])),
                  const SizedBox(height: 16),

                  // Estadísticas (datos reales)
                  const Text('Mi progreso',
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _StatCard(number: '${_subjects.length}',
                      label: 'Materias',
                      icon: Icons.menu_book_outlined,
                      color: AppColors.primary),
                    const SizedBox(width: 8),
                    _StatCard(number: '$_viewedLessons',
                      label: 'Clases vistas',
                      icon: Icons.play_circle_outline,
                      color: AppColors.accent),
                    const SizedBox(width: 8),
                    _StatCard(number: '$_upcomingClasses',
                      label: 'Clases en vivo',
                      icon: Icons.video_call_outlined,
                      color: const Color(0xFFEF9F27)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _StatCard(number: '$_tasksSubmitted',
                      label: 'Tareas entregadas',
                      icon: Icons.assignment_turned_in_outlined,
                      color: const Color(0xFF534AB7)),
                    const SizedBox(width: 8),
                    _StatCard(number: '$_tasksPending',
                      label: 'Pendientes',
                      icon: Icons.assignment_outlined,
                      color: const Color(0xFFEF9F27)),
                    const SizedBox(width: 8),
                    _StatCard(
                      number: '${(_overallProgress * 100).toInt()}%',
                      label: 'Progreso general',
                      icon: Icons.trending_up_outlined,
                      color: AppColors.primary),
                  ]),
                  const SizedBox(height: 16),

                  // Progreso por materia (datos reales)
                  const Text('Progreso por materia',
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: _subjects.isEmpty
                      ? const Text('Aún no hay materias asignadas.',
                          style: TextStyle(fontSize: 12,
                            color: AppColors.textSecondary))
                      : Column(children: [
                          for (var i = 0; i < _subjects.length; i++)
                            _SubjectProgress(
                              icon: _subjects[i].icon,
                              name: _subjects[i].name,
                              progress: _progress[_subjects[i].id] ?? 0,
                              isLast: i == _subjects.length - 1),
                        ])),
                  const SizedBox(height: 16),

                  // Información personal (solo datos reales)
                  const Text('Información personal',
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Column(children: [
                      _InfoRow(icon: Icons.person_outline,
                        label: 'Nombre completo',
                        value: _displayName),
                      _InfoRow(icon: Icons.email_outlined,
                        label: 'Correo',
                        value: SupabaseService.currentUser?.email ?? '',
                        isLast: true),
                    ])),
                  const SizedBox(height: 16),

                  // Configuración
                  const Text('Configuración',
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Column(children: [
                      _SwitchRow(
                        icon: Icons.notifications_outlined,
                        label: 'Notificaciones',
                        subtitle: 'Alertas de clases y tareas',
                        value: _notificationsOn,
                        onChanged: (v) async {
                          setState(() => _notificationsOn = v);
                          try {
                            await SupabaseService
                              .setNotificationsEnabled(v);
                          } catch (e) {
                            // ignore: avoid_print
                            print('Error guardando preferencia: $e');
                          }
                        }),
                      _SwitchRow(
                        icon: Icons.download_outlined,
                        label: 'Modo offline',
                        subtitle: 'Próximamente',
                        value: _offlineModeOn,
                        onChanged: (v) =>
                          setState(() => _offlineModeOn = v)),
                      _ActionRow(
                        icon: Icons.lock_outline,
                        label: 'Cambiar contraseña',
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            const ChangePasswordScreen()))),
                      _ActionRow(
                        icon: Icons.help_outline,
                        label: 'Ayuda y soporte',
                        onTap: _showHelpDialog),
                      _ActionRow(
                        icon: Icons.logout,
                        label: 'Cerrar sesión',
                        isRed: true,
                        isLast: true,
                        onTap: () async {
                          await SupabaseService.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                              (route) => false);
                          }
                        }),
                    ])),
                  const SizedBox(height: 24),

                  const Center(
                    child: Text('Aula Lid-IA v1.0.0',
                      style: TextStyle(fontSize: 11,
                        color: AppColors.textSecondary))),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(number, style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.w500, color: color)),
        Text(label,
          style: const TextStyle(fontSize: 9,
            color: AppColors.textSecondary),
          textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _SubjectProgress extends StatelessWidget {
  final String icon;
  final String name;
  final double progress;
  final bool isLast;
  const _SubjectProgress({required this.icon,
    required this.name, required this.progress,
    this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary)),
                Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
              ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFFF5F5F5),
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.primary))),
          ])),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({required this.icon, required this.label,
    required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(
              fontSize: 13, color: AppColors.textPrimary)),
          ])),
      ]),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  const _SwitchRow({required this.icon, required this.label,
    required this.subtitle, required this.value,
    required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              fontSize: 13, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary)),
          ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary),
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isRed;
  final bool isLast;
  const _ActionRow({required this.icon, required this.label,
    required this.onTap, this.isRed = false,
    this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(color: Colors.grey.shade100))),
        child: Row(children: [
          Icon(icon, size: 18,
            color: isRed ? Colors.red : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
            style: TextStyle(fontSize: 13,
              color: isRed
                ? Colors.red : AppColors.textPrimary))),
          Icon(Icons.chevron_right,
            size: 18, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}