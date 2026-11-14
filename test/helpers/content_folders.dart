import 'dart:io';

/// The check behind "every content folder is declared" (ADR 0018).
///
/// A folder entry in `pubspec.yaml` covers only the files directly inside
/// it, and the content loaders find files through the asset manifest, which
/// knows bundled files only. A content folder that is missing from
/// `pubspec.yaml` would therefore not fail with "file not found": its
/// content would silently be absent from the game. This check turns that
/// into a failing test.

final _assetEntry = RegExp(
  r'''^\s*-\s+(?:path:\s*)?["']?(assets/[^\s"'#]+)''',
  multiLine: true,
);

/// The folders under [contentRoot] that `pubspec.yaml` declares as assets
/// (entries that end with a slash), e.g. `assets/content/common/`.
List<String> declaredContentFolders(
  String pubspecYaml, {
  String contentRoot = 'assets/content',
}) => [
  for (final match in _assetEntry.allMatches(pubspecYaml))
    if (match.group(1)!.startsWith('$contentRoot/') &&
        match.group(1)!.endsWith('/'))
      match.group(1)!,
];

/// The folders under `projectRoot/contentRoot` that hold at least one file
/// directly, as project-relative paths with a trailing slash.
List<String> contentFoldersOnDisk(
  Directory projectRoot, {
  String contentRoot = 'assets/content',
}) {
  final root = Directory('${projectRoot.path}/$contentRoot');
  if (!root.existsSync()) return const [];

  final rootPath = projectRoot.absolute.path.replaceAll(r'\', '/');
  final folders = <String>{};
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    final parent = entity.parent.absolute.path.replaceAll(r'\', '/');
    folders.add('${parent.substring(rootPath.length + 1)}/');
  }
  return folders.toList()..sort();
}

/// What is wrong between the content folders on disk and the ones declared
/// in `pubspec.yaml`. Empty when they match.
List<String> contentFolderProblems({
  required String pubspecYaml,
  required List<String> foldersOnDisk,
  String contentRoot = 'assets/content',
}) {
  final declared = declaredContentFolders(
    pubspecYaml,
    contentRoot: contentRoot,
  );
  String undeclared(String folder) =>
      '$folder holds content files but is not listed under flutter.assets '
      'in pubspec.yaml: its content would be missing from the game';

  return [
    for (final folder in foldersOnDisk)
      if (!declared.contains(folder)) undeclared(folder),
    for (final folder in declared)
      if (!foldersOnDisk.contains(folder))
        'pubspec.yaml lists $folder but no such folder with files exists',
  ];
}
