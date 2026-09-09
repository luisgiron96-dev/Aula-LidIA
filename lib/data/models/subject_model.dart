class SubjectModel {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;
  final int periodo; // 1 a 4 (Periodo académico)

  const SubjectModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.sortOrder,
    this.periodo = 1,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      // Si la columna "periodo" todavía no existe en Supabase, cae en 1
      // en vez de romper la app.
      periodo: json['periodo'] as int? ?? 1,
    );
  }
}
