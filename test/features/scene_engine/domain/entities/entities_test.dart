import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  group('NormalizedRect', () {
    const rect = NormalizedRect(x: 0.2, y: 0.4, width: 0.3, height: 0.2);

    test('exposes its edges and center', () {
      expect(rect.right, closeTo(0.5, 1e-9));
      expect(rect.bottom, closeTo(0.6, 1e-9));
      expect(rect.centerX, closeTo(0.35, 1e-9));
      expect(rect.centerY, closeTo(0.5, 1e-9));
    });

    test('contains points inside and on the edge, not outside', () {
      expect(rect.contains(0.3, 0.5), isTrue);
      expect(rect.contains(0.2, 0.4), isTrue);
      expect(rect.contains(0.19, 0.5), isFalse);
      expect(rect.contains(0.3, 0.61), isFalse);
    });

    test('is valid only inside the image and with a size', () {
      expect(rect.isValid, isTrue);
      expect(
        const NormalizedRect(x: 0.7, y: 0, width: 0.3, height: 1).isValid,
        isTrue,
      );
      expect(
        const NormalizedRect(x: -0.1, y: 0, width: 0.3, height: 0.3).isValid,
        isFalse,
      );
      expect(
        const NormalizedRect(x: 0.8, y: 0, width: 0.3, height: 0.3).isValid,
        isFalse,
      );
      expect(
        const NormalizedRect(x: 0, y: 0.9, width: 0.3, height: 0.3).isValid,
        isFalse,
      );
      expect(
        const NormalizedRect(x: 0, y: 0, width: 0, height: 0.3).isValid,
        isFalse,
      );
    });
  });

  group('SceneTransition', () {
    test('defaults to a 150 ms fade out and in without a hold', () {
      const transition = SceneTransition.standard;

      expect(transition.type, SceneTransitionType.fade);
      expect(transition.fadeOut, AppDurations.sceneFadeOut);
      expect(transition.hold, Duration.zero);
      expect(transition.fadeIn, AppDurations.sceneFadeIn);
      expect(transition.sfx, isNull);
    });

    test('ofType keeps the default timing and drops hold and sound', () {
      const cut = SceneTransition.ofType(SceneTransitionType.cut);

      expect(cut.type, SceneTransitionType.cut);
      expect(cut.hold, Duration.zero);
      expect(cut.sfx, isNull);
    });

    test('goToScene uses the standard transition unless told otherwise', () {
      expect(const GoToScene('hall').transition, SceneTransition.standard);
    });
  });

  test('conditions and effects compare by value', () {
    expect(const FlagSet('a'), const FlagSet('a'));
    expect(const FlagSet('a'), isNot(const FlagNotSet('a')));
    expect(
      const AllOf([FlagSet('a'), HasItem('b')]),
      const AllOf([FlagSet('a'), HasItem('b')]),
    );
    expect(const GiveItem('key'), const GiveItem('key'));
    expect(const GiveItem('key'), isNot(const ConsumeItem('key')));
    expect(const HideHotspot(), const HideHotspot());
  });

  test('a scene finds its hotspots by ID', () {
    const scene = SceneDefinition(
      id: 'villa_door_closeup',
      titleKey: 'scene_door',
      visual: SceneVisual(placeholderStyle: 'door_closed'),
      hotspots: [lockHotspot],
    );

    expect(scene.hotspot('lock'), lockHotspot);
    expect(scene.hotspot('window'), isNull);
  });
}
