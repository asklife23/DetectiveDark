import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

/// Fits the scene into the available area at a fixed 16:9 ratio and fills
/// the rest with dark bars (letterbox).
///
/// Everything inside (image, overlay text, hotspots) uses coordinates
/// relative to this box, so it all scales together and nothing drifts apart
/// on a phone, a tablet or a resized window.
class SceneViewport extends StatelessWidget {
  const SceneViewport({required this.child, super.key});

  /// Width divided by height of every scene image.
  static const double aspectRatio = 16 / 9;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.fade,
      child: Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}
