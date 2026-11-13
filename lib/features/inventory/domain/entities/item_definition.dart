import 'package:equatable/equatable.dart';

/// An item the player can carry and use (a key, a crowbar, a torch).
class ItemDefinition extends Equatable {
  const ItemDefinition({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconStyle,
    this.iconAsset,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;

  /// Name of the placeholder drawing, used while [iconAsset] is null.
  final String iconStyle;

  /// Real artwork, once it exists.
  final String? iconAsset;

  @override
  List<Object?> get props => [
    id,
    nameKey,
    descriptionKey,
    iconStyle,
    iconAsset,
  ];
}
