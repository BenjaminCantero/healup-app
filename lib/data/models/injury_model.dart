import 'exercise_model.dart';

class InjuryModel {
  final String id;
  final String title;
  final String? description;
  final String? bodyPartId;
  final String? bodyPartName;
  final String? bodyPartSlug;
  final String severity;
  final String phase;   // acute | subacute | functional
  final String status;  // active | recovering | healed
  final String injuryDate;
  final String? imageUrl;
  
  // Extra fields for detailed view
  final List<String> symptoms;
  final List<String> recommendations;
  final String? whenToSeeSpecialist;
  final String? importantNote;
  final List<ExerciseModel> recommendedExercises;

  const InjuryModel({
    required this.id,
    required this.title,
    this.description,
    this.bodyPartId,
    this.bodyPartName,
    this.bodyPartSlug,
    required this.severity,
    required this.phase,
    required this.status,
    required this.injuryDate,
    this.imageUrl,
    this.symptoms = const [],
    this.recommendations = const [],
    this.whenToSeeSpecialist,
    this.importantNote,
    this.recommendedExercises = const [],
  });

  factory InjuryModel.fromJson(Map<String, dynamic> json) => InjuryModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        bodyPartId: json['bodyPartId'] as String?,
        bodyPartName: json['bodyPartName'] as String?,
        bodyPartSlug: json['bodyPartSlug'] as String?,
        severity: json['severity'] as String? ?? 'moderate',
        phase: json['phase'] as String? ?? 'acute',
        status: json['status'] as String? ?? 'active',
        injuryDate: json['injuryDate'] as String,
        imageUrl: json['imageUrl'] as String?,
        symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        recommendations: (json['recommendations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        whenToSeeSpecialist: json['whenToSeeSpecialist'] as String?,
        importantNote: json['importantNote'] as String?,
        recommendedExercises: (json['recommendedExercises'] as List<dynamic>?)
            ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'bodyPartId': bodyPartId,
        'severity': severity,
        'phase': phase,
        'injuryDate': injuryDate,
        'symptoms': symptoms,
        'recommendations': recommendations,
        'whenToSeeSpecialist': whenToSeeSpecialist,
        'importantNote': importantNote,
      };

  /// Convenience — mapa con los mismos colores/iconos usados en MockData
  String get phaseLabel => switch (phase) {
        'acute' => 'Aguda',
        'subacute' => 'Subaguda',
        'functional' => 'Funcional',
        _ => phase,
      };

  String get statusLabel => switch (status) {
        'active' => 'En Recuperación',
        'recovering' => 'Recuperándose',
        'healed' => 'Recuperado',
        _ => status,
      };

  String get severityLabel => switch (severity) {
        'mild' => 'Leve',
        'moderate' => 'Media',
        'severe' => 'Severa',
        _ => severity,
      };
}

class BodyPartModel {
  final String id;
  final String name;
  final String slug;
  final String region;

  const BodyPartModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.region,
  });

  factory BodyPartModel.fromJson(Map<String, dynamic> json) => BodyPartModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        region: json['region'] as String,
      );
}
