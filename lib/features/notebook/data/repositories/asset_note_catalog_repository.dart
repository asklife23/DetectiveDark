import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_loading.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/notebook/data/models/note_dto.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/notebook/domain/repositories/note_catalog_repository.dart';

/// Loads the note catalog from the note files of every chapter
/// (`notes.json` or `notes/*.json`) and merges the `noteExtensions` of
/// later chapters into the notes of earlier ones (ADR 0018). The domain
/// sees one merged catalog.
class AssetNoteCatalogRepository implements NoteCatalogRepository {
  const AssetNoteCatalogRepository(this._source, {this.chapterLimit});

  final ContentAssetSource _source;

  /// Loads only the first N chapters (content validation per prefix).
  final int? chapterLimit;

  @override
  Future<Result<Map<String, NoteDefinition>>> loadNotes(String caseId) {
    return guardContent(() async {
      final manifest = await CaseManifest.read(
        _source,
        caseId,
        chapterLimit: chapterLimit,
      );
      final notes = <String, NoteDefinition>{};
      // Notes of the chapters before the one being read: the only ones an
      // extension may target.
      var earlierNoteIds = <String>{};

      for (final chapter in manifest.chapters) {
        final files = await readChapterFiles(
          _source,
          chapter,
          ContentType.notes,
          NotesFileDto.fromJson,
        );
        for (final (file, content) in files) {
          mergeUnique(
            notes,
            content.notes.map((note) => MapEntry(note.id, note.toEntity())),
            file: file,
            kind: 'note',
          );
        }
        for (final (file, content) in files) {
          for (final extension in content.noteExtensions) {
            final target = notes[extension.note];
            if (target == null) {
              throw ContentException(
                file,
                'noteExtensions: unknown note "${extension.note}"',
              );
            }
            if (!earlierNoteIds.contains(extension.note)) {
              throw ContentException(
                file,
                'noteExtensions: note "${extension.note}" is not from an '
                'earlier chapter; edit the note itself',
              );
            }
            notes[extension.note] = inContentFile(
              file,
              () => extension.applyTo(target),
            );
          }
        }
        earlierNoteIds = notes.keys.toSet();
      }

      return Map.unmodifiable(notes);
    });
  }
}
