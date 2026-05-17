import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gamification_provider.dart';

final routineProgressProvider = Provider<double>((ref) {
  final tasksState = ref.watch(dailyTasksProvider);
  final tasks = tasksState.value ?? [];
  if (tasks.isEmpty) return 0.0;
  final completed = tasks.where((t) => t.isCompletedToday).length;
  return completed / tasks.length;
});

final routineCompletedCountProvider = Provider<int>((ref) {
  final tasksState = ref.watch(dailyTasksProvider);
  final tasks = tasksState.value ?? [];
  return tasks.where((t) => t.isCompletedToday).length;
});
