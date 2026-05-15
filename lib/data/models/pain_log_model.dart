class PainLogModel {
  final String id;
  final int painLevel;
  final String? notes;
  final String? injuryId;
  final DateTime loggedAt;

  const PainLogModel({
    required this.id,
    required this.painLevel,
    this.notes,
    this.injuryId,
    required this.loggedAt,
  });

  factory PainLogModel.fromJson(Map<String, dynamic> json) => PainLogModel(
        id: json['id'] as String,
        painLevel: (json['painLevel'] as num).toInt(),
        notes: json['notes'] as String?,
        injuryId: json['injuryId'] as String?,
        loggedAt: DateTime.parse(json['loggedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'painLevel': painLevel,
        'notes': notes,
        'injuryId': injuryId,
      };
}

class PainStatsModel {
  final double averagePain;
  final int maxPain;
  final int minPain;
  final int logCount;

  const PainStatsModel({
    required this.averagePain,
    required this.maxPain,
    required this.minPain,
    required this.logCount,
  });

  factory PainStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PainStatsModel(
      averagePain: (data['averagePain'] as num?)?.toDouble() ?? 0.0,
      maxPain: (data['maxPain'] as num?)?.toInt() ?? 0,
      minPain: (data['minPain'] as num?)?.toInt() ?? 0,
      logCount: (data['logCount'] as num?)?.toInt() ?? 0,
    );
  }
}
