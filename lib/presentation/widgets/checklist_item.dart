import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'custom_card.dart';
import 'bouncing_wrapper.dart';

class ChecklistItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback? onTap;

  const ChecklistItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: BouncingWrapper(
        onTap: onTap ?? () {},
        child: CustomCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16, key: ValueKey('checked'))
                      : const SizedBox(key: ValueKey('unchecked')),
                ),
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
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                      child: Text(title),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
