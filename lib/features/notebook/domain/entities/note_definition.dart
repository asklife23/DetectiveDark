import 'package:equatable/equatable.dart';

/// The notebook section a note belongs to.
enum NoteCategory {
  /// Letters, clippings, receipts, photos.
  document,

  /// Conclusions the detective draws.
  observation,

  /// The file of a suspect.
  suspect,
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
  });

  final String id;
  final NoteCategory category;
  final String titleKey;
  final String bodyKey;
  final String? imageAsset;

  @override
  List<Object?> get props => [id, category, titleKey, bodyKey, imageAsset];
}
