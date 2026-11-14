# 0017. Travel between locations without a map

- **Status:** Accepted
- **Date:** 2026-11-14

## Context

A chapter has several locations (the villa, the market square, ...), each a root scene with its own
close-ups. The open question was how the player moves between them: a map screen, a location list, or
nothing. A map is a second navigation model next to the scene stack, needs its own art and unlock rules,
and turns "where can I go?" into a menu instead of something found in the world.

## Decision

- **No map and no location list.** Locations are reached only through transition hotspots in the scene: a
  signpost, a gate, an exit. Finding the way is part of exploring.
- Navigation does not change: the stack is always the parent chain of the target scene
  (`SceneStackResolver`). Arriving at a root location leaves a stack of one scene, so the Back button is
  hidden there; Back always leads to the parent, never "to where I came from".
- A hotspot `sprite` may carry **`overlays`** (same model as scene overlays, normalized to the scene image).
  They are drawn and hidden together with the sprite. This is how a signpost that appears under a condition
  gets its readable, translatable text (ADR 0011, ADR 0012).
- The content validator gains two checks:
  - **error:** from every root scene there must be a way back to the entry scene of its chapter (following
    `goToScene` effects and Back). A location the player can enter but never leave is a trap.
  - **warning:** a `goToScene` whose target is neither a child of the current scene, nor its parent, nor a
    root scene. Such a jump works, but Back will not lead where the player expects.
- Content rule: the central scene of every interior location has an exit hotspot.

## Consequences

- No map screen, no map art, no second navigation state in the save.
- Authors control the pacing of new locations with ordinary rules: the signpost appears once the letter
  has been read.
- With many locations the player may walk through several scenes to cross the chapter. Chapter layout must
  keep routes short; play testing (phase 7.4) decides whether shortcuts are needed. A shortcut is just
  another transition hotspot.
- The trap check ignores conditions, so it proves that a way back is *written*, not that it is always
  *open*. The chapter walkthrough run in CI (phase 7.4) covers the rest.
- Closes the open question "navigation in 50+ scenes" in the game design.
