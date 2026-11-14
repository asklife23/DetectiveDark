import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:equatable/equatable.dart';

/// One chapter of `case.json` that is present in this build, with the
/// content files it consists of.
class ChapterManifest extends Equatable {
  const ChapterManifest({
    required this.id,
    required this.entrySceneId,
    this.files = const {},
  });

  final String id;
  final String entrySceneId;

  /// The asset paths of each kind of content, in name order: the single
  /// file, or every file of the folder. Empty for an optional kind the
  /// chapter leaves out.
  final Map<ContentType, List<String>> files;

  List<String> filesOf(ContentType type) => files[type] ?? const [];

  @override
  List<Object?> get props => [id, entrySceneId, files];
}

/// The table of contents of a case (`case.json`): which chapters exist, in
/// play order. Every content loader starts here to find its files, so the
/// rules about chapters and files live in this one place (ADR 0018):
///
/// - **One file or one folder per kind.** `scenes.json` or `scenes/*.json`;
///   both together are an error. Files of a folder are read in name order.
/// - **A missing chapter is skipped.** A chapter that is listed but has no
///   file at all in the bundle is left out (a demo build ships chapter 1
///   only). A chapter that is only partly there is an error; so is a
///   missing first chapter, and a chapter that follows a missing one.
class CaseManifest extends Equatable {
  const CaseManifest({
    required this.id,
    required this.chapters,
    this.skippedChapterIds = const [],
  });

  final String id;

  /// The chapters that are present in this build, in play order.
  final List<ChapterManifest> chapters;

  /// Chapters listed in `case.json` whose files are not in the bundle.
  final List<String> skippedChapterIds;

  /// Reads `case.json` of [caseId] and finds the files of its chapters.
  ///
  /// [chapterLimit] keeps only the first N listed chapters, as if the
  /// later ones did not exist. The content validation test uses it to
  /// check that an early chapter does not depend on a later one.
  ///
  /// Throws a [ContentException] when the file is missing or malformed, or
  /// when the chapter folders break the rules above.
  static Future<CaseManifest> read(
    ContentAssetSource source,
    String caseId, {
    int? chapterLimit,
  }) async {
    final path = ContentPaths.caseManifest(caseId);
    final json = await source.readObject(path);

    Never fail(String message) => throw ContentException(path, message);

    const known = {ContentAssetSource.formatVersionKey, 'id', 'chapters'};
    final unknown = json.keys.where((key) => !known.contains(key));
    if (unknown.isNotEmpty) fail('unknown keys: ${unknown.join(', ')}');

    final id = json['id'];
    if (id is! String) fail('"id" must be a string');
    if (id != caseId) fail('"id" is "$id" but the folder is "$caseId"');

    final rawChapters = json['chapters'];
    if (rawChapters is! List || rawChapters.isEmpty) {
      fail('"chapters" must be a non-empty list');
    }

    final listed = <ChapterManifest>[];
    for (final raw in rawChapters) {
      if (raw is! Map<String, dynamic>) fail('a chapter must be an object');
      final chapterId = raw['id'];
      final entrySceneId = raw['entrySceneId'];
      if (chapterId is! String || entrySceneId is! String) {
        fail('a chapter needs string "id" and "entrySceneId"');
      }
      if (raw.length != 2) {
        fail('chapter "$chapterId" has unknown keys');
      }
      if (listed.any((chapter) => chapter.id == chapterId)) {
        fail('duplicate chapter "$chapterId"');
      }
      listed.add(ChapterManifest(id: chapterId, entrySceneId: entrySceneId));
    }

    if (chapterLimit != null && chapterLimit < 1) {
      fail('the chapter limit must be at least 1, got $chapterLimit');
    }

    final present = <ChapterManifest>[];
    final skipped = <String>[];
    for (final chapter in listed.take(chapterLimit ?? listed.length)) {
      final folder = ContentPaths.chapterFolder(caseId, chapter.id);
      final assets = await source.list(folder);

      if (assets.isEmpty) {
        if (present.isEmpty) {
          fail('the first chapter "${chapter.id}" has no files ($folder)');
        }
        skipped.add(chapter.id);
        continue;
      }
      if (skipped.isNotEmpty) {
        fail(
          'chapter "${chapter.id}" is present but the earlier chapter '
          '"${skipped.first}" is missing',
        );
      }
      present.add(
        ChapterManifest(
          id: chapter.id,
          entrySceneId: chapter.entrySceneId,
          files: _filesByType(folder, chapter.id, assets),
        ),
      );
    }

    return CaseManifest(
      id: id,
      chapters: List.unmodifiable(present),
      skippedChapterIds: List.unmodifiable(skipped),
    );
  }

  /// Sorts the [assets] of a chapter [folder] into kinds.
  static Map<ContentType, List<String>> _filesByType(
    String folder,
    String chapterId,
    List<String> assets,
  ) {
    final result = <ContentType, List<String>>{};
    for (final type in ContentType.values) {
      final file = '$folder${type.fileName}';
      final subfolder = '$folder${type.folderName}';
      final hasFile = assets.contains(file);
      // Only `.json` files directly inside the folder; `list` is sorted.
      final inFolder = [
        for (final asset in assets)
          if (asset.startsWith(subfolder) &&
              asset.endsWith('.json') &&
              !asset.substring(subfolder.length).contains('/'))
            asset,
      ];

      if (hasFile && inFolder.isNotEmpty) {
        throw ContentException(
          folder,
          'chapter "$chapterId" has both ${type.fileName} and the folder '
          '${type.folderName}; use one of them',
        );
      }
      if (!hasFile && inFolder.isEmpty) {
        if (type.isOptional) continue;
        throw ContentException(
          '$folder${type.fileName}',
          'chapter "$chapterId" is incomplete: neither ${type.fileName} nor '
              'the folder ${type.folderName} exists',
        );
      }
      result[type] = List.unmodifiable(hasFile ? [file] : inFolder);
    }
    return Map.unmodifiable(result);
  }

  @override
  List<Object?> get props => [id, chapters, skippedChapterIds];
}
