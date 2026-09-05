class TaskSubmissionModel {
  final String id;
  final String taskId;
  final String studentId;
  final String? studentName;
  final String? fileUrl;
  final String? fileName;
  final DateTime? submittedAt;
  final num? grade;
  final String? feedback;

  const TaskSubmissionModel({
    required this.id,
    required this.taskId,
    required this.studentId,
    this.studentName,
    this.fileUrl,
    this.fileName,
    this.submittedAt,
    this.grade,
    this.feedback,
  });

  factory TaskSubmissionModel.fromJson(Map<String, dynamic> json) {
    final student = json['profiles'] as Map<String, dynamic>?;

    return TaskSubmissionModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      studentId: json['student_id'] as String,
      studentName: student?['full_name'] as String?,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      submittedAt: json['submitted_at'] != null
        ? DateTime.parse(json['submitted_at'] as String)
        : null,
      grade: json['grade'] as num?,
      feedback: json['feedback'] as String?,
    );
  }
}
