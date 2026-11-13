part of 'scene_bloc.dart';

enum SceneStatus { loading, ready, failed }

/// Where a scene transition stands. The bloc only keeps the phase; the
/// animation and its timing live in the UI (ADR 0007).
enum TransitionPhase {
  /// No transition; taps are accepted.
  idle,

  /// The screen is fading to black.
  covering,

  /// The new scene is fading in.
  revealing,
}

/// What the scene view shows.
class SceneState extends Equatable {
  const SceneState({
    this.status = SceneStatus.loading,
    this.failure,
    this.content,
    this.progress,
    this.scene,
    this.visual,
    this.visibleHotspots = const [],
    this.transitionPhase = TransitionPhase.idle,
    this.pendingTransition,
    this.pendingSceneId,
    this.activeInspection,
  });

  final SceneStatus status;

  /// Why loading failed, when [status] is [SceneStatus.failed].
  final Failure? failure;

  final CaseContent? content;
  final GameProgress? progress;

  /// The scene on screen.
  final SceneDefinition? scene;

  /// Its current look, with visual variants resolved.
  final SceneVisual? visual;

  /// The hotspots that exist right now (`visibleWhen` and hidden hotspots
  /// applied).
  final List<HotspotDefinition> visibleHotspots;

  final TransitionPhase transitionPhase;

  /// The transition being played, while [transitionPhase] is not idle.
  final SceneTransition? pendingTransition;

  /// The scene the transition leads to.
  final String? pendingSceneId;

  /// The open inspection panel, if any.
  final InspectionDefinition? activeInspection;

  /// Navigation stack, root first.
  List<String> get stack => progress?.sceneStack ?? const [];

  bool get canGoBack => stack.length > 1;

  bool get isReady => status == SceneStatus.ready;

  /// Whether a tap on the scene is accepted right now.
  bool get acceptsTaps =>
      isReady &&
      transitionPhase == TransitionPhase.idle &&
      activeInspection == null;

  SceneState _copy({
    GameProgress? progress,
    SceneDefinition? scene,
    SceneVisual? visual,
    List<HotspotDefinition>? visibleHotspots,
    TransitionPhase? transitionPhase,
    SceneTransition? Function()? pendingTransition,
    String? Function()? pendingSceneId,
    InspectionDefinition? Function()? activeInspection,
  }) {
    return SceneState(
      status: status,
      failure: failure,
      content: content,
      progress: progress ?? this.progress,
      scene: scene ?? this.scene,
      visual: visual ?? this.visual,
      visibleHotspots: visibleHotspots ?? this.visibleHotspots,
      transitionPhase: transitionPhase ?? this.transitionPhase,
      pendingTransition: pendingTransition == null
          ? this.pendingTransition
          : pendingTransition(),
      pendingSceneId: pendingSceneId == null
          ? this.pendingSceneId
          : pendingSceneId(),
      activeInspection: activeInspection == null
          ? this.activeInspection
          : activeInspection(),
    );
  }

  @override
  List<Object?> get props => [
    status,
    failure,
    content,
    progress,
    scene,
    visual,
    visibleHotspots,
    transitionPhase,
    pendingTransition,
    pendingSceneId,
    activeInspection,
  ];
}
