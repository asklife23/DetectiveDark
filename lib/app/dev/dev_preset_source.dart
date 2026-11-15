import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter/services.dart';

/// Reads the presets of the developer menu from the asset bundle.
///
/// The file is bundled only in the `dev` flavor (`pubspec.yaml`), and
/// Windows has no flavors, so there it is never part of the build. A
/// missing file is therefore normal and means "no presets", not an error.
class DevPresetSource {
  const DevPresetSource(
    this._bundle, {
    this._logger = const AppLogger('dev_menu'),
  });

  static const path = 'assets/dev/presets.json';

  final AssetBundle _bundle;
  final AppLogger _logger;

  Future<List<DevPreset>> load() async {
    final String raw;
    try {
      raw = await _bundle.loadString(path, cache: false);
    } on Object {
      return const [];
    }
    try {
      return parseDevPresets(raw);
    } on FormatException catch (error, stackTrace) {
      // A broken file must not take the menu down with it; the content
      // validation test is what keeps the file correct.
      _logger.error('$path: ${error.message}', stackTrace: stackTrace);
      return const [];
    }
  }
}
