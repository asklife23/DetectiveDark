import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the dependency rules of CLAUDE.md section 3 by reading the import
/// lines of every file under `lib/features`.
void main() {
  final featuresDir = Directory('lib/features');
  final importPattern = RegExp(r'''^import\s+['"]([^'"]+)['"]''');

  /// Dart files of all features with their import URIs.
  Map<String, List<String>> importsByFile() {
    final result = <String, List<String>>{};
    if (!featuresDir.existsSync()) return result;

    for (final entity in featuresDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      result[path] = [
        for (final line in entity.readAsLinesSync())
          if (importPattern.firstMatch(line) case final match?) match.group(1)!,
      ];
    }
    return result;
  }

  /// `lib/features/inventory/domain/x.dart` → (`inventory`, `domain`).
  (String feature, String layer) locate(String path) {
    final parts = path.split('/');
    final index = parts.indexOf('features');
    return (parts[index + 1], parts[index + 2]);
  }

  const featurePrefix = 'package:detective_dark/features/';

  test('the feature folders exist', () {
    expect(importsByFile(), isNotEmpty);
  });

  test('domain is pure Dart: no Flutter, only equatable as a package', () {
    final violations = <String>[];

    importsByFile().forEach((path, imports) {
      if (locate(path).$2 != 'domain') return;
      for (final uri in imports) {
        final allowed =
            uri.startsWith('dart:') && uri != 'dart:ui' && uri != 'dart:io' ||
            uri.startsWith('package:equatable/') ||
            uri.startsWith('package:detective_dark/');
        if (!allowed) violations.add('$path imports $uri');
      }
    });

    expect(violations, isEmpty);
  });

  test('domain imports no data or presentation layer', () {
    final violations = <String>[];

    importsByFile().forEach((path, imports) {
      if (locate(path).$2 != 'domain') return;
      for (final uri in imports.where((u) => u.startsWith(featurePrefix))) {
        final layer = uri.substring(featurePrefix.length).split('/')[1];
        if (layer != 'domain') violations.add('$path imports $uri');
      }
    });

    expect(violations, isEmpty);
  });

  test('presentation never imports data', () {
    final violations = <String>[];

    importsByFile().forEach((path, imports) {
      if (locate(path).$2 != 'presentation') return;
      for (final uri in imports.where((u) => u.startsWith(featurePrefix))) {
        final layer = uri.substring(featurePrefix.length).split('/')[1];
        if (layer == 'data') violations.add('$path imports $uri');
      }
    });

    expect(violations, isEmpty);
  });

  test('a feature imports only the domain of another feature', () {
    final violations = <String>[];

    importsByFile().forEach((path, imports) {
      final (feature, _) = locate(path);
      for (final uri in imports.where((u) => u.startsWith(featurePrefix))) {
        final target = uri.substring(featurePrefix.length).split('/');
        if (target[0] != feature && target[1] != 'domain') {
          violations.add('$path imports $uri');
        }
      }
    });

    expect(violations, isEmpty);
  });

  test('core never imports a feature or the app layer', () {
    final violations = <String>[];

    for (final entity in Directory('lib/core').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      for (final line in entity.readAsLinesSync()) {
        final uri = importPattern.firstMatch(line)?.group(1);
        if (uri == null) continue;
        if (uri.startsWith(featurePrefix) ||
            uri.startsWith('package:detective_dark/app/')) {
          violations.add('${entity.path} imports $uri');
        }
      }
    }

    expect(violations, isEmpty);
  });
}
