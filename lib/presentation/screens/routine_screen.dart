import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/gamification_model.dart';
import '../../data/models/injury_model.dart';
import '../widgets/checklist_item.dart';
import '../widgets/gradient_button.dart';
import '../widgets/routine_exercise_card.dart';
import '../providers/gamification_provider.dart';
import '../providers/injury_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/session_provider.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  bool _isFinishing = false;
  final DateTime _startTime = DateTime.now();

  /// IDs de los `routine_exercises` marcados como completados en esta sesión.
  final Set<String> _completedExerciseIds = {};

  @override
  Widget build(BuildContext context) {
    final activeInjury = ref.watch(activeInjuryProvider);
    final tasksState = ref.watch(dailyTasksProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Rutina de Hoy'),
      ),
      body: activeInjury == null
          ? _buildDailyTasksBody(context, tasksState)
          : _buildRoutineByInjuryBody(
              context,
              ref.watch(routineByInjuryProvider(activeInjury.id)),
              activeInjury,
            ),
    );
  }

  Widget _buildDailyTasksBody(
    BuildContext context,
    AsyncValue<List<DailyTaskModel>> tasksState,
  ) {
    return tasksState.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.checkCircle2,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sin tareas para hoy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Añade tareas diarias desde tu perfil',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        final completedTasks = tasks.where((t) => t.isCompletedToday).toList();
        final progress = tasks.isEmpty
            ? 0.0
            : completedTasks.length / tasks.length;

        return Column(
          children: [
            // Progress bar header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${completedTasks.length} / ${tasks.length} completadas',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.primaryLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            // Task list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8,
                ),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ChecklistItem(
                    title: task.title,
                    subtitle: task.category,
                    isCompleted: task.isCompletedToday,
                    onTap: () {
                      if (!task.isCompletedToday) {
                        ref
                            .read(dailyTasksProvider.notifier)
                            .completeTask(task.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  LucideIcons.checkCircle2,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${task.title} completado!',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppTheme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(
                              bottom: 24,
                              left: 24,
                              right: 24,
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),

            // Finish button
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                child: _isFinishing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : GradientButton(
                        text: completedTasks.isEmpty
                            ? 'Completar sin tareas'
                            : 'Finalizar Rutina',
                        icon: LucideIcons.flag,
                        onPressed: () => _finishRoutine(context, tasks),
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildRoutineByInjuryBody(
    BuildContext context,
    AsyncValue<RoutineModel?> routineAsync,
    InjuryModel activeInjury,
  ) {
    return routineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Error al cargar rutina: $error')),
      data: (routine) {
        if (routine == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.activity,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes una rutina generada para tu lesión activa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Genera un plan de rehabilitación personalizado según tu lesión activa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _generateRoutine(context, activeInjury.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Generar Rutina',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final routineExercises = routine.exercises;
        // Solo contamos como completados los ejercicios que siguen existiendo
        // en la rutina (evita divisores/estados obsoletos tras un refresh).
        final validIds = routineExercises.map((e) => e.id).toSet();
        final completedCount =
            _completedExerciseIds.where(validIds.contains).length;
        final progress = routineExercises.isEmpty
            ? 0.0
            : completedCount / routineExercises.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeInjury.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${routine.frequencyPerWeek} días por semana • ${routine.durationWeeks ?? 0} semanas',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (routineExercises.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completedCount / ${routineExercises.length} completados',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.primaryLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: routineExercises.isEmpty
                  ? const Center(
                      child: Text(
                        'Esta rutina aún no tiene ejercicios.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: routineExercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ex = routineExercises[index];
                        return RoutineExerciseCard(
                          exercise: ex,
                          position: index + 1,
                          isCompleted: _completedExerciseIds.contains(ex.id),
                          onToggleComplete: () {
                            setState(() {
                              if (!_completedExerciseIds.add(ex.id)) {
                                _completedExerciseIds.remove(ex.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            if (routineExercises.isNotEmpty)
              _buildFinishBar(context, routine, routineExercises, completedCount),
          ],
        );
      },
    );
  }

  Future<void> _generateRoutine(BuildContext context, String injuryId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(routineRepositoryProvider).generateForInjury(injuryId);
      ref.invalidate(routineByInjuryProvider(injuryId));
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Rutina generada correctamente.'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo generar la rutina: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _finishRoutine(
    BuildContext context,
    List<DailyTaskModel> tasks,
  ) async {
    setState(() => _isFinishing = true);
    try {
      final durationMinutes = DateTime.now().difference(_startTime).inMinutes;

      // Persist session to backend — triggers achievement evaluation
      await ref
          .read(sessionHistoryProvider.notifier)
          .createSession(
            durationMinutes: durationMinutes > 0 ? durationMinutes : 1,
            exercises: const [], // daily tasks don't map 1:1 to exercises
          );

      // Refresh gamification stats in background
      ref.read(dashboardStatsProvider.notifier).refresh();
      ref.read(achievementsProvider.notifier).refresh();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(LucideIcons.trophy, color: Colors.white),
              SizedBox(width: 12),
              Text(
                '¡Excelente trabajo! Rutina guardada.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(24),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar sesión: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  Widget _buildFinishBar(
    BuildContext context,
    RoutineModel routine,
    List<RoutineExerciseModel> exercises,
    int completedCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: _isFinishing
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : GradientButton(
                text: completedCount == 0
                    ? 'Marca al menos un ejercicio'
                    : 'Finalizar Rutina',
                icon: LucideIcons.flag,
                onPressed: () => _finishInjuryRoutine(context, routine, exercises),
              ),
      ),
    );
  }

  Future<void> _finishInjuryRoutine(
    BuildContext context,
    RoutineModel routine,
    List<RoutineExerciseModel> exercises,
  ) async {
    final completed = exercises
        .where((ex) => _completedExerciseIds.contains(ex.id))
        .map((ex) => {
              'exerciseId': ex.exerciseId,
              'setsCompleted': ex.effectiveSets,
              'repsCompleted': ex.effectiveReps,
            })
        .toList();

    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marca al menos un ejercicio como completado.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isFinishing = true);
    try {
      final durationMinutes = DateTime.now().difference(_startTime).inMinutes;

      await ref.read(sessionHistoryProvider.notifier).createSession(
            routineId: routine.id,
            durationMinutes: durationMinutes > 0 ? durationMinutes : 1,
            exercises: completed,
          );

      ref.read(dashboardStatsProvider.notifier).refresh();
      ref.read(achievementsProvider.notifier).refresh();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(LucideIcons.trophy, color: Colors.white),
              SizedBox(width: 12),
              Text(
                '¡Excelente trabajo! Rutina guardada.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(24),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar sesión: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }
}
