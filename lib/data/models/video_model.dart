class VideoModel {
  final String id;
  final String subjectId;
  final String title;
  final String? descripcion;
  final String tipo; // 'video' | 'pdf' | 'pptx' | 'otro'
  final String? videoUrl; // url genérico del archivo (video, pdf o pptx)
  final String? storagePath;
  final String? teacherId;
  final int durationMinutes;
  final int sortOrder;
  final bool viewed;

  const VideoModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.descripcion,
    this.tipo = 'video',
    this.videoUrl,
    this.storagePath,
    this.teacherId,
    required this.durationMinutes,
    required this.sortOrder,
    this.viewed = false,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      title: json['title'] as String,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String? ?? 'video',
      videoUrl: json['video_url'] as String?,
      storagePath: json['storage_path'] as String?,
      teacherId: json['teacher_id'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  VideoModel copyWith({bool? viewed}) {
    return VideoModel(
      id: id,
      subjectId: subjectId,
      title: title,
      descripcion: descripcion,
      tipo: tipo,
      videoUrl: videoUrl,
      storagePath: storagePath,
      teacherId: teacherId,
      durationMinutes: durationMinutes,
      sortOrder: sortOrder,
      viewed: viewed ?? this.viewed,
    );
  }
}