import 'package:flutter/material.dart';
import '../../core/constants/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/progress_bar.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: MockData.achievements.length,
        itemBuilder: (context, index) {
          final achievement = MockData.achievements[index];
          final bool isUnlocked = achievement['isUnlocked'];

          return CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppTheme.primaryLight.withOpacity(0.3)
                        : AppTheme.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      achievement['icon'],
                      style: TextStyle(fontSize: 28, color: isUnlocked ? null : Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  achievement['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                ProgressBar(
                  progress: achievement['progress'],
                  height: 6,
                  color: isUnlocked ? AppTheme.primaryColor : Colors.grey.shade400,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
