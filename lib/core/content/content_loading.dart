import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:json_annotation/json_annotation.dart';

/// Runs [body] and turns every content problem into a [ContentFailure], so
/// no exception leaves the data layer.
///
/// [body] may throw a [ContentException] (missing or malformed file), a
/// [CheckedFromJsonException] (wrong or unknown field in a generated DTO) or
/// a [FormatException] (hand-written parsing of conditions and effects).
Future<Result<T>> guardContent<T>(Future<T> Function() body) async {
  try {
    return Success(await body());
  } on ContentException catch (error, stackTrace) {
    return Failed(
      ContentFailure('$error', cause: error, stackTrace: stackTrace),
    );
  } on CheckedFromJsonException catch (error, stackTrace) {
    return Failed(
      ContentFailure(
        describeJsonError(error),
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  } on FormatException catch (error, stackTrace) {
    return Failed(
      ContentFailure(error.message, cause: error, stackTrace: stackTrace),
    );
  }
}

/// Parses [json] with [parse]; a failure is rethrown as a [ContentException]
/// that names [file].
T parseContentFile<T>(
  String file,
  Map<String, dynamic> json,
  T Function(Map<String, dynamic> json) parse,
) {
  try {
    return parse(json);
  } on CheckedFromJsonException catch (error) {
    throw ContentException(file, describeJsonError(error), cause: error);
  } on FormatException catch (error) {
    throw ContentException(file, error.message, cause: error);
  }
}

/// A readable one-line description of a generated-DTO parsing error.
String describeJsonError(CheckedFromJsonException error) {
  final where = [
    if (error.className != null) error.className,
    if (error.key != null) '"${error.key}"',
  ].join(' ');
  final what = error.message ?? '${error.innerError ?? 'invalid value'}';
  return where.isEmpty ? what : '$where: $what';
}

/// Adds [entries] to [target]; an ID that is already there is a content
/// error, because IDs are unique inside a case.
void mergeUnique<T>(
  Map<String, T> target,
  Iterable<MapEntry<String, T>> entries, {
  required String file,
  required String kind,
}) {
  for (final MapEntry(:key, :value) in entries) {
    if (target.containsKey(key)) {
      throw ContentException(file, 'duplicate $kind ID "$key"');
    }
    target[key] = value;
  }
}
