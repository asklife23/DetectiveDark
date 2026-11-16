import 'dart:convert';

import 'package:detective_dark/features/progress/data/models/game_progress_dto.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../helpers/progress_fixtures.dart';
import '../../../../helpers/slice_fixtures.dart';

void main() {
  /// To JSON text and back, as the save does.
  GameProgress roundTrip(GameProgress progress) {
    final text = jsonEncode(GameProgressDto.fromEntity(progress).toJson());
    final json = jsonDecode(text) as Map<String, dynamic>;
    return GameProgressDto.fromJson(json).toEntity();
  }

  test('every field survives the way to JSON and back', () {
    expect(roundTrip(richProgress), richProgress);
  });

  test('a new game survives too (empty lists and sets)', () {
    expect(roundTrip(newGame), newGame);
  });

  test('the JSON holds IDs and keys under the documented names', () {
    final json = GameProgressDto.fromEntity(richProgress).toJson();

    expect(json.keys, [
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
    ]);
    expect((json['notes'] as List).last, {
      'noteId': 'person_pharmacist',
      'addedAtUtcMs': 1700000000200,
      'isRead': true,
      'entries': [
        {'entryId': 'alibi', 'addedAtUtcMs': 1700000000300},
        {'entryId': 'lied', 'addedAtUtcMs': 1700000000400},
      ],
    });
    expect((json['chatLog'] as List).last, {
      'sender': 'system',
      'textKey': 'hint_header',
      'params': {'step': '2'},
      'sentAtUtcMs': 1700000000600,
    });
  });

  test('sets are written sorted: the same progress gives the same text, '
      'whatever order things happened in', () {
    final one = newGame.withFlag('b').withFlag('a').withFlag('c');
    final other = newGame.withFlag('c').withFlag('a').withFlag('b');

    expect(GameProgressDto.fromEntity(one).toJson()['flags'], ['a', 'b', 'c']);
    expect(
      jsonEncode(GameProgressDto.fromEntity(one).toJson()),
      jsonEncode(GameProgressDto.fromEntity(other).toJson()),
    );
  });

  test('lists keep their order (inventory, scene stack)', () {
    final progress = newGame.withItem('zebra').withItem('apple');

    expect(roundTrip(progress).inventory, ['zebra', 'apple']);
  });

  test('a chat log longer than the limit is cut to its newest entries', () {
    final json = GameProgressDto.fromEntity(newGame).toJson();
    json['chatLog'] = [
      for (var i = 0; i < GameProgress.chatLogLimit + 5; i++)
        {
          'sender': 'detective',
          'textKey': 'line_$i',
          'params': <String, String>{},
          'sentAtUtcMs': i,
        },
    ];

    final log = GameProgressDto.fromJson(json).toEntity().chatLog;

    expect(log, hasLength(GameProgress.chatLogLimit));
    expect(log.first.textKey, 'line_5');
    expect(log.last.sender, ChatSender.detective);
  });

  group('a damaged payload is rejected, not half-read', () {
    Map<String, dynamic> validJson() =>
        GameProgressDto.fromEntity(richProgress).toJson();

    test('missing field', () {
      final json = validJson()..remove('inventory');

      expect(
        () => GameProgressDto.fromJson(json),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('wrong type', () {
      final json = validJson()..['flags'] = 'front_door_open';

      expect(
        () => GameProgressDto.fromJson(json),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('unknown field', () {
      final json = validJson()..['gold'] = 9999;

      expect(
        () => GameProgressDto.fromJson(json),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('unknown chat sender', () {
      final json = validJson();
      ((json['chatLog'] as List).first as Map)['sender'] = 'butler';

      expect(
        () => GameProgressDto.fromJson(json),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
