# 0012. Object layer: hotspot sprites

- **Status:** Accepted
- **Date:** 2026-11-14

## Context

When the player picks something up, it has to disappear from the scene. `hideHotspot` only removed the tap
area, so the picture had to change too: phase 1 first used a flag plus a visual variant per pickup
(`statue_key_taken` → a second background without the key).

That needs two full scene images per collectable object, and 2ⁿ images for a scene with n objects. With
AI-assisted art (ADR 0011) every extra full image is also a consistency risk: regenerating a scene "without
the key" changes the rest of the picture. For 150+ scenes this multiplies the art budget for no gameplay gain.

## Decision

- A hotspot may carry an optional **sprite**: `rect` (normalized 0–1, relative to the scene image, independent
  of the tap area), `placeholderStyle` and an optional `image` (asset path, transparent background).
- The sprite is drawn exactly while its hotspot is visible. `hideHotspot` and a false `visibleWhen` remove the
  picture together with the tap area; no flag and no visual variant are needed for a pickup.
- While `image` is empty the placeholder painter named by `placeholderStyle` draws the object; switching to
  real art is a one-line JSON change, as for backgrounds.
- Layer order becomes **background → objects → overlays → noir filter → hotspots → transition**. Objects sit
  under the filter so grain, vignette and tint bind them to the background like one photograph.
- Inspection visuals have no object layer.
- Visual variants stay for changes of the scene itself (door open / closed), not for objects lying in it.
- This is presentation data only. `InteractionResolver` and the save format do not change: what is hidden
  is still `hiddenHotspots` in the progress.

This extends the layer order of [ADR 0011](0011-overlay-text-noir-filter-and-ai-art.md).

## Consequences

- One background per scene state instead of one per combination of collected objects.
- Real object art must be produced as separate images with an alpha channel, lit and angled to match the
  background, with the shadow included in the object image (noted in plan step 7.3).
- Sprite rects must be placed precisely; the dev editor (phase 7.2) edits them like hotspot and overlay rects.
  The content validation test checks sprite rects and placeholder style names.
- An object cannot be partly covered by something in the background (a key behind a vase). Such cases need
  either a visual variant or, later, a foreground layer; none exists in the vertical slice.
- The vertical slice dropped the flags `statue_key_taken` / `hall_letter_taken` and two placeholder variants.
