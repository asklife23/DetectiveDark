import 'package:detective_dark/core/theme/noir_filter_presets.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/inspection_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';

/// Turns an inventory item into the content of the inspection panel, so
/// the examine card (long press on an item) is the very same panel as a
/// look-only detail in a scene: one window, one Back behaviour.
///
/// It lives in `app/` because it connects two features: `inventory` never
/// sees the scene engine's widgets.
InspectionDefinition inspectionForItem(ItemDefinition item) {
  return InspectionDefinition(
    id: 'item:${item.id}',
    titleKey: item.nameKey,
    textKey: item.descriptionKey,
    visual: SceneVisual(
      background: item.iconAsset,
      placeholderStyle: item.iconStyle,
      filterPreset: NoirFilterPresets.closeUp,
    ),
  );
}
