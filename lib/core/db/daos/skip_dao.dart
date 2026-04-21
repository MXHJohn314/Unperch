import 'package:drift/drift.dart';
import 'package:unperch/core/db/app_database.dart';

part 'skip_dao.g.dart';

@DriftAccessor(tables: [SkipRecords])
class SkipDao extends DatabaseAccessor<AppDatabase> with _$SkipDaoMixin {
  SkipDao(super.db);

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Returns all skip records that are currently active — i.e., either
  /// indefinite or not yet past their [expiresAt] timestamp.
  Future<List<SkipRecordData>> getActiveSkips() {
    final now = DateTime.now();
    return (select(skipRecords)
          ..where(
            (tbl) =>
                // Indefinite skips have no expiry (NULL)
                tbl.expiresAt.isNull() |
                tbl.expiresAt.isBiggerThanValue(now),
          ))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Inserts or replaces a skip record.
  Future<int> insertSkip(SkipRecordsCompanion entry) =>
      into(skipRecords).insertOnConflictUpdate(entry);

  /// Deletes all skip records whose [expiresAt] is in the past.
  Future<int> deleteExpired() {
    final now = DateTime.now();
    return (delete(skipRecords)
          ..where(
            (tbl) =>
                tbl.expiresAt.isNotNull() &
                tbl.expiresAt.isSmallerOrEqualValue(now),
          ))
        .go();
  }

  /// Removes a specific skip record by its [id].
  Future<int> deleteById(String id) =>
      (delete(skipRecords)..where((tbl) => tbl.id.equals(id))).go();
}
