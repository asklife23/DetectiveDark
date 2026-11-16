import 'package:detective_dark/core/error/failure.dart';
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

/// Shown when the game could not start. The technical reason is in the
/// log; the player gets a short message and a way to go on.
///
/// What it says depends on the kind of [failure]:
/// - a save from a newer version of the game: "update the game";
/// - a save that cannot be read: it was kept as a backup, and the button
///   starts a new game (the next start finds an empty slot);
/// - anything else: the content could not be loaded, try again.
class GameErrorView extends StatelessWidget {
  const GameErrorView({required this.onRetry, this.failure, super.key});

  /// Starts the game again.
  final VoidCallback onRetry;

  /// Why the game did not start; null when only the texts failed to load.
  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final (title, body, button) = switch (failure) {
      SaveTooNewFailure() => (
        l10n.saveTooNewTitle,
        l10n.saveTooNewBody,
        l10n.retryButton,
      ),
      SaveCorruptFailure() => (
        l10n.saveCorruptTitle,
        l10n.saveCorruptBody,
        l10n.newGameButton,
      ),
      _ => (l10n.gameLoadFailed, null, l10n.retryButton),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                body,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(button)),
          ],
        ),
      ),
    );
  }
}
