import 'package:detective_dark/features/scene_engine/data/models/condition_codec.dart';
import 'package:detective_dark/features/scene_engine/data/models/effect_codec.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _formatError(String part) => throwsA(
  isA<FormatException>().having((e) => e.message, 'message', contains(part)),
);

void main() {
  group('ConditionCodec', () {
    test('parses every kind of condition', () {
      expect(ConditionCodec.parse({'flag': 'open'}), const FlagSet('open'));
      expect(
        ConditionCodec.parse({'notFlag': 'open'}),
        const FlagNotSet('open'),
      );
      expect(ConditionCodec.parse({'hasItem': 'key'}), const HasItem('key'));
      expect(
        ConditionCodec.parse({'usingItem': 'key'}),
        const UsingItem('key'),
      );
      expect(ConditionCodec.parse({'hasNote': 'memo'}), const HasNote('memo'));
    });

    test('parses nested all / any', () {
      final condition = ConditionCodec.parse({
        'all': [
          {'usingItem': 'key'},
          {
            'any': [
              {'flag': 'a'},
              {'notFlag': 'b'},
            ],
          },
        ],
      });

      expect(
        condition,
        const AllOf([
          UsingItem('key'),
          AnyOf([FlagSet('a'), FlagNotSet('b')]),
        ]),
      );
    });

    test('rejects an unknown key and names the known ones', () {
      expect(
        () => ConditionCodec.parse({'flagg': 'open'}),
        _formatError('Unknown condition "flagg". Known: flag, notFlag'),
      );
    });

    test('rejects objects that do not have exactly one key', () {
      expect(() => ConditionCodec.parse(<String, dynamic>{}), _formatError(''));
      expect(
        () => ConditionCodec.parse({'flag': 'a', 'hasItem': 'b'}),
        _formatError('exactly one key'),
      );
      expect(() => ConditionCodec.parse('flag'), _formatError('one key'));
    });

    test('rejects empty values', () {
      expect(() => ConditionCodec.parse({'flag': ''}), _formatError('"flag"'));
      expect(() => ConditionCodec.parse({'flag': 3}), _formatError('"flag"'));
      expect(
        () => ConditionCodec.parse({'all': <Object>[]}),
        _formatError('"all"'),
      );
    });
  });

  group('ConditionCodec: not, atLeast, visited, inScene', () {
    test('parses the four kinds', () {
      expect(
        ConditionCodec.parse({
          'not': {'hasItem': 'pill_bottle'},
        }),
        const Not(HasItem('pill_bottle')),
      );
      expect(
        ConditionCodec.parse({
          'atLeast': {
            'count': 2,
            'of': [
              {'flag': 'a'},
              {'flag': 'b'},
              {'visited': 'market_square'},
            ],
          },
        }),
        const AtLeast(2, [
          FlagSet('a'),
          FlagSet('b'),
          Visited('market_square'),
        ]),
      );
      expect(
        ConditionCodec.parse({'visited': 'villa_hall'}),
        const Visited('villa_hall'),
      );
      expect(
        ConditionCodec.parse({'inScene': 'market_square'}),
        const InScene('market_square'),
      );
    });

    test('not needs a single condition', () {
      expect(
        () => ConditionCodec.parse({'not': 'flag'}),
        _formatError('exactly one key'),
      );
      expect(
        () => ConditionCodec.parse({
          'not': [
            {'flag': 'a'},
          ],
        }),
        _formatError('exactly one key'),
      );
    });

    test('atLeast rejects malformed objects', () {
      expect(
        () => ConditionCodec.parse({'atLeast': 2}),
        _formatError('"count" and "of"'),
      );
      expect(
        () => ConditionCodec.parse({
          'atLeast': {
            'count': 1,
            'from': [
              {'flag': 'a'},
            ],
          },
        }),
        _formatError('Unknown "atLeast" keys: from'),
      );
      expect(
        () => ConditionCodec.parse({
          'atLeast': {
            'count': '2',
            'of': [
              {'flag': 'a'},
            ],
          },
        }),
        _formatError('whole number'),
      );
      expect(
        () => ConditionCodec.parse({
          'atLeast': {
            'of': [
              {'flag': 'a'},
            ],
          },
        }),
        _formatError('whole number'),
      );
      expect(
        () => ConditionCodec.parse({
          'atLeast': {'count': 1, 'of': <Object>[]},
        }),
        _formatError('"atLeast.of"'),
      );
    });

    test('visited and inScene need a scene ID', () {
      expect(
        () => ConditionCodec.parse({'visited': ''}),
        _formatError('"visited"'),
      );
      expect(
        () => ConditionCodec.parse({'inScene': 1}),
        _formatError('"inScene"'),
      );
    });
  });

  group('EffectCodec', () {
    test('parses every kind of effect', () {
      expect(EffectCodec.parse({'giveItem': 'key'}), const GiveItem('key'));
      expect(
        EffectCodec.parse({'consumeItem': 'key'}),
        const ConsumeItem('key'),
      );
      expect(EffectCodec.parse({'addNote': 'memo'}), const AddNote('memo'));
      expect(EffectCodec.parse({'setFlag': 'open'}), const SetFlag('open'));
      expect(EffectCodec.parse({'hideHotspot': true}), const HideHotspot());
      expect(EffectCodec.parse({'say': 'locked'}), const Say('locked'));
      expect(EffectCodec.parse({'inspect': 'plaque'}), const Inspect('plaque'));
      expect(EffectCodec.parse({'goToScene': 'hall'}), const GoToScene('hall'));
    });

    test('goToScene with a string uses the standard transition', () {
      final effect = EffectCodec.parse({'goToScene': 'hall'}) as GoToScene;

      expect(effect.transition, SceneTransition.standard);
    });

    test('goToScene with an object overrides parts of the transition', () {
      final effect =
          EffectCodec.parse({
                'goToScene': {
                  'sceneId': 'hall',
                  'holdMs': 600,
                  'fadeInMs': 400,
                  'sfx': 'door_creak',
                },
              })
              as GoToScene;

      expect(effect.sceneId, 'hall');
      expect(effect.transition.type, SceneTransitionType.fade);
      expect(effect.transition.fadeOut, SceneTransition.standard.fadeOut);
      expect(effect.transition.hold, const Duration(milliseconds: 600));
      expect(effect.transition.fadeIn, const Duration(milliseconds: 400));
      expect(effect.transition.sfx, 'door_creak');
    });

    test('goToScene can be a cut', () {
      final effect =
          EffectCodec.parse({
                'goToScene': {'sceneId': 'hall', 'type': 'cut'},
              })
              as GoToScene;

      expect(effect.transition.type, SceneTransitionType.cut);
    });

    test('rejects an unknown effect and names the known ones', () {
      expect(
        () => EffectCodec.parse({'giveItems': 'key'}),
        _formatError('Unknown effect "giveItems". Known: goToScene'),
      );
    });

    test('rejects malformed goToScene objects', () {
      expect(
        () => EffectCodec.parse({
          'goToScene': {'sceneId': 'hall', 'zoom': true},
        }),
        _formatError('Unknown "goToScene" keys: zoom'),
      );
      expect(
        () => EffectCodec.parse({
          'goToScene': {'sceneId': 'hall', 'type': 'zoom'},
        }),
        _formatError('Unknown transition type "zoom"'),
      );
      expect(
        () => EffectCodec.parse({
          'goToScene': {'sceneId': 'hall', 'holdMs': -1},
        }),
        _formatError('holdMs'),
      );
      expect(
        () => EffectCodec.parse({
          'goToScene': {'holdMs': 10},
        }),
        _formatError('sceneId'),
      );
    });

    test('say with first / then', () {
      expect(
        EffectCodec.parse({
          'say': {'first': 'statue_long', 'then': 'statue_short'},
        }),
        const Say('statue_long', repeatKey: 'statue_short'),
      );
    });

    test('say rejects malformed objects', () {
      expect(
        () => EffectCodec.parse({
          'say': {'first': 'a'},
        }),
        _formatError('both "first" and "then"'),
      );
      expect(
        () => EffectCodec.parse({
          'say': {'then': 'b'},
        }),
        _formatError('both "first" and "then"'),
      );
      expect(
        () => EffectCodec.parse({
          'say': {'first': 'a', 'then': ''},
        }),
        _formatError('both "first" and "then"'),
      );
      expect(
        () => EffectCodec.parse({
          'say': {'first': 'a', 'then': 'b', 'third': 'c'},
        }),
        _formatError('Unknown "say" keys: third'),
      );
      expect(
        () => EffectCodec.parse({'say': 3}),
        _formatError('a text key or an object'),
      );
      expect(() => EffectCodec.parse({'say': ''}), _formatError('"say"'));
    });

    test('addNoteEntry', () {
      expect(
        EffectCodec.parse({
          'addNoteEntry': {'note': 'person_pharmacist', 'entry': 'knows_villa'},
        }),
        const AddNoteEntry(noteId: 'person_pharmacist', entryId: 'knows_villa'),
      );
    });

    test('addNoteEntry rejects malformed objects', () {
      expect(
        () => EffectCodec.parse({'addNoteEntry': 'person_pharmacist'}),
        _formatError('"note" and "entry"'),
      );
      expect(
        () => EffectCodec.parse({
          'addNoteEntry': {'note': 'person_pharmacist'},
        }),
        _formatError('"addNoteEntry.entry"'),
      );
      expect(
        () => EffectCodec.parse({
          'addNoteEntry': {'entry': 'knows_villa'},
        }),
        _formatError('"addNoteEntry.note"'),
      );
      expect(
        () => EffectCodec.parse({
          'addNoteEntry': {'note': 'a', 'entry': 'b', 'line': 'c'},
        }),
        _formatError('Unknown "addNoteEntry" keys: line'),
      );
    });

    test('hideHotspot accepts only true', () {
      expect(
        () => EffectCodec.parse({'hideHotspot': 'statue_key'}),
        _formatError('hideHotspot'),
      );
    });

    test('parseList keeps the order', () {
      expect(
        EffectCodec.parseList([
          {'setFlag': 'open'},
          {'say': 'done'},
        ]),
        const [SetFlag('open'), Say('done')],
      );
    });
  });
}
