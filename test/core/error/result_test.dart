import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const failure = StorageFailure('disk full');

  group('Success', () {
    const result = Success<int>(42);

    test('exposes the value', () {
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('fold calls onSuccess', () {
      final text = result.fold(
        onSuccess: (value) => 'value $value',
        onFailure: (failure) => 'failure',
      );
      expect(text, 'value 42');
    });

    test('supports value equality', () {
      expect(const Success<int>(42), const Success<int>(42));
      expect(const Success<int>(42), isNot(const Success<int>(7)));
    });
  });

  group('Failed', () {
    const Result<int> result = Failed(failure);

    test('exposes the failure', () {
      expect(result.isSuccess, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('fold calls onFailure', () {
      final text = result.fold(
        onSuccess: (value) => 'value',
        onFailure: (failure) => failure.message,
      );
      expect(text, 'disk full');
    });

    test('supports value equality', () {
      expect(const Failed<int>(failure), const Failed<int>(failure));
      expect(
        const Failed<int>(failure),
        isNot(const Failed<int>(NetworkFailure('offline'))),
      );
    });
  });

  test('a switch over Result handles both cases', () {
    String describe(Result<int> result) => switch (result) {
      Success(:final value) => 'ok $value',
      Failed(:final failure) => 'error ${failure.message}',
    };

    expect(describe(const Success(1)), 'ok 1');
    expect(describe(const Failed(failure)), 'error disk full');
  });
}
