# 0009. Platform targets and platform services

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

The game ships on Android, iOS and Steam (Windows). Gameplay, content and UI are identical everywhere, but
some services are not: on mobile, purchases go through the stores and progress is protected by a Supabase
account (ADR 0004, 0005, 0006); on Steam, ownership and DLC come from Steam and saves are synced by Steam
Cloud. Several mobile packages (store purchases, Google sign-in) do not support Windows. Spreading
`Platform.isWindows` checks through the game would couple every feature to every platform.

## Decision

- **Two build targets**, `BuildTarget.mobile` and `BuildTarget.steam`, carried in `AppConfig`. The entry
  point decides: `main_dev/staging/prod.dart` → mobile, `lib/main_steam.dart` → Steam (`prod` flavor).
- **Platform services live behind domain interfaces** (`EntitlementRepository`, `AuthRepository`,
  `CloudSaveRepository`, ...). DI registers the implementation for the build target: store + Supabase for
  mobile, Steam ownership + Steam Cloud for Steam (no account, no `SyncService`).
- **Game code never checks the platform.** Platform checks are allowed only in `app/` start-up code where
  the OS itself differs (e.g. system UI calls that Windows does not implement).
- Packages without Windows support are used only inside mobile implementations, never by shared code.
- **Steam API last:** prefer mechanisms that need no Steamworks API (Steam Auto-Cloud for the save file,
  DLC delivered as a separate depot). A Steamworks binding is considered only if a feature requires it.
- **Windows window:** the native runner opens a 1280×720 (16:9) client area and enforces a 960×540
  minimum, both in logical pixels scaled by the monitor DPI. The scene is always drawn in a 16:9 viewport,
  so any window size works. Full screen and resolution options come in Phase 11.
- The mobile entry points also run on Windows for quick development testing (target stays `mobile`);
  mobile-only services get development stand-ins there when they are introduced.
- CI builds the Steam release on `windows-latest` on every push.

## Consequences

- One code base and one content set for three stores; a platform difference costs one interface
  implementation and one DI registration.
- Every feature is exercised on Windows with mouse input from the start, which also gives a fast
  development loop without a phone.
- Two sets of platform services to build, test and keep in sync (Phases 3–4 and 8 for mobile, 11 for Steam).
- Progress and purchases do not transfer between mobile and Steam; this is a product decision, not a
  technical limit.
- The runner's window code diverges slightly from the Flutter template; it is marked in the source.
