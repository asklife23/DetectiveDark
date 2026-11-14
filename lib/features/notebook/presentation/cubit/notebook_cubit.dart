import 'dart:async';

import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/notebook/domain/repositories/note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/usecases/mark_note_read.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A collected note together with its catalog data.
class NotebookEntry extends Equatable {
  const NotebookEntry({
    required this.note,
    required this.isRead,
    this.lines = const [],
  });

  final NoteDefinition note;
  final bool isRead;

  /// The lines added to the note so far, in the order they were added
  /// (which may differ from the order of the catalog).
  final List<NoteEntryDefinition> lines;

  @override
  List<Object?> get props => [note, isRead, lines];
}

/// What the notebook shows.
class NotebookState extends Equatable {
  const NotebookState({
    this.entries = const [],
    this.isOpen = false,
    this.category = NoteCategory.document,
    this.selectedNoteId,
    this.highlightedLineId,
    this.updatePulse = 0,
  });

  /// Every collected note, in the order it was found.
  final List<NotebookEntry> entries;

  /// Whether the notebook covers the scene right now.
  final bool isOpen;

  /// The open tab.
  final NoteCategory category;

  /// The note shown on the right page, if any.
  final String? selectedNoteId;

  /// The newest line of the open note, marked while the note is on the
  /// page: it is what made the note unread. Interface state, never saved.
  final String? highlightedLineId;

  /// Goes up by one every time a known note gains a line. The notebook
  /// button plays a short pulse when this changes.
  final int updatePulse;

  /// The number on the badge of the notebook button.
  int get unreadCount => entries.where((entry) => !entry.isRead).length;

  /// The notes of the open tab.
  List<NotebookEntry> get visibleEntries => [
    for (final entry in entries)
      if (entry.note.category == category) entry,
  ];

  NotebookEntry? get selectedEntry {
    for (final entry in entries) {
      if (entry.note.id == selectedNoteId) return entry;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    entries,
    isOpen,
    category,
    selectedNoteId,
    highlightedLineId,
    updatePulse,
  ];
}

/// The notebook: collected notes from the progress joined with the note
/// catalog, plus what is open on screen (interface state, not saved).
class NotebookCubit extends Cubit<NotebookState> {
  NotebookCubit({
    required this._catalogRepository,
    required this._progressRepository,
    required this._markNoteRead,
    required this._caseId,
    required GameEventBus eventBus,
  }) : super(const NotebookState()) {
    _updated = eventBus.on<NoteUpdated>().listen(_onNoteUpdated);
  }

  final NoteCatalogRepository _catalogRepository;
  final ProgressRepository _progressRepository;
  final MarkNoteRead _markNoteRead;
  final String _caseId;

  Map<String, NoteDefinition> _catalog = const {};
  StreamSubscription<GameProgress>? _subscription;
  late final StreamSubscription<NoteUpdated> _updated;

  /// Loads the catalog and starts following the progress.
  Future<void> load() async {
    switch (await _catalogRepository.loadNotes(_caseId)) {
      case Success(:final value):
        _catalog = value;
      case Failed(:final failure):
        addError(failure);
    }
    if (isClosed) return;

    await _subscription?.cancel();
    _subscription = _progressRepository.watch().listen(_onProgress);
  }

  void _onProgress(GameProgress progress) {
    final entries = [
      for (final collected in progress.notes)
        if (_catalog[collected.noteId] case final note?)
          NotebookEntry(
            note: note,
            isRead: collected.isRead,
            lines: [
              for (final added in collected.entries) ?note.entry(added.entryId),
            ],
          ),
    ];
    emit(_copy(entries: entries));
  }

  void _onNoteUpdated(NoteUpdated event) =>
      emit(_copy(updatePulse: state.updatePulse + 1));

  void openNotebook() => emit(_copy(isOpen: true));

  /// Closes the notebook. The open note stays selected; its marked line
  /// does not (it has been seen).
  void closeNotebook() => emit(_copy(isOpen: false, keepHighlight: false));

  /// Switches the tab; the right page is cleared.
  void selectCategory(NoteCategory category) {
    if (category == state.category) return;
    emit(
      NotebookState(
        entries: state.entries,
        isOpen: state.isOpen,
        category: category,
        updatePulse: state.updatePulse,
      ),
    );
  }

  /// Shows a note on the right page and marks it as read. If the note was
  /// unread and has lines, its newest line is marked on the page.
  Future<void> selectNote(String noteId) async {
    final entry = state.entries
        .where((entry) => entry.note.id == noteId)
        .firstOrNull;
    if (entry == null) return;
    emit(
      NotebookState(
        entries: state.entries,
        isOpen: state.isOpen,
        category: state.category,
        selectedNoteId: noteId,
        highlightedLineId: entry.isRead ? null : entry.lines.lastOrNull?.id,
        updatePulse: state.updatePulse,
      ),
    );
    final result = await _markNoteRead(noteId);
    if (result case Failed(:final failure)) addError(failure);
  }

  NotebookState _copy({
    List<NotebookEntry>? entries,
    bool? isOpen,
    int? updatePulse,
    bool keepHighlight = true,
  }) {
    return NotebookState(
      entries: entries ?? state.entries,
      isOpen: isOpen ?? state.isOpen,
      category: state.category,
      selectedNoteId: state.selectedNoteId,
      highlightedLineId: keepHighlight ? state.highlightedLineId : null,
      updatePulse: updatePulse ?? state.updatePulse,
    );
  }

  @override
  Future<void> close() async {
    await _updated.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
