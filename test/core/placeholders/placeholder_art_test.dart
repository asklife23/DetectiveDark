import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/placeholders/placeholder_styles.dart';
import 'package:detective_dark/core/theme/noir_filter_presets.dart';
import 'package:detective_dark/core/theme/overlay_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every placeholder style has its own drawing', () {
    for (final style in PlaceholderStyles.names) {
      expect(
        PlaceholderArt.painterFor(style),
        isNot(isA<UnknownPlaceholderPainter>()),
        reason: 'style "$style"',
      );
    }
  });

  test('an unknown style gets the plain fallback', () {
    expect(
      PlaceholderArt.painterFor('castle'),
      isA<UnknownPlaceholderPainter>(),
    );
  });

  testWidgets('every drawing paints without errors at phone and desktop '
      'sizes', (tester) async {
    for (final size in const [Size(640, 360), Size(1280, 720), Size(64, 64)]) {
      for (final style in [...PlaceholderStyles.names, 'castle']) {
        await tester.pumpWidget(
          Center(
            child: SizedBox.fromSize(
              size: size,
              child: PlaceholderArt(style: style),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$style at $size');
      }
    }
  });

  test('variants repaint only when their state differs', () {
    final closed = PlaceholderArt.painterFor(PlaceholderStyles.villaDoorClosed);
    final open = PlaceholderArt.painterFor(PlaceholderStyles.villaDoorOpen);

    expect(open.shouldRepaint(closed), isTrue);
    expect(closed.shouldRepaint(closed), isFalse);
  });

  group('named presets', () {
    test('overlay styles never inherit interface decoration', () {
      for (final name in OverlayTextStyles.names) {
        final style = OverlayTextStyles.resolve(name);
        expect(style.inherit, isFalse, reason: name);
        expect(style.decoration, TextDecoration.none, reason: name);
      }
    });

    test('an unknown overlay style falls back to typewriter', () {
      expect(
        OverlayTextStyles.resolve('neon'),
        OverlayTextStyles.resolve(OverlayTextStyles.typewriter),
      );
    });

    test('a missing or unknown filter preset gives the default', () {
      final fallback = NoirFilterPresets.resolve(NoirFilterPresets.defaultName);

      expect(NoirFilterPresets.resolve(null), same(fallback));
      expect(NoirFilterPresets.resolve('sepia'), same(fallback));
    });

    test('no preset can drown overlay text', () {
      for (final name in NoirFilterPresets.names) {
        final preset = NoirFilterPresets.resolve(name);
        expect(preset.grainOpacity, lessThanOrEqualTo(0.15), reason: name);
        expect(preset.tintOpacity, lessThanOrEqualTo(0.2), reason: name);
        expect(preset.vignetteOpacity, lessThanOrEqualTo(0.6), reason: name);
      }
    });
  });
}
