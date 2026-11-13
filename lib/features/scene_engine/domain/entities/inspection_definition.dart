import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:equatable/equatable.dart';

/// The content of the inspection panel: an image and a short text, shown
/// above the scene without leaving it (ADR 0010).
class InspectionDefinition extends Equatable {
  const InspectionDefinition({
    required this.id,
    required this.textKey,
    required this.visual,
    this.titleKey,
  });

  final String id;
  final String? titleKey;
  final String textKey;
  final SceneVisual visual;

  @override
  List<Object?> get props => [id, titleKey, textKey, visual];
}
