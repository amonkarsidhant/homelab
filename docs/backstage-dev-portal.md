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
