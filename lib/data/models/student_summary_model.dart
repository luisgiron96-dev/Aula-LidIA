class StudentSummaryModel {
  final String id;
  final String fullName;
  final double progress; // 0.0 a 1.0 — % de lecciones vistas (todas las materias)
  final double? averageGrade; // promedio 0 a 5 de todas las materias calificadas, null si aún no tiene notas

  const StudentSummaryModel({
    required this.id,
    required this.fullName,
    required this.progress,
    this.averageGrade,
  });
}