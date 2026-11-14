import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:detective_dark/features/scene_engine/domain/services/interaction_resolver.dart';
import 'package:detective_dark/features/scene_engine/domain/services/scene_view_resolver.dart';
import 'package:equatable/equatable.dart';

/// What a tap changed and what the caller still has to show.
class TapOutcome extends Equatable {
  const TapOutcome({
    required this.progress,
    this.navigation,
    this.inspectionId,
    this.dialogueId,
    this.shownItemId,
  });

  /// The progress after the tap (unchanged when nothing happened).
  final GameProgress progress;

  /// A scene change to start, if the rule asked for one.
  final GoToScene? navigation;

  /// An inspection to open, if the rule asked for one.
  final String? inspectionId;

  /// A conversation to open, if the rule asked for one (`talk`).
  final String? dialogueId;

  /// The selected item, when it is to be shown to the character of
  /// [dialogueId] once the conversation is open.
  final String? shownItemId;

  @override
  List<Object?> get props => [
    progress,
    navigation,
    inspectionId,
    dialogueId,
    shownItemId,
  ];
}

/// Handles a tap on a hotspot: pick the rule and hand its effects to the
/// [EffectPipeline], which saves once and then announces what happened.
class TapHotspot {
  const TapHotspot({
    required this._pipeline,
    required this._clock,
    this._resolver = const InteractionResolver(),
    this._viewResolver = const SceneViewResolver(),
  });

  final EffectPipeline _pipeline;
  final Clock _clock;
  final InteractionResolver _resolver;
  final SceneViewResolver _viewResolver;

  /// [usingItemId] is the item selected in the inventory, if any.
  /// [triggers] are the triggers of the case; they are evaluated in the
  /// same save as the tap.
  Future<Result<TapOutcome>> call({
    required SceneDefinition scene,
    required GameProgress progress,
    required String hotspotId,
    String? usingItemId,
    List<TriggerDefinition> triggers = const [],
  }) async {
    final hotspot = scene.hotspot(hotspotId);
    // A hotspot that is gone or hidden cannot be tapped (e.g. a tap that
    // was already on its way when the object was picked up).
    if (hotspot == null || !_viewResolver.isVisible(scene, hotspot, progress)) {
      return Success(TapOutcome(progress: progress));
    }

    // An item the player does not carry cannot be used.
    final selected = usingItemId != null && progress.hasItem(usingItemId)
        ? usingItemId
        : null;
    final resolved = _resolver.resolve(
      hotspot,
      progress,
      usingItemId: selected,
    );
    final outcome = await _pipeline.run(
      progress: progress,
      effects: resolved.effects,
      triggers: triggers,
      context: EffectContext(
        sceneId: scene.id,
        hotspotId: hotspot.id,
        usedItemId: resolved.usedItemId,
        nowUtcMs: _clock.nowUtc().millisecondsSinceEpoch,
      ),
    );

    return switch (outcome) {
      Success(:final value) => Success(
        TapOutcome(
          progress: value.progress,
          navigation: value.navigation,
          inspectionId: value.inspectionId,
          dialogueId: value.dialogueId,
          shownItemId: value.dialogueId == null ? null : resolved.shownItemId,
        ),
      ),
      Failed(:final failure) => Failed(failure),
    };
  }
}
