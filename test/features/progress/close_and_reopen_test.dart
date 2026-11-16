import 'dart:io';

import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/features/notebook/domain/usecases/mark_note_read.dart';
import 'package:detective_dark/features/progress/data/datasources/local/app_database.dart';
import 'package:detective_dark/features/progress/data/repositories/drift_progress_repository.dart';
import 'package:detective_dark/features/progress/data/services/play_time_counter.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/game_harness.dart';

/// One run of the app: its own memory, on a database file that outlives it.
class _Session {
  _Session(File file, Duration Function() playClock)
    : database = AppDatabase(NativeDatabase(file)) {
    repository = DriftProgressRepository(
      dao: database.saveSlotsDao,
      clock: GameHarness.clock,
      playTime: PlayTimeCounter(elapsed: playClock),
      writeDelay: writeDelay,
    );
    game = GameHarness(progressRepository: repository);
    bloc = game.createBloc();
  }

  static const writeDelay = Duration(milliseconds: 100);

  final AppDatabase database;
  late final DriftProgressRepository repository;
  late final GameHarness game;
  late final SceneBloc bloc;

  GameProgress get progress => repository.current!;

  /// The player leaves the game and the system ends the app.
  Future<void> close() async {
    await repository.onBackground();
    await _end();
  }

  /// Ends the app without the save hearing about it.
  Future<void> _end() async {
    await bloc.close();
    await repository.dispose();
    await game.dispose();
    await database.close();
  }
}

/// The "close and reopen" scenario of phase 2 on the real content: the game
/// logic as in the app, the save in a real SQLite file. Every `open()` is a
/// fresh start of the app on the same file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory folder;
  late File saveFile;
  late Duration playClock;
  final sessions = <_Session>[];

  setUp(() {
    folder = Directory.systemTemp.createTempSync('detective_dark_save_test');
    saveFile = File('${folder.path}/save.sqlite');
    playClock = Duration.zero;
  });

  tearDown(() async {
    for (final session in sessions) {
      await session._end();
    }
    sessions.clear();
    folder.deleteSync(recursive: true);
  });

  /// Starts the app on [file] and waits until the game is running.
  Future<_Session> open([File? file]) async {
    final session = _Session(file ?? saveFile, () => playClock);
    sessions.add(session);
    await session.bloc.start();
    return session;
  }

  Future<void> close(_Session session) async {
    sessions.remove(session);
    await session.close();
  }

  /// The disk as it is at this very moment, as if the app were killed now:
  /// whatever is still waiting in memory is not on it.
  File diskSnapshot() => saveFile.copySync('${folder.path}/killed.sqlite');

  /// Takes the key from the statue, unlocks the door, enters the hall and
  /// takes the letter.
  Future<void> playTheVilla(SceneBloc bloc) async {
    await bloc.tap('statue');
    await bloc.tap('statue_key');
    await bloc.back();
    await bloc.tap('door');
    await bloc.tap('lock', usingItemId: 'brass_key');
    await bloc.tap('doorway');
    await bloc.tap('desk_paper');
  }

  test('the first start begins a new game and stores it', () async {
    final session = await open();
    expect(session.bloc.sceneId, 'villa_exterior');
    await close(session);

    final again = await open();

    expect(again.bloc.sceneId, 'villa_exterior');
    // The opening line was said once, not again on the second start.
    expect(again.progress.chatLog, hasLength(1));
  });

  test('after closing and reopening everything is where it was: the door '
      'open, the key used, the letter in the notebook', () async {
    final first = await open();
    await playTheVilla(first.bloc);
    final before = first.progress;
    await close(first);

    final second = await open();

    final after = second.progress;
    expect(after, before);
    expect(after.caseId, ContentPaths.defaultCaseId);
    expect(after.sceneStack, [
      'villa_exterior',
      'villa_door_closeup',
      'villa_hall',
    ]);
    expect(after.hasFlag('front_door_open'), isTrue);
    expect(after.hasItem('brass_key'), isFalse);
    expect(after.hasNote('hall_letter'), isTrue);
    expect(after.unreadNoteCount, 1);
    expect(after.isHotspotHidden('statue_closeup', 'statue_key'), isTrue);
    expect(after.isHotspotHidden('villa_hall', 'desk_paper'), isTrue);
    expect(after.visitedSceneIds, contains('statue_closeup'));
    expect(after.chatLog, before.chatLog);
    expect(after.chatLog, isNotEmpty);

    // The scene on screen follows: the hall, without the letter, with Back.
    expect(second.bloc.sceneId, 'villa_hall');
    expect(second.bloc.hotspotIds, isNot(contains('desk_paper')));
    expect(second.bloc.state.canGoBack, isTrue);
  });

  test('the reopened game goes on and is saved again', () async {
    final first = await open();
    await playTheVilla(first.bloc);
    await close(first);

    final second = await open();
    await second.bloc.back();
    await second.bloc.back();
    // The letter made the signpost to the market appear.
    await second.bloc.tap('market_sign');
    await close(second);

    final third = await open();

    expect(third.bloc.sceneId, 'market_square');
    expect(third.progress.hasNote('hall_letter'), isTrue);
    expect(third.bloc.state.canGoBack, isFalse);
  });

  test('a note that was read stays read (the one write outside the effect '
      'pipeline)', () async {
    final first = await open();
    await playTheVilla(first.bloc);
    await MarkNoteRead(first.repository)('hall_letter');
    await close(first);

    final second = await open();

    expect(second.progress.unreadNoteCount, 0);
  });

  group('an app that is killed without warning', () {
    test('has everything on disk that is older than the write delay', () async {
      final first = await open();
      await playTheVilla(first.bloc);
      final before = first.progress;
      await Future<void>.delayed(_Session.writeDelay * 3);

      final second = await open(diskSnapshot());

      expect(second.progress, before);
      expect(second.bloc.sceneId, 'villa_hall');
    });

    test('loses at most the change of the last moment, and what is on disk '
        'is a complete earlier state', () async {
      final first = await open();
      await first.bloc.tap('statue');
      await first.bloc.tap('statue_key');
      final withKey = first.progress;
      await Future<void>.delayed(_Session.writeDelay * 3);

      await first.bloc.back();
      final disk = diskSnapshot();

      final second = await open(disk);
      expect(second.progress, withKey);
      expect(second.bloc.sceneId, 'statue_closeup');
      expect(second.progress.hasItem('brass_key'), isTrue);
    });
  });

  test('the play time adds up over several sessions and skips the time '
      'the app was closed', () async {
    final first = await open();
    playClock += const Duration(minutes: 2);
    await close(first);

    // A night passes; nobody is playing.
    playClock += const Duration(hours: 10);

    final second = await open();
    expect(second.progress.playTimeSeconds, 120);
    playClock += const Duration(seconds: 45);
    await close(second);

    final third = await open();
    expect(third.progress.playTimeSeconds, 165);
  });

  test('the save file holds one row that grows in revision', () async {
    final first = await open();
    await playTheVilla(first.bloc);
    await close(first);

    final second = await open();
    final rows = await second.database.select(second.database.saveSlots).get();

    expect(rows, hasLength(1));
    expect(rows.single.localRevision, greaterThanOrEqualTo(1));
    expect(rows.single.sceneId, 'villa_hall');
    expect(rows.single.chapterId, 'ch01');
    expect(rows.single.isDirty, isTrue);
    expect(await second.database.saveSlotsDao.readBackups(), isEmpty);
  });
}
