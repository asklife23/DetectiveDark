import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/interaction_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  const resolver = InteractionResolver();
  const genericReaction = [Say(InteractionResolver.genericItemNoEffectKey)];

  group('the villa door lock', () {
    test('without the key the detective says it is locked', () {
      final result = resolver.resolve(lockHotspot, newGame);

      expect(result.effects, const [Say('door_locked')]);
      expect(result.usedItemId, isNull);
    });

    test('carrying the key is not enough: it must be selected', () {
      final result = resolver.resolve(lockHotspot, newGame.withItem(brassKey));

      expect(result.effects, const [Say('door_locked')]);
    });

    test('with the brass key selected the door unlocks', () {
      final result = resolver.resolve(
        lockHotspot,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );

      expect(result.effects, const [
        SetFlag(doorOpenFlag),
        ConsumeItem(brassKey),
        Say('door_unlocked'),
      ]);
      expect(result.usedItemId, brassKey);
    });

    test('a wrong item gives only the generic reaction', () {
      final result = resolver.resolve(
        lockHotspot,
        newGame.withItem(crowbar),
        usingItemId: crowbar,
      );

      expect(result.effects, genericReaction);
      expect(result.usedItemId, isNull);
    });

    test('once open, a tap leads to the hall', () {
      final result = resolver.resolve(
        lockHotspot,
        newGame.withFlag(doorOpenFlag),
      );

      expect(result.effects, const [GoToScene('villa_hall')]);
    });

    test('a wrong item on the open door does not walk through it', () {
      final result = resolver.resolve(
        lockHotspot,
        newGame.withFlag(doorOpenFlag).withItem(crowbar),
        usingItemId: crowbar,
      );

      expect(result.effects, genericReaction);
    });
  });

  test('a look-only hotspot resolves to its inspect effect', () {
    final result = resolver.resolve(plaqueHotspot, newGame);

    expect(result.effects, const [Inspect('statue_plaque')]);
  });

  test('any item on a hotspot without item rules gives the generic '
      'reaction', () {
    final result = resolver.resolve(
      plaqueHotspot,
      newGame.withItem(brassKey),
      usingItemId: brassKey,
    );

    expect(result.effects, genericReaction);
  });

  test('no rule matches: nothing happens', () {
    const hotspot = HotspotDefinition(
      id: 'drawer',
      rect: anyRect,
      labelKey: 'hotspot_drawer',
      interactions: [
        InteractionRule(when: FlagSet('never'), effects: [Say('x')]),
      ],
    );

    expect(resolver.resolve(hotspot, newGame), ResolvedInteraction.none);
  });

  test('the first matching rule wins, later ones are ignored', () {
    const hotspot = HotspotDefinition(
      id: 'desk',
      rect: anyRect,
      labelKey: 'hotspot_desk',
      interactions: [
        InteractionRule(effects: [Say('first')]),
        InteractionRule(effects: [Say('second')]),
      ],
    );

    expect(resolver.resolve(hotspot, newGame).effects, const [Say('first')]);
  });

  group('item rules inside combined conditions', () {
    const hotspot = HotspotDefinition(
      id: 'safe',
      rect: anyRect,
      labelKey: 'hotspot_safe',
      interactions: [
        InteractionRule(
          when: AllOf([UsingItem(crowbar), FlagNotSet('safe_open')]),
          effects: [SetFlag('safe_open')],
        ),
        InteractionRule(effects: [Say('safe_closed')]),
      ],
    );

    test('the item rule runs while its other conditions hold', () {
      final result = resolver.resolve(
        hotspot,
        newGame.withItem(crowbar),
        usingItemId: crowbar,
      );

      expect(result.effects, const [SetFlag('safe_open')]);
      expect(result.usedItemId, crowbar);
    });

    test('the right item at the wrong time gives the generic reaction', () {
      final result = resolver.resolve(
        hotspot,
        newGame.withItem(crowbar).withFlag('safe_open'),
        usingItemId: crowbar,
      );

      expect(result.effects, genericReaction);
    });
  });
}
