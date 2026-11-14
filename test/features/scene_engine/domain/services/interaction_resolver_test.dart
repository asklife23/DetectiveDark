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

  group('not, atLeast, visited and inScene', () {
    const hotspot = HotspotDefinition(
      id: 'cabinet',
      rect: anyRect,
      labelKey: 'hotspot_cabinet',
      interactions: [
        InteractionRule(
          when: Not(HasItem(crowbar)),
          effects: [Say('needs_a_tool')],
        ),
        InteractionRule(
          when: AtLeast(1, [Visited('villa_hall'), InScene('villa_exterior')]),
          effects: [Say('cabinet_forced')],
        ),
      ],
    );

    test('they guard ordinary rules', () {
      expect(resolver.resolve(hotspot, newGame).effects, const [
        Say('needs_a_tool'),
      ]);
      expect(
        resolver.resolve(hotspot, newGame.withItem(crowbar)).effects,
        const [Say('cabinet_forced')],
      );
    });

    test('they are never item rules: a selected item gets the generic '
        'reaction', () {
      final result = resolver.resolve(
        hotspot,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );

      expect(result.effects, genericReaction);
      expect(result.usedItemId, isNull);
    });

    test('a usingItem hidden inside not is not looked at', () {
      const odd = HotspotDefinition(
        id: 'odd',
        rect: anyRect,
        labelKey: 'hotspot_odd',
        interactions: [
          InteractionRule(when: Not(UsingItem(crowbar)), effects: [Say('x')]),
        ],
      );

      final result = resolver.resolve(
        odd,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );

      expect(result.effects, genericReaction);
    });
  });

  group('an item on a character (ADR 0016)', () {
    const figure = HotspotDefinition(
      id: 'pharmacist',
      rect: anyRect,
      labelKey: 'hotspot_pharmacist',
      interactions: [
        InteractionRule(effects: [Talk('pharmacist')]),
      ],
    );

    test('without an item the conversation simply opens', () {
      final result = resolver.resolve(figure, newGame);

      expect(result.effects, const [Talk('pharmacist')]);
      expect(result.shownItemId, isNull);
      expect(result.usedItemId, isNull);
    });

    test('with an item selected the conversation opens and the item is '
        'shown: no generic reaction, the item is not "used"', () {
      final result = resolver.resolve(
        figure,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );

      expect(result.effects, const [Talk('pharmacist')]);
      expect(result.shownItemId, brassKey);
      expect(result.usedItemId, isNull);
    });

    test('any item is shown: the hotspot needs no rule per item', () {
      for (final item in [brassKey, crowbar]) {
        final result = resolver.resolve(
          figure,
          newGame.withItem(item),
          usingItemId: item,
        );

        expect(result.shownItemId, item);
      }
    });

    test('an explicit usingItem rule on the character comes first', () {
      const bribable = HotspotDefinition(
        id: 'guard',
        rect: anyRect,
        labelKey: 'hotspot_guard',
        interactions: [
          InteractionRule(
            when: UsingItem(brassKey),
            effects: [ConsumeItem(brassKey), SetFlag('guard_left')],
          ),
          InteractionRule(effects: [Talk('guard')]),
        ],
      );

      final withKey = resolver.resolve(
        bribable,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );
      final withCrowbar = resolver.resolve(
        bribable,
        newGame.withItem(crowbar),
        usingItemId: crowbar,
      );

      expect(withKey.effects, const [
        ConsumeItem(brassKey),
        SetFlag('guard_left'),
      ]);
      expect(withKey.usedItemId, brassKey);
      expect(withKey.shownItemId, isNull);
      // Another item is shown to the guard instead.
      expect(withCrowbar.effects, const [Talk('guard')]);
      expect(withCrowbar.shownItemId, crowbar);
    });

    test('the talk rule must be the one that would run without an item', () {
      const gone = HotspotDefinition(
        id: 'pharmacist',
        rect: anyRect,
        labelKey: 'hotspot_pharmacist',
        interactions: [
          InteractionRule(
            when: FlagSet('shop_closed'),
            effects: [Say('nobody_here')],
          ),
          InteractionRule(effects: [Talk('pharmacist')]),
        ],
      );

      final closed = resolver.resolve(
        gone,
        newGame.withItem(brassKey).withFlag('shop_closed'),
        usingItemId: brassKey,
      );
      final open = resolver.resolve(
        gone,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );

      // Nobody to show it to: the usual reaction to a wrong item.
      expect(closed.effects, genericReaction);
      expect(closed.shownItemId, isNull);
      expect(open.shownItemId, brassKey);
    });

    test('a hotspot without talk still gives only the generic reaction', () {
      final result = resolver.resolve(
        plaqueHotspot,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );

      expect(result.effects, genericReaction);
      expect(result.shownItemId, isNull);
    });

    test('talk next to other effects: all of them run', () {
      const greeter = HotspotDefinition(
        id: 'porter',
        rect: anyRect,
        labelKey: 'hotspot_porter',
        interactions: [
          InteractionRule(effects: [SetFlag('met_porter'), Talk('porter')]),
        ],
      );

      final result = resolver.resolve(
        greeter,
        newGame.withItem(brassKey),
        usingItemId: brassKey,
      );

      expect(result.effects, const [SetFlag('met_porter'), Talk('porter')]);
      expect(result.shownItemId, brassKey);
    });
  });
}
