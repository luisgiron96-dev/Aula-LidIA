import 'task_submission_model.dart';

class TaskModel {
  final String id;
  final String? subjectId;
  final String? subjectName;
  final String? subjectIcon;
  final String teacherId;
  final String? teacherName;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskSubmissionModel? mySubmission; // null si el estudiante no ha entregado

  const TaskModel({
    required this.id,
    this.subjectId,
    this.subjectName,
    this.subjectIcon,
    required this.teacherId,
    this.teacherName,
    required this.title,
    this.description,
    required this.dueDate,
    this.mySubmission,
  });

  bool get isOverdue =>
    mySubmission == null && DateTime.now().isAfter(dueDate);

  String get status {
    if (mySubmission?.grade != null) return 'Calificada';
    if (mySubmission?.submittedAt != null) return 'Entregada';
    if (isOverdue) return 'Atrasada';
    return 'Pendiente';
  }

  factory TaskModel.fromJson(Map<String, dynamic> json,
      {TaskSubmissionModel? mySubmission}) {
    final subject = json['subjects'] as Map<String, dynamic>?;
    final teacher = json['profiles'] as Map<String, dynamic>?;

    return TaskModel(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String?,
      subjectName: subject?['name'] as String?,
      subjectIcon: subject?['icon'] as String?,
      teacherId: json['teacher_id'] as String,
      teacherName: teacher?['full_name'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      mySubmission: mySubmission,
    );
  }
}
