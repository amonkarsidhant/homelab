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

1. **Gitea Actions Plugin** (requires custom Backstage app)
   - Current limitation: Stock Backstage image only supports GitHub.com
   - Workaround: All components have "CI/CD (Gitea Actions)" link in Links section
   - Solution paths:
     - Build custom Gitea Actions backend plugin
     - Migrate to custom Backstage app scaffold
     - Create proxy/adapter for Gitea→GitHub API translation
   - See: `docs/backstage-dev-portal.md` for details

2. Add service risk widgets (missing runbook, stale ownership, failing deploys)

3. Add curated homepage slices:
   - At-risk services (scorecard < 0.8)
   - Failing pipelines (via Gitea API when plugin ready)
   - Recent production changes

4. Move from guest-focused browsing to authenticated RBAC views in Week 3
