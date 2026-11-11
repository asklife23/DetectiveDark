# 0003. Local save game with Drift (SQLite)

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

The player must be able to close the game at any moment and continue exactly where they were, offline.
The save format will change many times during development and after release, and on mobile the save will
later be synced to the cloud (ADR 0006). On Steam the save file is synced by Steam Cloud. Options:
`shared_preferences` or plain JSON files, key-value stores (Hive, Isar, sembast) and SQLite (Drift).

## Decision

- **Drift (SQLite)** for the save game; `shared_preferences` only for small settings (and the device ID).
- **One table, `save_slots`**: summary columns (`caseId`, `chapterId`, `sceneId`, `playTimeSeconds`),
  sync columns (`localRevision`, `cloudRevision`, `isDirty`, `updatedAtUtcMs`, `lastSyncedAtUtcMs`), an
  `ownerUserId`, and the full progress as a **versioned JSON payload**. Times are UTC milliseconds.
- **One save slot**: the story is linear, so there is nothing to branch.
- The payload stores only IDs, flags and keys — never texts — and carries its own `schemaVersion`.
  A chain of pure functions migrates it (`v1 → v2 → ...`). A save newer than the app is never read or
  overwritten; a corrupt save is backed up, never silently deleted.
- The database file lives in a fixed, known folder per platform (the app support directory), so Steam
  Cloud can sync it.

## Consequences

- Drift gives typed queries, schema migrations with generated migration tests, and works on Android,
  iOS and Windows.
- The table has the same shape as the cloud table, so sync is a row-level comparison.
- A JSON payload is opaque to SQL queries; this is fine because the game always loads the whole state.
- SQL skills learned here carry over to Supabase/Postgres and a possible FastAPI backend.
- Adds code generation (`build_runner`) to the build.
