class SessionModel {
  final String id;
  final String? routineId;
  final String? routineTitle;
  final int? durationMinutes;
  final int? painAfter;
  final String? notes;
  final DateTime completedAt;

  const SessionModel({
    required this.id,
    this.routineId,
    this.routineTitle,
    this.durationMinutes,
    this.painAfter,
    this.notes,
    required this.completedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['id'] as String,
        routineId: json['routineId'] as String?,
        routineTitle: json['routineTitle'] as String?,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
        painAfter: (json['painAfter'] as num?)?.toInt(),
        notes: json['notes'] as String?,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );

  String get formattedDate {
    final d = completedAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get formattedTime {
    final d = completedAt;
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
