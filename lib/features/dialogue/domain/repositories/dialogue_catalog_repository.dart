import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';

/// The conversations of a case, by dialogue ID.
abstract interface class DialogueCatalogRepository {
  /// Loads the dialogues of every chapter of [caseId], with the topics
  /// later chapters add to earlier dialogues already merged in.
  Future<Result<Map<String, DialogueDefinition>>> loadDialogues(String caseId);
}
