import 'dart:developer' as developer;

/// Log severity. [severity] uses the same scale as `package:logging`
/// (FINE = 500 ... SEVERE = 1000), which DevTools uses to color log lines.
enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  const LogLevel(this.severity);

  final int severity;
}

/// One log line, handed to a [LogWriter].
typedef LogEntry = ({
  LogLevel level,
  String name,
  String message,
  Object? error,
  StackTrace? stackTrace,
});

/// Where log entries go. Tests pass a writer that collects entries in a list.
typedef LogWriter = void Function(LogEntry entry);

/// Writes to `dart:developer`, visible in the IDE console and DevTools.
void developerLogWriter(LogEntry entry) {
  developer.log(
    entry.message,
    name: entry.name,
    level: entry.level.severity,
    error: entry.error,
    stackTrace: entry.stackTrace,
  );
}

/// The project's logger. Use it instead of `print`.
///
/// [name] tags every line with its origin, e.g. `AppLogger('scene_engine')`.
/// Messages are for developers only and are never shown to players.
class AppLogger {
  /// Callers pass `writer:`; Dart 3.12 maps it to the private field.
  const AppLogger(this.name, {this._writer = developerLogWriter});

  final String name;
  final LogWriter _writer;

  void debug(String message) => _write(LogLevel.debug, message);

  void info(String message) => _write(LogLevel.info, message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _write(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _write(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _write(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _writer((
      level: level,
      name: name,
      message: message,
      error: error,
      stackTrace: stackTrace,
    ));
  }
}
