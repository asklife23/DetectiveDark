import 'package:detective_dark/app/bootstrap.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';

/// Entry point of the `prod` flavor.
///
/// `flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json`
Future<void> main() => bootstrap(AppConfig.fromEnvironment(Flavor.prod));
