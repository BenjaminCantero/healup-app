import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/injury_model.dart';
import '../widgets/bouncing_wrapper.dart';
import '../providers/injury_provider.dart';

class InjuriesScreen extends ConsumerWidget {
  const InjuriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final injuriesAsync = ref.watch(injuriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mis Lesiones'),
        backgroundColor: Colors.transparent,
        actions: [
          BouncingWrapper(
            onTap: () => context.push('/body_map'),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.map,
                  color: AppTheme.primaryColor, size: 20),
            ),
          ),
        ],
      ),
      body: injuriesAsync.when(
        data: (injuries) {
          if (injuries.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(injuriesProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 120),
              itemCount: injuries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '${injuries.length} lesión${injuries.length > 1 ? 'es' : ''} registrada${injuries.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }
                final injury = injuries[index - 1];
                return _buildInjuryCard(context, injury);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.frown,
                  size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text('Error al cargar lesiones',
                  style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              BouncingWrapper(
                onTap: () => ref.invalidate(injuriesProvider),
                child: const Text('Reintentar',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/add_injury'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: const Text(
            'Nueva Lesión',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(LucideIcons.heartPulse,
                  size: 48, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes lesiones registradas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las lesiones que registres aparecerán aquí.\nUsa el botón "Nueva Lesión" o el mapa corporal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            BouncingWrapper(
              onTap: () => context.push('/body_map'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.map,
                        color: AppTheme.primaryColor, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Explorar Mapa Corporal',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryCard(BuildContext context, InjuryModel injury) {
    final days = _daysSince(injury.injuryDate);
    final severityColor = _severityColor(injury.severity);

    return BouncingWrapper(
      onTap: () => context.push('/injury_detail', extra: injury),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _injuryIcon(injury.bodyPartSlug),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          injury.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          injury.severityLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: severityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (injury.bodyPartName != null) ...[
                        Text(
                          injury.bodyPartName!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                              color: AppTheme.textSecondary,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        'Día $days',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: injury.status == 'healed'
                              ? const Color(0xFF2EC4B6).withValues(alpha: 0.1)
                              : AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          injury.statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: injury.status == 'healed'
                                ? const Color(0xFF2EC4B6)
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _injuryIcon(String? bodyPartSlug) {
    const icons = {
      'head': '🤕',
      'neck': '🧣',
      'left-shoulder': '💪',
      'right-shoulder': '💪',
      'left-elbow': '🦾',
      'right-elbow': '🦾',
      'left-wrist': '🖐️',
      'right-wrist': '🖐️',
      'chest': '🫀',
      'upper-back': '🔙',
      'lower-back': '🔙',
      'abdomen': '🫃',
      'left-hip': '🦵',
      'right-hip': '🦵',
      'left-knee': '🦵',
      'right-knee': '🦵',
      'left-ankle': '🦶',
      'right-ankle': '🦶',
      'left-foot': '🦶',
      'right-foot': '🦶',
    };
    return Center(
      child: Text(
        icons[bodyPartSlug] ?? '🤕',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  int _daysSince(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateTime.now().difference(date).inDays;
    } catch (_) {
      return 0;
    }
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
}
