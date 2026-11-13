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

  checkBuildFlavor(config, appFlavor);
  logger.info('Starting DetectiveDark (${config.debugLabel})');

  Bloc.observer = const AppBlocObserver(AppLogger('bloc'));
  registerFontLicenses();

  await configureSystemUi();
  await configureDependencies(GetIt.instance, config);

  runApp(App(config: config));
}

/// Routes every uncaught error to [logger].
///
/// - [FlutterError.onError]: errors inside the framework (build, layout,
///   paint, gestures). Flutter's detailed report is still printed.
/// - [PlatformDispatcher.onError]: everything else, e.g. an exception in an
///   `async` function nobody awaited. Returning `true` marks it as handled.
@visibleForTesting
void registerErrorHandlers(AppLogger logger) {
  FlutterError.onError = (details) {
    // Keep Flutter's own console report: it names the widget that caused
    // the error and dumps layout details, which the log line does not.
    FlutterError.presentError(details);
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

/// Stops start-up when the entry point does not belong to the native build
/// flavor, e.g. `--flavor prod -t lib/main_dev.dart`. [buildFlavor] is
/// Flutter's `appFlavor`.
@visibleForTesting
void checkBuildFlavor(AppConfig config, String? buildFlavor) {
  if (config.matchesBuildFlavor(buildFlavor)) return;

  throw StateError(
    'Entry point flavor "${config.flavor.name}" does not match the build '
    'flavor "$buildFlavor". Use lib/main_$buildFlavor.dart.',
  );
}
