import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class WeeklyProgressChart extends StatelessWidget {
  final double progressVal;

  const WeeklyProgressChart({Key? key, required this.progressVal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 6,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                final isToday = value.toInt() == 6;
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: isToday
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
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
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBar(0, 2, false),
          _buildBar(1, 2, false),
          _buildBar(2, 5, true),
          _buildBar(3, 4, false),
          _buildBar(4, 2, false),
          _buildBar(5, 3, true),
          _buildBar(6, progressVal * 6, progressVal > 0),
        ],
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double y, bool isHighlighted) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y == 0 ? 0.2 : y,
          gradient: isHighlighted
              ? AppTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    AppTheme.textSecondary.withValues(alpha: 0.2),
                    AppTheme.textSecondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
          width: 14,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 6,
            color: AppTheme.backgroundColor,
          ),
        ),
      ],
    );
  }
}
