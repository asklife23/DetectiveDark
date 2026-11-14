import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_sprite.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_validator.dart';
import 'package:flutter_test/flutter_test.dart';

const _rect = NormalizedRect(x: 0.1, y: 0.1, width: 0.2, height: 0.2);
const _visual = SceneVisual(placeholderStyle: 'plain');
const _styles = KnownStyleNames(
  overlayStyles: {'engraved'},
  filterPresets: {'night'},
  placeholderStyles: {'plain'},
);

const _texts = {
  'generic_item_no_effect',
  'scene_yard',
  'scene_shed',
  'label',
  'say_locked',
  'key_name',
  'key_description',
  'memo_title',
  'memo_body',
  'sign_text',
};

const _items = {
  'key': ItemDefinition(
    id: 'key',
    nameKey: 'key_name',
    descriptionKey: 'key_description',
    iconStyle: 'plain',
  ),
};

const _notes = {
  'memo': NoteDefinition(
    id: 'memo',
    category: NoteCategory.document,
    titleKey: 'memo_title',
    bodyKey: 'memo_body',
  ),
};

HotspotDefinition _hotspot(
  String id,
  List<Effect> effects, {
  Condition? when,
  Condition? visibleWhen,
  NormalizedRect rect = _rect,
  String labelKey = 'label',
  HotspotSprite? sprite,
}) => HotspotDefinition(
  id: id,
  rect: rect,
  labelKey: labelKey,
  visibleWhen: visibleWhen,
  sprite: sprite,
  interactions: [InteractionRule(when: when, effects: effects)],
);

/// A small, consistent case: a yard with a door into a shed.
List<ContentIssue> _validate({
  List<HotspotDefinition>? yardHotspots,
  List<Effect> yardOnFirstEnter = const [],
  SceneVisual yardVisual = _visual,
  String? shedParent = 'yard',
  String entryScene = 'yard',
  List<SceneDefinition> extraScenes = const [],
  List<TriggerDefinition> triggers = const [],
  Map<String, Set<String>> texts = const {'en': _texts},
  Map<String, NoteDefinition> notes = _notes,
  double reservedBottomStrip = 0,
}) {
  final scenes = [
    SceneDefinition(
      id: 'yard',
      titleKey: 'scene_yard',
      visual: yardVisual,
      onFirstEnter: yardOnFirstEnter,
      hotspots:
          yardHotspots ??
          [
            _hotspot('door', const [GoToScene('shed')]),
          ],
    ),
    SceneDefinition(
      id: 'shed',
      parentId: shedParent,
      titleKey: 'scene_shed',
      visual: _visual,
    ),
    ...extraScenes,
  ];

  return const ContentValidator().validate(
    content: CaseContent(
      definition: CaseDefinition(
        id: 'case01',
        chapters: [ChapterDefinition(id: 'ch01', entrySceneId: entryScene)],
      ),
      scenes: {for (final scene in scenes) scene.id: scene},
      inspections: const {
        'sign': InspectionDefinition(
          id: 'sign',
          textKey: 'sign_text',
          visual: _visual,
        ),
      },
      sceneChapters: {for (final scene in scenes) scene.id: 'ch01'},
      triggers: triggers,
    ),
    items: _items,
    notes: notes,
    textKeysByLanguage: texts,
    styles: _styles,
    reservedBottomStrip: reservedBottomStrip,
  );
}

Matcher _reports(String part) =>
    contains(predicate<ContentIssue>((issue) => '$issue'.contains(part)));

void main() {
  test('consistent content has no issues', () {
    expect(_validate(), isEmpty);
  });

  group('references', () {
    test('goToScene to an unknown scene', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('gate', const [GoToScene('cellar')]),
        ],
      );

      expect(issues, _reports('unknown scene "cellar"'));
      expect(issues, _reports('scene yard / hotspot gate / rule 1'));
    });

    test('unknown item in an effect and in a condition', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot(
            'box',
            const [GiveItem('crowbar')],
            when: const UsingItem('hammer'),
          ),
        ],
      );

      expect(issues, _reports('unknown item "crowbar"'));
      expect(issues, _reports('unknown item "hammer"'));
    });

    test('unknown note and unknown inspection', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('paper', const [AddNote('diary')]),
          _hotspot('sign', const [Inspect('poster')]),
        ],
      );

      expect(issues, _reports('unknown note "diary"'));
      expect(issues, _reports('unknown inspection "poster"'));
    });

    test('unknown parent scene', () {
      expect(
        _validate(shedParent: 'garden'),
        _reports('unknown parent scene "garden"'),
      );
    });

    test('a parent chain that loops', () {
      final issues = _validate(
        extraScenes: const [
          SceneDefinition(
            id: 'a',
            parentId: 'b',
            titleKey: 'scene_yard',
            visual: _visual,
          ),
          SceneDefinition(
            id: 'b',
            parentId: 'a',
            titleKey: 'scene_yard',
            visual: _visual,
          ),
        ],
      );

      expect(issues, _reports('parent chain loops'));
    });

    test('unknown entry scene of a chapter', () {
      expect(
        _validate(entryScene: 'street'),
        _reports('unknown entry scene "street"'),
      );
    });
  });

  group('texts', () {
    test('a missing text key names the key and the language', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('lock', const [Say('say_opened')]),
        ],
      );

      expect(issues, _reports('missing text "say_opened" (en)'));
    });

    test('every supported language must have every key', () {
      final issues = _validate(
        texts: {
          'en': _texts,
          'tr': {..._texts}..remove('scene_shed'),
        },
      );

      expect(issues, hasLength(1));
      expect(issues, _reports('missing text "scene_shed" (tr)'));
    });

    test('the generic item reaction must exist', () {
      final issues = _validate(
        texts: {
          'en': {..._texts}..remove('generic_item_no_effect'),
        },
      );

      expect(issues, _reports('missing text "generic_item_no_effect"'));
    });
  });

  group('flags', () {
    test('a flag that is read but never set is reported (typo guard)', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('lever', const [SetFlag('shed_open')]),
          _hotspot(
            'window',
            const [Say('say_locked')],
            when: const FlagSet('shed_opn'),
          ),
        ],
      );

      expect(issues, hasLength(1));
      expect(issues, _reports('flag "shed_opn" is read but never set'));
    });

    test('flags read in visibleWhen and variants count as read', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot(
            'door',
            const [GoToScene('shed')],
            visibleWhen: const FlagNotSet('door_gone'),
          ),
        ],
      );

      expect(issues, _reports('flag "door_gone" is read but never set'));
    });
  });

  group('rules', () {
    test('two inspect effects in one rule', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('sign', const [Inspect('sign'), Inspect('sign')]),
        ],
      );

      expect(issues, _reports('more than one inspect effect'));
    });

    test('inspect together with goToScene', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [Inspect('sign'), GoToScene('shed')]),
        ],
      );

      expect(issues, _reports('inspect cannot be combined with goToScene'));
    });

    test('a rule without effects', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('stone', const []),
        ],
      );

      expect(issues, _reports('has no effects'));
    });

    test('onFirstEnter allows only say, setFlag, addNote and giveItem', () {
      expect(
        _validate(
          yardOnFirstEnter: const [
            Say('say_locked'),
            SetFlag('seen_yard'),
            AddNote('memo'),
            GiveItem('key'),
          ],
        ),
        isEmpty,
      );

      final issues = _validate(
        yardOnFirstEnter: const [GoToScene('shed'), HideHotspot()],
      );
      expect(issues, _reports('GoToScene is not allowed here'));
      expect(issues, _reports('HideHotspot is not allowed here'));
    });
  });

  group('hotspots and visuals', () {
    test('duplicate hotspot ID inside a scene', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('door', const [Say('say_locked')]),
        ],
      );

      expect(issues, _reports('duplicate hotspot ID'));
    });

    test('a hotspot rect outside the image', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot(
            'door',
            const [GoToScene('shed')],
            rect: const NormalizedRect(x: 0.9, y: 0, width: 0.2, height: 0.5),
          ),
        ],
      );

      expect(issues, _reports('rect is outside 0–1'));
    });

    test('a sprite with a valid rect and a known style is fine', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot(
            'door',
            const [GoToScene('shed')],
            sprite: const HotspotSprite(rect: _rect, placeholderStyle: 'plain'),
          ),
        ],
      );

      expect(issues, isEmpty);
    });

    test('a sprite with a bad rect and an unknown style', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot(
            'door',
            const [GoToScene('shed')],
            sprite: const HotspotSprite(
              rect: NormalizedRect(x: 0.9, y: 0, width: 0.2, height: 0.5),
              placeholderStyle: 'castle',
            ),
          ),
        ],
      );

      expect(issues, _reports('sprite rect is outside 0–1'));
      expect(issues, _reports('unknown sprite placeholder style "castle"'));
    });

    group('the bottom strip kept for the message bar', () {
      List<ContentIssue> withDoorAt(double y, double height) => _validate(
        reservedBottomStrip: 0.13,
        yardHotspots: [
          _hotspot(
            'door',
            const [GoToScene('shed')],
            rect: NormalizedRect(x: 0.1, y: y, width: 0.2, height: height),
          ),
        ],
      );

      test('a hotspot that reaches into it is reported', () {
        expect(withDoorAt(0.5, 0.4), _reports('reaches into the bottom strip'));
      });

      test('a hotspot that ends exactly at its edge is fine', () {
        // 0.76 + 0.11 is 0.8700000000000001 in floating point.
        expect(withDoorAt(0.76, 0.11), isEmpty);
      });

      test('without a reserved strip the whole scene is free', () {
        final issues = _validate(
          yardHotspots: [
            _hotspot(
              'door',
              const [GoToScene('shed')],
              rect: const NormalizedRect(
                x: 0.1,
                y: 0.5,
                width: 0.2,
                height: 0.5,
              ),
            ),
          ],
        );

        expect(issues, isEmpty);
      });
    });

    test('unknown placeholder style and filter preset', () {
      final issues = _validate(
        yardVisual: const SceneVisual(
          placeholderStyle: 'castle',
          filterPreset: 'sepia',
        ),
      );

      expect(issues, _reports('unknown placeholder style "castle"'));
      expect(issues, _reports('unknown filter preset "sepia"'));
    });

    test('overlay with a bad rect, style and text key', () {
      final issues = _validate(
        yardVisual: const SceneVisual(
          placeholderStyle: 'plain',
          overlays: [
            TextOverlay(
              rect: NormalizedRect(x: 0.5, y: 0.5, width: 0.6, height: 0.1),
              textKey: 'house_number',
              style: 'neon',
            ),
          ],
        ),
      );

      expect(issues, _reports('overlay rect is outside 0–1'));
      expect(issues, _reports('unknown overlay style "neon"'));
      expect(issues, _reports('missing text "house_number"'));
    });
  });

  group('reachability', () {
    test('a scene nothing leads to is reported', () {
      final issues = _validate(
        extraScenes: const [
          SceneDefinition(
            id: 'attic',
            titleKey: 'scene_yard',
            visual: _visual,
          ),
        ],
      );

      expect(issues, hasLength(1));
      expect(
        issues,
        _reports('scene attic: cannot be reached from the chapter entry'),
      );
    });

    test('Back counts: a parent is reachable from its child', () {
      // The chapter starts in the shed; the yard is only reachable by Back
      // (its door leads into the shed again, so the yard is no trap).
      final issues = _validate(entryScene: 'shed');

      expect(issues, isEmpty);
    });
  });

  group('not, atLeast, visited and inScene', () {
    List<ContentIssue> withCondition(Condition when) => _validate(
      yardHotspots: [
        _hotspot('door', const [GoToScene('shed')]),
        _hotspot('gate', const [Say('say_locked')], when: when),
      ],
    );

    test('valid uses have no issues', () {
      expect(
        withCondition(
          const AllOf([
            Not(HasItem('key')),
            AtLeast(1, [Visited('shed'), InScene('yard')]),
          ]),
        ),
        isEmpty,
      );
    });

    test('usingItem inside not', () {
      expect(
        withCondition(const Not(UsingItem('key'))),
        _reports('usingItem cannot be used inside not / atLeast'),
      );
    });

    test('usingItem deep inside atLeast', () {
      expect(
        withCondition(
          const AtLeast(1, [
            AllOf([
              AnyOf([UsingItem('key')]),
            ]),
          ]),
        ),
        _reports('usingItem cannot be used inside not / atLeast'),
      );
    });

    test('usingItem next to not is still fine', () {
      expect(
        withCondition(const AllOf([UsingItem('key'), Not(HasNote('memo'))])),
        isEmpty,
      );
    });

    test('atLeast count below 1 or above the number of conditions', () {
      expect(
        withCondition(const AtLeast(0, [HasItem('key')])),
        _reports('atLeast count 0 must be between 1 and 1'),
      );
      expect(
        withCondition(const AtLeast(3, [HasItem('key'), HasNote('memo')])),
        _reports('atLeast count 3 must be between 1 and 2'),
      );
    });

    test('visited and inScene with an unknown scene', () {
      expect(
        withCondition(const Visited('cellar')),
        _reports('unknown scene "cellar"'),
      );
      expect(
        withCondition(const InScene('attic')),
        _reports('unknown scene "attic"'),
      );
    });

    test('references and flags inside not and atLeast are checked', () {
      final issues = withCondition(
        const Not(
          AtLeast(1, [FlagSet('never_set'), HasItem('rope'), HasNote('map')]),
        ),
      );

      expect(issues, _reports('flag "never_set" is read but never set'));
      expect(issues, _reports('unknown item "rope"'));
      expect(issues, _reports('unknown note "map"'));
    });
  });

  group('say with first / then', () {
    const line = Say('say_locked', repeatKey: 'label');

    test('both texts must exist', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('gate', const [Say('say_long', repeatKey: 'say_short')]),
        ],
      );

      expect(issues, _reports('missing text "say_long" (en)'));
      expect(issues, _reports('missing text "say_short" (en)'));
    });

    test('a first key used in one place is fine', () {
      expect(
        _validate(
          yardHotspots: [
            _hotspot('door', const [GoToScene('shed')]),
            _hotspot('gate', const [line]),
          ],
        ),
        isEmpty,
      );
    });

    test('the same first key in two places is reported', () {
      final issues = _validate(
        yardHotspots: [
          _hotspot('door', const [GoToScene('shed')]),
          _hotspot('gate', const [line]),
        ],
        yardOnFirstEnter: const [line],
      );

      expect(
        issues,
        _reports(
          'first line "say_locked" is already used at scene yard / '
          'onFirstEnter',
        ),
      );
    });

    test('a plain line may repeat anywhere', () {
      expect(
        _validate(
          yardHotspots: [
            _hotspot('door', const [GoToScene('shed')]),
            _hotspot('gate', const [Say('say_locked')]),
            _hotspot('wall', const [Say('say_locked')]),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('triggers', () {
    TriggerDefinition trigger(
      String id, {
      Condition when = const Visited('shed'),
      List<Effect> effects = const [Say('say_locked')],
    }) => TriggerDefinition(id: id, when: when, effects: effects);

    test('a valid trigger has no issues', () {
      expect(
        _validate(
          triggers: [
            trigger(
              'seen_both',
              when: const AtLeast(2, [Visited('yard'), Visited('shed')]),
              effects: const [
                Say('say_locked'),
                SetFlag('seen_both'),
                AddNote('memo'),
                GiveItem('key'),
              ],
            ),
          ],
        ),
        isEmpty,
      );
    });

    test('duplicate trigger ID', () {
      expect(
        _validate(triggers: [trigger('twice'), trigger('twice')]),
        _reports('trigger twice: duplicate trigger ID'),
      );
    });

    test('a trigger without effects', () {
      expect(
        _validate(triggers: [trigger('empty', effects: const [])]),
        _reports('trigger empty: has no effects'),
      );
    });

    test('only say, setFlag, addNote, addNoteEntry and giveItem are '
        'allowed', () {
      final issues = _validate(
        triggers: [
          trigger(
            'too_much',
            effects: const [
              GoToScene('shed'),
              Inspect('sign'),
              HideHotspot(),
              ConsumeItem('key'),
            ],
          ),
        ],
      );

      for (final kind in [
        'GoToScene',
        'Inspect',
        'HideHotspot',
        'ConsumeItem',
      ]) {
        expect(issues, _reports('trigger too_much: $kind is not allowed here'));
      }
    });

    test('usingItem in the condition, at any depth', () {
      expect(
        _validate(
          triggers: [
            trigger(
              'with_item',
              when: const AllOf([
                Visited('shed'),
                AnyOf([UsingItem('key')]),
              ]),
            ),
          ],
        ),
        _reports('usingItem cannot be used in a trigger'),
      );
    });

    test('references and texts are checked', () {
      final issues = _validate(
        triggers: [
          trigger(
            'broken',
            when: const AllOf([Visited('cellar'), HasNote('map')]),
            effects: const [
              Say('say_missing'),
              AddNote('diary'),
              GiveItem('rope'),
            ],
          ),
        ],
      );

      expect(issues, _reports('unknown scene "cellar"'));
      expect(issues, _reports('unknown note "map"'));
      expect(issues, _reports('missing text "say_missing" (en)'));
      expect(issues, _reports('unknown note "diary"'));
      expect(issues, _reports('unknown item "rope"'));
    });

    test('a flag set by a trigger counts as set', () {
      expect(
        _validate(
          yardHotspots: [
            _hotspot('door', const [GoToScene('shed')]),
            _hotspot(
              'gate',
              const [Say('say_locked')],
              when: const FlagSet('been_inside'),
            ),
          ],
          triggers: [
            trigger('inside', effects: const [SetFlag('been_inside')]),
          ],
        ),
        isEmpty,
      );
    });

    test('a flag read only by a trigger must be set somewhere', () {
      expect(
        _validate(
          triggers: [trigger('typo', when: const FlagSet('been_insde'))],
        ),
        _reports('flag "been_insde" is read but never set'),
      );
    });

    test('a first line shared with a hotspot is reported', () {
      const line = Say('say_locked', repeatKey: 'label');

      expect(
        _validate(
          yardHotspots: [
            _hotspot('door', const [GoToScene('shed')]),
            _hotspot('gate', const [line]),
          ],
          triggers: [
            trigger('again', effects: const [line]),
          ],
        ),
        _reports('first line "say_locked" is already used'),
      );
    });
  });

  group('note entries', () {
    const file = NoteDefinition(
      id: 'person_gardener',
      category: NoteCategory.person,
      titleKey: 'memo_title',
      bodyKey: 'memo_body',
      entries: [
        NoteEntryDefinition(id: 'saw_light', textKey: 'say_locked'),
        NoteEntryDefinition(id: 'owes_money', textKey: 'label'),
      ],
    );
    const notes = {..._notes, 'person_gardener': file};

    List<ContentIssue> withEffect(
      Effect effect, {
      Map<String, NoteDefinition> notes = notes,
    }) => _validate(
      notes: notes,
      yardHotspots: [
        _hotspot('door', const [GoToScene('shed')]),
        _hotspot('gardener', [effect]),
      ],
    );

    test('a valid entry and a valid addNoteEntry have no issues', () {
      expect(
        withEffect(
          const AddNoteEntry(noteId: 'person_gardener', entryId: 'saw_light'),
        ),
        isEmpty,
      );
    });

    test('duplicate entry ID inside a note', () {
      const twice = NoteDefinition(
        id: 'person_gardener',
        category: NoteCategory.person,
        titleKey: 'memo_title',
        bodyKey: 'memo_body',
        entries: [
          NoteEntryDefinition(id: 'saw_light', textKey: 'say_locked'),
          NoteEntryDefinition(id: 'saw_light', textKey: 'label'),
        ],
      );

      expect(
        _validate(notes: const {..._notes, 'person_gardener': twice}),
        _reports('note person_gardener: duplicate entry ID "saw_light"'),
      );
    });

    test('the same entry ID in two different notes is fine', () {
      const other = NoteDefinition(
        id: 'person_cook',
        category: NoteCategory.person,
        titleKey: 'memo_title',
        bodyKey: 'memo_body',
        entries: [NoteEntryDefinition(id: 'saw_light', textKey: 'label')],
      );

      expect(_validate(notes: const {...notes, 'person_cook': other}), isEmpty);
    });

    test('an entry with a missing text', () {
      const broken = NoteDefinition(
        id: 'person_gardener',
        category: NoteCategory.person,
        titleKey: 'memo_title',
        bodyKey: 'memo_body',
        entries: [NoteEntryDefinition(id: 'saw_light', textKey: 'no_text')],
      );

      expect(
        _validate(notes: const {..._notes, 'person_gardener': broken}),
        _reports(
          'note person_gardener / entry saw_light: missing text "no_text"',
        ),
      );
    });

    test('addNoteEntry to an unknown note', () {
      expect(
        withEffect(
          const AddNoteEntry(noteId: 'person_cook', entryId: 'saw_light'),
        ),
        _reports('unknown note "person_cook"'),
      );
    });

    test('addNoteEntry to an unknown entry of a known note', () {
      expect(
        withEffect(
          const AddNoteEntry(noteId: 'person_gardener', entryId: 'saw_ghost'),
        ),
        _reports('note "person_gardener" has no entry "saw_ghost"'),
      );
    });

    test('addNoteEntry is allowed in a trigger but not in onFirstEnter', () {
      const effect = AddNoteEntry(
        noteId: 'person_gardener',
        entryId: 'saw_light',
      );

      expect(
        _validate(
          notes: notes,
          triggers: const [
            TriggerDefinition(
              id: 'heard',
              when: Visited('shed'),
              effects: [effect],
            ),
          ],
        ),
        isEmpty,
      );
      expect(
        _validate(notes: notes, yardOnFirstEnter: const [effect]),
        _reports('AddNoteEntry is not allowed here'),
      );
    });
  });

  group('travel without a map', () {
    const market = SceneDefinition(
      id: 'market',
      titleKey: 'scene_yard',
      visual: _visual,
    );

    SceneDefinition marketWith(List<HotspotDefinition> hotspots) =>
        SceneDefinition(
          id: 'market',
          titleKey: 'scene_yard',
          visual: _visual,
          hotspots: hotspots,
        );

    final toMarket = [
      _hotspot('door', const [GoToScene('shed')]),
      _hotspot('sign', const [GoToScene('market')]),
    ];

    test('a main location with a way back is fine', () {
      expect(
        _validate(
          yardHotspots: toMarket,
          extraScenes: [
            marketWith([
              _hotspot('road', const [GoToScene('yard')]),
            ]),
          ],
        ),
        isEmpty,
      );
    });

    test('a main location without a way back is a trap', () {
      expect(
        _validate(yardHotspots: toMarket, extraScenes: const [market]),
        _reports(
          'scene market: trap location: no way leads from here back to '
          '"yard"',
        ),
      );
    });

    test('the way back may lead through a close-up', () {
      expect(
        _validate(
          yardHotspots: toMarket,
          extraScenes: [
            marketWith([
              _hotspot('stall', const [GoToScene('stall')]),
            ]),
            SceneDefinition(
              id: 'stall',
              parentId: 'market',
              titleKey: 'scene_yard',
              visual: _visual,
              hotspots: [
                _hotspot('cart', const [GoToScene('yard')]),
              ],
            ),
          ],
        ).errors,
        isEmpty,
      );
    });

    test('conditions are not looked at: a guarded way back counts', () {
      expect(
        _validate(
          yardHotspots: toMarket,
          extraScenes: [
            marketWith([
              _hotspot(
                'road',
                const [GoToScene('yard')],
                when: const HasItem('key'),
              ),
            ]),
          ],
        ),
        isEmpty,
      );
    });

    test('a jump into the close-up of another place is a warning', () {
      final issues = _validate(
        yardHotspots: toMarket,
        extraScenes: [
          marketWith([
            _hotspot('road', const [GoToScene('yard')]),
            _hotspot('shortcut', const [GoToScene('shed')]),
          ]),
        ],
      );

      expect(issues.errors, isEmpty);
      expect(issues.warnings.single.location, contains('hotspot shortcut'));
      expect(
        issues.warnings.single.message,
        contains('goToScene "shed" is neither a close-up of this scene'),
      );
    });

    test('to a close-up, to the parent and to a main location: no '
        'warning', () {
      final issues = _validate(
        yardHotspots: toMarket,
        extraScenes: [
          marketWith([
            _hotspot('road', const [GoToScene('yard')]),
          ]),
          SceneDefinition(
            id: 'loft',
            parentId: 'shed',
            titleKey: 'scene_yard',
            visual: _visual,
            hotspots: [
              _hotspot('ladder', const [GoToScene('shed')]),
              _hotspot('window', const [GoToScene('market')]),
            ],
          ),
          const SceneDefinition(
            id: 'bench',
            parentId: 'yard',
            titleKey: 'scene_yard',
            visual: _visual,
          ),
        ],
      );

      // (The loft and the bench are unreachable; that is not the point.)
      expect(issues.warnings, isEmpty);
    });
  });

  group('sprite overlays', () {
    HotspotDefinition sign(List<VisualOverlay> overlays) => _hotspot(
      'sign',
      const [Say('say_locked')],
      sprite: HotspotSprite(
        rect: _rect,
        placeholderStyle: 'plain',
        overlays: overlays,
      ),
    );

    List<ContentIssue> withOverlays(List<VisualOverlay> overlays) => _validate(
      yardHotspots: [
        _hotspot('door', const [GoToScene('shed')]),
        sign(overlays),
      ],
    );

    test('a valid overlay has no issues', () {
      expect(
        withOverlays(const [
          TextOverlay(rect: _rect, textKey: 'sign_text', style: 'engraved'),
        ]),
        isEmpty,
      );
    });

    test('a bad rect, an unknown style and a missing text', () {
      final issues = withOverlays(const [
        TextOverlay(
          rect: NormalizedRect(x: 0.9, y: 0.1, width: 0.3, height: 0.1),
          textKey: 'no_such_text',
          style: 'neon',
        ),
      ]);

      expect(
        issues,
        _reports('hotspot sign / sprite: overlay rect is outside 0–1'),
      );
      expect(issues, _reports('unknown overlay style "neon"'));
      expect(issues, _reports('missing text "no_such_text" (en)'));
    });
  });
}
