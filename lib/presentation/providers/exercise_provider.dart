import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

// ─── Repository provider ──────────────────────────────────────────────────────
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

// ─── Quick recommendations (home screen — 3 exercises) ───────────────────────
final recommendedExercisesProvider =
    FutureProvider<List<ExerciseModel>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercises(limit: 3);
});

// ─── Exercise catalog filters state ──────────────────────────────────────────
class ExerciseCatalogFilter {
  final String? categoryId;
  final String? difficulty;
  final String search;

  const ExerciseCatalogFilter({
    this.categoryId,
    this.difficulty,
    this.search = '',
  });

  ExerciseCatalogFilter copyWith({
    String? categoryId,
    String? difficulty,
    String? search,
    bool clearCategory = false,
    bool clearDifficulty = false,
  }) =>
      ExerciseCatalogFilter(
        categoryId: clearCategory ? null : categoryId ?? this.categoryId,
        difficulty:
            clearDifficulty ? null : difficulty ?? this.difficulty,
        search: search ?? this.search,
      );
}

class ExerciseCatalogFilterNotifier
    extends Notifier<ExerciseCatalogFilter> {
  @override
  ExerciseCatalogFilter build() => const ExerciseCatalogFilter();

  void setCategory(String? id) =>
      state = state.copyWith(categoryId: id, clearCategory: id == null);
  void setDifficulty(String? d) =>
      state = state.copyWith(difficulty: d, clearDifficulty: d == null);
  void setSearch(String q) => state = state.copyWith(search: q);
  void reset() => state = const ExerciseCatalogFilter();
}

final exerciseCatalogFilterProvider = NotifierProvider<
    ExerciseCatalogFilterNotifier, ExerciseCatalogFilter>(
  ExerciseCatalogFilterNotifier.new,
);

// ─── Catalog exercises (filtered list, auto-dispose) ─────────────────────────
final exerciseCatalogProvider =
    FutureProvider.autoDispose<List<ExerciseModel>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final filter = ref.watch(exerciseCatalogFilterProvider);

  final exercises = await repo.getExercises(
    limit: 50,
    categoryId: filter.categoryId,
    difficulty: filter.difficulty,
  );

  // Client-side search filter (fast, no extra API call)
  if (filter.search.isEmpty) return exercises;
  final q = filter.search.toLowerCase();
  return exercises
      .where((e) =>
          e.title.toLowerCase().contains(q) ||
          (e.description?.toLowerCase().contains(q) ?? false))
      .toList();
});

// ─── Categories list (cached) ─────────────────────────────────────────────────
final exerciseCategoriesProvider =
    FutureProvider<List<ExerciseCategory>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getCategories();
});
