# 0011. Overlay text, shared noir filter and AI-assisted art

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

Scene art will be produced with AI-assisted tools. They are fast and can hold a mood, but:

- they render text and digits unreliably (garbled letters, wrong numbers);
- changing one digit means regenerating the image, which also changes the rest of the picture;
- images generated at different times drift in tone, grain and contrast.

Puzzles depend on exact text and numbers (a clock time, a safe code, the text of a letter), and every
puzzle answer must be fairly findable. The game must also accept new languages later without new art.

## Decision

1. **Overlay text.** Readable or puzzle-critical text and numbers are never baked into images. They are
   defined in content JSON as `overlays` on a visual (scene background, visual variant, inspection image)
   and drawn by the game: a normalized `rect` relative to the image (0–1), a localized `textKey`, a named
   `style` preset defined in code (typewriter, handwriting, engraved, ...) and an optional `rotation`.
   Phase 1 implements `TextOverlay`; other kinds (e.g. analog clock hands) are added when a puzzle needs them.
2. **Shared noir filter.** One filter layer is applied to every background and inspection image: film
   grain, vignette and color grading. The settings are named presets in `core/theme`; a scene may only
   pick a preset by name. Layer order: background → overlays → filter → hotspots → transition. Overlays
   sit under the filter so the text blends into the picture; no preset may make critical text unreadable.
3. **AI-assisted art pipeline** (detailed in Phase 7.3): a written style guide, prompts that ask for no
   text, manual cleanup, close-ups cropped or inpainted from the main image for consistency, and a
   per-image usage log (tool, model, date, prompt, manual edits) in `docs/art/ai-usage.md`.

## Consequences

- Puzzle answers are always legible and correct, and can change in JSON without touching the art.
- Overlay text is localized, so a new language needs no new images.
- The filter makes images from different sessions, and the placeholder drawings, look like one film.
  Placeholders stop drawing their own grain and vignette.
- Overlay rects must be placed precisely; the dev hotspot editor (Phase 7.2) edits them as well.
  The content validation test checks overlay rects and text keys.
- The filter costs GPU time whenever the scene repaints. It sits in the background `RepaintBoundary`, its
  implementation is chosen by measuring on Android, iOS and Windows (Phase 1.4), and grain is static by default.
- Steam requires disclosing pre-generated AI content in its content survey, which is shown on the store
  page (Phase 11.5); the usage log is the source. The chosen tool's terms must allow commercial use.
  Purely AI-generated images may get limited copyright protection in some jurisdictions; this is accepted.
