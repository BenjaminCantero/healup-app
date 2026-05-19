import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pain_log_model.dart';
import '../../data/repositories/pain_log_repository.dart';

final painLogRepositoryProvider = Provider((ref) => PainLogRepository());

class PainLogsNotifier extends AsyncNotifier<List<PainLogModel>> {
  @override
  Future<List<PainLogModel>> build() async {
    final repo = ref.read(painLogRepositoryProvider);
    return repo.getPainLogs(limit: 14);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(painLogRepositoryProvider).getPainLogs(limit: 14);
    });
  }
}

final painLogsProvider = AsyncNotifierProvider<PainLogsNotifier, List<PainLogModel>>(PainLogsNotifier.new);

class PainStatsNotifier extends AsyncNotifier<PainStatsModel> {
  @override
  Future<PainStatsModel> build() async {
    final repo = ref.read(painLogRepositoryProvider);
    return repo.getPainStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(painLogRepositoryProvider).getPainStats();
    });
  }
}

final painStatsProvider = AsyncNotifierProvider<PainStatsNotifier, PainStatsModel>(PainStatsNotifier.new);

class PainLogNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // empty build
  }

  Future<void> addLog(int painLevel, {String? notes, String? injuryId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(painLogRepositoryProvider);
      await repo.addPainLog(painLevel, notes: notes, injuryId: injuryId);
      await ref.read(painLogsProvider.notifier).refresh();
      await ref.read(painStatsProvider.notifier).refresh();
    });
  }
}

final painLogNotifierProvider = AsyncNotifierProvider<PainLogNotifier, void>(() {
  return PainLogNotifier();
});
