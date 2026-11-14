import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/condition_evaluator.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:equatable/equatable.dart';

/// What running the triggers led to.
class TriggerRun extends Equatable {
  const TriggerRun({
    required this.outcome,
    this.firedTriggerIds = const [],
    this.hitPassLimit = false,
  });

  /// The outcome that went in, plus the changes and events of every
  /// trigger that fired.
  final EffectOutcome outcome;

  /// The triggers that fired, in the order they ran.
  final List<String> firedTriggerIds;

  /// True when the runner gave up before reaching a fixed point. That
  /// cannot happen with correct code (every trigger fires at most once);
  /// it guards against a bug in the engine. The caller logs it.
  final bool hitPassLimit;

  @override
  List<Object?> get props => [outcome, firedTriggerIds, hitPassLimit];
}

/// Fires the triggers whose condition holds for the first time. Pure Dart:
/// it neither saves nor publishes (the effect pipeline does both).
///
/// The triggers are walked in content order. A trigger whose condition
/// holds applies its effects and is written to `firedTriggers`, so it never
/// runs again. When a pass fired at least one trigger the walk starts over,
/// because one trigger can make the condition of another one true. It ends
/// when a whole pass fires nothing: a **fixed point**.
class TriggerRunner {
  const TriggerRunner({
    this.maxPasses = defaultMaxPasses,
    this._evaluator = const ConditionEvaluator(),
    this._effectApplier = const EffectApplier(),
  });

  /// More passes than any real chapter needs: a chain where every trigger
  /// enables the one written *before* it costs one pass per trigger.
  static const defaultMaxPasses = 100;

  final int maxPasses;
  final ConditionEvaluator _evaluator;
  final EffectApplier _effectApplier;

  /// [applied] is the result of the action that just ran; [nowUtcMs] is
  /// its time. Triggers run in the current scene, without a hotspot.
  TriggerRun run(
    EffectOutcome applied,
    List<TriggerDefinition> triggers, {
    required int nowUtcMs,
  }) {
    var progress = applied.progress;
    final events = <GameEvent>[...applied.events];
    final fired = <String>[];
    var firedInPass = true;
    var passes = 0;

    while (firedInPass && passes < maxPasses) {
      firedInPass = false;
      passes++;
      for (final trigger in triggers) {
        if (progress.hasFired(trigger.id)) continue;
        if (!_evaluator.evaluate(trigger.when, progress)) continue;

        final outcome = _effectApplier.apply(
          progress.withFiredTrigger(trigger.id),
          trigger.effects,
          EffectContext(
            sceneId: progress.currentSceneId ?? '',
            nowUtcMs: nowUtcMs,
          ),
        );
        progress = outcome.progress;
        events.addAll(outcome.events);
        fired.add(trigger.id);
        firedInPass = true;
      }
    }

    return TriggerRun(
      outcome: EffectOutcome(
        progress: progress,
        events: List.unmodifiable(events),
        navigation: applied.navigation,
        inspectionId: applied.inspectionId,
        dialogueId: applied.dialogueId,
      ),
      firedTriggerIds: List.unmodifiable(fired),
      hitPassLimit: firedInPass,
    );
  }
}
