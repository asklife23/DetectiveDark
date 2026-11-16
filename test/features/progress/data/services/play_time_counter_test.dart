import 'package:detective_dark/features/progress/data/services/play_time_counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The time source of the test: it moves only when the test says so.
  var now = Duration.zero;
  late PlayTimeCounter counter;

  void pass(Duration duration) => now += duration;

  setUp(() {
    now = const Duration(hours: 5);
    counter = PlayTimeCounter(elapsed: () => now);
  });

  test('starts at zero and counts whole seconds', () {
    expect(counter.seconds, 0);

    pass(const Duration(milliseconds: 2999));
    expect(counter.seconds, 2);

    pass(const Duration(milliseconds: 1));
    expect(counter.seconds, 3);
  });

  test('restart counts on from the play time of the save', () {
    pass(const Duration(minutes: 3));

    counter.restart(754);
    expect(counter.seconds, 754);

    pass(const Duration(seconds: 6));
    expect(counter.seconds, 760);
  });

  test('does not count while paused', () {
    pass(const Duration(seconds: 10));
    counter.pause();
    pass(const Duration(hours: 8));
    expect(counter.seconds, 10);

    counter.resume();
    pass(const Duration(seconds: 5));
    expect(counter.seconds, 15);
  });

  test('parts of a second are not lost over a pause', () {
    pass(const Duration(milliseconds: 600));
    counter
      ..pause()
      ..resume();
    pass(const Duration(milliseconds: 600));

    expect(counter.seconds, 1);
  });

  test('pausing or resuming twice changes nothing', () {
    pass(const Duration(seconds: 10));
    counter.pause();
    pass(const Duration(seconds: 10));
    counter.pause();
    expect(counter.seconds, 10);

    counter.resume();
    pass(const Duration(seconds: 10));
    counter.resume();
    pass(const Duration(seconds: 10));
    expect(counter.seconds, 30);
  });

  test('a restart while paused stays paused', () {
    counter
      ..pause()
      ..restart(100);
    pass(const Duration(seconds: 30));
    expect(counter.seconds, 100);

    counter.resume();
    pass(const Duration(seconds: 2));
    expect(counter.seconds, 102);
  });

  test('without a time source it measures with a real stopwatch', () async {
    final real = PlayTimeCounter()..restart(40);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(real.seconds, inInclusiveRange(40, 41));
  });
}
