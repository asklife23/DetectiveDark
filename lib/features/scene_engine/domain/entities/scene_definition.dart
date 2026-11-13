import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:equatable/equatable.dart';

/// A place the player can be in: a main location or one of its close-ups.
class SceneDefinition extends Equatable {
  const SceneDefinition({
    required this.id,
    required this.titleKey,
    required this.visual,
    this.parentId,
    this.visualVariants = const [],
    this.hotspots = const [],
    this.onFirstEnter = const [],
  });

  final String id;

  /// The scene Back returns to. Null for a main location.
  final String? parentId;

  final String titleKey;

  /// The default look.
  final SceneVisual visual;

  /// Looks that depend on the state. The first variant whose condition
  /// holds wins; otherwise [visual] is used.
  final List<VisualVariant> visualVariants;

  final List<HotspotDefinition> hotspots;

  /// Effects that run once, the first time the player enters. Limited to
  /// `say`, `setFlag`, `addNote` and `giveItem`.
  final List<Effect> onFirstEnter;

  HotspotDefinition? hotspot(String hotspotId) {
    for (final hotspot in hotspots) {
      if (hotspot.id == hotspotId) return hotspot;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    parentId,
    titleKey,
    visual,
    visualVariants,
    hotspots,
    onFirstEnter,
  ];
}
