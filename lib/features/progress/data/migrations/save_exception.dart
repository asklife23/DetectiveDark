/// Why a stored save could not be turned into a progress.
///
/// These are thrown only inside the data layer (a Drift type converter has
/// no other way to report a problem). The repository and the save codec
/// catch them and hand a `Failure` to the domain.
sealed class SaveException implements Exception {
  const SaveException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The payload is not a save this game can read: broken JSON, a missing or
/// mistyped field, no version number.
final class SaveCorruptException extends SaveException {
  const SaveCorruptException(super.message, {this.cause});

  final Object? cause;
}

/// The payload was written by a newer version of the game.
final class SaveTooNewException extends SaveException {
  const SaveTooNewException({
    required this.savedVersion,
    required this.supportedVersion,
  }) : super(
         'Payload version $savedVersion is newer than the supported '
         'version $supportedVersion.',
       );

  final int savedVersion;
  final int supportedVersion;
}
