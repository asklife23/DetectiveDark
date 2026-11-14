import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:detective_dark/features/scene_engine/domain/services/scene_stack_resolver.dart';

/// Moves the player into a scene.
///
/// One save covers everything that belongs to the arrival: the new
/// navigation stack, the "visited" mark and, on the first visit, the
/// `onFirstEnter` effects of the scene. Saving and announcing is the job of
/// the [EffectPipeline].
class EnterScene {
  const EnterScene({
    required this._pipeline,
    required this._clock,
    this._stackResolver = const SceneStackResolver(),
  });

  final EffectPipeline _pipeline;
  final Clock _clock;
  final SceneStackResolver _stackResolver;

  Future<Result<GameProgress>> call({
    required CaseContent content,
    required GameProgress progress,
    required String sceneId,
  }) async {
    final stack = _stackResolver.stackFor(sceneId, content.scenes);
    if (stack case Failed(:final failure)) return Failed(failure);
    final scene = content.scenes[sceneId]!;

    final isFirstVisit = !progress.hasVisited(sceneId);
    final outcome = await _pipeline.run(
      progress: progress,
      prepare: (progress) =>
          progress.withSceneStack(stack.valueOrNull!).withVisited(sceneId),
      effects: isFirstVisit ? scene.onFirstEnter : const [],
      context: EffectContext(
        sceneId: sceneId,
        nowUtcMs: _clock.nowUtc().millisecondsSinceEpoch,
      ),
      leadingEvents: [SceneEntered(sceneId, isFirstVisit: isFirstVisit)],
    );

    return switch (outcome) {
      Success(:final value) => Success(value.progress),
      Failed(:final failure) => Failed(failure),
    };
  }
}
