import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:equatable/equatable.dart';

/// One chapter of a case and the scene it starts in.
class ChapterDefinition extends Equatable {
  const ChapterDefinition({required this.id, required this.entrySceneId});

  final String id;
  final String entrySceneId;

  @override
  List<Object?> get props => [id, entrySceneId];
}

/// A case: its chapters, in play order. Chapter end conditions and the
/// accusation are added in Phase 5.
class CaseDefinition extends Equatable {
  const CaseDefinition({required this.id, required this.chapters});

  final String id;
  final List<ChapterDefinition> chapters;

  @override
  List<Object?> get props => [id, chapters];
}

/// Every scene, inspection and trigger of a case, loaded as a whole.
///
/// The case is loaded at once because items, notes and messages travel
/// between chapters; IDs are unique inside the case.
class CaseContent extends Equatable {
  const CaseContent({
    required this.definition,
    required this.scenes,
    required this.inspections,
    this.sceneChapters = const {},
    this.triggers = const [],
  });

  final CaseDefinition definition;

  /// Scenes by ID.
  final Map<String, SceneDefinition> scenes;

  /// Inspections by ID.
  final Map<String, InspectionDefinition> inspections;

  /// The chapter each scene belongs to: scene ID → chapter ID.
  final Map<String, String> sceneChapters;

  /// The triggers of all chapters: chapter order, then file order. That is
  /// the order they are evaluated in.
  final List<TriggerDefinition> triggers;

  /// The same content with other [triggers].
  CaseContent copyWithTriggers(List<TriggerDefinition> triggers) => CaseContent(
    definition: definition,
    scenes: scenes,
    inspections: inspections,
    sceneChapters: sceneChapters,
    triggers: triggers,
  );

  @override
  List<Object?> get props => [
    definition,
    scenes,
    inspections,
    sceneChapters,
    triggers,
  ];
}
