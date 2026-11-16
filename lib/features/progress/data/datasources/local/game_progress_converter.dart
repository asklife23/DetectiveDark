import 'dart:convert';

import 'package:detective_dark/features/progress/data/models/game_progress_dto.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:drift/drift.dart';

/// Stores a [GameProgress] in a text column as JSON.
///
/// Drift calls [toSql] when a row is written and [fromSql] when it is read,
/// so the rest of the code works with the entity and never sees the text.
class GameProgressConverter extends TypeConverter<GameProgress, String> {
  const GameProgressConverter();

  @override
  GameProgress fromSql(String fromDb) {
    final json = jsonDecode(fromDb) as Map<String, dynamic>;
    return GameProgressDto.fromJson(json).toEntity();
  }

  @override
  String toSql(GameProgress value) =>
      jsonEncode(GameProgressDto.fromEntity(value).toJson());
}
