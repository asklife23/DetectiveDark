import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:detective_dark/core/theme/noir_filter_presets.dart';
import 'package:flutter/widgets.dart';

/// The shared noir filter (ADR 0011): a color tint, a vignette and film
/// grain, drawn above the image and its overlay text.
///
/// The grain is one small noise image, generated once and tiled. Drawing it
/// is a single cheap rectangle per frame, on every platform.
class NoirFilter extends StatelessWidget {
  const NoirFilter({required this.preset, super.key});

  final NoirFilterPreset preset;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _NoirFilterPainter(
          preset,
          // One grain pixel per screen pixel: without this the grain gets
          // three times coarser on a phone than on a desktop monitor.
          grainScale: 1 / MediaQuery.devicePixelRatioOf(context),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _NoirFilterPainter extends CustomPainter {
  const _NoirFilterPainter(this.preset, {required this.grainScale});

  final NoirFilterPreset preset;

  /// Size of one grain pixel in logical pixels.
  final double grainScale;

  /// Side of the square grain tile in pixels.
  static const _tileSize = 128;

  /// Where the vignette starts to darken, as a fraction of its radius.
  static const _vignetteStart = 0.55;

  /// Radius of the vignette relative to the shorter side of the image.
  static const _vignetteRadius = 0.95;

  static const _grainSeed = 1947;

  static const _black = Color(0xFF000000);
  static const _white = Color(0xFFFFFFFF);
  static const _transparent = Color(0x00000000);

  static ui.Image? _grainTile;

  /// Random black and white pixels. A fixed seed keeps the grain identical
  /// on every run (static grain; golden tests stay stable).
  static ui.Image _createGrainTile() {
    final random = math.Random(_grainSeed);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final pixel = Paint();
    for (var y = 0; y < _tileSize; y++) {
      for (var x = 0; x < _tileSize; x++) {
        final shade = random.nextBool() ? _white : _black;
        pixel.color = shade.withValues(alpha: random.nextDouble());
        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          pixel,
        );
      }
    }
    return recorder.endRecording().toImageSync(_tileSize, _tileSize);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final area = Offset.zero & size;

    canvas.drawRect(
      area,
      Paint()..color = preset.tint.withValues(alpha: preset.tintOpacity),
    );

    final vignette = RadialGradient(
      radius: _vignetteRadius,
      colors: [
        _transparent,
        _black.withValues(alpha: preset.vignetteOpacity),
      ],
      stops: const [_vignetteStart, 1],
    );
    canvas.drawRect(area, Paint()..shader = vignette.createShader(area));

    final tile = _grainTile ??= _createGrainTile();
    canvas.drawRect(
      area,
      Paint()
        ..shader = ui.ImageShader(
          tile,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.diagonal3Values(grainScale, grainScale, 1).storage,
        )
        // With a shader set, only the alpha of the paint color is used: it
        // fades the whole grain layer.
        ..color = _black.withValues(alpha: preset.grainOpacity),
    );
  }

  @override
  bool shouldRepaint(_NoirFilterPainter oldDelegate) =>
      oldDelegate.preset != preset || oldDelegate.grainScale != grainScale;
}
