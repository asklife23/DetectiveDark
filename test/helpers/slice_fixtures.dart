import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';

/// Hand-built pieces of the vertical slice (villa door, statue key) for unit
/// tests that should not depend on the JSON content.

const anyRect = NormalizedRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2);

const brassKey = 'brass_key';
const crowbar = 'crowbar';
const doorOpenFlag = 'front_door_open';

/// The lock of the villa door, with the rules of the acceptance scenario:
/// open door → hall; brass key → unlock; otherwise "Locked."
const lockHotspot = HotspotDefinition(
  id: 'lock',
  rect: anyRect,
  labelKey: 'hotspot_lock',
  interactions: [
    InteractionRule(
      when: FlagSet(doorOpenFlag),
      effects: [GoToScene('villa_hall')],
    ),
    InteractionRule(
      when: UsingItem(brassKey),
      effects: [
        SetFlag(doorOpenFlag),
        ConsumeItem(brassKey),
        Say('door_unlocked'),
      ],
    ),
    InteractionRule(effects: [Say('door_locked')]),
  ],
);

/// The plaque on the statue: a look-only detail.
const plaqueHotspot = HotspotDefinition(
  id: 'statue_plaque',
  rect: anyRect,
  labelKey: 'hotspot_plaque',
  interactions: [
    InteractionRule(effects: [Inspect('statue_plaque')]),
  ],
);

/// A fresh game standing in front of the villa.
const newGame = GameProgress(
  caseId: 'case01',
  chapterId: 'ch01',
  sceneStack: ['villa_exterior'],
);
