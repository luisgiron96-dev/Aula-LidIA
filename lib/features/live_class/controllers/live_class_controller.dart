import '../../../core/services/supabase_service.dart';
import '../../../data/models/live_class_model.dart';

class LiveClassController {
  static const _selectWithJoins =
    '*, subjects(name, icon), profiles!live_classes_teacher_id_fkey(full_name)';

  // Clases que aún no han terminado (en vivo o programadas a futuro)
  static Future<List<LiveClassModel>> fetchUpcoming() async {
    final nowIso = DateTime.now()
      .subtract(const Duration(hours: 6)) // margen para clases "en vivo"
      .toIso8601String();

    final data = await SupabaseService.client
      .from('live_classes')
      .select(_selectWithJoins)
      .gte('scheduled_at', nowIso)
      .order('scheduled_at');

    final classes = (data as List)
      .map((json) => LiveClassModel.fromJson(json as Map<String, dynamic>))
      .toList();

    // Filtra en el cliente las que ya terminaron de verdad
    return classes.where((c) => !c.isPast).toList();
  }

  // Clases que ya pasaron (últimas 20)
  static Future<List<LiveClassModel>> fetchPast() async {
    final nowIso = DateTime.now().toIso8601String();

    final data = await SupabaseService.client
      .from('live_classes')
      .select(_selectWithJoins)
      .lt('scheduled_at', nowIso)
      .order('scheduled_at', ascending: false)
      .limit(20);

    return (data as List)
      .map((json) => LiveClassModel.fromJson(json as Map<String, dynamic>))
      .toList();
  }

  // Crea una nueva clase en vivo (solo docentes, según RLS)
  static Future<void> createLiveClass({
    required String title,
    String? subjectId,
    required String meetingUrl,
    required String platform,
    required DateTime scheduledAt,
    required int durationMinutes,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');

    await SupabaseService.client.from('live_classes').insert({
      'title': title,
      'subject_id': subjectId,
      'teacher_id': userId,
      'meeting_url': meetingUrl,
      'platform': platform,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
    });
  }

  // Cancela/borra una clase (solo el docente dueño, según RLS)
  static Future<void> cancelLiveClass(String id) async {
    await SupabaseService.client
      .from('live_classes')
      .delete()
      .eq('id', id);
  }
}