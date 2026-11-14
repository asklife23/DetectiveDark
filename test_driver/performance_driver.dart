// Host side of `integration_test/performance_test.dart`: receives the frame
// time summary from the device and writes it to `build/performance/`.
import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data == null) return;
      final directory = Directory('build/performance')
        ..createSync(recursive: true);
      const encoder = JsonEncoder.withIndent('  ');
      for (final MapEntry(:key, :value) in data.entries) {
        File('${directory.path}/$key.json').writeAsStringSync(
          encoder.convert(value),
        );
      }
    },
  );
}
