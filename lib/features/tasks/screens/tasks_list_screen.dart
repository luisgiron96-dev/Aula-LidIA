import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../controllers/task_controller.dart';
import 'task_detail_screen.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  List<TaskModel> _tasks = [];
  bool _loading = true;
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
      if (!mounted) return;
      setState(() { _tasks = tasks; _loading = false; });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando tareas: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las tareas.';
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Calificada': return AppColors.primary;
      case 'Entregada': return const Color(0xFF378ADD);
      case 'Atrasada': return Colors.red;
      default: return const Color(0xFFEF9F27);
    }
  }

  String _formatDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tareas',
          style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined,
              color: AppColors.textSecondary),
            onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary));
    }
    if (_error != null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!, style: const TextStyle(
            color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: _load, child: const Text('Reintentar')),
        ]));
    }
    if (_tasks.isEmpty) {
      return const Center(child: Text('No hay tareas asignadas todavía.',
        style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
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
              onTap: () async {
                await Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(taskId: t.id)));
                _load();
              },
              leading: Text(t.subjectIcon ?? '📝',
                style: const TextStyle(fontSize: 22)),
              title: Text(t.title,
                style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
              subtitle: Text(
                '${t.subjectName ?? "General"} · '
                'Vence ${_formatDate(t.dueDate)}',
                style: const TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(t.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6)),
                child: Text(t.status,
                  style: TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _statusColor(t.status)))),
            ),
          );
        },
      ),
    );
  }
}
