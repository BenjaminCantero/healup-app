import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_model.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreen({Key? key, required this.exercise})
      : super(key: key);

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isCompleted = false;
  bool _isPlaying = false;
  int _currentStep = 0;
  late AnimationController _checkAnim;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(parent: _checkAnim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  void _markCompleted() {
    setState(() => _isCompleted = true);
    _checkAnim.forward();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final steps = ex.instructions != null && ex.instructions!.trim().isNotEmpty
        ? ex.instructions!
            .split(RegExp(r'\.\s+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => s.endsWith('.') ? s.substring(0, s.length - 1) : s)
            .toList()
        : [
            'Realiza el ejercicio controlando la respiración.',
            'Mantén la postura adecuada durante todo el movimiento.',
            'Detente inmediatamente si experimentas dolor agudo.',
          ];
    final diffColor = switch (ex.difficulty) {
      'beginner' => const Color(0xFF20A090),
      'intermediate' => const Color(0xFFFF9800),
      _ => const Color(0xFFE53935),
    };
    final emoji = switch (ex.category.toLowerCase()) {
      'fortalecimiento' || 'strength' => '💪',
      'movilidad' || 'mobility' || 'movimiento' => '🔄',
      'estiramiento' || 'flexibilidad' || 'stretch' || 'flexibility' => '🧘',
      'cardio suave' || 'cardio' => '🚶',
      'recuperación' || 'recovery' => '🧊',
      _ => '💪',
    };
    final targetZone = ex.targetBodyParts.isNotEmpty
        ? ex.targetBodyParts.map((slug) => switch (slug) {
            'left-shoulder' => 'Hombro Izquierdo',
            'right-shoulder' => 'Hombro Derecho',
            'left-knee' => 'Rodilla Izquierda',
            'right-knee' => 'Rodilla Derecha',
            'lower-back' => 'Espalda Baja',
            'neck' => 'Cuello',
            'left-ankle' => 'Tobillo Izquierdo',
            'right-ankle' => 'Tobillo Derecho',
            'left-wrist' => 'Muñeca Izquierda',
            'right-wrist' => 'Muñeca Derecha',
            'left-elbow' => 'Codo Izquierdo',
            'right-elbow' => 'Codo Derecho',
            'left-hip' => 'Cadera Izquierda',
            'right-hip' => 'Cadera Derecha',
            _ => slug,
          }).join(', ')
        : 'General';
    final tips = switch (ex.category.toLowerCase()) {
      'fortalecimiento' || 'strength' => 'Controla el movimiento en la fase de bajada. Evita usar impulsos.',
      'estiramiento' || 'flexibilidad' || 'stretch' || 'flexibility' => 'Mantén un estiramiento suave, nunca debes sentir dolor intenso.',
      'recuperación' || 'recovery' => 'Asegúrate de no aplicar frío o calor directo sobre la piel sin protección.',
      _ => 'Mantén el core activo y respira de forma controlada.',
    };

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.arrowLeft,
                    color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Category chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                ex.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Emoji + Name
                            Row(
                              children: [
                                Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    ex.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Stats row
                            Row(
                              children: [
                                _buildStatChip(
                                    LucideIcons.repeat,
                                    '${ex.defaultSets} series'),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                    LucideIcons.zap, '${ex.defaultReps} reps'),
                                const SizedBox(width: 8),
                                _buildStatChip(LucideIcons.clock,
                                    ex.durationSeconds != null ? '${(ex.durationSeconds! / 60).ceil()} min' : '5 min'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty + Target
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.gauge,
                                size: 14, color: diffColor),
                            const SizedBox(width: 6),
                            Text(
                              ex.difficultyLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: diffColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.textSecondary
                                  .withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.target,
                                size: 14,
                                color: AppTheme.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              targetZone,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Video placeholder
                  GestureDetector(
                    onTap: () => setState(() => _isPlaying = !_isPlaying),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.9),
                            const Color(0xFF007A65),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          // Grid pattern overlay
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                              ),
                              itemCount: 64,
                              itemBuilder: (_, __) => Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.05),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.95),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPlaying
                                        ? LucideIcons.pause
                                        : LucideIcons.play,
                                    color: AppTheme.primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _isPlaying
                                      ? 'Reproduciendo demostración...'
                                      : 'Ver demostración',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Description
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ex.description ?? 'Sin descripción disponible.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Steps
                  const Text(
                    'Paso a paso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...steps.asMap().entries.map((entry) {
                    final i = entry.key;
                    final step = entry.value;
                    final isActive = i == _currentStep;
                    return GestureDetector(
                      onTap: () => setState(() => _currentStep = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isActive ? AppTheme.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? AppTheme.primaryColor
                                    .withValues(alpha: 0.4)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.primaryColor
                                    : AppTheme.backgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isActive
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFFFB300)
                              .withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tips,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D4037),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: _isCompleted
            ? ScaleTransition(
                scale: _checkScale,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.checkCircle2,
                          color: AppTheme.primaryColor, size: 22),
                      SizedBox(width: 10),
                      Text(
                        '¡Ejercicio completado!',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: _markCompleted,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.checkCircle2,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Marcar como completado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
