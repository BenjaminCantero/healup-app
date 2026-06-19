import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/notifications/notification_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/bouncing_wrapper.dart';
import '../providers/auth_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/injury_provider.dart';
import '../providers/session_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/gamification_model.dart';
import '../../data/models/injury_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value?.user;
    final dashStats = ref.watch(dashboardStatsProvider).value;
    final injuries = ref.watch(injuriesProvider).value ?? [];
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: _buildHeroHeader(context, ref, user, dashStats?.userLevel),
          ),
          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(dashStats),
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
                  _buildInjuryHistory(context, injuries),
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
                  _buildSettingsSection(context, ref),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, WidgetRef ref, UserModel? user, String? userLevel) {
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
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
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
          BouncingWrapper(
            onTap: () => _pickAndUploadAvatar(context, ref),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 3),
                    gradient: user?.profile?.avatarUrl == null
                        ? const LinearGradient(
                            colors: [Color(0xFF20A090), Color(0xFF007A65)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    image: user?.profile?.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(user!.profile!.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user?.profile?.avatarUrl == null
                      ? Center(
                          child: Text(
                            user?.fullName
                                    .split(' ')
                                    .where((e) => e.isNotEmpty)
                                    .map((e) => e[0])
                                    .take(2)
                                    .join('')
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        )
                      : null,
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
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Usuario HealUp',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'usuario@correo.com',
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
                  userLevel ?? 'Iniciante',
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

  Widget _buildStatsRow(DashboardStatsModel? stats) {
    final streak = stats?.streakDays ?? 0;
    final active = stats?.totalDaysActive ?? 0;
    final recovered = stats?.totalRecoveredInjuries ?? 0;

    final statItems = [
      {
        'icon': '🔥',
        'value': '$streak',
        'label': 'Racha',
        'unit': 'días',
      },
      {
        'icon': '📅',
        'value': '$active',
        'label': 'Días activo',
        'unit': 'total',
      },
      {
        'icon': '✅',
        'value': '$recovered',
        'label': 'Recuperadas',
        'unit': 'lesiones',
      },
    ];

    return Row(
      children: statItems
          .map(
            (s) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    right: s != statItems.last ? 10 : 0),
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

  Widget _buildInjuryHistory(BuildContext context, List<InjuryModel> injuries) {
    if (injuries.isEmpty) {
      return const Center(child: Text('No hay lesiones registradas.'));
    }
    // Use real session count for progress calculation
    final sessions = ref.watch(sessionHistoryProvider).value ?? [];
    return Column(
      children: injuries.map((injury) {
        final isRecovered = injury.status == 'healed';
        // Real progress: sessions completed / routine duration in weeks * frequency
        // Fallback to phase-based estimate if no sessions yet
        final injurySessions =
            sessions.where((s) => s.routineId != null).length;
        final double progress = isRecovered
            ? 1.0
            : injurySessions > 0
                ? (injurySessions / 18.0).clamp(0.0, 0.95)
                : (injury.phase == 'functional'
                    ? 0.8
                    : (injury.phase == 'subacute' ? 0.5 : 0.2));
        return BouncingWrapper(
          onTap: () => context.push('/injury_detail', extra: injury),
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
                  child: const Center(
                    child: Text('⚕️',
                        style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        injury.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${injury.severity.toUpperCase()}',
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
                        isRecovered ? '✓ Listo' : injury.phase.toUpperCase(),
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

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider).value == ThemeMode.dark;
    final notifEnabled =
        ref.watch(notificationPrefsProvider).value?.enabled ?? false;

    final groups = [
      {
        'title': 'Cuenta',
        'items': [
          {'icon': LucideIcons.user, 'label': 'Información personal'},
          {
            'icon': LucideIcons.bell,
            'label': 'Notificaciones',
            'toggle': notifEnabled,
            'onToggle': (bool val) async {
              if (val) {
                await NotificationService.instance
                    .enableDailyReminder(hour: 9);
              } else {
                await NotificationService.instance.disableDailyReminder();
              }
              ref.invalidate(notificationPrefsProvider);
            },
          },
          {'icon': LucideIcons.shield, 'label': 'Privacidad y Seguridad'},
        ],
      },
      {
        'title': 'Preferencias',
        'items': [
          {
            'icon': LucideIcons.moon,
            'label': 'Modo Oscuro',
            'toggle': isDark,
            'onToggle': (bool _) {
              ref.read(themeModeProvider.notifier).toggle();
            },
          },
          {'icon': LucideIcons.globe, 'label': 'Idioma'},
          {
            'icon': LucideIcons.history,
            'label': 'Historial de sesiones',
          },
        ],
      },
      {
        'title': 'Soporte',
        'items': [
          {'icon': LucideIcons.helpCircle, 'label': 'Centro de ayuda'},
          {'icon': LucideIcons.star, 'label': 'Valorar la app'},
          {
            'icon': LucideIcons.logOut,
            'label': 'Cerrar sesión',
            'isDestructive': true,
          },
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
                        trailing: item['toggle'] != null
                            ? Switch(
                                value: item['toggle'] as bool,
                                onChanged: item['onToggle'] as Function(bool)?,
                                activeColor: AppTheme.primaryColor,
                              )
                            : isDestructive
                                ? null
                                : const Icon(LucideIcons.chevronRight,
                                    color: AppTheme.textSecondary, size: 18),
                        onTap: () {
                          if (isDestructive) {
                            ref.read(authProvider.notifier).logout();
                            context.go('/login');
                          } else if (item['label'] == 'Información personal') {
                            final user = ref.read(authProvider).value?.user;
                            if (user != null) {
                              _showEditProfileSheet(context, user);
                            }
                          } else if (item['label'] == 'Historial de sesiones') {
                            context.push('/session_history');
                          } else if (item['label'] == 'Valorar la app') {
                            launchUrl(
                              Uri.parse('https://play.google.com/store/apps'),
                              mode: LaunchMode.externalApplication,
                            );
                          } else if (item['label'] == 'Centro de ayuda') {
                            launchUrl(
                              Uri.parse('mailto:soporte@healup.app'),
                              mode: LaunchMode.externalApplication,
                            );
                          } else if (item['toggle'] != null) {
                            // Toggle-type items are handled by the Switch widget
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['label']} - Próximamente disponible'),
                                backgroundColor: AppTheme.primaryColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
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

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Subiendo nueva foto de perfil...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await ref.read(authProvider.notifier).updateAvatar(image.path);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Foto de perfil actualizada!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir avatar: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showEditProfileSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(user: user),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;
  const _EditProfileSheet({required this.user});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String _gender = 'prefer_not_to_say';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _heightController = TextEditingController(text: widget.user.profile?.heightCm?.toString() ?? '');
    _weightController = TextEditingController(text: widget.user.profile?.weightKg?.toString() ?? '');
    if (widget.user.profile?.gender != null) {
      _gender = widget.user.profile!.gender!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> data = {
        'fullName': _nameController.text.trim(),
        'gender': _gender,
      };
      if (_heightController.text.isNotEmpty) {
        data['heightCm'] = double.tryParse(_heightController.text) ?? 0;
      }
      if (_weightController.text.isNotEmpty) {
        data['weightKg'] = double.tryParse(_weightController.text) ?? 0;
      }
      
      await ref.read(authProvider.notifier).updateProfile(data);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil actualizado con éxito!'), backgroundColor: AppTheme.primaryColor),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField('Nombre Completo', _nameController, LucideIcons.user),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Altura (cm)', _heightController, LucideIcons.ruler, isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Peso (kg)', _weightController, LucideIcons.scale, isNumber: true)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Género', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _gender,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Masculino')),
                  DropdownMenuItem(value: 'female', child: Text('Femenino')),
                  DropdownMenuItem(value: 'other', child: Text('Otro')),
                  DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefiero no decirlo')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _gender = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
