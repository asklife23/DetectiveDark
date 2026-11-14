import 'package:bloc_test/bloc_test.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/detective_chat/presentation/cubit/chat_cubit.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  late InMemoryProgressRepository progress;
  late GameEventBus bus;

  setUp(() {
    progress = InMemoryProgressRepository();
    bus = GameEventBus();
  });
  tearDown(() async {
    await progress.dispose();
    await bus.dispose();
  });

  ChatCubit build() => ChatCubit(progressRepository: progress, eventBus: bus);

  ChatLogEntry entry(String key) => ChatLogEntry(textKey: key, sentAtUtcMs: 1);

  /// What the `say` effect does: one save with the new line, then the event.
  Future<void> say(String key) async {
    await progress.save(
      (progress.current ?? newGame).withChatEntry(entry(key)),
    );
    bus.publish(DetectiveSaid(key));
    await pumpEventQueue();
  }

  List<String> keys(ChatState state) => [
    for (final message in state.messages) message.textKey,
  ];

  blocTest<ChatCubit, ChatState>(
    'starts empty and silent',
    build: build,
    verify: (cubit) {
      expect(cubit.state, const ChatState());
      expect(cubit.state.latest, isNull);
    },
  );

  blocTest<ChatCubit, ChatState>(
    'a loaded save fills the history without announcing anything',
    setUp: () => progress.save(
      newGame.withChatEntry(entry('first')).withChatEntry(entry('second')),
    ),
    build: build,
    act: (_) => pumpEventQueue(),
    verify: (cubit) {
      expect(keys(cubit.state), ['first', 'second']);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.announcement, 0);
    },
  );

  blocTest<ChatCubit, ChatState>(
    'a new line is announced, counted as unread and becomes the latest',
    build: build,
    act: (_) async {
      await say('first');
      await say('second');
    },
    verify: (cubit) {
      expect(keys(cubit.state), ['first', 'second']);
      expect(cubit.state.latest!.textKey, 'second');
      expect(cubit.state.unreadCount, 2);
      expect(cubit.state.announcement, 2);
    },
  );

  blocTest<ChatCubit, ChatState>(
    'the same line twice is announced twice',
    build: build,
    act: (_) async {
      await say('locked');
      await say('locked');
    },
    verify: (cubit) {
      expect(keys(cubit.state), ['locked', 'locked']);
      expect(cubit.state.announcement, 2);
    },
  );

  blocTest<ChatCubit, ChatState>(
    'the announcement already carries the new line',
    build: build,
    act: (_) => say('first'),
    verify: (cubit) => expect(cubit.state.latest!.textKey, 'first'),
    // No emitted state announces without its message.
    expect: () => everyElement(
      predicate<ChatState>(
        (state) => state.announcement == 0 || state.messages.isNotEmpty,
      ),
    ),
  );

  blocTest<ChatCubit, ChatState>(
    'a message the bar has shown is no longer unread',
    build: build,
    act: (cubit) async {
      await say('first');
      await say('second');
      cubit
        ..markLatestSeen()
        ..markLatestSeen()
        ..markLatestSeen();
    },
    verify: (cubit) => expect(cubit.state.unreadCount, 0),
  );

  blocTest<ChatCubit, ChatState>(
    'opening the history marks everything as read',
    build: build,
    act: (cubit) async {
      await say('first');
      cubit.openHistory();
    },
    verify: (cubit) {
      expect(cubit.state.isHistoryOpen, isTrue);
      expect(cubit.state.unreadCount, 0);
      expect(keys(cubit.state), ['first']);
    },
  );

  blocTest<ChatCubit, ChatState>(
    'a line said while the history is open is not unread',
    build: build,
    act: (cubit) async {
      cubit.openHistory();
      await say('first');
      cubit.closeHistory();
    },
    verify: (cubit) {
      expect(cubit.state.isHistoryOpen, isFalse);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.announcement, 1);
    },
  );

  test('a closed cubit ignores later events', () async {
    final cubit = build();
    await cubit.close();

    await say('first');

    expect(cubit.state, const ChatState());
  });
}
