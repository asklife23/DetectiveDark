import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/enter_scene.dart';

/// What the developer menu can do to the game.
///
/// Nothing here writes the progress itself. Every change takes the same
/// road as the game (ADR 0014): the effect pipeline, directly or through
/// [EnterScene]. So triggers still fire, the save stays atomic and the
/// events reach the interface, exactly as if the player had done it.
class DevActions {
  const DevActions({
    required this._pipeline,
    required this._enterScene,
    required this._progressRepository,
    required this._clock,
    this._effectApplier = const EffectApplier(),
  });

  final EffectPipeline _pipeline;
  final EnterScene _enterScene;
  final ProgressRepository _progressRepository;
  final Clock _clock;
  final EffectApplier _effectApplier;

  /// Moves the player into [sceneId], keeping everything they have.
  Future<Result<void>> jumpTo(CaseContent content, String sceneId) async {
    final progress = _progressRepository.current;
    if (progress == null) return const Failed(_noGame);
    return _enter(content, progress, sceneId);
  }

  Future<Result<void>> giveItem(CaseContent content, String itemId) =>
      _apply(content, [GiveItem(itemId)]);

  Future<Result<void>> addNote(CaseContent content, String noteId) =>
      _apply(content, [AddNote(noteId)]);

  Future<Result<void>> setFlag(CaseContent content, String flag) =>
      _apply(content, [SetFlag(flag)]);

  /// Starts the case again: an empty progress in the entry scene of the
  /// first chapter.
  Future<Result<void>> reset(CaseContent content) {
    final chapter = content.definition.chapters.first;
    return _enter(
      content,
      _freshProgress(content, chapter.id),
      chapter.entrySceneId,
    );
  }

  /// Replaces the progress with [preset]: a fresh game that already holds
  /// the items, notes and flags of the preset, standing in its scene.
  ///
  /// The things are put into the new progress with the game's own effects
  /// (so a note gets its timestamp like any other), but without announcing
  /// them: nothing was picked up, so nothing should fly across the screen.
  Future<Result<void>> loadPreset(CaseContent content, DevPreset preset) {
    final chapterId =
        content.sceneChapters[preset.sceneId] ??
        content.definition.chapters.first.id;
    final stocked = _effectApplier.apply(
      _freshProgress(content, chapterId),
      [
        for (final itemId in preset.itemIds) GiveItem(itemId),
        for (final noteId in preset.noteIds) AddNote(noteId),
        for (final flag in preset.flags) SetFlag(flag),
      ],
      _contextIn(preset.sceneId),
    );
    return _enter(content, stocked.progress, preset.sceneId);
  }

  /// Replaces the progress with [imported]: a save pasted into the menu,
  /// e.g. the state a tester sent along with a bug report.
  ///
  /// The save must belong to this case and stand in a scene that exists.
  Future<Result<void>> importSave(CaseContent content, GameProgress imported) {
    final sceneId = imported.currentSceneId;
    if (imported.caseId != content.definition.id || sceneId == null) {
      return Future.value(
        Failed(
          ContentFailure(
            'The save belongs to case "${imported.caseId}" or has no scene.',
          ),
        ),
      );
    }
    // The pipeline stores only what differs from the progress it is given.
    // Arriving from an empty stack is always a change, so the imported
    // state is saved even when nothing else happens on arrival.
    return _enter(content, imported.withSceneStack(const []), sceneId);
  }

  static const _noGame = UnexpectedFailure('No game is running.');

  GameProgress _freshProgress(CaseContent content, String chapterId) =>
      GameProgress(
        caseId: content.definition.id,
        chapterId: chapterId,
        sceneStack: const [],
      );

  EffectContext _contextIn(String sceneId) => EffectContext(
    sceneId: sceneId,
    nowUtcMs: _clock.nowUtc().millisecondsSinceEpoch,
  );

  Future<Result<void>> _enter(
    CaseContent content,
    GameProgress progress,
    String sceneId,
  ) async {
    final entered = await _enterScene(
      content: content,
      progress: progress,
      sceneId: sceneId,
    );
    return _withoutValue(entered);
  }

  Future<Result<void>> _apply(CaseContent content, List<Effect> effects) async {
    final progress = _progressRepository.current;
    final sceneId = progress?.currentSceneId;
    if (progress == null || sceneId == null) return const Failed(_noGame);

    final outcome = await _pipeline.run(
      progress: progress,
      effects: effects,
      triggers: content.triggers,
      context: _contextIn(sceneId),
    );
    return _withoutValue(outcome);
  }

  Result<void> _withoutValue(Result<Object?> result) => switch (result) {
    Success() => const Success(null),
    Failed(:final failure) => Failed(failure),
  };
}
