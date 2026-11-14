import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'architecture_rules.dart';

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

  // `core/di` is the composition root: it must know every implementation
  // to wire them together, so it is the one exception.
  test('core never imports a feature or the app layer (except core/di)', () {
    final violations = <String>[];

    for (final entity in Directory('lib/core').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.replaceAll(r'\', '/').contains('lib/core/di/')) continue;
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

  group('one write path (ADR 0014)', () {
    /// Every Dart file under `lib/` with its source.
    Map<String, String> sources() => {
      for (final entity in Directory('lib').listSync(recursive: true))
        if (entity is File && entity.path.endsWith('.dart'))
          entity.path.replaceAll(r'\', '/'): entity.readAsStringSync(),
    };

    test('only the effect pipeline and MarkNoteRead save the progress', () {
      expect(saveCallViolations(sources()), isEmpty);
    });

    test('the allowed callers really save (the rule looks at the right '
        'files)', () {
      final all = sources();

      for (final path in saveCallers) {
        expect(all[path], contains('.save('), reason: path);
      }
    });

    test('the rule fires on a save from anywhere else', () {
      final violations = saveCallViolations({
        ...sources(),
        'lib/features/dialogue/domain/usecases/ask_topic.dart':
            'class AskTopic {\n'
            '  Future<void> call() async {\n'
            '    await _progressRepository.save(next);\n'
            '  }\n'
            '}\n',
        'lib/app/dev/dev_menu.dart':
            '// repository.save(x) in a comment is fine\n'
            'void reset() => repository\n'
            '    .save(fresh);\n',
      });

      expect(violations, [
        'lib/features/dialogue/domain/usecases/ask_topic.dart:3',
        'lib/app/dev/dev_menu.dart:3',
      ]);
    });
  });

  group('no cycles between features', () {
    test('the feature graph has no cycle', () {
      expect(featureCycle(importsByFile()), isEmpty);
    });

    test('the graph is read from the imports', () {
      final graph = featureGraph(importsByFile());

      expect(graph['scene_engine'], containsAll(['progress', 'notebook']));
      expect(graph['progress'], isEmpty);
    });

    test('the rule fires on a two-way import', () {
      final cycle = featureCycle({
        ...importsByFile(),
        'lib/features/notebook/domain/usecases/mark_note_read.dart': [
          '${featurePrefix}scene_engine/domain/services/effect_pipeline.dart',
        ],
      });

      expect(cycle, isNotEmpty);
      expect(cycle.first, cycle.last);
      expect(cycle, containsAll(['notebook', 'scene_engine']));
    });

    test('the rule fires on a longer cycle', () {
      final cycle = featureCycle({
        'lib/features/a/domain/a.dart': ['${featurePrefix}b/domain/b.dart'],
        'lib/features/b/domain/b.dart': ['${featurePrefix}c/domain/c.dart'],
        'lib/features/c/domain/c.dart': ['${featurePrefix}a/domain/a.dart'],
        'lib/features/d/domain/d.dart': ['${featurePrefix}a/domain/a.dart'],
      });

      expect(cycle, ['a', 'b', 'c', 'a']);
    });

    test('a diamond is not a cycle', () {
      final cycle = featureCycle({
        'lib/features/a/domain/a.dart': [
          '${featurePrefix}b/domain/b.dart',
          '${featurePrefix}c/domain/c.dart',
        ],
        'lib/features/b/domain/b.dart': ['${featurePrefix}d/domain/d.dart'],
        'lib/features/c/domain/c.dart': ['${featurePrefix}d/domain/d.dart'],
        'lib/features/d/domain/d.dart': <String>[],
      });

      expect(cycle, isEmpty);
    });
  });

  test('the dependency between dialogue and scene engine runs one way '
      '(ADR 0016)', () {
    final graph = featureGraph(importsByFile());

    expect(graph['dialogue'], contains('scene_engine'));
    expect(graph['scene_engine'], isNot(contains('dialogue')));
    expect(graph['notebook'], isNot(contains('dialogue')));
    expect(graph['inventory'], isNot(contains('dialogue')));
  });

  test('a feature data layer never imports the data layer of another '
      'feature (the rule parser comes through the domain)', () {
    final violations = <String>[];

    importsByFile().forEach((path, imports) {
      final (feature, layer) = locate(path);
      if (layer != 'data') return;
      for (final uri in imports.where((u) => u.startsWith(featurePrefix))) {
        final target = uri.substring(featurePrefix.length).split('/');
        if (target[0] != feature && target[1] == 'data') {
          violations.add('$path imports $uri');
        }
      }
    });

    expect(violations, isEmpty);
  });
}
