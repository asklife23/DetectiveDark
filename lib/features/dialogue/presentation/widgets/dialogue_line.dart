import 'dart:async';

import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/theme/dialogue_layout.dart';
import 'package:flutter/material.dart';

/// One line of a character, typed out letter by letter.
///
/// The widget only draws. Whether the line is complete is decided by the
/// cubit: the typewriter reports its end with [onTyped], and a tap on the
/// panel can complete the line earlier ([isComplete] turns true).
class DialogueLine extends StatefulWidget {
  const DialogueLine({
    required this.textKey,
    required this.isComplete,
    required this.isLast,
    required this.onTyped,
    super.key,
  });

  final String textKey;

  /// The whole line is shown, whatever the typewriter has reached.
  final bool isComplete;

  /// After this line the question list returns.
  final bool isLast;

  /// The typewriter reached the end of the line.
  final VoidCallback onTyped;

  @override
  State<DialogueLine> createState() => _DialogueLineState();
}

class _DialogueLineState extends State<DialogueLine>
    with SingleTickerProviderStateMixin {
  /// Runs from 0 (nothing typed) to 1 (the whole line is visible).
  late final AnimationController _typing;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _typing = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onTyped();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final text = context.storyTexts.text(widget.textKey);
    if (text == _text) return;
    _text = text;
    _typing.duration = AppDurations.dialogueTypePerCharacter * text.length;
    if (widget.isComplete) {
      _typing.value = 1;
    } else {
      unawaited(_typing.forward(from: 0));
    }
  }

  @override
  void didUpdateWidget(DialogueLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An impatient tap: show the rest at once.
    if (widget.isComplete && _typing.value < 1) _typing.value = 1;
  }

  @override
  void dispose() {
    _typing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize =
            (MediaQuery.sizeOf(context).height *
                    DialogueLayout.lineFontSizeFactor)
                .clamp(
                  DialogueLayout.minLineFontSize,
                  DialogueLayout.maxLineFontSize,
                );
        final style = Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: AppColors.textPrimary,
          fontSize: fontSize,
        );

        return Semantics(
          // Its own node: without this the line would merge into the
          // tappable panel around it and be read together with the name
          // and the buttons.
          container: true,
          liveRegion: true,
          button: true,
          label: _text,
          hint: widget.isLast ? null : l10n.dialogueContinueHint,
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: AnimatedBuilder(
                      animation: _typing,
                      builder: (context, _) {
                        final typed = (_text.length * _typing.value).ceil();
                        // The untyped rest is laid out invisibly, so words
                        // do not jump between lines while the text appears.
                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: _text.substring(0, typed)),
                              TextSpan(
                                text: _text.substring(typed),
                                style: const TextStyle(
                                  color: Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                          style: style,
                        );
                      },
                    ),
                  ),
                  // "There is more" once the line stands complete.
                  if (widget.isComplete)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        widget.isLast
                            ? Icons.keyboard_return
                            : Icons.arrow_drop_down,
                        color: AppColors.accent,
                        size: AppSizes.hudIcon,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
