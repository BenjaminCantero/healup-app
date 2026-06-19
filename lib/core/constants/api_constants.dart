import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConstants {
  ApiConstants._();

  // ── Base URL ───────────────────────────────────────────────────────────────
  /// Use `--dart-define=API_URL=https://your-server.com` when building
  /// for production. In development, falls back to localhost or the
  /// Android emulator/device address automatically.
  static const String _envApiUrl = String.fromEnvironment('API_URL', defaultValue: '');

  static String get _host {
    if (_envApiUrl.isNotEmpty) return _envApiUrl;
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // Android emulator
    return 'http://localhost:3000';
  }

  static String get baseUrl => '$_host/api/v1';
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
  static String routineByInjury(String injuryId) => '/routines/by-injury/$injuryId';
  static String routineGenerate(String injuryId) =>
      '/routines/by-injury/$injuryId/generate';
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
