import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/routine_repository.dart';
import 'gamification_provider.dart';
import 'injury_provider.dart';
import 'session_provider.dart';

// ─── Daily-tasks progress (hábitos diarios) ─────────────────────────────────────
// Ojo: esto mide los HÁBITOS DIARIOS del usuario, no la rutina de la lesión.
// Para el progreso de la rutina de rehabilitación usa
// [weeklyRoutineProgressProvider], que sí se alimenta de las sesiones reales.

final dailyTasksProgressProvider = Provider<double>((ref) {
  final tasksState = ref.watch(dailyTasksProvider);
  final tasks = tasksState.value ?? [];
  if (tasks.isEmpty) return 0.0;
  final completed = tasks.where((t) => t.isCompletedToday).length;
  return completed / tasks.length;
});

final dailyTasksCompletedCountProvider = Provider<int>((ref) {
  final tasksState = ref.watch(dailyTasksProvider);
  final tasks = tasksState.value ?? [];
  return tasks.where((t) => t.isCompletedToday).length;
});

// Alias retrocompatibles (usados por home_screen). Mantienen la semántica de
// hábitos diarios que ya tenían.
final routineProgressProvider = dailyTasksProgressProvider;
final routineCompletedCountProvider = dailyTasksCompletedCountProvider;

// ─── Routine Fetching ─────────────────────────────────────────────────────────

final routineRepositoryProvider = Provider((ref) => RoutineRepository());

final routineByInjuryProvider = FutureProvider.autoDispose.family<RoutineModel?, String>((ref, injuryId) async {
  final repo = ref.read(routineRepositoryProvider);
  return repo.getRoutineByInjury(injuryId);
});

// ─── Rutina de la lesión activa ────────────────────────────────────────────────
/// Rutina de rehabilitación de la lesión activa (o null si no hay lesión/rutina).
final activeRoutineProvider = FutureProvider.autoDispose<RoutineModel?>((ref) async {
  final injury = ref.watch(activeInjuryProvider);
  if (injury == null) return null;
  return ref.watch(routineByInjuryProvider(injury.id).future);
});

/// Progreso semanal de la rutina activa, alineado con las sesiones registradas.
/// [completed] = sesiones de esta rutina completadas esta semana (desde el lunes),
/// [target] = frecuencia semanal planificada de la rutina,
/// [exerciseCount] = nº de ejercicios de la rutina.
typedef WeeklyRoutineStats = ({
  int completed,
  int target,
  double progress,
  int exerciseCount,
});

final weeklyRoutineProgressProvider = Provider.autoDispose<WeeklyRoutineStats>((ref) {
  final routine = ref.watch(activeRoutineProvider).value;
  if (routine == null) {
    return (completed: 0, target: 0, progress: 0.0, exerciseCount: 0);
  }

  final sessions = ref.watch(sessionHistoryProvider).value ?? [];
  final now = DateTime.now();
  // Lunes 00:00 de la semana actual.
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));

  final completed = sessions
      .where((s) =>
          s.routineId == routine.id && !s.completedAt.isBefore(startOfWeek))
      .length;

  final target = routine.frequencyPerWeek;
  final progress = target > 0 ? (completed / target).clamp(0.0, 1.0) : 0.0;

  return (
    completed: completed,
    target: target,
    progress: progress,
    exerciseCount: routine.exercises.length,
  );
});
