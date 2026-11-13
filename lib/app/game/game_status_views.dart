import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Shown while the game content and the story texts load.
class GameLoadingView extends StatelessWidget {
  const GameLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Shown when the game content could not be loaded. The technical reason
/// is in the log; the player gets a short message and a way to try again.
class GameErrorView extends StatelessWidget {
  const GameErrorView({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.gameLoadFailed,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.retryButton)),
          ],
        ),
      ),
    );
  }
}
