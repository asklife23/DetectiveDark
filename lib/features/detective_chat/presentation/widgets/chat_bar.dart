import 'dart:async';

import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/widgets/hud_badge.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/detective_chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The inner voice of the detective on the bottom edge of the scene.
///
/// A new message opens the bar and is typed out letter by letter; a tap
/// finishes the typing at once. After the message has stayed long enough to
/// be read, the bar shrinks to a small button, so it never hides the scene
/// for long. A tap on the finished bar or on the button opens the history.
///
/// The widget fills the box its parent gives it and never paints outside
/// it: the parent decides which strip of the scene the bar may use.
class ChatBar extends StatefulWidget {
  const ChatBar({super.key});

  @override
  State<ChatBar> createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> with SingleTickerProviderStateMixin {
  /// Runs from 0 (nothing typed) to 1 (the whole message is visible).
  late final AnimationController _typing;

  Timer? _lingerTimer;

  /// The `announcement` of the message that was last played.
  int _played = 0;

  String _text = '';
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _typing = AnimationController(vsync: this)
      ..addStatusListener(_onTypingStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A message said before this widget existed (the first line of the
    // game) is played as soon as the bar is on screen.
    final state = context.read<ChatCubit>().state;
    if (state.announcement != _played) _play(state);
  }

  @override
  void dispose() {
    _lingerTimer?.cancel();
    _typing.dispose();
    super.dispose();
  }

  void _play(ChatState state) {
    final entry = state.latest;
    if (entry == null) return;

    _played = state.announcement;
    _lingerTimer?.cancel();
    final text = context.storyTexts.text(entry.textKey, params: entry.params);
    setState(() {
      _text = text;
      _isOpen = true;
    });
    _typing.duration = AppDurations.chatTypePerCharacter * text.length;
    unawaited(_typing.forward(from: 0));
  }

  void _onTypingStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    // Longer messages stay longer.
    final byLength = AppDurations.chatLingerPerCharacter * _text.length;
    _lingerTimer?.cancel();
    _lingerTimer = Timer(
      byLength > AppDurations.chatLingerMin
          ? byLength
          : AppDurations.chatLingerMin,
      _shrink,
    );
  }

  void _shrink() {
    _lingerTimer?.cancel();
    if (!mounted || !_isOpen) return;
    setState(() => _isOpen = false);
    context.read<ChatCubit>().markLatestSeen();
  }

  void _onBarTap() {
    if (_typing.isAnimating) {
      // Impatient reader: show the rest at once.
      _typing.value = 1;
      return;
    }
    _shrink();
    context.read<ChatCubit>().openHistory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.announcement != current.announcement,
      listener: (context, state) => _play(state),
      child: AnimatedSwitcher(
        duration: AppDurations.chatBarToggle,
        child: _isOpen
            ? _OpenBar(
                key: const ValueKey('open'),
                text: _text,
                typing: _typing,
                onTap: _onBarTap,
              )
            : const _ShrunkButton(key: ValueKey('shrunk')),
      ),
    );
  }
}

/// The bar with the message being typed.
class _OpenBar extends StatelessWidget {
  const _OpenBar({
    required this.text,
    required this.typing,
    required this.onTap,
    super.key,
  });

  /// Font size as a share of the bar height, within readable limits: the
  /// text grows with the scene on a large window.
  static const _fontSizeFactor = 0.27;
  static const _minFontSize = 12.0;
  static const _maxFontSize = 18.0;
  static const _maxLines = 2;

  final String text;
  final Animation<double> typing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = (constraints.maxHeight * _fontSizeFactor).clamp(
          _minFontSize,
          _maxFontSize,
        );
        final style = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: AppColors.textPrimary,
          fontSize: fontSize,
        );

        return Semantics(
          button: true,
          liveRegion: true,
          label: text,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.xxs),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.hudSurface,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
                border: Border.all(color: AppColors.outline),
              ),
              child: ExcludeSemantics(
                child: AnimatedBuilder(
                  animation: typing,
                  builder: (context, _) {
                    final typed = (text.length * typing.value).ceil();
                    // The untyped rest is laid out invisibly, so words do
                    // not jump between lines while the text appears.
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: text.substring(0, typed)),
                          TextSpan(
                            text: text.substring(typed),
                            style: const TextStyle(color: Colors.transparent),
                          ),
                        ],
                      ),
                      style: style,
                      maxLines: _maxLines,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// What the bar shrinks to: a button that opens the message history.
class _ShrunkButton extends StatelessWidget {
  const _ShrunkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: FittedBox(
          // On a very low scene the button gets smaller instead of leaving
          // its strip.
          fit: BoxFit.scaleDown,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              HudIconButton(
                icon: Icons.chat_bubble_outline,
                tooltip: context.l10n.chatTooltip,
                onPressed: () => context.read<ChatCubit>().openHistory(),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: BlocSelector<ChatCubit, ChatState, int>(
                  selector: (state) => state.unreadCount,
                  builder: (context, unread) => unread == 0
                      ? const SizedBox.shrink()
                      : HudBadge(count: unread),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
