# 0019. Autosave: memory first, delayed write, play time stamped by the save

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

ADR 0003 put the save game into a Drift database, and ADR 0014 made `ProgressRepository.save` the one
atomic write of an interaction. With a real disk behind the interface, three questions had to be answered:

- One tap can cause several saves in a row (the effect pipeline, then "note read", then the next tap).
  Writing a row for each is wasteful and bumps the sync revision for no reason.
- A phone may stop a paused app at any moment without telling it. Whatever is not on disk then is lost.
- The play time has to count only while the player sees the game, and the game rules must not care
  about it (they are pure and have no clock).

## Decision

- **Memory first.** `DriftProgressRepository.save` updates the progress in memory, notifies the listeners
  and returns `Success` at once. The interface and every caller stay as they were.
- **Delayed, merged write.** The row is written 500 ms after the first unwritten change; later changes in
  that window go into the same write (the timer is not restarted, so a stream of changes cannot postpone
  it). Writes are chained and never overlap. Every write is `localRevision + 1`, `isDirty = true`.
- **Immediate write when the app leaves the foreground.** The `app/` layer listens to the app lifecycle
  (`SaveLifecycle`) and talks to the save through a small domain interface, `ProgressAutosave`
  (`onBackground` / `onForeground`). `hidden`, `paused` and `detached` write at once; a window that is
  being closed (desktop) waits for the write before the app exits. `inactive` does nothing.
- **The disk is read once**, by the first `load`. Afterwards memory is the truth and a later `load`
  answers from it (the developer menu restarts the scene bloc, which loads again).
- **Play time belongs to the save, not to the rules.** A `PlayTimeCounter` (monotonic stopwatch, paused in
  the background) starts from the stored value. The time is stamped into the payload and the summary
  column at the moment of writing; the progress in memory keeps the value it was loaded with. A progress
  saved with a *different* play time is another playthrough (new game, pasted save) and restarts the count
  from that value.
- **Unreadable saves are handled in `load`:** too new → `SaveTooNewFailure`, nothing is touched and later
  saves are refused; corrupt → moved to `save_backups`, `SaveCorruptFailure`, the slot is free. The
  version column is checked before the payload is decoded, so a future format this build cannot even
  parse is "too new", never "corrupt".

## Consequences

- The game never waits for the disk; a burst of changes costs one write.
- **`save` no longer reports disk errors.** A failed write is logged, the progress stays unwritten and
  the next change or the next background tries again. The player is not told. A crash or a kill can lose
  at most the last 500 ms of changes.
- The progress in memory shows the play time of the last load, not the live one. Nothing in the game reads
  it today; a screen that shows the live play time must ask the save, not the progress.
- Starting a new game from a save with play time 0 cannot be told apart from continuing it by the play
  time alone. The "New game" action of the main menu (Phase 6) must reset the counter explicitly.
- Tests give the app an in-memory repository (`configureDependencies(progressRepository: ...)`): no
  timers, no database file. The Drift repository has its own tests on an in-memory SQLite database.
