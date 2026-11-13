import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';

/// Reads an [Effect] from its JSON form: an object with exactly one key.
///
/// ```json
/// {"giveItem": "brass_key"}
/// {"hideHotspot": true}
/// {"goToScene": "villa_hall"}
/// {"goToScene": {"sceneId": "villa_hall", "holdMs": 600, "sfx": "door"}}
/// ```
///
/// An unknown key is rejected with the list of known ones.
abstract final class EffectCodec {
  static const knownKeys = [
    'goToScene',
    'giveItem',
    'consumeItem',
    'addNote',
    'setFlag',
    'hideHotspot',
    'say',
    'inspect',
  ];

  static const _transitionKeys = {
    'sceneId',
    'type',
    'fadeOutMs',
    'holdMs',
    'fadeInMs',
    'sfx',
  };

  /// Throws a [FormatException] for anything that is not a valid effect.
  static Effect parse(Object? json) {
    if (json is! Map<String, dynamic> || json.length != 1) {
      throw FormatException(
        'An effect must be an object with exactly one key, got: $json',
      );
    }
    final MapEntry(:key, :value) = json.entries.single;

    return switch (key) {
      'goToScene' => _goToScene(value),
      'giveItem' => GiveItem(_id(key, value)),
      'consumeItem' => ConsumeItem(_id(key, value)),
      'addNote' => AddNote(_id(key, value)),
      'setFlag' => SetFlag(_id(key, value)),
      'hideHotspot' => _hideHotspot(value),
      'say' => Say(_id(key, value)),
      'inspect' => Inspect(_id(key, value)),
      _ => throw FormatException(
        'Unknown effect "$key". Known: ${knownKeys.join(', ')}.',
      ),
    };
  }

  static List<Effect> parseList(List<dynamic> json) =>
      List.unmodifiable(json.map(parse));

  static String _id(String key, Object? value) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Effect "$key" needs a non-empty string.');
  }

  static HideHotspot _hideHotspot(Object? value) {
    if (value == true) return const HideHotspot();
    throw const FormatException('Effect "hideHotspot" must be true.');
  }

  static GoToScene _goToScene(Object? value) {
    if (value is String) return GoToScene(_id('goToScene', value));
    if (value is! Map<String, dynamic>) {
      throw const FormatException(
        'Effect "goToScene" needs a scene ID or an object with "sceneId".',
      );
    }

    final unknown = value.keys.where((key) => !_transitionKeys.contains(key));
    if (unknown.isNotEmpty) {
      throw FormatException(
        'Unknown "goToScene" keys: ${unknown.join(', ')}. '
        'Known: ${_transitionKeys.join(', ')}.',
      );
    }

    const standard = SceneTransition.standard;
    return GoToScene(
      _id('goToScene.sceneId', value['sceneId']),
      transition: SceneTransition(
        type: _type(value['type']),
        fadeOut: _duration(value, 'fadeOutMs') ?? standard.fadeOut,
        hold: _duration(value, 'holdMs') ?? standard.hold,
        fadeIn: _duration(value, 'fadeInMs') ?? standard.fadeIn,
        sfx: value['sfx'] == null ? null : _id('goToScene.sfx', value['sfx']),
      ),
    );
  }

  static SceneTransitionType _type(Object? value) {
    if (value == null) return SceneTransitionType.fade;
    for (final type in SceneTransitionType.values) {
      if (type.name == value) return type;
    }
    final names = SceneTransitionType.values.map((type) => type.name);
    throw FormatException(
      'Unknown transition type "$value". Known: ${names.join(', ')}.',
    );
  }

  static Duration? _duration(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int && value >= 0) return Duration(milliseconds: value);
    throw FormatException('"goToScene.$key" must be a whole number >= 0.');
  }
}
