import 'package:detective_dark/app/game/game_screen.dart';
import 'package:go_router/go_router.dart';

/// Paths of the app screens. In-game scene changes are not routes; they live
/// in the `SceneBloc` navigation stack.
abstract final class AppRoutes {
  static const game = '/';
}

/// Creates the app router. Splash, main menu and settings come in Phase 6.
///
/// [showDebugTools] turns on the developer tools of the game screen.
GoRouter createAppRouter({bool showDebugTools = false}) {
  return GoRouter(
    initialLocation: AppRoutes.game,
    routes: [
      GoRoute(
        path: AppRoutes.game,
        builder: (_, _) => GameScreen(showDebugTools: showDebugTools),
      ),
    ],
  );
}
