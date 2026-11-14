import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_sprite.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/normalized_rect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/hotspot_layer.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/inspect_panel.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/overlay_layer.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_viewport.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_visual_view.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/sprite_layer.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/transition_overlay.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _texts = ContentTexts({
  'label_door': 'Front door',
  'label_key': 'Key',
  'number': '17',
  'plaque_title': 'Plaque',
  'plaque_text': 'Faith and silence.',
});

/// Wraps [child] with theme and story texts, in a box of [size].
Widget _host(Widget child, {Size size = const Size(800, 450)}) => MaterialApp(
  theme: AppTheme.dark(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ContentTextScope(
    texts: _texts,
    child: Center(
      child: SizedBox.fromSize(size: size, child: child),
    ),
  ),
);

void main() {
  group('SceneViewport', () {
    Future<Size> viewportSize(WidgetTester tester, Size area) async {
      const childKey = Key('scene');
      await tester.pumpWidget(
        _host(
          const SceneViewport(child: SizedBox.expand(key: childKey)),
          size: area,
        ),
      );
      return tester.getSize(find.byKey(childKey));
    }

    testWidgets('keeps 16:9 in a wide area (bars left and right)', (
      tester,
    ) async {
      final size = await viewportSize(tester, const Size(800, 360));

      expect(size.height, 360);
      expect(size.width, closeTo(640, 0.01));
    });

    testWidgets('keeps 16:9 in a tall area (bars top and bottom)', (
      tester,
    ) async {
      final size = await viewportSize(tester, const Size(600, 500));

      expect(size.width, 600);
      expect(size.height, closeTo(337.5, 0.01));
    });
  });

  group('HotspotLayer', () {
    const door = HotspotDefinition(
      id: 'door',
      rect: NormalizedRect(x: 0.25, y: 0.5, width: 0.5, height: 0.25),
      labelKey: 'label_door',
    );
    const key = HotspotDefinition(
      id: 'key',
      rect: NormalizedRect(x: 0.4, y: 0.55, width: 0.1, height: 0.1),
      labelKey: 'label_key',
      glint: true,
    );

    testWidgets('places hotspots by their normalized rect', (tester) async {
      await tester.pumpWidget(
        _host(HotspotLayer(hotspots: const [door], onTap: (_) {})),
      );

      final layer = tester.getTopLeft(find.byType(HotspotLayer));
      final area = tester.getRect(find.bySemanticsLabel('Front door'));
      expect(area.topLeft - layer, const Offset(200, 225));
      expect(area.size, const Size(400, 112.5));
    });

    testWidgets('a tap reports the hotspot ID', (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        _host(HotspotLayer(hotspots: const [door], onTap: tapped.add)),
      );

      await tester.tap(find.bySemanticsLabel('Front door'));
      await tester.pump(const Duration(seconds: 1));

      expect(tapped, ['door']);
    });

    testWidgets('a mouse click works like a touch', (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        _host(HotspotLayer(hotspots: const [door], onTap: tapped.add)),
      );

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.down(tester.getCenter(find.bySemanticsLabel('Front door')));
      await gesture.up();
      await tester.pump(const Duration(seconds: 1));

      expect(tapped, ['door']);
    });

    testWidgets('where two hotspots overlap, the later one is on top', (
      tester,
    ) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        _host(HotspotLayer(hotspots: const [door, key], onTap: tapped.add)),
      );

      await tester.tap(find.bySemanticsLabel('Key'));
      await tester.pump(const Duration(seconds: 1));

      expect(tapped, ['key']);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('debug mode shows the hotspot IDs', (tester) async {
      await tester.pumpWidget(
        _host(
          HotspotLayer(hotspots: const [door], onTap: (_) {}, showDebug: true),
        ),
      );

      expect(find.text('door'), findsOneWidget);
    });

    testWidgets('exposes hotspots as buttons to accessibility', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(HotspotLayer(hotspots: const [door], onTap: (_) {})),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Front door')),
        matchesSemantics(
          label: 'Front door',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('OverlayLayer', () {
    testWidgets('draws overlay text inside its normalized rect', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const OverlayLayer(
            overlays: [
              TextOverlay(
                rect: NormalizedRect(x: 0.5, y: 0.2, width: 0.1, height: 0.1),
                textKey: 'number',
                style: 'brass',
              ),
            ],
          ),
        ),
      );

      final layer = tester.getRect(find.byType(OverlayLayer));
      final text = tester.getRect(find.text('17'));
      final box = Rect.fromLTWH(layer.left + 400, layer.top + 90, 80, 45);
      expect(box.contains(text.topLeft), isTrue);
      expect(box.contains(text.bottomRight - const Offset(0.01, 0.01)), isTrue);
    });

    testWidgets('the text scales with the scene', (tester) async {
      const layer = OverlayLayer(
        overlays: [
          TextOverlay(
            rect: NormalizedRect(x: 0.1, y: 0.1, width: 0.5, height: 0.2),
            textKey: 'number',
            style: 'engraved',
          ),
        ],
      );

      await tester.pumpWidget(_host(layer, size: const Size(400, 225)));
      final small = tester.getSize(find.byType(FittedBox));
      await tester.pumpWidget(_host(layer));
      final large = tester.getSize(find.byType(FittedBox));

      expect(large.width, small.width * 2);
      expect(large.height, small.height * 2);
    });
  });

  group('SpriteLayer', () {
    const key = HotspotSprite(
      rect: NormalizedRect(x: 0.5, y: 0.2, width: 0.1, height: 0.2),
      placeholderStyle: 'sprite_brass_key',
    );

    Finder art(String style) => find.byWidgetPredicate(
      (widget) => widget is PlaceholderArt && widget.style == style,
    );

    testWidgets('draws a sprite inside its normalized rect', (tester) async {
      await tester.pumpWidget(_host(const SpriteLayer(sprites: [key])));

      final layer = tester.getTopLeft(find.byType(SpriteLayer));
      final rect = tester.getRect(art('sprite_brass_key'));
      expect(rect.left - layer.dx, moreOrLessEquals(400));
      expect(rect.top - layer.dy, moreOrLessEquals(90));
      expect(rect.size, const Size(80, 90));
    });

    testWidgets('draws nothing without sprites', (tester) async {
      await tester.pumpWidget(_host(const SpriteLayer(sprites: [])));

      expect(find.byType(PlaceholderArt), findsNothing);
    });

    testWidgets('an image that cannot be loaded falls back to the '
        'placeholder', (tester) async {
      await tester.pumpWidget(
        _host(
          const SpriteLayer(
            sprites: [
              HotspotSprite(
                rect: NormalizedRect(x: 0.5, y: 0.2, width: 0.1, height: 0.2),
                placeholderStyle: 'sprite_letter',
                image: 'assets/art/missing.webp',
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(art('sprite_letter'), findsOneWidget);
    });

    testWidgets('SceneVisualView draws sprites above the background and '
        'under overlays and filter', (tester) async {
      await tester.pumpWidget(
        _host(
          const SceneVisualView(
            visual: SceneVisual(
              placeholderStyle: 'statue_closeup',
              overlays: [
                TextOverlay(
                  rect: NormalizedRect(x: 0.5, y: 0.5, width: 0.1, height: 0.1),
                  textKey: 'number',
                  style: 'brass',
                ),
              ],
            ),
            sprites: [key],
          ),
        ),
      );

      // Children of a Stack paint in order: a later one lies on top.
      final stack = tester.widget<Stack>(
        find
            .descendant(
              of: find.byType(SceneVisualView),
              matching: find.byType(Stack),
            )
            .first,
      );
      final order = [
        for (final child in stack.children) child.runtimeType.toString(),
      ];
      expect(order.indexOf('SpriteLayer'), 1);
      expect(order.indexOf('OverlayLayer'), 2);
      expect(order.indexOf('NoirFilter'), 3);
    });
  });

  testWidgets('SceneVisualView paints picture, overlays and filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SceneVisualView(
          visual: SceneVisual(
            placeholderStyle: 'villa_exterior',
            filterPreset: 'night',
            overlays: [
              TextOverlay(
                rect: NormalizedRect(x: 0.5, y: 0.5, width: 0.1, height: 0.1),
                textKey: 'number',
                style: 'brass',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('17'), findsOneWidget);
  });

  testWidgets('a background that cannot be loaded falls back to the '
      'placeholder', (tester) async {
    await tester.pumpWidget(
      _host(
        const SceneVisualView(
          visual: SceneVisual(
            placeholderStyle: 'villa_exterior',
            background: 'assets/scenes/missing.webp',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  group('TransitionOverlay', () {
    const transition = SceneTransition(hold: Duration(milliseconds: 400));

    Widget overlay(
      TransitionPhase phase,
      List<String> log, {
      SceneTransition? using = transition,
    }) => _host(
      TransitionOverlay(
        phase: phase,
        transition: using,
        onCovered: () => log.add('covered'),
        onFinished: () => log.add('finished'),
      ),
    );

    testWidgets('covering: fades out, holds, then reports covered', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(overlay(TransitionPhase.idle, log));
      await tester.pumpWidget(overlay(TransitionPhase.covering, log));

      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump();
      expect(log, isEmpty, reason: 'still holding in the dark');

      await tester.pump(const Duration(milliseconds: 400));
      expect(log, ['covered']);
    });

    testWidgets('revealing: fades in, then reports finished', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(overlay(TransitionPhase.covering, log));
      await tester.pump(const Duration(seconds: 1));
      log.clear();

      await tester.pumpWidget(overlay(TransitionPhase.revealing, log));
      await tester.pump(const Duration(milliseconds: 100));
      expect(log, isEmpty);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(log, ['finished']);
    });

    testWidgets('without a hold it reports covered right after the fade', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(overlay(TransitionPhase.idle, log));
      await tester.pumpWidget(
        overlay(
          TransitionPhase.covering,
          log,
          using: SceneTransition.standard,
        ),
      );
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump();

      expect(log, ['covered']);
    });

    testWidgets('swallows taps while running, lets them through when idle', (
      tester,
    ) async {
      var taps = 0;
      Widget stack(TransitionPhase phase) => _host(
        Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
            ),
            TransitionOverlay(
              phase: phase,
              transition: transition,
              onCovered: () {},
              onFinished: () {},
            ),
          ],
        ),
      );

      await tester.pumpWidget(stack(TransitionPhase.idle));
      await tester.tapAt(tester.getCenter(find.byType(TransitionOverlay)));
      expect(taps, 1);

      await tester.pumpWidget(stack(TransitionPhase.covering));
      await tester.tapAt(tester.getCenter(find.byType(TransitionOverlay)));
      expect(taps, 1);

      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('InspectPanel', () {
    const inspection = InspectionDefinition(
      id: 'plaque',
      titleKey: 'plaque_title',
      textKey: 'plaque_text',
      visual: SceneVisual(placeholderStyle: 'statue_plaque'),
    );

    testWidgets('shows title and text', (tester) async {
      await tester.pumpWidget(
        _host(InspectPanel(inspection: inspection, onClose: () {})),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Plaque'), findsOneWidget);
      expect(find.text('Faith and silence.'), findsOneWidget);
    });

    testWidgets('a tap on the panel itself does not close it', (tester) async {
      var closed = 0;
      await tester.pumpWidget(
        _host(InspectPanel(inspection: inspection, onClose: () => closed++)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Faith and silence.'));
      expect(closed, 0);

      await tester.tapAt(
        tester.getTopLeft(find.byType(InspectPanel)) + const Offset(3, 3),
      );
      expect(closed, 1);
    });
  });
}
