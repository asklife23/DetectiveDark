import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_loading.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/notebook/data/models/note_dto.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/notebook/domain/repositories/note_catalog_repository.dart';

/// Loads the note catalog from the `notes.json` of every chapter.
class AssetNoteCatalogRepository implements NoteCatalogRepository {
  const AssetNoteCatalogRepository(this._source);

  final ContentAssetSource _source;

  @override
  Future<Result<Map<String, NoteDefinition>>> loadNotes(String caseId) {
    return guardContent(() async {
      final manifest = await CaseManifest.read(_source, caseId);
      final notes = <String, NoteDefinition>{};

      for (final chapter in manifest.chapters) {
        final path = ContentPaths.chapterFile(
          caseId,
          chapter.id,
          ContentPaths.notesFile,
        );
        final chapterNotes = parseContentFile(
          path,
          await _source.readObject(path),
          (json) => NotesFileDto.fromJson(json).notes,
        );
        mergeUnique(
          notes,
          chapterNotes.map((note) => MapEntry(note.id, note.toEntity())),
          file: path,
          kind: 'note',
        );
      }

      return Map.unmodifiable(notes);
    });
  }
}
