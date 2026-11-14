import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';
import 'package:equatable/equatable.dart';

/// One thing that happens when an interaction rule runs.
///
/// The class is `sealed`: the effect applier must handle every kind, and
/// adding a kind is an architecture decision (ADR first). `OpenPuzzle` and
/// `PlayMedia` arrive in Phase 5.
sealed class Effect extends Equatable {
  const Effect();
}

/// Moves to another scene, through [transition].
final class GoToScene extends Effect {
  const GoToScene(this.sceneId, {this.transition = SceneTransition.standard});

  final String sceneId;
  final SceneTransition transition;

  @override
  List<Object?> get props => [sceneId, transition];
}

/// Puts an item into the inventory.
final class GiveItem extends Effect {
  const GiveItem(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

/// Removes an item from the inventory (the key stays in the lock).
final class ConsumeItem extends Effect {
  const ConsumeItem(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

/// Adds a note to the notebook.
final class AddNote extends Effect {
  const AddNote(this.noteId);

  final String noteId;

  @override
  List<Object?> get props => [noteId];
}

/// Adds a line to a note (ADR 0015): what a person said goes into their
/// file instead of becoming a note of its own. If the note is not in the
/// notebook yet, it is added first.
final class AddNoteEntry extends Effect {
  const AddNoteEntry({required this.noteId, required this.entryId});

  final String noteId;
  final String entryId;

  @override
  List<Object?> get props => [noteId, entryId];
}

/// Sets a flag. Flags are never cleared: the story only moves forward.
final class SetFlag extends Effect {
  const SetFlag(this.flag);

  final String flag;

  @override
  List<Object?> get props => [flag];
}

/// Hides the tapped hotspot for good (a picked-up object does not return).
final class HideHotspot extends Effect {
  const HideHotspot();

  @override
  List<Object?> get props => [];
}

/// Makes the detective say a line through the inner voice.
///
/// With a [repeatKey] the line has two forms (ADR 0013): [messageKey] is
/// said the first time, [repeatKey] every time after that. "Already said"
/// is remembered in the save (`spokenLines`), under [messageKey].
final class Say extends Effect {
  const Say(this.messageKey, {this.repeatKey});

  /// The line; with a [repeatKey], the line of the first time (`first`).
  final String messageKey;

  /// The shorter line of every later time (`then`). Null for a plain line.
  final String? repeatKey;

  @override
  List<Object?> get props => [messageKey, repeatKey];
}

/// Opens the inspection panel above the scene without leaving it (ADR 0010).
final class Inspect extends Effect {
  const Inspect(this.inspectionId);

  final String inspectionId;

  @override
  List<Object?> get props => [inspectionId];
}

/// Opens the conversation with a character above the scene (ADR 0016).
///
/// Interface state like [Inspect]: it does not change the navigation stack
/// and is not saved. It carries only the ID of the dialogue.
final class Talk extends Effect {
  const Talk(this.dialogueId);

  final String dialogueId;

  @override
  List<Object?> get props => [dialogueId];
}
