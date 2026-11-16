import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:detective_dark/features/progress/domain/entities/collected_note.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';

/// A progress that uses **every** field of the save, for tests that prove
/// nothing is lost on the way to disk and back.
const richProgress = GameProgress(
  caseId: 'case01',
  chapterId: 'ch01',
  sceneStack: ['villa_exterior', 'statue_closeup'],
  inventory: ['brass_key', 'crowbar'],
  notes: [
    CollectedNote(noteId: 'torn_letter', addedAtUtcMs: 1700000000100),
    CollectedNote(
      noteId: 'person_pharmacist',
      addedAtUtcMs: 1700000000200,
      isRead: true,
      entries: [
        CollectedNoteEntry(entryId: 'alibi', addedAtUtcMs: 1700000000300),
        CollectedNoteEntry(entryId: 'lied', addedAtUtcMs: 1700000000400),
      ],
    ),
  ],
  flags: {'front_door_open', 'alarm_off'},
  hiddenHotspots: {'statue_closeup/key', 'villa_hall/crowbar'},
  visitedSceneIds: {'villa_exterior', 'statue_closeup'},
  chatLog: [
    ChatLogEntry(textKey: 'intro_line', sentAtUtcMs: 1700000000500),
    ChatLogEntry(
      sender: ChatSender.system,
      textKey: 'hint_header',
      params: {'step': '2'},
      sentAtUtcMs: 1700000000600,
    ),
  ],
  spokenLines: {'statue_first_look'},
  firedTriggers: {'both_witnesses_asked'},
  askedTopics: {'pharmacist/about_villa', 'barista/last_night'},
  playTimeSeconds: 754,
);
