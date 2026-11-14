import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/fly_anchors.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The item panel on the right edge: one slot per carried item.
///
/// Tap selects an item (tap again to put it back); the next tap on the
/// scene uses it. Long press calls [onExamine] to open the examine card.
///
/// When [onItemTap] is given, a tap calls it instead of selecting. The
/// panel does not know why: the screen that owns it decides what a tap
/// means right now (while a conversation is open it shows the item).
class ItemSidebar extends StatelessWidget {
  const ItemSidebar({
    required this.onExamine,
    this.onItemTap,
    this.arrivingItemIds = const {},
    super.key,
  });

  final ValueChanged<ItemDefinition> onExamine;

  /// Replaces "tap selects" while it is not null.
  final ValueChanged<ItemDefinition>? onItemTap;

  /// Items that are still flying towards the panel: their slot stays empty
  /// until they land.
  final Set<String> arrivingItemIds;

  @override
  Widget build(BuildContext context) {
    return FlyAnchor(
      id: FlyAnchors.itemPanel,
      child: Semantics(
        container: true,
        label: context.l10n.inventoryLabel,
        child: Container(
          width: AppSizes.sidebarWidth,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(left: BorderSide(color: AppColors.outline)),
          ),
          child: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) => AnimatedSwitcher(
              // Identical slots overlap exactly, so only the slot of a
              // used-up item is seen fading out.
              duration: AppDurations.itemFadeOut,
              child: state.items.isEmpty
                  ? const _EmptyHint()
                  : ListView(
                      key: ValueKey(state.items.map((i) => i.id).join(',')),
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      children: [
                        for (final item in state.items)
                          _ItemSlot(
                            item: item,
                            isSelected: item.id == state.selectedItemId,
                            isArriving: arrivingItemIds.contains(item.id),
                            onTap: () => onItemTap == null
                                ? context.read<InventoryCubit>().toggle(item.id)
                                : onItemTap!(item),
                            onLongPress: () => onExamine(item),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Text(
          context.l10n.inventoryEmpty,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ItemSlot extends StatelessWidget {
  const _ItemSlot({
    required this.item,
    required this.isSelected,
    required this.isArriving,
    required this.onTap,
    required this.onLongPress,
  });

  final ItemDefinition item;
  final bool isSelected;
  final bool isArriving;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: context.storyTexts.text(item.nameKey),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          child: AspectRatio(
            aspectRatio: 1,
            child: AnimatedContainer(
              duration: AppDurations.itemSelect,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surfaceRaised
                    : AppColors.background,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.outline,
                  width: isSelected
                      ? AppSizes.selectedBorder
                      : AppSizes.hairline,
                ),
              ),
              child: FlyAnchor(
                id: FlyAnchors.item(item.id),
                child: AnimatedOpacity(
                  // The icon appears when the flying copy has landed.
                  opacity: isArriving ? 0 : 1,
                  duration: AppDurations.itemLand,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: ItemIcon(item: item),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The picture of an item: real artwork when it exists, otherwise the
/// placeholder drawing.
class ItemIcon extends StatelessWidget {
  const ItemIcon({required this.item, super.key});

  final ItemDefinition item;

  @override
  Widget build(BuildContext context) {
    final placeholder = PlaceholderArt(style: item.iconStyle);
    final asset = item.iconAsset;
    if (asset == null) return placeholder;
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
