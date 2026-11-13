import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:equatable/equatable.dart';

/// One chapter listed in `case.json`.
class ChapterManifest extends Equatable {
  const ChapterManifest({required this.id, required this.entrySceneId});

  final String id;
  final String entrySceneId;

  @override
  List<Object?> get props => [id, entrySceneId];
}

/// The table of contents of a case (`case.json`): which chapters exist, in
/// play order. Every content loader starts here to find its files.
class CaseManifest extends Equatable {
  const CaseManifest({required this.id, required this.chapters});

  final String id;
  final List<ChapterManifest> chapters;

  /// Reads `case.json` of [caseId]. Throws a [ContentException] when the
  /// file is missing or malformed.
  static Future<CaseManifest> read(
    ContentAssetSource source,
    String caseId,
  ) async {
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

    final chapters = <ChapterManifest>[];
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
      if (chapters.any((chapter) => chapter.id == chapterId)) {
        fail('duplicate chapter "$chapterId"');
      }
      chapters.add(ChapterManifest(id: chapterId, entrySceneId: entrySceneId));
    }

    return CaseManifest(id: id, chapters: List.unmodifiable(chapters));
  }

  @override
  List<Object?> get props => [id, chapters];
}
