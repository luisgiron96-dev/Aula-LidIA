import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/grade_model.dart';
import '../controllers/teacher_controller.dart';

class StudentGradesScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const StudentGradesScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  List<GradeModel> _grades = [];
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final grades =
        await TeacherController.fetchStudentSubjectGrades(widget.studentId);
      if (!mounted) return;
      setState(() {
        _grades = grades;
        for (final g in grades) {
          _controllers[g.subjectId] = TextEditingController(
            text: g.score?.toStringAsFixed(1) ?? '');
        }
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando notas: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las materias y notas.';
        _loading = false;
      });
    }
  }

  Future<void> _saveGrade(GradeModel grade) async {
    final text = _controllers[grade.subjectId]?.text.trim() ?? '';
    final score = double.tryParse(text.replaceAll(',', '.'));

    if (score == null || score < 0 || score > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una nota válida entre 0 y 5.')));
      return;
    }

    try {
      await TeacherController.setGrade(
        studentId: widget.studentId,
        subjectId: grade.subjectId,
        score: score,
      );
      if (!mounted) return;
      setState(() {
        final i = _grades.indexWhere((g) => g.subjectId == grade.subjectId);
        if (i != -1) {
          _grades[i] = GradeModel(
            subjectId: grade.subjectId,
            subjectName: grade.subjectName,
            subjectIcon: grade.subjectIcon,
            progress: grade.progress,
            score: score,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nota guardada en ${grade.subjectName}.')));
    } catch (e) {
      // ignore: avoid_print
      print('Error guardando nota: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la nota.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.studentName,
          style: const TextStyle(fontSize: 16,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 40,
            color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(
            color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: _load, child: const Text('Reintentar')),
        ]));
    }
    if (_grades.isEmpty) {
      return const Center(child: Text(
        'Todavía no hay materias creadas.',
        style: TextStyle(color: AppColors.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _grades.length,
      itemBuilder: (_, i) => _GradeCard(
        grade: _grades[i],
        controller: _controllers[_grades[i].subjectId]!,
        onSave: () => _saveGrade(_grades[i]),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final GradeModel grade;
  final TextEditingController controller;
  final VoidCallback onSave;

  const _GradeCard({
    required this.grade,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final progressPct = (grade.progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(grade.subjectIcon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Text(grade.subjectName,
            style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary))),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: grade.progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary)),
        const SizedBox(height: 4),
        Text('$progressPct% completado',
          style: const TextStyle(fontSize: 11,
            color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Nota (0-5):',
            style: TextStyle(fontSize: 12,
              color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: TextField(
              controller: controller,
              keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36)),
            child: const Text('Guardar', style: TextStyle(fontSize: 12))),
        ]),
      ]),
    );
  }
}