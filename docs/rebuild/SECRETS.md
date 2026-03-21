# Secrets Recovery Guide

> All secrets must be filled before services will start properly. Use this guide to collect each one.

---

## How to Find Secrets

### Option A: From Existing VM (if still accessible)
```bash
# List all .env files
find /home/sidhant -name ".env" -exec grep -h '=' {} \; 2>/dev/null

# Individual secrets
cat /home/sidhant/traefik/.env
cat /home/sidhant/authelia/.env
cat /home/sidhant/vaultwarden/.env
```

### Option B: From Encrypted Backup
```bash
# List available backups
ls ~/backups/

# Decrypt and inspect
BACKUP_PASSPHRASE="your_passphrase" \
  ~/homelab/scripts/backup/restore.sh \
  ~/backups/homelab-backup-YYYYMMDD-HHMMSS.tar.gz.gpg
```

### Option C: Generate Fresh (services will need reconfiguration)
```bash
# Generate random secrets
openssl rand -hex 32   # For most secrets
openssl rand -base64 32  # Alternative
```

---

## Secrets Checklist

Copy this and fill in each value:

| Secret | Where Used | How to Get | Status |
|--------|-----------|------------|--------|
| `CF_API_TOKEN` | Traefik | Cloudflare Dashboard → My Profile → API Tokens → Create DNS token with Zone:Edit | ☐ |
| `AUTHELIA_JWT_SECRET` | Authelia | `openssl rand -hex 32` | ☐ |
| `AUTHELIA_SESSION_SECRET` | Authelia | `openssl rand -hex 32` | ☐ |
| `AUTHELIA_STORAGE_ENCRYPTION_KEY` | Authelia | `openssl rand -hex 32` | ☐ |
| `GITEA_ADMIN_PASSWORD` | Gitea | You set this during first-run | ☐ |
| `GITEA_RUNNER_REGISTRATION_TOKEN` | Act Runner | Gitea → Settings → Runner → New Runner | ☐ |
| `POSTGRES_PASSWORD` | Backstage, Goalert | `openssl rand -hex 32` | ☐ |
| `BACKEND_SECRET` | Backstage | `openssl rand -hex 32` | ☐ |
| `MINIO_ROOT_USER` | MinIO | Default: `minioadmin` (change after first login) | ☐ |
| `MINIO_ROOT_PASSWORD` | MinIO | Set in traefik/.env | ☐ |
| `CODE_SERVER_PASSWORD` | Code Server | Your chosen password | ☐ |
| `SMTP_HOST` | Vaultwarden | `smtp.mailgun.org` (if using Mailgun) | ☐ |
| `SMTP_PORT` | Vaultwarden | `587` (STARTTLS) | ☐ |
| `SMTP_FROM` | Vaultwarden | `vault@homelabdev.space` | ☐ |
| `SMTP_FROM_NAME` | Vaultwarden | `Vaultwarden` | ☐ |
| `SMTP_USERNAME` | Vaultwarden | From SMTP provider | ☐ |
| `SMTP_PASSWORD` | Vaultwarden | From SMTP provider | ☐ |
| `SMTP_RELAY_USER` | Mailserver | From SMTP provider (Mailgun) | ☐ |
| `SMTP_RELAY_PASSWORD` | Mailserver | From SMTP provider | ☐ |
| `OLLAMA_API_KEY` | Chat UI | `https://ollama.com/settings/keys` | ☐ |
| `BACKUP_PASSPHRASE` | Backup encryption | `gpg --gen-random --armor 1 32 \| tr -dc 'a-zA-Z0-9'` | ☐ |
| `DISCORD_WEBHOOK_URL` | Alerts | Discord Server Settings → Integrations → Webhooks | ☐ |

---

## Cloudflare API Token Setup

1. Go to `https://dash.cloudflare.com`
2. My Profile → API Tokens
3. Create Custom Token:
   - Name: `homelab-lets-encrypt`
   - Account: `Edit` permission
   - Zone: `Edit` permission for `homelabdev.space`
4. Copy the token — this is your `CF_API_TOKEN`

---

## .env File Setup

Create `~/.config/homelab/secrets.env` with all filled values:

```bash
mkdir -p ~/.config/homelab

cat > ~/.config/homelab/secrets.env << 'EOF'
# Cloudflare
CF_API_TOKEN="your_cf_token_here"

# Authelia
AUTHELIA_JWT_SECRET="your_jwt_secret_here"
AUTHELIA_SESSION_SECRET="your_session_secret_here"
AUTHELIA_STORAGE_ENCRYPTION_KEY="your_storage_key_here"

# Databases
POSTGRES_PASSWORD="your_postgres_password_here"
BACKEND_SECRET="your_backend_secret_here"

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD="your_minio_password_here"

# Gitea Runner
GITEA_RUNNER_REGISTRATION_TOKEN="your_runner_token_here"

# Vaultwarden + Mailserver SMTP
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_FROM="vault@homelabdev.space"
SMTP_FROM_NAME="Vaultwarden"
SMTP_USERNAME="postmaster@homelabdev.space"
SMTP_PASSWORD="your_smtp_password_here"
SMTP_RELAY_USER="postmaster@homelabdev.space"
SMTP_RELAY_PASSWORD="your_smtp_password_here"

# Code Server
CODE_SERVER_PASSWORD="your_code_password_here"

# Ollama Cloud
OLLAMA_API_KEY="your_ollama_key_here"

# Backup
BACKUP_PASSPHRASE="your_backup_passphrase_here"

# Discord Alerts
DISCORD_WEBHOOK_URL=""
EOF
```

Then source it before running services:
```bash
source ~/.config/homelab/secrets.env
```

---

## Vaultwarden Admin Token

If you lose Vaultwarden admin access:
```bash
# Generate new admin token
docker exec vaultwarden vaultwarden generate-admin-token
```
