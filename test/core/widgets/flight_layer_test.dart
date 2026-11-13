import 'dart:async';

import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/widgets/flight_layer.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const flyer = SizedBox.expand(key: Key('flyer'));
  const from = Rect.fromLTWH(100, 100, 40, 40);
  const to = Rect.fromLTWH(700, 20, 60, 60);

  Future<GlobalKey<FlightLayerState>> pumpLayer(WidgetTester tester) async {
    final key = GlobalKey<FlightLayerState>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FlightLayer(key: key),
      ),
    );
    return key;
  }

  testWidgets('flies its child from the start to the destination', (
    tester,
  ) async {
    final layer = await pumpLayer(tester);
    var landed = false;

    unawaited(
      layer.currentState!
          .fly(from: from, to: () => to, child: flyer)
          .then((_) => landed = true),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.getRect(find.byKey(const Key('flyer'))), from);

    await tester.pump(AppDurations.itemFlight ~/ 2);
    final midway = tester.getRect(find.byKey(const Key('flyer')));
    expect(midway.left, greaterThan(from.left));
    expect(midway.left, lessThan(to.left));
    expect(landed, isFalse);

    await tester.pump(AppDurations.itemFlight);
    await tester.pump();
    expect(landed, isTrue);
    expect(find.byKey(const Key('flyer')), findsNothing);
  });

  testWidgets('does nothing when the destination is not on screen', (
    tester,
  ) async {
    final layer = await pumpLayer(tester);
    var done = false;

    unawaited(
      layer.currentState!
          .fly(from: from, to: () => null, child: flyer)
          .then((_) => done = true),
    );
    await tester.pump();
    await tester.pump();

    expect(done, isTrue);
    expect(find.byKey(const Key('flyer')), findsNothing);
  });

  testWidgets('removing the layer mid-flight is safe', (tester) async {
    final layer = await pumpLayer(tester);

    unawaited(layer.currentState!.fly(from: from, to: () => to, child: flyer));
    await tester.pump();
    await tester.pump(AppDurations.itemFlight ~/ 3);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(AppDurations.itemFlight);

    expect(tester.takeException(), isNull);
  });

  group('FlyAnchors', () {
    testWidgets('reports where a named widget is', (tester) async {
      final anchors = FlyAnchors();
      await tester.pumpWidget(
        FlyAnchorScope(
          anchors: anchors,
          child: const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30, top: 50),
              child: FlyAnchor(
                id: 'slot',
                child: SizedBox(width: 20, height: 10),
              ),
            ),
          ),
        ),
      );

      expect(anchors.rectOf('slot'), const Rect.fromLTWH(30, 50, 20, 10));
      expect(anchors.rectOf('other'), isNull);
    });

    testWidgets('forgets a widget that left the screen', (tester) async {
      final anchors = FlyAnchors();
      await tester.pumpWidget(
        FlyAnchorScope(
          anchors: anchors,
          child: const FlyAnchor(id: 'slot', child: SizedBox()),
        ),
      );
      await tester.pumpWidget(
        FlyAnchorScope(anchors: anchors, child: const SizedBox()),
      );

      expect(anchors.rectOf('slot'), isNull);
    });

    testWidgets('an anchor without a scope just shows its child', (
      tester,
    ) async {
      await tester.pumpWidget(
        const FlyAnchor(
          id: 'slot',
          child: SizedBox(key: Key('child')),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);
    });
  });
}
