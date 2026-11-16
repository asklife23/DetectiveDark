import 'package:detective_dark/features/progress/data/datasources/local/app_database.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_tables.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:drift/drift.dart';

part 'save_slots_dao.g.dart';

/// Reads and writes the save slots. All SQL of the save game is here.
@DriftAccessor(tables: [SaveSlots, SaveBackups])
class SaveSlotsDao extends DatabaseAccessor<AppDatabase>
    with _$SaveSlotsDaoMixin {
  SaveSlotsDao(super.attachedDatabase);

  /// The slot with its decoded progress; null when the slot is empty.
  ///
  /// Throws what the payload converter throws when the payload cannot be
  /// read. Callers that must survive that ask for [readSchemaVersion] and
  /// [readRawPayload] instead.
  Future<SaveSlotRow?> readSlot(int slotIndex) => (select(
    saveSlots,
  )..where((slot) => slot.slotIndex.equals(slotIndex))).getSingleOrNull();

  /// The payload version of the slot, without decoding the payload.
  Future<int?> readSchemaVersion(int slotIndex) async {
    final row = await _column(slotIndex, saveSlots.schemaVersion);
    return row?.read(saveSlots.schemaVersion);
  }

  /// The payload exactly as it is stored, without decoding it.
  Future<String?> readRawPayload(int slotIndex) async {
    final row = await _column(slotIndex, saveSlots.payload);
    // `read` returns the SQL value; only `readWithConverter` would decode.
    return row?.read(saveSlots.payload);
  }

  /// Stores [progress] in the slot and returns whether it was written.
  ///
  /// A new slot starts at revision 1; every later write adds one, marks the
  /// row as changed for cloud sync and stamps it with [nowUtcMs].
  ///
  /// A slot whose payload is **newer** than [schemaVersion] was written by
  /// a newer version of the game. It is left untouched and the result is
  /// `false`: an old build must never destroy a save it cannot understand.
  ///
  /// Check and write run in one transaction, so nothing can slip between.
  Future<bool> writeProgress({
    required int slotIndex,
    required GameProgress progress,
    required int schemaVersion,
    required int playTimeSeconds,
    required int nowUtcMs,
  }) {
    return transaction(() async {
      final query = selectOnly(saveSlots)
        ..addColumns([saveSlots.schemaVersion, saveSlots.localRevision])
        ..where(saveSlots.slotIndex.equals(slotIndex));
      final stored = await query.getSingleOrNull();

      final storedVersion = stored?.read(saveSlots.schemaVersion);
      if (storedVersion != null && storedVersion > schemaVersion) return false;
      final storedRevision = stored?.read(saveSlots.localRevision) ?? 0;

      // Insert, or replace the row when the slot is already taken. Columns
      // that are not named here (owner, cloud revision, last sync) keep
      // their values on a replace.
      await into(saveSlots).insertOnConflictUpdate(
        SaveSlotsCompanion.insert(
          slotIndex: Value(slotIndex),
          schemaVersion: schemaVersion,
          payload: progress,
          caseId: progress.caseId,
          chapterId: progress.chapterId,
          sceneId: progress.currentSceneId ?? '',
          playTimeSeconds: Value(playTimeSeconds),
          localRevision: Value(storedRevision + 1),
          isDirty: const Value(true),
          updatedAtUtcMs: nowUtcMs,
        ),
      );
      return true;
    });
  }

  /// Moves the slot into the backup table and empties it.
  ///
  /// Used for a save that cannot be read: it is kept, never silently
  /// deleted (ADR 0003), and the slot is free for a new game. Copy and
  /// delete run in one transaction. Returns false when the slot is empty.
  Future<bool> moveSlotToBackup({
    required int slotIndex,
    required String reason,
    required int nowUtcMs,
  }) {
    return transaction(() async {
      final payload = await readRawPayload(slotIndex);
      final version = await readSchemaVersion(slotIndex);
      if (payload == null || version == null) return false;

      await into(saveBackups).insert(
        SaveBackupsCompanion.insert(
          slotIndex: slotIndex,
          schemaVersion: version,
          payload: payload,
          reason: reason,
          createdAtUtcMs: nowUtcMs,
        ),
      );
      await (delete(
        saveSlots,
      )..where((slot) => slot.slotIndex.equals(slotIndex))).go();
      return true;
    });
  }

  /// Every backup, oldest first.
  Future<List<SaveBackupRow>> readBackups() => (select(
    saveBackups,
  )..orderBy([(backup) => OrderingTerm.asc(backup.id)])).get();

  Future<TypedResult?> _column(int slotIndex, Expression<Object> column) {
    final query = selectOnly(saveSlots)
      ..addColumns([column])
      ..where(saveSlots.slotIndex.equals(slotIndex));
    return query.getSingleOrNull();
  }
}
