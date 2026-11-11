import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Locks phones and tablets to landscape and hides the system bars.
///
/// `immersiveSticky`: the status and navigation bars stay hidden; a swipe
/// from the edge shows them briefly, then they hide again on their own.
///
/// Desktop (the Steam build) skips this: Windows does not implement these
/// platform calls and would throw a `MissingPluginException`. Window mode
/// and full screen on desktop are handled in Phase 11.
Future<void> configureSystemUi() async {
  final isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (!isMobile) return;

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}
