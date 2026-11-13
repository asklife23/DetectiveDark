import 'dart:async';

import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/notebook/domain/repositories/note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/usecases/mark_note_read.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A collected note together with its catalog data.
class NotebookEntry extends Equatable {
  const NotebookEntry({required this.note, required this.isRead});

  final NoteDefinition note;
  final bool isRead;

  @override
  List<Object?> get props => [note, isRead];
}

/// What the notebook shows.
class NotebookState extends Equatable {
  const NotebookState({
    this.entries = const [],
    this.isOpen = false,
    this.category = NoteCategory.document,
    this.selectedNoteId,
  });

  /// Every collected note, in the order it was found.
  final List<NotebookEntry> entries;

  /// Whether the notebook covers the scene right now.
  final bool isOpen;

  /// The open tab.
  final NoteCategory category;

  /// The note shown on the right page, if any.
  final String? selectedNoteId;

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
  List<Object?> get props => [entries, isOpen, category, selectedNoteId];
}

/// The notebook: collected notes from the progress joined with the note
/// catalog, plus what is open on screen (interface state, not saved).
class NotebookCubit extends Cubit<NotebookState> {
  NotebookCubit({
    required this._catalogRepository,
    required this._progressRepository,
    required this._markNoteRead,
    required this._caseId,
  }) : super(const NotebookState());

  final NoteCatalogRepository _catalogRepository;
  final ProgressRepository _progressRepository;
  final MarkNoteRead _markNoteRead;
  final String _caseId;

  Map<String, NoteDefinition> _catalog = const {};
  StreamSubscription<GameProgress>? _subscription;

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
          NotebookEntry(note: note, isRead: collected.isRead),
    ];
    emit(_copy(entries: entries));
  }

  void openNotebook() => emit(_copy(isOpen: true));

  void closeNotebook() => emit(_copy(isOpen: false));

  /// Switches the tab; the right page is cleared.
  void selectCategory(NoteCategory category) {
    if (category == state.category) return;
    emit(
      NotebookState(
        entries: state.entries,
        isOpen: state.isOpen,
        category: category,
      ),
    );
  }

  /// Shows a note on the right page and marks it as read.
  Future<void> selectNote(String noteId) async {
    if (!state.entries.any((entry) => entry.note.id == noteId)) return;
    emit(
      NotebookState(
        entries: state.entries,
        isOpen: state.isOpen,
        category: state.category,
        selectedNoteId: noteId,
      ),
    );
    final result = await _markNoteRead(noteId);
    if (result case Failed(:final failure)) addError(failure);
  }

  NotebookState _copy({List<NotebookEntry>? entries, bool? isOpen}) {
    return NotebookState(
      entries: entries ?? state.entries,
      isOpen: isOpen ?? state.isOpen,
      category: state.category,
      selectedNoteId: state.selectedNoteId,
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
