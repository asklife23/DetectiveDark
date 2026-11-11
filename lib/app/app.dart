import 'package:detective_dark/app/flavor_badge.dart';
import 'package:detective_dark/app/router/app_router.dart';
import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The root widget.
///
/// It is stateful so the router is created once and disposed with the app,
/// instead of being rebuilt (and losing navigation state) on every build.
class App extends StatefulWidget {
  const App({required this.config, super.key});

  final AppConfig config;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.dark(),
      // Languages come only from the ARB files. A device language that is
      // not supported falls back to the first supported locale (English).
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      // `builder` wraps every screen, so the badge stays on top of all of
      // them without each screen knowing about it.
      builder: (context, child) => Stack(
        children: [
          ?child,
          if (widget.config.showDebugOverlay)
            FlavorBadge(label: widget.config.debugLabel),
        ],
      ),
    );
  }
}
