import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:equatable/equatable.dart';

/// Everything the developer menu can offer, as plain IDs taken from the
/// loaded content. Nothing is written down in code: a new scene, item, note
/// or flag shows up here by itself.
class DevCatalog extends Equatable {
  const DevCatalog({
    required this.sceneIds,
    required this.itemIds,
    required this.noteIds,
    required this.flags,
  });

  /// [itemIds] and [noteIds] are the keys of the item and note catalogs.
  /// The flags are the ones the content can set somewhere: in a hotspot
  /// rule, on entering a scene, in a trigger or in a dialogue topic.
  factory DevCatalog.fromContent({
    required CaseContent content,
    required Iterable<String> itemIds,
    required Iterable<String> noteIds,
    required Iterable<DialogueDefinition> dialogues,
  }) {
    final effects = <Effect>[
      for (final scene in content.scenes.values) ...[
        ...scene.onFirstEnter,
        for (final hotspot in scene.hotspots)
          for (final rule in hotspot.interactions) ...rule.effects,
      ],
      for (final trigger in content.triggers) ...trigger.effects,
      for (final dialogue in dialogues)
        for (final topic in dialogue.topics) ...topic.effects,
    ];
    return DevCatalog(
      sceneIds: content.scenes.keys.toList()..sort(),
      itemIds: itemIds.toList()..sort(),
      noteIds: noteIds.toList()..sort(),
      flags: {
        for (final effect in effects.whereType<SetFlag>()) effect.flag,
      }.toList()..sort(),
    );
  }

  final List<String> sceneIds;
  final List<String> itemIds;
  final List<String> noteIds;
  final List<String> flags;

  /// What [preset] refers to that the content does not have. Empty when
  /// the preset is sound. The content validation test runs this on the
  /// real preset file.
  List<String> problemsOf(DevPreset preset) {
    String missing(String kind, String id) =>
        'preset "${preset.id}": unknown $kind "$id"';

    return [
      if (!sceneIds.contains(preset.sceneId)) missing('scene', preset.sceneId),
      for (final id in preset.itemIds)
        if (!itemIds.contains(id)) missing('item', id),
      for (final id in preset.noteIds)
        if (!noteIds.contains(id)) missing('note', id),
      for (final flag in preset.flags)
        if (!flags.contains(flag)) missing('flag', flag),
    ];
  }

  @override
  List<Object?> get props => [sceneIds, itemIds, noteIds, flags];
}
