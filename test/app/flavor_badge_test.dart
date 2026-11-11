import 'package:detective_dark/app/flavor_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the label in capitals', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FlavorBadge(label: 'prod · steam'),
      ),
    );

    expect(find.text('PROD · STEAM'), findsOneWidget);
  });

  testWidgets('lets taps pass through to the widget below', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
              ),
            ),
            const FlavorBadge(label: 'dev'),
          ],
        ),
      ),
    );

    // warnIfMissed: false — the badge is meant to miss hit testing.
    await tester.tap(find.text('DEV'), warnIfMissed: false);

    expect(taps, 1);
  });
}
