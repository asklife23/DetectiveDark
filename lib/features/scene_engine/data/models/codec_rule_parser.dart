import 'package:detective_dark/features/scene_engine/data/models/condition_codec.dart';
import 'package:detective_dark/features/scene_engine/data/models/effect_codec.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/rule_parser.dart';

/// The [RuleParser] of the game: the same codecs the scene files use.
class CodecRuleParser implements RuleParser {
  const CodecRuleParser();

  @override
  Condition parseCondition(Object? json) => ConditionCodec.parse(json);

  @override
  List<Effect> parseEffects(List<dynamic> json) => EffectCodec.parseList(json);
}
