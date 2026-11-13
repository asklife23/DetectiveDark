import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';

/// Reads a [Condition] from its JSON form: an object with exactly one key.
///
/// ```json
/// {"flag": "front_door_open"}
/// {"all": [{"usingItem": "brass_key"}, {"notFlag": "front_door_open"}]}
/// ```
///
/// Written by hand (not generated) because the key names the type. An
/// unknown key is rejected with the list of known ones, so a typo in
/// content fails loudly.
abstract final class ConditionCodec {
  static const knownKeys = [
    'flag',
    'notFlag',
    'hasItem',
    'usingItem',
    'hasNote',
    'all',
    'any',
  ];

  /// Throws a [FormatException] for anything that is not a valid condition.
  static Condition parse(Object? json) {
    if (json is! Map<String, dynamic> || json.length != 1) {
      throw FormatException(
        'A condition must be an object with exactly one key, got: $json',
      );
    }
    final MapEntry(:key, :value) = json.entries.single;

    return switch (key) {
      'flag' => FlagSet(_id(key, value)),
      'notFlag' => FlagNotSet(_id(key, value)),
      'hasItem' => HasItem(_id(key, value)),
      'usingItem' => UsingItem(_id(key, value)),
      'hasNote' => HasNote(_id(key, value)),
      'all' => AllOf(_list(key, value)),
      'any' => AnyOf(_list(key, value)),
      _ => throw FormatException(
        'Unknown condition "$key". Known: ${knownKeys.join(', ')}.',
      ),
    };
  }

  static String _id(String key, Object? value) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Condition "$key" needs a non-empty string.');
  }

  static List<Condition> _list(String key, Object? value) {
    if (value is List && value.isNotEmpty) {
      return List.unmodifiable(value.map(parse));
    }
    throw FormatException('Condition "$key" needs a non-empty list.');
  }
}
