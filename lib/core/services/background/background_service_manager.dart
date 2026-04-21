import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/db/app_database.dart';
import 'package:unperch/core/enums/enums.dart';
import 'package:unperch/core/models/reminder_event.dart';
import 'package:unperch/core/services/notification/notification_service.dart';
import 'package:unperch/core/services/reminder_scheduler.dart';
import 'package:unperch/core/services/tts/tts_service.dart';

// ---------------------------------------------------------------------------
// Background entry-point (top-level function — required by flutter_background_service)
// ---------------------------------------------------------------------------

/// Top-level entry point called by [flutter_background_service] when the
/// service starts.  Must be annotated with `@pragma('vm:entry-point')` so
/// the Dart tree-shaker does not remove it.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // ---- Initialise dependencies in the background isolate ----
  final prefs = await SharedPreferences.getInstance();
  final store = UnperchDataStore(prefs);
  final db = AppDatabase();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final ttsService = await TtsService.create(store);

  final scheduler = ReminderScheduler(
    dataStore: store,
    reminderDao: db.reminderDao,
    skipDao: db.skipDao,
    shiftDao: db.shiftDao,
  );

  // Track the last midnight we used to pre-populate tomorrow's schedule.
  DateTime? lastScheduledDate;

  // ---- Periodic tick ----
  Timer.periodic(const Duration(seconds: 60), (_) async {
    final now = DateTime.now();

    // Pre-populate tomorrow's schedule at midnight.
    final today = DateTime(now.year, now.month, now.day);
    if (lastScheduledDate == null || lastScheduledDate != today) {
      lastScheduledDate = today;
      final tomorrow = today.add(const Duration(days: 1));
      await scheduler.scheduleDay(tomorrow);
    }

    // Fetch today's events from the DB.
    final rawEvents = await db.reminderDao.getEventsForDay(now);
    final events = rawEvents.map(_toReminderEvent).toList();

    // Find the next pending reminder.
    final next = scheduler.nextPendingReminder(events);

    if (next != null) {
      // Fire if the reminder is due within the next 30 seconds.
      final diff = next.scheduledAt.difference(now);
      if (diff.inSeconds <= 30) {
        // Build TTS script.
        final script = _ttsScript(next);

        // Speak + notify.
        await ttsService.speak(script);
        await notificationService.showReminder(
          title: _notificationTitle(next.type),
          body: script,
          id: next.id.hashCode.abs() % 100000,
        );

        // Mark the event completed.
        await db.reminderDao.markCompleted(next.id);
      }

      // Update the foreground notification text.
      final minutesUntilNext = next.scheduledAt.difference(now).inMinutes;
      final typeLabel = next.type.name;

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Unperch',
          content: 'Next: $typeLabel in ${minutesUntilNext > 0 ? minutesUntilNext : 0} min',
        );
      }
    } else {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Unperch',
          content: 'No upcoming reminders today.',
        );
      }
    }
  });
}

// ---------------------------------------------------------------------------
// Private helpers (top-level so they can be used in the entry-point isolate)
// ---------------------------------------------------------------------------

ReminderEvent _toReminderEvent(ReminderEventData data) {
  return ReminderEvent(
    id: data.id,
    type: ReminderType.values.firstWhere(
      (e) => e.name == data.type,
      orElse: () => ReminderType.water,
    ),
    scheduledAt: data.scheduledAt,
    completed: data.completed,
    skipped: data.skipped,
    exerciseId: data.exerciseId,
  );
}

String _ttsScript(ReminderEvent event) {
  switch (event.type) {
    case ReminderType.water:
      return 'Time to drink some water. Stay hydrated!';
    case ReminderType.stretch:
      return 'Time for a quick stretch. Get up and move!';
    case ReminderType.exercise:
      return 'Time for your exercise break. Let\'s go!';
    case ReminderType.treadmill:
      return 'Time to hop on the treadmill. Keep moving!';
  }
}

String _notificationTitle(ReminderType type) {
  switch (type) {
    case ReminderType.water:
      return 'Hydration Reminder';
    case ReminderType.stretch:
      return 'Stretch Reminder';
    case ReminderType.exercise:
      return 'Exercise Reminder';
    case ReminderType.treadmill:
      return 'Treadmill Reminder';
  }
}

// ---------------------------------------------------------------------------
// BackgroundServiceManager
// ---------------------------------------------------------------------------

/// Manages the lifecycle of the [flutter_background_service] foreground
/// service (Android) / background task (iOS).
class BackgroundServiceManager {
  BackgroundServiceManager() : _service = FlutterBackgroundService();

  final FlutterBackgroundService _service;

  bool _running = false;

  /// Whether the background service is currently running.
  bool get isRunning => _running;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Configures the background service.  Must be called once at app startup
  /// before [start].
  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        autoStartOnBoot: false,
        notificationChannelId: 'unperch_reminders',
        initialNotificationTitle: 'Unperch',
        initialNotificationContent: 'Initialising…',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  /// Starts the background service.
  Future<void> start() async {
    await _service.startService();
    _running = true;
  }

  /// Stops the background service.
  Future<void> stop() async {
    _service.invoke('stop');
    _running = false;
  }
}

/// iOS background handler — required by [IosConfiguration].
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  return true;
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider for [BackgroundServiceManager].
final backgroundServiceManagerProvider = Provider<BackgroundServiceManager>(
  (ref) => BackgroundServiceManager(),
);
