import 'dart:convert';

import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/features/dialogue/data/repositories/asset_dialogue_catalog_repository.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/scene_engine/data/models/codec_rule_parser.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/game_app.dart';
import '../../../helpers/two_chapter_fixture.dart';

/// `dialogues.json` and `dialogueExtensions`, on the two-chapter fixture.
void main() {
  Map<String, Object?> topic(
    String id, {
    Map<String, Object?>? visibleWhen,
    Map<String, Object?>? trigger,
    List<Map<String, Object?>>? effects,
    List<String> answer = const ['answer_1'],
  }) => {
    'id': id,
    'promptKey': 'q_$id',
    'answer': answer,
    'visibleWhen': ?visibleWhen,
    'trigger': ?trigger,
    'do': ?effects,
  };

  Map<String, Object?> gardener({
    Object? greeting = const {'first': 'hello', 'then': 'again'},
    List<Map<String, Object?>>? topics,
  }) => {
    'id': 'gardener',
    'nameKey': 'gardener_name',
    'portrait': {'placeholderStyle': 'plain'},
    'greeting': greeting,
    'noReactionKey': 'gardener_no_reaction',
    'topics':
        topics ??
        [
          topic(
            'about_garden',
            answer: ['garden_1', 'garden_2'],
            effects: [
              {
                'addNoteEntry': {
                  'note': 'person_gardener',
                  'entry': 'works_here',
                },
              },
            ],
          ),
          topic(
            'about_key',
            visibleWhen: {
              'not': {'hasItem': 'key'},
            },
          ),
          topic(
            'give_key',
            trigger: {'showItem': 'key'},
            effects: [
              {'consumeItem': 'key'},
              {'say': 'say_key_given'},
            ],
          ),
          topic('show_file', trigger: {'showNote': 'person_gardener'}),
        ],
  };

  String dialoguesFile(Map<String, Object?> content) =>
      jsonEncode({'formatVersion': 1, ...content});

  AssetDialogueCatalogRepository repository(
    Map<String, String?> overrides, {
    int? chapterLimit,
  }) => AssetDialogueCatalogRepository(
    ContentAssetSource(twoChapterBundle(overrides)),
    const CodecRuleParser(),
    chapterLimit: chapterLimit,
  );

  Future<Map<String, DialogueDefinition>> load(
    Map<String, String?> overrides, {
    int? chapterLimit,
  }) async => (await repository(
    overrides,
    chapterLimit: chapterLimit,
  ).loadDialogues('case01')).valueOrNull!;

  Future<String> failure(Map<String, String?> overrides) async {
    final result = await repository(overrides).loadDialogues('case01');
    expect(result.failureOrNull, isA<ContentFailure>());
    return result.failureOrNull!.message;
  }

  /// Chapter 1 with the gardener's dialogue.
  Map<String, String?> withGardener([Map<String, Object?>? dialogue]) => {
    ch1('dialogues.json'): dialoguesFile({
      'dialogues': [dialogue ?? gardener()],
    }),
  };

  test('dialogues are optional: a case without them has none', () async {
    expect(await load({}), isEmpty);
  });

  test('a dialogue is read with greeting, portrait and topics', () async {
    final dialogue = (await load(withGardener()))['gardener']!;

    expect(dialogue.nameKey, 'gardener_name');
    expect(dialogue.noReactionKey, 'gardener_no_reaction');
    expect(
      dialogue.portrait,
      const DialoguePortrait(placeholderStyle: 'plain'),
    );
    expect(
      dialogue.greeting,
      const DialogueGreeting('hello', thenKey: 'again'),
    );
    expect(dialogue.topics, const [
      DialogueTopic(
        id: 'about_garden',
        promptKey: 'q_about_garden',
        answer: ['garden_1', 'garden_2'],
        effects: [
          AddNoteEntry(noteId: 'person_gardener', entryId: 'works_here'),
        ],
      ),
      DialogueTopic(
        id: 'about_key',
        promptKey: 'q_about_key',
        answer: ['answer_1'],
        visibleWhen: Not(HasItem('key')),
      ),
      DialogueTopic(
        id: 'give_key',
        promptKey: 'q_give_key',
        answer: ['answer_1'],
        trigger: ShowItem('key'),
        effects: [ConsumeItem('key'), Say('say_key_given')],
      ),
      DialogueTopic(
        id: 'show_file',
        promptKey: 'q_show_file',
        answer: ['answer_1'],
        trigger: ShowNote('person_gardener'),
      ),
    ]);
  });

  test('a greeting can be a single text key', () async {
    final dialogue = (await load(
      withGardener(gardener(greeting: 'hello')),
    ))['gardener']!;

    expect(dialogue.greeting, const DialogueGreeting('hello'));
  });

  test('a portrait can name real artwork', () async {
    final dialogue = (await load(
      withGardener({
        ...gardener(),
        'portrait': {
          'placeholderStyle': 'plain',
          'image': 'assets/portraits/gardener.webp',
        },
      }),
    ))['gardener']!;

    expect(dialogue.portrait.image, 'assets/portraits/gardener.webp');
  });

  test('dialogues can live in a folder, read in name order', () async {
    final dialogues = await load({
      ch1('dialogues/b_gardener.json'): dialoguesFile({
        'dialogues': [gardener()],
      }),
      ch1('dialogues/a_cook.json'): dialoguesFile({
        'dialogues': [
          {...gardener(), 'id': 'cook'},
        ],
      }),
    });

    expect(dialogues.keys, ['cook', 'gardener']);
  });

  test('the real content loads: two dialogues, the letter is shown to the '
      'café owner only', () async {
    final dialogues = (await AssetDialogueCatalogRepository(
      ContentAssetSource(realContentBundle()),
      const CodecRuleParser(),
    ).loadDialogues('case01')).valueOrNull!;

    expect(dialogues.keys, ['pharmacist', 'cafe_owner']);
    expect(
      dialogues['cafe_owner']!.topic('show_letter')!.trigger,
      const ShowNote('hall_letter'),
    );
    expect(dialogues['pharmacist']!.topic('show_letter'), isNull);
    expect(
      dialogues['pharmacist']!.topic('give_pills')!.trigger,
      const ShowItem('pill_bottle'),
    );
  });

  group('malformed content', () {
    test('a greeting must be a key or first + then', () async {
      for (final greeting in <Object?>[
        {'first': 'hello'},
        {'then': 'again'},
        {'first': 'hello', 'then': ''},
        '',
        7,
      ]) {
        final message = await failure(
          withGardener(gardener(greeting: greeting)),
        );

        expect(message, contains('dialogues.json'), reason: '$greeting');
        expect(message, contains('greeting'), reason: '$greeting');
      }
    });

    test('an unknown greeting key is named', () async {
      final message = await failure(
        withGardener(
          gardener(greeting: {'first': 'a', 'then': 'b', 'later': 'c'}),
        ),
      );

      expect(message, contains('dialogue "gardener"'));
      expect(message, contains('Unknown "greeting" keys: later'));
    });

    test('a trigger needs exactly one of showItem / showNote', () async {
      for (final trigger in <Map<String, Object?>>[
        {},
        {'showItem': 'key', 'showNote': 'person_gardener'},
        {'show': 'key'},
        {'showItem': ''},
        {'showItem': 3},
      ]) {
        final message = await failure(
          withGardener(
            gardener(topics: [topic('broken', trigger: trigger)]),
          ),
        );

        expect(message, contains('topic "broken"'), reason: '$trigger');
        expect(
          message,
          contains('exactly one of "showItem" or "showNote"'),
          reason: '$trigger',
        );
      }
    });

    test('a broken condition or effect names dialogue and topic', () async {
      final condition = await failure(
        withGardener(
          gardener(
            topics: [
              topic('broken', visibleWhen: {'hasItm': 'key'}),
            ],
          ),
        ),
      );
      final effect = await failure(
        withGardener(
          gardener(
            topics: [
              topic(
                'broken',
                effects: [
                  {'sayy': 'x'},
                ],
              ),
            ],
          ),
        ),
      );

      expect(condition, contains('dialogue "gardener": topic "broken"'));
      expect(condition, contains('Unknown condition "hasItm"'));
      expect(effect, contains('Unknown effect "sayy"'));
    });

    test('a missing required field is reported', () async {
      final dialogue = gardener()..remove('noReactionKey');

      final message = await failure(withGardener(dialogue));

      expect(message, contains('noReactionKey'));
    });

    test('an unknown field is rejected', () async {
      final message = await failure(
        withGardener({...gardener(), 'mood': 'grumpy'}),
      );

      expect(message, contains('mood'));
    });

    test('the same dialogue ID twice is an error', () async {
      final message = await failure({
        ch1('dialogues.json'): dialoguesFile({
          'dialogues': [gardener(), gardener()],
        }),
      });

      expect(message, contains('duplicate dialogue ID "gardener"'));
    });
  });

  group('dialogueExtensions', () {
    Map<String, String?> extended(Map<String, Object?> extension) => {
      ...withGardener(),
      ch2('dialogues.json'): dialoguesFile({
        'dialogueExtensions': [extension],
      }),
    };

    test('a later chapter appends topics to an earlier dialogue', () async {
      final dialogue = (await load(
        extended({
          'dialogue': 'gardener',
          'topics': [
            topic('about_cellar', visibleWhen: {'visited': 'cellar'}),
          ],
        }),
      ))['gardener']!;

      expect(dialogue.topics.map((topic) => topic.id), [
        'about_garden',
        'about_key',
        'give_key',
        'show_file',
        'about_cellar',
      ]);
      expect(dialogue.topics.last.visibleWhen, const Visited('cellar'));
      // The rest of the dialogue is what chapter 1 wrote.
      expect(
        dialogue.greeting,
        const DialogueGreeting('hello', thenKey: 'again'),
      );
      expect(dialogue.nameKey, 'gardener_name');
    });

    test('without the later chapter the dialogue is as chapter 1 wrote '
        'it', () async {
      final dialogue = (await load(
        extended({
          'dialogue': 'gardener',
          'topics': [topic('about_cellar')],
        }),
        chapterLimit: 1,
      ))['gardener']!;

      expect(dialogue.topics, hasLength(4));
    });

    test('an unknown dialogue is an error', () async {
      final message = await failure(
        extended({'dialogue': 'cook', 'topics': <Object>[]}),
      );

      expect(message, contains('dialogueExtensions: unknown dialogue "cook"'));
    });

    test('a dialogue of the same chapter cannot be extended', () async {
      final message = await failure({
        ch1('dialogues.json'): dialoguesFile({
          'dialogues': [gardener()],
          'dialogueExtensions': [
            {'dialogue': 'gardener', 'topics': <Object>[]},
          ],
        }),
      });

      expect(message, contains('"gardener" is not from an earlier chapter'));
    });

    test('a topic ID the dialogue already has is an error', () async {
      final message = await failure(
        extended({
          'dialogue': 'gardener',
          'topics': [topic('about_key')],
        }),
      );

      expect(
        message,
        contains(
          'dialogueExtensions "gardener": topic ID "about_key" already '
          'exists',
        ),
      );
    });

    test('a broken topic in an extension names the file', () async {
      final message = await failure(
        extended({
          'dialogue': 'gardener',
          'topics': [
            topic('broken', trigger: {'show': 'key'}),
          ],
        }),
      );

      expect(message, contains('ch02/dialogues.json'));
      expect(message, contains('dialogueExtensions "gardener"'));
    });
  });
}
