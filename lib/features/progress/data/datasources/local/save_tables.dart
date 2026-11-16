import 'package:detective_dark/features/progress/data/datasources/local/game_progress_converter.dart';
import 'package:drift/drift.dart';

/// The save game: one row per slot. The game uses a single slot (ADR 0003).
///
/// The columns come in three groups:
/// - the **payload**: the whole progress as versioned JSON;
/// - a **summary** of it (`caseId` ... `playTimeSeconds`), readable without
///   decoding the payload (a "Continue" button, the cloud table);
/// - **sync** columns, used by cloud sync in Phase 4. They exist from the
///   first schema version so that phase needs no migration.
///
/// All times are UTC milliseconds since the Unix epoch.
@DataClassName('SaveSlotRow')
class SaveSlots extends Table {
  IntColumn get slotIndex => integer()();

  /// The account the save belongs to; null until the player has one.
  TextColumn get ownerUserId => text().nullable()();

  /// The version of the payload format, also stored inside the payload.
  IntColumn get schemaVersion => integer()();

  TextColumn get payload => text().map(const GameProgressConverter())();

  TextColumn get caseId => text()();
  TextColumn get chapterId => text()();

  /// The scene the player is in; empty when the navigation stack is.
  TextColumn get sceneId => text()();
  IntColumn get playTimeSeconds => integer().withDefault(const Constant(0))();

  /// Grows by one with every write on this device.
  IntColumn get localRevision => integer().withDefault(const Constant(1))();

  /// The revision the cloud had at the last sync; null before the first.
  IntColumn get cloudRevision => integer().nullable()();

  /// True while the row has changes the cloud has not seen.
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  IntColumn get updatedAtUtcMs => integer()();
  IntColumn get lastSyncedAtUtcMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {slotIndex};
}

/// Saves the game could not read, kept instead of being thrown away.
///
/// The payload is stored exactly as it was found (plain text, no
/// converter): it is unreadable for the game, but a developer can still
/// inspect or repair it.
@DataClassName('SaveBackupRow')
class SaveBackups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get slotIndex => integer()();
  IntColumn get schemaVersion => integer()();
  TextColumn get payload => text()();

  /// Why the save was set aside, for developers (e.g. the parse error).
  TextColumn get reason => text()();
  IntColumn get createdAtUtcMs => integer()();
}
