import 'package:detective_dark/core/placeholders/placeholder_art.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_sprite.dart';
import 'package:flutter/widgets.dart';

/// The object layer (ADR 0012): the pictures of the things that lie in a
/// scene and can disappear from it, such as a key or a letter.
///
/// It sits between the background and the overlay text, under the noir
/// filter, so an object looks like part of the same photograph. Each
/// rectangle is converted from normalized coordinates to pixels of this
/// layer, which has exactly the size of the scene image.
class SpriteLayer extends StatelessWidget {
  const SpriteLayer({required this.sprites, super.key});

  /// The sprites of the hotspots that are visible right now, in content
  /// order (later ones are drawn on top of earlier ones).
  final List<HotspotSprite> sprites;

  @override
  Widget build(BuildContext context) {
    if (sprites.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          children: [
            for (final sprite in sprites)
              Positioned(
                left: sprite.rect.x * size.width,
                top: sprite.rect.y * size.height,
                width: sprite.rect.width * size.width,
                height: sprite.rect.height * size.height,
                child: _SpritePicture(sprite: sprite),
              ),
          ],
        );
      },
    );
  }
}

/// The real artwork when the content names one, otherwise the placeholder
/// drawing: the same one-line switch as for scene backgrounds.
class _SpritePicture extends StatelessWidget {
  const _SpritePicture({required this.sprite});

  final HotspotSprite sprite;

  @override
  Widget build(BuildContext context) {
    final placeholder = PlaceholderArt(style: sprite.placeholderStyle);
    final image = sprite.image;
    if (image == null) return placeholder;

    return Image.asset(
      image,
      // The rect in the content decides the shape; the artist exports the
      // object cropped to exactly that box.
      fit: BoxFit.fill,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
