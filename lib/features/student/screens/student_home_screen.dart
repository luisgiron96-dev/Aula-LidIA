import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../../subjects/controllers/subject_controller.dart';
import '../../subjects/screens/subject_detail_screen.dart';
import '../../subjects/widgets/subject_card.dart';
import '../../notifications/screens/notifications_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSubjects();
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

  @override
  Widget build(BuildContext context) {
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
        onRefresh: _loadSubjects,
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

                // Próximas clases (aún no conectado a datos reales)
                Expanded(child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(children: [
                        Icon(Icons.video_call_outlined,
                          size: 15, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Próximas clases',
                          style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w500)),
                      ]),
                      SizedBox(height: 10),
                      Text('Próximamente',
                        style: TextStyle(fontSize: 11,
                          color: AppColors.textSecondary)),
                    ]),
                )),
                const SizedBox(width: 8),

                // Tareas (aún no conectado a datos reales)
                Expanded(child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(children: [
                        Icon(Icons.checklist_outlined,
                          size: 15, color: Color(0xFF378ADD)),
                        SizedBox(width: 6),
                        Text('Tareas',
                          style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w500)),
                      ]),
                      SizedBox(height: 10),
                      Text('Próximamente',
                        style: TextStyle(fontSize: 11,
                          color: AppColors.textSecondary)),
                    ]),
                )),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}