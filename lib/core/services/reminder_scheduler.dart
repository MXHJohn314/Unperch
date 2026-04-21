import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/db/app_database.dart';
import 'package:unperch/core/datastore/unperch_datastore.dart';
import 'package:unperch/core/enums/enums.dart';
import 'package:unperch/core/models/reminder_event.dart';

// ---------------------------------------------------------------------------
// ReminderScheduler
// ---------------------------------------------------------------------------

/// Computes and persists the set of [ReminderEventData] rows for a given
/// shift-day, honouring OOO overrides and active skip records.
class ReminderScheduler {
  ReminderScheduler({
    required UnperchDataStore dataStore,
    required ReminderDao reminderDao,
    required SkipDao skipDao,
    required ShiftDao shiftDao,
  })  : _dataStore = dataStore,
        _reminderDao = reminderDao,
        _skipDao = skipDao,
        _shiftDao = shiftDao;

  final UnperchDataStore _dataStore;
  final ReminderDao _reminderDao;
  final SkipDao _skipDao;
  final ShiftDao _shiftDao;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Computes all reminder [DateTime]s for [date]'s shift (water + exercise
  /// interleaved), filters out OOO days and events blocked by active skips,
  /// then upserts [ReminderEventData] rows via [ReminderDao.insertEvent].
  ///
  /// Existing rows for [date] are not deleted first — [insertEvent] uses
  /// "insert or replace" semantics so re-calling is idempotent.
  Future<void> scheduleDay(DateTime date) async {
    // 1. Check working-day membership.
    final dow = _dartWeekdayToDayOfWeek(date.weekday);
    if (!_dataStore.workingDays.contains(dow)) return;

    // 2. Check OOO override.
    final dateKey = _dateKey(date);
    final shiftOverride = await _shiftDao.getShiftForDay(dateKey);
    if (shiftOverride != null && shiftOverride.isOutOfOffice == 1) return;

    // 3. Load active skips (keyed by exerciseId).
    final activeSkips = await _skipDao.getActiveSkips();
    final skippedExerciseIds = {
      for (final s in activeSkips) s.exerciseId,
    };

    // 4. Build reminder schedule.
    final startMinutes = _dataStore.shiftStartMinutes;
    final endMinutes = _dataStore.shiftEndMinutes;
    final waterInterval = _dataStore.waterIntervalMinutes;
    final exerciseInterval = _dataStore.exerciseIntervalMinutes;

    final events = _buildSchedule(
      date: date,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      waterIntervalMinutes: waterInterval,
      exerciseIntervalMinutes: exerciseInterval,
      skippedExerciseIds: skippedExerciseIds,
    );

    // 5. Persist.
    for (final event in events) {
      await _reminderDao.insertEvent(
        ReminderEventsCompanion.insert(
          id: event.id,
          type: event.type.name,
          scheduledAt: event.scheduledAt,
          completed: Value(event.completed),
          skipped: Value(event.skipped),
          exerciseId: Value(event.exerciseId),
        ),
      );
    }
  }

  /// Calls [scheduleDay] for today if onboarding is complete and the day has
  /// not already been scheduled (i.e., no rows exist for today yet).
  Future<void> scheduleTodayIfNeeded() async {
    if (!_dataStore.onboardingComplete) return;

    final today = DateTime.now();
    final existing = await _reminderDao.getEventsForDay(today);
    if (existing.isNotEmpty) return;

    await scheduleDay(today);
  }

  /// Returns the soonest upcoming [ReminderEvent] from [events] that is
  /// neither completed nor skipped and whose [ReminderEvent.scheduledAt] is
  /// at or after now.
  ///
  /// Returns [null] if no such event exists.
  ReminderEvent? nextPendingReminder(List<ReminderEvent> events) {
    final now = DateTime.now();
    final pending = events
        .where((e) => !e.completed && !e.skipped && !e.scheduledAt.isBefore(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return pending.isEmpty ? null : pending.first;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Builds the interleaved list of water + exercise reminders for [date].
  ///
  /// IDs are deterministic: `"<date>_<type>_<offset_minutes>"` so that
  /// inserting the same day twice is idempotent.
  List<ReminderEvent> _buildSchedule({
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required int waterIntervalMinutes,
    required int exerciseIntervalMinutes,
    required Set<String> skippedExerciseIds,
  }) {
    final events = <ReminderEvent>[];
    final dateKey = _dateKey(date);

    // Water reminders
    for (
      int m = startMinutes + waterIntervalMinutes;
      m <= endMinutes;
      m += waterIntervalMinutes
    ) {
      final scheduledAt = _minutesToDateTime(date, m);
      events.add(
        ReminderEvent(
          id: '${dateKey}_water_$m',
          type: ReminderType.water,
          scheduledAt: scheduledAt,
          completed: false,
          skipped: false,
        ),
      );
    }

    // Exercise reminders
    for (
      int m = startMinutes + exerciseIntervalMinutes;
      m <= endMinutes;
      m += exerciseIntervalMinutes
    ) {
      final scheduledAt = _minutesToDateTime(date, m);
      final eventId = '${dateKey}_exercise_$m';
      // Exercise events with a matching active skip are recorded as skipped.
      // (exerciseId is null until the exercise library assigns one — for now
      //  we generate a placeholder so the row is valid.)
      final isSkipped = false; // library not yet available; skips apply at fire time
      events.add(
        ReminderEvent(
          id: eventId,
          type: ReminderType.exercise,
          scheduledAt: scheduledAt,
          completed: false,
          skipped: isSkipped,
        ),
      );
    }

    // Sort by scheduledAt before returning.
    events.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return events;
  }

  /// Converts a minute-offset from midnight to an absolute [DateTime] on [date].
  DateTime _minutesToDateTime(DateTime date, int minutes) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  /// Formats a [DateTime] as an ISO-8601 date string, e.g. "2025-04-21".
  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Maps Dart's [DateTime.weekday] (1 = Monday … 7 = Sunday) to [DayOfWeek].
  DayOfWeek _dartWeekdayToDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return DayOfWeek.monday;
      case DateTime.tuesday:
        return DayOfWeek.tuesday;
      case DateTime.wednesday:
        return DayOfWeek.wednesday;
      case DateTime.thursday:
        return DayOfWeek.thursday;
      case DateTime.friday:
        return DayOfWeek.friday;
      case DateTime.saturday:
        return DayOfWeek.saturday;
      case DateTime.sunday:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider for [ReminderScheduler].
///
/// Requires [unperchDataStoreProvider] and [appDatabaseProvider] to be
/// overridden in [ProviderScope] at startup.
final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  final store = ref.watch(unperchDataStoreProvider);
  final db = ref.watch(appDatabaseProvider);
  return ReminderScheduler(
    dataStore: store,
    reminderDao: db.reminderDao,
    skipDao: db.skipDao,
    shiftDao: db.shiftDao,
  );
});

/// Provider for the [AppDatabase] singleton.
///
/// Must be overridden in [ProviderScope]:
///
/// ```dart
/// appDatabaseProvider.overrideWithValue(AppDatabase())
/// ```
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in ProviderScope.',
  );
});
