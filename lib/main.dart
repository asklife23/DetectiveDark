import 'package:detective_dark/app/app.dart';
import 'package:detective_dark/app/bootstrap.dart';

/// Temporary entry point. Step 0.3 replaces it with one entry point per
/// flavor (`main_dev.dart`, `main_staging.dart`, `main_prod.dart`).
Future<void> main() => bootstrap(App.new);
