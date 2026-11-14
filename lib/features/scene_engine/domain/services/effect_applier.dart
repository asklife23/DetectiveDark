import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:equatable/equatable.dart';

/// Where and when a list of effects runs.
class EffectContext extends Equatable {
  const EffectContext({
    required this.sceneId,
    required this.nowUtcMs,
    this.hotspotId,
    this.usedItemId,
  });

  final String sceneId;

  /// The tapped hotspot. Null for effects that do not come from a tap
  /// (`onFirstEnter`).
  final String? hotspotId;

  /// The selected item, when the rule accepted it.
  final String? usedItemId;

  /// UTC milliseconds since the Unix epoch.
  final int nowUtcMs;

  @override
  List<Object?> get props => [sceneId, hotspotId, usedItemId, nowUtcMs];
}

/// The result of applying effects: the new progress plus what the caller
/// still has to do with it.
class EffectOutcome extends Equatable {
  const EffectOutcome({
    required this.progress,
    this.events = const [],
    this.navigation,
    this.inspectionId,
  });

  /// The progress after all effects. Save it in one step.
  final GameProgress progress;

  /// Events to publish once the save succeeded.
  final List<GameEvent> events;

  /// A requested scene change, if any.
  final GoToScene? navigation;

  /// An inspection to open, if any.
  final String? inspectionId;

  @override
  List<Object?> get props => [progress, events, navigation, inspectionId];
}

/// Turns a list of effects into one new [GameProgress].
///
/// It has no side effects: it neither saves nor publishes. That keeps every
/// rule atomic (all its effects end up in a single save) and makes the whole
/// effect system testable with plain values. Puzzle `onSolved` effects
/// (Phase 5) go through the same class.
class EffectApplier {
  const EffectApplier();

  EffectOutcome apply(
    GameProgress progress,
    List<Effect> effects,
    EffectContext context,
  ) {
    var next = progress;
    final events = <GameEvent>[];
    GoToScene? navigation;
    String? inspectionId;

    final hotspotId = context.hotspotId;
    final usedItemId = context.usedItemId;
    if (usedItemId != null && hotspotId != null) {
      events.add(ItemUsed(usedItemId, hotspotId: hotspotId));
    }

    for (final effect in effects) {
      switch (effect) {
        case GiveItem(:final itemId):
          if (!next.hasItem(itemId)) {
            next = next.withItem(itemId);
            events.add(
              ItemObtained(
                itemId,
                sceneId: context.sceneId,
                hotspotId: hotspotId,
              ),
            );
          }
        case ConsumeItem(:final itemId):
          next = next.withoutItem(itemId);
        case AddNote(:final noteId):
          if (!next.hasNote(noteId)) {
            next = next.withNote(
              CollectedNote(noteId: noteId, addedAtUtcMs: context.nowUtcMs),
            );
            events.add(
              NoteAdded(
                noteId,
                sceneId: context.sceneId,
                hotspotId: hotspotId,
              ),
            );
          }
        case AddNoteEntry(:final noteId, :final entryId):
          final entry = CollectedNoteEntry(
            entryId: entryId,
            addedAtUtcMs: context.nowUtcMs,
          );
          if (!next.hasNote(noteId)) {
            // The file is opened with its first line: a new note.
            next = next.withNote(
              CollectedNote(
                noteId: noteId,
                addedAtUtcMs: context.nowUtcMs,
                entries: [entry],
              ),
            );
            events.add(
              NoteAdded(
                noteId,
                sceneId: context.sceneId,
                hotspotId: hotspotId,
              ),
            );
          } else if (!next.hasNoteEntry(noteId, entryId)) {
            // A known file gains a line and is unread again.
            next = next.withNoteEntry(noteId, entry);
            events.add(NoteUpdated(noteId, entryId: entryId));
          }
        case SetFlag(:final flag):
          next = next.withFlag(flag);
        case HideHotspot():
          if (hotspotId != null) {
            next = next.withHiddenHotspot(context.sceneId, hotspotId);
          }
        case Say(:final messageKey, :final repeatKey):
          // A two-form line plays `first` once, then `then` (ADR 0013).
          final lineKey = repeatKey != null && next.hasSpoken(messageKey)
              ? repeatKey
              : messageKey;
          if (repeatKey != null) next = next.withSpokenLine(messageKey);
          next = next.withChatEntry(
            ChatLogEntry(textKey: lineKey, sentAtUtcMs: context.nowUtcMs),
          );
          events.add(DetectiveSaid(lineKey));
        case GoToScene():
          navigation = effect;
        case Inspect(inspectionId: final id):
          inspectionId = id;
      }
    }

    return EffectOutcome(
      progress: next,
      events: List.unmodifiable(events),
      navigation: navigation,
      inspectionId: inspectionId,
    );
  }
}
