import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../controllers/subject_controller.dart';
import '../widgets/subject_card.dart';
import 'subject_detail_screen.dart';

class SubjectsListScreen extends StatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> {
  List<SubjectModel> _subjects = [];
  Map<String, double> _progress = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _loading = true;
      _error = null;
    });
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
      print('Error cargando materias: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar tus materias. Verifica tu conexión.';
        _loading = false;
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
        automaticallyImplyLeading: false,
        title: const Text('Mis materias',
          style: TextStyle(fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined,
              color: AppColors.textSecondary),
            onPressed: _loadSubjects),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_outlined,
                size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadSubjects,
                child: const Text('Reintentar')),
            ]),
        ),
      );
    }

    if (_subjects.isEmpty) {
      return const Center(
        child: Text('Todavía no hay materias asignadas.',
          style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: _loadSubjects,
      color: AppColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 150,
        ),
        itemCount: _subjects.length,
        itemBuilder: (_, i) {
          final subject = _subjects[i];
          final progress = _progress[subject.id] ?? 0.0;
          return SubjectCard(
            icon: subject.icon,
            name: subject.name,
            progress: progress,
            onTap: () async {
              await Navigator.push(context,
                MaterialPageRoute(builder: (_) => SubjectDetailScreen(
                  subjectId: subject.id,
                  icon: subject.icon,
                  name: subject.name,
                  progress: progress,
                )));
              // al volver, refresca por si vio videos nuevos
              _loadSubjects();
            },
          );
        },
      ),
    );
  }
}