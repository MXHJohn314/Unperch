// TODO: run build_runner after deps are resolved:
//   dart run build_runner build --delete-conflicting-outputs

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/reminder_dao.dart';
import 'daos/shift_dao.dart';
import 'daos/skip_dao.dart';
import 'daos/treadmill_dao.dart';

export 'daos/reminder_dao.dart';
export 'daos/shift_dao.dart';
export 'daos/skip_dao.dart';
export 'daos/treadmill_dao.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

/// Stores each scheduled reminder/exercise prompt.
@DataClassName('ReminderEventData')
class ReminderEvents extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Serialised [ReminderType] enum name (e.g. "water").
  TextColumn get type => text()();

  /// UTC epoch milliseconds stored as a DateTime column.
  DateTimeColumn get scheduledAt => dateTime()();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  /// Null for water/stretch reminders; references an exercise by its id.
  TextColumn get exerciseId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tracks which exercises a user has skipped and for how long.
@DataClassName('SkipRecordData')
class SkipRecords extends Table {
  TextColumn get id => text()();

  TextColumn get exerciseId => text()();

  /// Serialised [SkipScope] enum name.
  TextColumn get scope => text()();

  DateTimeColumn get createdAt => dateTime()();

  /// Null unless [scope] is "untilDate".
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-date overrides for the user's shift (currently only the OOO flag).
@DataClassName('ShiftOverrideData')
class ShiftOverrides extends Table {
  /// ISO-8601 date string, e.g. "2025-04-21". Acts as the primary key.
  TextColumn get date => text()();

  /// 1 = out of office (reminders suspended), 0 = normal.
  IntColumn get isOutOfOffice => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

/// Records stats from a connected BLE treadmill session.
@DataClassName('TreadmillSessionData')
class TreadmillSessions extends Table {
  TextColumn get id => text()();

  DateTimeColumn get startTime => dateTime()();

  /// Null if the session is still active.
  DateTimeColumn get endTime => dateTime().nullable()();

  IntColumn get steps => integer().withDefault(const Constant(0))();
  IntColumn get calories => integer().withDefault(const Constant(0))();

  /// BLE device model string reported by the treadmill.
  TextColumn get deviceModel => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [ReminderEvents, SkipRecords, ShiftOverrides, TreadmillSessions],
  daos: [ReminderDao, SkipDao, ShiftDao, TreadmillDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Convenience constructor used in tests — pass an in-memory executor.
  AppDatabase.forTesting(super.executor) : super();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'unperch.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
