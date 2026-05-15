import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/injury_model.dart';
import '../../data/repositories/injury_repository.dart';
import '../../core/network/api_exception.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────
final injuryRepositoryProvider =
    Provider<InjuryRepository>((_) => InjuryRepository());

// ─── Injuries List ────────────────────────────────────────────────────────────
class InjuryNotifier extends AsyncNotifier<List<InjuryModel>> {
  late InjuryRepository _repo;

  @override
  Future<List<InjuryModel>> build() async {
    _repo = ref.read(injuryRepositoryProvider);
    return _repo.getInjuries();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getInjuries());
  }

  Future<void> createInjury(Map<String, dynamic> dto) async {
    final newInjury = await _repo.createInjury(dto);
    state = AsyncData([newInjury, ...state.value ?? []]);
  }

  Future<void> updateInjury(String id, Map<String, dynamic> dto) async {
    final updated = await _repo.updateInjury(id, dto);
    state = AsyncData(
      state.value?.map((i) => i.id == id ? updated : i).toList() ?? [updated],
    );
  }

  Future<void> deleteInjury(String id) async {
    await _repo.deleteInjury(id);
    state = AsyncData(
      state.value?.where((i) => i.id != id).toList() ?? [],
    );
  }
}

final injuriesProvider =
    AsyncNotifierProvider<InjuryNotifier, List<InjuryModel>>(
        InjuryNotifier.new);

// ─── Body Parts (se cachean en el provider) ────────────────────────────────────
final bodyPartsProvider =
    FutureProvider<List<BodyPartModel>>((ref) async {
  final repo = ref.read(injuryRepositoryProvider);
  try {
    return await repo.getBodyParts();
  } on ApiException catch (_) {
    return [];
  }
});

// ─── Selected Injury ──────────────────────────────────────────────────────────
final selectedInjuryIdProvider = NotifierProvider<_StringNotifier, String?>(
  _StringNotifier.new,
);

class _StringNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final selectedInjuryProvider = Provider<InjuryModel?>((ref) {
  final id = ref.watch(selectedInjuryIdProvider);
  final injuries = ref.watch(injuriesProvider).value ?? [];
  if (id == null || injuries.isEmpty) return null;
  return injuries.firstWhere((i) => i.id == id, orElse: () => injuries.first);
});
