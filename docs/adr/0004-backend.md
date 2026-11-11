# 0004. Supabase backend, FastAPI as a later option

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

The mobile version needs accounts and cloud saves so progress survives a reinstall or a new phone.
A solo developer cannot run and secure a custom auth server from day one. The developer also wants to
learn backend development and may later build a custom API (FastAPI). The Steam version uses Steam's own
services instead (ADR 0009).

## Decision

- **Supabase** for the mobile backend: Auth, Postgres with Row Level Security, and Edge Functions.
- **Two projects:** `detectivedark-staging` (used by the `dev` and `staging` flavors) and
  `detectivedark-prod`. Real player data never meets test data.
- **Schema changes only through SQL files** in `supabase/migrations/`, applied to staging first.
- **Every table has RLS enabled** with explicit policies; no table without a policy.
- The app contains only the anon / publishable key. The service-role / secret key lives only in Edge
  Function environment variables (e.g. account deletion).
- **FastAPI path:** cloud saves are reached through the `CloudSaveRepository` interface. A future FastAPI
  service replaces only that data source; authentication stays in Supabase and the API verifies Supabase
  JWTs.

## Consequences

- Production-grade auth, a real Postgres and security policies without running servers.
- Business rules that must be atomic (compare-and-swap of saves) live in a Postgres function, versioned with
  the migrations.
- Vendor dependency on Supabase, limited by the repository interfaces and by Supabase being open source.
- The free plan pauses inactive projects; production moves to a paid plan before release (Phase 10).
