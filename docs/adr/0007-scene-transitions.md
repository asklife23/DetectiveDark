# 0007. Scene transitions: fades, no zoom

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

Players move between main locations and close-ups dozens of times per chapter. A zoom into the tapped
point is common in the genre, but it requires matching art at both zoom levels, looks wrong with
AI-assisted art whose close-ups are separate images, and becomes tiring after many repetitions. Some
transitions need to linger in the dark while a sound plays (a door creaking open). Double taps during a
transition must not trigger a second action.

## Decision

- **No zoom.** The default transition is a fade to black (150 ms) → scene change → fade in (150 ms).
- Every `goToScene` effect can override it in JSON: `type` (`fade` | `cut`), `fadeOutMs`, `holdMs` (time
  spent in black, e.g. while a sound effect plays), `fadeInMs`, optional `sfx` (sound arrives in Phase 6).
  Defaults live in `AppDurations`.
- Back uses the same transition type to return to the parent scene.
  The type is remembered for the running session only: after loading a save, Back from the restored
  scene uses the default fade. Stack entries do not store a transition type, so the save format
  (ADR 0003) stays free of presentation details (decided 2026-11-14).
- `SceneBloc` holds only the transition phase (`idle` / `covering` / `revealing`); the UI owns the timing.
  When the screen is fully black the UI sends `TransitionCovered` and the bloc swaps the scene.
- Taps are ignored while a transition runs.

## Consequences

- A calm, consistent noir rhythm that does not depend on how the art was produced.
- Dramatic moments are tuned in content (longer hold, sound) without code changes.
- Splitting timing (UI) from state (bloc) keeps the bloc testable with no timers.
- A fade hides spatial continuity between a location and its close-up; the art direction and scene titles
  have to keep the player oriented.
