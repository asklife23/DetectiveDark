import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_loading.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/dialogue/data/models/dialogue_dto.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/repositories/dialogue_catalog_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/services/rule_parser.dart';

/// Loads the conversations from the dialogue files of every chapter
/// (`dialogues.json` or `dialogues/*.json`, both optional) and merges the
/// `dialogueExtensions` of later chapters into the dialogues of earlier
/// ones (ADR 0018).
///
/// Conditions and effects inside topics are parsed by the [RuleParser] it
/// is given (the scene engine's codecs, handed over by dependency
/// injection).
class AssetDialogueCatalogRepository implements DialogueCatalogRepository {
  const AssetDialogueCatalogRepository(
    this._source,
    this._rules, {
    this.chapterLimit,
  });

  final ContentAssetSource _source;
  final RuleParser _rules;

  /// Loads only the first N chapters (content validation per prefix).
  final int? chapterLimit;

  @override
  Future<Result<Map<String, DialogueDefinition>>> loadDialogues(
    String caseId,
  ) {
    return guardContent(() async {
      final manifest = await CaseManifest.read(
        _source,
        caseId,
        chapterLimit: chapterLimit,
      );
      final dialogues = <String, DialogueDefinition>{};
      // Dialogues of the chapters before the one being read: the only ones
      // an extension may target.
      var earlierIds = <String>{};

      for (final chapter in manifest.chapters) {
        final files = await readChapterFiles(
          _source,
          chapter,
          ContentType.dialogues,
          DialoguesFileDto.fromJson,
        );
        for (final (file, content) in files) {
          final entities = inContentFile(
            file,
            () => [for (final dto in content.dialogues) dto.toEntity(_rules)],
          );
          mergeUnique(
            dialogues,
            entities.map((dialogue) => MapEntry(dialogue.id, dialogue)),
            file: file,
            kind: 'dialogue',
          );
        }
        for (final (file, content) in files) {
          for (final extension in content.dialogueExtensions) {
            final target = dialogues[extension.dialogue];
            if (target == null) {
              throw ContentException(
                file,
                'dialogueExtensions: unknown dialogue '
                '"${extension.dialogue}"',
              );
            }
            if (!earlierIds.contains(extension.dialogue)) {
              throw ContentException(
                file,
                'dialogueExtensions: dialogue "${extension.dialogue}" is '
                'not from an earlier chapter; edit the dialogue itself',
              );
            }
            dialogues[extension.dialogue] = inContentFile(
              file,
              () => extension.applyTo(target, _rules),
            );
          }
        }
        earlierIds = dialogues.keys.toSet();
      }

      return Map.unmodifiable(dialogues);
    });
  }
}
