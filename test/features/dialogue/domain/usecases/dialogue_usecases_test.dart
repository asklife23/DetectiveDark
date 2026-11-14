import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/dialogue/data/repositories/asset_dialogue_catalog_repository.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_view_resolver.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/data/models/codec_rule_parser.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dialogue_fixtures.dart';
import '../../../../helpers/game_app.dart';
import '../../../../helpers/game_harness.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  late DialogueHarness game;

  setUp(() => game = DialogueHarness());
  tearDown(() => game.dispose());

  const triggers = [bothAskedAboutVilla];

  group('AskTopic', () {
    Future<GameProgress> ask(
      DialogueDefinition dialogue,
      String topicId,
      GameProgress progress,
    ) async {
      final reply = await game.askTopic(
        dialogue: dialogue,
        topicId: topicId,
        progress: progress,
        triggers: triggers,
      );
      await pumpEventQueue();
      return reply.valueOrNull!.progress;
    }

    test('the first time: the answer, the effects, the asked mark and the '
        'event, in one save', () async {
      final reply = (await game.askTopic(
        dialogue: pharmacist,
        topicId: 'about_villa',
        progress: newGame,
        triggers: triggers,
      )).valueOrNull!;
      await pumpEventQueue();

      expect(reply.lineKeys, ['villa_1', 'villa_2']);
      expect(reply.isFirstTime, isTrue);
      expect(reply.progress.hasAsked('pharmacist', 'about_villa'), isTrue);
      expect(reply.progress.askedTopics, {'pharmacist/about_villa'});
      expect(
        reply.progress.hasNoteEntry('person_pharmacist', 'knows'),
        isTrue,
      );
      expect(game.saves, [reply.progress]);
      expect(game.events, const [
        TopicAsked('pharmacist', 'about_villa'),
        NoteAdded('person_pharmacist', sceneId: 'villa_exterior'),
      ]);
    });

    test(
      'asking again: the same answer, no change, no save, no event',
      () async {
        final asked = await ask(pharmacist, 'about_villa', newGame);
        game.events.clear();

        final again = (await game.askTopic(
          dialogue: pharmacist,
          topicId: 'about_villa',
          progress: asked,
          triggers: triggers,
        )).valueOrNull!;
        await pumpEventQueue();

        expect(again.lineKeys, ['villa_1', 'villa_2']);
        expect(again.isFirstTime, isFalse);
        expect(again.progress, same(asked));
        expect(game.saves, hasLength(1));
        expect(game.events, isEmpty);
      },
    );

    test('a topic without effects is still remembered as asked', () async {
      final progress = await ask(pharmacist, 'about_night', newGame);

      expect(progress.hasAsked('pharmacist', 'about_night'), isTrue);
      expect(game.events, const [TopicAsked('pharmacist', 'about_night')]);
    });

    test('a topic hidden by its condition does nothing', () async {
      final reply = (await game.askTopic(
        dialogue: pharmacist,
        topicId: 'ask_pills',
        progress: newGame,
        triggers: triggers,
      )).valueOrNull!;
      await pumpEventQueue();

      expect(reply.lineKeys, isEmpty);
      expect(reply.progress, same(newGame));
      expect(game.saves, isEmpty);
      expect(game.events, isEmpty);
    });

    test('a topic that waits for evidence cannot be asked', () async {
      final reply = (await game.askTopic(
        dialogue: pharmacist,
        topicId: 'give_pills',
        progress: newGame.withItem(pillBottle),
        triggers: triggers,
      )).valueOrNull!;

      expect(reply.lineKeys, isEmpty);
      expect(reply.progress.hasItem(pillBottle), isTrue);
    });

    test('an unknown topic does nothing', () async {
      final reply = (await game.askTopic(
        dialogue: pharmacist,
        topicId: 'about_the_weather',
        progress: newGame,
        triggers: triggers,
      )).valueOrNull!;

      expect(reply.lineKeys, isEmpty);
      expect(game.saves, isEmpty);
    });

    test('the comment of the detective is a say effect: it goes to the '
        'message history, the lines of the character do not', () async {
      final progress = await ask(
        pharmacist,
        'ask_pills',
        newGame.withItem(pillBottle),
      );

      expect(progress.chatLog.map((entry) => entry.textKey), [
        'say_pills_owner_known',
      ]);
      expect(game.events, const [
        TopicAsked('pharmacist', 'ask_pills'),
        DetectiveSaid('say_pills_owner_known'),
      ]);
    });

    test(
      'play runs a topic that waits for evidence (used by showing)',
      () async {
        final reply = (await game.askTopic.play(
          dialogue: pharmacist,
          topic: pharmacist.topic('give_pills')!,
          progress: newGame.withItem(pillBottle),
          triggers: triggers,
        )).valueOrNull!;

        expect(reply.lineKeys, ['give_1', 'give_2']);
        expect(reply.progress.hasItem(pillBottle), isFalse);
        expect(reply.progress.hasAsked('pharmacist', 'give_pills'), isTrue);
      },
    );

    group('triggers', () {
      test('the second "about the villa" fires the trigger once, in the '
          'same save as the question', () async {
        var progress = await ask(cafeOwner, 'about_villa', newGame);
        expect(progress.firedTriggers, isEmpty);
        game.events.clear();

        progress = await ask(pharmacist, 'about_villa', progress);

        expect(progress.firedTriggers, {'both_asked_about_villa'});
        expect(progress.hasNote('obs_stories'), isTrue);
        expect(game.saves, hasLength(2));
        expect(game.saves.last, progress);
        expect(game.events, const [
          TopicAsked('pharmacist', 'about_villa'),
          NoteAdded('person_pharmacist', sceneId: 'villa_exterior'),
          DetectiveSaid('say_stories_do_not_match'),
          NoteAdded('obs_stories', sceneId: 'villa_exterior'),
        ]);
      });

      test('the order of the two questions does not matter', () async {
        var progress = await ask(pharmacist, 'about_villa', newGame);
        progress = await ask(cafeOwner, 'about_villa', progress);

        expect(progress.firedTriggers, {'both_asked_about_villa'});
      });

      test('asking either of them again does not fire it again', () async {
        var progress = await ask(cafeOwner, 'about_villa', newGame);
        progress = await ask(pharmacist, 'about_villa', progress);
        game.events.clear();

        progress = await ask(pharmacist, 'about_villa', progress);
        progress = await ask(cafeOwner, 'about_villa', progress);

        expect(game.events, isEmpty);
        expect(
          progress.chatLog.where(
            (entry) => entry.textKey == 'say_stories_do_not_match',
          ),
          hasLength(1),
        );
      });
    });

    test('a failed save: Failed, nothing asked, no event', () async {
      final failing = DialogueHarness(
        progressRepository: FailingProgressRepository(stored: newGame),
      );
      addTearDown(failing.dispose);

      final reply = await failing.askTopic(
        dialogue: pharmacist,
        topicId: 'about_villa',
        progress: newGame,
        triggers: triggers,
      );
      await pumpEventQueue();

      expect(reply.failureOrNull, isA<StorageFailure>());
      expect(failing.progress.current!.askedTopics, isEmpty);
      expect(failing.events, isEmpty);
    });
  });

  group('StartConversation', () {
    test(
      'the first time: the first greeting, remembered in one save',
      () async {
        final start = (await game.startConversation(
          dialogue: pharmacist,
          progress: newGame,
          triggers: triggers,
        )).valueOrNull!;
        await pumpEventQueue();

        expect(start.greetingKey, 'pharmacist_hello');
        expect(start.progress.spokenLines, {'pharmacist_hello'});
        expect(game.saves, [start.progress]);
        // A greeting is not the inner voice: no message, no event.
        expect(start.progress.chatLog, isEmpty);
        expect(game.events, isEmpty);
      },
    );

    test('every later time: the second greeting, nothing to save', () async {
      final first = (await game.startConversation(
        dialogue: pharmacist,
        progress: newGame,
        triggers: triggers,
      )).valueOrNull!;

      final second = (await game.startConversation(
        dialogue: pharmacist,
        progress: first.progress,
        triggers: triggers,
      )).valueOrNull!;
      final third = (await game.startConversation(
        dialogue: pharmacist,
        progress: second.progress,
        triggers: triggers,
      )).valueOrNull!;
      await pumpEventQueue();

      expect(second.greetingKey, 'pharmacist_again');
      expect(third.greetingKey, 'pharmacist_again');
      expect(third.progress, same(first.progress));
      expect(game.saves, hasLength(1));
    });

    test('a greeting with one form is not remembered', () async {
      final start = (await game.startConversation(
        dialogue: cafeOwner,
        progress: newGame,
        triggers: triggers,
      )).valueOrNull!;
      await pumpEventQueue();

      expect(start.greetingKey, 'cafe_owner_hello');
      expect(start.progress, same(newGame));
      expect(game.saves, isEmpty);
    });

    test('opening a conversation goes through the pipeline: a trigger '
        'that waits for the greeting fires', () async {
      final heardHello = TriggerDefinition(
        id: 'met_the_pharmacist',
        // Stands in for any condition the greeting can complete.
        when: bothAskedAboutVilla.when,
        effects: bothAskedAboutVilla.effects,
      );
      final ready = newGame
          .withAskedTopic('pharmacist', 'about_villa')
          .withAskedTopic('cafe_owner', 'about_villa');

      final start = (await game.startConversation(
        dialogue: pharmacist,
        progress: ready,
        triggers: [heardHello],
      )).valueOrNull!;
      await pumpEventQueue();

      expect(start.progress.firedTriggers, {'met_the_pharmacist'});
      expect(game.saves, hasLength(1));
    });

    test('a failed save is reported', () async {
      final failing = DialogueHarness(
        progressRepository: FailingProgressRepository(stored: newGame),
      );
      addTearDown(failing.dispose);

      final start = await failing.startConversation(
        dialogue: pharmacist,
        progress: newGame,
        triggers: triggers,
      );

      expect(start.failureOrNull, isA<StorageFailure>());
    });
  });

  group('the market demo, on the real content (acceptance scenario 14–16 '
      'and 19, without the interface)', () {
    late Map<String, DialogueDefinition> dialogues;
    late List<TriggerDefinition> realTriggers;
    const resolver = DialogueViewResolver();

    /// In the market, with the bottle and the letter from the villa.
    final atMarket = newGame
        .withSceneStack(const ['market_square'])
        .withItem('pill_bottle')
        .withNote(const CollectedNote(noteId: 'hall_letter', addedAtUtcMs: 1));

    setUp(() async {
      final source = ContentAssetSource(realContentBundle());
      dialogues = (await AssetDialogueCatalogRepository(
        source,
        const CodecRuleParser(),
      ).loadDialogues('case01')).valueOrNull!;
      realTriggers = (await AssetSceneContentRepository(
        source,
      ).loadCase('case01')).valueOrNull!.triggers;
    });

    Future<GameProgress> ask(
      String dialogueId,
      String topicId,
      GameProgress progress,
    ) async {
      final reply = await game.askTopic(
        dialogue: dialogues[dialogueId]!,
        topicId: topicId,
        progress: progress,
        triggers: realTriggers,
      );
      await pumpEventQueue();
      expect(reply.valueOrNull!.lineKeys, isNotEmpty);
      return reply.valueOrNull!.progress;
    }

    List<String> offered(String dialogueId, GameProgress progress) => [
      for (final view in resolver.visibleTopics(
        dialogues[dialogueId]!,
        progress,
      ))
        '${view.topic.id}${view.isNew ? ' (new)' : ''}',
    ];

    test('14. the café owner offers two questions, both new; asking about '
        'the villa marks the question as asked', () async {
      expect(offered('cafe_owner', atMarket), [
        'about_villa (new)',
        'about_pharmacist (new)',
      ]);

      final progress = await ask('cafe_owner', 'about_villa', atMarket);

      expect(offered('cafe_owner', progress), [
        'about_villa',
        'about_pharmacist (new)',
      ]);
      expect(progress.firedTriggers, isEmpty);
    });

    test('15. the pharmacist offers three questions with the bottle in '
        'hand; asking about the villa adds a line to his file and fires '
        'the trigger once', () async {
      expect(offered('pharmacist', atMarket), [
        'about_villa (new)',
        'about_last_night (new)',
        'ask_pills (new)',
      ]);
      // Without the bottle only the two fixed questions are there.
      expect(offered('pharmacist', newGame), hasLength(2));

      var progress = await ask('cafe_owner', 'about_villa', atMarket);
      game.events.clear();
      progress = await ask('pharmacist', 'about_villa', progress);

      expect(
        progress.hasNoteEntry('person_pharmacist', 'knows_villa'),
        isTrue,
      );
      expect(progress.unreadNoteCount, greaterThan(0));
      expect(progress.firedTriggers, {'both_asked_about_villa'});
      expect(progress.hasNote('obs_stories_do_not_match'), isTrue);
      expect(
        game.events,
        containsAllInOrder(const [
          TopicAsked('pharmacist', 'about_villa'),
          DetectiveSaid('say_stories_do_not_match'),
        ]),
      );

      // Asking again changes nothing.
      game.events.clear();
      final again = await ask('pharmacist', 'about_villa', progress);
      expect(again, same(progress));
      expect(game.events, isEmpty);
    });

    test('16. asking about the pills: the answer and the inner voice of '
        'the detective', () async {
      final progress = await ask('pharmacist', 'ask_pills', atMarket);

      expect(progress.chatLog.last.textKey, 'say_pills_owner_known');
      expect(progress.hasItem('pill_bottle'), isTrue);
    });

    test('19. the second visit is greeted differently; the trigger does '
        'not fire again', () async {
      Future<(String, GameProgress)> open(GameProgress progress) async {
        final start = (await game.startConversation(
          dialogue: dialogues['pharmacist']!,
          progress: progress,
          triggers: realTriggers,
        )).valueOrNull!;
        return (start.greetingKey, start.progress);
      }

      var progress = await ask('cafe_owner', 'about_villa', atMarket);
      final (first, afterFirst) = await open(progress);
      progress = await ask('pharmacist', 'about_villa', afterFirst);
      game.events.clear();
      final (second, afterSecond) = await open(progress);
      await pumpEventQueue();

      expect(first, 'dlg_pharmacist_hello');
      expect(second, 'dlg_pharmacist_again');
      expect(afterSecond, same(progress));
      expect(game.events, isEmpty);
    });
  });
}
