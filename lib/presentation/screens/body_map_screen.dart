import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/mock_data.dart';
import '../widgets/bouncing_wrapper.dart';
import '../providers/injury_provider.dart';
import '../../data/models/injury_model.dart';

class BodyMapScreen extends ConsumerStatefulWidget {
  const BodyMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends ConsumerState<BodyMapScreen> {
  String? _selectedPart;
  bool _showFront = true;

  void _selectPart(String partId, String partName, List<String> injuries) {
    setState(() => _selectedPart = partId);
    _showBottomSheet(partName, injuries);
  }

  void _showBottomSheet(String partName, List<String> commonInjuries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.mapPin,
                      color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Lesiones frecuentes',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...commonInjuries.map(
              (injury) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.circle,
                        size: 8, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      injury,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                final slug = _getSlugForUiId(_selectedPart!);
                context.push('/add_injury?slug=$slug');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.plus, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Registrar lesión aquí',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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

  @override
  Widget build(BuildContext context) {
    final injuriesState = ref.watch(injuriesProvider);
    final activeInjuries = injuriesState.value?.where((i) => i.status != 'healed').toList() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mapa Corporal'),
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
      body: Column(
        children: [
          // Front / Back toggle
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildToggle('Frontal', _showFront,
                      () => setState(() => _showFront = true)),
                  _buildToggle('Posterior', !_showFront,
                      () => setState(() => _showFront = false)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca la zona donde sientes dolor',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Body diagram
          Expanded(
            child: _buildBodyDiagram(activeInjuries),
          ),
          // Active injuries at bottom
          _buildActiveInjuriesBar(activeInjuries),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyDiagram(List<InjuryModel> activeInjuries) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _showFront ? _buildFrontBody(activeInjuries) : _buildBackBody(activeInjuries),
      ),
    );
  }

  Widget _buildFrontBody(List<InjuryModel> activeInjuries) {
    final parts = MockData.bodyParts;
    return Column(
      children: [
        // Head
        _buildBodyZone('head', '🧠', 'Cabeza',
            parts.firstWhere((p) => p['id'] == 'head')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        // Shoulders
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBodyZone(
                'shoulder_left',
                '💪',
                'Hombro Izq.',
                parts.firstWhere(
                    (p) => p['id'] == 'shoulder_left')['commonInjuries'], activeInjuries),
            _buildBodyZone(
                'shoulder_right',
                '💪',
                'Hombro Der.',
                parts.firstWhere(
                    (p) => p['id'] == 'shoulder_right')['commonInjuries'], activeInjuries),
          ],
        ),
        const SizedBox(height: 8),
        // Elbows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBodyZone(
                'elbow_left',
                '🦾',
                'Codo Izq.',
                parts.firstWhere(
                    (p) => p['id'] == 'elbow_left')['commonInjuries'], activeInjuries),
            _buildBodyZone(
                'elbow_right',
                '🦾',
                'Codo Der.',
                parts.firstWhere(
                    (p) => p['id'] == 'elbow_right')['commonInjuries'], activeInjuries),
          ],
        ),
        const SizedBox(height: 8),
        // Back
        _buildBodyZone('back_upper', '🔙', 'Espalda Alta',
            parts.firstWhere((p) => p['id'] == 'back_upper')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        _buildBodyZone('back_lower', '🔙', 'Espalda Baja',
            parts.firstWhere((p) => p['id'] == 'back_lower')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        // Hip
        _buildBodyZone('hip', '🍑', 'Cadera',
            parts.firstWhere((p) => p['id'] == 'hip')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        // Knees
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBodyZone(
                'knee_left',
                '🦵',
                'Rodilla Izq.',
                parts.firstWhere(
                    (p) => p['id'] == 'knee_left')['commonInjuries'], activeInjuries),
            _buildBodyZone(
                'knee_right',
                '🦵',
                'Rodilla Der.',
                parts.firstWhere(
                    (p) => p['id'] == 'knee_right')['commonInjuries'], activeInjuries),
          ],
        ),
        const SizedBox(height: 8),
        // Ankles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBodyZone(
                'ankle_left',
                '🦶',
                'Tobillo Izq.',
                parts.firstWhere(
                    (p) => p['id'] == 'ankle_left')['commonInjuries'], activeInjuries),
            _buildBodyZone(
                'ankle_right',
                '🦶',
                'Tobillo Der.',
                parts.firstWhere(
                    (p) => p['id'] == 'ankle_right')['commonInjuries'], activeInjuries),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBackBody(List<InjuryModel> activeInjuries) {
    final parts = MockData.bodyParts;
    return Column(
      children: [
        _buildBodyZone('head', '🧠', 'Cabeza',
            parts.firstWhere((p) => p['id'] == 'head')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBodyZone(
                'shoulder_left',
                '💪',
                'Hombro Izq.',
                parts.firstWhere(
                    (p) => p['id'] == 'shoulder_left')['commonInjuries'], activeInjuries),
            _buildBodyZone(
                'shoulder_right',
                '💪',
                'Hombro Der.',
                parts.firstWhere(
                    (p) => p['id'] == 'shoulder_right')['commonInjuries'], activeInjuries),
          ],
        ),
        const SizedBox(height: 8),
        _buildBodyZone('back_upper', '🔙', 'Espalda Alta',
            parts.firstWhere((p) => p['id'] == 'back_upper')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        _buildBodyZone('back_lower', '🔙', 'Espalda Baja',
            parts.firstWhere((p) => p['id'] == 'back_lower')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        _buildBodyZone('hip', '🍑', 'Cadera',
            parts.firstWhere((p) => p['id'] == 'hip')['commonInjuries'], activeInjuries),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBodyZone(
                'knee_left',
                '🦵',
                'Rodilla Izq.',
                parts.firstWhere(
                    (p) => p['id'] == 'knee_left')['commonInjuries'], activeInjuries),
            _buildBodyZone(
                'knee_right',
                '🦵',
                'Rodilla Der.',
                parts.firstWhere(
                    (p) => p['id'] == 'knee_right')['commonInjuries'], activeInjuries),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBodyZone(
                'ankle_left',
                '🦶',
                'Tobillo Izq.',
                parts.firstWhere(
                    (p) => p['id'] == 'ankle_left')['commonInjuries'], activeInjuries),
            _buildBodyZone(
                'ankle_right',
                '🦶',
                'Tobillo Der.',
                parts.firstWhere(
                    (p) => p['id'] == 'ankle_right')['commonInjuries'], activeInjuries),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getSlugForUiId(String id) {
    switch (id) {
      case 'shoulder_left': return 'left-shoulder';
      case 'shoulder_right': return 'right-shoulder';
      case 'elbow_left': return 'left-elbow';
      case 'elbow_right': return 'right-elbow';
      case 'knee_left': return 'left-knee';
      case 'knee_right': return 'right-knee';
      case 'ankle_left': return 'left-ankle';
      case 'ankle_right': return 'right-ankle';
      case 'back_upper': return 'upper-back';
      case 'back_lower': return 'lower-back';
      default: return id;
    }
  }

  Widget _buildBodyZone(
    String id,
    String emoji,
    String name,
    List<dynamic> injuries,
    List<InjuryModel> activeInjuries,
  ) {
    final slug = _getSlugForUiId(id);
    final hasInjury = activeInjuries.any((injury) => 
        injury.bodyPartSlug == slug || (id == 'hip' && (injury.bodyPartSlug == 'left-hip' || injury.bodyPartSlug == 'right-hip'))
    );
    final isSelected = _selectedPart == id;
    return BouncingWrapper(
      onTap: () =>
          _selectPart(id, name, injuries.map((e) => e.toString()).toList()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight
              : hasInjury
                  ? const Color(0xFFFFF3E0)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : hasInjury
                    ? const Color(0xFFFF9800)
                    : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppTheme.primaryColor
                    : hasInjury
                        ? const Color(0xFFE65100)
                        : AppTheme.textPrimary,
              ),
            ),
            if (hasInjury) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveInjuriesBar(List<InjuryModel> activeInjuries) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lesiones activas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activeInjuries.length}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activeInjuries.isEmpty)
            const Text('Sin lesiones activas.', style: TextStyle(color: Colors.grey))
          else
            Row(
              children: activeInjuries.map((injury) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚕️',
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          injury.title.split(' ').take(2).join(' '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
