import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';

/// Reads the scenes and inspections of a case from the game content.
abstract interface class SceneContentRepository {
  /// Loads the whole case. Malformed or missing content comes back as a
  /// `ContentFailure` that names the file and the place.
  Future<Result<CaseContent>> loadCase(String caseId);
}
