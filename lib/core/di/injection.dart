import 'package:detective_dark/core/config/app_config.dart';
import 'package:get_it/get_it.dart';

/// Registers every dependency of the app in [getIt].
///
/// Each feature gets its own registration function in this folder, called
/// from here in dependency order, e.g. `registerSceneEngine(getIt)`.
/// Widgets read from `get_it` only when creating a `BlocProvider`.
Future<void> configureDependencies(GetIt getIt, AppConfig config) async {
  getIt.registerSingleton<AppConfig>(config);
}
