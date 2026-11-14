import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_view_resolver.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:equatable/equatable.dart';

/// What opening a conversation led to.
class ConversationStart extends Equatable {
  const ConversationStart({required this.progress, required this.greetingKey});

  /// The progress afterwards (unchanged unless a first greeting was heard).
  final GameProgress progress;

  /// The line the character opens with.
  final String greetingKey;

  @override
  List<Object?> get props => [progress, greetingKey];
}

/// Opens a conversation: picks the greeting and remembers that the first
/// greeting was heard.
///
/// The `talk` effect itself saves nothing (the open panel is interface
/// state). The one lasting change of opening a conversation is this mark in
/// `spokenLines`, and like every change it goes through the effect
/// pipeline: triggers are evaluated and there is one save.
class StartConversation {
  const StartConversation({
    required this._pipeline,
    required this._clock,
    this._viewResolver = const DialogueViewResolver(),
  });

  final EffectPipeline _pipeline;
  final Clock _clock;
  final DialogueViewResolver _viewResolver;

  /// [triggers] are the triggers of the case (`CaseContent.triggers`).
  Future<Result<ConversationStart>> call({
    required DialogueDefinition dialogue,
    required GameProgress progress,
    required List<TriggerDefinition> triggers,
  }) async {
    final greetingKey = _viewResolver.greetingKey(dialogue, progress);
    final greeting = dialogue.greeting;

    final outcome = await _pipeline.run(
      progress: progress,
      // Only a two-form greeting needs to be remembered.
      prepare: greeting.thenKey == null
          ? null
          : (progress) => progress.withSpokenLine(greeting.firstKey),
      context: EffectContext(
        sceneId: progress.currentSceneId ?? '',
        nowUtcMs: _clock.nowUtc().millisecondsSinceEpoch,
      ),
      triggers: triggers,
    );

    return switch (outcome) {
      Success(:final value) => Success(
        ConversationStart(progress: value.progress, greetingKey: greetingKey),
      ),
      Failed(:final failure) => Failed(failure),
    };
  }
}
