# Backstage Dev Portal

This homelab includes a Backstage developer portal for service discovery and ownership.

## URL

- Portal: `https://backstage.homelabdev.space`

## Deployment Model

- Runtime compose: `backstage/docker-compose.yml`
- Config: `backstage/app-config.yaml`, `backstage/app-config.production.yaml`
- Catalog seed files: `backstage/catalog/`
- Data persistence:
  - Postgres data: `/mnt/data/backstage-postgres`
- Runtime files on VM:
  - `/home/sidhant/backstage`
  - `/home/sidhant/backstage/catalog`

The deploy workflow copies Backstage files to `/home/sidhant/backstage` and runs `docker-compose up -d` there.

## Traefik Routing

Backstage is exposed through Traefik with Authelia forward auth:

- Host: `backstage.homelabdev.space`
- Upstream: `http://backstage:7007`
- Middleware: `authelia`

## First-Time Setup

1. Add DNS record:
   - `backstage -> 51.143.249.28` in Cloudflare.
2. Trigger deploy pipeline on `main`.
3. Verify containers:
   - `docker ps | grep backstage`
4. Verify route:
   - `curl -skI -H 'Host: backstage.homelabdev.space' https://127.0.0.1`

## Service Catalog Structure

- Org entities: `backstage/catalog/org.yaml`
- Platform entities: `backstage/catalog/all.yaml`

Current catalog includes:

- System: `homelab`
- Components: `traefik`, `gitea`, `act-runner`, `authelia`, `prometheus`, `grafana`, `loki`, `jaeger`, `minio`, `vaultwarden`, `backstage`, `goalert`, `homelab-operations-hub`
- Resources: `azure-vm`, `data-volume`, `cloudflare-dns`
- API: `homelab-integrity-check`

## CI/CD Integration

### Current State (Stock Backstage Image)

The Backstage instance currently uses the stock `ghcr.io/backstage/backstage:latest` image which includes:
- GitHub Actions plugin (for GitHub.com)
- Basic catalog features
- TechDocs, Templates, Search

**The CI/CD tab is currently non-functional** because:
1. The stock GitHub Actions plugin expects GitHub.com API endpoints
2. Our Gitea Actions workflows are not exposed through GitHub-compatible APIs
3. A custom Gitea Actions plugin would be needed for full integration

### Workaround: Links Section

All components have a **"CI/CD (Gitea Actions)"** link in the Links section:
- Click the component
- Go to the "Overview" or "Links" section
- Click "CI/CD (Gitea Actions)" to view workflows in Gitea

### Future Enhancement

To populate the CI/CD tab, we need to either:
1. **Build a custom Gitea Actions backend plugin** that fetches workflow runs from Gitea's API
2. **Migrate to a custom Backstage app** with the Gitea plugin installed
3. **Use a proxy/adapter** to translate Gitea API responses to GitHub Actions format

This is tracked in the Week 3-4 roadmap as "Gitea Actions CI/CD plugin/card" work.

## Service Readiness Metadata Convention

Week 2 introduces consistent custom annotations in component entities:

- `homelab.dev/tier`
- `homelab.dev/criticality`
- `homelab.dev/runbook`

These annotations help keep reliability and operational ownership visible in the catalog.

## Golden Path Template

- Template: `homelab-service-onboarding`
- Source: `backstage/catalog/templates/homelab-service/template.yaml`
- Purpose: generate a standardized `catalog-info.yaml` for new homelab services with required readiness metadata.

Usage:

1. Open `https://backstage.homelabdev.space/create`
2. Select **Homelab Service Onboarding**
3. Fill service metadata and links
4. Copy generated `catalog-info.yaml` into your target service repository
5. Register the component in Backstage Catalog

## CI/CD Metadata Contract (Phase 1+2)

- Annotation: `homelab.dev/gitea-repo` (format: `owner/repo`)
- Link title: `CI/CD (Gitea Actions)`
- Current rollout: `homelab-operations-hub` and all newly generated service entities via template

This provides a consistent CI identity contract while we prepare a dedicated Gitea CI plugin/card integration.

## Cortex-Inspired Scorecard

- Generated report: `docs/backstage-scorecard.md`
- Generator: `scripts/backstage-scorecard.sh`
- Enforcement: run in `scripts/ci-preflight.sh` so high-critical production components must keep score >= 0.80.

## Guest Access Policy

- Guest auth is allowed temporarily for homelab usability.
- Traefik + Authelia still gate entry before Backstage guest identity is used.
- Guest mode should remain read-focused; Week 3 will move to stricter authenticated RBAC.

## Adding a New Service to Catalog

1. Add an entity YAML in `backstage/catalog/`.
2. Reference it from `backstage/catalog/all.yaml` (or append directly in that file).
3. Open PR and merge via normal workflow.
4. Refresh entities in Backstage Catalog UI if needed.

## Secrets

Backstage uses `/home/sidhant/backstage/.env` on VM:

- `POSTGRES_PASSWORD`
- `BACKEND_SECRET`

The deploy workflow auto-creates this file once if missing using random values.
