import 'package:detective_dark/app/flavor_badge.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the flavor name in capitals', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FlavorBadge(flavor: Flavor.staging),
      ),
    );

    expect(find.text('STAGING'), findsOneWidget);
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
            const FlavorBadge(flavor: Flavor.dev),
          ],
        ),
      ),
    );

    // warnIfMissed: false — the badge is meant to miss hit testing.
    await tester.tap(find.text('DEV'), warnIfMissed: false);

    expect(taps, 1);
  });
}
