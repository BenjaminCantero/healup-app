import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/injury_model.dart';
import '../widgets/custom_card.dart';
import '../widgets/bouncing_wrapper.dart';
import '../providers/routine_provider.dart';
import '../../data/models/exercise_model.dart';

class InjuryDetailScreen extends ConsumerStatefulWidget {
  final InjuryModel injury;

  const InjuryDetailScreen({Key? key, required this.injury}) : super(key: key);

  @override
  ConsumerState<InjuryDetailScreen> createState() => _InjuryDetailScreenState();
}

class _InjuryDetailScreenState extends ConsumerState<InjuryDetailScreen> {
  bool stretchCompleted = true;
  bool iceCompleted = false;
  bool medsCompleted = true;
  
  final Map<String, bool> tempCompletedExercises = {};

  int get _daysSinceInjury {
    try {
      final date = DateTime.parse(widget.injury.injuryDate);
      return DateTime.now().difference(date).inDays;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final injury = widget.injury;
    final days = _daysSinceInjury;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(injury.title),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            left: 24.0, right: 24.0, top: 16.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInjuryHeader(injury, days),
            const SizedBox(height: 32),
            _buildSectionTitle('Fase de Recuperación'),
            const SizedBox(height: 16),
            _buildRecoveryChart(injury, days),

            if (injury.symptoms.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildSectionTitle('Síntomas Reportados'),
              const SizedBox(height: 12),
              ...injury.symptoms.map((s) => _buildBulletPoint(s)).toList(),
            ],

            if (injury.recommendations.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildSectionTitle('Recomendaciones de Recuperación'),
              const SizedBox(height: 12),
              ...injury.recommendations.map((r) => _buildBulletPoint(r)).toList(),
            ],

            if (injury.importantNote != null && injury.importantNote!.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildInfoAlert('Nota Importante', injury.importantNote!, LucideIcons.alertCircle, AppTheme.primaryColor),
            ],

            if (injury.whenToSeeSpecialist != null && injury.whenToSeeSpecialist!.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildInfoAlert('Cuándo ver a un especialista', injury.whenToSeeSpecialist!, LucideIcons.stethoscope, const Color(0xFFFF6B6B)),
            ],

            const SizedBox(height: 32),
            _buildRoutineSection(context, ref, injury.id),

            const SizedBox(height: 32),
            _buildSectionTitle('Hábitos Diarios'),
            const SizedBox(height: 16),
            _buildHabitTile(
              title: 'Estiramientos',
              subtitle: '2 sesiones diarias',
              icon: LucideIcons.move,
              isCompleted: stretchCompleted,
              onTap: () => setState(() => stretchCompleted = !stretchCompleted),
            ),
            const SizedBox(height: 12),
            _buildHabitTile(
              title: 'Aplicar Hielo',
              subtitle: '15 min cada 4 hrs',
              icon: LucideIcons.thermometerSnowflake,
              isCompleted: iceCompleted,
              onTap: () => setState(() => iceCompleted = !iceCompleted),
            ),
            const SizedBox(height: 12),
            _buildHabitTile(
              title: 'Medicamentos',
              subtitle: 'Ibuprofeno 400mg',
              icon: LucideIcons.pill,
              isCompleted: medsCompleted,
              onTap: () => setState(() => medsCompleted = !medsCompleted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryHeader(InjuryModel injury, int days) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _severityColor(injury.severity).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _severityIcon(injury.severity),
              color: _severityColor(injury.severity),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  injury.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${injury.bodyPartName ?? ''}${injury.bodyPartName != null ? ' • ' : ''}${injury.statusLabel} • Día $days',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryChart(InjuryModel injury, int days) {
    final progress = (days / 21).clamp(0.0, 1.0);

    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso Estimado',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                        7,
                        (i) => FlSpot(
                            i.toDouble(), 3.0 + progress * 3.5 * (i / 6))),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.3),
                          AppTheme.primaryColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return BouncingWrapper(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.02),
            width: isCompleted ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.primaryColor
                    : AppTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isCompleted ? Colors.white : AppTheme.textSecondary,
                  size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 13,
                        color: isCompleted
                            ? AppTheme.primaryColor.withValues(alpha: 0.8)
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: isCompleted
                  ? const Icon(LucideIcons.checkCircle2,
                      color: AppTheme.primaryColor,
                      size: 28,
                      key: ValueKey('checked'))
                  : Icon(LucideIcons.circle,
                      color: AppTheme.textSecondary.withValues(alpha: 0.3),
                      size: 28,
                      key: const ValueKey('unchecked')),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'mild':
        return const Color(0xFF2EC4B6);
      case 'severe':
        return const Color(0xFFFF6B6B);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'mild':
        return LucideIcons.alertCircle;
      case 'severe':
        return LucideIcons.alertTriangle;
      default:
        return LucideIcons.activitySquare;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 12.0),
            child: Icon(LucideIcons.circle, size: 8, color: AppTheme.primaryColor),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoAlert(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.textPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSection(BuildContext context, WidgetRef ref, String injuryId) {
    final routinesAsync = ref.watch(routineByInjuryProvider(injuryId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tu Plan de Rehabilitación'),
        const SizedBox(height: 16),
        routinesAsync.when(
          data: (routine) {
            if (routine == null) return _buildEmptyRoutineState();
            return _buildActiveRoutineView(context, ref, routine);
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          ),
          error: (err, stack) => CustomCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Error al cargar tu rutina.\nRevisa tu conexión.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRoutineState() {
    return CustomCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.activity, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes rutina',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Asigna o genera una rutina personalizada para iniciar tu recuperación estructurada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          BouncingWrapper(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generador de rutinas con IA (Próximamente)')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Generar Plan de Recuperación',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRoutineView(BuildContext context, WidgetRef ref, RoutineModel routine) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${routine.frequencyPerWeek} días a la semana',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tempCompletedExercises.values.where((v) => v).length} / ${routine.exercises.length}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...routine.exercises.map((ex) {
            final isCompleted = tempCompletedExercises[ex.id] ?? false;
            return BouncingWrapper(
              onTap: () {
                setState(() {
                  tempCompletedExercises[ex.id] = !isCompleted;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.primaryColor.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.primaryColor.withValues(alpha: 0.3)
                        : AppTheme.textSecondary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? AppTheme.primaryColor 
                            : AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.check,
                        color: isCompleted ? Colors.white : AppTheme.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.exerciseTitle ?? 'Ejercicio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ex.customSets ?? 3} series x ${ex.customReps ?? 12} reps',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Post to /sessions -> Update UI Optimistically -> Show Confetti
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('+150 XP • ¡Sesión completada!'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Finalizar Sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
