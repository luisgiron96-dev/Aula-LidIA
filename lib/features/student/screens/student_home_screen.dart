import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/live_class_model.dart';
import '../../../data/models/task_model.dart';
import '../../subjects/controllers/subject_controller.dart';
import '../../subjects/screens/subject_detail_screen.dart';
import '../../subjects/widgets/subject_card.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../live_class/controllers/live_class_controller.dart';
import '../../live_class/screens/live_class_screen.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../tasks/screens/tasks_list_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final String userName;
  const StudentHomeScreen({super.key, this.userName = 'Estudiante'});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  List<SubjectModel> _subjects = [];
  Map<String, double> _progress = {};
  bool _loading = true;

  List<LiveClassModel> _upcomingClasses = [];
  bool _loadingClasses = true;

  List<TaskModel> _tasks = [];
  bool _loadingTasks = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadUpcomingClasses();
    _loadTasks();
  }

  Future<void> _loadSubjects() async {
    setState(() => _loading = true);
    try {
      final subjects = await SubjectController.fetchSubjects();
      final progressList = await Future.wait(
        subjects.map((s) => SubjectController.fetchSubjectProgress(s.id)));

      final progressMap = <String, double>{};
      for (var i = 0; i < subjects.length; i++) {
        progressMap[subjects[i].id] = progressList[i];
      }

      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _progress = progressMap;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando materias en inicio: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadUpcomingClasses() async {
    setState(() => _loadingClasses = true);
    try {
      final classes = await LiveClassController.fetchUpcoming();
      if (!mounted) return;
      setState(() {
        _upcomingClasses = classes;
        _loadingClasses = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando próximas clases: $e');
      if (!mounted) return;
      setState(() => _loadingClasses = false);
    }
  }

  Future<void> _loadTasks() async {
    setState(() => _loadingTasks = true);
    try {
      final tasks = await TaskController.fetchTasksForStudent();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loadingTasks = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando tareas en inicio: $e');
      if (!mounted) return;
      setState(() => _loadingTasks = false);
    }
  }

  Future<void> _reloadAll() async {
    await Future.wait(
      [_loadSubjects(), _loadUpcomingClasses(), _loadTasks()]);
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = _tasks.where(
      (t) => t.status == 'Pendiente' || t.status == 'Atrasada').length;

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
          const Text('Aula Lid-IA',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen()))),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.studentColor,
            child: Text('VA',
              style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark))),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadAll,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Banner bienvenida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D9E75), Color(0xFF085041)],
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
                        const Text('Sigue así, vas muy bien 🚀',
                          style: TextStyle(fontSize: 12,
                            color: Colors.white70)),
                      ]),
                    const Text('👩🏾‍🎓', style: TextStyle(fontSize: 36)),
                  ]),
              ),
              const SizedBox(height: 20),

              // Mis materias
              const Text('Mis materias',
                style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
              const SizedBox(height: 10),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator(
                    color: AppColors.primary)))
              else if (_subjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(
                    'Todavía no hay materias asignadas.',
                    style: TextStyle(color: AppColors.textSecondary))))
              else
                GridView.extent(
                  maxCrossAxisExtent: 180,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.4,
                  children: _subjects.map((subject) {
                    final progress = _progress[subject.id] ?? 0.0;
                    return SubjectCard(
                      icon: subject.icon,
                      name: subject.name,
                      progress: progress,
                      onTap: () async {
                        await Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            SubjectDetailScreen(
                              subjectId: subject.id,
                              icon: subject.icon,
                              name: subject.name,
                              progress: progress)));
                        _loadSubjects();
                      });
                  }).toList(),
                ),
              const SizedBox(height: 20),

              // Fila inferior
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Próximas clases (datos reales)
                Expanded(child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                        const LiveClassesScreen(role: 'student')));
                    _loadUpcomingClasses();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.video_call_outlined,
                            size: 15, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text('Próximas clases',
                            style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w500)),
                        ]),
                        const SizedBox(height: 10),
                        if (_loadingClasses)
                          const SizedBox(height: 14, width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary))
                        else if (_upcomingClasses.isEmpty)
                          const Text('No tienes clases programadas.',
                            style: TextStyle(fontSize: 11,
                              color: AppColors.textSecondary))
                        else ...[
                          Text(_upcomingClasses.first.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(_formatClassDate(
                              _upcomingClasses.first.scheduledAt),
                            style: const TextStyle(fontSize: 10,
                              color: AppColors.textSecondary)),
                          if (_upcomingClasses.length > 1) ...[
                            const SizedBox(height: 2),
                            Text('+${_upcomingClasses.length - 1} más',
                              style: const TextStyle(fontSize: 10,
                                color: AppColors.primary)),
                          ],
                        ],
                      ])),
                )),
                const SizedBox(width: 8),

                // Tareas (datos reales)
                Expanded(child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => const TasksListScreen()));
                    _loadTasks();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.checklist_outlined,
                            size: 15, color: Color(0xFF378ADD)),
                          SizedBox(width: 6),
                          Text('Tareas',
                            style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w500)),
                        ]),
                        const SizedBox(height: 10),
                        if (_loadingTasks)
                          const SizedBox(height: 14, width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary))
                        else if (_tasks.isEmpty)
                          const Text('No tienes tareas asignadas.',
                            style: TextStyle(fontSize: 11,
                              color: AppColors.textSecondary))
                        else
                          Text(
                            pendingTasks == 0
                              ? '¡Todo al día! ✓'
                              : '$pendingTasks pendiente'
                                '${pendingTasks == 1 ? "" : "s"}',
                            style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: pendingTasks == 0
                                ? AppColors.primary
                                : const Color(0xFF378ADD))),
                      ])),
                )),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatClassDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'a.m.' : 'p.m.';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} · $hour:$minute $ampm';
  }
}