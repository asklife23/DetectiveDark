import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/ask_topic.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/start_conversation.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';

import 'game_harness.dart';

/// Hand-built conversations for tests that should not depend on the JSON
/// content: a pharmacist and a café owner, shaped like the market demo.

const pillBottle = 'pill_bottle';
const hallLetter = 'hall_letter';

const pharmacist = DialogueDefinition(
  id: 'pharmacist',
  nameKey: 'pharmacist_name',
  portrait: DialoguePortrait(placeholderStyle: 'plain'),
  greeting: DialogueGreeting('pharmacist_hello', thenKey: 'pharmacist_again'),
  noReactionKey: 'pharmacist_no_reaction',
  topics: [
    DialogueTopic(
      id: 'about_villa',
      promptKey: 'q_villa',
      answer: ['villa_1', 'villa_2'],
      effects: [AddNoteEntry(noteId: 'person_pharmacist', entryId: 'knows')],
    ),
    DialogueTopic(
      id: 'about_night',
      promptKey: 'q_night',
      answer: ['night_1'],
    ),
    DialogueTopic(
      id: 'ask_pills',
      promptKey: 'q_pills',
      answer: ['pills_1'],
      visibleWhen: HasItem(pillBottle),
      effects: [Say('say_pills_owner_known')],
    ),
    DialogueTopic(
      id: 'give_pills',
      promptKey: 'q_give_pills',
      answer: ['give_1', 'give_2'],
      trigger: ShowItem(pillBottle),
      effects: [
        ConsumeItem(pillBottle),
        AddNoteEntry(noteId: 'person_pharmacist', entryId: 'prescribed'),
      ],
    ),
  ],
);

const cafeOwner = DialogueDefinition(
  id: 'cafe_owner',
  nameKey: 'cafe_owner_name',
  portrait: DialoguePortrait(placeholderStyle: 'plain'),
  // A greeting with a single form.
  greeting: DialogueGreeting('cafe_owner_hello'),
  noReactionKey: 'cafe_owner_no_reaction',
  topics: [
    DialogueTopic(
      id: 'about_villa',
      promptKey: 'q_villa',
      answer: ['cafe_villa_1'],
      effects: [SetFlag('cafe_owner_talked')],
    ),
    DialogueTopic(
      id: 'show_letter',
      promptKey: 'q_letter',
      answer: ['letter_1'],
      trigger: ShowNote(hallLetter),
    ),
  ],
);

/// Fires once both were asked about the villa.
const bothAskedAboutVilla = TriggerDefinition(
  id: 'both_asked_about_villa',
  when: AtLeast(2, [
    HasAsked(dialogueId: 'pharmacist', topicId: 'about_villa'),
    HasAsked(dialogueId: 'cafe_owner', topicId: 'about_villa'),
  ]),
  effects: [Say('say_stories_do_not_match'), AddNote('obs_stories')],
);

/// The dialogue use cases wired to a real effect pipeline, progress in
/// memory and a fixed clock; saves and events are recorded.
class DialogueHarness {
  DialogueHarness({ProgressRepository? progressRepository})
    : progress = progressRepository ?? InMemoryProgressRepository() {
    bus.events.listen(events.add);
    progress.watch().listen(saves.add);
  }

  final ProgressRepository progress;
  final bus = GameEventBus();

  /// Every event published so far.
  final events = <GameEvent>[];

  /// Every progress that was saved.
  final saves = <GameProgress>[];

  late final pipeline = EffectPipeline(
    progressRepository: progress,
    eventBus: bus,
  );
  late final startConversation = StartConversation(
    pipeline: pipeline,
    clock: GameHarness.clock,
  );
  late final askTopic = AskTopic(pipeline: pipeline, clock: GameHarness.clock);

  Future<void> dispose() => bus.dispose();
}
