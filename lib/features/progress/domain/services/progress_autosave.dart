/// What the app tells the save when it leaves and re-enters the foreground.
///
/// The game rules never call this. The `app/` layer does, from the app
/// lifecycle: the play time counts only while the player can see the game,
/// and a save that is still waiting to be written must reach the disk
/// before the system may stop the app.
abstract interface class ProgressAutosave {
  /// The app is no longer visible (or is about to close): stops the play
  /// time and writes the progress now. Completes when it is on disk.
  Future<void> onBackground();

  /// The app is visible again: the play time goes on.
  void onForeground();
}

/// For a progress that is not stored anywhere (tests).
class NoAutosave implements ProgressAutosave {
  const NoAutosave();

  @override
  Future<void> onBackground() async {}

  @override
  void onForeground() {}
}
