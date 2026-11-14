import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Esc works like the Back button, wherever the keyboard focus is inside
/// [child]. Plain keyboard input, not tied to a platform.
class BackShortcut extends StatelessWidget {
  const BackShortcut({required this.onBack, required this.child, super.key});

  final VoidCallback onBack;
  final Widget child;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    onBack();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    // Key events travel from the focused widget up to this node, which
    // takes the focus as soon as the game is on screen. It is not a control
    // of its own, so it stays out of the accessibility tree (a semantics
    // node here would swallow the labels of the hotspots below it).
    return Focus(
      autofocus: true,
      includeSemantics: false,
      onKeyEvent: _onKey,
      child: child,
    );
  }
}
