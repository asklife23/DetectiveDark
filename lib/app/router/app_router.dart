import 'package:detective_dark/app/game_screen.dart';
import 'package:go_router/go_router.dart';

/// Paths of the app screens. In-game scene changes are not routes; they live
/// in the `SceneBloc` navigation stack.
abstract final class AppRoutes {
  static const game = '/';
}

/// Creates the app router. Splash, main menu and settings come in Phase 6.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.game,
    routes: [
      GoRoute(
        path: AppRoutes.game,
        builder: (_, _) => const GameScreen(),
      ),
    ],
  );
}
