import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/game_harness.dart';

/// The acceptance scenario of Phase 1 (plan.md), steps 1–11, played on the
/// bloc with the real JSON content and no UI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the vertical slice plays from the villa to the letter', () async {
    final game = GameHarness();
    final bloc = game.createBloc();
    addTearDown(bloc.close);
    addTearDown(game.dispose);

    List<String> chat() => [
      for (final entry in bloc.state.progress!.chatLog) entry.textKey,
    ];

    // 1. The villa opens with the detective's first remark; no Back.
    await bloc.start();
    expect(bloc.state.status, SceneStatus.ready);
    expect(bloc.sceneId, 'villa_exterior');
    expect(bloc.hotspotIds, ['door', 'statue']);
    expect(bloc.state.canGoBack, isFalse);
    expect(chat(), ['say_villa_first_look']);

    // 2. Door → close-up of the door. Back is available.
    await bloc.tap('door');
    expect(bloc.sceneId, 'villa_door_closeup');
    expect(bloc.state.stack, ['villa_exterior', 'villa_door_closeup']);
    expect(bloc.state.canGoBack, isTrue);
    expect(bloc.state.visual!.placeholderStyle, 'villa_door_closed');

    // 3. The lock: "Locked."
    await bloc.tap('lock');
    expect(chat().last, 'say_door_locked');
    expect(bloc.sceneId, 'villa_door_closeup');

    // 4. Back → villa → statue close-up, with the key in place.
    await bloc.back();
    expect(bloc.sceneId, 'villa_exterior');
    await bloc.tap('statue');
    expect(bloc.sceneId, 'statue_closeup');
    expect(bloc.hotspotIds, contains('statue_key'));
    expect(
      bloc.state.visibleHotspots.map((hotspot) => hotspot.sprite),
      contains(isNotNull),
    );

    // 5. Take the key: it leaves the scene and enters the inventory.
    await bloc.tap('statue_key');
    expect(bloc.state.progress!.inventory, ['brass_key']);
    expect(bloc.hotspotIds, isNot(contains('statue_key')));
    expect(
      bloc.state.visibleHotspots.map((hotspot) => hotspot.sprite),
      everyElement(isNull),
    );
    expect(chat().last, 'say_statue_key_found');
    expect(game.events, contains(isA<ItemObtained>()));

    // 6. The key on the statue itself: only the generic reaction.
    await bloc.tap('statue_body', usingItemId: 'brass_key');
    expect(chat().last, 'generic_item_no_effect');
    expect(bloc.state.progress!.inventory, ['brass_key']);

    // 7. Back → door close-up → key on the lock: the door opens, the key is
    //    used up.
    await bloc.back();
    await bloc.tap('door');
    await bloc.tap('lock', usingItemId: 'brass_key');
    expect(bloc.state.progress!.hasFlag('front_door_open'), isTrue);
    expect(bloc.state.progress!.inventory, isEmpty);
    expect(bloc.state.visual!.placeholderStyle, 'villa_door_open');
    expect(bloc.hotspotIds, ['doorway']);
    expect(chat().last, 'say_door_unlocked');
    expect(
      game.events,
      contains(const ItemUsed('brass_key', hotspotId: 'lock')),
    );

    // 8. Through the open door into the hall; take the paper.
    await bloc.tap('doorway');
    expect(bloc.sceneId, 'villa_hall');
    expect(bloc.state.stack, [
      'villa_exterior',
      'villa_door_closeup',
      'villa_hall',
    ]);
    await bloc.tap('desk_paper');
    expect(bloc.hotspotIds, isEmpty);
    expect(bloc.state.visual!.placeholderStyle, 'villa_hall');

    // 9. The letter is in the notebook, unread.
    final notes = bloc.state.progress!.notes;
    expect(notes.single.noteId, 'hall_letter');
    expect(bloc.state.progress!.unreadNoteCount, 1);

    // 10. Back, Back → villa. The key is still gone, the door still open.
    await bloc.back();
    expect(bloc.sceneId, 'villa_door_closeup');
    expect(bloc.state.visual!.placeholderStyle, 'villa_door_open');
    await bloc.back();
    expect(bloc.sceneId, 'villa_exterior');
    await bloc.tap('statue');
    expect(bloc.hotspotIds, isNot(contains('statue_key')));

    // 11. The plaque opens the inspection panel; the scene stays. Back
    //     closes only the panel; Back again leaves the scene.
    await bloc.tap('statue_plaque');
    expect(bloc.state.activeInspection!.id, 'statue_plaque');
    expect(bloc.sceneId, 'statue_closeup');
    expect(bloc.state.transitionPhase, TransitionPhase.idle);

    await bloc.back();
    expect(bloc.state.activeInspection, isNull);
    expect(bloc.sceneId, 'statue_closeup');

    await bloc.back();
    expect(bloc.sceneId, 'villa_exterior');
    expect(bloc.state.canGoBack, isFalse);

    // The first remark was made once, not on every visit to the villa.
    expect(chat().where((key) => key == 'say_villa_first_look'), hasLength(1));
  });
}
