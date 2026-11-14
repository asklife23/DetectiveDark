import 'package:equatable/equatable.dart';

/// Something that just happened in the game, announced to every feature.
///
/// Events are for reactions in the UI (an item flying to the panel, the
/// typewriter effect). They are never the source of lasting state: that is
/// always read from the progress.
sealed class GameEvent extends Equatable {
  const GameEvent();
}

/// The player arrived in a scene.
final class SceneEntered extends GameEvent {
  const SceneEntered(this.sceneId, {required this.isFirstVisit});

  final String sceneId;
  final bool isFirstVisit;

  @override
  List<Object?> get props => [sceneId, isFirstVisit];
}

/// An item was added to the inventory. [sceneId] and [hotspotId] say where
/// it was picked up, when it came from a hotspot.
final class ItemObtained extends GameEvent {
  const ItemObtained(this.itemId, {this.sceneId, this.hotspotId});

  final String itemId;
  final String? sceneId;
  final String? hotspotId;

  @override
  List<Object?> get props => [itemId, sceneId, hotspotId];
}

/// The selected item was used on a hotspot and a rule accepted it.
final class ItemUsed extends GameEvent {
  const ItemUsed(this.itemId, {required this.hotspotId});

  final String itemId;
  final String hotspotId;

  @override
  List<Object?> get props => [itemId, hotspotId];
}

/// A note was added to the notebook. [sceneId] and [hotspotId] say where it
/// was found, when it came from a hotspot.
final class NoteAdded extends GameEvent {
  const NoteAdded(this.noteId, {this.sceneId, this.hotspotId});

  final String noteId;
  final String? sceneId;
  final String? hotspotId;

  @override
  List<Object?> get props => [noteId, sceneId, hotspotId];
}

/// A line was added to a note that is already in the notebook (ADR 0015):
/// a statement entered into the file of a person. The note is unread again.
final class NoteUpdated extends GameEvent {
  const NoteUpdated(this.noteId, {required this.entryId});

  final String noteId;
  final String entryId;

  @override
  List<Object?> get props => [noteId, entryId];
}

/// The detective said something through the inner voice.
final class DetectiveSaid extends GameEvent {
  const DetectiveSaid(this.messageKey);

  final String messageKey;

  @override
  List<Object?> get props => [messageKey];
}

/// The player asked a dialogue topic for the first time (or showed the
/// evidence that opens it). Asking again does not announce it again.
final class TopicAsked extends GameEvent {
  const TopicAsked(this.dialogueId, this.topicId);

  final String dialogueId;
  final String topicId;

  @override
  List<Object?> get props => [dialogueId, topicId];
}
