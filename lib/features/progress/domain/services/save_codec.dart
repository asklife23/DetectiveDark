import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';

/// Turns a progress into the text of a save and back.
///
/// The text is exactly what the save slot stores, so it can be copied out
/// of one device and into another (the developer menu does that to
/// reproduce bug reports).
abstract interface class SaveCodec {
  /// The save text of [progress], in the current format version.
  String encode(GameProgress progress);

  /// Reads a save text of the current or any older format version.
  ///
  /// Fails with `SaveTooNewFailure` for a text from a newer build and with
  /// `SaveCorruptFailure` for anything that is not a readable save.
  Result<GameProgress> decode(String text);
}
