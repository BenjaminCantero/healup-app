import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoutineItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;

  RoutineItem({required this.id, required this.title, required this.subtitle, this.isCompleted = false});

  RoutineItem copyWith({bool? isCompleted}) {
    return RoutineItem(
      id: id,
      title: title,
      subtitle: subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class RoutineNotifier extends Notifier<List<RoutineItem>> {
  @override
  List<RoutineItem> build() {
    return [
      RoutineItem(id: 'r1', title: 'Extensiones de rodilla', subtitle: '3 sets de 12 • Fácil', isCompleted: false),
      RoutineItem(id: 'r2', title: 'Estiramiento', subtitle: '2 sets de 30s • Fácil', isCompleted: false),
      RoutineItem(id: 'r3', title: 'Aplicar hielo', subtitle: '20 mins • Recuperación', isCompleted: false),
      RoutineItem(id: 'r4', title: 'Caminata suave', subtitle: '15 mins • Fácil', isCompleted: false),
    ];
  }

  void toggleItem(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
  }

  double get progress {
    if (state.isEmpty) return 0.0;
    final completed = state.where((item) => item.isCompleted).length;
    return completed / state.length;
  }

  int get completedCount => state.where((item) => item.isCompleted).length;
}

final routineProvider = NotifierProvider<RoutineNotifier, List<RoutineItem>>(() {
  return RoutineNotifier();
});

final routineProgressProvider = Provider<double>((ref) {
  return ref.watch(routineProvider.notifier).progress;
});

final routineCompletedCountProvider = Provider<int>((ref) {
  return ref.watch(routineProvider.notifier).completedCount;
});
