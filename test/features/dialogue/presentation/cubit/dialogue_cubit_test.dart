import 'package:bloc_test/bloc_test.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/dialogue/presentation/cubit/dialogue_cubit.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dialogue_fixtures.dart';
import '../../../../helpers/game_harness.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  late DialogueHarness game;

  /// A cubit that is loaded, with [progress] as the running game.
  Future<DialogueCubit> ready([GameProgress progress = newGame]) async {
    await game.progress.save(progress);
    final cubit = game.createCubit();
    await cubit.load();
    return cubit;
  }

  List<String> topicIds(DialogueCubit cubit) => [
    for (final view in cubit.state.topics)
      '${view.topic.id}${view.isNew ? ' (new)' : ''}',
  ];

  setUp(() => game = DialogueHarness());
  tearDown(() => game.dispose());

  test('starts closed', () async {
    final cubit = await ready();
    addTearDown(cubit.close);

    expect(cubit.state, const DialogueState());
    expect(cubit.state.isOpen, isFalse);
    expect(cubit.state.isSpeaking, isFalse);
    expect(cubit.state.currentLineKey, isNull);
  });

  group('opening', () {
    blocTest<DialogueCubit, DialogueState>(
      'the character greets first: one line, still being typed, the '
      'questions ready behind it',
      build: () => game.createCubit(),
      setUp: () => game.progress.save(newGame),
      act: (cubit) async {
        await cubit.load();
        await cubit.open('pharmacist');
      },
      verify: (cubit) {
        final state = cubit.state;
        expect(state.dialogue, pharmacist);
        expect(state.isOpen, isTrue);
        expect(state.isSpeaking, isTrue);
        expect(state.lineKeys, ['pharmacist_hello']);
        expect(state.currentLineKey, 'pharmacist_hello');
        expect(state.isLineComplete, isFalse);
        expect(state.isLastLine, isTrue);
        expect(topicIds(cubit), ['about_villa (new)', 'about_night (new)']);
      },
    );

    test('the first greeting is remembered: the second visit is greeted '
        'with the other line', () async {
      final cubit = await ready();
      addTearDown(cubit.close);

      await cubit.open('pharmacist');
      cubit.leave();
      await cubit.open('pharmacist');

      expect(cubit.state.currentLineKey, 'pharmacist_again');
      expect(game.progress.current!.spokenLines, {'pharmacist_hello'});
    });

    test('an unknown dialogue opens nothing', () async {
      final cubit = await ready();
      addTearDown(cubit.close);

      await cubit.open('butcher');

      expect(cubit.state.isOpen, isFalse);
    });

    test('before a game exists nothing opens', () async {
      final cubit = game.createCubit();
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.open('pharmacist');

      expect(cubit.state.isOpen, isFalse);
    });

    test('with the bottle in hand the question about the pills is on '
        'offer', () async {
      final cubit = await ready(newGame.withItem(pillBottle));
      addTearDown(cubit.close);

      await cubit.open('pharmacist');

      expect(topicIds(cubit), [
        'about_villa (new)',
        'about_night (new)',
        'ask_pills (new)',
      ]);
    });
  });

  group('advancing through lines', () {
    /// Open, with the greeting read and the question list on screen.
    Future<DialogueCubit> choosing([GameProgress progress = newGame]) async {
      final cubit = await ready(progress);
      await cubit.open('pharmacist');
      cubit
        ..advance()
        ..advance();
      expect(cubit.state.isSpeaking, isFalse);
      return cubit;
    }

    test('a tap on a line that is being typed completes it', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      await cubit.open('pharmacist');

      cubit.advance();

      expect(cubit.state.isLineComplete, isTrue);
      expect(cubit.state.currentLineKey, 'pharmacist_hello');
    });

    test('the typewriter reaching the end completes it too', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      await cubit.open('pharmacist');

      cubit.lineTyped();
      final complete = cubit.state;
      cubit.lineTyped();

      expect(complete.isLineComplete, isTrue);
      expect(cubit.state, same(complete));
    });

    test('a tap on the complete last line returns to the questions', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      await cubit.open('pharmacist');

      cubit
        ..lineTyped()
        ..advance();

      expect(cubit.state.isOpen, isTrue);
      expect(cubit.state.isSpeaking, isFalse);
      expect(cubit.state.lineKeys, isEmpty);
      expect(cubit.state.topics, hasLength(2));
    });

    blocTest<DialogueCubit, DialogueState>(
      'an answer of two lines: complete, next, complete, back to the list',
      build: () => game.createCubit(),
      setUp: () => game.progress.save(newGame),
      act: (cubit) async {
        await cubit.load();
        await cubit.open('pharmacist');
        cubit
          ..advance()
          ..advance();
        await cubit.ask('about_villa');
        cubit
          ..advance() // completes "villa_1"
          ..advance() // shows "villa_2"
          ..advance() // completes "villa_2"
          ..advance(); // back to the questions
      },
      // greeting, complete, list; then the progress stream reports the save
      // of the greeting and of the question in between.
      verify: (cubit) {
        expect(cubit.state.isSpeaking, isFalse);
        expect(topicIds(cubit), ['about_villa', 'about_night (new)']);
      },
    );

    test('the lines of an answer come one at a time', () async {
      final cubit = await choosing();
      addTearDown(cubit.close);

      await cubit.ask('about_villa');
      expect(cubit.state.currentLineKey, 'villa_1');
      expect(cubit.state.isLineComplete, isFalse);
      expect(cubit.state.isLastLine, isFalse);

      cubit.advance();
      expect(cubit.state.currentLineKey, 'villa_1');
      expect(cubit.state.isLineComplete, isTrue);

      cubit.advance();
      expect(cubit.state.currentLineKey, 'villa_2');
      expect(cubit.state.isLineComplete, isFalse);
      expect(cubit.state.isLastLine, isTrue);

      cubit
        ..advance()
        ..advance();
      expect(cubit.state.isSpeaking, isFalse);
    });

    test('advance does nothing while the player chooses', () async {
      final cubit = await choosing();
      addTearDown(cubit.close);
      final before = cubit.state;

      cubit
        ..advance()
        ..lineTyped();

      expect(cubit.state, same(before));
    });
  });

  group('asking', () {
    Future<DialogueCubit> choosing([GameProgress progress = newGame]) async {
      final cubit = await ready(progress);
      await cubit.open('pharmacist');
      cubit
        ..advance()
        ..advance();
      return cubit;
    }

    Future<void> readAnswer(DialogueCubit cubit) async {
      while (cubit.state.isSpeaking) {
        cubit.advance();
      }
      await pumpEventQueue();
    }

    test('a question that was asked is marked asked, the others stay '
        'new', () async {
      final cubit = await choosing();
      addTearDown(cubit.close);

      await cubit.ask('about_villa');
      await readAnswer(cubit);

      expect(topicIds(cubit), ['about_villa', 'about_night (new)']);
      expect(
        game.progress.current!.hasAsked('pharmacist', 'about_villa'),
        isTrue,
      );
    });

    test('asking again replays the answer and changes nothing', () async {
      final cubit = await choosing();
      addTearDown(cubit.close);
      await cubit.ask('about_villa');
      await readAnswer(cubit);
      final saved = game.progress.current;
      game.events.clear();

      await cubit.ask('about_villa');

      expect(cubit.state.lineKeys, ['villa_1', 'villa_2']);
      await readAnswer(cubit);
      expect(game.progress.current, same(saved));
      expect(game.events, isEmpty);
    });

    test('a question cannot be asked while the character speaks', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      await cubit.open('pharmacist');

      await cubit.ask('about_villa');

      expect(cubit.state.currentLineKey, 'pharmacist_hello');
      expect(game.progress.current!.askedTopics, isEmpty);
    });

    test('a question that is not on offer does nothing', () async {
      final cubit = await choosing();
      addTearDown(cubit.close);

      await cubit.ask('ask_pills');
      await cubit.ask('give_pills');
      await cubit.ask('about_the_weather');

      expect(cubit.state.isSpeaking, isFalse);
      expect(game.progress.current!.askedTopics, isEmpty);
    });

    test('nothing can be asked while the panel is closed', () async {
      final cubit = await ready();
      addTearDown(cubit.close);

      await cubit.ask('about_villa');

      expect(cubit.state.isOpen, isFalse);
      expect(game.progress.current!.askedTopics, isEmpty);
    });

    test(
      'the comment of the detective is announced for the message bar',
      () async {
        final cubit = await choosing(newGame.withItem(pillBottle));
        addTearDown(cubit.close);

        await cubit.ask('ask_pills');
        await pumpEventQueue();

        expect(
          game.events,
          contains(const DetectiveSaid('say_pills_owner_known')),
        );
      },
    );

    test(
      'the second "about the villa" fires the trigger of the case',
      () async {
        final cubit = await choosing();
        addTearDown(cubit.close);
        await cubit.ask('about_villa');
        await readAnswer(cubit);
        cubit.leave();

        await cubit.open('cafe_owner');
        await readAnswer(cubit);
        await cubit.ask('about_villa');
        await pumpEventQueue();

        expect(game.progress.current!.firedTriggers, {
          'both_asked_about_villa',
        });
        expect(
          game.events,
          contains(const DetectiveSaid('say_stories_do_not_match')),
        );
      },
    );
  });

  group('following the progress', () {
    test('a question appears while the panel is open, when its condition '
        'starts to hold', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      await cubit.open('pharmacist');
      cubit
        ..advance()
        ..advance();
      expect(topicIds(cubit), hasLength(2));

      await game.progress.save(game.progress.current!.withItem(pillBottle));
      await pumpEventQueue();

      expect(topicIds(cubit), contains('ask_pills (new)'));
    });

    test('a change of the progress while the panel is closed opens '
        'nothing', () async {
      final cubit = await ready();
      addTearDown(cubit.close);

      await game.progress.save(newGame.withItem(pillBottle));
      await pumpEventQueue();

      expect(cubit.state, const DialogueState());
    });
  });

  group('leaving', () {
    test('closes the panel and saves nothing', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      await cubit.open('pharmacist');
      final saved = game.progress.current;

      cubit.leave();

      expect(cubit.state, const DialogueState());
      expect(game.progress.current, same(saved));
    });

    test('leaving a closed panel does nothing', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      final before = cubit.state;

      cubit.leave();

      expect(cubit.state, same(before));
    });

    test('a conversation left in the middle of an answer starts clean '
        'next time', () async {
      final cubit = await ready();
      addTearDown(cubit.close);
      await cubit.open('pharmacist');
      cubit
        ..advance()
        ..advance();
      await cubit.ask('about_villa');

      cubit.leave();
      await cubit.open('cafe_owner');

      expect(cubit.state.dialogue, cafeOwner);
      expect(cubit.state.lineKeys, ['cafe_owner_hello']);
      expect(cubit.state.lineIndex, 0);
    });
  });

  group('failures', () {
    test(
      'a catalog that cannot be loaded: nothing opens',
      () async {
        await game.progress.save(newGame);
        final cubit = DialogueCubit(
          catalogRepository: const FixedDialogueCatalog(
            [],
            failure: ContentFailure('dialogues.json: broken'),
          ),
          contentRepository: const FixedSceneContent(),
          progressRepository: game.progress,
          startConversation: game.startConversation,
          askTopic: game.askTopic,
          caseId: 'case01',
        );
        addTearDown(cubit.close);

        await cubit.load();
        await cubit.open('pharmacist');

        expect(cubit.state.isOpen, isFalse);
      },
    );

    test(
      'a failed save keeps the panel closed',
      () async {
        final failing = DialogueHarness(
          progressRepository: FailingProgressRepository(stored: newGame),
        );
        addTearDown(failing.dispose);
        final cubit = failing.createCubit();
        addTearDown(cubit.close);
        await cubit.load();

        await cubit.open('pharmacist');

        expect(cubit.state.isOpen, isFalse);
      },
    );
  });
}
