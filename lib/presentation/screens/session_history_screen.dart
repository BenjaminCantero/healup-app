import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../providers/session_provider.dart';
import '../../data/models/session_model.dart';

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft,
              color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Historial de Sesiones'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw,
                color: AppTheme.textSecondary, size: 18),
            onPressed: () =>
                ref.read(sessionHistoryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.calendarDays,
                        color: AppTheme.primaryColor, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin sesiones aún',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completa tu primera rutina para verla aquí',
                    style: TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group sessions by date
          final grouped = <String, List<SessionModel>>{};
          for (final s in sessions) {
            final key = s.formattedDate;
            grouped.putIfAbsent(key, () => []).add(s);
          }

          final dates = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            itemCount: dates.length,
            itemBuilder: (context, i) {
              final date = dates[i];
              final daySessions = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  ...daySessions.map(
                    (session) => _SessionCard(session: session),
                  ),
                ],
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: 5,
          itemBuilder: (_, __) => _SessionCardSkeleton(),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.wifiOff,
                  color: AppTheme.textSecondary, size: 40),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar el historial',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(sessionHistoryProvider.notifier).refresh(),
                child: const Text('Reintentar',
                    style: TextStyle(color: AppTheme.primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final painColor = session.painAfter == null
        ? AppTheme.textSecondary
        : session.painAfter! <= 3
            ? AppTheme.primaryColor
            : session.painAfter! <= 6
                ? const Color(0xFFFF9800)
                : const Color(0xFFE53935);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.dumbbell,
                color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.routineTitle ?? 'Sesión libre',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.clock,
                        size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      session.durationMinutes != null
                          ? '${session.durationMinutes} min'
                          : 'Duración no registrada',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.mapPin,
                        size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      session.formattedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pain badge
          if (session.painAfter != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: painColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${session.painAfter}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: painColor,
                    ),
                  ),
                  Text(
                    'dolor',
                    style: TextStyle(
                      fontSize: 10,
                      color: painColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 14,
                    width: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(7),
                    )),
                const SizedBox(height: 8),
                Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(6),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
