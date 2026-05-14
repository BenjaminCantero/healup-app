import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/mock_data.dart';
import '../widgets/custom_card.dart';
import '../widgets/bouncing_wrapper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: _buildHeroHeader(context),
          ),
          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 28),
                  const Text(
                    'Historial de Lesiones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInjuryHistory(context),
                  const SizedBox(height: 28),
                  const Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: Column(
        children: [
          // Settings button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mi Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(LucideIcons.settings,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 3),
                  image: const DecorationImage(
                    image: NetworkImage(MockData.userAvatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(LucideIcons.pencil,
                      size: 14, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            MockData.userName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            MockData.userEmail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Level badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  MockData.userLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {
        'icon': '🔥',
        'value': '${MockData.streakDays}',
        'label': 'Racha',
        'unit': 'días',
      },
      {
        'icon': '📅',
        'value': '${MockData.totalDaysActive}',
        'label': 'Días activo',
        'unit': 'total',
      },
      {
        'icon': '✅',
        'value': '${MockData.totalRecoveredInjuries}',
        'label': 'Recuperadas',
        'unit': 'lesiones',
      },
    ];

    return Row(
      children: stats
          .map(
            (s) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    right: s != stats.last ? 10 : 0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(s['icon']!,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(
                      s['value']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      s['unit']!,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInjuryHistory(BuildContext context) {
    return Column(
      children: MockData.injuries.map((injury) {
        final progress = injury['progress'] as double;
        final isRecovered = injury['status'] == 'Recuperado';
        return BouncingWrapper(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isRecovered
                        ? AppTheme.primaryLight
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(injury['icon'],
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        injury['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${injury['type']} • ${injury['days']} días',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mini progress bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isRecovered
                                  ? AppTheme.primaryColor
                                  : const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRecovered
                            ? AppTheme.primaryLight
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isRecovered ? '✓ Listo' : injury['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isRecovered
                              ? AppTheme.primaryColor
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isRecovered
                            ? AppTheme.primaryColor
                            : const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsSection() {
    final groups = [
      {
        'title': 'Cuenta',
        'items': [
          {'icon': LucideIcons.user, 'label': 'Información personal'},
          {'icon': LucideIcons.bell, 'label': 'Notificaciones'},
          {'icon': LucideIcons.shield, 'label': 'Privacidad y Seguridad'},
        ],
      },
      {
        'title': 'Preferencias',
        'items': [
          {'icon': LucideIcons.moon, 'label': 'Modo Oscuro'},
          {'icon': LucideIcons.globe, 'label': 'Idioma'},
          {'icon': LucideIcons.heart, 'label': 'Conectar wearable'},
        ],
      },
      {
        'title': 'Soporte',
        'items': [
          {'icon': LucideIcons.helpCircle, 'label': 'Centro de ayuda'},
          {'icon': LucideIcons.star, 'label': 'Valorar la app'},
          {'icon': LucideIcons.logOut, 'label': 'Cerrar sesión', 'isDestructive': true},
        ],
      },
    ];

    return Column(
      children: groups.map((group) {
        final items = group['items'] as List<Map<String, dynamic>>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                group['title'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isDestructive = item['isDestructive'] == true;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDestructive
                                ? AppTheme.errorColor.withValues(alpha: 0.1)
                                : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: isDestructive
                                ? AppTheme.errorColor
                                : AppTheme.textSecondary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: isDestructive
                                ? AppTheme.errorColor
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        trailing: isDestructive
                            ? null
                            : const Icon(LucideIcons.chevronRight,
                                color: AppTheme.textSecondary, size: 18),
                        onTap: () {},
                      ),
                      if (i < items.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.black.withValues(alpha: 0.04),
                          indent: 56,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
