import 'models/injury_model.dart';
import 'models/exercise_model.dart';

class SampleData {
  static final List<ExerciseModel> _kneeExercises = [
    const ExerciseModel(
      id: 'ex-1',
      title: 'Elevación de pierna recta',
      description: 'Fortalece el cuádriceps sin doblar la rodilla.',
      category: 'rehab',
      difficulty: 'beginner',
      defaultSets: 3,
      defaultReps: 15,
      targetBodyParts: ['left-knee', 'right-knee'],
    ),
    const ExerciseModel(
      id: 'ex-2',
      title: 'Deslizamiento de talón',
      description: 'Mejora la movilidad de la rodilla suavemente.',
      category: 'rehab',
      difficulty: 'beginner',
      defaultSets: 3,
      defaultReps: 10,
      targetBodyParts: ['left-knee', 'right-knee'],
    ),
  ];

  static final List<ExerciseModel> _ankleExercises = [
    const ExerciseModel(
      id: 'ex-3',
      title: 'Círculos con el tobillo',
      description: 'Mejora el rango de movimiento y circulación.',
      category: 'rehab',
      difficulty: 'beginner',
      defaultSets: 3,
      defaultReps: 20,
      targetBodyParts: ['left-ankle', 'right-ankle'],
    ),
  ];

  static final List<InjuryModel> sampleInjuries = [
    InjuryModel(
      id: 'inj-1',
      title: 'Esguince de Rodilla (LCA)',
      description: 'Lesión leve en el ligamento cruzado anterior.',
      bodyPartId: 'part-knee-left',
      bodyPartName: 'Rodilla Izquierda',
      bodyPartSlug: 'left-knee',
      severity: 'moderate',
      phase: 'subacute',
      status: 'active',
      injuryDate: DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      symptoms: [
        'Dolor al doblar la rodilla más de 90 grados',
        'Ligera inflamación al final del día',
        'Sensación de inestabilidad al bajar escaleras'
      ],
      recommendations: [
        'Mantener la pierna elevada cuando estés sentado',
        'Evitar ejercicios de impacto como correr o saltar',
        'Usar rodillera de compresión durante la actividad'
      ],
      whenToSeeSpecialist: 'Si la rodilla se bloquea repentinamente, hace un ruido fuerte (chasquido) o el dolor aumenta bruscamente.',
      importantNote: 'No te saltes los ejercicios de fortalecimiento del cuádriceps; son cruciales para la estabilidad.',
      recommendedExercises: _kneeExercises,
    ),
    InjuryModel(
      id: 'inj-2',
      title: 'Esguince de Tobillo',
      description: 'Torcedura lateral del tobillo derecho.',
      bodyPartId: 'part-ankle-right',
      bodyPartName: 'Tobillo Derecho',
      bodyPartSlug: 'right-ankle',
      severity: 'mild',
      phase: 'functional',
      status: 'recovering',
      injuryDate: DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
      symptoms: [
        'Molestia leve al girar el pie hacia adentro',
        'Pequeña rigidez matutina'
      ],
      recommendations: [
        'Comenzar ejercicios de propiocepción (equilibrio en un pie)',
        'Caminar sobre superficies irregulares con cuidado'
      ],
      whenToSeeSpecialist: 'Si el dolor vuelve a ser agudo o notas inestabilidad severa al caminar.',
      importantNote: 'Puedes comenzar a trotar suavemente si no sientes dolor al caminar rápido.',
      recommendedExercises: _ankleExercises,
    ),
  ];

  static List<InjuryModel> getInjuriesByBodyPart(String slug) {
    return sampleInjuries.where((i) => i.bodyPartSlug == slug).toList();
  }

  static InjuryModel? getInjuryById(String id) {
    try {
      return sampleInjuries.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
