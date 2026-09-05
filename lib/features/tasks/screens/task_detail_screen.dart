import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../controllers/task_controller.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? _task;
  bool _loading = true;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tasks = await TaskController.fetchTasksForStudent();
      final task = tasks.firstWhere((t) => t.id == widget.taskId);
      if (!mounted) return;
      setState(() { _task = task; _loading = false; });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando la tarea: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la tarea.';
        _loading = false;
      });
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _uploading = true);
    try {
      await TaskController.submitTask(
        taskId: widget.taskId,
        fileName: file.name,
        fileBytes: file.bytes!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('¡Tarea entregada correctamente!')));
      _load();
    } catch (e) {
      // ignore: avoid_print
      print('Error subiendo la tarea: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo subir el archivo. Intenta de nuevo.')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detalle de la tarea',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary));
    }
    if (_error != null || _task == null) {
      return Center(child: Text(_error ?? 'Tarea no encontrada.',
        style: const TextStyle(color: AppColors.textSecondary)));
    }

    final t = _task!;
    final submission = t.mySubmission;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.title, style: const TextStyle(fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('${t.subjectName ?? "General"} · '
            'Docente: ${t.teacherName ?? "—"}',
            style: const TextStyle(fontSize: 12,
              color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Fecha límite: ${t.dueDate.day}/${t.dueDate.month}/'
            '${t.dueDate.year}',
            style: const TextStyle(fontSize: 12,
              color: AppColors.textSecondary)),
          const SizedBox(height: 16),

          if (t.description != null && t.description!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
              child: Text(t.description!,
                style: const TextStyle(fontSize: 13,
                  color: AppColors.textPrimary))),
            const SizedBox(height: 16),
          ],

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu entrega',
                  style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 8),

                if (submission?.submittedAt != null) ...[
                  Row(children: [
                    const Icon(Icons.check_circle_outline,
                      size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(
                      submission!.fileName ?? 'Archivo entregado',
                      style: const TextStyle(fontSize: 12,
                        color: AppColors.textPrimary))),
                  ]),
                  const SizedBox(height: 8),
                  if (submission.grade != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5EE),
                        borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nota: ${submission.grade}',
                            style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark)),
                          if (submission.feedback != null &&
                              submission.feedback!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(submission.feedback!,
                              style: const TextStyle(fontSize: 12,
                                color: AppColors.textPrimary)),
                          ],
                        ])),
                  ] else
                    const Text('Esperando calificación del docente.',
                      style: TextStyle(fontSize: 11,
                        color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickAndUpload,
                    icon: const Icon(Icons.upload_file_outlined, size: 14),
                    label: Text(_uploading
                      ? 'Subiendo...'
                      : 'Reemplazar archivo')),
                ] else ...[
                  Text(
                    t.isOverdue
                      ? 'Esta tarea está atrasada. Aún puedes entregarla.'
                      : 'Todavía no has entregado esta tarea.',
                    style: TextStyle(fontSize: 12,
                      color: t.isOverdue
                        ? Colors.red : AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _uploading ? null : _pickAndUpload,
                      icon: _uploading
                        ? const SizedBox(width: 14, height: 14,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.upload_file_outlined,
                            size: 16, color: Colors.white),
                      label: Text(_uploading
                        ? 'Subiendo...'
                        : 'Subir archivo',
                        style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12)))),
                ],
              ])),
        ],
      ),
    );
  }
}
