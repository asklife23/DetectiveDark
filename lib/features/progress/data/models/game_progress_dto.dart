import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_progress_dto.g.dart';

/// JSON form of a [GameProgress]: what is written into the save.
///
/// It holds only IDs, flags and keys, never texts (ADR 0003), so a save
/// stays valid when a text is reworded or a language is added.
///
/// Sets are written as sorted lists: the same progress always produces the
/// same JSON, whatever order the flags were set in.
@JsonSerializable(createToJson: true, explicitToJson: true)
class GameProgressDto {
  const GameProgressDto({
    required this.caseId,
    required this.chapterId,
    required this.sceneStack,
    required this.inventory,
    required this.notes,
    required this.flags,
    required this.hiddenHotspots,
    required this.visitedSceneIds,
    required this.chatLog,
    required this.spokenLines,
    required this.firedTriggers,
    required this.askedTopics,
    required this.playTimeSeconds,
  });

  factory GameProgressDto.fromJson(Map<String, dynamic> json) =>
      _$GameProgressDtoFromJson(json);

  factory GameProgressDto.fromEntity(GameProgress progress) => GameProgressDto(
    caseId: progress.caseId,
    chapterId: progress.chapterId,
    sceneStack: progress.sceneStack,
    inventory: progress.inventory,
    notes: [
      for (final note in progress.notes) CollectedNoteDto.fromEntity(note),
    ],
    flags: _sorted(progress.flags),
    hiddenHotspots: _sorted(progress.hiddenHotspots),
    visitedSceneIds: _sorted(progress.visitedSceneIds),
    chatLog: [
      for (final entry in progress.chatLog) ChatLogEntryDto.fromEntity(entry),
    ],
    spokenLines: _sorted(progress.spokenLines),
    firedTriggers: _sorted(progress.firedTriggers),
    askedTopics: _sorted(progress.askedTopics),
    playTimeSeconds: progress.playTimeSeconds,
  );

  final String caseId;
  final String chapterId;
  final List<String> sceneStack;
  final List<String> inventory;
  final List<CollectedNoteDto> notes;
  final List<String> flags;
  final List<String> hiddenHotspots;
  final List<String> visitedSceneIds;
  final List<ChatLogEntryDto> chatLog;
  final List<String> spokenLines;
  final List<String> firedTriggers;
  final List<String> askedTopics;
  final int playTimeSeconds;

  static List<String> _sorted(Set<String> values) => values.toList()..sort();

  Map<String, dynamic> toJson() => _$GameProgressDtoToJson(this);

  GameProgress toEntity() {
    // A hand-edited save may hold more messages than the game ever keeps.
    final log = chatLog.length > GameProgress.chatLogLimit
        ? chatLog.sublist(chatLog.length - GameProgress.chatLogLimit)
        : chatLog;

    return GameProgress(
      caseId: caseId,
      chapterId: chapterId,
      sceneStack: List.unmodifiable(sceneStack),
      inventory: List.unmodifiable(inventory),
      notes: List.unmodifiable([for (final note in notes) note.toEntity()]),
      flags: Set.unmodifiable(flags),
      hiddenHotspots: Set.unmodifiable(hiddenHotspots),
      visitedSceneIds: Set.unmodifiable(visitedSceneIds),
      chatLog: List.unmodifiable([for (final entry in log) entry.toEntity()]),
      spokenLines: Set.unmodifiable(spokenLines),
      firedTriggers: Set.unmodifiable(firedTriggers),
      askedTopics: Set.unmodifiable(askedTopics),
      playTimeSeconds: playTimeSeconds,
    );
  }
}

/// JSON form of a [CollectedNote].
@JsonSerializable(createToJson: true, explicitToJson: true)
class CollectedNoteDto {
  const CollectedNoteDto({
    required this.noteId,
    required this.addedAtUtcMs,
    required this.isRead,
    required this.entries,
  });

  factory CollectedNoteDto.fromJson(Map<String, dynamic> json) =>
      _$CollectedNoteDtoFromJson(json);

  factory CollectedNoteDto.fromEntity(CollectedNote note) => CollectedNoteDto(
    noteId: note.noteId,
    addedAtUtcMs: note.addedAtUtcMs,
    isRead: note.isRead,
    entries: [
      for (final entry in note.entries) CollectedNoteEntryDto.fromEntity(entry),
    ],
  );

  final String noteId;
  final int addedAtUtcMs;
  final bool isRead;
  final List<CollectedNoteEntryDto> entries;

  Map<String, dynamic> toJson() => _$CollectedNoteDtoToJson(this);

  CollectedNote toEntity() => CollectedNote(
    noteId: noteId,
    addedAtUtcMs: addedAtUtcMs,
    isRead: isRead,
    entries: List.unmodifiable([for (final entry in entries) entry.toEntity()]),
  );
}

/// JSON form of a [CollectedNoteEntry].
@JsonSerializable(createToJson: true)
class CollectedNoteEntryDto {
  const CollectedNoteEntryDto({
    required this.entryId,
    required this.addedAtUtcMs,
  });

  factory CollectedNoteEntryDto.fromJson(Map<String, dynamic> json) =>
      _$CollectedNoteEntryDtoFromJson(json);

  factory CollectedNoteEntryDto.fromEntity(CollectedNoteEntry entry) =>
      CollectedNoteEntryDto(
        entryId: entry.entryId,
        addedAtUtcMs: entry.addedAtUtcMs,
      );

  final String entryId;
  final int addedAtUtcMs;

  Map<String, dynamic> toJson() => _$CollectedNoteEntryDtoToJson(this);

  CollectedNoteEntry toEntity() =>
      CollectedNoteEntry(entryId: entryId, addedAtUtcMs: addedAtUtcMs);
}

/// JSON form of a [ChatLogEntry].
@JsonSerializable(createToJson: true)
class ChatLogEntryDto {
  const ChatLogEntryDto({
    required this.sender,
    required this.textKey,
    required this.params,
    required this.sentAtUtcMs,
  });

  factory ChatLogEntryDto.fromJson(Map<String, dynamic> json) =>
      _$ChatLogEntryDtoFromJson(json);

  factory ChatLogEntryDto.fromEntity(ChatLogEntry entry) => ChatLogEntryDto(
    sender: entry.sender,
    textKey: entry.textKey,
    params: entry.params,
    sentAtUtcMs: entry.sentAtUtcMs,
  );

  /// Written by name: `detective` or `system`.
  final ChatSender sender;
  final String textKey;
  final Map<String, String> params;
  final int sentAtUtcMs;

  Map<String, dynamic> toJson() => _$ChatLogEntryDtoToJson(this);

  ChatLogEntry toEntity() => ChatLogEntry(
    sender: sender,
    textKey: textKey,
    params: Map.unmodifiable(params),
    sentAtUtcMs: sentAtUtcMs,
  );
}
