import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_view_resolver.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/dialogue_fixtures.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  const resolver = DialogueViewResolver();

  List<String> ids(DialogueDefinition dialogue, GameProgress progress) => [
    for (final view in resolver.visibleTopics(dialogue, progress))
      view.topic.id,
  ];

  group('visibility = asked OR (no trigger AND visibleWhen holds)', () {
    // One topic per combination of condition and trigger.
    const plain = DialogueTopic(id: 'plain', promptKey: 'q', answer: ['a']);
    const guarded = DialogueTopic(
      id: 'guarded',
      promptKey: 'q',
      answer: ['a'],
      visibleWhen: HasItem(pillBottle),
    );
    const shown = DialogueTopic(
      id: 'shown',
      promptKey: 'q',
      answer: ['a'],
      trigger: ShowItem(pillBottle),
    );
    const shownAndGuarded = DialogueTopic(
      id: 'shown_guarded',
      promptKey: 'q',
      answer: ['a'],
      trigger: ShowNote(hallLetter),
      visibleWhen: FlagSet('trusts_me'),
    );
    const dialogue = DialogueDefinition(
      id: 'witness',
      nameKey: 'name',
      portrait: DialoguePortrait(placeholderStyle: 'plain'),
      greeting: DialogueGreeting('hello'),
      noReactionKey: 'no_reaction',
      topics: [plain, guarded, shown, shownAndGuarded],
    );

    // A progress in which every condition of the topics above holds.
    final conditionsHold = newGame.withItem(pillBottle).withFlag('trusts_me');

    // topic, was it asked, does its condition hold → is it visible
    final table = <(DialogueTopic, {bool asked, bool holds, bool visible})>[
      (plain, asked: false, holds: true, visible: true),
      (plain, asked: true, holds: true, visible: true),
      (guarded, asked: false, holds: false, visible: false),
      (guarded, asked: false, holds: true, visible: true),
      (guarded, asked: true, holds: false, visible: true),
      (guarded, asked: true, holds: true, visible: true),
      (shown, asked: false, holds: true, visible: false),
      (shown, asked: true, holds: true, visible: true),
      (shownAndGuarded, asked: false, holds: false, visible: false),
      (shownAndGuarded, asked: false, holds: true, visible: false),
      (shownAndGuarded, asked: true, holds: false, visible: true),
      (shownAndGuarded, asked: true, holds: true, visible: true),
    ];

    for (final (topic, :asked, :holds, :visible) in table) {
      test('${topic.id}: asked=$asked, condition holds=$holds → '
          '${visible ? 'visible' : 'hidden'}', () {
        var progress = holds ? conditionsHold : newGame;
        if (asked) progress = progress.withAskedTopic('witness', topic.id);

        expect(resolver.isVisible(dialogue, topic, progress), visible);
      });
    }

    test('an asked topic of another dialogue does not count', () {
      final progress = newGame.withAskedTopic('stranger', 'shown');

      expect(resolver.isVisible(dialogue, shown, progress), isFalse);
    });
  });

  group('the question list', () {
    test('a new game: the fixed topics, in content order, all new', () {
      final views = resolver.visibleTopics(pharmacist, newGame);

      expect(views.map((view) => view.topic.id), [
        'about_villa',
        'about_night',
      ]);
      expect(views.every((view) => view.isNew), isTrue);
      expect(views.any((view) => view.isAsked), isFalse);
    });

    test('carrying the bottle adds the question about the pills', () {
      expect(ids(pharmacist, newGame.withItem(pillBottle)), [
        'about_villa',
        'about_night',
        'ask_pills',
      ]);
    });

    test('an asked topic is marked asked, the others stay new', () {
      final progress = newGame.withAskedTopic('pharmacist', 'about_villa');

      final views = resolver.visibleTopics(pharmacist, progress);

      expect(views.first.isAsked, isTrue);
      expect(views.first.isNew, isFalse);
      expect(views.last.isNew, isTrue);
    });

    test('after the bottle was handed over: the asked question about the '
        'pills stays and the hand-over is listed as asked', () {
      // Asked about the pills, then gave the bottle away.
      final progress = newGame
          .withAskedTopic('pharmacist', 'ask_pills')
          .withAskedTopic('pharmacist', 'give_pills');

      final views = resolver.visibleTopics(pharmacist, progress);

      expect(views.map((view) => view.topic.id), [
        'about_villa',
        'about_night',
        'ask_pills',
        'give_pills',
      ]);
      expect(views[2].isAsked, isTrue);
      expect(views[3].isAsked, isTrue);
    });

    test('a question about the pills that was never asked is gone with '
        'the bottle', () {
      final progress = newGame.withAskedTopic('pharmacist', 'give_pills');

      expect(ids(pharmacist, progress), [
        'about_villa',
        'about_night',
        'give_pills',
      ]);
    });

    test('a dialogue without topics has an empty list', () {
      const silent = DialogueDefinition(
        id: 'silent',
        nameKey: 'name',
        portrait: DialoguePortrait(placeholderStyle: 'plain'),
        greeting: DialogueGreeting('hello'),
        noReactionKey: 'no_reaction',
      );

      expect(resolver.visibleTopics(silent, newGame), isEmpty);
    });
  });

  group('the greeting', () {
    test('first form until it was heard, then the second form', () {
      expect(resolver.greetingKey(pharmacist, newGame), 'pharmacist_hello');
      expect(
        resolver.greetingKey(
          pharmacist,
          newGame.withSpokenLine('pharmacist_hello'),
        ),
        'pharmacist_again',
      );
    });

    test('a greeting with one form never changes', () {
      expect(
        resolver.greetingKey(
          cafeOwner,
          newGame.withSpokenLine('cafe_owner_hello'),
        ),
        'cafe_owner_hello',
      );
    });
  });

  test('entities compare by value and find their topics', () {
    expect(pharmacist.topic('ask_pills')!.promptKey, 'q_pills');
    expect(pharmacist.topic('unknown'), isNull);
    expect(const ShowItem(pillBottle), const ShowItem(pillBottle));
    expect(const ShowItem('a'), isNot(const ShowNote('a')));
    expect(
      const DialogueGreeting('a', thenKey: 'b'),
      isNot(const DialogueGreeting('a')),
    );
  });
}
