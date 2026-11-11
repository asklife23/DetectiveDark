import 'package:detective_dark/app/bootstrap.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/build_target.dart';
import 'package:detective_dark/core/config/flavor.dart';

/// Entry point of the Steam (Windows) build: real players, so the `prod`
/// flavor, with Steam platform services instead of the mobile ones.
///
/// `flutter run -d windows -t lib/main_steam.dart --dart-define-from-file=env/steam.json`
Future<void> main() => bootstrap(
  AppConfig.fromEnvironment(Flavor.prod, target: BuildTarget.steam),
);
