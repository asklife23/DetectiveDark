/// Counts the seconds the player has spent in the game.
///
/// It starts from the play time of the loaded save and counts on while the
/// app is in the foreground. It measures with a monotonic time source (a
/// stopwatch), not with the wall clock: changing the date of the device or
/// a daylight saving switch cannot add or remove play time.
class PlayTimeCounter {
  /// [elapsed] is a time that only moves forward; tests pass their own.
  PlayTimeCounter({Duration Function()? elapsed})
    : _elapsed = elapsed ?? _stopwatchElapsed() {
    _since = _elapsed();
  }

  final Duration Function() _elapsed;

  /// What was counted before the current stretch began.
  Duration _counted = Duration.zero;

  /// When the current stretch of counting began.
  late Duration _since;
  bool _paused = false;

  /// The play time so far, in whole seconds.
  int get seconds => (_counted + _stretch).inSeconds;

  /// Starts counting from [baseSeconds] (the play time of the save).
  /// Whether the counter runs or waits stays as [pause] and [resume] left
  /// it.
  void restart(int baseSeconds) {
    _counted = Duration(seconds: baseSeconds);
    _since = _elapsed();
  }

  /// Stops counting (the app went to the background).
  void pause() {
    if (_paused) return;
    _counted += _stretch;
    _paused = true;
  }

  /// Counts on (the app is back in the foreground).
  void resume() {
    if (!_paused) return;
    _since = _elapsed();
    _paused = false;
  }

  Duration get _stretch => _paused ? Duration.zero : _elapsed() - _since;

  static Duration Function() _stopwatchElapsed() {
    final stopwatch = Stopwatch()..start();
    return () => stopwatch.elapsed;
  }
}
