import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../../subjects/controllers/subject_controller.dart';
import '../controllers/live_class_controller.dart';

class CreateLiveClassScreen extends StatefulWidget {
  const CreateLiveClassScreen({super.key});

  @override
  State<CreateLiveClassScreen> createState() =>
    _CreateLiveClassScreenState();
}

class _CreateLiveClassScreenState extends State<CreateLiveClassScreen> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');

  List<SubjectModel> _subjects = [];
  String? _subjectId;
  String _platform = 'Google Meet';
  DateTime? _date;
  TimeOfDay? _time;

  bool _loadingSubjects = true;
  bool _saving = false;
  String? _error;

  final _platforms = const ['Zoom', 'Google Meet', 'Jitsi Meet', 'Otro'];

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 60;

    if (title.isEmpty) {
      setState(() => _error = 'Ponle un título a la clase.');
      return;
    }
    if (url.isEmpty || Uri.tryParse(url)?.hasScheme != true) {
      setState(() =>
        _error = 'Pega un enlace válido (debe empezar con https://).');
      return;
    }
    if (_date == null || _time == null) {
      setState(() => _error = 'Elige la fecha y la hora de la clase.');
      return;
    }

    final scheduledAt = DateTime(_date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute);

    setState(() { _saving = true; _error = null; });

    try {
      await LiveClassController.createLiveClass(
        title: title,
        subjectId: _subjectId,
        meetingUrl: url,
        platform: _platform,
        scheduledAt: scheduledAt,
        durationMinutes: duration);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      // ignore: avoid_print
      print('Error creando clase en vivo: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo programar la clase. Intenta de nuevo.';
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
        title: const Text('Programar clase en vivo',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text('Título de la clase',
              style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              decoration: _inputDecoration('Ej. Matemáticas — Fracciones')),
            const SizedBox(height: 16),

            const Text('Materia (opcional)',
              style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w500)),
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

            const Text('Plataforma',
              style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _platform,
                  isExpanded: true,
                  items: _platforms.map((p) =>
                    DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _platform = v!))),
            ),
            const SizedBox(height: 16),

            const Text('Enlace de la reunión',
              style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration(
                'https://meet.google.com/xxx-xxxx-xxx')),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha',
                    style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(_date == null
                        ? 'Elegir fecha'
                        : '${_date!.day}/${_date!.month}/${_date!.year}',
                        style: TextStyle(fontSize: 13,
                          color: _date == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary)))),
                ])),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hora',
                    style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(_time == null
                        ? 'Elegir hora'
                        : _time!.format(context),
                        style: TextStyle(fontSize: 13,
                          color: _time == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary)))),
                ])),
            ]),
            const SizedBox(height: 16),

            const Text('Duración (minutos)',
              style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('60')),

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
                  : const Text('Programar clase',
                      style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w600)))),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none));
  }
}
