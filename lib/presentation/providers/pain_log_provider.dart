import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pain_log_model.dart';
import '../../data/repositories/pain_log_repository.dart';

final painLogRepositoryProvider = Provider((ref) => PainLogRepository());

final painLogsProvider = FutureProvider<List<PainLogModel>>((ref) async {
  final repo = ref.read(painLogRepositoryProvider);
  return await repo.getPainLogs(limit: 14);
});

final painStatsProvider = FutureProvider<PainStatsModel>((ref) async {
  final repo = ref.read(painLogRepositoryProvider);
  return await repo.getPainStats();
});

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
      ref.invalidate(painLogsProvider);
      ref.invalidate(painStatsProvider);
    });
  }
}

final painLogNotifierProvider = AsyncNotifierProvider<PainLogNotifier, void>(() {
  return PainLogNotifier();
});
