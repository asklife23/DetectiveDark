/// Spacing scale in logical pixels. Paddings and gaps use these steps.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Fixed sizes of interface elements, in logical pixels.
abstract final class AppSizes {
  /// Touch target of a round HUD button (back, notebook, close).
  static const double hudButton = 44;

  /// Icon inside a HUD button.
  static const double hudIcon = 22;

  /// Width of the item panel on the right edge.
  static const double sidebarWidth = 72;

  /// Diameter of the unread-notes badge on the notebook button.
  static const double badge = 18;

  /// Border of the selected inventory slot.
  static const double selectedBorder = 2.5;

  /// Line width of thin strokes (borders, the tap ripple).
  static const double hairline = 1.5;
}

/// Corner radii.
abstract final class AppRadii {
  static const double sm = 4;
  static const double md = 8;
}
