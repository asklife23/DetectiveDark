import 'package:detective_dark/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('is equal when type, message and cause match', () {
      final cause = Exception('io');
      expect(
        StorageFailure('save failed', cause: cause),
        StorageFailure('save failed', cause: cause),
      );
    });

    test('ignores the stack trace in equality', () {
      expect(
        StorageFailure('save failed', stackTrace: StackTrace.current),
        const StorageFailure('save failed'),
      );
    });

    test('is not equal across categories with the same message', () {
      expect(
        const ContentFailure('bad'),
        isNot(const UnexpectedFailure('bad')),
      );
    });

    test('a too-new save names both versions and compares by them', () {
      const failure = SaveTooNewFailure(savedVersion: 3, supportedVersion: 1);

      expect(failure.message, allOf(contains('3'), contains('1')));
      expect(
        failure,
        const SaveTooNewFailure(savedVersion: 3, supportedVersion: 1),
      );
      expect(
        failure,
        isNot(const SaveTooNewFailure(savedVersion: 2, supportedVersion: 1)),
      );
    });

    test('a switch over Failure covers every category', () {
      String category(Failure failure) => switch (failure) {
        ContentFailure() => 'content',
        StorageFailure() => 'storage',
        SaveTooNewFailure() => 'save too new',
        SaveCorruptFailure() => 'save corrupt',
        NetworkFailure() => 'network',
        UnexpectedFailure() => 'unexpected',
      };

      expect(category(const ContentFailure('x')), 'content');
      expect(category(const StorageFailure('x')), 'storage');
      expect(
        category(const SaveTooNewFailure(savedVersion: 2, supportedVersion: 1)),
        'save too new',
      );
      expect(category(const SaveCorruptFailure('x')), 'save corrupt');
      expect(category(const NetworkFailure('x')), 'network');
      expect(category(const UnexpectedFailure('x')), 'unexpected');
    });
  });
}
