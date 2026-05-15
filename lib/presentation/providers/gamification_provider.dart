import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/gamification_model.dart';
import '../../data/repositories/gamification_repository.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────
final gamificationRepositoryProvider =
    Provider<GamificationRepository>((_) => GamificationRepository());

// ─── Dashboard Stats ──────────────────────────────────────────────────────────
final dashboardStatsProvider = FutureProvider<DashboardStatsModel>((ref) async {
  final repo = ref.read(gamificationRepositoryProvider);
  return repo.getDashboardStats();
});

// ─── Achievements ─────────────────────────────────────────────────────────────
final achievementsProvider =
    FutureProvider<List<AchievementModel>>((ref) async {
  final repo = ref.read(gamificationRepositoryProvider);
  return repo.getAchievements();
});

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
