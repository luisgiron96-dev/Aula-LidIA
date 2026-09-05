class StudentSummaryModel {
  final String id;
  final String fullName;
  final double progress; // 0.0 a 1.0 — % de lecciones vistas (todas las materias)

  const StudentSummaryModel({
    required this.id,
    required this.fullName,
    required this.progress,
  });
}