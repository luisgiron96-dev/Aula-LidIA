import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../../subjects/controllers/subject_controller.dart';
import '../controllers/task_controller.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  List<SubjectModel> _subjects = [];
  String? _subjectId;
  DateTime? _dueDate;

  bool _loadingSubjects = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await SubjectController.fetchSubjects();
      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _loadingSubjects = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingSubjects = false);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'Ponle un título a la tarea.');
      return;
    }
    if (_dueDate == null) {
      setState(() => _error = 'Elige la fecha límite.');
      return;
    }

    setState(() { _saving = true; _error = null; });

    try {
      await TaskController.createTask(
        title: title,
        description: _descCtrl.text.trim(),
        subjectId: _subjectId,
        dueDate: _dueDate!);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      // ignore: avoid_print
      print('Error creando tarea: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo crear la tarea. Intenta de nuevo.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nueva tarea',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              decoration: _dec('Ej. Taller de fracciones')),
            const SizedBox(height: 16),

            const Text('Materia (opcional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            _loadingSubjects
              ? const LinearProgressIndicator()
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _subjectId,
                      isExpanded: true,
                      hint: const Text('Sin materia específica'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin materia específica')),
                        ..._subjects.map((s) => DropdownMenuItem<String?>(
                          value: s.id,
                          child: Text('${s.icon}  ${s.name}'))),
                      ],
                      onChanged: (v) => setState(() => _subjectId = v))),
                ),
            const SizedBox(height: 16),

            const Text('Descripción / instrucciones',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: _dec('Describe qué debe hacer el estudiante...')),
            const SizedBox(height: 16),

            const Text('Fecha límite',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDueDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
                child: Text(_dueDate == null
                  ? 'Elegir fecha'
                  : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  style: TextStyle(fontSize: 13,
                    color: _dueDate == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary)))),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(
                color: Colors.red, fontSize: 12)),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
                child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Text('Crear tarea',
                      style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w600)))),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none));
}
