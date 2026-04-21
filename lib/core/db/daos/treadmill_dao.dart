import 'package:drift/drift.dart';
import 'package:unperch/core/db/app_database.dart';

part 'treadmill_dao.g.dart';

@DriftAccessor(tables: [TreadmillSessions])
class TreadmillDao extends DatabaseAccessor<AppDatabase>
    with _$TreadmillDaoMixin {
  TreadmillDao(super.db);

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Inserts or replaces a treadmill session record.
  Future<int> insertSession(TreadmillSessionsCompanion entry) =>
      into(treadmillSessions).insertOnConflictUpdate(entry);

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Returns all treadmill sessions whose [startTime] falls within
  /// [[start], [end]).
  Future<List<TreadmillSessionData>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(treadmillSessions)
            ..where(
              (tbl) =>
                  tbl.startTime.isBiggerOrEqualValue(start) &
                  tbl.startTime.isSmallerThanValue(end),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.startTime)]))
          .get();

  /// Deletes the session identified by [id].
  Future<int> deleteById(String id) =>
      (delete(treadmillSessions)..where((tbl) => tbl.id.equals(id))).go();
}
