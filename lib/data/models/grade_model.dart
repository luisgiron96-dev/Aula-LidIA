class GradeModel {
  final String subjectId;
  final String subjectName;
  final String subjectIcon;
  final double progress; // 0.0 a 1.0 — % de lecciones vistas en esa materia
  final double? score;   // 0 a 5, null si aún no se ha calificado

  const GradeModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectIcon,
    required this.progress,
    this.score,
  });
}