import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/exercise_provider.dart';
import '../bouncing_wrapper.dart';

class HomeExerciseCards extends ConsumerWidget {
  const HomeExerciseCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesState = ref.watch(recommendedExercisesProvider);

    return exercisesState.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return const Center(child: Text('No hay ejercicios recomendados hoy.'));
        }
        return Column(
          children: exercises.map((ex) {
            Color diffColor;
            switch (ex.difficulty) {
              case 'beginner': diffColor = const Color(0xFF20A090); break;
              case 'intermediate': diffColor = const Color(0xFFFF6B35); break;
              case 'advanced': diffColor = const Color(0xFFE65100); break;
              default: diffColor = const Color(0xFF20A090);
            }

            return BouncingWrapper(
              onTap: () => context.push('/exercise_detail', extra: ex),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('💪', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${ex.defaultSets} sets · ${ex.defaultReps}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: diffColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ex.difficultyLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: diffColor,
                                    ),
                                  ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight,
                        size: 18, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
