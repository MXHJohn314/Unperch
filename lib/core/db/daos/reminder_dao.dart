import 'package:drift/drift.dart';
import 'package:unperch/core/db/app_database.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [ReminderEvents])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  // ---------------------------------------------------------------------------
  // Watches
  // ---------------------------------------------------------------------------

  /// Emits the full list of [ReminderEvent] rows scheduled for today whenever
  /// the underlying data changes.
  Stream<List<ReminderEventData>> watchTodayEvents() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(reminderEvents)
          ..where(
            (tbl) =>
                tbl.scheduledAt.isBiggerOrEqualValue(startOfDay) &
                tbl.scheduledAt.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.scheduledAt)]))
        .watch();
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Inserts or replaces a reminder event row.
  Future<int> insertEvent(ReminderEventsCompanion entry) =>
      into(reminderEvents).insertOnConflictUpdate(entry);

  /// Marks the event identified by [id] as completed.
  Future<void> markCompleted(String id) => (update(reminderEvents)
        ..where((tbl) => tbl.id.equals(id)))
      .write(const ReminderEventsCompanion(completed: Value(true)));

  /// Marks the event identified by [id] as skipped.
  Future<void> markSkipped(String id) => (update(reminderEvents)
        ..where((tbl) => tbl.id.equals(id)))
      .write(const ReminderEventsCompanion(skipped: Value(true)));

  /// Deletes all reminder events scheduled before [before].
  Future<int> deleteBefore(DateTime before) =>
      (delete(reminderEvents)
            ..where((tbl) => tbl.scheduledAt.isSmallerThanValue(before)))
          .go();
}
