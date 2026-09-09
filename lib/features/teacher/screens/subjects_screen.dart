import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../../subjects/controllers/subject_controller.dart';
import '../controllers/teacher_controller.dart';
import 'students_list_screen.dart';

const List<int> _kPeriodos = [1, 2, 3, 4];
const double _kWideBreakpoint = 900;

class TeacherSubjectsScreen extends StatefulWidget {
  const TeacherSubjectsScreen({super.key});

  @override
  State<TeacherSubjectsScreen> createState() =>
    _TeacherSubjectsScreenState();
}

class _TeacherSubjectsScreenState extends State<TeacherSubjectsScreen> {
  List<SubjectModel> _subjects = [];
  int _studentsCount = 0;
  Set<String> _subjectIdsWithContent = {};
  int _selectedPeriodo = 1;
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
      final subjects = await SubjectController.fetchSubjects();
      final students = await TeacherController.fetchStudents();
      final withContent =
        await SubjectController.fetchSubjectIdsWithContent();

      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _studentsCount = students.length;
        _subjectIdsWithContent = withContent;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando asignaturas: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las asignaturas.';
        _loading = false;
      });
    }
  }

  List<SubjectModel> _subjectsFor(int periodo) =>
    _subjects.where((s) => s.periodo == periodo).toList();

  double get _contentAvailablePercent {
    if (_subjects.isEmpty) return 0;
    final withContent = _subjects
      .where((s) => _subjectIdsWithContent.contains(s.id)).length;
    return withContent / _subjects.length * 100;
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : AppColors.primary));
  }

  Future<void> _openCreateSubjectDialog() async {
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController(text: '📘');
    int periodo = _selectedPeriodo;

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva asignatura'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ícono (emoji)',
                  style: TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: iconCtrl,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    hintText: 'Ej: 📘', counterText: '')),
                const SizedBox(height: 8),
                const Text('Nombre',
                  style: TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Robótica')),
                const SizedBox(height: 14),
                const Text('Período',
                  style: TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: _kPeriodos.map((p) =>
                  ChoiceChip(
                    label: Text('Periodo $p'),
                    selected: periodo == p,
                    selectedColor:
                      AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (_) =>
                      setDialogState(() => periodo = p),
                  )).toList()),
              ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
              child: const Text('Crear')),
          ],
        ),
      ),
    );

    if (created != true) return;
    final name = nameCtrl.text.trim();
    final icon = iconCtrl.text.trim();
    if (name.isEmpty || icon.isEmpty) {
      _showSnack('Escribe un nombre y un ícono', isError: true);
      return;
    }

    try {
      await SubjectController.createSubject(
        name: name, icon: icon, periodo: periodo);
      if (!mounted) return;
      setState(() => _selectedPeriodo = periodo);
      _showSnack('✅ Asignatura creada');
      _load();
    } catch (e) {
      _showSnack('Error al crear la asignatura: $e', isError: true);
    }
  }

  Future<void> _openSubjectOptions(SubjectModel subject) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text(subject.icon,
                style: const TextStyle(fontSize: 22)),
              title: Text(subject.name),
              subtitle: Text('Periodo ${subject.periodo}')),
            const Divider(height: 1),
            ..._kPeriodos.where((p) => p != subject.periodo).map((p) =>
              ListTile(
                leading: const Icon(Icons.swap_horiz,
                  color: AppColors.textSecondary),
                title: Text('Mover a Periodo $p'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    await SubjectController.updateSubjectPeriodo(
                      subject.id, p);
                    _showSnack('Movida a Periodo $p');
                    _load();
                  } catch (e) {
                    _showSnack(
                      'Error al mover la asignatura: $e',
                      isError: true);
                  }
                })),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                color: Colors.red),
              title: const Text('Eliminar asignatura',
                style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteSubject(subject);
              }),
          ]),
      ),
    );
  }

  Future<void> _confirmDeleteSubject(SubjectModel subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar asignatura?'),
        content: Text(
          'Esto eliminará "${subject.name}" de la plataforma. '
          'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red),
            child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await SubjectController.deleteSubject(subject.id);
      _showSnack('Asignatura eliminada');
      _load();
    } catch (e) {
      _showSnack(
        'No se pudo eliminar: probablemente tiene contenido '
        'asociado. Elimina primero ese contenido.',
        isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Asignaturas',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined,
              color: AppColors.textSecondary),
            onPressed: _loading ? null : _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSubjectDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva asignatura',
          style: TextStyle(color: Colors.white))),
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
          Text(_error!,
            style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Reintentar')),
        ]));
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= _kWideBreakpoint;
      final mainColumn = _buildMainColumn();
      final sidePanel = _buildSidePanel();

      if (isWide) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: mainColumn),
              const SizedBox(width: 16),
              SizedBox(width: 300, child: sidePanel),
            ]),
        );
      }

      return RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              mainColumn,
              const SizedBox(height: 20),
              sidePanel,
            ]),
        ),
      );
    });
  }

  Widget _buildMainColumn() {
    final subjectsInPeriodo = _subjectsFor(_selectedPeriodo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE7F7F1), Color(0xFFD3F0E6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.menu_book_outlined,
                color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Asignaturas por período',
                  style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark)),
                const SizedBox(height: 2),
                const Text(
                  'Organiza y gestiona tus asignaturas según '
                  'el período académico.',
                  style: TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
              ])),
          ]),
        ),
        const SizedBox(height: 16),

        // Chips de período (datos reales por asignatura)
        Wrap(spacing: 8, runSpacing: 8, children: _kPeriodos.map((p) {
          final count = _subjectsFor(p).length;
          final active = _selectedPeriodo == p;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriodo = p),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active
                    ? AppColors.primary
                    : Colors.grey.shade300)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today_outlined, size: 15,
                  color: active ? Colors.white : AppColors.textSecondary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Periodo $p',
                      style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: active
                          ? Colors.white
                          : AppColors.textPrimary)),
                    Text('$count asignatura${count == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 10,
                        color: active
                          ? Colors.white70
                          : AppColors.textSecondary)),
                  ]),
              ]),
            ),
          );
        }).toList()),
        const SizedBox(height: 16),

        Row(children: [
          Text('Asignaturas del Periodo $_selectedPeriodo',
            style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${subjectsInPeriodo.length} asignatura'
              '${subjectsInPeriodo.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 10,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 10),

        if (subjectsInPeriodo.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200)),
            child: const Column(children: [
              Icon(Icons.menu_book_outlined,
                size: 32, color: AppColors.textSecondary),
              SizedBox(height: 8),
              Text('No hay asignaturas en este período todavía.',
                style: TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
            ]))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 92),
            itemCount: subjectsInPeriodo.length,
            itemBuilder: (_, i) {
              final subject = subjectsInPeriodo[i];
              return _SubjectTile(
                subject: subject,
                studentsCount: _studentsCount,
                hasContent:
                  _subjectIdsWithContent.contains(subject.id),
                onTap: () => _openSubjectOptions(subject));
            },
          ),
      ],
    );
  }

  Widget _buildSidePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Resumen académico (100% datos reales)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [
                Icon(Icons.bar_chart_outlined,
                  color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text('Resumen académico',
                  style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _StatBox(
                  number: '${_subjects.length}',
                  label: 'Total de\nasignaturas',
                  icon: Icons.menu_book_outlined,
                  color: AppColors.accent)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(
                  number: '$_studentsCount',
                  label: 'Estudiantes',
                  icon: Icons.people_outline,
                  color: const Color(0xFF534AB7))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _StatBox(
                  number: '${_kPeriodos.length}',
                  label: 'Períodos',
                  icon: Icons.calendar_today_outlined,
                  color: AppColors.warning)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(
                  number: '${_contentAvailablePercent.round()}%',
                  label: 'Con contenido',
                  icon: Icons.check_circle_outline,
                  color: AppColors.primary)),
              ]),
            ]),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD8ECFB), Color(0xFFEAF3FD)]),
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.school_outlined,
              color: AppColors.accent, size: 30),
            const SizedBox(width: 10),
            const Expanded(child: Text(
              'El conocimiento es la clave del cambio',
              style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark))),
          ]),
        ),
        const SizedBox(height: 16),

        const Text('Accesos rápidos',
          style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        _QuickAction(
          icon: Icons.add_circle_outline,
          label: 'Crear nueva asignatura',
          onTap: _openCreateSubjectDialog),
        const SizedBox(height: 8),
        _QuickAction(
          icon: Icons.people_outline,
          label: 'Gestionar estudiantes',
          onTap: () => Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => const StudentsListScreen()))),
      ],
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _SubjectTile extends StatelessWidget {
  final SubjectModel subject;
  final int studentsCount;
  final bool hasContent;
  final VoidCallback onTap;
  const _SubjectTile({
    required this.subject,
    required this.studentsCount,
    required this.hasContent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10)),
            child: Text(subject.icon,
              style: const TextStyle(fontSize: 20))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text('$studentsCount estudiantes',
                style: const TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text('Periodo ${subject.periodo}',
                    style: const TextStyle(fontSize: 9,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500))),
                if (!hasContent) ...[
                  const SizedBox(width: 6),
                  Text('Sin contenido',
                    style: TextStyle(fontSize: 9,
                      color: Colors.orange.shade700)),
                ],
              ]),
            ])),
          const Icon(Icons.chevron_right,
            color: AppColors.textSecondary, size: 18),
        ]),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.number,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(number,
            style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
            style: const TextStyle(fontSize: 9,
              color: AppColors.textSecondary, height: 1.2)),
        ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
            style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary))),
          const Icon(Icons.chevron_right,
            size: 16, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}
