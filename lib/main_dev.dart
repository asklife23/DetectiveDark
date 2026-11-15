import 'package:detective_dark/app/bootstrap.dart';
import 'package:detective_dark/app/dev/dev_menu.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';

/// Entry point of the `dev` flavor.
///
/// The only entry point that knows the developer menu: it imports
/// `lib/app/dev/` and hands the menu to `bootstrap`. Staging, prod and Steam
/// do not, so their builds contain no menu code.
///
/// `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`
Future<void> main() =>
    bootstrap(AppConfig.fromEnvironment(Flavor.dev), devMenu: buildDevMenu);
