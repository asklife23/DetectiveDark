// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteDto _$NoteDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NoteDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'category',
          'titleKey',
          'bodyKey',
          'imageAsset',
        ],
      );
      final val = NoteDto(
        id: $checkedConvert('id', (v) => v as String),
        category: $checkedConvert(
          'category',
          (v) => $enumDecode(_$NoteCategoryEnumMap, v),
        ),
        titleKey: $checkedConvert('titleKey', (v) => v as String),
        bodyKey: $checkedConvert('bodyKey', (v) => v as String),
        imageAsset: $checkedConvert('imageAsset', (v) => v as String?),
      );
      return val;
    });

const _$NoteCategoryEnumMap = {
  NoteCategory.document: 'document',
  NoteCategory.observation: 'observation',
  NoteCategory.suspect: 'suspect',
};

NotesFileDto _$NotesFileDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NotesFileDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['formatVersion', 'notes']);
      final val = NotesFileDto(
        formatVersion: $checkedConvert(
          'formatVersion',
          (v) => (v as num).toInt(),
        ),
        notes: $checkedConvert(
          'notes',
          (v) => (v as List<dynamic>)
              .map((e) => NoteDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
