import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/task_submission_model.dart';

class TaskController {
  static const _bucket = 'task-submissions';

  static Future<List<TaskModel>> fetchTasksForStudent() async {
    final userId = SupabaseService.currentUser?.id;

    final tasksData = await SupabaseService.client
      .from('tasks')
      .select('*, subjects(name, icon), profiles!tasks_teacher_id_fkey(full_name)')
      .order('due_date');

    Map<String, TaskSubmissionModel> mySubmissions = {};
    if (userId != null) {
      final subs = await SupabaseService.client
        .from('task_submissions')
        .select()
        .eq('student_id', userId);
      for (final s in (subs as List)) {
        final sub = TaskSubmissionModel.fromJson(s as Map<String, dynamic>);
        mySubmissions[sub.taskId] = sub;
      }
    }

    return (tasksData as List).map((json) {
      final map = json as Map<String, dynamic>;
      return TaskModel.fromJson(map, mySubmission: mySubmissions[map['id']]);
    }).toList();
  }

  static Future<List<TaskModel>> fetchTasksForTeacher() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    final data = await SupabaseService.client
      .from('tasks')
      .select('*, subjects(name, icon), profiles!tasks_teacher_id_fkey(full_name)')
      .eq('teacher_id', userId)
      .order('due_date');

    return (data as List)
      .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
      .toList();
  }

  static Future<List<TaskSubmissionModel>> fetchSubmissions(
      String taskId) async {
    final data = await SupabaseService.client
      .from('task_submissions')
      .select('*, profiles!task_submissions_student_id_fkey(full_name)')
      .eq('task_id', taskId)
      .order('submitted_at');

    return (data as List)
      .map((json) =>
        TaskSubmissionModel.fromJson(json as Map<String, dynamic>))
      .toList();
  }

  static Future<void> createTask({
    required String title,
    String? description,
    String? subjectId,
    required DateTime dueDate,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');

    await SupabaseService.client.from('tasks').insert({
      'teacher_id': userId,
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'due_date': dueDate.toIso8601String(),
    });
  }

  static Future<void> submitTask({
    required String taskId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');

    final path = '$userId/$taskId-$fileName';

    await SupabaseService.client.storage
      .from(_bucket)
      .uploadBinary(path, fileBytes,
        fileOptions: const FileOptions(upsert: true));

    final publicUrl = SupabaseService.client.storage
      .from(_bucket)
      .getPublicUrl(path);

    await SupabaseService.client.from('task_submissions').upsert({
      'task_id': taskId,
      'student_id': userId,
      'file_url': publicUrl,
      'file_name': fileName,
      'submitted_at': DateTime.now().toIso8601String(),
    }, onConflict: 'task_id,student_id');
  }

  static Future<void> gradeSubmission({
    required String submissionId,
    required num grade,
    String? feedback,
  }) async {
    await SupabaseService.client.from('task_submissions').update({
      'grade': grade,
      'feedback': feedback,
      'graded_at': DateTime.now().toIso8601String(),
    }).eq('id', submissionId);
  }
}
