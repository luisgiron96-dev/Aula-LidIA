class VideoModel {
  final String id;
  final String subjectId;
  final String title;
  final String? videoUrl;
  final int durationMinutes;
  final int sortOrder;
  final bool viewed;

  const VideoModel({
    required this.id,
    required this.subjectId,
    required this.title,
    this.videoUrl,
    required this.durationMinutes,
    required this.sortOrder,
    this.viewed = false,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      title: json['title'] as String,
      videoUrl: json['video_url'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  VideoModel copyWith({bool? viewed}) {
    return VideoModel(
      id: id,
      subjectId: subjectId,
      title: title,
      videoUrl: videoUrl,
      durationMinutes: durationMinutes,
      sortOrder: sortOrder,
      viewed: viewed ?? this.viewed,
    );
  }
}