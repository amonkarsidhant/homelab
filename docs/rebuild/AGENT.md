# AI Agent Rebuild Guide

> You are an AI assistant helping rebuild a homelab from a blank Ubuntu 22.04 VM using only the files in this repository.

## Your Mission

Rebuild `https://github.com/amonkarsidhant/homelab` on a fresh Azure Ubuntu 22.04 VM — identical to how it runs today.

## Rules

1. **Read all docs first** — Before touching anything, read `REBUILD.md`, this file, and `SERVICES.md`
2. **Never skip steps** — Follow the dependency order strictly
3. **Verify each step** — Run health checks after each service
4. **Report deviations** — If something doesn't match the spec, say so
5. **Ask for secrets** — If a required secret is missing, say exactly which one

## Phase 1: Environment Audit

Run these first:

```bash
# Check Ubuntu version
cat /etc/os-release

# Check Docker
docker --version
docker compose version

# Check disk space
df -h

# Check memory
free -h

# Check CPU
nproc

# Check existing services
docker ps -a
```

## Phase 2: Base Setup

### Install dependencies
```bash
# Docker (if not present)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Docker Compose v2
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# Git (should be present)
sudo apt-get install -y git

# GPG (for backup encryption)
sudo apt-get install -y gnupg

# rsync (for backups)
sudo apt-get install -y rsync

# curl (should be present)
sudo apt-get install -y curl
```

### Clone the repo
```bash
git clone https://github.com/amonkarsidhant/homelab.git ~/homelab
cd ~/homelab
```

## Phase 3: Secrets Setup

```bash
# Copy env template
cp -r .env-template ~/homelab/.env

# List all required secrets
# See SECRETS.md for full instructions
# The agent should ask the user for:
# - CF_API_TOKEN (Cloudflare DNS)
# - All AUTHELIA_* secrets
# - SMTP credentials
# - Database passwords
# - BACKUP_PASSPHRASE
```

## Phase 4: Directory Setup

```bash
# Create all required data directories
sudo mkdir -p /mnt/data/{traefik,prometheus,grafana,loki,jaeger,minio,gitea,act-runner,backstage-postgres,goalert-postgres,vaultwarden,authelia,mailserver}

# Set ownership
sudo chown -R $(id -u):$(id -g) /mnt/data

# Create home config dir
mkdir -p ~/.config/homelab
```

## Phase 5: Service Bootstrap

Follow the order in `SERVICES.md`. After each service:

```bash
docker compose up -d <service>
sleep 5
docker ps --filter name=<service>
curl -sI https://<service>.homelabdev.space | head -3
```

## Phase 6: Final Verification

```bash
# Run integrity check
bash ~/homelab/scripts/service-integrity-check.sh

# Check all containers
docker ps --format "table {{.Names}}\t{{.Status}}"

# Test HTTPS on all subdomains
for host in home auth gitea vault ai backstage goalert code chat mail; do
  curl -sI https://${host}.homelabdev.space | head -2
done
```

## Important Notes

- **Traefik must be first** — all other services route through it
- **Authelia must be second** — it provides SSO for all protected services
- **Cloudflare DNS** must be configured manually — CF_API_TOKEN is required
- **Let's Encrypt** issues certs automatically once CF_API_TOKEN is set
- **Volumes are critical** — without `/mnt/data/*` volumes, services will be fresh installs
- **n8n workflows** must be imported manually after n8n is up

## If Something Goes Wrong

1. Check the container logs: `docker logs <container-name> --tail 50`
2. Check Traefik logs: `docker logs traefik --tail 50`
3. Verify the compose file is correct: `docker compose config`
4. Check cert status: `docker exec traefik ls /mnt/data/traefik/acme.json`
5. Common issue: missing env vars — verify `~/.config/homelab/` has all required files
