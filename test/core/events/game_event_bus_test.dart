import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameEventBus bus;

  setUp(() => bus = GameEventBus());
  tearDown(() => bus.dispose());

  test('delivers events to every listener in publish order', () async {
    final first = <GameEvent>[];
    final second = <GameEvent>[];
    bus.events.listen(first.add);
    bus.events.listen(second.add);

    bus
      ..publish(const ItemObtained('brass_key'))
      ..publish(const DetectiveSaid('found_key'));
    await pumpEventQueue();

    const expected = [ItemObtained('brass_key'), DetectiveSaid('found_key')];
    expect(first, expected);
    expect(second, expected);
  });

  test('on<T> filters by event type', () async {
    final said = <DetectiveSaid>[];
    bus.on<DetectiveSaid>().listen(said.add);

    bus.publishAll(const [
      SceneEntered('villa_exterior', isFirstVisit: true),
      DetectiveSaid('first_look'),
      NoteAdded('hall_letter'),
    ]);
    await pumpEventQueue();

    expect(said, const [DetectiveSaid('first_look')]);
  });

  test('an event without listeners is dropped, not replayed', () async {
    bus.publish(const DetectiveSaid('early'));

    final received = <GameEvent>[];
    bus.events.listen(received.add);
    await pumpEventQueue();

    expect(received, isEmpty);
  });

  test('publishing after dispose is ignored', () async {
    await bus.dispose();

    expect(() => bus.publish(const DetectiveSaid('late')), returnsNormally);
  });

  test('events compare by value', () {
    expect(
      const ItemUsed('brass_key', hotspotId: 'lock'),
      const ItemUsed('brass_key', hotspotId: 'lock'),
    );
    expect(
      const SceneEntered('a', isFirstVisit: true),
      isNot(const SceneEntered('a', isFirstVisit: false)),
    );
  });

  test('the system clock reports UTC', () {
    expect(const SystemClock().nowUtc().isUtc, isTrue);
  });
}
