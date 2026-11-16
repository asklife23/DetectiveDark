import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/device/device_id_provider.dart';
import 'package:detective_dark/core/di/register_core.dart';
import 'package:detective_dark/core/di/register_detective_chat.dart';
import 'package:detective_dark/core/di/register_dialogue.dart';
import 'package:detective_dark/core/di/register_inventory.dart';
import 'package:detective_dark/core/di/register_notebook.dart';
import 'package:detective_dark/core/di/register_progress.dart';
import 'package:detective_dark/core/di/register_scene_engine.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:detective_dark/core/storage/key_value_store.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

/// Registers every dependency of the app in [getIt].
///
/// This folder is the composition root: the one place that knows which
/// implementation stands behind each interface. Each feature gets its own
/// registration function, called here in dependency order. Widgets read
/// from `get_it` only when creating a `BlocProvider`.
///
/// [assetBundle], [keyValueStore] and [progressRepository] replace the real
/// asset bundle, `shared_preferences` and the save database in tests.
Future<void> configureDependencies(
  GetIt getIt,
  AppConfig config, {
  AssetBundle? assetBundle,
  KeyValueStore? keyValueStore,
  ProgressRepository? progressRepository,
}) async {
  getIt.registerSingleton<AppConfig>(config);
  registerCore(
    getIt,
    assetBundle: assetBundle ?? rootBundle,
    keyValueStore: keyValueStore,
  );
  registerProgress(getIt, repository: progressRepository);
  registerSceneEngine(getIt);
  registerDialogue(getIt);
  registerInventory(getIt);
  registerNotebook(getIt);
  registerDetectiveChat(getIt);

  await _ensureDeviceId(getIt);
}

/// Creates the device ID on the very first start, so it exists before
/// anything needs it. The game does not depend on it: a failure is logged
/// and the next start tries again.
Future<void> _ensureDeviceId(GetIt getIt) async {
  final deviceId = await getIt<DeviceIdProvider>().get();
  if (deviceId case Failed(:final failure)) {
    const AppLogger('di').warning(
      failure.message,
      error: failure.cause,
      stackTrace: failure.stackTrace,
    );
  }
}
