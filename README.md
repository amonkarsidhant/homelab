# Homelab

> **A production-grade homelab running 14 services on a single Azure VM — fully documented, automatically backed up, and rebuildable from scratch in ~2 hours.**

---

## What This Is

A self-hosted infrastructure stack providing enterprise-grade DevOps, security, and AI tooling — running on commodity hardware in your living room. Everything from git hosting and CI/CD pipelines to password management, on-call alerting, AI chat, and a full developer portal.

**Azure VM** · Ubuntu 22.04 LTS · Docker + Traefik · 14 services

---

## Services

| # | Service | URL | Purpose |
|---|---------|-----|---------|
| 1 | **Traefik** | — | Reverse proxy + automatic TLS (Let's Encrypt) |
| 2 | **Authelia** | auth.homelabdev.space | SSO provider for all protected services |
| 3 | **Gitea** | gitea.homelabdev.space | Self-hosted Git hosting |
| 4 | **Act Runner** | — | GitHub Actions-compatible CI/CD runner |
| 5 | **Prometheus** | observability.homelabdev.space | Metrics collection |
| 6 | **Grafana** | observability.homelabdev.space | Dashboards + alerting |
| 7 | **Loki** | — | Log aggregation |
| 8 | **Jaeger** | — | Distributed tracing |
| 9 | **Alertmanager** | — | Alert routing + deduplication |
| 10 | **Backstage** | backstage.homelabdev.space | Developer portal + service catalog |
| 11 | **Goalert** | goalert.homelabdev.space | On-call alerting + incident management |
| 12 | **n8n** | ai.homelabdev.space | Workflow automation |
| 13 | **Vaultwarden** | vault.homelabdev.space | Password + secrets manager |
| 14 | **Code Server** | code.homelabdev.space | Cloud IDE (VS Code in browser) |
| 15 | **Homarr** | home.homelabdev.space | Dashboard |
| 16 | **Open WebUI** | chat.homelabdev.space | AI chat (LiteLLM-powered) |
| 17 | **LiteLLM** | localhost:4000 | AI gateway (15+ model providers) |
| 18 | **Mailserver** | mail.homelabdev.space | Email receiving + relay |

---

## Quick Start

### Clone and Explore
```bash
git clone https://github.com/amonkarsidhant/homelab.git ~/homelab
cd ~/homelab
```

### Check Service Health
```bash
bash scripts/service-integrity-check.sh
```

### View Architecture
```bash
cat docs/homelab-architecture.md
```

---

## Rebuild from Scratch

**If the VM dies, rebuild everything from this repo in ~2 hours.**

👉 Read: [`docs/rebuild/README.md`](docs/rebuild/README.md)

The rebuild system includes:
- `BOOTSTRAP.sh` — one-shot VM setup script
- `docs/rebuild/AGENT.md` — AI agent instructions for autonomous rebuild
- `docs/rebuild/SERVICES.md` — per-service step-by-step guides
- `docs/rebuild/SECRETS.md` — secrets checklist + recovery guide
- `.env-template/` — env file templates for all 14 services

---

## Documentation

### Operations
| Document | Description |
|----------|-------------|
| [`docs/homelab-operations-runbook.md`](docs/homelab-operations-runbook.md) | Day-to-day operations guide |
| [`docs/operations-checklist.md`](docs/operations-checklist.md) | Pre-flight + health checklists |
| [`docs/homelab-architecture.md`](docs/homelab-architecture.md) | System architecture + data flows |

### Security & Compliance
| Document | Description |
|----------|-------------|
| [`docs/chaos-engineering.md`](docs/chaos-engineering.md) | Chaos engineering program |
| [`docs/week2-reliability-hardening.md`](docs/week2-reliability-hardening.md) | Reliability hardening |

### Automation
| Document | Description |
|----------|-------------|
| [`docs/week1-automation-foundation.md`](docs/week1-automation-foundation.md) | Initial automation setup |
| [`docs/week2-4-roadmap.md`](docs/week2-4-roadmap.md) | Build roadmap |
| [`docs/backstage-dev-portal.md`](docs/backstage-dev-portal.md) | Backstage setup + usage |
| [`docs/backstage-cortex-inspired-portal.md`](docs/backstage-cortex-inspired-portal.md) | Service catalog design |

### Services
| Document | Description |
|----------|-------------|
| [`docs/vaultwarden-admin-user-guide.md`](docs/vaultwarden-admin-user-guide.md) | Vaultwarden admin guide |

### Backup & Recovery
| Document | Description |
|----------|-------------|
| [`docs/backup/backup-guide.md`](docs/backup/backup-guide.md) | Backup system guide |
| [`docs/backup/pi-mac-setup.md`](docs/backup/pi-mac-setup.md) | Pi + Mac backup target setup |

### Rebuild (Disaster Recovery)
| Document | Description |
|----------|-------------|
| [`docs/rebuild/README.md`](docs/rebuild/README.md) | Master rebuild spec |
| [`docs/rebuild/AGENT.md`](docs/rebuild/AGENT.md) | AI agent rebuild guide |
| [`docs/rebuild/SERVICES.md`](docs/rebuild/SERVICES.md) | Per-service rebuild steps |
| [`docs/rebuild/SECRETS.md`](docs/rebuild/SECRETS.md) | Secrets recovery guide |

---

## Scripts

### Health & Integrity
```bash
bash scripts/service-integrity-check.sh      # Full integrity check
bash scripts/health-check.sh                # Container health snapshot
bash scripts/config-drift-check.sh          # Repo vs live config drift
bash scripts/config-drift-check.sh baseline # Set drift baseline
```

### Automation
```bash
bash scripts/autonomous/overnight-agent-runner.sh  # Run all overnight agents
bash scripts/autonomous/install-cron.sh             # Install overnight schedule
```

### CI/CD
```bash
bash scripts/ci-preflight.sh                # Pre-commit checks
bash scripts/vm-deploy-orchestrator.sh     # VM deployment
```

### Chaos Engineering
```bash
bash scripts/chaos/chaosctl.sh             # Chaos control CLI
bash scripts/chaos/install-grafana-reporting-dashboard.sh  # Install Grafana dashboard
bash scripts/chaos/install-weekly-drill.sh              # Schedule weekly drill
```

### Backstage
```bash
bash scripts/backstage-catalog-validate.sh  # Validate catalog entities
bash scripts/backstage-scorecard.sh          # Generate quality scorecard
```

---

## Backup System

Automated overnight backups run via systemd timer. Backups are:
- **Encrypted** with GPG (secrets volumes)
- **Pushed to GitHub** (git mirror, automatic)
- **Synced to Raspberry Pi** (LAN, 24/7)
- **Synced to MacBook** (LAN, secondary)

```bash
# Run backup manually
BACKUP_PASSPHRASE="your-passphrase" bash scripts/backup/backup-runner.sh

# Restore from backup
BACKUP_PASSPHRASE="your-passphrase" bash scripts/backup/restore.sh ~/backups/homelab-backup-YYYYMMDD-HHMMSS.tar.gz.gpg
```

See [`docs/backup/backup-guide.md`](docs/backup/backup-guide.md) for full setup.

---

## Architecture

```
                        ┌─────────────────────────────────────────┐
Internet ─────────────►│  Traefik (443/80)                      │
                        │  Let's Encrypt via Cloudflare DNS-01   │
                        └──────────┬────────────────────────────────┘
                                   │路由
     ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
     │Authelia  │  │  Gitea   │  │Backstage │  │ Goalert  │  │  n8n     │
     │(SSO)     │  │  (Git)   │  │(Portal)  │  │(On-call) │  │(Workflow)│
     └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘
     ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
     │Vaultwarden│ │Code-Server│ │Homarr    │  │Open WebUI│  │Mailserver│
     │(Passwords)│  │(IDE)     │  │(Dashboard)│  │(AI Chat) │  │(Email)   │
     └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘

     ┌──────────────────────────────────────────────────────────────────────┐
     │  Observability: Prometheus · Grafana · Loki · Jaeger · Alertmanager │
     └──────────────────────────────────────────────────────────────────────┘

                        ┌─────────────────────────────────────────┐
  GitHub ◄──────────────│  Act Runner (CI/CD)                      │
                        │  Gitea webhooks → trigger pipelines       │
                        └─────────────────────────────────────────┘
```

---

## Repository Structure

```
homelab/
├── BOOTSTRAP.sh              # One-shot VM rebuild script
├── .env-template/           # Env file templates for all services
├── traefik/                 # Reverse proxy + TLS
├── authelia/                # SSO provider
├── gitea/                   # Git hosting
├── act-runner/              # CI/CD runner
├── observability/           # Prometheus, Grafana, Loki, Jaeger, Alertmanager
│   └── grafana-provisioning/  # Pre-built dashboards + datasources
├── backstage/               # Developer portal
│   └── catalog/             # Backstage entity catalog
├── goalert/                 # On-call alerting
├── n8n/                     # Workflow automation
│   └── workflows/           # n8n workflow JSONs
├── vaultwarden/             # Password manager
├── code-server/             # Cloud IDE
├── mailserver/              # Email server
├── homarr/                  # Dashboard (appdata + config)
├── chat-ui/                 # Open WebUI (AI chat)
├── ai-gateway/              # LiteLLM AI gateway
├── scripts/                 # Operational scripts
│   ├── autonomous/          # Overnight agent system
│   ├── backup/              # Backup + restore scripts
│   └── chaos/               # Chaos engineering tools
├── docs/                    # Documentation
│   ├── rebuild/              # Disaster recovery docs
│   ├── backup/              # Backup system docs
│   └── chaos-reports/       # Weekly chaos drill reports
└── .github/
    └── workflows/           # GitHub Actions workflows
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| OS | Ubuntu 22.04 LTS |
| Container Runtime | Docker + Docker Compose |
| Reverse Proxy | Traefik v3 |
| TLS | Let's Encrypt (Cloudflare DNS-01) |
| SSO | Authelia |
| Git | Gitea |
| CI/CD | Act Runner |
| Monitoring | Prometheus + Grafana |
| Logs | Loki + Promtail |
| Tracing | Jaeger |
| Alerting | Alertmanager + Goalert |
| Developer Portal | Backstage |
| Workflow Automation | n8n |
| Password Management | Vaultwarden |
| Cloud IDE | Code Server |
| AI Chat | Open WebUI + LiteLLM |
| Email | Docker Mailserver |
| Dashboard | Homarr |
| VPN | Tailscale |

---

## Contact

- GitHub Issues: [github.com/amonkarsidhant/homelab/issues](https://github.com/amonkarsidhant/homelab/issues)
- Gitea: [gitea.homelabdev.space](https://gitea.homelabdev.space)
