class LiveClassModel {
  final String id;
  final String title;
  final String? subjectId;
  final String? subjectName;
  final String? subjectIcon;
  final String teacherId;
  final String? teacherName;
  final String meetingUrl;
  final String platform;
  final DateTime scheduledAt;
  final int durationMinutes;

  const LiveClassModel({
    required this.id,
    required this.title,
    this.subjectId,
    this.subjectName,
    this.subjectIcon,
    required this.teacherId,
    this.teacherName,
    required this.meetingUrl,
    required this.platform,
    required this.scheduledAt,
    required this.durationMinutes,
  });

  DateTime get endsAt =>
    scheduledAt.add(Duration(minutes: durationMinutes));

  bool get isLiveNow {
    final now = DateTime.now();
    return now.isAfter(scheduledAt) && now.isBefore(endsAt);
  }

  bool get isPast => DateTime.now().isAfter(endsAt);

  factory LiveClassModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subjects'] as Map<String, dynamic>?;
    final teacher = json['profiles'] as Map<String, dynamic>?;

    return LiveClassModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subjectId: json['subject_id'] as String?,
      subjectName: subject?['name'] as String?,
      subjectIcon: subject?['icon'] as String?,
      teacherId: json['teacher_id'] as String,
      teacherName: teacher?['full_name'] as String?,
      meetingUrl: json['meeting_url'] as String,
      platform: json['platform'] as String? ?? 'Otro',
      scheduledAt:
        DateTime.parse(json['scheduled_at'] as String).toLocal(),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
    );
  }
}