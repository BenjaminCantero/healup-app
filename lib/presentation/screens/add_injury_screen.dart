import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/pain_slider.dart';
import '../widgets/custom_card.dart';
import '../providers/injury_provider.dart';
import '../../data/models/injury_model.dart';

class AddInjuryScreen extends ConsumerStatefulWidget {
  final String? bodyPartSlug;
  final String? initialTitle;
  const AddInjuryScreen({Key? key, this.bodyPartSlug, this.initialTitle}) : super(key: key);

  @override
  ConsumerState<AddInjuryScreen> createState() => _AddInjuryScreenState();
}

class _AddInjuryScreenState extends ConsumerState<AddInjuryScreen> {
  late final TextEditingController _titleController;
  final _descriptionController = TextEditingController();
  double localPainLevel = 5.0;
  String _severity = 'moderate';
  String _phase = 'acute';
  BodyPartModel? _selectedBodyPart;
  DateTime _selectedDate = DateTime.now();

  static const Map<String, List<String>> _commonInjuries = {
    'head': ['Concusión', 'Contractura cervical'],
    'left-shoulder': ['Tendinitis', 'Luxación', 'Desgarro'],
    'right-shoulder': ['Tendinitis', 'Luxación', 'Desgarro'],
    'left-elbow': ['Epicondilitis', 'Bursitis'],
    'right-elbow': ['Epicondilitis', 'Bursitis'],
    'left-wrist': ['Esguince', 'Tendinitis', 'Túnel carpiano'],
    'right-wrist': ['Esguince', 'Tendinitis', 'Túnel carpiano'],
    'upper-back': ['Contractura', 'Hernia discal'],
    'lower-back': ['Lumbalgia', 'Hernia discal', 'Ciática'],
    'hip': ['Bursitis', 'Tendinitis', 'Fractura de estrés'],
    'left-hip': ['Bursitis', 'Tendinitis', 'Fractura de estrés'],
    'right-hip': ['Bursitis', 'Tendinitis', 'Fractura de estrés'],
    'left-knee': ['Esguince LCA', 'Esguince LCL', 'Menisco', 'Condromalacia'],
    'right-knee': ['Esguince LCA', 'Esguince LCL', 'Menisco', 'Condromalacia'],
    'left-ankle': ['Esguince Grado I', 'Esguince Grado II', 'Fractura'],
    'right-ankle': ['Esguince Grado I', 'Esguince Grado II', 'Fractura'],
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTitle ?? 'Nueva Lesión',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveInjury() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un título.')),
      );
      return;
    }

    final dto = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'severity': _severity,
      'phase': _phase,
      'painLevel': localPainLevel.toInt(),
      'injuryDate': _selectedDate.toIso8601String().split('T')[0],
      if (_selectedBodyPart != null) 'bodyPartId': _selectedBodyPart!.id,
    };

    try {
      await ref.read(injuriesProvider.notifier).createInjury(dto);
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
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar lesión: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyPartsAsync = ref.watch(bodyPartsProvider);

    bodyPartsAsync.whenData((parts) {
      if (_selectedBodyPart == null && parts.isNotEmpty) {
        if (widget.bodyPartSlug != null) {
          _selectedBodyPart = parts.firstWhere(
            (p) => p.slug == widget.bodyPartSlug,
            orElse: () => parts.first,
          );
        } else {
          _selectedBodyPart = parts.first;
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Registrar Lesión'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(context).padding.bottom + 24.0,
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la lesión',
                      hintText: 'Ej. Esguince de tobillo',
                      border: UnderlineInputBorder(),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  if (_selectedBodyPart != null) ...[
                    Builder(
                      builder: (context) {
                        final slug = _selectedBodyPart!.slug;
                        final suggestions = _commonInjuries[slug] ?? [];
                        if (suggestions.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Sugerencias comunes para esta zona:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: suggestions.map((injury) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _titleController.text = injury;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Text(
                                        injury,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción / Notas (Opcional)',
                      hintText: 'Ej. Sentí un tirón fuerte al correr.',
                      border: UnderlineInputBorder(),
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  bodyPartsAsync.when(
                    data: (parts) {
                      return DropdownButtonFormField<BodyPartModel>(
                        value: _selectedBodyPart,
                        decoration: const InputDecoration(labelText: 'Parte del Cuerpo'),
                        items: parts.map((part) {
                          return DropdownMenuItem<BodyPartModel>(
                            value: part,
                            child: Text(part.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBodyPart = val;
                          });
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar partes del cuerpo'),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha del Incidente', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    trailing: const Icon(LucideIcons.calendar),
                    onTap: () => _selectDate(context),
                  ),
                  const Divider(),
                  DropdownButtonFormField<String>(
                    value: _severity,
                    decoration: const InputDecoration(labelText: 'Severidad'),
                    items: const [
                      DropdownMenuItem(value: 'mild', child: Text('Leve')),
                      DropdownMenuItem(value: 'moderate', child: Text('Media')),
                      DropdownMenuItem(value: 'severe', child: Text('Severa')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _severity = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _phase,
                    decoration: const InputDecoration(labelText: 'Fase de Recuperación'),
                    items: const [
                      DropdownMenuItem(value: 'acute', child: Text('Aguda')),
                      DropdownMenuItem(value: 'subacute', child: Text('Subaguda')),
                      DropdownMenuItem(value: 'functional', child: Text('Funcional')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _phase = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Nivel de Dolor Inicial',
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
}
