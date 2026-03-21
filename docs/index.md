# Homelab Platform

> **A production-grade homelab running 18 services on a single Azure VM — fully documented, automatically backed up, and rebuildable from scratch.**

## What This Is

A self-hosted infrastructure stack providing enterprise-grade DevOps, security, and AI tooling — running on a single Azure VM. Everything from git hosting and CI/CD pipelines to password management, on-call alerting, AI chat, and a full developer portal.

## Quick Links

- [:rocket: Quick Start](quickstart.md) — Get up and running in 5 minutes
- [:wrench: Operations Runbook](homelab-operations-runbook.md) — Day-to-day operational guide
- [:card_file_box: Backup Guide](backup/backup-guide.md) — Automated backup system
- [:twisted_rightwards_arrows: Rebuild Spec](rebuild/README.md) — Disaster recovery playbook
- [:pill: Backstage Dev Portal](backstage-dev-portal.md) — Service catalog and developer portal

## Architecture

```
Internet ──► Traefik (TLS termination, routing)
                    │
    ┌───────────────┼────────────────┬───────────────┐
    │               │                │               │
 Authelia       Gitea         Backstage        Goalert
    │               │                │               │
 Vaultwarden    Act Runner        n8n         Homarr
    │               │                │               │
 Code Server  Open WebUI     Mailserver     Observability
                                               (Prometheus +
                                                Grafana +
                                                 Loki)
```

## Features

- **18 production services** with automatic TLS via Let's Encrypt
- **Authelia SSO** protecting all authenticated endpoints
- **Full observability stack** — metrics, logs, traces, alerting
- **Automated backup system** — encrypted, multi-target (GitHub, Pi, Mac)
- **Disaster recovery playbook** — rebuild entire homelab from blank VM
- **AI chat** powered by Open WebUI + LiteLLM
- **Developer portal** with Backstage service catalog

## Services Overview

| Layer | Services |
|-------|----------|
| Security & Auth | Authelia, Vaultwarden |
| Source & CI | Gitea, Act Runner |
| Observability | Prometheus, Grafana, Loki, Jaeger, Alertmanager |
| Developer Experience | Backstage, Code Server, Homarr |
| Automation | n8n, Traefik |
| AI | Open WebUI, LiteLLM |
| Communication | Mailserver |

## Getting Started

1. [Clone the repo](https://github.com/amonkarsidhant/homelab)
2. Follow the [Quick Start guide](quickstart.md)
3. Set up [secrets](rebuild/SECRETS.md)
4. Start [services](services.md)
5. Configure [backups](backup/backup-guide.md)

## Support

- [GitHub Issues](https://github.com/amonkarsidhant/homelab/issues)
- [Operations Runbook](homelab-operations-runbook.md)
- [Troubleshooting Guide](troubleshooting.md)

This homelab is an Azure VM-based platform for delivery automation, observability, and security experimentation. It runs a complete DevOps stack with CI/CD, monitoring, secrets management, and developer experience tools.

## Architecture

The platform consists of:

- **Infrastructure**: Single Azure VM with persistent data volume
- **Edge Layer**: Traefik reverse proxy with TLS termination
- **Security**: Authelia authentication, Vaultwarden secrets
- **CI/CD**: Gitea + Gitea Actions + act-runner
- **Observability**: Prometheus, Grafana, Loki, Jaeger
- **Developer Portal**: Backstage (this portal!)
- **Incident Management**: GoAlert for on-call scheduling

## Quick Links

- [Operations Runbook](homelab-operations-runbook.md)
- [Week 2-4 Roadmap](week2-4-roadmap.md)
- [Backstage Scorecard](backstage-scorecard.md)

## Core Services

### Platform Tier

- **Traefik**: Reverse proxy and ingress controller
- **Gitea**: Git hosting and CI/CD control plane
- **act-runner**: Gitea Actions execution runtime
- **Minio**: Object storage for artifacts and backups
- **Authelia**: SSO and authentication gateway

### Observability Tier

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Dashboards and visualization
- **Loki**: Log aggregation
- **Jaeger**: Distributed tracing

### Developer Experience

- **Backstage**: Service catalog and developer portal
- **GoAlert**: On-call scheduling and escalation

## Getting Started

New to the homelab? Start here:

1. Review the [Operations Runbook](homelab-operations-runbook.md)
2. Check service health in [Grafana](https://grafana.homelabdev.space)
3. View recent deployments in [Gitea Actions](https://gitea.homelabdev.space/sidhant/homelab/actions)
4. Browse the service catalog in Backstage

## Operational Excellence

- **Service Scorecard**: All 13 components maintain 100% quality score
- **CI/CD Integration**: Automated deploy on merge to main
- **Monitoring**: Full observability stack with Prometheus + Grafana
- **Secrets**: Centralized in Vaultwarden
- **Documentation**: TechDocs for all major components

## Support

- **Runbook**: See [homelab-operations-runbook.md](homelab-operations-runbook.md)
- **Incidents**: Escalate via GoAlert
- **Questions**: Check existing docs or create an issue in Gitea
