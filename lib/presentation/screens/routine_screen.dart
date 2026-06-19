import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/exercise_model.dart';
import '../widgets/checklist_item.dart';
import '../widgets/gradient_button.dart';
import '../providers/gamification_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/session_provider.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  bool _finishing = false;

  /// Registra la sesión del día usando la rutina activa del usuario.
  /// Las tareas diarias son de gamificación (sin exerciseId), por eso la
  /// sesión se construye desde los ejercicios de la rutina activa.
  Future<void> _finishRoutine() async {
    if (_finishing) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _finishing = true);

    try {
      final routines = await ref.read(routineRepositoryProvider).getRoutines();

      RoutineModel? active;
      for (final r in routines) {
        if (r.status == 'active' && r.exercises.isNotEmpty) {
          active = r;
          break;
        }
      }

      if (active == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
                'No tenés una rutina activa con ejercicios. Genera una desde tu lesión.'),
          ),
        );
        return;
      }

      await ref.read(sessionRepositoryProvider).createSession(
            routineId: active.id,
            exercises: active.exercises
                .map((ex) => <String, dynamic>{
                      'exerciseId': ex.exerciseId,
                      'setsCompleted': ex.customSets ?? 3,
                      'repsCompleted': ex.customReps ?? 12,
                    })
                .toList(),
          );

      if (!mounted) return;

      // Refrescar XP/nivel y logros desbloqueados.
      ref.read(dashboardStatsProvider.notifier).refresh();
      ref.read(achievementsProvider.notifier).refresh();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Sesión registrada! Excelente trabajo.',
              style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.message : 'Revisa tu conexión.';
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo registrar la sesión: $msg'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(dailyTasksProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Rutina de Hoy'),
      ),
      body: tasksState.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('No hay tareas para hoy.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24.0),
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
                                  const Icon(LucideIcons.checkCircle2,
                                      color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text('${task.title} completado!',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              backgroundColor: AppTheme.primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.only(
                                  bottom: 24, left: 24, right: 24),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 24,
                        offset: const Offset(0, -8)),
                  ],
                ),
                child: SafeArea(
                  child: GradientButton(
                    text: _finishing ? 'Guardando...' : 'Finalizar Rutina',
                    icon: LucideIcons.flag,
                    onPressed: _finishRoutine,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
