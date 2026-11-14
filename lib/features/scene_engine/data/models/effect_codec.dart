import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_transition.dart';

/// Reads an [Effect] from its JSON form: an object with exactly one key.
///
/// ```json
/// {"giveItem": "brass_key"}
/// {"hideHotspot": true}
/// {"addNoteEntry": {"note": "person_pharmacist", "entry": "knows_villa"}}
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
    'addNoteEntry',
    'setFlag',
    'hideHotspot',
    'say',
    'inspect',
  ];

  static const _noteEntryKeys = {'note', 'entry'};

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
      'addNoteEntry' => _addNoteEntry(value),
      'setFlag' => SetFlag(_id(key, value)),
      'hideHotspot' => _hideHotspot(value),
      'say' => _say(value),
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

  /// `{"note": "person_pharmacist", "entry": "knows_villa"}`.
  static AddNoteEntry _addNoteEntry(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException(
        'Effect "addNoteEntry" needs an object with "note" and "entry".',
      );
    }
    final unknown = value.keys.where((key) => !_noteEntryKeys.contains(key));
    if (unknown.isNotEmpty) {
      throw FormatException(
        'Unknown "addNoteEntry" keys: ${unknown.join(', ')}. '
        'Known: ${_noteEntryKeys.join(', ')}.',
      );
    }
    return AddNoteEntry(
      noteId: _id('addNoteEntry.note', value['note']),
      entryId: _id('addNoteEntry.entry', value['entry']),
    );
  }

  /// `"key"` or `{"first": "key_long", "then": "key_short"}`.
  static Say _say(Object? value) {
    if (value is String) return Say(_id('say', value));
    final (first, then) = LineCodec.firstThen('say', value);
    return Say(first, repeatKey: then);
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

/// Reads the two-form line `{"first": ..., "then": ...}` shared by the `say`
/// effect and (later) dialogue greetings.
abstract final class LineCodec {
  static const _keys = {'first', 'then'};

  /// Throws a [FormatException] unless [value] is an object with exactly
  /// the non-empty strings `first` and `then`.
  static (String first, String then) firstThen(String owner, Object? value) {
    if (value is! Map<String, dynamic>) {
      throw FormatException(
        '"$owner" needs a text key or an object with "first" and "then".',
      );
    }
    final unknown = value.keys.where((key) => !_keys.contains(key));
    if (unknown.isNotEmpty) {
      throw FormatException(
        'Unknown "$owner" keys: ${unknown.join(', ')}. '
        'Known: ${_keys.join(', ')}.',
      );
    }
    final first = value['first'];
    final then = value['then'];
    if (first is! String || first.isEmpty || then is! String || then.isEmpty) {
      throw FormatException(
        '"$owner" needs both "first" and "then" as non-empty strings.',
      );
    }
    return (first, then);
  }
}
