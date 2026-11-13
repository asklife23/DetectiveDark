import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_dto.g.dart';

/// JSON form of an [ItemDefinition].
@JsonSerializable()
class ItemDto {
  const ItemDto({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconStyle,
    this.iconAsset,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) =>
      _$ItemDtoFromJson(json);

  final String id;
  final String nameKey;
  final String descriptionKey;
  final String iconStyle;
  final String? iconAsset;

  ItemDefinition toEntity() => ItemDefinition(
    id: id,
    nameKey: nameKey,
    descriptionKey: descriptionKey,
    iconStyle: iconStyle,
    iconAsset: iconAsset,
  );
}

/// `items.json`: the items of one chapter.
@JsonSerializable()
class ItemsFileDto {
  const ItemsFileDto({required this.formatVersion, required this.items});

  factory ItemsFileDto.fromJson(Map<String, dynamic> json) =>
      _$ItemsFileDtoFromJson(json);

  final int formatVersion;
  final List<ItemDto> items;
}
