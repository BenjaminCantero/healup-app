import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

final recommendedExercisesProvider = FutureProvider<List<ExerciseModel>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercises(limit: 3);
});
