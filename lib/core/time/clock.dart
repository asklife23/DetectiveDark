/// The source of "now" for the game.
///
/// Domain code never calls `DateTime.now()` itself: with a clock passed in,
/// tests can use a fixed time and get the same result on every run.
abstract interface class Clock {
  /// The current moment in UTC.
  DateTime nowUtc();
}

/// The real clock of the device.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
