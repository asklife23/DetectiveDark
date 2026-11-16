import 'package:detective_dark/features/progress/data/datasources/local/app_database.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_slots_dao.dart';
import 'package:detective_dark/features/progress/data/migrations/save_exception.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/progress_fixtures.dart';
import '../../../../../helpers/slice_fixtures.dart';

void main() {
  late AppDatabase database;
  late SaveSlotsDao dao;

  // A fresh database in memory for every test: fast, and no test can see
  // what another one wrote.
  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.saveSlotsDao;
  });
  tearDown(() => database.close());

  Future<bool> write(
    GameProgress progress, {
    int slotIndex = 0,
    int schemaVersion = 1,
    int playTimeSeconds = 0,
    int nowUtcMs = 1000,
  }) => dao.writeProgress(
    slotIndex: slotIndex,
    progress: progress,
    schemaVersion: schemaVersion,
    playTimeSeconds: playTimeSeconds,
    nowUtcMs: nowUtcMs,
  );

  test('an empty slot reads as null', () async {
    expect(await dao.readSlot(0), isNull);
    expect(await dao.readSchemaVersion(0), isNull);
    expect(await dao.readRawPayload(0), isNull);
  });

  test('the first write creates the row with its summary', () async {
    final written = await write(richProgress, playTimeSeconds: 754);

    final row = (await dao.readSlot(0))!;
    expect(written, isTrue);
    expect(row.payload, richProgress);
    expect(row.schemaVersion, 1);
    expect(row.caseId, 'case01');
    expect(row.chapterId, 'ch01');
    expect(row.sceneId, 'statue_closeup');
    expect(row.playTimeSeconds, 754);
    expect(row.updatedAtUtcMs, 1000);
  });

  test('a new row starts at revision 1, is dirty and knows no cloud', () async {
    await write(newGame);

    final row = (await dao.readSlot(0))!;
    expect(row.localRevision, 1);
    expect(row.isDirty, isTrue);
    expect(row.ownerUserId, isNull);
    expect(row.cloudRevision, isNull);
    expect(row.lastSyncedAtUtcMs, isNull);
  });

  test('every later write replaces the progress and adds one to the '
      'revision', () async {
    await write(newGame);
    await write(newGame.withItem('brass_key'), nowUtcMs: 2000);
    await write(richProgress, nowUtcMs: 3000);

    final row = (await dao.readSlot(0))!;
    expect(row.payload, richProgress);
    expect(row.localRevision, 3);
    expect(row.updatedAtUtcMs, 3000);
    expect(await database.select(database.saveSlots).get(), hasLength(1));
  });

  test('a write marks a synced row dirty again and keeps what sync '
      'stored', () async {
    await write(newGame);
    // What Phase 4 will do after an upload.
    await database
        .update(database.saveSlots)
        .write(
          const SaveSlotsCompanion(
            ownerUserId: Value('user-1'),
            cloudRevision: Value(1),
            isDirty: Value(false),
            lastSyncedAtUtcMs: Value(1500),
          ),
        );

    await write(newGame.withFlag('front_door_open'), nowUtcMs: 2000);

    final row = (await dao.readSlot(0))!;
    expect(row.isDirty, isTrue);
    expect(row.localRevision, 2);
    expect(row.ownerUserId, 'user-1');
    expect(row.cloudRevision, 1);
    expect(row.lastSyncedAtUtcMs, 1500);
  });

  test('slots are independent', () async {
    await write(newGame);
    await write(richProgress, slotIndex: 1);

    expect((await dao.readSlot(0))!.payload, newGame);
    expect((await dao.readSlot(1))!.payload, richProgress);
    expect((await dao.readSlot(1))!.localRevision, 1);
  });

  test('an empty navigation stack is stored with an empty scene', () async {
    await write(newGame.withSceneStack(const []));

    expect((await dao.readSlot(0))!.sceneId, isEmpty);
  });

  group('a save from a newer version of the game', () {
    test('is not overwritten', () async {
      await write(richProgress, schemaVersion: 2);

      final written = await write(newGame, nowUtcMs: 2000);

      final row = (await dao.readSlot(0))!;
      expect(written, isFalse);
      expect(row.payload, richProgress);
      expect(row.schemaVersion, 2);
      expect(row.localRevision, 1);
      expect(row.updatedAtUtcMs, 1000);
    });

    test('an older or equal one is', () async {
      await write(newGame);

      expect(await write(richProgress, schemaVersion: 2), isTrue);
      expect(await write(newGame, schemaVersion: 2), isTrue);
      expect(await dao.readSchemaVersion(0), 2);
    });
  });

  group('a payload the game cannot read', () {
    const garbage = '{"caseId": "case01", "sceneSt';

    Future<void> corruptSlot() async {
      await write(richProgress);
      await database.customUpdate(
        'UPDATE save_slots SET payload = ?',
        variables: [Variable.withString(garbage)],
        updates: {database.saveSlots},
      );
    }

    test('makes readSlot throw, but version and raw text stay '
        'readable', () async {
      await corruptSlot();

      await expectLater(
        dao.readSlot(0),
        throwsA(isA<SaveCorruptException>()),
      );
      expect(await dao.readSchemaVersion(0), 1);
      expect(await dao.readRawPayload(0), garbage);
    });

    test('is moved to the backups untouched and the slot becomes '
        'free', () async {
      await corruptSlot();

      final moved = await dao.moveSlotToBackup(
        slotIndex: 0,
        reason: 'FormatException: Unexpected end of input',
        nowUtcMs: 5000,
      );

      final backups = await dao.readBackups();
      expect(moved, isTrue);
      expect(await dao.readSlot(0), isNull);
      expect(backups, hasLength(1));
      expect(backups.single.payload, garbage);
      expect(backups.single.slotIndex, 0);
      expect(backups.single.schemaVersion, 1);
      expect(backups.single.reason, contains('FormatException'));
      expect(backups.single.createdAtUtcMs, 5000);
    });

    test('a new game can be written after the move, at revision 1', () async {
      await corruptSlot();
      await dao.moveSlotToBackup(slotIndex: 0, reason: 'x', nowUtcMs: 5000);

      expect(await write(newGame), isTrue);
      expect((await dao.readSlot(0))!.localRevision, 1);
      expect(await dao.readBackups(), hasLength(1));
    });
  });

  test('moving an empty slot does nothing', () async {
    final moved = await dao.moveSlotToBackup(
      slotIndex: 0,
      reason: 'x',
      nowUtcMs: 5000,
    );

    expect(moved, isFalse);
    expect(await dao.readBackups(), isEmpty);
  });

  test('backups are listed oldest first', () async {
    for (final (index, progress) in [newGame, richProgress].indexed) {
      await write(progress);
      await dao.moveSlotToBackup(
        slotIndex: 0,
        reason: 'backup $index',
        nowUtcMs: 5000 + index,
      );
    }

    expect(
      [for (final backup in await dao.readBackups()) backup.reason],
      ['backup 0', 'backup 1'],
    );
  });
}
