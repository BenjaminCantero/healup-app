import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/bouncing_wrapper.dart';

class InjuriesScreen extends ConsumerStatefulWidget {
  const InjuriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InjuriesScreen> createState() => _InjuriesScreenState();
}

class _InjuriesScreenState extends ConsumerState<InjuriesScreen> {
  bool stretchCompleted = true;
  bool iceCompleted = false;
  bool medsCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detalle de Lesión'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 120.0), // padding for Glass NavBar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(LucideIcons.activitySquare, color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rodilla Izquierda',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Esguince LCL • Día 7',
                          style: TextStyle(
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
            ),
            const SizedBox(height: 32),
            const Text(
              'Fase de Recuperación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso Estimado',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('50%', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w800, fontSize: 13)),
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
                            spots: const [
                              FlSpot(0, 3.5),
                              FlSpot(1, 3.8),
                              FlSpot(2, 4.2),
                              FlSpot(3, 4.5),
                              FlSpot(4, 5.0),
                              FlSpot(5, 5.5),
                              FlSpot(6, 6.0),
                            ],
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: AppTheme.primaryColor,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [AppTheme.primaryColor.withValues(alpha: 0.3), AppTheme.primaryColor.withValues(alpha: 0.0)],
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
            ),
            const SizedBox(height: 32),
            const Text(
              'Hábitos Diarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
            ),
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
            color: isCompleted ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.02),
            width: isCompleted ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
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
                color: isCompleted ? AppTheme.primaryColor : AppTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isCompleted ? Colors.white : AppTheme.textSecondary, size: 20),
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
                      color: isCompleted ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: isCompleted ? AppTheme.primaryColor.withValues(alpha: 0.8) : AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: isCompleted
                  ? const Icon(LucideIcons.checkCircle2, color: AppTheme.primaryColor, size: 28, key: ValueKey('checked'))
                  : Icon(LucideIcons.circle, color: AppTheme.textSecondary.withValues(alpha: 0.3), size: 28, key: const ValueKey('unchecked')),
            ),
          ],
        ),
      ),
    );
  }
}
