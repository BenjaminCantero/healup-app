import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/models/session_model.dart';

final sessionRepositoryProvider = Provider<SessionRepository>(
  (_) => SessionRepository(),
);

// ─── Session history provider ─────────────────────────────────────────────────
class SessionHistoryNotifier
    extends AsyncNotifier<List<SessionModel>> {
  late SessionRepository _repo;

  @override
  Future<List<SessionModel>> build() async {
    _repo = ref.read(sessionRepositoryProvider);
    return _repo.getSessions();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getSessions());
  }

  Future<void> createSession({
    String? routineId,
    int? durationMinutes,
    int? painAfter,
    String? notes,
    required List<Map<String, dynamic>> exercises,
  }) async {
    await _repo.createSession(
      routineId: routineId,
      durationMinutes: durationMinutes,
      painAfter: painAfter,
      notes: notes,
      exercises: exercises,
    );
    await refresh();
  }
}

final sessionHistoryProvider = AsyncNotifierProvider<SessionHistoryNotifier,
    List<SessionModel>>(SessionHistoryNotifier.new);
