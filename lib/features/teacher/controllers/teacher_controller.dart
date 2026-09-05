import '../../../core/services/supabase_service.dart';
import '../../../data/models/student_summary_model.dart';

class TeacherController {
  // Lista de estudiantes con su progreso general (todas las materias)
  static Future<List<StudentSummaryModel>> fetchStudents() async {
    final profilesData = await SupabaseService.client
      .from('profiles')
      .select('id, full_name')
      .eq('role', 'student')
      .order('full_name');

    final students = (profilesData as List)
      .map((p) => {
        'id': p['id'] as String,
        'name': (p['full_name'] as String?) ?? 'Sin nombre',
      })
      .toList();

    if (students.isEmpty) return [];

    // Total de lecciones disponibles en toda la plataforma
    final lessonsData = await SupabaseService.client
      .from('lessons')
      .select('id');
    final totalLessons = (lessonsData as List).length;

    // Lecciones vistas por cada estudiante (todas las materias)
    final progressData = await SupabaseService.client
      .from('lesson_progress')
      .select('student_id')
      .eq('viewed', true);

    final viewedCount = <String, int>{};
    for (final row in (progressData as List)) {
      final sid = row['student_id'] as String;
      viewedCount[sid] = (viewedCount[sid] ?? 0) + 1;
    }

    return students.map((s) {
      final id = s['id'] as String;
      final viewed = viewedCount[id] ?? 0;
      final progress = totalLessons == 0 ? 0.0 : viewed / totalLessons;
      return StudentSummaryModel(
        id: id,
        fullName: s['name'] as String,
        progress: progress.clamp(0.0, 1.0),
      );
    }).toList();
  }
}