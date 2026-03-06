# Homelab Architecture

## Overview

This homelab runs on a single Azure VM with Docker Compose stacks and Traefik ingress.

Traffic flow:
1. Cloudflare DNS -> VM public IP
2. Traefik handles TLS and routing
3. Authelia protects selected routes (forward auth)
4. Service containers run on shared Docker network `traefik_default`

Persistent state:
- Stored under `/mnt/data/*` (non-OS volume)

## Service Map

| Domain | Service | Container | Data Path |
|---|---|---|---|
| `gitea.homelabdev.space` | Git + CI control plane | `gitea` | `/mnt/data/gitea` |
| `auth.homelabdev.space` | Identity / SSO | `authelia` | `/mnt/data/authelia` |
| `vault.homelabdev.space` | Password manager | `vaultwarden` | `/mnt/data/vaultwarden` |
| `grafana.homelabdev.space` | Dashboards/alerts | `grafana` | `/mnt/data/grafana` |
| `prometheus.homelabdev.space` | Metrics | `prometheus` | `/mnt/data/prometheus` |
| `jaeger.homelabdev.space` | Tracing UI | `jaeger` | `/mnt/data/jaeger` |
| `minio.homelabdev.space` | Object storage | `minio` | `/mnt/data/minio` |
| `code.homelabdev.space` | Web IDE | `code-server` | `/home/sidhant/.config/code-server` |

Supporting containers:
- `traefik`
- `act-runner`
- `loki`
- `promtail`
- `mailserver`

## CI/CD Flow

1. Changes are made on a feature branch.
2. PR is opened in Gitea.
3. Actions validate changes.
4. Merge to `main` triggers deploy workflow.
5. VM syncs latest repo and applies service updates.

## Reliability Controls

- Hourly integrity check timer:
  - service: `homelab-integrity.service`
  - timer: `homelab-integrity.timer`
- Daily backups to MinIO
- Discord notifications for deploy and integrity failures

## Secrets Strategy

- Runtime secrets are loaded from local `.env` files.
- Source-of-truth is Vaultwarden.
- Breakglass account mapping is documented in Vault as `Breakglass Email Mapping`.
