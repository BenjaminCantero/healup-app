import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final double height;
  final bool showLabel;

  const ProgressBar({
    Key? key,
    required this.progress,
    this.color,
    this.height = 10.0,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showLabel) ...[
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: color ?? AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
