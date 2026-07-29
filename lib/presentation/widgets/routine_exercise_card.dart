import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_model.dart';

/// Tarjeta enriquecida de un ejercicio dentro de una rutina.
///
/// Muestra imagen, dificultad, series/reps/duración y, al expandir, la
/// descripción e instrucciones completas provenientes de la base de datos.
/// Es la vista única compartida por la pantalla de Rutina y el detalle de
/// lesión para que ambas se rendericen igual.
class RoutineExerciseCard extends StatefulWidget {
  final RoutineExerciseModel exercise;
  final int position;
  final bool isCompleted;
  final VoidCallback onToggleComplete;

  const RoutineExerciseCard({
    super.key,
    required this.exercise,
    required this.position,
    required this.isCompleted,
    required this.onToggleComplete,
  });

  @override
  State<RoutineExerciseCard> createState() => _RoutineExerciseCardState();
}

class _RoutineExerciseCardState extends State<RoutineExerciseCard> {
  bool _expanded = false;

  Color get _difficultyColor => switch (widget.exercise.exerciseDifficulty) {
        'beginner' => AppTheme.primaryColor,
        'intermediate' => const Color(0xFFE0A82E),
        'advanced' => AppTheme.errorColor,
        _ => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final hasDetails =
        (ex.exerciseDescription != null &&
                ex.exerciseDescription!.trim().isNotEmpty) ||
            (ex.exerciseInstructions != null &&
                ex.exerciseInstructions!.trim().isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: hasDetails ? () => setState(() => _expanded = !_expanded) : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckCircle(),
                    const SizedBox(width: 12),
                    _buildThumbnail(ex),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.position}. ${ex.exerciseTitle ?? 'Ejercicio'}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: widget.isCompleted
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              decoration: widget.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildChip(
                                LucideIcons.repeat,
                                '${ex.effectiveSets} series',
                              ),
                              _buildChip(
                                LucideIcons.dumbbell,
                                '${ex.effectiveReps} reps',
                              ),
                              if (ex.exerciseDurationSeconds != null &&
                                  ex.exerciseDurationSeconds! > 0)
                                _buildChip(
                                  LucideIcons.clock,
                                  '${ex.exerciseDurationSeconds}s',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildDifficultyBadge(ex),
                        if (hasDetails) ...[
                          const SizedBox(height: 10),
                          Icon(
                            _expanded
                                ? LucideIcons.chevronUp
                                : LucideIcons.chevronDown,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: _buildDetails(ex),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckCircle() {
    return GestureDetector(
      onTap: widget.onToggleComplete,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: widget.isCompleted
              ? AppTheme.primaryColor
              : Colors.transparent,
          border: Border.all(
            color: widget.isCompleted
                ? AppTheme.primaryColor
                : AppTheme.textSecondary.withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildThumbnail(RoutineExerciseModel ex) {
    final url = ex.exerciseImageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 56,
        height: 56,
        color: AppTheme.primaryLight,
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  LucideIcons.activity,
                  color: AppTheme.primaryColor,
                ),
              )
            : const Icon(LucideIcons.activity, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(RoutineExerciseModel ex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _difficultyColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ex.difficultyLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _difficultyColor,
        ),
      ),
    );
  }

  Widget _buildDetails(RoutineExerciseModel ex) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (ex.exerciseDescription != null &&
              ex.exerciseDescription!.trim().isNotEmpty) ...[
            Text(
              ex.exerciseDescription!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (ex.exerciseInstructions != null &&
              ex.exerciseInstructions!.trim().isNotEmpty) ...[
            const Text(
              'Instrucciones',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ex.exerciseInstructions!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
