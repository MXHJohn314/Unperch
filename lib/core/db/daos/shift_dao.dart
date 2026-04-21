import 'package:drift/drift.dart';
import 'package:unperch/core/db/app_database.dart';

part 'shift_dao.g.dart';

@DriftAccessor(tables: [ShiftOverrides])
class ShiftDao extends DatabaseAccessor<AppDatabase> with _$ShiftDaoMixin {
  ShiftDao(super.db);

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Returns the [ShiftOverrideData] for [date] (formatted as ISO-8601 date
  /// string, e.g. "2025-04-21"), or null if no override exists.
  Future<ShiftOverrideData?> getShiftForDay(String date) =>
      (select(shiftOverrides)..where((tbl) => tbl.date.equals(date)))
          .getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Upserts the out-of-office flag for [date].
  Future<int> setOutOfOffice(String date, bool isOutOfOffice) =>
      into(shiftOverrides).insertOnConflictUpdate(
        ShiftOverridesCompanion.insert(
          date: date,
          isOutOfOffice: Value(isOutOfOffice ? 1 : 0),
        ),
      );

  /// Removes the override row for [date], reverting to default shift settings.
  Future<int> clearOverride(String date) =>
      (delete(shiftOverrides)..where((tbl) => tbl.date.equals(date))).go();
}
