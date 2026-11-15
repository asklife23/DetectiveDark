import 'dart:convert';

import 'package:equatable/equatable.dart';

/// A named game state of the developer menu: the scene to stand in and what
/// the player already has. Loading one replaces the whole progress.
class DevPreset extends Equatable {
  const DevPreset({
    required this.id,
    required this.sceneId,
    this.itemIds = const [],
    this.noteIds = const [],
    this.flags = const [],
  });

  final String id;
  final String sceneId;
  final List<String> itemIds;
  final List<String> noteIds;
  final List<String> flags;

  @override
  List<Object?> get props => [id, sceneId, itemIds, noteIds, flags];
}

/// Reads the text of `assets/dev/presets.json`.
///
/// The file is as strict as the game content: an unknown key or a wrong
/// type throws a [FormatException] that names the place, instead of being
/// ignored.
List<DevPreset> parseDevPresets(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('the top level must be a JSON object');
  }
  _allowKeys(decoded, const {_formatVersionKey, _presetsKey}, 'the file');
  if (decoded[_formatVersionKey] != _supportedFormatVersion) {
    throw FormatException(
      'unsupported $_formatVersionKey "${decoded[_formatVersionKey]}" '
      '(expected $_supportedFormatVersion)',
    );
  }
  final presets = decoded[_presetsKey];
  if (presets is! List) {
    throw const FormatException('"$_presetsKey" must be a list');
  }
  return [
    for (final (index, preset) in presets.indexed) _parsePreset(preset, index),
  ];
}

const _formatVersionKey = 'formatVersion';
const _supportedFormatVersion = 1;
const _presetsKey = 'presets';
const _idKey = 'id';
const _sceneKey = 'scene';
const _itemsKey = 'items';
const _notesKey = 'notes';
const _flagsKey = 'flags';

DevPreset _parsePreset(Object? json, int index) {
  final where = 'preset #$index';
  if (json is! Map<String, dynamic>) {
    throw FormatException('$where must be a JSON object');
  }
  _allowKeys(
    json,
    const {_idKey, _sceneKey, _itemsKey, _notesKey, _flagsKey},
    where,
  );
  return DevPreset(
    id: _string(json, _idKey, where),
    sceneId: _string(json, _sceneKey, where),
    itemIds: _strings(json, _itemsKey, where),
    noteIds: _strings(json, _notesKey, where),
    flags: _strings(json, _flagsKey, where),
  );
}

void _allowKeys(Map<String, dynamic> json, Set<String> allowed, String where) {
  final unknown = json.keys.where((key) => !allowed.contains(key));
  if (unknown.isNotEmpty) {
    throw FormatException('$where has unknown keys: ${unknown.join(', ')}');
  }
}

String _string(Map<String, dynamic> json, String key, String where) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('$where needs a non-empty string "$key"');
  }
  return value;
}

List<String> _strings(Map<String, dynamic> json, String key, String where) {
  final value = json[key];
  if (value == null) return const [];
  if (value is! List || value.any((entry) => entry is! String)) {
    throw FormatException('$where: "$key" must be a list of strings');
  }
  return List.unmodifiable(value.cast<String>());
}
