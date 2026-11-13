import 'package:flutter/widgets.dart';

/// Remembers where things are on screen, by name, so an animation can fly
/// from one feature to another (a hotspot in the scene → a slot in the item
/// panel) without those features knowing each other.
///
/// A widget wraps itself in a [FlyAnchor]; the `app/` layer asks the
/// registry for the rectangle when it starts a flight.
class FlyAnchors {
  final _keys = <String, GlobalKey>{};

  /// Names used across features.
  static String hotspot(String hotspotId) => 'hotspot:$hotspotId';
  static String item(String itemId) => 'item:$itemId';
  static const itemPanel = 'item-panel';
  static const notebookButton = 'notebook-button';

  GlobalKey _keyFor(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  /// Where the widget registered as [id] is right now, in global
  /// coordinates; null when it is not on screen.
  Rect? rectOf(String id) {
    final box = _keys[id]?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

/// Provides one [FlyAnchors] registry to the widgets below it.
class FlyAnchorScope extends InheritedWidget {
  const FlyAnchorScope({
    required this.anchors,
    required super.child,
    super.key,
  });

  final FlyAnchors anchors;

  static FlyAnchors? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FlyAnchorScope>()?.anchors;

  @override
  bool updateShouldNotify(FlyAnchorScope oldWidget) =>
      oldWidget.anchors != anchors;
}

/// Marks [child] as the place called [id]. Without a [FlyAnchorScope] above
/// it, it does nothing.
class FlyAnchor extends StatelessWidget {
  const FlyAnchor({required this.id, required this.child, super.key});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anchors = FlyAnchorScope.maybeOf(context);
    if (anchors == null) return child;
    return KeyedSubtree(key: anchors._keyFor(id), child: child);
  }
}
