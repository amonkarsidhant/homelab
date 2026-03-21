# Per-Service Rebuild Steps

## 1. Traefik (Reverse Proxy + TLS)

Traefik is the foundation — all services route through it.

```bash
cd ~/homelab/traefik

# Set Cloudflare API token
export CF_API_TOKEN="your_cloudflare_dns_token"

# Create data directory
sudo mkdir -p /mnt/data/traefik /mnt/data/traefik/certs
sudo chown -R $(id -u):$(id -g) /mnt/data/traefik

# Generate acme.json (required for Let's Encrypt)
touch /mnt/data/traefik/acme.json
chmod 600 /mnt/data/traefik/acme.json

# Copy env
cp .env.example .env 2>/dev/null || true
# Edit .env and set CF_API_TOKEN

# Start
docker compose up -d

# Verify
docker ps --filter name=traefik
curl -sI https://home.homelabdev.space | head -5
```

### Traefik Key Files
- `docker-compose.yml` — main service definition
- `traefik.yml` — static config (entrypoints, certificates)
- `dynamic/dynamic.yml` — dynamic routing (add new services here)

### Common Issues
- **ACME not working**: Check `CF_API_TOKEN` has DNS edit permission
- **Port 80/443 busy**: `sudo lsof -i :80` to find conflicting process

---

## 2. Authelia (SSO Provider)

Authelia protects all other services. Must be running before any protected service.

```bash
cd ~/homelab/authelia

# Generate secrets (run these):
openssl rand -hex 32  # AUTHELIA_JWT_SECRET
openssl rand -hex 32  # AUTHELIA_SESSION_SECRET
openssl rand -hex 32  # AUTHELIA_STORAGE_ENCRYPTION_KEY

# Create config directory
sudo mkdir -p /mnt/data/authelia
sudo chown -R $(id -u):$(id -g) /mnt/data/authelia

# Copy and edit config
cp config.yml.example config.yml
# Edit config.yml with your domains and users

# Start
docker compose up -d

# Verify
curl -sI https://auth.homelabdev.space | head -5
```

### Authelia Key Files
- `config.yml` — main config (users, domains, session)
- `docker-compose.yml` — service definition

---

## 3. Gitea (Git Hosting)

```bash
cd ~/homelab/gitea

# Create data directory
sudo mkdir -p /mnt/data/gitea
sudo chown -R 1000:1000 /mnt/data/gitea

# Set timezone
sudo ln -sf /etc/timezone /mnt/data/gitea/timezone 2>/dev/null || true
sudo ln -sf /etc/localtime /mnt/data/gitea/localtime 2>/dev/null || true

# Start
docker compose up -d

# First-run setup
# Visit https://gitea.homelabdev.space
# Use SQLite for simplicity
# Admin user: set during first-run web UI
```

### Gitea Key Files
- `docker-compose.yml` — service definition
- SQLite DB at `/mnt/data/gitea/gitea.db`

---

## 4. Act Runner (CI/CD)

```bash
cd ~/homelab/act-runner

# Get runner token from Gitea:
# Settings → Runner → New Runner → copy registration token

export GITEA_RUNNER_REGISTRATION_TOKEN="your_token_here"

# Create data directory
sudo mkdir -p /mnt/data/act-runner
sudo chown -R $(id -u):$(id -g) /mnt/data/act-runner

# Create .env with token
echo "GITEA_RUNNER_REGISTRATION_TOKEN=$GITEA_RUNNER_REGISTRATION_TOKEN" > .env

# Start
docker compose up -d

# Verify in Gitea: Settings → Runner → should show "homelab-runner" online
```

---

## 5. Observability Stack

```bash
cd ~/homelab/observability

# Create directories
sudo mkdir -p /mnt/data/{prometheus,grafana,loki,jaeger,alertmanager}
sudo chown -R $(id -u):$(id -g) /mnt/data/prometheus /mnt/data/grafana /mnt/data/loki /mnt/data/jaeger /mnt/data/alertmanager

# Grafana default credentials
# User: admin
# Password: admin (change after first login)
# URL: https://observability.homelabdev.space

# Start all observability services
docker compose up -d prometheus
docker compose up -d grafana
docker compose up -d loki
docker compose up -d jaeger
docker compose up -d alertmanager
docker compose up -d promtail

# Or all at once
docker compose up -d

# Verify
curl -sI https://observability.homelabdev.space | head -5
```

### Key Services
- **Prometheus** — metrics collection (`/etc/prometheus/prometheus.yml`)
- **Grafana** — dashboards (`/var/lib/grafana`)
- **Loki** — log aggregation (`/loki`)
- **Jaeger** — distributed tracing (`/tmp/jaeger`)
- **Alertmanager** — alerting (`/etc/alertmanager/alertmanager.yml`)
- **Promtail** — log scraping (`/etc/promtail/promtail.yml`)

---

## 6. Backstage (Dev Portal)

```bash
cd ~/homelab/backstage

# Create postgres directory
sudo mkdir -p /mnt/data/backstage-postgres
sudo chown -R 70:70 /mnt/data/backstage-postgres 2>/dev/null || true

# Set secrets
export POSTGRES_PASSWORD="your_secure_password"
export BACKEND_SECRET="your_backend_secret"

# Create .env
cat > .env << 'EOF'
POSTGRES_USER=backstage
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=backstage
NODE_ENV=production
POSTGRES_HOST=backstage-postgres
POSTGRES_PORT=5432
BACKEND_SECRET=${BACKEND_SECRET}
EOF

# Start postgres first
docker compose up -d backstage-postgres
sleep 10

# Start backstage
docker compose up -d backstage

# Verify
curl -sI https://backstage.homelabdev.space | head -5
```

---

## 7. Goalert (On-Call Alerting)

```bash
cd ~/homelab/goalert

# Create postgres directory
sudo mkdir -p /mnt/data/goalert-postgres
sudo chown -R 70:70 /mnt/data/goalert-postgres 2>/dev/null || true

# Start
docker compose up -d goalert-postgres
sleep 5
docker compose up -d goalert

# First-run: visit https://goalert.homelabdev.space
# Create admin user during setup
```

---

## 8. n8n (Workflow Automation)

```bash
cd ~/homelab/n8n

# Create workflow directory
mkdir -p ~/homelab/n8n/workflows

# Start
docker compose up -d

# First-run: visit https://ai.homelabdev.space
# Create admin account

# Import workflows (after n8n is up):
# n8n UI → Settings → Import → select JSON files from workflows/
```

### n8n Workflows Included
- `01-homelab-ops-alerts.json` — homelab ops alerts
- `02-scheduled-backups.json` — scheduled backup trigger
- `03-daily-status-report.json` — daily status reporting
- `04-gitops-automation.json` — gitops sync automation

---

## 9. Vaultwarden (Password Manager)

```bash
cd ~/homelab/vaultwarden

# Create data directory
sudo mkdir -p /mnt/data/vaultwarden
sudo chown -R $(id -u):$(id -g) /mnt/data/vaultwarden

# Set SMTP env vars (for invite emails):
export SMTP_HOST="smtp.mailgun.org"
export SMTP_PORT="587"
export SMTP_USERNAME="postmaster@homelabdev.space"
export SMTP_PASSWORD="your_smtp_password"

# Create .env with all vars
# Edit .env and set:
# - DOMAIN=https://vault.homelabdev.space
# - SIGNUPS_ALLOWED=false (after first admin is created)
# - SMTP_* vars

# Start
docker compose up -d

# Verify
curl -sI https://vault.homelabdev.space | head -5

# First admin: visit vault.homelabdev.space/setup to create admin
```

---

## 10. Code Server (Cloud IDE)

```bash
cd ~/homelab/code-server

# Set password
export CODE_SERVER_PASSWORD="your_code_server_password"

# Create config directory
mkdir -p ~/.config/code-server
mkdir -p ~/homelab  # project directory

# Create .env
echo "PASSWORD=${CODE_SERVER_PASSWORD}" > .env

# Start
docker compose up -d

# Access: https://code.homelabdev.space
# Default password: set in CODE_SERVER_PASSWORD
```

---

## 11. Mailserver

```bash
cd ~/homelab/mailserver

# Create directories
sudo mkdir -p /mnt/data/mailserver /mnt/data/mailserver/config
sudo chown -R $(id -u):$(id -g) /mnt/data/mailserver

# Set SMTP relay credentials
export SMTP_RELAY_USER="postmaster@homelabdev.space"
export SMTP_RELAY_PASSWORD="your_smtp_password"

# Create .env
cat > .env << 'EOF'
HOSTNAME=mail
DOMAINNAME=homelabdev.space
SSL=letsencrypt
ENABLE_QUOTAS=1
PERMIT_DOCKER=host
TLS_LEVEL=modern
SMTP_RELAY_HOST=smtp.mailgun.org
SMTP_RELAY_PORT=587
SMTP_RELAY_USER=${SMTP_RELAY_USER}
SMTP_RELAY_PASSWORD=${SMTP_RELAY_PASSWORD}
EOF

# Start
docker compose up -d

# Check logs
docker logs mailserver --tail 20
```

---

## 12. Homarr (Dashboard)

```bash
cd ~/homelab/homarr

# Create appdata directory
sudo mkdir -p /mnt/data/homarr
sudo chown -R $(id -u):$(id -g) /mnt/data/homarr

# Copy appdata if restoring from backup
# If fresh: docker will create empty DB
# After first start: visit https://home.homelabdev.space and complete onboarding

# Start
docker compose up -d

# Verify
curl -sI https://home.homelabdev.space | head -5
```

### Homarr Post-Setup
1. Visit `https://home.homelabdev.space/setup`
2. Create admin account
3. Import board from `homarr/appdata/` if restoring
4. Add service tiles

---

## 13. Chat UI (Open WebUI + LiteLLM)

```bash
cd ~/homelab/chat-ui

# Create data directory
sudo mkdir -p /mnt/data/open-webui
sudo chown -R $(id -u):$(id -g) /mnt/data/open-webui

# Set Ollama Cloud API key
export OLLAMA_API_KEY="your_ollama_cloud_key"

# Create .env
cat > .env << 'EOF'
OLLAMA_API_KEY=${OLLAMA_API_KEY}
WEBUI_URL=https://chat.homelabdev.space
EOF

# Start
docker compose up -d

# Verify
curl -sI https://chat.homelabdev.space | head -5

# First login: visit https://chat.homelabdev.space
# Create account, then login
```

---

## 14. AI Gateway (LiteLLM)

```bash
cd ~/homelab/ai-gateway

# Copy config
cp config.yaml.example config.yaml 2>/dev/null || true
# Edit config.yaml if custom models needed

# Start
docker compose up -d

# Verify
curl -s http://localhost:4000/v1/models | python3 -m json.tool | head -20
```

---

## Quick Verification Checklist

```bash
# All containers
docker ps --format "table {{.Names}}\t{{.Status}}"

# All HTTPS endpoints
for host in home auth gitea vault ai backstage goalert code chat mail observability; do
  echo -n "$host: "
  curl -sI -o /dev/null -w "%{http_code}" https://${host}.homelabdev.space 2>/dev/null || echo "FAIL"
done

# Run full integrity check
bash ~/homelab/scripts/service-integrity-check.sh
```
