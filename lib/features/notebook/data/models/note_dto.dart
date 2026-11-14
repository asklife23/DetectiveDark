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

/// One entry of `noteExtensions`: lines a later chapter adds to a note of
/// an earlier chapter (ADR 0018). They are appended to its entry catalog.
@JsonSerializable()
class NoteExtensionDto {
  const NoteExtensionDto({required this.note, required this.entries});

  factory NoteExtensionDto.fromJson(Map<String, dynamic> json) =>
      _$NoteExtensionDtoFromJson(json);

  /// ID of the note to extend.
  final String note;
  final List<NoteEntryDto> entries;

  /// [target] with the new entries at the end. Throws a [FormatException]
  /// when an entry ID is already taken.
  NoteDefinition applyTo(NoteDefinition target) {
    final added = entries.map((entry) => entry.toEntity()).toList();
    final taken = {for (final entry in target.entries) entry.id};
    for (final entry in added) {
      if (!taken.add(entry.id)) {
        throw FormatException(
          'noteExtensions "$note": entry ID "${entry.id}" already exists',
        );
      }
    }
    return NoteDefinition(
      id: target.id,
      category: target.category,
      titleKey: target.titleKey,
      bodyKey: target.bodyKey,
      imageAsset: target.imageAsset,
      entries: List.unmodifiable([...target.entries, ...added]),
    );
  }
}

/// A notes file (`notes.json` or one file of `notes/`): the notes of one
/// chapter and, optionally, extensions of notes of earlier chapters.
@JsonSerializable()
class NotesFileDto {
  const NotesFileDto({
    required this.formatVersion,
    this.notes = const [],
    this.noteExtensions = const [],
  });

  factory NotesFileDto.fromJson(Map<String, dynamic> json) =>
      _$NotesFileDtoFromJson(json);

  final int formatVersion;
  final List<NoteDto> notes;
  final List<NoteExtensionDto> noteExtensions;
}
