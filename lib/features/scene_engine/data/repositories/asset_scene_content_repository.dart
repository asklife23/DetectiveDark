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
///
/// Each kind of content is one file or one folder per chapter, and a later
/// chapter may extend the scenes of an earlier one (`sceneExtensions`, ADR
/// 0018). All of that is resolved here, in the data layer: the domain gets
/// one merged [CaseContent].
class AssetSceneContentRepository implements SceneContentRepository {
  const AssetSceneContentRepository(this._source, {this.chapterLimit});

  final ContentAssetSource _source;

  /// Loads only the first N chapters (content validation per prefix).
  final int? chapterLimit;

  @override
  Future<Result<CaseContent>> loadCase(String caseId) {
    return guardContent(() async {
      final manifest = await CaseManifest.read(
        _source,
        caseId,
        chapterLimit: chapterLimit,
      );
      final scenes = <String, SceneDefinition>{};
      final inspections = <String, InspectionDefinition>{};
      final sceneChapters = <String, String>{};
      final triggers = <String, TriggerDefinition>{};

      for (final chapter in manifest.chapters) {
        final sceneFiles = await readChapterFiles(
          _source,
          chapter,
          ContentType.scenes,
          ScenesFileDto.fromJson,
        );
        _addScenes(sceneFiles, chapter.id, scenes, sceneChapters);
        _applyExtensions(sceneFiles, chapter.id, scenes, sceneChapters);

        final inspectionFiles = await readChapterFiles(
          _source,
          chapter,
          ContentType.inspections,
          InspectionsFileDto.fromJson,
        );
        for (final (file, content) in inspectionFiles) {
          final entities = inContentFile(
            file,
            () => [for (final dto in content.inspections) dto.toEntity()],
          );
          mergeUnique(
            inspections,
            entities.map((inspection) => MapEntry(inspection.id, inspection)),
            file: file,
            kind: 'inspection',
          );
        }

        final triggerFiles = await readChapterFiles(
          _source,
          chapter,
          ContentType.triggers,
          TriggersFileDto.fromJson,
        );
        for (final (file, content) in triggerFiles) {
          final entities = inContentFile(
            file,
            () => [for (final dto in content.triggers) dto.toEntity()],
          );
          // A map literal keeps insertion order: chapter, then file order.
          mergeUnique(
            triggers,
            entities.map((trigger) => MapEntry(trigger.id, trigger)),
            file: file,
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

  /// The scenes a chapter defines itself.
  void _addScenes(
    List<(String, ScenesFileDto)> files,
    String chapterId,
    Map<String, SceneDefinition> scenes,
    Map<String, String> sceneChapters,
  ) {
    for (final (file, content) in files) {
      final entities = inContentFile(
        file,
        () => [for (final dto in content.scenes) dto.toEntity()],
      );
      mergeUnique(
        scenes,
        entities.map((scene) => MapEntry(scene.id, scene)),
        file: file,
        kind: 'scene',
      );
      for (final scene in entities) {
        sceneChapters[scene.id] = chapterId;
      }
    }
  }

  /// What a chapter adds to the scenes of earlier chapters. The extended
  /// scene stays a scene of its own chapter.
  void _applyExtensions(
    List<(String, ScenesFileDto)> files,
    String chapterId,
    Map<String, SceneDefinition> scenes,
    Map<String, String> sceneChapters,
  ) {
    for (final (file, content) in files) {
      for (final extension in content.sceneExtensions) {
        final target = scenes[extension.scene];
        if (target == null) {
          throw ContentException(
            file,
            'sceneExtensions: unknown scene "${extension.scene}"',
          );
        }
        if (sceneChapters[extension.scene] == chapterId) {
          throw ContentException(
            file,
            'sceneExtensions: scene "${extension.scene}" is not from an '
            'earlier chapter; edit the scene itself',
          );
        }
        scenes[extension.scene] = inContentFile(
          file,
          () => extension.applyTo(target),
        );
      }
    }
  }
}
