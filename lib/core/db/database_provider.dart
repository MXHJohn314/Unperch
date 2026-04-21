import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unperch/core/db/app_database.dart';
import 'package:unperch/core/services/reminder_scheduler.dart';

export 'package:unperch/core/services/reminder_scheduler.dart'
    show appDatabaseProvider;

/// Convenience provider for [ShiftDao].
final shiftDaoProvider = Provider<ShiftDao>((ref) {
  return ref.watch(appDatabaseProvider).shiftDao;
});

/// Convenience provider for [ReminderDao].
final reminderDaoProvider = Provider<ReminderDao>((ref) {
  return ref.watch(appDatabaseProvider).reminderDao;
});
