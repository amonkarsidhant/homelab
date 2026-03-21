# Environment Templates

This directory contains `.env` templates for each service. Copy these to your VM and fill in real values.

## Quick Setup

```bash
# Copy all templates to ~/.config/homelab/
mkdir -p ~/.config/homelab/
cp *.env ~/.config/homelab/

# Edit each file with real values
nano ~/.config/homelab/traefik.env
nano ~/.config/homelab/authelia.env
# ... etc
```

## Template Breakdown

| File | Required Secrets |
|------|-----------------|
| `traefik.env` | `CF_API_TOKEN` |
| `authelia.env` | `AUTHELIA_JWT_SECRET`, `AUTHELIA_SESSION_SECRET`, `AUTHELIA_STORAGE_ENCRYPTION_KEY` |
| `gitea.env` | (usually defaults work) |
| `act-runner.env` | `GITEA_RUNNER_REGISTRATION_TOKEN` |
| `observability.env` | `GF_SECURITY_ADMIN_PASSWORD` |
| `backstage.env` | `POSTGRES_PASSWORD`, `BACKEND_SECRET` |
| `goalert.env` | (usually defaults work) |
| `vaultwarden.env` | `SMTP_*` vars |
| `code-server.env` | `CODE_SERVER_PASSWORD` |
| `mailserver.env` | `SMTP_RELAY_USER`, `SMTP_RELAY_PASSWORD` |
| `n8n.env` | `WEBHOOK_URL` (usually pre-set) |
| `chat-ui.env` | `OLLAMA_API_KEY` |
| `ai-gateway.env` | (usually defaults work) |

See `docs/rebuild/SECRETS.md` for how to generate each secret.
