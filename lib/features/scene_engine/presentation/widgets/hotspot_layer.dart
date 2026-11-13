import 'dart:async';

import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:flutter/material.dart';

/// The invisible, tappable areas of a scene.
///
/// Each hotspot rectangle is converted from normalized coordinates to
/// pixels of this layer, which has exactly the size of the scene image.
/// Later hotspots in the list lie on top of earlier ones.
class HotspotLayer extends StatelessWidget {
  const HotspotLayer({
    required this.hotspots,
    required this.onTap,
    this.showDebug = false,
    super.key,
  });

  final List<HotspotDefinition> hotspots;

  /// Called with the hotspot ID. A mouse click and a touch are the same.
  final ValueChanged<String> onTap;

  /// Draws the rectangles and IDs (developer tool).
  final bool showDebug;

  @override
  Widget build(BuildContext context) {
    final texts = context.storyTexts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final hotspot in hotspots)
              Positioned(
                // The key keeps the ripple with its hotspot when another
                // hotspot disappears from the list.
                key: ValueKey(hotspot.id),
                left: hotspot.rect.x * size.width,
                top: hotspot.rect.y * size.height,
                width: hotspot.rect.width * size.width,
                height: hotspot.rect.height * size.height,
                // The anchor lets the app layer find this spot on screen,
                // e.g. to start the flight of a collected item here.
                child: FlyAnchor(
                  id: FlyAnchors.hotspot(hotspot.id),
                  child: _HotspotArea(
                    hotspot: hotspot,
                    label: texts.text(hotspot.labelKey),
                    showDebug: showDebug,
                    onTap: () => onTap(hotspot.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HotspotArea extends StatefulWidget {
  const _HotspotArea({
    required this.hotspot,
    required this.label,
    required this.showDebug,
    required this.onTap,
  });

  final HotspotDefinition hotspot;
  final String label;
  final bool showDebug;
  final VoidCallback onTap;

  @override
  State<_HotspotArea> createState() => _HotspotAreaState();
}

class _HotspotAreaState extends State<_HotspotArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: AppDurations.hotspotRipple,
  );
  Offset _rippleCenter = Offset.zero;

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _rippleCenter = details.localPosition);
    unawaited(_ripple.forward(from: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            if (widget.hotspot.glint) const _Glint(),
            CustomPaint(
              painter: _RipplePainter(_ripple, _rippleCenter),
            ),
            if (widget.showDebug) _DebugFrame(id: widget.hotspot.id),
          ],
        ),
      ),
    );
  }
}

/// A slow, faint pulse of light on something that can be picked up.
class _Glint extends StatefulWidget {
  const _Glint();

  @override
  State<_Glint> createState() => _GlintState();
}

class _GlintState extends State<_Glint> with SingleTickerProviderStateMixin {
  static const _minOpacity = 0.10;
  static const _maxOpacity = 0.42;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.glintPulse,
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween(
    begin: _minOpacity,
    end: _maxOpacity,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppColors.textPrimary, AppColors.glintEdge],
            ),
          ),
        ),
      ),
    );
  }
}

/// A ring that spreads from the tapped point and fades out.
class _RipplePainter extends CustomPainter {
  _RipplePainter(this.progress, this.center) : super(repaint: progress);

  /// Radius of the ring at the end, in logical pixels.
  static const _maxRadius = 28.0;

  static const _startOpacity = 0.5;

  final Animation<double> progress;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    final value = progress.value;
    if (value == 0 || value == 1) return;
    canvas.drawCircle(
      center,
      _maxRadius * Curves.easeOut.transform(value),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.hairline
        ..color = AppColors.textPrimary.withValues(
          alpha: _startOpacity * (1 - value),
        ),
    );
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.progress != progress;
}

/// Developer overlay: the outline of the hotspot and its ID.
class _DebugFrame extends StatelessWidget {
  const _DebugFrame({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.debugOutline,
            width: AppSizes.hairline,
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: Text(
                id,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.debugOutline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
