import 'package:detective_dark/core/error/failure.dart';
import 'package:equatable/equatable.dart';

/// The outcome of an operation that can fail: either [Success] with a value
/// or [Failed] with a [Failure].
///
/// Repositories return `Result` instead of throwing, which makes the failure
/// path visible in the type and forces callers to handle it:
///
/// ```dart
/// switch (await repository.load()) {
///   case Success(:final value):
///     emit(Loaded(value));
///   case Failed(:final failure):
///     emit(LoadError(failure));
/// }
/// ```
///
/// This file is pure Dart, so the domain layer may depend on it.
sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;

  /// The value on success, `null` on failure.
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failed() => null,
  };

  /// The failure on failure, `null` on success.
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Failed(:final failure) => failure,
  };

  /// Reduces both cases to a single value of type [R].
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failed(:final failure) => onFailure(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
