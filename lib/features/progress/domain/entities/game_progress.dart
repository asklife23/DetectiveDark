import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:equatable/equatable.dart';

/// Everything the game remembers about one playthrough.
///
/// It is immutable: every change returns a new copy (`withItem`,
/// `withFlag`, ...). A whole interaction is computed as one new
/// [GameProgress] and saved in one step, so a half-applied rule can never be
/// stored or drawn.
///
/// It holds only IDs, flags and keys, never texts (ADR 0003).
class GameProgress extends Equatable {
  const GameProgress({
    required this.caseId,
    required this.chapterId,
    required this.sceneStack,
    this.inventory = const [],
    this.notes = const [],
    this.flags = const {},
    this.hiddenHotspots = const {},
    this.visitedSceneIds = const {},
    this.chatLog = const [],
    this.spokenLines = const {},
    this.playTimeSeconds = 0,
  });

  /// The chat log keeps only its newest entries, so a long playthrough
  /// cannot grow the save without bound (ADR 0013). The one constant.
  static const chatLogLimit = 200;

  final String caseId;
  final String chapterId;

  /// Navigation stack, root first: `[villa_exterior, statue_closeup]`.
  final List<String> sceneStack;

  /// Item IDs in the order they were picked up.
  final List<String> inventory;

  /// Collected notes in the order they were found.
  final List<CollectedNote> notes;

  final Set<String> flags;

  /// Permanently hidden hotspots, as [hotspotKey]s.
  final Set<String> hiddenHotspots;

  final Set<String> visitedSceneIds;

  /// The messages of the detective, oldest first; at most [chatLogLimit].
  /// It is a history for the player: **no game logic reads it**.
  final List<ChatLogEntry> chatLog;

  /// The `first` keys of two-form lines (`say` first/then, greetings) that
  /// have been spoken once. This, not [chatLog], decides which form plays.
  final Set<String> spokenLines;

  final int playTimeSeconds;

  /// Hotspot IDs are unique only inside their scene, so a hidden hotspot is
  /// stored together with its scene.
  static String hotspotKey(String sceneId, String hotspotId) =>
      '$sceneId/$hotspotId';

  /// The scene the player is in. Null only for an empty stack.
  String? get currentSceneId => sceneStack.isEmpty ? null : sceneStack.last;

  int get unreadNoteCount => notes.where((note) => !note.isRead).length;

  bool hasItem(String itemId) => inventory.contains(itemId);

  bool hasNote(String noteId) => notes.any((note) => note.noteId == noteId);

  bool hasFlag(String flag) => flags.contains(flag);

  bool hasVisited(String sceneId) => visitedSceneIds.contains(sceneId);

  bool hasSpoken(String lineKey) => spokenLines.contains(lineKey);

  bool isHotspotHidden(String sceneId, String hotspotId) =>
      hiddenHotspots.contains(hotspotKey(sceneId, hotspotId));

  /// Adds the item at the end. No change if it is already there.
  GameProgress withItem(String itemId) =>
      hasItem(itemId) ? this : _copy(inventory: [...inventory, itemId]);

  GameProgress withoutItem(String itemId) => hasItem(itemId)
      ? _copy(inventory: [...inventory.where((id) => id != itemId)])
      : this;

  /// Adds the note at the end. No change if a note with that ID exists.
  GameProgress withNote(CollectedNote note) =>
      hasNote(note.noteId) ? this : _copy(notes: [...notes, note]);

  GameProgress withNoteRead(String noteId) {
    if (!notes.any((note) => note.noteId == noteId && !note.isRead)) {
      return this;
    }
    return _copy(
      notes: [
        for (final note in notes)
          if (note.noteId == noteId) note.markedRead() else note,
      ],
    );
  }

  GameProgress withFlag(String flag) =>
      hasFlag(flag) ? this : _copy(flags: {...flags, flag});

  GameProgress withHiddenHotspot(String sceneId, String hotspotId) =>
      isHotspotHidden(sceneId, hotspotId)
      ? this
      : _copy(
          hiddenHotspots: {...hiddenHotspots, hotspotKey(sceneId, hotspotId)},
        );

  GameProgress withSceneStack(List<String> stack) =>
      _copy(sceneStack: List.unmodifiable(stack));

  GameProgress withVisited(String sceneId) => hasVisited(sceneId)
      ? this
      : _copy(visitedSceneIds: {...visitedSceneIds, sceneId});

  /// Appends a message. Unlike the other changes this is not idempotent:
  /// the detective may say the same line twice. Beyond [chatLogLimit] the
  /// oldest entries are dropped.
  GameProgress withChatEntry(ChatLogEntry entry) {
    final log = [...chatLog, entry];
    return _copy(
      chatLog: log.length > chatLogLimit
          ? log.sublist(log.length - chatLogLimit)
          : log,
    );
  }

  /// Remembers that the two-form line [lineKey] was spoken. No change if it
  /// already was.
  GameProgress withSpokenLine(String lineKey) =>
      hasSpoken(lineKey) ? this : _copy(spokenLines: {...spokenLines, lineKey});

  GameProgress _copy({
    List<String>? sceneStack,
    List<String>? inventory,
    List<CollectedNote>? notes,
    Set<String>? flags,
    Set<String>? hiddenHotspots,
    Set<String>? visitedSceneIds,
    List<ChatLogEntry>? chatLog,
    Set<String>? spokenLines,
  }) {
    return GameProgress(
      caseId: caseId,
      chapterId: chapterId,
      sceneStack: sceneStack ?? this.sceneStack,
      inventory: inventory ?? this.inventory,
      notes: notes ?? this.notes,
      flags: flags ?? this.flags,
      hiddenHotspots: hiddenHotspots ?? this.hiddenHotspots,
      visitedSceneIds: visitedSceneIds ?? this.visitedSceneIds,
      chatLog: chatLog ?? this.chatLog,
      spokenLines: spokenLines ?? this.spokenLines,
      playTimeSeconds: playTimeSeconds,
    );
  }

  @override
  List<Object?> get props => [
    caseId,
    chapterId,
    sceneStack,
    inventory,
    notes,
    flags,
    hiddenHotspots,
    visitedSceneIds,
    chatLog,
    spokenLines,
    playTimeSeconds,
  ];
}
