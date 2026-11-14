import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_validator.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_checks.dart';
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
  'scene_square',
  'label',
  'key_name',
  'key_description',
  'file_title',
  'file_body',
  'file_line',
  'name',
  'hello',
  'again',
  'no_reaction',
  'question',
  'answer',
  'say_comment',
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
  'person_baker': NoteDefinition(
    id: 'person_baker',
    category: NoteCategory.person,
    titleKey: 'file_title',
    bodyKey: 'file_body',
    entries: [NoteEntryDefinition(id: 'said_so', textKey: 'file_line')],
  ),
};

DialogueTopic _topic(
  String id, {
  List<String> answer = const ['answer'],
  String promptKey = 'question',
  Condition? visibleWhen,
  TopicTrigger? trigger,
  List<Effect> effects = const [],
}) => DialogueTopic(
  id: id,
  promptKey: promptKey,
  answer: answer,
  visibleWhen: visibleWhen,
  trigger: trigger,
  effects: effects,
);

DialogueDefinition _baker({
  String id = 'baker',
  List<DialogueTopic>? topics,
  DialogueGreeting greeting = const DialogueGreeting('hello', thenKey: 'again'),
  String nameKey = 'name',
  String noReactionKey = 'no_reaction',
  String portraitStyle = 'plain',
}) => DialogueDefinition(
  id: id,
  nameKey: nameKey,
  portrait: DialoguePortrait(placeholderStyle: portraitStyle),
  greeting: greeting,
  noReactionKey: noReactionKey,
  topics: topics ?? [_topic('about_bread')],
);

/// A square with a baker. Scenes are validated first, then the dialogues,
/// then the flags: the order of the content validation test.
List<ContentIssue> _validate({
  List<DialogueDefinition>? dialogues,
  List<Effect> bakerHotspotEffects = const [Talk('baker')],
  Condition? doorVisibleWhen,
  List<Effect> squareOnFirstEnter = const [],
}) {
  final all = {
    for (final dialogue in dialogues ?? [_baker()]) dialogue.id: dialogue,
  };
  final scene = SceneDefinition(
    id: 'square',
    titleKey: 'scene_square',
    visual: _visual,
    onFirstEnter: squareOnFirstEnter,
    hotspots: [
      HotspotDefinition(
        id: 'baker',
        rect: _rect,
        labelKey: 'label',
        interactions: [InteractionRule(effects: bakerHotspotEffects)],
      ),
      HotspotDefinition(
        id: 'door',
        rect: _rect,
        labelKey: 'label',
        visibleWhen: doorVisibleWhen,
        interactions: const [
          InteractionRule(effects: [Say('say_comment')]),
        ],
      ),
    ],
  );
  final checks = ContentChecks(
    content: CaseContent(
      definition: const CaseDefinition(
        id: 'case01',
        chapters: [ChapterDefinition(id: 'ch01', entrySceneId: 'square')],
      ),
      scenes: {'square': scene},
      inspections: const {},
      sceneChapters: const {'square': 'ch01'},
    ),
    items: _items,
    notes: _notes,
    textKeysByLanguage: const {'en': _texts},
    dialogueTopics: DialogueValidator.topicIds(all),
  );
  const ContentValidator().validateWith(checks, styles: _styles);
  const DialogueValidator().validate(
    dialogues: all,
    checks: checks,
    portraitStyles: _styles.placeholderStyles,
  );
  checks.flagIssues();
  return checks.issues;
}

Matcher _reports(String part) =>
    contains(predicate<ContentIssue>((issue) => '$issue'.contains(part)));

void main() {
  test('a consistent dialogue has no issues', () {
    expect(
      _validate(
        dialogues: [
          _baker(
            topics: [
              _topic(
                'about_bread',
                effects: const [
                  Say('say_comment'),
                  SetFlag('asked_bread'),
                  AddNote('person_baker'),
                  AddNoteEntry(noteId: 'person_baker', entryId: 'said_so'),
                  GiveItem('key'),
                  ConsumeItem('key'),
                ],
              ),
              _topic('about_key', visibleWhen: const HasItem('key')),
              _topic('give_key', trigger: const ShowItem('key')),
              _topic('show_file', trigger: const ShowNote('person_baker')),
            ],
          ),
        ],
      ),
      isEmpty,
    );
  });

  test('topicIds is the plain data the scene validator needs', () {
    expect(
      DialogueValidator.topicIds({
        'baker': _baker(topics: [_topic('a'), _topic('b')]),
      }),
      {
        'baker': {'a', 'b'},
      },
    );
  });

  group('texts', () {
    test('name, greeting, no-reaction line, question and answer lines', () {
      final issues = _validate(
        dialogues: [
          _baker(
            nameKey: 'no_name',
            noReactionKey: 'no_shrug',
            greeting: const DialogueGreeting('no_hello', thenKey: 'no_again'),
            topics: [
              _topic(
                'about_bread',
                promptKey: 'no_question',
                answer: const ['answer', 'no_answer'],
              ),
            ],
          ),
        ],
      );

      for (final key in [
        'no_name',
        'no_shrug',
        'no_hello',
        'no_again',
        'no_question',
        'no_answer',
      ]) {
        expect(issues, _reports('missing text "$key" (en)'));
      }
    });

    test('a topic needs at least one answer line', () {
      expect(
        _validate(
          dialogues: [
            _baker(topics: [_topic('about_bread', answer: const [])]),
          ],
        ),
        _reports('dialogue baker / topic about_bread: has no answer lines'),
      );
    });

    test('the texts of a dialogue count as used', () {
      final checks = ContentChecks(
        content: const CaseContent(
          definition: CaseDefinition(id: 'case01', chapters: []),
          scenes: {},
          inspections: {},
        ),
        items: _items,
        notes: _notes,
        textKeysByLanguage: const {'en': _texts},
      );

      const DialogueValidator().validate(
        dialogues: {'baker': _baker()},
        checks: checks,
        portraitStyles: const {'plain'},
      );

      expect(
        checks.usedTextKeys,
        containsAll([
          'name',
          'hello',
          'again',
          'no_reaction',
          'question',
          'answer',
        ]),
      );
    });
  });

  group('IDs', () {
    test('duplicate topic ID inside a dialogue', () {
      expect(
        _validate(
          dialogues: [
            _baker(topics: [_topic('twice'), _topic('twice')]),
          ],
        ),
        _reports(
          'dialogue baker / topic twice: duplicate topic ID in this '
          'dialogue',
        ),
      );
    });

    test('the same topic ID in two dialogues is fine', () {
      expect(
        _validate(
          dialogues: [
            _baker(),
            _baker(
              id: 'miller',
              greeting: const DialogueGreeting('hello'),
            ),
          ],
        ).errors,
        isEmpty,
      );
    });
  });

  test('an unknown portrait style', () {
    expect(
      _validate(dialogues: [_baker(portraitStyle: 'oil_painting')]),
      _reports('unknown portrait placeholder style "oil_painting"'),
    );
  });

  group('topic effects', () {
    test('goToScene, inspect, talk and hideHotspot are not allowed', () {
      final issues = _validate(
        dialogues: [
          _baker(
            topics: [
              _topic(
                'about_bread',
                effects: const [
                  GoToScene('square'),
                  Inspect('sign'),
                  Talk('baker'),
                  HideHotspot(),
                ],
              ),
            ],
          ),
        ],
      );

      for (final kind in ['GoToScene', 'Inspect', 'Talk', 'HideHotspot']) {
        expect(
          issues,
          _reports(
            'dialogue baker / topic about_bread: $kind is not allowed here '
            '(only say, setFlag, addNote, addNoteEntry, giveItem, '
            'consumeItem)',
          ),
        );
      }
    });

    test('references are checked', () {
      final issues = _validate(
        dialogues: [
          _baker(
            topics: [
              _topic(
                'about_bread',
                effects: const [
                  GiveItem('rope'),
                  AddNote('diary'),
                  AddNoteEntry(noteId: 'person_baker', entryId: 'lied'),
                  Say('no_comment'),
                ],
              ),
            ],
          ),
        ],
      );

      expect(issues, _reports('unknown item "rope"'));
      expect(issues, _reports('unknown note "diary"'));
      expect(issues, _reports('note "person_baker" has no entry "lied"'));
      expect(issues, _reports('missing text "no_comment" (en)'));
    });
  });

  group('topic conditions', () {
    test('usingItem is forbidden, at any depth', () {
      expect(
        _validate(
          dialogues: [
            _baker(
              topics: [
                _topic(
                  'about_bread',
                  visibleWhen: const AllOf([
                    HasItem('key'),
                    AnyOf([UsingItem('key')]),
                  ]),
                ),
              ],
            ),
          ],
        ),
        _reports('usingItem cannot be used in a dialogue topic'),
      );
    });

    test('references are checked', () {
      final issues = _validate(
        dialogues: [
          _baker(
            topics: [
              _topic(
                'about_bread',
                visibleWhen: const AllOf([
                  HasItem('rope'),
                  HasNote('diary'),
                  Visited('cellar'),
                  HasAsked(dialogueId: 'baker', topicId: 'about_cake'),
                  HasAsked(dialogueId: 'miller', topicId: 'about_bread'),
                ]),
              ),
            ],
          ),
        ],
      );

      expect(issues, _reports('unknown item "rope"'));
      expect(issues, _reports('unknown note "diary"'));
      expect(issues, _reports('unknown scene "cellar"'));
      expect(issues, _reports('dialogue "baker" has no topic "about_cake"'));
      expect(issues, _reports('unknown dialogue "miller"'));
    });

    test('a topic may depend on another topic of the same dialogue', () {
      expect(
        _validate(
          dialogues: [
            _baker(
              topics: [
                _topic('about_bread'),
                _topic(
                  'about_oven',
                  visibleWhen: const HasAsked(
                    dialogueId: 'baker',
                    topicId: 'about_bread',
                  ),
                ),
              ],
            ),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('triggers of topics', () {
    test('the shown item or note must exist', () {
      final issues = _validate(
        dialogues: [
          _baker(
            topics: [
              _topic('give_rope', trigger: const ShowItem('rope')),
              _topic('show_diary', trigger: const ShowNote('diary')),
            ],
          ),
        ],
      );

      expect(
        issues,
        _reports('topic give_rope / trigger: unknown item "rope"'),
      );
      expect(
        issues,
        _reports('topic show_diary / trigger: unknown note "diary"'),
      );
    });
  });

  group('rules that span scenes and dialogues', () {
    test('a flag set by a topic may be read by a hotspot', () {
      expect(
        _validate(
          doorVisibleWhen: const FlagSet('baker_left'),
          dialogues: [
            _baker(
              topics: [
                _topic('about_bread', effects: const [SetFlag('baker_left')]),
              ],
            ),
          ],
        ),
        isEmpty,
      );
    });

    test('a flag read by a topic must be set somewhere', () {
      expect(
        _validate(
          dialogues: [
            _baker(
              topics: [
                _topic('about_bread', visibleWhen: const FlagSet('trusts_mee')),
              ],
            ),
          ],
        ),
        _reports('flag "trusts_mee" is read but never set'),
      );
    });

    test('a greeting may not share its first line with a say effect', () {
      expect(
        _validate(
          squareOnFirstEnter: const [Say('hello', repeatKey: 'again')],
        ),
        _reports(
          'dialogue baker / greeting: first line "hello" is already used at '
          'scene square / onFirstEnter',
        ),
      );
    });

    test('two dialogues may not share a first greeting', () {
      expect(
        _validate(
          dialogues: [
            _baker(),
            _baker(id: 'miller'),
          ],
        ),
        _reports('first line "hello" is already used at dialogue baker'),
      );
    });

    test('a greeting with one form shares nothing', () {
      expect(
        _validate(
          dialogues: [
            _baker(greeting: const DialogueGreeting('hello')),
            _baker(id: 'miller', greeting: const DialogueGreeting('hello')),
          ],
        ).errors,
        isEmpty,
      );
    });

    test('a dialogue no talk effect opens is a warning', () {
      final issues = _validate(
        dialogues: [
          _baker(),
          _baker(id: 'miller', greeting: const DialogueGreeting('hello')),
        ],
      );

      expect(issues.errors, isEmpty);
      expect(issues.warnings, const [
        ContentIssue(
          'dialogue miller',
          'no talk effect opens this dialogue',
          severity: ContentSeverity.warning,
        ),
      ]);
    });

    test('talk to an unknown dialogue is an error on the scene side', () {
      expect(
        _validate(bakerHotspotEffects: const [Talk('butcher')]),
        _reports('scene square / hotspot baker / rule 1: unknown dialogue'),
      );
    });
  });
}
