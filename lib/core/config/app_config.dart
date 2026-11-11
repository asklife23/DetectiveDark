import 'package:detective_dark/core/config/flavor.dart';
import 'package:equatable/equatable.dart';

/// Build-time configuration of one app instance.
///
/// The flavor comes from the entry point (`main_dev.dart`, ...); the other
/// values come from the env file passed with
/// `--dart-define-from-file=env/<flavor>.json`. They are baked into the
/// binary at compile time, so they are never secrets: only public values
/// (like the Supabase anon key) belong here.
class AppConfig extends Equatable {
  const AppConfig({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.showDebugOverlay,
  });

  /// Reads the values defined with `--dart-define-from-file`.
  ///
  /// Missing keys fall back to empty strings. `SHOW_DEBUG_OVERLAY` defaults
  /// to `true` only for [Flavor.dev].
  factory AppConfig.fromEnvironment(Flavor flavor) {
    const hasOverlayKey = bool.hasEnvironment(_showDebugOverlayKey);
    const overlayValue = bool.fromEnvironment(_showDebugOverlayKey);

    return AppConfig(
      flavor: flavor,
      supabaseUrl: const String.fromEnvironment(_supabaseUrlKey),
      supabaseAnonKey: const String.fromEnvironment(_supabaseAnonKeyKey),
      showDebugOverlay: hasOverlayKey ? overlayValue : flavor == Flavor.dev,
    );
  }

  static const _supabaseUrlKey = 'SUPABASE_URL';
  static const _supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';
  static const _showDebugOverlayKey = 'SHOW_DEBUG_OVERLAY';

  final Flavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;

  /// Shows the flavor badge on screen (e.g. "DEV").
  final bool showDebugOverlay;

  /// Whether this config fits the native build flavor ([buildFlavor] is
  /// Flutter's `appFlavor`, i.e. the `--flavor` value).
  ///
  /// Catches mix-ups like `--flavor prod -t lib/main_dev.dart`. Builds
  /// without native flavors (Windows, tests) have no build flavor and always
  /// match.
  bool matchesBuildFlavor(String? buildFlavor) =>
      buildFlavor == null || buildFlavor == flavor.name;

  @override
  List<Object?> get props => [
    flavor,
    supabaseUrl,
    supabaseAnonKey,
    showDebugOverlay,
  ];
}
