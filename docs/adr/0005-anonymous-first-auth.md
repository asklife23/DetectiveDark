# 0005. Anonymous-first authentication

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

A sign-up form on first launch makes many players quit before they see the game. Still, saves and
purchases must survive a reinstall, and both stores require in-app account deletion when accounts exist.
The game must also start and be fully playable offline.

## Decision

- On first launch, if there is a connection, the app signs in **anonymously** with Supabase. Without a
  connection the game starts anyway and retries later; local saves never wait for the network.
- On successful sign-in, an ownerless local save is assigned to that user.
- At the end of Chapter 1 the player is invited to **secure their progress** by linking Google or Apple to
  the anonymous user (`linkIdentityWithIdToken`). The user ID does not change, so saves stay attached.
- **"I already have an account"** signs in with the existing identity on a fresh install; the cloud save is
  then restored by the sync flow (ADR 0006).
- **Account deletion** runs through an Edge Function that deletes the user and their saves, then clears
  local data.
- Mobile only. The Steam version has no account; Steam itself identifies the player.

## Consequences

- No forms before play; the account appears only when the player has something worth protecting.
- Anonymous users who never link lose cloud progress on reinstall; the Chapter 1 prompt and the settings
  screen make this clear.
- Anonymous sign-ins must be rate-limited in Supabase to prevent abuse.
- Linking and the "account already linked elsewhere" case need careful handling and tests.
