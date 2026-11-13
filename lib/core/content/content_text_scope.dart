import 'package:detective_dark/core/content/content_texts.dart';
import 'package:flutter/widgets.dart';

/// Makes the loaded story texts available to every widget below it.
///
/// Widgets read them with `context.storyTexts.text('say_door_locked')`.
/// Interface texts (buttons, tooltips) come from `context.l10n` instead.
class ContentTextScope extends InheritedWidget {
  const ContentTextScope({
    required this.texts,
    required super.child,
    super.key,
  });

  final ContentTexts texts;

  /// The texts of the nearest scope; without one, every key is shown as
  /// itself.
  static ContentTexts of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ContentTextScope>()?.texts ??
      ContentTexts.empty;

  @override
  bool updateShouldNotify(ContentTextScope oldWidget) =>
      !identical(oldWidget.texts, texts);
}

extension ContentTextScopeX on BuildContext {
  /// The story texts of the running case.
  ContentTexts get storyTexts => ContentTextScope.of(this);
}
