class ExerciseModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String difficulty; // beginner | intermediate | advanced
  final int defaultSets;
  final int defaultReps;
  final int? durationSeconds;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> targetBodyParts;
  final String? instructions;

  const ExerciseModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.difficulty,
    required this.defaultSets,
    required this.defaultReps,
    this.durationSeconds,
    this.imageUrl,
    this.videoUrl,
    required this.targetBodyParts,
    this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: json['category'] as String? ?? 'general',
        difficulty: json['difficulty'] as String? ?? 'beginner',
        defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
        defaultReps: (json['defaultReps'] as num?)?.toInt() ?? 10,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
        imageUrl: json['imageUrl'] as String?,
        videoUrl: json['videoUrl'] as String?,
        targetBodyParts: (json['targetBodyParts'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        instructions: json['instructions'] as String?,
      );

  String get difficultyLabel => switch (difficulty) {
        'beginner' => 'Fácil',
        'intermediate' => 'Moderado',
        'advanced' => 'Avanzado',
        _ => difficulty,
      };
}

class RoutineModel {
  final String id;
  final String title;
  final String? description;
  final String? injuryId;
  final int frequencyPerWeek;
  final int? durationWeeks;
  final String status; // active | paused | completed
  final List<RoutineExerciseModel> exercises;

  const RoutineModel({
    required this.id,
    required this.title,
    this.description,
    this.injuryId,
    required this.frequencyPerWeek,
    this.durationWeeks,
    required this.status,
    required this.exercises,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) => RoutineModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        injuryId: json['injuryId'] as String?,
        frequencyPerWeek: (json['frequencyPerWeek'] as num?)?.toInt() ?? 3,
        durationWeeks: (json['durationWeeks'] as num?)?.toInt(),
        status: json['status'] as String? ?? 'active',
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) =>
                    RoutineExerciseModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class RoutineExerciseModel {
  final String id;
  final String exerciseId;
  final String? exerciseTitle;
  final String? exerciseImageUrl;
  final String? exerciseDescription;
  final String? exerciseInstructions;
  final String? exerciseDifficulty;
  final int? exerciseDurationSeconds;
  final String? exerciseVideoUrl;
  final int? exerciseDefaultSets;
  final int? exerciseDefaultReps;
  final int orderIndex;
  final int? customSets;
  final int? customReps;

  const RoutineExerciseModel({
    required this.id,
    required this.exerciseId,
    this.exerciseTitle,
    this.exerciseImageUrl,
    this.exerciseDescription,
    this.exerciseInstructions,
    this.exerciseDifficulty,
    this.exerciseDurationSeconds,
    this.exerciseVideoUrl,
    this.exerciseDefaultSets,
    this.exerciseDefaultReps,
    required this.orderIndex,
    this.customSets,
    this.customReps,
  });

  factory RoutineExerciseModel.fromJson(Map<String, dynamic> json) =>
      RoutineExerciseModel(
        id: json['id'] as String,
        exerciseId: json['exerciseId'] as String,
        exerciseTitle: json['exerciseTitle'] as String?,
        exerciseImageUrl: json['exerciseImageUrl'] as String?,
        exerciseDescription: json['exerciseDescription'] as String?,
        exerciseInstructions: json['exerciseInstructions'] as String?,
        exerciseDifficulty: json['exerciseDifficulty'] as String?,
        exerciseDurationSeconds:
            (json['exerciseDurationSeconds'] as num?)?.toInt(),
        exerciseVideoUrl: json['exerciseVideoUrl'] as String?,
        exerciseDefaultSets: (json['exerciseDefaultSets'] as num?)?.toInt(),
        exerciseDefaultReps: (json['exerciseDefaultReps'] as num?)?.toInt(),
        orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
        customSets: (json['customSets'] as num?)?.toInt(),
        customReps: (json['customReps'] as num?)?.toInt(),
      );

  /// Sets a mostrar: personalizados si existen, si no los del ejercicio.
  int get effectiveSets => customSets ?? exerciseDefaultSets ?? 3;

  /// Reps a mostrar: personalizadas si existen, si no las del ejercicio.
  int get effectiveReps => customReps ?? exerciseDefaultReps ?? 12;

  String get difficultyLabel => switch (exerciseDifficulty) {
        'beginner' => 'Fácil',
        'intermediate' => 'Moderado',
        'advanced' => 'Avanzado',
        _ => 'General',
      };
}
