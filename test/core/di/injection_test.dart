import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:detective_dark/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  test('configureDependencies registers the AppConfig', () async {
    final getIt = GetIt.asNewInstance();
    final config = AppConfig.fromEnvironment(Flavor.dev);

    await configureDependencies(getIt, config);

    expect(getIt<AppConfig>(), same(config));
  });
}
