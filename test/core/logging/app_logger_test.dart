import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<LogEntry> entries;
  late AppLogger logger;

  setUp(() {
    entries = [];
    logger = AppLogger('test', writer: entries.add);
  });

  test('writes each level with the logger name', () {
    logger
      ..debug('d')
      ..info('i')
      ..warning('w')
      ..error('e');

    expect(entries.map((e) => e.level), [
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warning,
      LogLevel.error,
    ]);
    expect(entries.map((e) => e.message), ['d', 'i', 'w', 'e']);
    expect(entries.every((e) => e.name == 'test'), isTrue);
  });

  test('passes error and stack trace through', () {
    final error = StateError('boom');
    final stackTrace = StackTrace.current;

    logger.error('failed', error: error, stackTrace: stackTrace);

    expect(entries.single.error, error);
    expect(entries.single.stackTrace, stackTrace);
  });

  test('severities increase with the level', () {
    final severities = LogLevel.values.map((l) => l.severity).toList();
    expect(severities, [...severities]..sort());
  });

  test('the default writer accepts an entry', () {
    expect(
      () => developerLogWriter((
        level: LogLevel.info,
        name: 'test',
        message: 'hello',
        error: null,
        stackTrace: null,
      )),
      returnsNormally,
    );
  });
}
