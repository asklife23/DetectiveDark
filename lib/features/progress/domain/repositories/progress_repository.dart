import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';

/// The single source of truth for the progress of the player.
///
/// Scene, inventory, notebook and chat all read from here. There is exactly
/// one way to write: [save] stores a complete [GameProgress] atomically, so
/// all effects of one interaction land together or not at all.
abstract interface class ProgressRepository {
  /// The latest loaded or saved progress; `null` before either happened.
  GameProgress? get current;

  /// Reads the stored progress. `Success(null)` means there is no save yet.
  Future<Result<GameProgress?>> load();

  /// Emits the progress after every successful [load] and [save]. A new
  /// listener first receives [current], if there is one.
  Stream<GameProgress> watch();

  /// Stores [progress] as the new state.
  Future<Result<void>> save(GameProgress progress);
}
