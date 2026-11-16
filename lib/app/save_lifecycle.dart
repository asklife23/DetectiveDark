import 'dart:async';
import 'dart:ui';

import 'package:detective_dark/features/progress/domain/services/progress_autosave.dart';
import 'package:flutter/widgets.dart';

/// Tells the save when the app leaves and re-enters the foreground.
///
/// - **Not visible any more** (`hidden`, `paused`, `detached`): the save is
///   written at once and the play time stops. On a phone the system may
///   end a paused app at any moment without asking, so this is the last
///   safe point.
/// - **Visible again** (`resumed`): the play time goes on.
/// - **`inactive`** (a system dialog on top, the window lost the focus):
///   the game is still on screen, nothing happens.
/// - **The window is being closed** (desktop): the app waits for the write
///   before it exits.
class SaveLifecycle extends StatefulWidget {
  const SaveLifecycle({required this.autosave, required this.child, super.key});

  final ProgressAutosave autosave;
  final Widget child;

  @override
  State<SaveLifecycle> createState() => _SaveLifecycleState();
}

class _SaveLifecycleState extends State<SaveLifecycle> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: _onStateChange,
      onExitRequested: _onExitRequested,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  void _onStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.autosave.onForeground();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        unawaited(widget.autosave.onBackground());
    }
  }

  Future<AppExitResponse> _onExitRequested() async {
    await widget.autosave.onBackground();
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
