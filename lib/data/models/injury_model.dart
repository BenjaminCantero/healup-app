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
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'bodyPartId': bodyPartId,
        'severity': severity,
        'phase': phase,
        'injuryDate': injuryDate,
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
