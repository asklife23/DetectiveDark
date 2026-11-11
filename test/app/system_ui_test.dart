import 'package:detective_dark/app/system_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> runOn(TargetPlatform platform) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await configureSystemUi();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test('on ${platform.name} locks landscape and hides system bars', () async {
      await runOn(platform);

      expect(calls.map((c) => c.method), [
        'SystemChrome.setPreferredOrientations',
        'SystemChrome.setEnabledSystemUIMode',
      ]);
      expect(calls[0].arguments, [
        'DeviceOrientation.landscapeLeft',
        'DeviceOrientation.landscapeRight',
      ]);
      expect(calls[1].arguments, 'SystemUiMode.immersiveSticky');
    });
  }

  test('on Windows makes no platform calls', () async {
    await runOn(TargetPlatform.windows);

    expect(calls, isEmpty);
  });
}
