# Backstage Cortex-Inspired Portal Plan

This plan adapts Cortex-style platform experience patterns to the homelab Backstage instance.

## Principles

- catalog entries are operational products, not static metadata
- every production component should expose ownership, runbook, CI/CD, and readiness context
- scorecards should highlight risk and missing controls

## Implemented Foundation

- Golden path template for service onboarding: `homelab-service-onboarding`
- CI identity contract:
  - annotation: `homelab.dev/gitea-repo`
  - link title: `CI/CD (Gitea Actions)`
- Scorecard generation + policy gate:
  - script: `scripts/backstage-scorecard.sh`
  - report: `docs/backstage-scorecard.md`
  - CI entrypoint: `scripts/ci-preflight.sh`

## Next Build Targets

1. Add a dedicated Backstage plugin/card for Gitea Actions run status per entity
2. Add service risk widgets (missing runbook, stale ownership, failing deploys)
3. Add curated homepage slices:
   - At-risk services
   - Failing pipelines
   - Recent production changes
4. Move from guest-focused browsing to authenticated RBAC views in Week 3
