import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/task_submission_model.dart';
import '../controllers/task_controller.dart';
import 'create_task_screen.dart';

class TeacherTasksScreen extends StatefulWidget {
  const TeacherTasksScreen({super.key});

  @override
  State<TeacherTasksScreen> createState() => _TeacherTasksScreenState();
}

class _TeacherTasksScreenState extends State<TeacherTasksScreen> {
  List<TaskModel> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await TaskController.fetchTasksForTeacher();
      if (!mounted) return;
      setState(() { _tasks = tasks; _loading = false; });
    } catch (e) {
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
        title: const Text('Mis tareas',
          style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva tarea',
          style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final created = await Navigator.push<bool>(context,
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
          if (created == true) _load();
        }),
      body: _loading
        ? const Center(child: CircularProgressIndicator(
            color: AppColors.primary))
        : _tasks.isEmpty
          ? const Center(child: Text('Aún no has creado tareas.',
              style: TextStyle(color: AppColors.textSecondary)))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tasks.length,
                itemBuilder: (_, i) {
                  final t = _tasks[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: ListTile(
                      leading: Text(t.subjectIcon ?? '📝',
                        style: const TextStyle(fontSize: 22)),
                      title: Text(t.title,
                        style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        'Vence ${t.dueDate.day}/${t.dueDate.month}'
                        '/${t.dueDate.year}',
                        style: const TextStyle(fontSize: 11,
                          color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) =>
                          TaskSubmissionsScreen(
                            taskId: t.id, taskTitle: t.title))),
                    ),
                  );
                })),
    );
  }
}

class TaskSubmissionsScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;
  const TaskSubmissionsScreen({super.key,
    required this.taskId, required this.taskTitle});

  @override
  State<TaskSubmissionsScreen> createState() =>
    _TaskSubmissionsScreenState();
}

class _TaskSubmissionsScreenState extends State<TaskSubmissionsScreen> {
  List<TaskSubmissionModel> _submissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final subs = await TaskController.fetchSubmissions(widget.taskId);
      if (!mounted) return;
      setState(() { _submissions = subs; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openGradeDialog(TaskSubmissionModel s) async {
    final gradeCtrl = TextEditingController(
      text: s.grade?.toString() ?? '');
    final feedbackCtrl = TextEditingController(text: s.feedback ?? '');

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.studentName ?? 'Estudiante'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: gradeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nota (0-5)')),
          const SizedBox(height: 8),
          TextField(
            controller: feedbackCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar')),
        ]));

    if (save != true) return;
    final grade = num.tryParse(gradeCtrl.text.trim());
    if (grade == null) return;

    try {
      await TaskController.gradeSubmission(
        submissionId: s.id,
        grade: grade,
        feedback: feedbackCtrl.text.trim());
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo guardar la calificación.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.taskTitle,
          style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(
            color: AppColors.primary))
        : _submissions.isEmpty
          ? const Center(child: Text('Nadie ha entregado esta tarea aún.',
              style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _submissions.length,
              itemBuilder: (_, i) {
                final s = _submissions[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.studentName ?? 'Estudiante',
                          style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        if (s.fileUrl != null)
                          GestureDetector(
                            onTap: () => launchUrl(Uri.parse(s.fileUrl!),
                              mode: LaunchMode.externalApplication),
                            child: Text(s.fileName ?? 'Ver archivo',
                              style: const TextStyle(fontSize: 11,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline))),
                        if (s.grade != null) ...[
                          const SizedBox(height: 4),
                          Text('Nota: ${s.grade}',
                            style: const TextStyle(fontSize: 11,
                              color: AppColors.textSecondary)),
                        ],
                      ])),
                    ElevatedButton(
                      onPressed: () => _openGradeDialog(s),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(0, 32)),
                      child: Text(s.grade != null ? 'Editar' : 'Calificar',
                        style: const TextStyle(fontSize: 11,
                          color: Colors.white))),
                  ]),
                );
              }),
    );
  }
}
