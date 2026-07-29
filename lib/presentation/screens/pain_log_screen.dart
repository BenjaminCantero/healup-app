import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../providers/pain_log_provider.dart';
import '../../data/models/pain_log_model.dart';

class PainLogScreen extends ConsumerStatefulWidget {
  const PainLogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PainLogScreen> createState() => _PainLogScreenState();
}

class _PainLogScreenState extends ConsumerState<PainLogScreen> {
  double _todayPain = 2.0;
  int _selectedDay = 0; // index of the selected day
  String _todayNote = '';
  bool _saved = false;

  final List<Map<String, String>> _emojiScale = [
    {'emoji': '😄', 'label': 'Sin dolor'},
    {'emoji': '🙂', 'label': 'Leve'},
    {'emoji': '😐', 'label': 'Moderado'},
    {'emoji': '😕', 'label': 'Fuerte'},
    {'emoji': '😣', 'label': 'Intenso'},
    {'emoji': '😭', 'label': 'Insoportable'},
  ];

  String get _currentEmoji {
    final index = ((_todayPain / 10) * 5).round().clamp(0, 5);
    return _emojiScale[index]['emoji']!;
  }

  String get _currentLabel {
    final index = ((_todayPain / 10) * 5).round().clamp(0, 5);
    return _emojiScale[index]['label']!;
  }

  Color get _painColor {
    if (_todayPain <= 2) return const Color(0xFF20A090);
    if (_todayPain <= 4) return const Color(0xFF4CAF50);
    if (_todayPain <= 6) return const Color(0xFFFF9800);
    if (_todayPain <= 8) return const Color(0xFFFF5722);
    return const Color(0xFFF44336);
  }

  void _save() {
    ref.read(painLogNotifierProvider.notifier).addLog(
      _todayPain.toInt(),
      notes: _todayNote.isNotEmpty ? _todayNote : null,
    ).then((_) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.checkCircle2, color: Colors.white),
              SizedBox(width: 12),
              Text('Dolor registrado correctamente',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(24),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(painLogsProvider);
    final statsAsync = ref.watch(painStatsProvider);
    final isSaving = ref.watch(painLogNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Registro de Dolor'),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.arrowLeft,
                color: AppTheme.textPrimary, size: 20),
          ),
        ),
      ),
      body: logsAsync.when(
        data: (logs) {
          // Sort logs chronologically
          final sortedLogs = List<PainLogModel>.from(logs)
            ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
            
          // If we have selected an index out of bounds, fix it
          if (sortedLogs.isNotEmpty && _selectedDay >= sortedLogs.length) {
            _selectedDay = sortedLogs.length - 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodayCard(),
                const SizedBox(height: 28),
                if (sortedLogs.isNotEmpty) ...[
                  const Text(
                    'Historial semanal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(sortedLogs),
                  const SizedBox(height: 28),
                  const Text(
                    'Notas del día',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDaySelector(sortedLogs),
                  const SizedBox(height: 12),
                  _buildSelectedDayNote(sortedLogs),
                  const SizedBox(height: 28),
                ],
                statsAsync.when(
                  data: (stats) => _buildTrendSummary(stats, sortedLogs),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: (_saved || isSaving) ? null : _save,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: (_saved || isSaving) ? null : AppTheme.primaryGradient,
              color: (_saved || isSaving) ? AppTheme.primaryLight : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: (_saved || isSaving)
                  ? null
                  : [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2),
                  )
                else
                  Icon(
                    _saved ? LucideIcons.checkCircle2 : LucideIcons.save,
                    color: _saved ? AppTheme.primaryColor : Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 10),
                Text(
                  isSaving ? 'Guardando...' : _saved ? 'Guardado' : 'Guardar registro de hoy',
                  style: TextStyle(
                    color: (_saved || isSaving) ? AppTheme.primaryColor : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoy — ${_getDayName(DateTime.now().weekday)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¿Cómo está tu dolor?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _currentEmoji,
                  key: ValueKey(_currentEmoji),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _todayPain.toInt().toString(),
                  key: ValueKey(_todayPain.toInt()),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: _painColor,
                    letterSpacing: -4,
                    height: 1,
                  ),
                ),
              ),
              const Text(
                ' /10',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _currentLabel,
              key: ValueKey(_currentLabel),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _painColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _painColor,
              inactiveTrackColor: AppTheme.backgroundColor,
              thumbColor: _painColor,
              overlayColor: _painColor.withValues(alpha: 0.15),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _todayPain,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (val) => setState(() => _todayPain = val),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sin dolor', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              Text('Insoportable', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              maxLines: 2,
              onChanged: (v) => setState(() => _todayNote = v),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Añade una nota (opcional)...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<PainLogModel> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tendencia de dolor',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.activity, size: 12, color: AppTheme.primaryColor),
                    SizedBox(width: 4),
                    Text(
                      'Últimos registros',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.textSecondary.withValues(alpha: 0.1),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= 0 && i < history.length) {
                          final dateStr = '${history[i].loggedAt.day}/${history[i].loggedAt.month}';
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              dateStr,
                              style: TextStyle(
                                color: i == _selectedDay ? AppTheme.primaryColor : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: i == _selectedDay ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (history.length - 1).toDouble() > 0 ? (history.length - 1).toDouble() : 1.0,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: history.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.painLevel.toDouble());
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: spot.x.toInt() == _selectedDay ? 6 : 3,
                        color: spot.x.toInt() == _selectedDay ? AppTheme.primaryColor : Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppTheme.primaryColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                          AppTheme.primaryColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(List<PainLogModel> history) {
    if (history.isEmpty) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: history.asMap().entries.map((entry) {
          final i = entry.key;
          final day = entry.value;
          final isSelected = i == _selectedDay;
          final dateStr = '${day.loggedAt.day}/${day.loggedAt.month}';
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.painLevel}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedDayNote(List<PainLogModel> history) {
    if (history.isEmpty || _selectedDay >= history.length) return const SizedBox.shrink();
    final day = history[_selectedDay];
    
    final note = day.notes?.isNotEmpty == true ? day.notes! : 'Sin notas registradas para este día.';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.messageSquare, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '"$note"',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSummary(PainStatsModel stats, List<PainLogModel> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('📉', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Promedio de dolor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu dolor promedio es de ${stats.averagePain.toStringAsFixed(1)}. Has registrado ${stats.logCount} veces.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[(weekday - 1).clamp(0, 6)];
  }
}
