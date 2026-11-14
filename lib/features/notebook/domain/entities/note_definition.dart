import 'package:equatable/equatable.dart';

/// The notebook section a note belongs to.
enum NoteCategory {
  /// Letters, clippings, receipts, photos.
  document,

  /// Conclusions the detective draws.
  observation,

  /// The file of a person: what is known about a witness or a possible
  /// culprit. Who counts as one of the accused is decided by the case
  /// (Phase 5), not by this category.
  person,
}

/// A line that can be added to a note while the game goes on (ADR 0015):
/// a statement in the file of a person.
class NoteEntryDefinition extends Equatable {
  const NoteEntryDefinition({required this.id, required this.textKey});

  /// Unique inside its note.
  final String id;
  final String textKey;

  @override
  List<Object?> get props => [id, textKey];
}

/// Something the player can read in the notebook and later present as
/// evidence.
class NoteDefinition extends Equatable {
  const NoteDefinition({
    required this.id,
    required this.category,
    required this.titleKey,
    required this.bodyKey,
    this.imageAsset,
    this.entries = const [],
  });

  final String id;
  final NoteCategory category;
  final String titleKey;
  final String bodyKey;
  final String? imageAsset;

  /// The lines this note can gain (the catalog). Which of them the player
  /// has is stored in the progress; the `addNoteEntry` effect adds one.
  final List<NoteEntryDefinition> entries;

  NoteEntryDefinition? entry(String entryId) {
    for (final entry in entries) {
      if (entry.id == entryId) return entry;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    category,
    titleKey,
    bodyKey,
    imageAsset,
    entries,
  ];
}
