import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/di/register_core.dart';
import 'package:detective_dark/core/di/register_progress.dart';
import 'package:detective_dark/core/di/register_scene_engine.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

/// Registers every dependency of the app in [getIt].
///
/// This folder is the composition root: the one place that knows which
/// implementation stands behind each interface. Each feature gets its own
/// registration function, called here in dependency order. Widgets read
/// from `get_it` only when creating a `BlocProvider`.
///
/// [assetBundle] replaces the real asset bundle in tests.
Future<void> configureDependencies(
  GetIt getIt,
  AppConfig config, {
  AssetBundle? assetBundle,
}) async {
  getIt.registerSingleton<AppConfig>(config);
  registerCore(getIt, assetBundle: assetBundle ?? rootBundle);
  registerProgress(getIt);
  registerSceneEngine(getIt);
}
