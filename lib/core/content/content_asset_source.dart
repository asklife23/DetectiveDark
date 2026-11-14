import 'dart:convert';

import 'package:flutter/services.dart';

/// A problem in a content file. Thrown inside the data layer only;
/// repositories turn it into a `ContentFailure` before it can reach the
/// domain.
class ContentException implements Exception {
  const ContentException(this.file, this.message, {this.cause});

  /// Asset path of the file.
  final String file;

  final String message;
  final Object? cause;

  @override
  String toString() => '$file: $message';
}

/// Reads content JSON files from an [AssetBundle].
///
/// The bundle is passed in, so tests can feed JSON from memory instead of
/// the real assets.
class ContentAssetSource {
  const ContentAssetSource(this._bundle);

  /// The format this version of the game understands. Every content file
  /// states its own `formatVersion`.
  static const supportedFormatVersion = 1;

  static const formatVersionKey = 'formatVersion';

  final AssetBundle _bundle;

  /// The asset paths that start with [prefix], sorted by name.
  ///
  /// The list comes from the asset manifest Flutter writes at build time,
  /// so it knows only **bundled** files: a folder that is missing from
  /// `pubspec.yaml` is simply empty here (the content validation test
  /// guards against that).
  Future<List<String>> list(String prefix) async {
    final AssetManifest manifest;
    try {
      manifest = await AssetManifest.loadFromAssetBundle(_bundle);
    } on Object catch (error) {
      throw ContentException(
        prefix,
        'the asset manifest could not be read',
        cause: error,
      );
    }
    return manifest
        .listAssets()
        .where((asset) => asset.startsWith(prefix))
        .toList()
      ..sort();
  }

  /// Reads [path] as a JSON object and checks its format version.
  ///
  /// Throws a [ContentException] when the file is missing, is not a JSON
  /// object or has a format version this build does not support.
  Future<Map<String, dynamic>> readObject(String path) async {
    final String raw;
    try {
      raw = await _bundle.loadString(path, cache: false);
    } on Object catch (error) {
      throw ContentException(path, 'file is missing', cause: error);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw ContentException(
        path,
        'invalid JSON: ${error.message}',
        cause: error,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ContentException(path, 'the top level must be a JSON object');
    }
    final version = decoded[formatVersionKey];
    if (version != supportedFormatVersion) {
      throw ContentException(
        path,
        'unsupported $formatVersionKey "$version" '
        '(expected $supportedFormatVersion)',
      );
    }
    return decoded;
  }
}
