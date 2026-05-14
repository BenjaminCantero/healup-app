import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/checklist_item.dart';
import '../widgets/gradient_button.dart';
import '../providers/routine_provider.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Rutina de Hoy'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return ChecklistItem(
                  title: routine.title,
                  subtitle: routine.subtitle,
                  isCompleted: routine.isCompleted,
                  onTap: () {
                    ref.read(routineProvider.notifier).toggleItem(routine.id);

                    if (!routine.isCompleted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(LucideIcons.checkCircle2, color: Colors.white),
                              const SizedBox(width: 12),
                              Text('${routine.title} completado!', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 24, offset: const Offset(0, -8)),
              ],
            ),
            child: SafeArea(
              child: GradientButton(
                text: 'Finalizar Rutina',
                icon: LucideIcons.flag,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('¡Excelente trabajo! Rutina guardada.', style: TextStyle(fontWeight: FontWeight.w600)),
                      backgroundColor: AppTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.all(24),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
