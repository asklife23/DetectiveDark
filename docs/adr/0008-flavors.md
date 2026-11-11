# 0008. dev / staging / prod flavors

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

Development, testing and real players must never share data or be confused with each other: a test
build must not write to production saves, and the developer wants the store version and test versions on
the same phone at the same time. Configuration such as backend URLs differs per environment and must not
be hard-coded.

## Decision

- Three flavors: **`dev`** (daily development, debug badge on screen), **`staging`** (release-like test
  builds) and **`prod`** (real players). `dev` and `staging` use the staging backend; `prod` uses
  production (ADR 0004).
- **Android `productFlavors`** with `applicationIdSuffix` (`.dev`, `.stg`) and per-flavor launcher names, so
  all three install side by side.
- **One entry point per flavor** (`lib/main_dev.dart`, `main_staging.dart`, `main_prod.dart`), each calling
  `bootstrap(AppConfig)`. At start-up the entry point's flavor is checked against the native `--flavor`;
  a mismatch fails fast.
- **Configuration through `--dart-define-from-file=env/<flavor>.json`**, read into `AppConfig` at compile
  time. Real env files are git-ignored; `env/example.json` documents the keys. They hold only public
  values (the Supabase anon key), never secrets — compiled values can be extracted from the binary.
- Shared Android Studio run configurations live in `.run/`.
- iOS schemes are set up when a Mac or cloud CI is available (Phase 10). Windows has no native flavors; the
  Steam build gets its own entry point (step 0.6).

## Consequences

- Test builds cannot touch production data by accident, and the right build is easy to spot on the phone.
- Running the app always needs a flavor and an entry point (`flutter run` alone fails); the run
  configurations and the README hide this cost.
- Three builds to keep working; CI and the content tests are flavor-independent.
