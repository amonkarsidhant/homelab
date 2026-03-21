# Homelab Complete Rebuild Specification

> **If the Azure VM is destroyed, a single AI agent with access to this repository can rebuild the entire homelab from a blank Ubuntu 22.04 VM in ~2-3 hours.**

---

## Repository Structure

```
homelab/
├── README.md                      ← Start here (you are here)
├── REBUILD.md                    ← This file (agent rebuild bible)
├── BOOTSTRAP.sh                  ← Master bootstrap script
├── .env-template/                 ← All service env vars (no real secrets)
├── docs/rebuild/
│   ├── AGENT.md                  ← Instructions for the AI agent
│   ├── SERVICES.md               ← Per-service rebuild steps
│   └── SECRETS.md                ← Secrets recovery guide
├── scripts/
│   ├── bootstrap/                ← Individual setup scripts
│   └── autonomous/               ← Overnight agents (already in repo)
├── traefik/                      ← Reverse proxy + TLS
├── authelia/                     ← SSO/auth
├── gitea/                        ← Git hosting
├── act-runner/                   ← CI/CD runner
├── observability/                ← Prometheus, Grafana, Loki, Jaeger, Alertmanager
├── backstage/                    ← Dev portal
├── goalert/                      ← Alerting/on-call
├── n8n/                          ← Workflow automation
├── vaultwarden/                  ← Password manager
├── code-server/                  ← Cloud IDE
├── mailserver/                  ← Email server
├── homarr/                       ← Dashboard
├── chat-ui/                      ← Open WebUI (AI chat)
├── ai-gateway/                   ← LiteLLM gateway
└── observability/grafana-provisioning/  ← Pre-built dashboards
```

---

## The 4-Phase Rebuild

### Phase 1 — Base VM Setup (Manual, ~10 min)
1. Spin up Ubuntu 22.04 LTS on Azure
2. SSH in as a sudo user
3. Run: `curl -fsSL https://get.docker.com | sh`
4. Clone repo: `git clone https://github.com/amonkarsidhant/homelab.git ~/homelab`

### Phase 2 — Secrets Provisioning (~5 min)
1. Copy `.env-template/` to `~/homelab/.env/`
2. Fill in real values (see `docs/rebuild/SECRETS.md`)
3. Restore Vaultwarden + Authelia volumes from backup if available

### Phase 3 — Bootstrap (~15 min)
```bash
cd ~/homelab
bash BOOTSTRAP.sh
```
This script will:
- Install all dependencies (Docker Compose v2, Traefik, Tailscale, GPG)
- Create all required directories and set permissions
- Generate self-signed certs for local dev (optional)
- Spin up services in dependency order

### Phase 4 — Agent Verification (~30 min)
The AI agent reads `docs/rebuild/AGENT.md` and executes:
- Verifies all containers are healthy
- Checks DNS/SSL for all subdomains
- Runs `scripts/service-integrity-check.sh`
- Confirms access to all endpoints

---

## Service Dependency Order

```
1.  traefik        (reverse proxy, must be first)
2.  authelia       (SSO provider, needed by all others)
3.  minio          (S3-compatible object storage)
4.  observability   (prometheus, grafana, loki — monitoring)
5.  gitea          (git hosting)
6.  act-runner     (CI/CD runner, depends on gitea)
7.  backstage      (dev portal)
8.  goalert        (on-call alerting)
9.  n8n            (workflow automation)
10. vaultwarden    (password manager)
11. code-server    (cloud IDE)
12. mailserver     (email)
13. homarr         (dashboard)
14. chat-ui        (AI chat, depends on ai-gateway)
15. ai-gateway     (LiteLLM, depends on n8n for workflows)
```

---

## Domain Map

| Subdomain | Service | Authelia Protected |
|-----------|---------|-------------------|
| home.homelabdev.space | Homarr | Yes |
| auth.homelabdev.space | Authelia | No |
| gitea.homelabdev.space | Gitea | Yes |
| vault.homelabdev.space | Vaultwarden | Yes |
| ai.homelabdev.space | n8n | Yes |
| backstage.homelabdev.space | Backstage | Yes |
| goalert.homelabdev.space | Goalert | Yes |
| code.homelabdev.space | Code Server | Yes |
| chat.homelabdev.space | Open WebUI | Yes |
| mail.homelabdev.space | Mailserver | No |
| observability.homelabdev.space | Grafana | Yes |

---

## Critical Data (not in git, must restore from backup)

| Data | Location | How to Restore |
|------|----------|---------------|
| Vaultwarden vault | `/mnt/data/vaultwarden` | Decrypt from `homelab-backup-*.tar.gz.gpg` |
| Authelia config + users | `/mnt/data/authelia` | Decrypt from backup |
| Gitea repositories | `/mnt/data/gitea` | rsync from Pi/Mac backup |
| Prometheus metrics | `/mnt/data/prometheus` | rsync from backup |
| n8n workflows | `/mnt/data/docker/volumes/n8n_data` | rsync from backup |
| Homarr DB + icons | `/mnt/data/homarr` | rsync from backup |
| Ollama models | `/mnt/data/ollama` | Re-download (large) |

---

## Secrets Required (see SECRETS.md)

| Secret | Purpose |
|--------|---------|
| `CF_API_TOKEN` | Cloudflare DNS for Let's Encrypt |
| `AUTHELIA_JWT_SECRET` | Authelia JWT signing |
| `AUTHELIA_SESSION_SECRET` | Authelia session encryption |
| `AUTHELIA_STORAGE_ENCRYPTION_KEY` | Authelia DB encryption |
| `GITEA_RUNNER_REGISTRATION_TOKEN` | Act Runner → Gitea auth |
| `POSTGRES_PASSWORD` | Backstage + Goalert DB |
| `BACKEND_SECRET` | Backstage auth |
| `SMTP_*` | Vaultwarden email + Mailserver relay |
| `MINIO_ROOT_PASSWORD` | S3 storage |
| `CODE_SERVER_PASSWORD` | Code Server access |
| `OLLAMA_API_KEY` | Open WebUI → Ollama Cloud |
| `BACKUP_PASSPHRASE` | Decrypt backup archives |

---

## How to Trigger a Rebuild

### As a human:
1. Spin up a fresh Ubuntu 22.04 VM
2. `git clone https://github.com/amonkarsidhant/homelab.git`
3. Read `REBUILD.md` and follow steps

### As an AI agent:
1. Read `docs/rebuild/AGENT.md`
2. Follow the phase-by-phase checklist
3. Use `scripts/bootstrap/*.sh` for automated setup
4. Report any deviations from expected state
