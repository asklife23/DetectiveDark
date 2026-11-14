import 'package:equatable/equatable.dart';

/// A line that was added to a collected note (ADR 0015). The text lives in
/// the note catalog; the save stores only the ID and when it was added.
class CollectedNoteEntry extends Equatable {
  const CollectedNoteEntry({required this.entryId, required this.addedAtUtcMs});

  final String entryId;

  /// UTC milliseconds since the Unix epoch.
  final int addedAtUtcMs;

  @override
  List<Object?> get props => [entryId, addedAtUtcMs];
}

/// A note the player has collected. The texts live in the note catalog; the
/// save stores only the ID, when it was found, whether it has been read and
/// which of its lines have been added so far.
class CollectedNote extends Equatable {
  const CollectedNote({
    required this.noteId,
    required this.addedAtUtcMs,
    this.isRead = false,
    this.entries = const [],
  });

  final String noteId;

  /// UTC milliseconds since the Unix epoch.
  final int addedAtUtcMs;

  final bool isRead;

  /// The lines added to this note, in the order they were added.
  final List<CollectedNoteEntry> entries;

  bool hasEntry(String entryId) =>
      entries.any((entry) => entry.entryId == entryId);

  CollectedNote markedRead() => CollectedNote(
    noteId: noteId,
    addedAtUtcMs: addedAtUtcMs,
    isRead: true,
    entries: entries,
  );

  /// Adds a line at the end and makes the note unread again: there is
  /// something new to read. No change if the line is already there.
  CollectedNote withEntry(CollectedNoteEntry entry) => hasEntry(entry.entryId)
      ? this
      : CollectedNote(
          noteId: noteId,
          addedAtUtcMs: addedAtUtcMs,
          entries: List.unmodifiable([...entries, entry]),
        );

  @override
  List<Object?> get props => [noteId, addedAtUtcMs, isRead, entries];
}
