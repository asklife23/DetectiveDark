// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemDto _$ItemDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ItemDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'id',
          'nameKey',
          'descriptionKey',
          'iconStyle',
          'iconAsset',
        ],
      );
      final val = ItemDto(
        id: $checkedConvert('id', (v) => v as String),
        nameKey: $checkedConvert('nameKey', (v) => v as String),
        descriptionKey: $checkedConvert('descriptionKey', (v) => v as String),
        iconStyle: $checkedConvert('iconStyle', (v) => v as String),
        iconAsset: $checkedConvert('iconAsset', (v) => v as String?),
      );
      return val;
    });

ItemsFileDto _$ItemsFileDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ItemsFileDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['formatVersion', 'items']);
      final val = ItemsFileDto(
        formatVersion: $checkedConvert(
          'formatVersion',
          (v) => (v as num).toInt(),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => ItemDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
