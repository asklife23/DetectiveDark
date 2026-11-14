# 0015. Note entries and the People category

- **Status:** Accepted
- **Date:** 2026-11-14

## Context

Notes were write-once: `addNote` puts a fixed text into the notebook. Characters can now be questioned
(ADR 0016), and what they say has to end up somewhere the player can reread and later use as evidence.
One new note per statement would flood the notebook; rewriting a note would need a second note ID per
version.

The third notebook category was `suspect`. Witnesses get files too, and labelling a file "suspect" the
moment it appears tells the player who matters.

## Decision

- The category `suspect` becomes **`person`** (tab "People"): files of suspects and witnesses alike. Who is
  a suspect is defined in `case.json` with the accusation (phase 5.5), not by the notebook.
- A note may declare an optional catalog of **entries**; the new effect `addNoteEntry` reveals one:

```json
{"id": "person_pharmacist", "category": "person", "titleKey": "...", "bodyKey": "...",
 "entries": [{"id": "knows_villa", "textKey": "..."}, {"id": "pills_prescribed", "textKey": "..."}]}

{"addNoteEntry": {"note": "person_pharmacist", "entry": "knows_villa"}}
```

- The save stores, per collected note, `entries: [{entryId, addedAtUtcMs}]` in the order they were added.
  Texts stay in the catalog.
- Adding an entry marks the note **unread** again and publishes `NoteUpdated`. If the note is not in the
  notebook yet, the effect adds it first (then `NoteAdded` is published instead). Adding an entry twice
  does nothing.
- Entries work for every category, but statements of characters are their main use: they are filed as
  lines in the person's file.

## Consequences

- A file grows as the investigation moves on; the notebook badge tells the player something changed.
- One note ID per person keeps evidence selection in the accusation simple.
- `CollectedNote` and the phase 2.2 payload gain `entries`; one more effect and one more event.
- Renaming the category touches the enum, the DTO, the ARB keys of the tab and its empty state, and tests.
  No save exists yet, so no migration is needed.
- Entry order in the notebook is the order of discovery, which differs between players.
