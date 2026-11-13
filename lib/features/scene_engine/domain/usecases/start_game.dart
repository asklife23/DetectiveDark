import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/enter_scene.dart';
import 'package:equatable/equatable.dart';

/// A game that is ready to be played: the content and where the player is.
class StartedGame extends Equatable {
  const StartedGame({required this.content, required this.progress});

  final CaseContent content;
  final GameProgress progress;

  @override
  List<Object?> get props => [content, progress];
}

/// Loads the content and either continues the stored game or starts a new
/// one in the entry scene of the first chapter.
///
/// "New game" and "continue" share this one path, so persistent saves
/// (Phase 2) need no change here or in the UI.
class StartGame {
  const StartGame({
    required this._contentRepository,
    required this._progressRepository,
    required this._enterScene,
  });

  final SceneContentRepository _contentRepository;
  final ProgressRepository _progressRepository;
  final EnterScene _enterScene;

  Future<Result<StartedGame>> call(String caseId) async {
    final loadedContent = await _contentRepository.loadCase(caseId);
    if (loadedContent case Failed(:final failure)) return Failed(failure);
    final content = loadedContent.valueOrNull!;

    final loadedProgress = await _progressRepository.load();
    if (loadedProgress case Failed(:final failure)) return Failed(failure);
    final stored = loadedProgress.valueOrNull;

    // Continue only when the save points at a scene that still exists.
    final storedSceneId = stored?.currentSceneId;
    if (stored != null &&
        stored.caseId == caseId &&
        content.scenes.containsKey(storedSceneId)) {
      return Success(StartedGame(content: content, progress: stored));
    }

    if (content.definition.chapters.isEmpty) {
      return Failed(ContentFailure('Case "$caseId" has no chapters.'));
    }
    final chapter = content.definition.chapters.first;
    final entered = await _enterScene(
      content: content,
      progress: GameProgress(
        caseId: caseId,
        chapterId: chapter.id,
        sceneStack: const [],
      ),
      sceneId: chapter.entrySceneId,
    );

    return switch (entered) {
      Success(:final value) => Success(
        StartedGame(content: content, progress: value),
      ),
      Failed(:final failure) => Failed(failure),
    };
  }
}
