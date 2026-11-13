import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/condition_evaluator.dart';
import 'package:equatable/equatable.dart';

/// What a tap on a hotspot leads to.
class ResolvedInteraction extends Equatable {
  const ResolvedInteraction({required this.effects, this.usedItemId});

  /// Nothing happens.
  static const none = ResolvedInteraction(effects: []);

  /// The effects to apply, in order. Empty when no rule matched.
  final List<Effect> effects;

  /// The selected item, when a rule accepted it.
  final String? usedItemId;

  @override
  List<Object?> get props => [effects, usedItemId];
}

/// Decides which rule of a hotspot runs. Pure Dart, no state.
///
/// - Rules are read top to bottom; the first rule whose condition holds
///   runs.
/// - With an item selected, only rules that ask for that item
///   ([UsingItem] somewhere in their condition) are candidates. If none of
///   them holds, the detective gives the generic reaction and nothing else
///   happens: a wrong item never triggers the normal interaction.
/// - Without an item selected, [UsingItem] is always false.
class InteractionResolver {
  const InteractionResolver({this._evaluator = const ConditionEvaluator()});

  /// Text key of the reaction to an item that has no use here.
  static const genericItemNoEffectKey = 'generic_item_no_effect';

  final ConditionEvaluator _evaluator;

  ResolvedInteraction resolve(
    HotspotDefinition hotspot,
    GameProgress progress, {
    String? usingItemId,
  }) {
    if (usingItemId == null) {
      for (final rule in hotspot.interactions) {
        if (_evaluator.holds(rule.when, progress)) {
          return ResolvedInteraction(effects: rule.effects);
        }
      }
      return ResolvedInteraction.none;
    }

    for (final rule in hotspot.interactions) {
      final condition = rule.when;
      if (condition == null || !_asksFor(condition, usingItemId)) continue;
      if (_evaluator.evaluate(condition, progress, usingItemId: usingItemId)) {
        return ResolvedInteraction(
          effects: rule.effects,
          usedItemId: usingItemId,
        );
      }
    }
    return const ResolvedInteraction(effects: [Say(genericItemNoEffectKey)]);
  }

  bool _asksFor(Condition condition, String itemId) => switch (condition) {
    UsingItem(itemId: final asked) => asked == itemId,
    AllOf(:final conditions) ||
    AnyOf(:final conditions) => conditions.any((c) => _asksFor(c, itemId)),
    FlagSet() || FlagNotSet() || HasItem() || HasNote() => false,
  };
}
