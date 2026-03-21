# Quick Start

Get up and running with the homelab in under 5 minutes.

## Prerequisites

- Ubuntu 22.04 LTS VM (Azure or local)
- Docker + Docker Compose installed
- Git access

## 1. Clone the Repository

```bash
git clone https://github.com/amonkarsidhant/homelab.git ~/homelab
cd ~/homelab
```

## 2. Check Service Health

```bash
bash scripts/service-integrity-check.sh
```

## 3. Set Up Secrets

```bash
# Copy env templates
cp .env-template/*.env ~/.config/homelab/

# Edit with your values (see docs/rebuild/SECRETS.md)
nano ~/.config/homelab/traefik.env
```

## 4. Start Services

```bash
# Core services first
cd ~/homelab/traefik && docker compose up -d
cd ~/homelab/authelia && docker compose up -d

# Then the rest
cd ~/homelab && for svc in */; do
  [ -f "$svc/docker-compose.yml" ] && (cd "$svc" && docker compose up -d)
done
```

## 5. Verify Everything is Running

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## 6. Access Services

| Service | URL |
|---------|-----|
| Dashboard | https://home.homelabdev.space |
| Auth | https://auth.homelabdev.space |
| Gitea | https://gitea.homelabdev.space |
| Grafana | https://observability.homelabdev.space |
| AI Chat | https://chat.homelabdev.space |
| Vault | https://vault.homelabdev.space |

## Next Steps

- [Set up the backup system](backup/backup-guide.md)
- [Read the operations runbook](homelab-operations-runbook.md)
- [Configure TLS certificates](docs/rebuild/SERVICES.md)
