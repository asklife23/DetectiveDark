import 'package:detective_dark/features/scene_engine/data/models/scene_visual_dto.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inspection_dto.g.dart';

/// JSON form of an [InspectionDefinition].
@JsonSerializable()
class InspectionDto {
  const InspectionDto({
    required this.id,
    required this.textKey,
    required this.visual,
    this.titleKey,
  });

  factory InspectionDto.fromJson(Map<String, dynamic> json) =>
      _$InspectionDtoFromJson(json);

  final String id;
  final String? titleKey;
  final String textKey;
  final SceneVisualDto visual;

  InspectionDefinition toEntity() {
    try {
      return InspectionDefinition(
        id: id,
        titleKey: titleKey,
        textKey: textKey,
        visual: visual.toEntity(),
      );
    } on FormatException catch (error) {
      throw FormatException('inspection "$id": ${error.message}');
    }
  }
}

/// `inspections.json`: the inspections of one chapter.
@JsonSerializable()
class InspectionsFileDto {
  const InspectionsFileDto({
    required this.formatVersion,
    required this.inspections,
  });

  factory InspectionsFileDto.fromJson(Map<String, dynamic> json) =>
      _$InspectionsFileDtoFromJson(json);

  final int formatVersion;
  final List<InspectionDto> inspections;
}
