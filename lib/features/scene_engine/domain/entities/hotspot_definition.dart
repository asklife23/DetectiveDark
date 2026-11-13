import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:equatable/equatable.dart';

/// One rule of a hotspot: when [when] holds (or is absent), run [effects].
class InteractionRule extends Equatable {
  const InteractionRule({required this.effects, this.when});

  final Condition? when;
  final List<Effect> effects;

  @override
  List<Object?> get props => [when, effects];
}

/// A tappable area of a scene.
///
/// Hotspots have no type. What a tap does is decided by [interactions]: the
/// rules are read top to bottom and the first one whose condition holds
/// runs.
class HotspotDefinition extends Equatable {
  const HotspotDefinition({
    required this.id,
    required this.rect,
    required this.labelKey,
    this.interactions = const [],
    this.visibleWhen,
    this.glint = false,
  });

  /// Unique inside its scene.
  final String id;

  final NormalizedRect rect;

  /// Text key of the accessibility label.
  final String labelKey;

  /// While this is false the hotspot does not exist for the player.
  final Condition? visibleWhen;

  final List<InteractionRule> interactions;

  /// A faint glimmer that marks something the player can pick up. A hint
  /// for the presentation only; it never affects the rules.
  final bool glint;

  @override
  List<Object?> get props => [
    id,
    rect,
    labelKey,
    visibleWhen,
    interactions,
    glint,
  ];
}
