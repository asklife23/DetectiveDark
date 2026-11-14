import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/logging/app_logger.dart';

/// The story texts of a case in one language, looked up by key.
///
/// Story texts (scene titles, the lines of the detective, notes) live in
/// content files, not in the ARB files: ARB is for the fixed interface.
/// The texts cover the whole case, because notes and messages from earlier
/// chapters stay readable later.
class ContentTexts {
  const ContentTexts(
    this._texts, {
    this.languageCode = 'en',
    this._logger = const AppLogger('content'),
  });

  /// No texts at all: every lookup returns its key.
  static const empty = ContentTexts({});

  final Map<String, String> _texts;
  final String languageCode;
  final AppLogger _logger;

  Iterable<String> get keys => _texts.keys;

  bool has(String key) => _texts.containsKey(key);

  /// The text for [key], with `{name}` placeholders replaced from [params].
  ///
  /// A missing key does not crash the game: the key itself is shown and a
  /// warning is logged. The content validation test catches it earlier.
  String text(String key, {Map<String, String> params = const {}}) {
    var value = _texts[key];
    if (value == null) {
      _logger.warning('Missing content text "$key" ($languageCode).');
      return key;
    }
    params.forEach((name, replacement) {
      value = value!.replaceAll('{$name}', replacement);
    });
    return value!;
  }
}

/// Loads [ContentTexts] from the content files.
class ContentTextLoader {
  const ContentTextLoader(this._source);

  static const _textsKey = 'texts';

  final ContentAssetSource _source;

  /// Loads the shared texts plus the texts of every chapter of [caseId]
  /// that is present in this build. Keys must be unique across all of these
  /// files. [chapterLimit] keeps only the first N chapters.
  Future<Result<ContentTexts>> load(
    String caseId,
    String languageCode, {
    int? chapterLimit,
  }) async {
    try {
      final manifest = await CaseManifest.read(
        _source,
        caseId,
        chapterLimit: chapterLimit,
      );
      final paths = [
        ContentPaths.commonTexts(languageCode),
        for (final chapter in manifest.chapters)
          ContentPaths.chapterTexts(caseId, chapter.id, languageCode),
      ];

      final texts = <String, String>{};
      for (final path in paths) {
        final json = await _source.readObject(path);
        final entries = json[_textsKey];
        if (entries is! Map<String, dynamic> || json.length != 2) {
          throw ContentException(
            path,
            'expected exactly "${ContentAssetSource.formatVersionKey}" and '
            'a "$_textsKey" object',
          );
        }
        entries.forEach((key, value) {
          if (value is! String) {
            throw ContentException(path, 'text "$key" must be a string');
          }
          if (texts.containsKey(key)) {
            throw ContentException(path, 'duplicate text key "$key"');
          }
          texts[key] = value;
        });
      }

      return Success(
        ContentTexts(Map.unmodifiable(texts), languageCode: languageCode),
      );
    } on ContentException catch (error, stackTrace) {
      return Failed(
        ContentFailure('$error', cause: error, stackTrace: stackTrace),
      );
    }
  }
}
