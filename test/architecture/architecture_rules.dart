/// Pure checks behind the architecture test. They take plain data (paths,
/// sources, import URIs), so the test can also feed them deliberately
/// broken input and prove that each rule really fires.
library;

const featurePrefix = 'package:detective_dark/features/';

/// The only files that may call `ProgressRepository.save` (ADR 0014): the
/// effect pipeline and, by name, the one exception `MarkNoteRead`.
/// Repository implementations (`progress/data`) may call it on each other.
const saveCallers = [
  'lib/features/scene_engine/domain/services/effect_pipeline.dart',
  'lib/features/notebook/domain/usecases/mark_note_read.dart',
];

final _saveCall = RegExp(r'\.\s*save\s*\(');

/// Every `.save(` call outside the allowed files, as `path:line`.
List<String> saveCallViolations(Map<String, String> sourcesByPath) {
  final violations = <String>[];
  sourcesByPath.forEach((path, source) {
    if (saveCallers.contains(path) ||
        path.startsWith('lib/features/progress/data/')) {
      return;
    }
    for (final (index, line) in source.split('\n').indexed) {
      if (line.trimLeft().startsWith('//')) continue;
      if (_saveCall.hasMatch(line)) violations.add('$path:${index + 1}');
    }
  });
  return violations;
}

/// `lib/features/inventory/domain/x.dart` → `inventory`.
String featureOf(String path) {
  final parts = path.split('/');
  return parts[parts.indexOf('features') + 1];
}

/// The feature dependency graph: A → B when any file of A imports B.
Map<String, Set<String>> featureGraph(Map<String, List<String>> importsByFile) {
  final graph = <String, Set<String>>{};
  importsByFile.forEach((path, imports) {
    final feature = featureOf(path);
    final targets = graph.putIfAbsent(feature, () => {});
    for (final uri in imports.where((u) => u.startsWith(featurePrefix))) {
      final target = uri.substring(featurePrefix.length).split('/').first;
      if (target != feature) targets.add(target);
    }
  });
  return graph;
}

/// The first dependency cycle between features, as the chain of feature
/// names (`[a, b, a]`); empty when the graph has none.
List<String> featureCycle(Map<String, List<String>> importsByFile) {
  final graph = featureGraph(importsByFile);
  final done = <String>{};

  List<String> visit(String feature, List<String> path) {
    final index = path.indexOf(feature);
    if (index >= 0) return [...path.sublist(index), feature];
    if (done.contains(feature)) return const [];
    for (final target in graph[feature] ?? const <String>{}) {
      final cycle = visit(target, [...path, feature]);
      if (cycle.isNotEmpty) return cycle;
    }
    done.add(feature);
    return const [];
  }

  for (final feature in graph.keys) {
    final cycle = visit(feature, const []);
    if (cycle.isNotEmpty) return cycle;
  }
  return const [];
}
