import 'dart:async';

import 'package:detective_dark/core/events/game_event.dart';

/// Carries [GameEvent]s between features, so they never import each other's
/// presentation code.
///
/// It is a broadcast stream: any number of listeners, and an event published
/// while nobody listens is simply dropped.
class GameEventBus {
  final _controller = StreamController<GameEvent>.broadcast();

  /// Every event, in the order it was published.
  Stream<GameEvent> get events => _controller.stream;

  /// Only the events of type [T].
  Stream<T> on<T extends GameEvent>() =>
      _controller.stream.where((event) => event is T).cast<T>();

  void publish(GameEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void publishAll(Iterable<GameEvent> events) => events.forEach(publish);

  Future<void> dispose() => _controller.close();
}
