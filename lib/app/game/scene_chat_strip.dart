import 'package:detective_dark/core/theme/scene_layout.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_bar.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_viewport.dart';
import 'package:flutter/widgets.dart';

/// Puts the detective message bar on the bottom strip of the scene image.
///
/// It repeats the geometry of [SceneViewport] (centered, 16:9) and gives
/// the bar exactly the strip named by [SceneLayout.chatStripHeight]. The
/// content validation test keeps every hotspot out of that strip, so the
/// bar can lie on top of the scene without ever covering a hotspot.
///
/// It lives in `app/` because it joins two features: the scene engine's
/// viewport and the chat bar.
class SceneChatStrip extends StatelessWidget {
  const SceneChatStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AspectRatio(
        aspectRatio: SceneViewport.aspectRatio,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: SceneLayout.chatStripHeight,
            child: ChatBar(),
          ),
        ),
      ),
    );
  }
}
