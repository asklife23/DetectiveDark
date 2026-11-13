import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/interaction_resolver.dart';
import 'package:detective_dark/features/scene_engine/domain/services/scene_view_resolver.dart';
import 'package:equatable/equatable.dart';

/// What a tap changed and what the caller still has to show.
class TapOutcome extends Equatable {
  const TapOutcome({
    required this.progress,
    this.navigation,
    this.inspectionId,
  });

  /// The progress after the tap (unchanged when nothing happened).
  final GameProgress progress;

  /// A scene change to start, if the rule asked for one.
  final GoToScene? navigation;

  /// An inspection to open, if the rule asked for one.
  final String? inspectionId;

  @override
  List<Object?> get props => [progress, navigation, inspectionId];
}

/// Handles a tap on a hotspot: pick the rule, compute the new progress,
/// save it once, then announce what happened.
class TapHotspot {
  const TapHotspot({
    required this._progressRepository,
    required this._eventBus,
    required this._clock,
    this._resolver = const InteractionResolver(),
    this._effectApplier = const EffectApplier(),
    this._viewResolver = const SceneViewResolver(),
  });

  final ProgressRepository _progressRepository;
  final GameEventBus _eventBus;
  final Clock _clock;
  final InteractionResolver _resolver;
  final EffectApplier _effectApplier;
  final SceneViewResolver _viewResolver;

  /// [usingItemId] is the item selected in the inventory, if any.
  Future<Result<TapOutcome>> call({
    required SceneDefinition scene,
    required GameProgress progress,
    required String hotspotId,
    String? usingItemId,
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
    final outcome = _effectApplier.apply(
      progress,
      resolved.effects,
      EffectContext(
        sceneId: scene.id,
        hotspotId: hotspot.id,
        usedItemId: resolved.usedItemId,
        nowUtcMs: _clock.nowUtc().millisecondsSinceEpoch,
      ),
    );

    if (outcome.progress != progress) {
      final saved = await _progressRepository.save(outcome.progress);
      if (saved case Failed(:final failure)) return Failed(failure);
    }

    _eventBus.publishAll(outcome.events);
    return Success(
      TapOutcome(
        progress: outcome.progress,
        navigation: outcome.navigation,
        inspectionId: outcome.inspectionId,
      ),
    );
  }
}
