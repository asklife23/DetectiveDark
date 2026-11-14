import 'package:detective_dark/features/scene_engine/data/models/condition_codec.dart';
import 'package:detective_dark/features/scene_engine/data/models/effect_codec.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/trigger_definition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trigger_dto.g.dart';

/// JSON form of a [TriggerDefinition]: `id`, `when` and `do`.
@JsonSerializable()
class TriggerDto {
  const TriggerDto({
    required this.id,
    required this.when,
    required this.effects,
  });

  factory TriggerDto.fromJson(Map<String, dynamic> json) =>
      _$TriggerDtoFromJson(json);

  final String id;
  final Map<String, dynamic> when;

  @JsonKey(name: 'do')
  final List<Map<String, dynamic>> effects;

  TriggerDefinition toEntity() {
    try {
      return TriggerDefinition(
        id: id,
        when: ConditionCodec.parse(when),
        effects: EffectCodec.parseList(effects),
      );
    } on FormatException catch (error) {
      throw FormatException('trigger "$id": ${error.message}');
    }
  }
}

/// `triggers.json`: the triggers of one chapter. The file is optional.
@JsonSerializable()
class TriggersFileDto {
  const TriggersFileDto({required this.formatVersion, required this.triggers});

  factory TriggersFileDto.fromJson(Map<String, dynamic> json) =>
      _$TriggersFileDtoFromJson(json);

  final int formatVersion;
  final List<TriggerDto> triggers;
}
