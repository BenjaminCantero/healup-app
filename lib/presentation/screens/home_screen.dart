import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/bouncing_wrapper.dart';
import '../providers/routine_provider.dart';
import '../providers/injury_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/home/home_modern_header.dart';
import '../widgets/home/home_quick_stats_row.dart';
import '../widgets/home/hero_progress_card.dart';
import '../widgets/home/coach_tip_card.dart';
import '../widgets/home/weekly_progress_chart.dart';
import '../widgets/home/home_exercise_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).value;
    final userName = authState?.user?.fullName.split(' ').first ?? 'Amigo';
    final avatarUrl = authState?.user?.profile?.avatarUrl;
    final progressVal = ref.watch(routineProgressProvider);
    final dashStats = ref.watch(dashboardStatsProvider);
    final streakDays = dashStats.value?.streakDays ?? 0;
    const coachTips = [
      {'title': '¡Buen ritmo!', 'message': 'El descanso también es parte de la recuperación — asegúrate de dormir 8 horas.', 'icon': '🧠'},
      {'title': 'Hidratación clave', 'message': 'Beber al menos 2L de agua hoy acelera la recuperación de tejidos.', 'icon': '💧'},
      {'title': 'Reducción notable', 'message': 'Mantén la constancia con tus ejercicios diarios. ¡Cada día cuenta!', 'icon': '📉'},
    ];
    final coachTip = coachTips[DateTime.now().day % coachTips.length];

    final injuries = ref.watch(injuriesProvider).value ?? [];
    final activeInjury = injuries.where((i) => i.status != 'healed').toList().isNotEmpty
        ? injuries.firstWhere((i) => i.status != 'healed')
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, top: 16.0, bottom: 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeModernHeader(userName: userName, avatarUrl: avatarUrl),
              const SizedBox(height: 24),

              // Streak + Quick actions row
              HomeQuickStatsRow(streakDays: streakDays),
              const SizedBox(height: 24),

              // Hero progress card
              BouncingWrapper(
                onTap: () {
                  if (activeInjury != null) {
                    context.push('/injury_detail', extra: activeInjury);
                  } else {
                    context.push('/add_injury');
                  }
                },
                child: HeroProgressCard(progressVal: progressVal, activeInjury: activeInjury),
              ),
              const SizedBox(height: 24),

              // Coach AI tip
              CoachTipCard(tip: coachTip),
              const SizedBox(height: 28),

              // Weekly tracking
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seguimiento Diario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  BouncingWrapper(
                    onTap: () => context.push('/pain_log'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ver todo',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BouncingWrapper(
                onTap: () {},
                child: CustomCard(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 180,
                    child: WeeklyProgressChart(progressVal: progressVal),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Exercises section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ejercicios de Hoy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  BouncingWrapper(
                    onTap: () => context.push('/routine'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ver rutina',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const HomeExerciseCards(),
            ],
          ),
        ),
      ),
    );
  }
}
