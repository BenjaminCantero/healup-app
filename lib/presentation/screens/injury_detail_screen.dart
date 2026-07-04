import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/injury_model.dart';
import '../widgets/custom_card.dart';
import '../widgets/bouncing_wrapper.dart';
import '../widgets/routine_exercise_card.dart';
import '../providers/routine_provider.dart';
import '../providers/session_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/injury_provider.dart';
import '../../data/models/exercise_model.dart';
import '../../core/network/api_exception.dart';

class InjuryDetailScreen extends ConsumerStatefulWidget {
  final InjuryModel injury;

  const InjuryDetailScreen({Key? key, required this.injury}) : super(key: key);

  @override
  ConsumerState<InjuryDetailScreen> createState() => _InjuryDetailScreenState();
}

class _InjuryDetailScreenState extends ConsumerState<InjuryDetailScreen> {
  final Map<String, bool> completedHabits = {};

  final Map<String, bool> tempCompletedExercises = {};

  bool _submittingSession = false;

  bool _generatingRoutine = false;

  int get _daysSinceInjury {
    try {
      final date = DateTime.parse(widget.injury.injuryDate);
      return DateTime.now().difference(date).inDays;
    } catch (_) {
      return 0;
    }
  }

  List<Map<String, dynamic>> _getDynamicHabits(InjuryModel injury) {
    final slug = injury.bodyPartSlug ?? '';
    final title = injury.title.toLowerCase();

    if (slug.contains('shoulder') || title.contains('hombro')) {
      return [
        {'id': 'h1', 'title': 'Estiramiento Péndulo', 'subtitle': '2 series de 10 reps', 'icon': LucideIcons.move},
        {'id': 'h2', 'title': 'Compresa Contraste', 'subtitle': 'Alternar frío/calor 15 min', 'icon': LucideIcons.thermometerSnowflake},
        {'id': 'h3', 'title': 'Postura Erguida', 'subtitle': 'Mantener hombros atrás', 'icon': LucideIcons.accessibility},
      ];
    } else if (slug.contains('knee') || title.contains('rodilla')) {
      return [
        {'id': 'h1', 'title': 'Elevación de Pierna', 'subtitle': '15 min en reposo', 'icon': LucideIcons.arrowUp},
        {'id': 'h2', 'title': 'Isometría Ligera', 'subtitle': 'Contracción sin peso', 'icon': LucideIcons.activity},
        {'id': 'h3', 'title': 'Crioterapia', 'subtitle': 'Hielo tras caminar', 'icon': LucideIcons.thermometerSnowflake},
      ];
    } else if (slug.contains('back') || title.contains('espalda')) {
      return [
        {'id': 'h1', 'title': 'Gato-Camello', 'subtitle': 'Estiramiento suave', 'icon': LucideIcons.move},
        {'id': 'h2', 'title': 'Calor Local', 'subtitle': 'Para relajar espasmos', 'icon': LucideIcons.flame},
        {'id': 'h3', 'title': 'Pausas Activas', 'subtitle': 'Caminar 5 min cada hr', 'icon': LucideIcons.timer},
      ];
    } else if (slug.contains('ankle') || title.contains('tobillo')) {
      return [
        {'id': 'h1', 'title': 'Movilidad Circular', 'subtitle': 'Rotar suavemente', 'icon': LucideIcons.rotateCcw},
        {'id': 'h2', 'title': 'Elevación', 'subtitle': 'Por encima del corazón', 'icon': LucideIcons.arrowUp},
        {'id': 'h3', 'title': 'Compresa Fría', 'subtitle': '10 min para desinflamar', 'icon': LucideIcons.thermometerSnowflake},
      ];
    } else {
      return [
        {'id': 'h1', 'title': 'Movilidad Suave', 'subtitle': '10 min diarios', 'icon': LucideIcons.move},
        {'id': 'h2', 'title': 'Aplicar Hielo', 'subtitle': '15 min en zona afectada', 'icon': LucideIcons.thermometerSnowflake},
        {'id': 'h3', 'title': 'Descanso Activo', 'subtitle': 'Evitar esfuerzos intensos', 'icon': LucideIcons.batteryCharging},
      ];
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
        actions: [_buildActionsMenu(injury)],
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
            ..._getDynamicHabits(injury).map((habit) {
              final hId = habit['id'] as String;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHabitTile(
                  title: habit['title'] as String,
                  subtitle: habit['subtitle'] as String,
                  icon: habit['icon'] as IconData,
                  isCompleted: completedHabits[hId] ?? false,
                  onTap: () {
                    setState(() {
                      completedHabits[hId] = !(completedHabits[hId] ?? false);
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsMenu(InjuryModel injury) {
    final isHealed = injury.status == 'healed';
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical),
      onSelected: (value) {
        switch (value) {
          case 'recovered':
            _setStatus(injury, 'healed');
            break;
          case 'reactivate':
            _setStatus(injury, 'active');
            break;
          case 'delete':
            _confirmDelete(injury);
            break;
        }
      },
      itemBuilder: (context) => [
        if (!isHealed)
          const PopupMenuItem(
            value: 'recovered',
            child: Row(
              children: [
                Icon(LucideIcons.checkCircle2,
                    size: 18, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text('Marcar como recuperada'),
              ],
            ),
          )
        else
          const PopupMenuItem(
            value: 'reactivate',
            child: Row(
              children: [
                Icon(LucideIcons.rotateCcw,
                    size: 18, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text('Reactivar lesión'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 18, color: AppTheme.errorColor),
              SizedBox(width: 12),
              Text('Eliminar lesión',
                  style: TextStyle(color: AppTheme.errorColor)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _setStatus(InjuryModel injury, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(injuriesProvider.notifier)
          .updateInjury(injury.id, {'status': status});
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status == 'healed'
                ? '¡Lesión marcada como recuperada!'
                : 'Lesión reactivada.',
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar la lesión: ${_errorText(e)}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _confirmDelete(InjuryModel injury) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lesión'),
        content: Text(
          '¿Seguro que quieres eliminar "${injury.title}"? '
          'Se borrará también su rutina y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(injuriesProvider.notifier).deleteInjury(injury.id);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Lesión eliminada.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar la lesión: ${_errorText(e)}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  String _errorText(Object e) =>
      e is ApiException ? e.message : e.toString();

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
            if (routine == null) return _buildEmptyRoutineState(injuryId);
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

  Widget _buildEmptyRoutineState(String injuryId) {
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
            'Genera una rutina personalizada según tu lesión para iniciar tu recuperación estructurada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          BouncingWrapper(
            onTap: () => _generateRoutine(injuryId),
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
              child: _generatingRoutine
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
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

  /// Genera la rutina en el backend (POST /routines/by-injury/:id/generate)
  /// y recarga la sección de rutina para mostrarla.
  Future<void> _generateRoutine(String injuryId) async {
    if (_generatingRoutine) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _generatingRoutine = true);

    try {
      await ref.read(routineRepositoryProvider).generateForInjury(injuryId);
      if (!mounted) return;

      // Recargar la rutina por lesión para que la sección muestre el plan.
      ref.invalidate(routineByInjuryProvider(injuryId));

      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Plan de recuperación generado!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.message : 'Revisa tu conexión.';
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo generar la rutina: $msg'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    } finally {
      if (mounted) setState(() => _generatingRoutine = false);
    }
  }

  /// Registra la sesión en el backend (POST /sessions) con los ejercicios
  /// marcados como completados, y refresca XP/nivel/logros.
  Future<void> _finishSession(BuildContext context, RoutineModel routine) async {
    if (_submittingSession) return;

    final messenger = ScaffoldMessenger.of(context);

    final completed = routine.exercises
        .where((ex) => tempCompletedExercises[ex.id] ?? false)
        .toList();

    if (completed.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Marca al menos un ejercicio para registrar la sesión.'),
        ),
      );
      return;
    }

    setState(() => _submittingSession = true);

    try {
      await ref.read(sessionRepositoryProvider).createSession(
            routineId: routine.id,
            exercises: completed
                .map((ex) => <String, dynamic>{
                      'exerciseId': ex.exerciseId,
                      'setsCompleted': ex.effectiveSets,
                      'repsCompleted': ex.effectiveReps,
                    })
                .toList(),
          );

      if (!mounted) return;

      // Refrescar estadísticas (XP, nivel) y logros recién desbloqueados.
      ref.read(dashboardStatsProvider.notifier).refresh();
      ref.read(achievementsProvider.notifier).refresh();

      setState(() => tempCompletedExercises.clear());

      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Sesión registrada! Sigue así 💪'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
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
      if (mounted) setState(() => _submittingSession = false);
    }
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
          ...routine.exercises.asMap().entries.map((entry) {
            final ex = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RoutineExerciseCard(
                exercise: ex,
                position: entry.key + 1,
                isCompleted: tempCompletedExercises[ex.id] ?? false,
                onToggleComplete: () {
                  setState(() {
                    tempCompletedExercises[ex.id] =
                        !(tempCompletedExercises[ex.id] ?? false);
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _submittingSession ? null : () => _finishSession(context, routine),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppTheme.primaryColor.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _submittingSession
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
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
