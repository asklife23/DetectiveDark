# 0010. Inspect effect

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

Many details in a point-and-click scene only need a quick look: the time on a wall clock, a statue's
plaque, the back of a photo. Modelling each one as a child close-up scene adds navigation (go in, go back),
inflates the scene count and the art budget, and hides the detail behind a screen change.
The interaction system (conditions + effects) had no way to show something without navigating.

## Decision

Add an `inspect` effect to the sealed `Effect` hierarchy.

- JSON: `{"inspect": "<inspectionId>"}`. Inspections live in a per-chapter catalog, `inspections.json`:
  `id`, optional `titleKey`, `textKey`, and a `visual` that uses the same model as a scene visual
  (background or placeholder, text overlays, noir filter preset — see ADR 0011).
- It opens a small panel above the current scene with the image and the text. The scene and the
  navigation stack do not change.
- While the panel is open, hotspots ignore taps. Tapping outside, the close button or Back (including the
  Android system back) closes only the panel.
- It is UI state and is not stored in `GameProgress`. Anything that must persist is added by another effect
  in the same rule, e.g. `addNote` for a letter that is read and filed.
- At most one `inspect` per rule, and never together with `goToScene`. The content validation test
  enforces both.
- The inventory's long-press examine card reuses the same panel.

## Consequences

- Look-only details need no close-up scene; places with their own hotspots (drawers, safes) stay close-ups.
- `SceneBloc` gains an `activeInspection` state and an `InspectionClosed` event; Back closes the panel
  before it touches the stack.
- One more effect in the resolver, the content parser and the validation test, all covered by tests.
- Panels never stack, so there is no "inspect inside inspect" and no second navigation model.
