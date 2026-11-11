import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/config/build_target.dart';
import 'package:detective_dark/core/config/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tests run without --dart-define-from-file, so every key is missing and
  // the defaults apply.
  group('AppConfig.fromEnvironment without defines', () {
    test('keeps the flavor and leaves Supabase values empty', () {
      final config = AppConfig.fromEnvironment(Flavor.staging);

      expect(config.flavor, Flavor.staging);
      expect(config.target, BuildTarget.mobile);
      expect(config.supabaseUrl, isEmpty);
      expect(config.supabaseAnonKey, isEmpty);
    });

    test('shows the debug overlay only for dev', () {
      expect(AppConfig.fromEnvironment(Flavor.dev).showDebugOverlay, isTrue);
      expect(
        AppConfig.fromEnvironment(Flavor.staging).showDebugOverlay,
        isFalse,
      );
      expect(AppConfig.fromEnvironment(Flavor.prod).showDebugOverlay, isFalse);
    });
  });

  group('build target', () {
    test('the Steam entry point config targets Steam', () {
      final config = AppConfig.fromEnvironment(
        Flavor.prod,
        target: BuildTarget.steam,
      );

      expect(config.target, BuildTarget.steam);
      expect(config.showDebugOverlay, isFalse);
    });

    test('debugLabel names the target only for Steam', () {
      expect(AppConfig.fromEnvironment(Flavor.dev).debugLabel, 'dev');
      expect(
        AppConfig.fromEnvironment(
          Flavor.prod,
          target: BuildTarget.steam,
        ).debugLabel,
        'prod · steam',
      );
    });
  });

  group('matchesBuildFlavor', () {
    final config = AppConfig.fromEnvironment(Flavor.dev);

    test('matches the same flavor name', () {
      expect(config.matchesBuildFlavor('dev'), isTrue);
    });

    test('rejects a different flavor', () {
      expect(config.matchesBuildFlavor('prod'), isFalse);
    });

    test('matches builds without a native flavor', () {
      expect(config.matchesBuildFlavor(null), isTrue);
    });
  });

  test('flavor names match the Android productFlavors', () {
    expect(Flavor.values.map((f) => f.name), ['dev', 'staging', 'prod']);
  });

  test('supports value equality', () {
    expect(
      AppConfig.fromEnvironment(Flavor.prod),
      AppConfig.fromEnvironment(Flavor.prod),
    );
  });
}
