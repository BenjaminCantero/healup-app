import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pain_slider.dart';
import '../widgets/custom_card.dart';
import '../providers/injury_provider.dart';

class AddInjuryScreen extends ConsumerStatefulWidget {
  const AddInjuryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddInjuryScreen> createState() => _AddInjuryScreenState();
}

class _AddInjuryScreenState extends ConsumerState<AddInjuryScreen> {
  double localPainLevel = 5.0;

  void _saveInjury() async {
    await ref.read(injuriesProvider.notifier).createInjury({
      'title': 'Nueva Lesión',
      'painLevel': localPainLevel.toInt(),
      'severity': 'moderate',
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Lesión guardada!', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 80, left: 24, right: 24),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Completar Lesión'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles Principales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildFormRow('Tipo de lesión', 'Rodilla'),
                  _buildDivider(),
                  _buildFormRow('Fecha del Incidente', '13 abr 2024'),
                  _buildDivider(),
                  _buildFormRow('Severidad', 'Media', showChevron: false),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Nivel de Dolor Actual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localPainLevel.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                          letterSpacing: -2,
                        ),
                      ),
                      const Text(
                        ' / 10',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PainSlider(
                    initialValue: localPainLevel,
                    onChanged: (val) {
                      setState(() {
                        localPainLevel = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Leve', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                      Text('Intenso', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            GradientButton(
              text: 'Guardar Lesión',
              onPressed: _saveInjury,
              icon: LucideIcons.checkCircle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow(String title, String value, {bool showChevron = true}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.chevronRight, color: AppTheme.textSecondary, size: 20),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.black.withValues(alpha: 0.05),
      indent: 20,
    );
  }
}
