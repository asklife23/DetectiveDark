import 'package:detective_dark/features/progress/data/migrations/save_exception.dart';

/// Rewrites a save payload from one version to the next.
///
/// It gets the decoded JSON of version N and returns the JSON of version
/// N + 1. A pure function: no I/O, no clock, no entity classes. It works on
/// plain maps on purpose, because the entity of today no longer has the
/// fields an old save used.
typedef SaveMigration =
    Map<String, dynamic> Function(Map<String, dynamic> json);

/// The migrations of the game, oldest first: entry 0 turns version 1 into
/// version 2, entry 1 turns 2 into 3, and so on.
///
/// **Changing the save format:** write a function `v1ToV2` in this folder,
/// add it at the END of this list, update `GameProgressDto` to the new
/// shape and add a test with a real version-1 payload. Never edit or
/// remove an entry: saves of every released version must stay readable.
const List<SaveMigration> saveMigrations = [];

/// Brings a save payload of any older version up to the current one by
/// running the missing migrations in order (`v1 → v2 → v3 ...`).
class SaveMigrator {
  const SaveMigrator({this.migrations = saveMigrations});

  /// The JSON key that holds the version of a payload.
  static const versionKey = 'schemaVersion';

  /// The first version of the save format.
  static const firstVersion = 1;

  final List<SaveMigration> migrations;

  /// The version this build writes and the newest one it can read.
  int get currentVersion => firstVersion + migrations.length;

  /// The version a payload claims to have.
  ///
  /// Throws [SaveCorruptException] when there is no usable version number.
  int versionOf(Map<String, dynamic> json) {
    final version = json[versionKey];
    if (version is! int || version < firstVersion) {
      throw SaveCorruptException(
        'The payload has no valid "$versionKey" (found: $version).',
      );
    }
    return version;
  }

  /// Returns [json] in the current version; an up-to-date payload is
  /// returned as it is.
  ///
  /// Throws [SaveTooNewException] for a payload from a newer build and
  /// [SaveCorruptException] when the version is missing or a migration
  /// cannot digest the data.
  Map<String, dynamic> migrate(Map<String, dynamic> json) {
    final savedVersion = versionOf(json);
    if (savedVersion > currentVersion) {
      throw SaveTooNewException(
        savedVersion: savedVersion,
        supportedVersion: currentVersion,
      );
    }

    var migrated = json;
    for (var version = savedVersion; version < currentVersion; version++) {
      try {
        migrated = {
          ...migrations[version - firstVersion](migrated),
          versionKey: version + 1,
        };
        // A migration reads untyped JSON; on damaged data its casts fail
        // with a TypeError, which is an Error and not an Exception.
        // ignore: avoid_catching_errors
      } on TypeError catch (error) {
        throw SaveCorruptException(
          'Migration v$version → v${version + 1} failed.',
          cause: error,
        );
      } on Exception catch (error) {
        throw SaveCorruptException(
          'Migration v$version → v${version + 1} failed.',
          cause: error,
        );
      }
    }
    return migrated;
  }
}
