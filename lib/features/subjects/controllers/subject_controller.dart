import '../../../core/services/supabase_service.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/video_model.dart';

class SubjectController {
  // Trae todas las materias, ordenadas
  static Future<List<SubjectModel>> fetchSubjects() async {
    final data = await SupabaseService.client
      .from('subjects')
      .select()
      .order('sort_order');

    return (data as List)
      .map((json) => SubjectModel.fromJson(json as Map<String, dynamic>))
      .toList();
  }

  // Progreso (0.0 a 1.0) del estudiante actual en una materia
  static Future<double> fetchSubjectProgress(String subjectId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0.0;

    final lessons = await SupabaseService.client
      .from('lessons')
      .select('id')
      .eq('subject_id', subjectId);

    final lessonIds = (lessons as List)
      .map((l) => l['id'] as String)
      .toList();
    if (lessonIds.isEmpty) return 0.0;

    final progress = await SupabaseService.client
      .from('lesson_progress')
      .select('lesson_id')
      .eq('student_id', userId)
      .eq('viewed', true)
      .inFilter('lesson_id', lessonIds);

    return (progress as List).length / lessonIds.length;
  }

  // Lecciones/videos de una materia, marcando cuáles ya vio el estudiante actual
  static Future<List<VideoModel>> fetchLessons(String subjectId) async {
    final userId = SupabaseService.currentUser?.id;

    final lessonsData = await SupabaseService.client
      .from('lessons')
      .select()
      .eq('subject_id', subjectId)
      .order('sort_order');

    Set<String> viewedIds = {};
    if (userId != null) {
      final progressData = await SupabaseService.client
        .from('lesson_progress')
        .select('lesson_id')
        .eq('student_id', userId)
        .eq('viewed', true);
      viewedIds = (progressData as List)
        .map((p) => p['lesson_id'] as String)
        .toSet();
    }

    return (lessonsData as List).map((json) {
      final lesson = VideoModel.fromJson(json as Map<String, dynamic>);
      return lesson.copyWith(viewed: viewedIds.contains(lesson.id));
    }).toList();
  }

  // Marca una lección como vista para el estudiante actual
  static Future<void> markLessonViewed(String lessonId) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    await SupabaseService.client.from('lesson_progress').upsert({
      'student_id': userId,
      'lesson_id': lessonId,
      'viewed': true,
      'viewed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'student_id,lesson_id');
  }

  // IDs de materias que ya tienen al menos un contenido (lección) subido
  static Future<Set<String>> fetchSubjectIdsWithContent() async {
    final data = await SupabaseService.client
      .from('lessons')
      .select('subject_id');
    return (data as List)
      .map((row) => row['subject_id'] as String)
      .toSet();
  }

  // Crea una nueva materia
  static Future<void> createSubject({
    required String name,
    required String icon,
    required int periodo,
  }) async {
    final subjects = await fetchSubjects();
    final nextSortOrder = subjects.isEmpty
      ? 0
      : subjects.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    await SupabaseService.client.from('subjects').insert({
      'name': name,
      'icon': icon,
      'periodo': periodo,
      'sort_order': nextSortOrder,
    });
  }

  // Cambia el período académico de una materia existente
  static Future<void> updateSubjectPeriodo(
    String subjectId, int periodo,
  ) async {
    await SupabaseService.client
      .from('subjects')
      .update({'periodo': periodo})
      .eq('id', subjectId);
  }

  // Elimina una materia. Si tiene contenido asociado (lecciones), Supabase
  // puede rechazar el borrado por la relación entre tablas; en ese caso
  // se propaga el error para que la pantalla lo muestre al docente.
  static Future<void> deleteSubject(String subjectId) async {
    await SupabaseService.client
      .from('subjects')
      .delete()
      .eq('id', subjectId);
  }
}