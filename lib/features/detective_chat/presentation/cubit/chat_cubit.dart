import 'dart:async';

import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// What the message bar and the message history show.
class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.unreadCount = 0,
    this.announcement = 0,
    this.isHistoryOpen = false,
  });

  /// Everything said so far, oldest first. Read from the progress.
  final List<ChatLogEntry> messages;

  /// Messages the player has probably not read yet: the number on the badge
  /// of the collapsed bar. Interface state, never saved.
  final int unreadCount;

  /// Goes up by one every time the detective says something. The bar plays
  /// its typewriter effect when this changes, also for the same line twice.
  final int announcement;

  /// Whether the message history covers the scene right now.
  final bool isHistoryOpen;

  /// The newest message, shown in the bar.
  ChatLogEntry? get latest => messages.lastOrNull;

  ChatState copyWith({
    List<ChatLogEntry>? messages,
    int? unreadCount,
    int? announcement,
    bool? isHistoryOpen,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      announcement: announcement ?? this.announcement,
      isHistoryOpen: isHistoryOpen ?? this.isHistoryOpen,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    unreadCount,
    announcement,
    isHistoryOpen,
  ];
}

/// The inner voice of the detective, as the interface sees it.
///
/// This cubit owns no messages. The history lives in the progress
/// (`chatLog`, written by the `say` effect in the same save as the rest of
/// the rule) and is only read here. The `DetectiveSaid` event adds the one
/// thing the progress cannot tell: that a message is new right now.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this._progressRepository,
    required GameEventBus eventBus,
  }) : super(const ChatState()) {
    // Listening starts at once, not in a `load` method: the very first line
    // of the game is said while the first scene is still loading.
    _said = eventBus.on<DetectiveSaid>().listen(_onSaid);
    _progress = _progressRepository.watch().listen(_onProgress);
  }

  final ProgressRepository _progressRepository;
  late final StreamSubscription<DetectiveSaid> _said;
  late final StreamSubscription<GameProgress> _progress;

  void _onProgress(GameProgress progress) =>
      emit(state.copyWith(messages: progress.chatLog));

  void _onSaid(DetectiveSaid event) {
    emit(
      state.copyWith(
        // The event may arrive before the progress stream does; read the
        // saved log directly so the bar never shows the previous line.
        messages: _progressRepository.current?.chatLog,
        unreadCount: state.isHistoryOpen ? 0 : state.unreadCount + 1,
        announcement: state.announcement + 1,
      ),
    );
  }

  /// The bar showed the newest message long enough to read it.
  void markLatestSeen() {
    if (state.unreadCount == 0) return;
    emit(state.copyWith(unreadCount: state.unreadCount - 1));
  }

  /// Opens the message history; everything in it counts as read.
  void openHistory() =>
      emit(state.copyWith(isHistoryOpen: true, unreadCount: 0));

  void closeHistory() => emit(state.copyWith(isHistoryOpen: false));

  @override
  Future<void> close() async {
    await _said.cancel();
    await _progress.cancel();
    return super.close();
  }
}
