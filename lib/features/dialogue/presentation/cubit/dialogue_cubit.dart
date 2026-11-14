import 'dart:async';

import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/repositories/dialogue_catalog_repository.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_view_resolver.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/ask_topic.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/start_conversation.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// What the dialogue panel shows.
///
/// The panel is in one of two modes: the character **speaks** (a greeting
/// or the lines of an answer, one at a time) or the player **chooses** the
/// next question.
class DialogueState extends Equatable {
  const DialogueState({
    this.dialogue,
    this.topics = const [],
    this.lineKeys = const [],
    this.lineIndex = 0,
    this.isLineComplete = false,
  });

  /// The conversation that is open; null while the panel is closed.
  final DialogueDefinition? dialogue;

  /// The questions on offer, in content order.
  final List<TopicView> topics;

  /// The lines the character is saying. Empty while the player chooses.
  final List<String> lineKeys;

  /// Which of [lineKeys] is on screen.
  final int lineIndex;

  /// Whether the line on screen is fully typed out.
  final bool isLineComplete;

  bool get isOpen => dialogue != null;

  /// The character is speaking: the question list is hidden.
  bool get isSpeaking => lineKeys.isNotEmpty;

  /// The line on screen, while the character speaks.
  String? get currentLineKey => isSpeaking ? lineKeys[lineIndex] : null;

  bool get isLastLine => lineIndex >= lineKeys.length - 1;

  @override
  List<Object?> get props => [
    dialogue,
    topics,
    lineKeys,
    lineIndex,
    isLineComplete,
  ];
}

/// Runs an open conversation: greeting, questions, answers.
///
/// It owns no game state. Which questions exist and which were asked is
/// read from the progress; asking goes through the use cases (and with
/// them through the effect pipeline). What it adds is interface state: the
/// line on screen and whether it is typed out.
class DialogueCubit extends Cubit<DialogueState> {
  DialogueCubit({
    required this._catalogRepository,
    required this._contentRepository,
    required this._progressRepository,
    required this._startConversation,
    required this._askTopic,
    required this._caseId,
    this._viewResolver = const DialogueViewResolver(),
  }) : super(const DialogueState());

  final DialogueCatalogRepository _catalogRepository;
  final SceneContentRepository _contentRepository;
  final ProgressRepository _progressRepository;
  final StartConversation _startConversation;
  final AskTopic _askTopic;
  final String _caseId;
  final DialogueViewResolver _viewResolver;

  Map<String, DialogueDefinition> _dialogues = const {};
  List<TriggerDefinition> _triggers = const [];
  StreamSubscription<GameProgress>? _subscription;

  /// Guards against a second tap while a use case is saving.
  bool _isBusy = false;

  /// Loads the dialogue catalog and the triggers of the case, and starts
  /// following the progress.
  Future<void> load() async {
    switch (await _catalogRepository.loadDialogues(_caseId)) {
      case Success(:final value):
        _dialogues = value;
      case Failed(:final failure):
        addError(failure);
    }
    switch (await _contentRepository.loadCase(_caseId)) {
      case Success(:final value):
        _triggers = value.triggers;
      case Failed(:final failure):
        addError(failure);
    }
    if (isClosed) return;

    await _subscription?.cancel();
    _subscription = _progressRepository.watch().listen(_onProgress);
  }

  /// The question list follows the progress: a question appears when its
  /// condition starts to hold, also while the panel is open.
  void _onProgress(GameProgress progress) {
    final dialogue = state.dialogue;
    if (dialogue == null) return;
    emit(_copy(topics: _viewResolver.visibleTopics(dialogue, progress)));
  }

  /// Opens the conversation [dialogueId]: the character greets first.
  Future<void> open(String dialogueId) async {
    final dialogue = _dialogues[dialogueId];
    final progress = _progressRepository.current;
    if (dialogue == null || progress == null || _isBusy) return;

    _isBusy = true;
    final result = await _startConversation(
      dialogue: dialogue,
      progress: progress,
      triggers: _triggers,
    );
    _isBusy = false;
    if (isClosed) return;

    switch (result) {
      case Failed(:final failure):
        addError(failure);
      case Success(value: final start):
        emit(
          DialogueState(
            dialogue: dialogue,
            topics: _viewResolver.visibleTopics(dialogue, start.progress),
            lineKeys: [start.greetingKey],
          ),
        );
    }
  }

  /// Asks the question [topicId]. Ignored while the character speaks.
  Future<void> ask(String topicId) async {
    final dialogue = state.dialogue;
    final progress = _progressRepository.current;
    if (dialogue == null || progress == null) return;
    if (state.isSpeaking || _isBusy) return;

    _isBusy = true;
    final result = await _askTopic(
      dialogue: dialogue,
      topicId: topicId,
      progress: progress,
      triggers: _triggers,
    );
    _isBusy = false;
    if (isClosed || state.dialogue != dialogue) return;

    switch (result) {
      case Failed(:final failure):
        addError(failure);
      case Success(value: final reply):
        if (reply.lineKeys.isEmpty) return;
        emit(
          DialogueState(
            dialogue: dialogue,
            topics: _viewResolver.visibleTopics(dialogue, reply.progress),
            lineKeys: reply.lineKeys,
          ),
        );
    }
  }

  /// The typewriter effect reached the end of the line.
  void lineTyped() {
    if (!state.isSpeaking || state.isLineComplete) return;
    emit(_copy(isLineComplete: true));
  }

  /// A tap while the character speaks: a line that is still being typed is
  /// completed; a complete line makes way for the next one; after the last
  /// line the question list returns.
  void advance() {
    if (!state.isSpeaking) return;
    if (!state.isLineComplete) {
      emit(_copy(isLineComplete: true));
    } else if (!state.isLastLine) {
      emit(_copy(lineIndex: state.lineIndex + 1, isLineComplete: false));
    } else {
      emit(_copy(lineKeys: const [], lineIndex: 0, isLineComplete: false));
    }
  }

  /// Closes the panel. Nothing is saved: an open conversation is interface
  /// state.
  void leave() {
    if (!state.isOpen) return;
    emit(const DialogueState());
  }

  DialogueState _copy({
    List<TopicView>? topics,
    List<String>? lineKeys,
    int? lineIndex,
    bool? isLineComplete,
  }) => DialogueState(
    dialogue: state.dialogue,
    topics: topics ?? state.topics,
    lineKeys: lineKeys ?? state.lineKeys,
    lineIndex: lineIndex ?? state.lineIndex,
    isLineComplete: isLineComplete ?? state.isLineComplete,
  );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
