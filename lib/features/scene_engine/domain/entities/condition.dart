import 'package:equatable/equatable.dart';

/// A question about the state of the game, answered with yes or no.
///
/// Conditions guard interaction rules (`when`), hotspot visibility
/// (`visibleWhen`) and visual variants. The class is `sealed`: the evaluator
/// must handle every kind, and adding a kind is an architecture decision
/// (ADR first).
sealed class Condition extends Equatable {
  const Condition();
}

/// True when [flag] has been set.
final class FlagSet extends Condition {
  const FlagSet(this.flag);

  final String flag;

  @override
  List<Object?> get props => [flag];
}

/// True while [flag] has not been set.
final class FlagNotSet extends Condition {
  const FlagNotSet(this.flag);

  final String flag;

  @override
  List<Object?> get props => [flag];
}

/// True while the item is in the inventory.
final class HasItem extends Condition {
  const HasItem(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

/// True when the player tapped with exactly this item selected.
final class UsingItem extends Condition {
  const UsingItem(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

/// True when the note is in the notebook.
final class HasNote extends Condition {
  const HasNote(this.noteId);

  final String noteId;

  @override
  List<Object?> get props => [noteId];
}

/// True when every condition in [conditions] is true.
final class AllOf extends Condition {
  const AllOf(this.conditions);

  final List<Condition> conditions;

  @override
  List<Object?> get props => [conditions];
}

/// True when at least one condition in [conditions] is true.
final class AnyOf extends Condition {
  const AnyOf(this.conditions);

  final List<Condition> conditions;

  @override
  List<Object?> get props => [conditions];
}
