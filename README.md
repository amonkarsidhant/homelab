# Homelab

<p align="center">
  <img src="https://www.docker.com/wp-content/uploads/2022/03/vertical-logo-monochromatic.png" alt="Docker" width="100" />
</p>

> **A production-grade homelab running 18 services on a single VM — fully documented, automatically backed up, and rebuildable from scratch in ~2 hours.**

<p align="center">
  <a href="https://github.com/amonkarsidhant/homelab/actions"><img src="https://img.shields.io/github/actions/workflow/status/amonkarsidhant/homelab/ci.yml?branch=main&style=for-the-badge" alt="CI status" /></a>
  <a href="https://github.com/amonkarsidhant/homelab/blob/main/LICENSE"><img src="https://img.shields.io/github/license/amonkarsidhant/homelab?style=for-the-badge" alt="MIT License" /></a>
  <a href="https://github.com/amonkarsidhant/homelab/commits/main"><img src="https://img.shields.io/github/last-commit/amonkarsidhant/homelab?style=for-the-badge" alt="Last commit" /></a>
  <a href="https://github.com/amonkarsidhant/homelab/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge" alt="PRs welcome" /></a>
  <a href="https://github.com/amonkarsidhant/homelab/network"><img src="https://img.shields.io/github/forks/amonkarsidhant/homelab?style=for-the-badge" alt="Forks" /></a>
  <a href="https://github.com/amonkarsidhant/homelab/stargazers"><img src="https://img.shields.io/github/stars/amonkarsidhant/homelab?style=for-the-badge" alt="Stars" /></a>
</p>

---

## 🎯 What You Get

A **self-hosted infrastructure stack** with enterprise-grade DevOps, security, and AI tooling — all running on a single VM.

| Layer | Services |
|-------|----------|
| 🛡️ **Security & Auth** | Authelia, Vaultwarden |
| 🔄 **Source & CI** | Gitea, Act Runner |
| 📊 **Observability** | Prometheus, Grafana, Loki, Jaeger, Alertmanager |
| 🏗️ **Developer Experience** | Backstage, Code Server, Homarr |
| ⚡ **Automation** | n8n, Traefik |
| ✉️ **Communication** | Mailserver |
| 🤖 **AI** | Open WebUI + LiteLLM gateway |

---

## 🚀 Quick Start

```bash
git clone https://github.com/amonkarsidhant/homelab.git ~/homelab
cd ~/homelab
bash scripts/service-integrity-check.sh
```

---

## 🌐 Services at a Glance

| Service | URL | Status | Purpose |
|---------|-----|--------|---------|
| [Traefik](traefik/) | — | ✅ | Reverse proxy + automatic TLS |
| [Authelia](authelia/) | auth.homelabdev.space | ✅ | SSO provider |
| [Gitea](gitea/) | gitea.homelabdev.space | ✅ | Git hosting |
| [Act Runner](act-runner/) | — | ✅ | CI/CD runner |
| [Prometheus](observability/) | — | ✅ | Metrics |
| [Grafana](observability/) | observability.homelabdev.space | ✅ | Dashboards |
| [Loki](observability/) | — | ✅ | Logs |
| [Jaeger](observability/) | — | ✅ | Traces |
| [Alertmanager](observability/) | — | ✅ | Alerts |
| [Backstage](backstage/) | backstage.homelabdev.space | ✅ | Dev portal |
| [Goalert](goalert/) | goalert.homelabdev.space | ✅ | On-call |
| [n8n](n8n/) | ai.homelabdev.space | ✅ | Workflows |
| [Vaultwarden](vaultwarden/) | vault.homelabdev.space | ✅ | Passwords |
| [Code Server](code-server/) | code.homelabdev.space | ✅ | Cloud IDE |
| [Homarr](homarr/) | home.homelabdev.space | ✅ | Dashboard |
| [Open WebUI](chat-ui/) | chat.homelabdev.space | ✅ | AI chat |
| [LiteLLM](ai-gateway/) | localhost:4000 | ✅ | AI gateway |
| [Mailserver](mailserver/) | mail.homelabdev.space | ✅ | Email |

---

## 🏗️ Architecture

```
     Internet
         │
    [ Traefik ] — TLS termination, routing
         │
    ┌────┴────┬──────────┬─────────────┬──────────┬─────────┐
    │         │          │             │          │         │
[Authelia] [Gitea]  [Backstage]  [Goalert]  [n8n]  [Vaultwarden]
    │         │          │             │          │         │
    └─────────┴──────────┴─────────────┴──────────┴─────────┘
         │
    [ n8n ]  [ Homarr ]  [ Code Server ]  [ Open WebUI ]  [ Mailserver ]
         │
    [ Observability Stack ]
    Prometheus · Grafana · Loki · Jaeger · Alertmanager
```

---

## 📚 Documentation

### 🛠️ Operations
- 📖 [Homelab Operations Runbook](docs/homelab-operations-runbook.md)
- ✅ [Operations Checklist](docs/operations-checklist.md)
- 🏛️ [Homelab Architecture](docs/homelab-architecture.md)

### 🔒 Security & Reliability
- 🧪 [Chaos Engineering](docs/chaos-engineering.md)
- 🛡️ [Week 2 Reliability Hardening](docs/week2-reliability-hardening.md)

### 🔧 Automation & CI/CD
- 🛠️ [Week 1 Automation Foundation](docs/week1-automation-foundation.md)
- 🗺️ [Week 2-4 Roadmap](docs/week2-4-roadmap.md)
- 🎭 [Backstage Dev Portal Guide](docs/backstage-dev-portal.md)
- 📋 [Backstage Service Catalog Design](docs/backstage-cortex-inspired-portal.md)

### 💾 Backup & Disaster Recovery
- 📦 [Backup System Guide](docs/backup/backup-guide.md)
- 🖥️ [Pi + Mac Backup Targets Setup](docs/backup/pi-mac-setup.md)
- 🔄 [Complete Rebuild Specification](docs/rebuild/README.md)
- 🤖 [AI Agent Rebuild Guide](docs/rebuild/AGENT.md)
- 🧩 [Per-Service Rebuild Steps](docs/rebuild/SERVICES.md)
- 🔑 [Secrets Recovery Guide](docs/rebuild/SECRETS.md)

---

## 🔧 Key Scripts

### Health & Integrity
```bash
bash scripts/service-integrity-check.sh      # Full system integrity check
bash scripts/health-check.sh                # Container health snapshot
bash scripts/config-drift-check.sh          # Repo vs live config drift
bash scripts/config-drift-check.sh baseline # Set drift baseline
```

### Automation
```bash
bash scripts/autonomous/overnight-agent-runner.sh  # Run all overnight agents
bash scripts/autonomous/install-cron.sh             # Install overnight schedule
```

### CI/CD & DevOps
```bash
bash scripts/ci-preflight.sh                # Pre-commit checks
bash scripts/vm-deploy-orchestrator.sh     # VM provisioning
```

### Chaos Engineering
```bash
bash scripts/chaos/chaosctl.sh             # Chaos control CLI
bash scripts/chaos/install-grafana-reporting-dashboard.sh  # Install dashboard
bash scripts/chaos/install-weekly-drill.sh              # Schedule weekly drill
```

---

## 💾 Backup System

**Automated nightly backups** with 3-layer redundancy:

- 🔐 Encrypted tarballs (GPG) of all configs + secrets
- ☁️ GitHub mirror push on every change
- 🏠 Raspberry Pi sync (LAN, always-on)
- 💻 MacBook sync (LAN, secondary)

```bash
BACKUP_PASSPHRASE="your-passphrase" bash scripts/backup/backup-runner.sh
BACKUP_PASSPHRASE="your-passphrase" bash scripts/backup/restore.sh ~/backups/homelab-backup-YYYYMMDD-HHMMSS.tar.gz.gpg
```

Full backup docs: [docs/backup/backup-guide.md](docs/backup/backup-guide.md)

---

## 🧪 Testing & Quality

- 🌙 **Overnight Autonomous Agents** — integrity, drift, health, TLS monitoring
- 🤖 **GitHub Actions** — automated verification
- 🌪️ **Chaos Engineering** — weekly drills
- 🧬 **Mutation Testing** — test suite effectiveness (optional)

---

## 🗂️ Repository Structure

```
homelab/
├── BOOTSTRAP.sh              # One-shot VM rebuild script
├── .env-template/            # Templates for 14 service envs
├── traefik/                  # Reverse proxy + TLS
├── authelia/                 # SSO provider
├── gitea/                    # Git hosting
├── act-runner/               # CI/CD runner
├── observability/            # Metrics, logs, traces, alerts
│   └── grafana-provisioning/ # Dashboards + datasources
├── backstage/                # Developer portal
│   └── catalog/              # Backstage entity catalog
├── goalert/                  # On-call alerting
├── n8n/                      # Workflow automation
│   └── workflows/            # n8n workflow JSONs
├── vaultwarden/              # Password manager
├── code-server/              # Cloud IDE
├── mailserver/               # Email server
├── homarr/                   # Dashboard (appdata + config)
├── chat-ui/                  # Open WebUI (AI chat)
├── ai-gateway/               # LiteLLM AI gateway
├── scripts/                  # Operational scripts
│   ├── autonomous/           # Overnight agent system
│   ├── backup/               # Backup + restore
│   └── chaos/               # Chaos engineering tools
├── docs/                     # Documentation
│   ├── rebuild/              # Disaster recovery
│   ├── backup/               # Backup system docs
│   └── chaos-reports/       # Weekly chaos drill reports
└── .github/
    └── workflows/            # GitHub Actions workflows
```

---

## 🛠️ Tech Stack

| Category | Technologies |
|----------|--------------|
| **OS** | Ubuntu 22.04 LTS |
| **Containers** | Docker + Docker Compose |
| **Proxy** | Traefik v3 |
| **TLS** | Let's Encrypt (Cloudflare DNS-01) |
| **SSO** | Authelia |
| **Git** | Gitea |
| **CI/CD** | Act Runner |
| **Monitoring** | Prometheus + Grafana |
| **Logging** | Loki + Promtail |
| **Tracing** | Jaeger |
| **Alerting** | Alertmanager + Goalert |
| **Dev Portal** | Backstage |
| **Automation** | n8n |
| **Secrets** | Vaultwarden |
| **IDE** | Code Server |
| **AI** | Open WebUI + LiteLLM |
| **Email** | Docker Mailserver |
| **Dashboard** | Homarr |

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📄 License

MIT © [amonkarsidhant](https://github.com/amonkarsidhant)

---

## 📞 Support

- **GitHub Issues**: [github.com/amonkarsidhant/homelab/issues](https://github.com/amonkarsidhant/homelab/issues)
- **Gitea (internal)**: [gitea.homelabdev.space](https://gitea.homelabdev.space)
- **Documentation**: [`docs/`](docs/)

---

## 🙏 Acknowledgments

Built with amazing open-source software and run on an Azure VM. Special thanks to the Traefik, Authelia, Gitea, n8n, Backstage, and Open WebUI communities.
