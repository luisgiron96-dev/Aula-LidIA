import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/student_summary_model.dart';
import '../controllers/teacher_controller.dart';
import 'student_grades_screen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  List<StudentSummaryModel> _students = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final students = await TeacherController.fetchStudents();
      if (!mounted) return;
      setState(() {
        _students = students;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando estudiantes: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la lista de estudiantes.';
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(StudentSummaryModel student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar estudiante'),
        content: Text(
          '¿Seguro que quieres eliminar a ${student.fullName} de la plataforma? '
          'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
              style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await TeacherController.deleteStudent(student.id);
      if (!mounted) return;
      setState(() {
        _students.removeWhere((s) => s.id == student.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${student.fullName} fue eliminado.')));
    } catch (e) {
      // ignore: avoid_print
      print('Error eliminando estudiante: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'No se pudo eliminar al estudiante. Intenta de nuevo.')));
    }
  }

  void _openGrades(StudentSummaryModel student) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => StudentGradesScreen(
        studentId: student.id,
        studentName: student.fullName,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Estudiantes',
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
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary));
    }

    if (_error != null) {
      return ListView(children: [
        const SizedBox(height: 80),
        Center(child: Column(children: [
          const Icon(Icons.wifi_off_outlined, size: 40,
            color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(
            color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: _load, child: const Text('Reintentar')),
        ])),
      ]);
    }

    if (_students.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 80),
        Center(child: Text(
          'Todavía no hay estudiantes registrados.',
          style: TextStyle(color: AppColors.textSecondary))),
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            children: _students.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return _StudentRow(
                student: s,
                colorIndex: i,
                onTap: () => _openGrades(s),
                onDelete: () => _confirmDelete(s));
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentSummaryModel student;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _StudentRow({
    required this.student,
    required this.colorIndex,
    required this.onTap,
    required this.onDelete,
  });

  static const _avatarColors = [
    Color(0xFF9FE1CB), Color(0xFFB5D4F4), Color(0xFFEEEDFE),
    Color(0xFFFAEEDA), Color(0xFFFAECE7),
  ];
  static const _textColors = [
    Color(0xFF0F6E56), Color(0xFF185FA5), Color(0xFF534AB7),
    Color(0xFF633806), Color(0xFF993C1D),
  ];

  String get _initials {
    final parts = student.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
      .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColors[colorIndex % _avatarColors.length];
    final textColor = _textColors[colorIndex % _textColors.length];
    final progressPct = (student.progress * 100).round();
    final isLow = progressPct < 50;

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
            backgroundColor: avatarColor,
            child: Text(_initials,
              style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textColor))),
          const SizedBox(width: 10),
          Expanded(child: Text(student.fullName,
            style: const TextStyle(fontSize: 12,
              color: AppColors.textPrimary))),
          if (student.averageGrade != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 3),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Prom: ${student.averageGrade!.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF534AB7)))),
          ],
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
          IconButton(
            icon: const Icon(Icons.delete_outline,
              color: Colors.red, size: 20),
            tooltip: 'Eliminar estudiante',
            onPressed: onDelete),
        ]),
      ),
    );
  }
}