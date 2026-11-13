import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note_dto.g.dart';

/// JSON form of a [NoteDefinition]. `category` is one of `document`,
/// `observation`, `suspect`.
@JsonSerializable()
class NoteDto {
  const NoteDto({
    required this.id,
    required this.category,
    required this.titleKey,
    required this.bodyKey,
    this.imageAsset,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);

  final String id;
  final NoteCategory category;
  final String titleKey;
  final String bodyKey;
  final String? imageAsset;

  NoteDefinition toEntity() => NoteDefinition(
    id: id,
    category: category,
    titleKey: titleKey,
    bodyKey: bodyKey,
    imageAsset: imageAsset,
  );
}

/// `notes.json`: the notes of one chapter.
@JsonSerializable()
class NotesFileDto {
  const NotesFileDto({required this.formatVersion, required this.notes});

  factory NotesFileDto.fromJson(Map<String, dynamic> json) =>
      _$NotesFileDtoFromJson(json);

  final int formatVersion;
  final List<NoteDto> notes;
}
