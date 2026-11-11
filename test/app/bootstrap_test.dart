import 'package:detective_dark/app/bootstrap.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('registerErrorHandlers', () {
    late List<LogEntry> entries;

    setUp(() => entries = []);

    // The test framework installs its own handlers and checks they are
    // restored, so each test puts the originals back before it ends.
    void withHandlers(void Function() body) {
      final flutterHandler = FlutterError.onError;
      final platformHandler = PlatformDispatcher.instance.onError;
      try {
        registerErrorHandlers(AppLogger('app', writer: entries.add));
        body();
      } finally {
        FlutterError.onError = flutterHandler;
        PlatformDispatcher.instance.onError = platformHandler;
      }
    }

    test('logs framework errors', () {
      final error = StateError('build failed');

      withHandlers(() {
        FlutterError.onError!(FlutterErrorDetails(exception: error));
      });

      expect(entries.single.level, LogLevel.error);
      expect(entries.single.error, error);
    });

    test('logs uncaught platform errors and marks them handled', () {
      final error = StateError('async failure');
      late bool handled;

      withHandlers(() {
        handled = PlatformDispatcher.instance.onError!(
          error,
          StackTrace.current,
        );
      });

      expect(handled, isTrue);
      expect(entries.single.level, LogLevel.error);
      expect(entries.single.error, error);
    });
  });
}
