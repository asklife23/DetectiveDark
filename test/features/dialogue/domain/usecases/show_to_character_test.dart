import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/ask_topic.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dialogue_fixtures.dart';
import '../../../../helpers/game_harness.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  late DialogueHarness game;

  setUp(() => game = DialogueHarness());
  tearDown(() => game.dispose());

  const letter = CollectedNote(noteId: hallLetter, addedAtUtcMs: 1);
  final withBottle = newGame.withItem(pillBottle);
  final withLetter = newGame.withNote(letter);

  Future<TopicReply> show(
    DialogueDefinition dialogue,
    TopicTrigger shown,
    GameProgress progress,
  ) async {
    final reply = await game.showToCharacter(
      dialogue: dialogue,
      shown: shown,
      progress: progress,
      triggers: const [bothAskedAboutVilla],
    );
    await pumpEventQueue();
    return reply.valueOrNull!;
  }

  group('giving an item', () {
    test(
      'the matching topic plays: answer, effects, asked mark, one save',
      () async {
        final reply = await show(
          pharmacist,
          const ShowItem(pillBottle),
          withBottle,
        );

        expect(reply.lineKeys, ['give_1', 'give_2']);
        expect(reply.isFirstTime, isTrue);
        // Handing over is a consumeItem among the effects of the topic.
        expect(reply.progress.hasItem(pillBottle), isFalse);
        expect(reply.progress.hasAsked('pharmacist', 'give_pills'), isTrue);
        expect(
          reply.progress.hasNoteEntry('person_pharmacist', 'prescribed'),
          isTrue,
        );
        expect(game.saves, [reply.progress]);
        expect(game.events, const [
          TopicAsked('pharmacist', 'give_pills'),
          NoteAdded('person_pharmacist', sceneId: 'villa_exterior'),
        ]);
      },
    );

    test('an item is shown, not used: no ItemUsed event', () async {
      await show(pharmacist, const ShowItem(pillBottle), withBottle);

      expect(game.events.whereType<ItemUsed>(), isEmpty);
    });

    test('an item the player does not carry cannot be shown', () async {
      final reply = await show(pharmacist, const ShowItem(pillBottle), newGame);

      expect(reply.lineKeys, isEmpty);
      expect(reply.progress, same(newGame));
      expect(game.saves, isEmpty);
      expect(game.events, isEmpty);
    });

    test('once given away it cannot be given again', () async {
      final given = await show(
        pharmacist,
        const ShowItem(pillBottle),
        withBottle,
      );
      game.events.clear();

      final again = await show(
        pharmacist,
        const ShowItem(pillBottle),
        given.progress,
      );

      expect(again.lineKeys, isEmpty);
      expect(again.progress, same(given.progress));
      expect(game.events, isEmpty);
    });
  });

  group('showing a note', () {
    test('the matching topic plays; the note stays in the notebook', () async {
      final reply = await show(
        cafeOwner,
        const ShowNote(hallLetter),
        withLetter,
      );

      expect(reply.lineKeys, ['letter_1']);
      expect(reply.progress.hasNote(hallLetter), isTrue);
      expect(reply.progress.hasAsked('cafe_owner', 'show_letter'), isTrue);
      expect(game.events, const [TopicAsked('cafe_owner', 'show_letter')]);
    });

    test('showing it again only replays the answer', () async {
      final first = await show(
        cafeOwner,
        const ShowNote(hallLetter),
        withLetter,
      );
      game.events.clear();

      final again = await show(
        cafeOwner,
        const ShowNote(hallLetter),
        first.progress,
      );

      expect(again.lineKeys, ['letter_1']);
      expect(again.isFirstTime, isFalse);
      expect(again.progress, same(first.progress));
      expect(game.saves, hasLength(1));
      expect(game.events, isEmpty);
    });

    test('a note the player does not have cannot be shown', () async {
      final reply = await show(cafeOwner, const ShowNote(hallLetter), newGame);

      expect(reply.lineKeys, isEmpty);
      expect(game.saves, isEmpty);
    });
  });

  group('no reaction', () {
    test('evidence that means nothing gets the shrug of the character: '
        'nothing changes, nothing is saved, no event', () async {
      // The pharmacist has no topic for the letter.
      final reply = await show(
        pharmacist,
        const ShowNote(hallLetter),
        withLetter,
      );

      expect(reply.lineKeys, ['pharmacist_no_reaction']);
      expect(reply.isFirstTime, isFalse);
      expect(reply.progress, same(withLetter));
      expect(game.saves, isEmpty);
      expect(game.events, isEmpty);
    });

    test('an item nobody asks for gets the shrug too', () async {
      final reply = await show(
        cafeOwner,
        const ShowItem(pillBottle),
        withBottle,
      );

      expect(reply.lineKeys, ['cafe_owner_no_reaction']);
      expect(reply.progress.hasItem(pillBottle), isTrue);
    });

    test('an item is not a note with the same ID', () async {
      final progress = newGame.withItem(hallLetter);

      final reply = await show(cafeOwner, const ShowItem(hallLetter), progress);

      expect(reply.lineKeys, ['cafe_owner_no_reaction']);
    });
  });

  group('conditions on topics that wait for evidence', () {
    const guarded = DialogueDefinition(
      id: 'guard',
      nameKey: 'name',
      portrait: DialoguePortrait(placeholderStyle: 'plain'),
      greeting: DialogueGreeting('hello'),
      noReactionKey: 'guard_no_reaction',
      topics: [
        // The same evidence, two reactions: before and after he trusts you.
        DialogueTopic(
          id: 'letter_trusted',
          promptKey: 'q',
          answer: ['trusted_answer'],
          trigger: ShowNote(hallLetter),
          visibleWhen: FlagSet('trusts_me'),
          effects: [SetFlag('knows_sender')],
        ),
        DialogueTopic(
          id: 'letter_wary',
          promptKey: 'q',
          answer: ['wary_answer'],
          trigger: ShowNote(hallLetter),
          visibleWhen: FlagNotSet('trusts_me'),
        ),
      ],
    );

    test('the first topic whose condition holds plays', () async {
      final wary = await show(guarded, const ShowNote(hallLetter), withLetter);
      final trusted = await show(
        guarded,
        const ShowNote(hallLetter),
        withLetter.withFlag('trusts_me'),
      );

      expect(wary.lineKeys, ['wary_answer']);
      expect(wary.progress.hasAsked('guard', 'letter_wary'), isTrue);
      expect(trusted.lineKeys, ['trusted_answer']);
      expect(trusted.progress.hasFlag('knows_sender'), isTrue);
    });

    test('no topic whose condition holds: the shrug', () async {
      const onlyTrusted = DialogueDefinition(
        id: 'guard',
        nameKey: 'name',
        portrait: DialoguePortrait(placeholderStyle: 'plain'),
        greeting: DialogueGreeting('hello'),
        noReactionKey: 'guard_no_reaction',
        topics: [
          DialogueTopic(
            id: 'letter_trusted',
            promptKey: 'q',
            answer: ['trusted_answer'],
            trigger: ShowNote(hallLetter),
            visibleWhen: FlagSet('trusts_me'),
          ),
        ],
      );

      final reply = await show(
        onlyTrusted,
        const ShowNote(hallLetter),
        withLetter,
      );

      expect(reply.lineKeys, ['guard_no_reaction']);
      expect(reply.progress.askedTopics, isEmpty);
    });

    test('a topic that already played is replayed even when its condition '
        'no longer holds', () async {
      final first = await show(guarded, const ShowNote(hallLetter), withLetter);

      // Now he trusts the detective: `letter_wary` no longer holds, but it
      // comes after `letter_trusted`, which plays for the first time.
      final later = await show(
        guarded,
        const ShowNote(hallLetter),
        first.progress.withFlag('trusts_me'),
      );
      // With both played, the first one in the list is replayed.
      final replay = await show(
        guarded,
        const ShowNote(hallLetter),
        later.progress,
      );

      expect(later.lineKeys, ['trusted_answer']);
      expect(later.isFirstTime, isTrue);
      expect(replay.lineKeys, ['trusted_answer']);
      expect(replay.isFirstTime, isFalse);
    });
  });

  test('showing can complete a trigger of the case', () async {
    const gossip = DialogueDefinition(
      id: 'cafe_owner',
      nameKey: 'name',
      portrait: DialoguePortrait(placeholderStyle: 'plain'),
      greeting: DialogueGreeting('hello'),
      noReactionKey: 'no_reaction',
      topics: [
        DialogueTopic(
          id: 'about_villa',
          promptKey: 'q',
          answer: ['a'],
          trigger: ShowNote(hallLetter),
        ),
      ],
    );
    final progress = withLetter.withAskedTopic('pharmacist', 'about_villa');

    final reply = await show(gossip, const ShowNote(hallLetter), progress);

    expect(reply.progress.firedTriggers, {'both_asked_about_villa'});
    expect(game.saves, hasLength(1));
    expect(
      game.events,
      contains(const DetectiveSaid('say_stories_do_not_match')),
    );
  });

  test('a failed save is reported and nothing is announced', () async {
    final failing = DialogueHarness(
      progressRepository: FailingProgressRepository(stored: withBottle),
    );
    addTearDown(failing.dispose);

    final reply = await failing.showToCharacter(
      dialogue: pharmacist,
      shown: const ShowItem(pillBottle),
      progress: withBottle,
      triggers: const [],
    );
    await pumpEventQueue();

    expect(reply.failureOrNull, isA<StorageFailure>());
    expect(failing.progress.current!.hasItem(pillBottle), isTrue);
    expect(failing.events, isEmpty);
  });
}
