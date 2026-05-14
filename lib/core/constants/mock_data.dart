class MockData {
  static const String userName = 'Alejandro';
  static const String userEmail = 'alejandro@healup.app';
  static const String userAvatar = 'https://i.pravatar.cc/150?img=11';
  static const int streakDays = 12;
  static const int totalRecoveredInjuries = 3;
  static const int totalDaysActive = 47;
  static const String userLevel = 'Guerrero de Recuperación';

  // ─── Injuries ─────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> injuries = [
    {
      'id': '1',
      'name': 'Rodilla Izquierda',
      'type': 'Esguince LCL',
      'bodyPart': 'knee_left',
      'status': 'En Recuperación',
      'severity': 'Media',
      'painLevel': 2.0,
      'dateLogged': '13 abr 2025',
      'days': 12,
      'totalDays': 21,
      'progress': 0.57,
      'phase': 'Subaguda',
      'icon': '🦵',
      'color': 0xFF20A090,
    },
    {
      'id': '2',
      'name': 'Hombro Derecho',
      'type': 'Tendinitis Rotador',
      'bodyPart': 'shoulder_right',
      'status': 'Leve',
      'severity': 'Leve',
      'painLevel': 1.5,
      'dateLogged': '28 mar 2025',
      'days': 28,
      'totalDays': 30,
      'progress': 0.93,
      'phase': 'Funcional',
      'icon': '💪',
      'color': 0xFF2EC4B6,
    },
    {
      'id': '3',
      'name': 'Tobillo Izquierdo',
      'type': 'Esguince Grado I',
      'bodyPart': 'ankle_left',
      'status': 'Recuperado',
      'severity': 'Leve',
      'painLevel': 0.0,
      'dateLogged': '10 ene 2025',
      'days': 14,
      'totalDays': 14,
      'progress': 1.0,
      'phase': 'Completado',
      'icon': '🦶',
      'color': 0xFF007A65,
    },
  ];

  // ─── Exercises ─────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> exercises = [
    {
      'id': 'e1',
      'name': 'Extensiones de Rodilla',
      'category': 'Fortalecimiento',
      'sets': 3,
      'reps': '12 reps',
      'duration': '5 min',
      'difficulty': 'Fácil',
      'difficultyColor': 0xFF20A090,
      'targetZone': 'Cuádriceps',
      'description':
          'Siéntate en el borde de una silla con los pies apoyados en el suelo. Extiende lentamente una pierna hasta quedar paralela al suelo. Mantén 2 segundos y baja con control.',
      'steps': [
        'Siéntate en el borde de una silla firme',
        'Pies ligeramente separados al ancho de cadera',
        'Extiende la rodilla derecha lentamente',
        'Mantén la posición 2 segundos',
        'Baja con control en 3 segundos',
        'Repite con la pierna izquierda',
      ],
      'tips': 'Evita bloquear la rodilla al extender. Mantén el core activo.',
      'emoji': '🦵',
    },
    {
      'id': 'e2',
      'name': 'Estiramiento de Cuádriceps',
      'category': 'Flexibilidad',
      'sets': 2,
      'reps': '30 seg',
      'duration': '2 min',
      'difficulty': 'Fácil',
      'difficultyColor': 0xFF20A090,
      'targetZone': 'Cuádriceps / Rodilla',
      'description':
          'De pie, dobla la rodilla afectada llevando el talón hacia los glúteos. Sostén el tobillo con la mano y mantén la posición.',
      'steps': [
        'Párate cerca de una pared para apoyo',
        'Dobla la rodilla llevando el talón atrás',
        'Agarra el tobillo con tu mano',
        'Mantén las rodillas juntas',
        'Sostén el estiramiento 30 segundos',
        'Suelta lentamente y repite',
      ],
      'tips':
          'No arquees la espalda. Si sientes dolor agudo, detente inmediatamente.',
      'emoji': '🧘',
    },
    {
      'id': 'e3',
      'name': 'Caminata Terapéutica',
      'category': 'Cardio Suave',
      'sets': 1,
      'reps': '15 min',
      'duration': '15 min',
      'difficulty': 'Fácil',
      'difficultyColor': 0xFF20A090,
      'targetZone': 'Todo el cuerpo',
      'description':
          'Caminata a paso moderado para mejorar la circulación y mantener la movilidad articular. Ideal en fase de recuperación subaguda.',
      'steps': [
        'Usa calzado cómodo y soporte adecuado',
        'Inicia con 5 minutos de paso muy lento',
        'Aumenta gradualmente el ritmo',
        'Mantén postura erguida',
        'Finaliza con 5 minutos de paso suave',
      ],
      'tips': 'Evita superficies irregulares. Camina en terreno plano.',
      'emoji': '🚶',
    },
    {
      'id': 'e4',
      'name': 'Elevaciones de Talón',
      'category': 'Fortalecimiento',
      'sets': 3,
      'reps': '15 reps',
      'duration': '4 min',
      'difficulty': 'Moderado',
      'difficultyColor': 0xFFFF6B35,
      'targetZone': 'Gemelos / Tobillo',
      'description':
          'Ejercicio isométrico para fortalecer el complejo gemelo-sóleo y mejorar la estabilidad del tobillo.',
      'steps': [
        'Párate con los pies al ancho de caderas',
        'Apoya las manos en una pared o silla',
        'Sube lentamente sobre las puntas de los pies',
        'Mantén la cima 1 segundo',
        'Baja lentamente en 3 segundos',
        'No dejes caer el talón bruscamente',
      ],
      'tips': 'Mantén los tobillos alineados. No abras ni cierres los pies.',
      'emoji': '👟',
    },
    {
      'id': 'e5',
      'name': 'Aplicar Hielo',
      'category': 'Recuperación',
      'sets': 1,
      'reps': '20 min',
      'duration': '20 min',
      'difficulty': 'Fácil',
      'difficultyColor': 0xFF2EC4B6,
      'targetZone': 'Zona afectada',
      'description':
          'Crioterapia para reducir inflamación y aliviar el dolor. Siempre usa una tela entre el hielo y la piel.',
      'steps': [
        'Prepara bolsa de hielo o gel frío',
        'Envuelve en una tela fina o toalla',
        'Aplica sobre la zona afectada',
        'Mantén 20 minutos como máximo',
        'Retira y deja reposar 40 minutos',
        'Puedes repetir hasta 4 veces al día',
      ],
      'tips':
          'Nunca apliques hielo directo sobre la piel. Puede causar quemaduras.',
      'emoji': '🧊',
    },
    {
      'id': 'e6',
      'name': 'Rotaciones de Hombro',
      'category': 'Movilidad',
      'sets': 2,
      'reps': '10 reps cada lado',
      'duration': '3 min',
      'difficulty': 'Fácil',
      'difficultyColor': 0xFF20A090,
      'targetZone': 'Hombro / Manguito rotador',
      'description':
          'Movimientos pendulares y de rotación para mantener la movilidad del hombro y reducir la rigidez articular.',
      'steps': [
        'Párate con los pies separados',
        'Inclina ligeramente el torso hacia adelante',
        'Deja el brazo afectado colgar libre',
        'Haz círculos pequeños en sentido horario',
        'Cambia a círculos en sentido antihorario',
        'Aumenta gradualmente el rango',
      ],
      'tips': 'Los movimientos deben ser suaves y controlados. Sin fuerza.',
      'emoji': '🔄',
    },
    {
      'id': 'e7',
      'name': 'Banda Elástica — Abducción',
      'category': 'Fortalecimiento',
      'sets': 3,
      'reps': '12 reps',
      'duration': '6 min',
      'difficulty': 'Moderado',
      'difficultyColor': 0xFFFF6B35,
      'targetZone': 'Glúteo Medio / Cadera',
      'description':
          'Fortalecimiento del glúteo medio con banda elástica para estabilizar la rodilla y cadera.',
      'steps': [
        'Coloca la banda elástica sobre los tobillos',
        'Párate con pies al ancho de caderas',
        'Mantén ligera flexión de rodillas',
        'Separa lateralmente la pierna derecha',
        'Regresa con control sin juntar los pies',
        'Completa series y cambia de pierna',
      ],
      'tips': 'Mantén el tronco estable. No dejes que la cadera se incline.',
      'emoji': '💪',
    },
  ];

  // ─── Daily Routines ────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> dailyTracking = [
    {'title': 'Estiramientos', 'status': 'Completa', 'isCompleted': true},
    {'title': 'Aplicar hielo', 'status': 'Parcial', 'isCompleted': true},
    {'title': 'Medicamentos', 'status': 'Completado', 'isCompleted': true},
    {'title': 'Caminata', 'status': '', 'isCompleted': false},
  ];

  // ─── Pain History ─────────────────────────────────────────────────────────
  static final List<double> weeklyPainData = [5.0, 4.5, 4.0, 3.5, 3.0, 2.5, 2.0];
  static final List<double> weeklyRecoveryLine = [2.0, 3.0, 3.5, 5.0, 6.0, 7.0, 8.0];

  static final List<Map<String, dynamic>> painLogHistory = [
    {'date': 'Lun 6', 'pain': 5.0, 'note': 'Mucho dolor al caminar'},
    {'date': 'Mar 7', 'pain': 4.5, 'note': 'Un poco mejor'},
    {'date': 'Mié 8', 'pain': 4.0, 'note': 'El hielo ayudó bastante'},
    {'date': 'Jue 9', 'pain': 3.5, 'note': 'Pude bajar escaleras'},
    {'date': 'Vie 10', 'pain': 3.0, 'note': 'Caminaré 10 minutos'},
    {'date': 'Sáb 11', 'pain': 2.5, 'note': 'Progresando bien'},
    {'date': 'Dom 12', 'pain': 2.0, 'note': 'Casi sin dolor en reposo'},
  ];

  // ─── Achievements ─────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> achievements = [
    {
      'id': 'a1',
      'title': 'Racha 7 Días',
      'description': 'Completaste ejercicios 7 días seguidos',
      'icon': '🔥',
      'isUnlocked': true,
      'progress': 1.0,
      'unlockedDate': 'Hace 5 días',
      'rarity': 'Común',
      'rarityColor': 0xFF20A090,
    },
    {
      'id': 'a2',
      'title': 'Racha 14 Días',
      'description': 'Mantén la racha por 2 semanas',
      'icon': '⚡',
      'isUnlocked': false,
      'progress': 0.86,
      'unlockedDate': null,
      'rarity': 'Raro',
      'rarityColor': 0xFF2196F3,
    },
    {
      'id': 'a3',
      'title': 'Sin Dolor',
      'description': 'Registra dolor nivel 1 o menos',
      'icon': '✨',
      'isUnlocked': false,
      'progress': 0.6,
      'unlockedDate': null,
      'rarity': 'Épico',
      'rarityColor': 0xFF9C27B0,
    },
    {
      'id': 'a4',
      'title': 'Primera Lesión',
      'description': 'Registraste tu primera lesión',
      'icon': '📋',
      'isUnlocked': true,
      'progress': 1.0,
      'unlockedDate': 'Hace 12 días',
      'rarity': 'Común',
      'rarityColor': 0xFF20A090,
    },
    {
      'id': 'a5',
      'title': 'Guerrero de Hielo',
      'description': 'Aplicaste crioterapia 10 días seguidos',
      'icon': '🧊',
      'isUnlocked': true,
      'progress': 1.0,
      'unlockedDate': 'Hace 2 días',
      'rarity': 'Raro',
      'rarityColor': 0xFF2196F3,
    },
    {
      'id': 'a6',
      'title': 'Recuperado',
      'description': 'Completa el 100% de una recuperación',
      'icon': '🏆',
      'isUnlocked': false,
      'progress': 0.57,
      'unlockedDate': null,
      'rarity': 'Legendario',
      'rarityColor': 0xFFFF9800,
    },
    {
      'id': 'a7',
      'title': 'Constancia',
      'description': 'Completa 20 ejercicios en total',
      'icon': '🎯',
      'isUnlocked': true,
      'progress': 1.0,
      'unlockedDate': 'Ayer',
      'rarity': 'Común',
      'rarityColor': 0xFF20A090,
    },
    {
      'id': 'a8',
      'title': 'Maratón de Hielo',
      'description': 'Aplica hielo 30 veces en total',
      'icon': '❄️',
      'isUnlocked': false,
      'progress': 0.37,
      'unlockedDate': null,
      'rarity': 'Raro',
      'rarityColor': 0xFF2196F3,
    },
  ];

  // ─── Body Parts ───────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> bodyParts = [
    {'id': 'head', 'name': 'Cabeza', 'commonInjuries': ['Concusión', 'Contractura cervical']},
    {'id': 'shoulder_left', 'name': 'Hombro Izquierdo', 'commonInjuries': ['Tendinitis', 'Luxación', 'Desgarro']},
    {'id': 'shoulder_right', 'name': 'Hombro Derecho', 'commonInjuries': ['Tendinitis', 'Luxación', 'Desgarro']},
    {'id': 'elbow_left', 'name': 'Codo Izquierdo', 'commonInjuries': ['Epicondilitis', 'Bursitis']},
    {'id': 'elbow_right', 'name': 'Codo Derecho', 'commonInjuries': ['Epicondilitis', 'Bursitis']},
    {'id': 'wrist', 'name': 'Muñeca', 'commonInjuries': ['Esguince', 'Tendinitis', 'Túnel carpiano']},
    {'id': 'back_upper', 'name': 'Espalda Alta', 'commonInjuries': ['Contractura', 'Hernia discal']},
    {'id': 'back_lower', 'name': 'Espalda Baja', 'commonInjuries': ['Lumbalgia', 'Hernia discal', 'Ciática']},
    {'id': 'hip', 'name': 'Cadera', 'commonInjuries': ['Bursitis', 'Tendinitis', 'Fractura de estrés']},
    {'id': 'knee_left', 'name': 'Rodilla Izquierda', 'commonInjuries': ['Esguince LCA', 'Esguince LCL', 'Menisco', 'Condromalacia']},
    {'id': 'knee_right', 'name': 'Rodilla Derecha', 'commonInjuries': ['Esguince LCA', 'Esguince LCL', 'Menisco', 'Condromalacia']},
    {'id': 'ankle_left', 'name': 'Tobillo Izquierdo', 'commonInjuries': ['Esguince Grado I', 'Esguince Grado II', 'Fractura']},
    {'id': 'ankle_right', 'name': 'Tobillo Derecho', 'commonInjuries': ['Esguince Grado I', 'Esguince Grado II', 'Fractura']},
  ];

  // ─── Coach Tips ───────────────────────────────────────────────────────────
  static const List<Map<String, String>> coachTips = [
    {
      'title': '¡Buen ritmo!',
      'message': 'Llevas 12 días consecutivos. El descanso también es parte de la recuperación — mañana asegúrate de dormir 8 horas.',
      'icon': '🧠',
    },
    {
      'title': 'Hidratación clave',
      'message': 'Beber al menos 2L de agua hoy acelera la recuperación de tejidos. ¿Ya bebiste suficiente?',
      'icon': '💧',
    },
    {
      'title': 'Reducción notable',
      'message': 'Tu nivel de dolor bajó de 5.0 a 2.0 en una semana. ¡Sigue así con constancia!',
      'icon': '📉',
    },
  ];

  // ─── Recovery Phases ─────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> recoveryPhases = [
    {
      'phase': 'Aguda',
      'days': '1-3 días',
      'description': 'Reposo, hielo y control de inflamación',
      'isCompleted': true,
      'icon': '🚨',
    },
    {
      'phase': 'Subaguda',
      'days': '4-21 días',
      'description': 'Movilidad gradual y ejercicios suaves',
      'isCompleted': false,
      'isCurrent': true,
      'icon': '🔄',
    },
    {
      'phase': 'Funcional',
      'days': '21+ días',
      'description': 'Fortalecimiento progresivo y retorno al deporte',
      'isCompleted': false,
      'icon': '🏃',
    },
  ];
}
