class DashboardStatsModel {
  final int streakDays;
  final int totalDaysActive;
  final int totalRecoveredInjuries;
  final String userLevel;

  const DashboardStatsModel({
    required this.streakDays,
    required this.totalDaysActive,
    required this.totalRecoveredInjuries,
    required this.userLevel,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DashboardStatsModel(
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      totalDaysActive: (data['totalDaysActive'] as num?)?.toInt() ?? 0,
      totalRecoveredInjuries:
          (data['totalRecoveredInjuries'] as num?)?.toInt() ?? 0,
      userLevel: data['userLevel'] as String? ?? 'Iniciante',
    );
  }
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String rarity;
  final String rarityColor;
  final int targetValue;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.rarityColor,
    required this.targetValue,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double get progress =>
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        rarity: json['rarity'] as String,
        rarityColor: json['rarityColor'] as String,
        targetValue: (json['targetValue'] as num?)?.toInt() ?? 1,
        currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
      );
}

class DailyTaskModel {
  final String id;
  final String title;
  final String category;
  final bool isActive;
  final bool isCompletedToday;

  const DailyTaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.isActive,
    required this.isCompletedToday,
  });

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) => DailyTaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        isActive: json['isActive'] as bool? ?? true,
        isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      );
}
