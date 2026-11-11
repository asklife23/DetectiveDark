# 0006. Cloud sync with revisions and explicit conflicts

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

On mobile, progress is saved locally first (ADR 0003) and synced to Supabase when online. The same
account can play on two devices, or play offline on one device while the other is online. "Last write
wins" by timestamp silently destroys progress when device clocks differ or both devices played.
Players must never lose progress without being asked.

## Decision

- **Revisions, not timestamps.** Each cloud save has an integer `revision`. Locally, `localRevision`
  increments on every save, `cloudRevision` remembers the last revision seen in the cloud, and `isDirty`
  marks unsent changes.
- **Atomic compare-and-swap on the server:** the Postgres function `upsert_save` writes only if the cloud
  `revision` equals the expected one and returns the new revision; otherwise it returns the current cloud
  save summary as a conflict.
- **Push** when the local save is dirty and owned by the current user. `isDirty` is cleared only if the
  pushed `localRevision` is still the latest, so a save made during the upload is not lost.
- **Pull** when the cloud revision is newer and the local save is not dirty: download, migrate, store.
- **Conflict** only when both sides changed: the player chooses between two summary cards (chapter, scene,
  notes, play time, date). The losing save is first copied to a local `save_backups` table.
- Sync runs on start, on resume, ~5 s after an autosave and on connectivity changes; one sync at a time;
  failures retry with exponential backoff (2 s … 5 min). Sync status is exposed as a stream for the
  settings screen.
- Mobile only; Steam relies on Steam Cloud (ADR 0009).

## Consequences

- No silent progress loss; the player is asked only on a real conflict, which is rare for one player.
- Clock differences between devices do not matter.
- More logic than last-write-wins; it lives in pure-Dart services and is covered by scenario tests with a
  fake cloud (offline → online, reinstall, two devices, save during push).
