import 'package:detective_dark/features/progress/data/migrations/json_save_codec.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:drift/drift.dart';

/// Stores a [GameProgress] in a text column as versioned JSON.
///
/// Drift calls [toSql] when a row is written and [fromSql] when it is read,
/// so the rest of the code works with the entity and never sees the text.
/// The format itself belongs to the [JsonSaveCodec].
class GameProgressConverter extends TypeConverter<GameProgress, String> {
  const GameProgressConverter();

  /// The codec of the save column. Its version is the one to store in the
  /// `schemaVersion` column next to a payload written by [toSql].
  static const codec = JsonSaveCodec();

  /// Throws a `SaveException` for a payload that is damaged or too new;
  /// a type converter cannot return a `Result`.
  @override
  GameProgress fromSql(String fromDb) => codec.decodeOrThrow(fromDb);

  @override
  String toSql(GameProgress value) => codec.encode(value);
}
