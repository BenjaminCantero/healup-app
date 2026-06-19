import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/checklist_item.dart';
import '../widgets/gradient_button.dart';
import '../providers/gamification_provider.dart';
import '../providers/session_provider.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  bool _isFinishing = false;
  final DateTime _startTime = DateTime.now();

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
                    child: const Icon(LucideIcons.checkCircle2,
                        color: AppTheme.primaryColor, size: 40),
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

          final completedTasks =
              tasks.where((t) => t.isCompletedToday).toList();
          final progress =
              tasks.isEmpty ? 0.0 : completedTasks.length / tasks.length;

          return Column(
            children: [
              // Progress bar header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
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
                            AppTheme.primaryColor),
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
                      horizontal: 24.0, vertical: 8),
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
                                  Text(
                                    '${task.title} completado!',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
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
                              color: AppTheme.primaryColor))
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
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _finishRoutine(BuildContext context, List tasks) async {
    setState(() => _isFinishing = true);
    try {
      final durationMinutes =
          DateTime.now().difference(_startTime).inMinutes;

      // Persist session to backend — triggers achievement evaluation
      await ref.read(sessionHistoryProvider.notifier).createSession(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
