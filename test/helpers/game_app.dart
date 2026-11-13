import 'dart:io';

import 'package:detective_dark/app/game/game_screen.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/build_target.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:detective_dark/core/di/injection.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'fake_asset_bundle.dart';

/// A config for tests: dev flavor, no backend.
AppConfig testConfig({bool showDebugOverlay = false}) => AppConfig(
  flavor: Flavor.dev,
  target: BuildTarget.mobile,
  supabaseUrl: '',
  supabaseAnonKey: '',
  showDebugOverlay: showDebugOverlay,
);

/// The real game content, read from disk into memory.
///
/// Widget tests run on a fake clock, where the real asset bundle (true
/// file I/O) would never finish. An in-memory bundle answers at once.
FakeAssetBundle realContentBundle() {
  final files = <String, String>{};
  for (final entity in Directory('assets/content').listSync(recursive: true)) {
    if (entity is File) {
      files[entity.path.replaceAll(r'\', '/')] = entity.readAsStringSync();
    }
  }
  return FakeAssetBundle(files);
}

/// Registers all dependencies like `bootstrap` does, with [assetBundle]
/// (default: the real content) instead of the platform asset bundle.
Future<void> setUpGameDependencies({
  AssetBundle? assetBundle,
  AppConfig? config,
}) async {
  await GetIt.instance.reset();
  await configureDependencies(
    GetIt.instance,
    config ?? testConfig(),
    assetBundle: assetBundle ?? realContentBundle(),
  );
}

/// One frame step used while a scene animates.
const _frame = Duration(milliseconds: 50);

extension GameTester on WidgetTester {
  /// Makes the test window a landscape phone (800×360 logical pixels).
  void useLandscapePhone() {
    view
      ..physicalSize = const Size(2400, 1080)
      ..devicePixelRatio = 3;
    addTearDown(view.reset);
  }

  /// Lets [duration] pass frame by frame.
  ///
  /// Scenes with a glimmering pickup animate forever, so `pumpAndSettle`
  /// would never return; tests advance time explicitly instead.
  Future<void> pumpFor([
    Duration duration = const Duration(milliseconds: 600),
  ]) async {
    for (var elapsed = Duration.zero; elapsed < duration; elapsed += _frame) {
      await pump(_frame);
    }
  }

  /// Shows the game screen and waits until the first scene is up.
  Future<void> pumpGame({bool showDebugTools = false}) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameScreen(showDebugTools: showDebugTools),
      ),
    );
    await pumpFor();
  }

  /// Taps the hotspot with the accessibility [label] and plays the
  /// transition, if one starts.
  Future<void> tapHotspot(String label) async {
    await tap(find.bySemanticsLabel(label));
    await pumpFor();
  }

  /// Unmounts everything, so repeating animations stop before a test ends.
  Future<void> closeGame() => pumpWidget(const SizedBox.shrink());
}
