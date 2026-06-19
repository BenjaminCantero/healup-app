import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../providers/exercise_provider.dart';
import '../../data/models/exercise_model.dart';

class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState
    extends ConsumerState<ExerciseCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(exerciseCatalogFilterProvider);
    final exercisesAsync = ref.watch(exerciseCatalogProvider);
    final categoriesAsync = ref.watch(exerciseCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Catálogo de Ejercicios'),
        actions: [
          if (filter.categoryId != null ||
              filter.difficulty != null ||
              filter.search.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                ref.read(exerciseCatalogFilterProvider.notifier).reset();
              },
              child: const Text(
                'Limpiar',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => ref
                  .read(exerciseCatalogFilterProvider.notifier)
                  .setSearch(q),
              decoration: InputDecoration(
                hintText: 'Buscar ejercicio...',
                hintStyle:
                    const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(LucideIcons.search,
                    color: AppTheme.textSecondary, size: 18),
                suffixIcon: filter.search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(exerciseCatalogFilterProvider
                                  .notifier)
                              .setSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),

          // Difficulty chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: ['beginner', 'intermediate', 'advanced']
                  .map((d) {
                final label = switch (d) {
                  'beginner' => 'Fácil',
                  'intermediate' => 'Moderado',
                  _ => 'Avanzado',
                };
                final selected = filter.difficulty == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color:
                          selected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(
                      color: selected
                          ? AppTheme.primaryColor
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                    onSelected: (val) {
                      ref
                          .read(exerciseCatalogFilterProvider.notifier)
                          .setDifficulty(val ? d : null);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Category chips
          categoriesAsync.when(
            data: (cats) => SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                itemCount: cats.length,
                itemBuilder: (context, i) {
                  final cat = cats[i];
                  final selected = filter.categoryId == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: selected,
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(
                        color: selected
                            ? AppTheme.primaryColor
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                      onSelected: (val) {
                        ref
                            .read(exerciseCatalogFilterProvider
                                .notifier)
                            .setCategory(val ? cat.id : null);
                      },
                    ),
                  );
                },
              ),
            ),
            loading: () => const SizedBox(height: 44),
            error: (_, __) => const SizedBox(height: 44),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.dumbbell,
                              color: AppTheme.primaryColor, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sin ejercicios encontrados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prueba con otros filtros',
                          style:
                              TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return _ExerciseCard(
                      exercise: exercises[index],
                      onTap: () => context.push(
                        '/exercise_detail',
                        extra: exercises[index],
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 6,
                itemBuilder: (_, __) => _ExerciseCardSkeleton(),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.wifiOff,
                        color: AppTheme.textSecondary, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar ejercicios',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(exerciseCatalogProvider),
                      child: const Text('Reintentar',
                          style:
                              TextStyle(color: AppTheme.primaryColor)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const _ExerciseCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final difficultyColor = switch (exercise.difficulty) {
      'beginner' => const Color(0xFF20A090),
      'intermediate' => const Color(0xFFFF9800),
      _ => const Color(0xFFE53935),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Thumbnail or placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
                image: exercise.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(exercise.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: exercise.imageUrl == null
                  ? const Icon(LucideIcons.dumbbell,
                      color: AppTheme.primaryColor, size: 28)
                  : null,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.description ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          exercise.difficultyLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${exercise.defaultSets} series · ${exercise.defaultReps} reps',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(LucideIcons.chevronRight,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCardSkeleton extends StatelessWidget {
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
            width: 64,
            height: 64,
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
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(7),
                    )),
                const SizedBox(height: 8),
                Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(6),
                    )),
                const SizedBox(height: 8),
                Container(
                    height: 20,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
