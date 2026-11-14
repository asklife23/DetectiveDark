import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_loading.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/scene_engine/data/models/inspection_dto.dart';
import 'package:detective_dark/features/scene_engine/data/models/scene_dto.dart';
import 'package:detective_dark/features/scene_engine/data/models/trigger_dto.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';

/// Loads scenes, inspections and triggers from the JSON files in the asset
/// bundle.
class AssetSceneContentRepository implements SceneContentRepository {
  const AssetSceneContentRepository(this._source);

  final ContentAssetSource _source;

  @override
  Future<Result<CaseContent>> loadCase(String caseId) {
    return guardContent(() async {
      final manifest = await CaseManifest.read(_source, caseId);
      final scenes = <String, SceneDefinition>{};
      final inspections = <String, InspectionDefinition>{};
      final sceneChapters = <String, String>{};
      final triggers = <String, TriggerDefinition>{};

      for (final chapter in manifest.chapters) {
        final scenesPath = ContentPaths.chapterFile(
          caseId,
          chapter.id,
          ContentPaths.scenesFile,
        );
        final chapterScenes = parseContentFile(
          scenesPath,
          await _source.readObject(scenesPath),
          (json) => ScenesFileDto.fromJson(
            json,
          ).scenes.map((scene) => scene.toEntity()).toList(),
        );
        mergeUnique(
          scenes,
          chapterScenes.map((scene) => MapEntry(scene.id, scene)),
          file: scenesPath,
          kind: 'scene',
        );
        for (final scene in chapterScenes) {
          sceneChapters[scene.id] = chapter.id;
        }

        final inspectionsPath = ContentPaths.chapterFile(
          caseId,
          chapter.id,
          ContentPaths.inspectionsFile,
        );
        final chapterInspections = parseContentFile(
          inspectionsPath,
          await _source.readObject(inspectionsPath),
          (json) => InspectionsFileDto.fromJson(
            json,
          ).inspections.map((inspection) => inspection.toEntity()).toList(),
        );
        mergeUnique(
          inspections,
          chapterInspections.map((item) => MapEntry(item.id, item)),
          file: inspectionsPath,
          kind: 'inspection',
        );

        final triggersPath = ContentPaths.chapterFile(
          caseId,
          chapter.id,
          ContentPaths.triggersFile,
        );
        final triggersJson = await _source.readOptionalObject(triggersPath);
        if (triggersJson != null) {
          final chapterTriggers = parseContentFile(
            triggersPath,
            triggersJson,
            (json) => TriggersFileDto.fromJson(
              json,
            ).triggers.map((trigger) => trigger.toEntity()).toList(),
          );
          // A map literal keeps insertion order: chapter, then file order.
          mergeUnique(
            triggers,
            chapterTriggers.map((trigger) => MapEntry(trigger.id, trigger)),
            file: triggersPath,
            kind: 'trigger',
          );
        }
      }

      return CaseContent(
        definition: CaseDefinition(
          id: manifest.id,
          chapters: List.unmodifiable(
            manifest.chapters.map(
              (chapter) => ChapterDefinition(
                id: chapter.id,
                entrySceneId: chapter.entrySceneId,
              ),
            ),
          ),
        ),
        scenes: Map.unmodifiable(scenes),
        inspections: Map.unmodifiable(inspections),
        sceneChapters: Map.unmodifiable(sceneChapters),
        triggers: List.unmodifiable(triggers.values),
      );
    });
  }
}
