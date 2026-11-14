import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';

/// The one path on which the game changes its progress (ADR 0014).
///
/// Every use case that changes the progress (a tap on a hotspot, entering a
/// scene, and later dialogue topics, the developer menu and solved puzzles)
/// hands its effects to [run]. The order is fixed:
///
/// 1. the optional `prepare` change and the effects become **one** new
///    progress ([EffectApplier], pure);
/// 2. triggers run on that progress;
/// 3. if anything changed, it is saved **once**; a failed save ends the run
///    with `Failed` and nothing is announced;
/// 4. the events are published.
///
/// So a new feature never writes its own save-and-publish code, and a
/// half-applied state can neither be stored nor announced.
///
/// The only other caller of `ProgressRepository.save` is `MarkNoteRead`
/// (the architecture test enforces that).
class EffectPipeline {
  const EffectPipeline({
    required this._progressRepository,
    required this._eventBus,
    this._effectApplier = const EffectApplier(),
  });

  final ProgressRepository _progressRepository;
  final GameEventBus _eventBus;
  final EffectApplier _effectApplier;

  /// Applies [effects] to [progress] and stores the result.
  ///
  /// [prepare] is a change that belongs to the same save but is not an
  /// effect (the new navigation stack and the "visited" mark of an
  /// arrival). [leadingEvents] are published before the events of the
  /// effects (`SceneEntered`).
  ///
  /// The returned outcome carries the saved progress and every published
  /// event, in order.
  Future<Result<EffectOutcome>> run({
    required GameProgress progress,
    required EffectContext context,
    List<Effect> effects = const [],
    GameProgress Function(GameProgress progress)? prepare,
    List<GameEvent> leadingEvents = const [],
  }) async {
    final prepared = prepare == null ? progress : prepare(progress);
    final applied = _effectApplier.apply(prepared, effects, context);
    final outcome = _runTriggers(applied, context);

    if (outcome.progress != progress) {
      final saved = await _progressRepository.save(outcome.progress);
      if (saved case Failed(:final failure)) return Failed(failure);
    }

    final events = List<GameEvent>.unmodifiable([
      ...leadingEvents,
      ...outcome.events,
    ]);
    _eventBus.publishAll(events);
    return Success(
      EffectOutcome(
        progress: outcome.progress,
        events: events,
        navigation: outcome.navigation,
        inspectionId: outcome.inspectionId,
      ),
    );
  }

  /// The hook for triggers: rules that run once when their condition first
  /// holds. Empty for now; step 1.12 fills it.
  EffectOutcome _runTriggers(EffectOutcome applied, EffectContext context) =>
      applied;
}
