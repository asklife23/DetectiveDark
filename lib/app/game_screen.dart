import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The in-game screen. From Phase 1 on it composes the features: scene view,
/// inventory panel, notebook button and detective message bar.
///
/// For now it shows the title and one atmospheric line, which also previews
/// the two fonts (typewriter title, readable body).
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.appTitle, style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.gameScreenPlaceholder,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
