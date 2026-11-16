import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:detective_dark/features/progress/data/datasources/local/app_database.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_slots_dao.dart';
import 'package:detective_dark/features/progress/data/repositories/drift_progress_repository.dart';
import 'package:detective_dark/features/progress/data/services/play_time_counter.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_harness.dart';
import '../../../../helpers/progress_fixtures.dart';
import '../../../../helpers/slice_fixtures.dart';

/// A DAO whose disk gives up on demand.
class _FlakyDao extends SaveSlotsDao {
  _FlakyDao(super.attachedDatabase);

  bool failReads = false;
  bool failWrites = false;

  @override
  Future<int?> readSchemaVersion(int slotIndex) => failReads
      ? Future.error(Exception('disk unplugged'))
      : super.readSchemaVersion(slotIndex);

  @override
  Future<bool> writeProgress({
    required int slotIndex,
    required GameProgress progress,
    required int schemaVersion,
    required int playTimeSeconds,
    required int nowUtcMs,
  }) => failWrites
      ? Future.error(Exception('disk full'))
      : super.writeProgress(
          slotIndex: slotIndex,
          progress: progress,
          schemaVersion: schemaVersion,
          playTimeSeconds: playTimeSeconds,
          nowUtcMs: nowUtcMs,
        );
}

void main() {
  const writeDelay = Duration(milliseconds: 100);
  const slot = DriftProgressRepository.slotIndex;

  late AppDatabase database;
  late _FlakyDao dao;
  late List<LogEntry> log;

  /// The monotonic time of the play time counter; moved by the test.
  late Duration playClock;

  final repositories = <DriftProgressRepository>[];

  /// A repository on the database of the test. Calling it again is what
  /// starting the app again does: new memory, same disk.
  DriftProgressRepository open({int nowUtcMs = 1700000000000}) {
    final repository = DriftProgressRepository(
      dao: dao,
      clock: FixedClock(nowUtcMs),
      playTime: PlayTimeCounter(elapsed: () => playClock),
      writeDelay: writeDelay,
      logger: AppLogger('test', writer: log.add),
    );
    repositories.add(repository);
    return repository;
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = _FlakyDao(database);
    log = [];
    playClock = Duration.zero;
  });

  tearDown(() async {
    for (final repository in repositories) {
      await repository.dispose();
    }
    repositories.clear();
    await database.close();
  });

  Future<SaveSlotRow?> row() => dao.readSlot(slot);

  Future<void> corrupt(String payload, {int? schemaVersion}) async {
    await dao.writeProgress(
      slotIndex: slot,
      progress: richProgress,
      schemaVersion: 1,
      playTimeSeconds: 0,
      nowUtcMs: 1,
    );
    await database
        .update(database.saveSlots)
        .write(
          SaveSlotsCompanion(
            schemaVersion: Value.absentIfNull(schemaVersion),
          ),
        );
    await database.customUpdate(
      'UPDATE save_slots SET payload = ?',
      variables: [Variable.withString(payload)],
      updates: {database.saveSlots},
    );
  }

  group('without a save', () {
    test('load finds nothing', () async {
      final repository = open();

      expect((await repository.load()).valueOrNull, isNull);
      expect((await repository.load()).isSuccess, isTrue);
      expect(repository.current, isNull);
    });

    test('watch emits nothing', () async {
      final repository = open();
      final seen = <GameProgress>[];
      repository.watch().listen(seen.add);

      await repository.load();
      await pumpEventQueue();

      expect(seen, isEmpty);
    });
  });

  group('save', () {
    test('answers at once from memory; the disk follows after the '
        'delay', () async {
      final repository = open();

      final result = await repository.save(newGame);

      expect(result.isSuccess, isTrue);
      expect(repository.current, newGame);
      expect(await row(), isNull);

      await Future<void>.delayed(writeDelay * 2);
      expect((await row())!.payload, newGame);
    });

    test('watch gives the current progress first, then every save', () async {
      final repository = open();
      await repository.save(newGame);
      final seen = <GameProgress>[];
      repository.watch().listen(seen.add);
      await pumpEventQueue();

      final next = newGame.withFlag('front_door_open');
      await repository.save(next);
      await pumpEventQueue();

      expect(seen, [newGame, next]);
    });

    test('changes close together are written as one row', () async {
      final repository = open();

      await repository.save(newGame);
      await repository.save(newGame.withItem('brass_key'));
      await repository.save(richProgress);
      await Future<void>.delayed(writeDelay * 2);

      final stored = (await row())!;
      expect(stored.payload, richProgress);
      expect(stored.localRevision, 1);
    });

    test('a stream of changes cannot postpone the write: it comes one '
        'delay after the first change', () async {
      final repository = open();

      await repository.save(newGame);
      await Future<void>.delayed(writeDelay * 0.6);
      await repository.save(newGame.withItem('brass_key'));
      await Future<void>.delayed(writeDelay * 0.6);

      // 1.2 delays after the first change, 0.6 after the second.
      expect((await row())!.payload.inventory, ['brass_key']);
    });

    test('every write adds one to the revision, marks the row changed and '
        'stamps the time', () async {
      final repository = open(nowUtcMs: 5000);

      await repository.save(newGame);
      await repository.onBackground();
      await repository.save(newGame.withItem('brass_key'));
      await repository.onBackground();

      final stored = (await row())!;
      expect(stored.localRevision, 2);
      expect(stored.isDirty, isTrue);
      expect(stored.updatedAtUtcMs, 5000);
      expect(stored.schemaVersion, 1);
      expect(stored.sceneId, 'villa_exterior');
    });
  });

  group('going to the background', () {
    test('writes what is waiting, immediately', () async {
      final repository = open();
      await repository.save(richProgress);

      await repository.onBackground();

      expect((await row())!.payload, richProgress);
    });

    test('the timer that was waiting does not write a second time', () async {
      final repository = open();
      await repository.save(newGame);
      await repository.onBackground();

      await Future<void>.delayed(writeDelay * 2);

      expect((await row())!.localRevision, 1);
    });

    test('without anything new, nothing is written', () async {
      final repository = open();
      await repository.save(newGame);
      await repository.onBackground();

      await repository.onBackground();
      await repository.onBackground();

      expect((await row())!.localRevision, 1);
    });

    test('before a game exists it does nothing', () async {
      final repository = open();

      await repository.onBackground();

      expect(await row(), isNull);
    });

    test('dispose writes what is waiting', () async {
      final repository = open();
      await repository.save(richProgress);

      await repository.dispose();

      expect((await row())!.payload, richProgress);
    });
  });

  group('starting the app again', () {
    test('load brings back every field of the progress', () async {
      final before = open();
      await before.save(richProgress);
      await before.onBackground();

      final after = open();
      final loaded = (await after.load()).valueOrNull;

      expect(loaded, richProgress);
      expect(after.current, richProgress);
    });

    test('a listener that was waiting before the load gets the loaded '
        'progress', () async {
      final before = open();
      await before.save(richProgress);
      await before.onBackground();

      final after = open();
      final seen = <GameProgress>[];
      after.watch().listen(seen.add);
      await after.load();
      await pumpEventQueue();

      expect(seen, [richProgress]);
    });

    test('the disk is read once: a later load answers from memory, which '
        'is ahead of the disk', () async {
      final before = open();
      await before.save(newGame);
      await before.onBackground();

      final after = open();
      await after.load();
      final ahead = newGame.withItem('brass_key');
      await after.save(ahead);

      expect((await after.load()).valueOrNull, ahead);
      expect((await row())!.payload, newGame);
    });
  });

  group('a save that cannot be read', () {
    const garbage = '{"schemaVersion":1,"caseId":"case01","sceneSt';

    test(
      'is reported as corrupt and moved to the backups, untouched',
      () async {
        await corrupt(garbage);
        final repository = open(nowUtcMs: 7000);

        final failure = (await repository.load()).failureOrNull;

        final backup = (await dao.readBackups()).single;
        expect(failure, isA<SaveCorruptFailure>());
        expect(repository.current, isNull);
        expect(await dao.readRawPayload(slot), isNull);
        expect(backup.payload, garbage);
        expect(backup.schemaVersion, 1);
        expect(backup.createdAtUtcMs, 7000);
        expect(backup.reason, contains('not valid JSON'));
        expect(log.single.level, LogLevel.error);
      },
    );

    test('the next load finds an empty slot, and a new game is saved '
        'there', () async {
      await corrupt(garbage);
      final repository = open();
      await repository.load();

      expect((await repository.load()).valueOrNull, isNull);
      expect((await repository.save(newGame)).isSuccess, isTrue);
      await repository.onBackground();

      expect((await row())!.payload, newGame);
      expect((await row())!.localRevision, 1);
      expect(await dao.readBackups(), hasLength(1));
    });

    test('a readable JSON with a wrong field is corrupt too', () async {
      await corrupt('{"schemaVersion":1,"caseId":7}');
      final repository = open();

      expect(
        (await repository.load()).failureOrNull,
        isA<SaveCorruptFailure>(),
      );
      expect(await dao.readBackups(), hasLength(1));
    });
  });

  group('a save from a newer version of the game', () {
    test('is reported with both versions and left exactly as it is', () async {
      const future = '{"schemaVersion":3,"somethingNew":true}';
      await corrupt(future, schemaVersion: 3);
      final repository = open();

      final failure = (await repository.load()).failureOrNull;

      expect(
        failure,
        const SaveTooNewFailure(savedVersion: 3, supportedVersion: 1),
      );
      expect(await dao.readRawPayload(slot), future);
      expect(await dao.readBackups(), isEmpty);
    });

    test('is too new, not corrupt, even when this build cannot parse '
        'it', () async {
      await corrupt('<save version="3"/>', schemaVersion: 3);
      final repository = open();

      expect(
        (await repository.load()).failureOrNull,
        isA<SaveTooNewFailure>(),
      );
      expect(await dao.readBackups(), isEmpty);
    });

    test('is found by the version inside the payload when the column '
        'does not say so', () async {
      await corrupt('{"schemaVersion":3,"somethingNew":true}');
      final repository = open();

      expect(
        (await repository.load()).failureOrNull,
        isA<SaveTooNewFailure>(),
      );
      expect(await dao.readBackups(), isEmpty);
    });

    test('cannot be overwritten: save fails and the disk stays', () async {
      const future = '{"schemaVersion":3,"somethingNew":true}';
      await corrupt(future, schemaVersion: 3);
      final repository = open();
      await repository.load();

      final result = await repository.save(newGame);
      await repository.onBackground();

      expect(result.failureOrNull, isA<SaveTooNewFailure>());
      expect(repository.current, isNull);
      expect(await dao.readRawPayload(slot), future);
    });
  });

  group('a disk that fails', () {
    test('on reading: load reports a storage failure', () async {
      final repository = open();
      dao.failReads = true;

      final failure = (await repository.load()).failureOrNull;

      expect(failure, isA<StorageFailure>());
      expect(failure!.cause, isNotNull);
    });

    test('on writing: the game goes on in memory, the failure is logged '
        'and the next chance writes everything', () async {
      final repository = open();
      dao.failWrites = true;

      expect((await repository.save(newGame)).isSuccess, isTrue);
      await repository.onBackground();
      expect(await row(), isNull);
      expect(log.single.level, LogLevel.error);
      expect(repository.current, newGame);

      dao.failWrites = false;
      await repository.onBackground();
      expect((await row())!.payload, newGame);
    });
  });

  group('play time', () {
    void play(Duration duration) => playClock += duration;

    test('is stamped when the row is written, in the summary and in the '
        'payload', () async {
      final repository = open();
      await repository.load();
      await repository.save(newGame);

      play(const Duration(seconds: 90));
      await repository.onBackground();

      final stored = (await row())!;
      expect(stored.playTimeSeconds, 90);
      expect(stored.payload.playTimeSeconds, 90);
    });

    test('goes on from the stored value after a restart', () async {
      final before = open();
      await before.load();
      await before.save(newGame);
      play(const Duration(seconds: 90));
      await before.onBackground();

      final after = open();
      expect((await after.load()).valueOrNull!.playTimeSeconds, 90);
      play(const Duration(seconds: 30));
      await after.save(after.current!.withItem('brass_key'));
      await after.onBackground();

      expect((await row())!.playTimeSeconds, 120);
    });

    test('is written when the player leaves, even without any other '
        'change', () async {
      final repository = open();
      await repository.load();
      await repository.save(newGame);
      await repository.onBackground();
      repository.onForeground();

      play(const Duration(minutes: 5));
      await repository.onBackground();

      final stored = (await row())!;
      expect(stored.playTimeSeconds, 300);
      expect(stored.localRevision, 2);
    });

    test('does not count while the app is in the background', () async {
      final repository = open();
      await repository.load();
      await repository.save(newGame);
      play(const Duration(seconds: 10));
      await repository.onBackground();

      play(const Duration(hours: 9));
      repository.onForeground();
      play(const Duration(seconds: 5));
      await repository.onBackground();

      expect((await row())!.playTimeSeconds, 15);
    });

    test('a progress with another play time is another playthrough: '
        'counting starts from its value', () async {
      final repository = open();
      await repository.load();
      await repository.save(newGame);
      play(const Duration(minutes: 10));
      await repository.onBackground();
      repository.onForeground();

      // A pasted save that had been played for 754 seconds.
      await repository.save(richProgress);
      play(const Duration(seconds: 6));
      await repository.onBackground();

      expect((await row())!.playTimeSeconds, 760);
    });
  });
}
