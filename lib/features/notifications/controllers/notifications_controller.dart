import '../../../core/services/supabase_service.dart';
import '../../../data/models/notification_model.dart';

class NotificationsController {
  static Future<List<NotificationModel>> fetchAll() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    final data = await SupabaseService.client
      .from('notifications')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(50);

    return (data as List)
      .map((json) =>
        NotificationModel.fromJson(json as Map<String, dynamic>))
      .toList();
  }

  static Future<int> fetchUnreadCount() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0;

    final data = await SupabaseService.client
      .from('notifications')
      .select('id')
      .eq('user_id', userId)
      .eq('read', false);

    return (data as List).length;
  }

  static Future<void> markRead(String id) async {
    await SupabaseService.client
      .from('notifications')
      .update({'read': true})
      .eq('id', id);
  }

  static Future<void> markAllRead() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    await SupabaseService.client
      .from('notifications')
      .update({'read': true})
      .eq('user_id', userId)
      .eq('read', false);
  }
}