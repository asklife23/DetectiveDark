import 'package:flutter/widgets.dart';

/// Builds the developer menu; [onClose] closes it.
///
/// This type is all the game knows about the menu. The menu itself lives in
/// `lib/app/dev/`, and only `lib/main_dev.dart` imports that folder and
/// hands a builder to `bootstrap`. The other entry points pass nothing, so
/// their builds contain no menu code (the compiler drops code nothing
/// refers to) and no environment value can switch the menu on.
typedef DevMenuBuilder =
    Widget Function(BuildContext context, VoidCallback onClose);
