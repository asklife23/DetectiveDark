import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';

/// Reads the notes of a case, keyed by note ID. Notes from every chapter
/// stay readable until the final accusation, so the catalog covers the
/// whole case.
abstract interface class NoteCatalogRepository {
  Future<Result<Map<String, NoteDefinition>>> loadNotes(String caseId);
}
