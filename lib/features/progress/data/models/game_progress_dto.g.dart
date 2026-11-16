// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameProgressDto _$GameProgressDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GameProgressDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'caseId',
          'chapterId',
          'sceneStack',
          'inventory',
          'notes',
          'flags',
          'hiddenHotspots',
          'visitedSceneIds',
          'chatLog',
          'spokenLines',
          'firedTriggers',
          'askedTopics',
          'playTimeSeconds',
        ],
      );
      final val = GameProgressDto(
        caseId: $checkedConvert('caseId', (v) => v as String),
        chapterId: $checkedConvert('chapterId', (v) => v as String),
        sceneStack: $checkedConvert(
          'sceneStack',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        inventory: $checkedConvert(
          'inventory',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        notes: $checkedConvert(
          'notes',
          (v) => (v as List<dynamic>)
              .map((e) => CollectedNoteDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        flags: $checkedConvert(
          'flags',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        hiddenHotspots: $checkedConvert(
          'hiddenHotspots',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        visitedSceneIds: $checkedConvert(
          'visitedSceneIds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        chatLog: $checkedConvert(
          'chatLog',
          (v) => (v as List<dynamic>)
              .map((e) => ChatLogEntryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        spokenLines: $checkedConvert(
          'spokenLines',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        firedTriggers: $checkedConvert(
          'firedTriggers',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        askedTopics: $checkedConvert(
          'askedTopics',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        playTimeSeconds: $checkedConvert(
          'playTimeSeconds',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GameProgressDtoToJson(GameProgressDto instance) =>
    <String, dynamic>{
      'caseId': instance.caseId,
      'chapterId': instance.chapterId,
      'sceneStack': instance.sceneStack,
      'inventory': instance.inventory,
      'notes': instance.notes.map((e) => e.toJson()).toList(),
      'flags': instance.flags,
      'hiddenHotspots': instance.hiddenHotspots,
      'visitedSceneIds': instance.visitedSceneIds,
      'chatLog': instance.chatLog.map((e) => e.toJson()).toList(),
      'spokenLines': instance.spokenLines,
      'firedTriggers': instance.firedTriggers,
      'askedTopics': instance.askedTopics,
      'playTimeSeconds': instance.playTimeSeconds,
    };

CollectedNoteDto _$CollectedNoteDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CollectedNoteDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['noteId', 'addedAtUtcMs', 'isRead', 'entries'],
  );
  final val = CollectedNoteDto(
    noteId: $checkedConvert('noteId', (v) => v as String),
    addedAtUtcMs: $checkedConvert('addedAtUtcMs', (v) => (v as num).toInt()),
    isRead: $checkedConvert('isRead', (v) => v as bool),
    entries: $checkedConvert(
      'entries',
      (v) => (v as List<dynamic>)
          .map((e) => CollectedNoteEntryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CollectedNoteDtoToJson(CollectedNoteDto instance) =>
    <String, dynamic>{
      'noteId': instance.noteId,
      'addedAtUtcMs': instance.addedAtUtcMs,
      'isRead': instance.isRead,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };

CollectedNoteEntryDto _$CollectedNoteEntryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CollectedNoteEntryDto', json, ($checkedConvert) {
  $checkKeys(json, allowedKeys: const ['entryId', 'addedAtUtcMs']);
  final val = CollectedNoteEntryDto(
    entryId: $checkedConvert('entryId', (v) => v as String),
    addedAtUtcMs: $checkedConvert('addedAtUtcMs', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$CollectedNoteEntryDtoToJson(
  CollectedNoteEntryDto instance,
) => <String, dynamic>{
  'entryId': instance.entryId,
  'addedAtUtcMs': instance.addedAtUtcMs,
};

ChatLogEntryDto _$ChatLogEntryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChatLogEntryDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['sender', 'textKey', 'params', 'sentAtUtcMs'],
      );
      final val = ChatLogEntryDto(
        sender: $checkedConvert(
          'sender',
          (v) => $enumDecode(_$ChatSenderEnumMap, v),
        ),
        textKey: $checkedConvert('textKey', (v) => v as String),
        params: $checkedConvert(
          'params',
          (v) => Map<String, String>.from(v as Map),
        ),
        sentAtUtcMs: $checkedConvert('sentAtUtcMs', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ChatLogEntryDtoToJson(ChatLogEntryDto instance) =>
    <String, dynamic>{
      'sender': _$ChatSenderEnumMap[instance.sender]!,
      'textKey': instance.textKey,
      'params': instance.params,
      'sentAtUtcMs': instance.sentAtUtcMs,
    };

const _$ChatSenderEnumMap = {
  ChatSender.detective: 'detective',
  ChatSender.system: 'system',
};
