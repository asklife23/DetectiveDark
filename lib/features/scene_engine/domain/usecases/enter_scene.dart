import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/scene_stack_resolver.dart';

/// Moves the player into a scene.
///
/// One save covers everything that belongs to the arrival: the new
/// navigation stack, the "visited" mark and, on the first visit, the
/// `onFirstEnter` effects of the scene. Events are published only after the
/// save succeeded.
class EnterScene {
  const EnterScene({
    required this._progressRepository,
    required this._eventBus,
    required this._clock,
    this._stackResolver = const SceneStackResolver(),
    this._effectApplier = const EffectApplier(),
  });

  final ProgressRepository _progressRepository;
  final GameEventBus _eventBus;
  final Clock _clock;
  final SceneStackResolver _stackResolver;
  final EffectApplier _effectApplier;

  Future<Result<GameProgress>> call({
    required CaseContent content,
    required GameProgress progress,
    required String sceneId,
  }) async {
    final stack = _stackResolver.stackFor(sceneId, content.scenes);
    if (stack case Failed(:final failure)) return Failed(failure);
    final scene = content.scenes[sceneId]!;

    final isFirstVisit = !progress.hasVisited(sceneId);
    final arrived = progress
        .withSceneStack(stack.valueOrNull!)
        .withVisited(sceneId);

    final outcome = _effectApplier.apply(
      arrived,
      isFirstVisit ? scene.onFirstEnter : const [],
      EffectContext(
        sceneId: sceneId,
        nowUtcMs: _clock.nowUtc().millisecondsSinceEpoch,
      ),
    );

    final saved = await _progressRepository.save(outcome.progress);
    if (saved case Failed(:final failure)) return Failed(failure);

    _eventBus
      ..publish(SceneEntered(sceneId, isFirstVisit: isFirstVisit))
      ..publishAll(outcome.events);
    return Success(outcome.progress);
  }
}
