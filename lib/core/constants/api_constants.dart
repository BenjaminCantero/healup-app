class ApiConstants {
  ApiConstants._();

  // ── Base URL ───────────────────────────────────────────────────────────────
  // Android Emulator: 10.0.2.2 es el alias de localhost en el host
  // Dispositivo físico: Cambia a la IP local de tu PC (ej. 192.168.1.50)
  // Producción: https://api.healup.app
  static const String _host = 'http://10.0.2.2:3000';
  static const String baseUrl = '$_host/api/v1';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = '/users/profile';
  static const String profileAvatar = '/users/profile/avatar';

  // ── Injuries ──────────────────────────────────────────────────────────────
  static const String injuries = '/injuries';
  static const String bodyParts = '/injuries/body-parts';
  static String injuryById(String id) => '/injuries/$id';
  static String injuryImage(String id) => '/injuries/$id/image';

  // ── Pain Logs ─────────────────────────────────────────────────────────────
  static const String painLogs = '/pain-logs';
  static const String painStats = '/pain-logs/stats';

  // ── Exercises ─────────────────────────────────────────────────────────────
  static const String exercises = '/exercises';
  static const String exerciseCategories = '/exercises/categories';
  static String exerciseById(String id) => '/exercises/$id';

  // ── Routines ──────────────────────────────────────────────────────────────
  static const String routines = '/routines';
  static String routineById(String id) => '/routines/$id';
  static String routineExercises(String id) => '/routines/$id/exercises';
  static String routineExercise(String id, String exId) =>
      '/routines/$id/exercises/$exId';
  static String routineReorder(String id) => '/routines/$id/exercises/reorder';

  // ── Sessions ──────────────────────────────────────────────────────────────
  static const String sessions = '/sessions';

  // ── Gamification ──────────────────────────────────────────────────────────
  static const String dashboard = '/gamification/dashboard';
  static const String achievements = '/gamification/achievements';
  static const String dailyTasks = '/gamification/daily-tasks';
  static String completeTask(String id) => '/gamification/daily-tasks/$id/complete';
}
