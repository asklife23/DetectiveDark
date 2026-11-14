import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';

/// Reads conditions and effects from their JSON form.
///
/// The rule language (`when` / `do`) is the same everywhere: in hotspots,
/// in triggers, in dialogue topics and, later, in items. The code that
/// parses it lives in the data layer of the scene engine. Another feature's
/// data layer may not import that (a feature sees only the **domain** of
/// another feature), so it asks for this interface instead and gets the
/// implementation from dependency injection.
abstract interface class RuleParser {
  /// Throws a [FormatException] for anything that is not a valid condition.
  Condition parseCondition(Object? json);

  /// Throws a [FormatException] when one entry is not a valid effect.
  List<Effect> parseEffects(List<dynamic> json);
}
