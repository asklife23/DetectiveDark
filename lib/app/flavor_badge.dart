import 'package:detective_dark/core/config/flavor.dart';
import 'package:flutter/material.dart';

/// A small label at the top center showing the flavor (e.g. "DEV"), so a
/// dev build is never mistaken for the real game.
///
/// It ignores pointer events: taps go straight through to the scene below.
/// Top center is the one HUD area that stays free (back button top left,
/// inventory panel on the right, message bar at the bottom).
class FlavorBadge extends StatelessWidget {
  const FlavorBadge({required this.flavor, super.key});

  final Flavor flavor;

  // Debug-only styling; it moves to theme tokens if it ever needs to match
  // the game's look.
  static const _margin = EdgeInsets.only(top: 4);
  static const _padding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
  static const _radius = BorderRadius.all(Radius.circular(4));
  static const _background = Color(0x99B00020);
  static const _textStyle = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    decoration: TextDecoration.none,
  );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: _margin,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _background,
                borderRadius: _radius,
              ),
              child: Padding(
                padding: _padding,
                child: Text(flavor.name.toUpperCase(), style: _textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
