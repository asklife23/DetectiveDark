import 'package:equatable/equatable.dart';

/// A known, expected problem returned from the data layer to the domain.
///
/// Failures travel inside a `Result` instead of being thrown, so the UI never
/// sees raw exceptions. [message] is for developers and logs only; the UI maps
/// the failure *type* to a localized text.
///
/// The class is `sealed`, so a `switch` over a failure must handle every
/// category. Adding a new category is a deliberate change made here.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause, this.stackTrace});

  final String message;

  /// The original exception, if the failure was created from one.
  final Object? cause;

  final StackTrace? stackTrace;

  // The stack trace is diagnostic data, not part of the failure's identity.
  @override
  List<Object?> get props => [message, cause];
}

/// Game content (scenes, items, notes JSON) is missing or malformed.
final class ContentFailure extends Failure {
  const ContentFailure(super.message, {super.cause, super.stackTrace});
}

/// Reading or writing local data (the save game) failed.
final class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause, super.stackTrace});
}

/// A remote service could not be reached or answered with an error.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause, super.stackTrace});
}

/// Anything that does not fit a known category. Usually a bug.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.cause, super.stackTrace});
}
