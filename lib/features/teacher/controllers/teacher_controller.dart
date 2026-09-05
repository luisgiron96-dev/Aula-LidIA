import '../../../core/services/supabase_service.dart';
import '../../../data/models/student_summary_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/grade_model.dart';

class TeacherController {
  // Lista de estudiantes con su progreso general y promedio de notas
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

    // Notas por materia de cada estudiante (para calcular el promedio)
    final gradesData = await SupabaseService.client
      .from('grades')
      .select('student_id, score');

    final scoresByStudent = <String, List<double>>{};
    for (final row in (gradesData as List)) {
      final sid = row['student_id'] as String;
      final score = (row['score'] as num).toDouble();
      scoresByStudent.putIfAbsent(sid, () => []).add(score);
    }

    return students.map((s) {
      final id = s['id'] as String;
      final viewed = viewedCount[id] ?? 0;
      final progress = totalLessons == 0 ? 0.0 : viewed / totalLessons;

      final scores = scoresByStudent[id];
      final avgGrade = (scores == null || scores.isEmpty)
        ? null
        : scores.reduce((a, b) => a + b) / scores.length;

      return StudentSummaryModel(
        id: id,
        fullName: s['name'] as String,
        progress: progress.clamp(0.0, 1.0),
        averageGrade: avgGrade,
      );
    }).toList();
  }

  // Progreso y nota de un estudiante en cada materia
  static Future<List<GradeModel>> fetchStudentSubjectGrades(
    String studentId,
  ) async {
    final subjectsData = await SupabaseService.client
      .from('subjects')
      .select()
      .order('sort_order');
    final subjects = (subjectsData as List)
      .map((json) => SubjectModel.fromJson(json as Map<String, dynamic>))
      .toList();

    if (subjects.isEmpty) return [];

    // Todas las lecciones, agrupadas por materia
    final lessonsData = await SupabaseService.client
      .from('lessons')
      .select('id, subject_id');
    final lessonsBySubject = <String, List<String>>{};
    for (final row in (lessonsData as List)) {
      final subjectId = row['subject_id'] as String;
      lessonsBySubject.putIfAbsent(subjectId, () => [])
        .add(row['id'] as String);
    }

    // Lecciones vistas por este estudiante
    final progressData = await SupabaseService.client
      .from('lesson_progress')
      .select('lesson_id')
      .eq('student_id', studentId)
      .eq('viewed', true);
    final viewedLessonIds = (progressData as List)
      .map((r) => r['lesson_id'] as String)
      .toSet();

    // Notas ya puestas a este estudiante
    final gradesData = await SupabaseService.client
      .from('grades')
      .select('subject_id, score')
      .eq('student_id', studentId);
    final scoreBySubject = <String, double>{
      for (final row in (gradesData as List))
        row['subject_id'] as String: (row['score'] as num).toDouble(),
    };

    return subjects.map((subject) {
      final lessonIds = lessonsBySubject[subject.id] ?? [];
      final viewedCount =
        lessonIds.where(viewedLessonIds.contains).length;
      final progress =
        lessonIds.isEmpty ? 0.0 : viewedCount / lessonIds.length;

      return GradeModel(
        subjectId: subject.id,
        subjectName: subject.name,
        subjectIcon: subject.icon,
        progress: progress,
        score: scoreBySubject[subject.id],
      );
    }).toList();
  }

  // Pone o actualiza la nota de un estudiante en una materia
  static Future<void> setGrade({
    required String studentId,
    required String subjectId,
    required double score,
  }) async {
    final teacherId = SupabaseService.currentUser?.id;
    if (teacherId == null) throw Exception('No hay sesión activa');

    await SupabaseService.client.from('grades').upsert({
      'student_id': studentId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'score': score,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'student_id,subject_id');
  }

  // Elimina el perfil de un estudiante de la plataforma
  // (no borra su cuenta de acceso, solo su registro en la app)
  static Future<void> deleteStudent(String studentId) async {
    await SupabaseService.client
      .from('profiles')
      .delete()
      .eq('id', studentId);
  }
}