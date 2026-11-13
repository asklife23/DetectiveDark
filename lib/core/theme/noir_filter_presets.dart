import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';

/// The settings of the shared noir filter (ADR 0011): film grain, vignette
/// and a color tint, drawn above every background and inspection image so
/// that pictures made at different times look like one film.
class NoirFilterPreset {
  const NoirFilterPreset({
    required this.grainOpacity,
    required this.vignetteOpacity,
    required this.tint,
    required this.tintOpacity,
  });

  /// Strength of the film grain, 0–1.
  final double grainOpacity;

  /// How dark the corners get, 0–1.
  final double vignetteOpacity;

  /// Color laid over the whole image.
  final Color tint;

  /// Strength of [tint], 0–1.
  final double tintOpacity;
}

/// The named presets. Content picks one by name and never writes numbers;
/// no preset may make overlay text unreadable.
abstract final class NoirFilterPresets {
  /// Outdoors at night: cold tint, strong vignette. The default.
  static const night = 'night';

  /// Indoors by lamp light: warmer and a little brighter.
  static const interior = 'interior';

  /// Close looks at objects and documents: light touch, text stays crisp.
  static const closeUp = 'close_up';

  static const String defaultName = night;

  static const Map<String, NoirFilterPreset> _presets = {
    night: NoirFilterPreset(
      grainOpacity: 0.10,
      vignetteOpacity: 0.55,
      tint: AppColors.nightBlue,
      tintOpacity: 0.12,
    ),
    interior: NoirFilterPreset(
      grainOpacity: 0.09,
      vignetteOpacity: 0.45,
      tint: AppColors.accent,
      tintOpacity: 0.06,
    ),
    closeUp: NoirFilterPreset(
      grainOpacity: 0.07,
      vignetteOpacity: 0.30,
      tint: AppColors.nightBlue,
      tintOpacity: 0.05,
    ),
  };

  /// Every preset name content may use.
  static Set<String> get names => _presets.keys.toSet();

  /// The preset called [name]; null or an unknown name gives the default
  /// (the content validation test reports unknown names).
  static NoirFilterPreset resolve(String? name) =>
      _presets[name] ?? _presets[defaultName]!;
}
