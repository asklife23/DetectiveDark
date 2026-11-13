import 'package:equatable/equatable.dart';

/// A note the player has collected. The texts live in the note catalog; the
/// save stores only the ID, when it was found and whether it has been read.
class CollectedNote extends Equatable {
  const CollectedNote({
    required this.noteId,
    required this.addedAtUtcMs,
    this.isRead = false,
  });

  final String noteId;

  /// UTC milliseconds since the Unix epoch.
  final int addedAtUtcMs;

  final bool isRead;

  CollectedNote markedRead() =>
      CollectedNote(noteId: noteId, addedAtUtcMs: addedAtUtcMs, isRead: true);

  @override
  List<Object?> get props => [noteId, addedAtUtcMs, isRead];
}
