import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';

/// Marks a collected note as read.
///
/// The read state is part of the progress, not of the screen: once saves
/// are persistent (Phase 2), the "new note" badge does not come back after
/// the app restarts.
class MarkNoteRead {
  const MarkNoteRead(this._progressRepository);

  final ProgressRepository _progressRepository;

  Future<Result<void>> call(String noteId) async {
    final progress = _progressRepository.current;
    if (progress == null) return const Success(null);

    final updated = progress.withNoteRead(noteId);
    // Already read, or not collected: nothing to save.
    if (identical(updated, progress)) return const Success(null);
    return _progressRepository.save(updated);
  }
}
