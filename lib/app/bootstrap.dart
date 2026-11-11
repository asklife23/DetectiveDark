import 'package:detective_dark/app/app.dart';
import 'package:detective_dark/app/app_bloc_observer.dart';
import 'package:detective_dark/app/font_licenses.dart';
import 'package:detective_dark/app/system_ui.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/di/injection.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Shared start-up sequence for every entry point (`main_*.dart`).
///
/// Order matters: error handlers first, so nothing that fails during
/// start-up goes unnoticed; then system UI and dependencies; then the app.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  const logger = AppLogger('app');
  registerErrorHandlers(logger);

  if (!config.matchesBuildFlavor(appFlavor)) {
    throw StateError(
      'Entry point flavor "${config.flavor.name}" does not match the build '
      'flavor "$appFlavor". Use lib/main_$appFlavor.dart.',
    );
  }
  logger.info('Starting DetectiveDark (${config.flavor.name})');

  Bloc.observer = const AppBlocObserver(AppLogger('bloc'));
  registerFontLicenses();

  await configureSystemUi();
  await configureDependencies(GetIt.instance, config);

  runApp(App(config: config));
}

/// Routes every uncaught error to [logger].
///
/// - [FlutterError.onError]: errors inside the framework (build, layout,
///   paint, gestures).
/// - [PlatformDispatcher.onError]: everything else, e.g. an exception in an
///   `async` function nobody awaited. Returning `true` marks it as handled.
@visibleForTesting
void registerErrorHandlers(AppLogger logger) {
  FlutterError.onError = (details) {
    logger.error(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error('Uncaught error', error: error, stackTrace: stackTrace);
    return true;
  };
}
