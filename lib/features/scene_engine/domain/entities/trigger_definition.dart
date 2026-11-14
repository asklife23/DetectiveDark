import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:equatable/equatable.dart';

/// A rule that runs **once**, the first time its condition holds, no matter
/// which action made it hold (ADR 0014).
///
/// "Both witnesses were asked about the villa" is written here once,
/// instead of being copied into every rule that could complete it.
class TriggerDefinition extends Equatable {
  const TriggerDefinition({
    required this.id,
    required this.when,
    required this.effects,
  });

  /// Unique inside the case; stored in the save once the trigger has fired.
  final String id;

  final Condition when;

  /// Allowed: `say`, `setFlag`, `addNote`, `addNoteEntry`, `giveItem`.
  final List<Effect> effects;

  @override
  List<Object?> get props => [id, when, effects];
}
