import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/condition_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  const evaluator = ConditionEvaluator();
  final progress = newGame
      .withFlag('door_open')
      .withItem(brassKey)
      .withNote(const CollectedNote(noteId: 'letter', addedAtUtcMs: 1));

  test('flag: true only when the flag is set', () {
    expect(evaluator.evaluate(const FlagSet('door_open'), progress), isTrue);
    expect(evaluator.evaluate(const FlagSet('other'), progress), isFalse);
  });

  test('notFlag: true only while the flag is not set', () {
    expect(evaluator.evaluate(const FlagNotSet('other'), progress), isTrue);
    expect(
      evaluator.evaluate(const FlagNotSet('door_open'), progress),
      isFalse,
    );
  });

  test('hasItem: true while the item is carried', () {
    expect(evaluator.evaluate(const HasItem(brassKey), progress), isTrue);
    expect(evaluator.evaluate(const HasItem(crowbar), progress), isFalse);
  });

  test('usingItem: true only for the selected item', () {
    const condition = UsingItem(brassKey);

    expect(
      evaluator.evaluate(condition, progress, usingItemId: brassKey),
      isTrue,
    );
    expect(
      evaluator.evaluate(condition, progress, usingItemId: crowbar),
      isFalse,
    );
    expect(evaluator.evaluate(condition, progress), isFalse);
  });

  test('hasNote: true when the note was collected', () {
    expect(evaluator.evaluate(const HasNote('letter'), progress), isTrue);
    expect(evaluator.evaluate(const HasNote('photo'), progress), isFalse);
  });

  test('all: every condition must hold', () {
    expect(
      evaluator.evaluate(
        const AllOf([FlagSet('door_open'), HasItem(brassKey)]),
        progress,
      ),
      isTrue,
    );
    expect(
      evaluator.evaluate(
        const AllOf([FlagSet('door_open'), HasItem(crowbar)]),
        progress,
      ),
      isFalse,
    );
  });

  test('any: one condition is enough', () {
    expect(
      evaluator.evaluate(
        const AnyOf([FlagSet('other'), HasItem(brassKey)]),
        progress,
      ),
      isTrue,
    );
    expect(
      evaluator.evaluate(
        const AnyOf([FlagSet('other'), HasItem(crowbar)]),
        progress,
      ),
      isFalse,
    );
  });

  test('conditions nest and pass the selected item down', () {
    const condition = AllOf([
      FlagSet('door_open'),
      AnyOf([UsingItem(crowbar), UsingItem(brassKey)]),
    ]);

    expect(
      evaluator.evaluate(condition, progress, usingItemId: brassKey),
      isTrue,
    );
    expect(evaluator.evaluate(condition, progress), isFalse);
  });

  test('holds: an absent condition is true', () {
    expect(evaluator.holds(null, progress), isTrue);
    expect(evaluator.holds(const FlagSet('other'), progress), isFalse);
  });
}
