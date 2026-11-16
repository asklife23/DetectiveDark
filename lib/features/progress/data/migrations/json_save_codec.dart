import 'dart:convert';

import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/progress/data/migrations/save_exception.dart';
import 'package:detective_dark/features/progress/data/migrations/save_migrator.dart';
import 'package:detective_dark/features/progress/data/models/game_progress_dto.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/services/save_codec.dart';
import 'package:json_annotation/json_annotation.dart';

/// The save format of the game: versioned JSON (ADR 0003).
///
/// Reading runs three steps: parse the text → migrate the JSON to the
/// current version ([SaveMigrator]) → check every field
/// ([GameProgressDto]). Whatever goes wrong ends as one of the two
/// [SaveException]s, never as a raw parse error.
class JsonSaveCodec implements SaveCodec {
  const JsonSaveCodec({this.migrator = const SaveMigrator()});

  final SaveMigrator migrator;

  /// The format version this build writes.
  int get version => migrator.currentVersion;

  @override
  String encode(GameProgress progress) => jsonEncode(
    GameProgressDto.fromEntity(progress, schemaVersion: version).toJson(),
  );

  @override
  Result<GameProgress> decode(String text) {
    try {
      return Success(decodeOrThrow(text));
    } on SaveException catch (error, stackTrace) {
      return Failed(failureOf(error, stackTrace));
    }
  }

  /// Like [decode], for callers that cannot return a `Result` (the Drift
  /// type converter). Throws a [SaveException].
  GameProgress decodeOrThrow(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException catch (error) {
      throw SaveCorruptException('The save is not valid JSON.', cause: error);
    }
    if (json is! Map<String, dynamic>) {
      throw const SaveCorruptException('The save is not a JSON object.');
    }

    final migrated = migrator.migrate(json);
    try {
      return GameProgressDto.fromJson(migrated).toEntity();
    } on CheckedFromJsonException catch (error) {
      throw SaveCorruptException(
        'The save has a missing, unknown or mistyped field: '
        '${error.key ?? error.message}.',
        cause: error,
      );
    }
  }

  /// The failure the domain sees for a [SaveException].
  static Failure failureOf(SaveException error, [StackTrace? stackTrace]) =>
      switch (error) {
        SaveTooNewException(:final savedVersion, :final supportedVersion) =>
          SaveTooNewFailure(
            savedVersion: savedVersion,
            supportedVersion: supportedVersion,
          ),
        SaveCorruptException(:final message, :final cause) =>
          SaveCorruptFailure(
            message,
            cause: cause ?? error,
            stackTrace: stackTrace,
          ),
      };
}
