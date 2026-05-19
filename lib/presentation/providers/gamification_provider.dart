import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/gamification_model.dart';
import '../../data/repositories/gamification_repository.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────
final gamificationRepositoryProvider =
    Provider<GamificationRepository>((_) => GamificationRepository());

// ─── Dashboard Stats ──────────────────────────────────────────────────────────
class DashboardStatsNotifier extends AsyncNotifier<DashboardStatsModel> {
  @override
  Future<DashboardStatsModel> build() async {
    final repo = ref.read(gamificationRepositoryProvider);
    return repo.getDashboardStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(gamificationRepositoryProvider).getDashboardStats();
    });
  }
}

final dashboardStatsProvider = AsyncNotifierProvider<DashboardStatsNotifier, DashboardStatsModel>(DashboardStatsNotifier.new);

// ─── Achievements ─────────────────────────────────────────────────────────────
class AchievementsNotifier extends AsyncNotifier<List<AchievementModel>> {
  @override
  Future<List<AchievementModel>> build() async {
    final repo = ref.read(gamificationRepositoryProvider);
    return repo.getAchievements();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(gamificationRepositoryProvider).getAchievements();
    });
  }
}

final achievementsProvider = AsyncNotifierProvider<AchievementsNotifier, List<AchievementModel>>(AchievementsNotifier.new);

// ─── Daily Tasks ──────────────────────────────────────────────────────────────
class DailyTasksNotifier extends AsyncNotifier<List<DailyTaskModel>> {
  late GamificationRepository _repo;

  @override
  Future<List<DailyTaskModel>> build() async {
    _repo = ref.read(gamificationRepositoryProvider);
    return _repo.getDailyTasks();
  }

  Future<void> completeTask(String taskId) async {
    await _repo.completeTask(taskId);
    ref.read(dashboardStatsProvider.notifier).refresh(); // Notify stats to update (XP, level)
    ref.read(achievementsProvider.notifier).refresh(); // Check if new achievements were unlocked
    state = AsyncData(
      state.value
              ?.map((t) => t.id == taskId
                  ? DailyTaskModel(
                      id: t.id,
                      title: t.title,
                      category: t.category,
                      isActive: t.isActive,
                      isCompletedToday: true,
                    )
                  : t)
              .toList() ??
          [],
    );
  }

  Future<void> createTask(String title, String category) async {
    final newTask = await _repo.createDailyTask(title, category);
    state = AsyncData([...state.value ?? [], newTask]);
  }
}

final dailyTasksProvider =
    AsyncNotifierProvider<DailyTasksNotifier, List<DailyTaskModel>>(
        DailyTasksNotifier.new);
