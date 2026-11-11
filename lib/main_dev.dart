import 'package:detective_dark/app/bootstrap.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';

/// Entry point of the `dev` flavor.
///
/// `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`
Future<void> main() => bootstrap(AppConfig.fromEnvironment(Flavor.dev));
