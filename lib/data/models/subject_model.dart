class SubjectModel {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.sortOrder,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}