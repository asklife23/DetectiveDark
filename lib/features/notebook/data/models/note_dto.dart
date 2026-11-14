import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note_dto.g.dart';

/// JSON form of a [NoteEntryDefinition]: a line a note can gain.
@JsonSerializable()
class NoteEntryDto {
  const NoteEntryDto({required this.id, required this.textKey});

  factory NoteEntryDto.fromJson(Map<String, dynamic> json) =>
      _$NoteEntryDtoFromJson(json);

  final String id;
  final String textKey;

  NoteEntryDefinition toEntity() =>
      NoteEntryDefinition(id: id, textKey: textKey);
}

/// JSON form of a [NoteDefinition]. `category` is one of `document`,
/// `observation`, `person`.
@JsonSerializable()
class NoteDto {
  const NoteDto({
    required this.id,
    required this.category,
    required this.titleKey,
    required this.bodyKey,
    this.imageAsset,
    this.entries = const [],
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);

  final String id;
  final NoteCategory category;
  final String titleKey;
  final String bodyKey;
  final String? imageAsset;
  final List<NoteEntryDto> entries;

  NoteDefinition toEntity() => NoteDefinition(
    id: id,
    category: category,
    titleKey: titleKey,
    bodyKey: bodyKey,
    imageAsset: imageAsset,
    entries: List.unmodifiable(entries.map((entry) => entry.toEntity())),
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
