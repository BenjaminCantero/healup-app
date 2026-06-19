import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ─── Preferences keys ─────────────────────────────────────────────────────────
const _kRemindersEnabled = 'healup_reminders_enabled';
const _kReminderHour = 'healup_reminder_hour';
const _kReminderMinute = 'healup_reminder_minute';

// ─── Notification IDs ─────────────────────────────────────────────────────────
const _kDailyReminderNotifId = 100;

/// Thin wrapper around [FlutterLocalNotificationsPlugin] that handles:
///  - Initialization (call once in main())
///  - Scheduling daily rehabilitation reminders
///  - Cancelling / toggling reminders
///  - Persisting user preferences with SharedPreferences
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    _initialized = true;

    // Re-schedule if reminders were enabled before restart
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kRemindersEnabled) ?? false;
    if (enabled) {
      final hour = prefs.getInt(_kReminderHour) ?? 9;
      final minute = prefs.getInt(_kReminderMinute) ?? 0;
      await _scheduleDailyReminder(hour: hour, minute: minute);
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kRemindersEnabled) ?? false;
  }

  Future<int> getReminderHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kReminderHour) ?? 9;
  }

  Future<int> getReminderMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kReminderMinute) ?? 0;
  }

  /// Enables the daily rehabilitation reminder at [hour]:[minute].
  Future<void> enableDailyReminder({int hour = 9, int minute = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRemindersEnabled, true);
    await prefs.setInt(_kReminderHour, hour);
    await prefs.setInt(_kReminderMinute, minute);
    await _scheduleDailyReminder(hour: hour, minute: minute);
  }

  /// Cancels all scheduled reminders and persists the disabled state.
  Future<void> disableDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRemindersEnabled, false);
    await _plugin.cancel(_kDailyReminderNotifId);
  }

  // ── Internal scheduling ───────────────────────────────────────────────────

  Future<void> _scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.cancel(_kDailyReminderNotifId);

    const androidDetails = AndroidNotificationDetails(
      'healup_daily_reminder',
      'Recordatorio diario de rehabilitación',
      channelDescription: 'Recuerda completar tus ejercicios de hoy',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _kDailyReminderNotifId,
      '¡Hora de tu rutina! 💪',
      'Recuerda completar tus ejercicios de rehabilitación hoy.',
      scheduledDate,
      const NotificationDetails(android: androidDetails, iOS: darwinDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }
}

// ─── Riverpod provider ────────────────────────────────────────────────────────

/// Async state: { enabled, hour, minute }
class NotificationPrefsState {
  final bool enabled;
  final int hour;
  final int minute;

  const NotificationPrefsState({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  NotificationPrefsState copyWith({bool? enabled, int? hour, int? minute}) =>
      NotificationPrefsState(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefsState> {
  @override
  Future<NotificationPrefsState> build() async {
    final svc = NotificationService.instance;
    return NotificationPrefsState(
      enabled: await svc.isEnabled(),
      hour: await svc.getReminderHour(),
      minute: await svc.getReminderMinute(),
    );
  }

  Future<void> toggle(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    if (enabled) {
      await NotificationService.instance.enableDailyReminder(
        hour: current.hour,
        minute: current.minute,
      );
    } else {
      await NotificationService.instance.disableDailyReminder();
    }
    state = AsyncData(current.copyWith(enabled: enabled));
  }

  Future<void> updateTime({required int hour, required int minute}) async {
    final current = state.value;
    if (current == null) return;
    if (current.enabled) {
      await NotificationService.instance.enableDailyReminder(
        hour: hour,
        minute: minute,
      );
    } else {
      // Just save the preference without scheduling
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('healup_reminder_hour', hour);
      await prefs.setInt('healup_reminder_minute', minute);
    }
    state = AsyncData(current.copyWith(hour: hour, minute: minute));
  }
}

final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefsState>(
      NotificationPrefsNotifier.new,
    );
