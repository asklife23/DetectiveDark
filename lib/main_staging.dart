import 'package:detective_dark/app/bootstrap.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';

/// Entry point of the `staging` flavor.
///
/// `flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=env/staging.json`
Future<void> main() => bootstrap(AppConfig.fromEnvironment(Flavor.staging));
