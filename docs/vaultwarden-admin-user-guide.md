# Vaultwarden Guide (Admin + User)

This guide explains how to use your self-hosted Vaultwarden securely as an admin and as a normal user.

## URLs
- Vault app: `https://vault.homelabdev.space`
- Admin panel: `https://vault.homelabdev.space/admin`

## Architecture Notes
- Vaultwarden runs in Docker (`vaultwarden` container).
- Data is stored at `/mnt/data/vaultwarden`.
- Traffic is routed via Traefik and protected by Authelia.
- Admin token is mounted from `/home/sidhant/vaultwarden/admin_token`.

## Admin Guide

### 1) First Admin Login
1. Open `https://vault.homelabdev.space/admin`.
2. Enter the `ADMIN_TOKEN` from your secrets store.
3. Confirm server settings:
   - `SIGNUPS_ALLOWED=false` (already set)
   - HTTPS domain is correct (`vault.homelabdev.space`).

### 2) User Onboarding Strategy
Because signups are disabled, choose one onboarding method:

- Recommended (controlled):
  1. Temporarily set `SIGNUPS_ALLOWED=true`.
  2. Restart container: `cd /home/sidhant/vaultwarden && docker-compose up -d`.
  3. Have users create accounts.
  4. Set `SIGNUPS_ALLOWED=false` again and restart.

- Alternative:
  - Keep signups off and use organization invites only for existing accounts.

### 3) Organization Setup (Team Secrets)
1. Login to Vaultwarden as admin user (normal UI, not admin panel).
2. Create an organization (e.g. `Homelab Team`).
3. Create collections by scope:
   - `Infra`
   - `CI/CD`
   - `Ops`
   - `Mail`
4. Invite users and assign least privilege:
   - Read-only where possible.
   - Write/admin only for maintainers.

### 4) Store Infrastructure Secrets
Store these as secure items (already prepared/imported):
- Cloudflare API token
- Grafana admin credentials
- MinIO root credentials
- code-server credentials
- Mail relay credentials
- Gitea runner token
- Authelia secrets
- Vaultwarden admin token

### 5) Security Hardening (Admin)
- Enable 2FA for all admin-capable users.
- Use a unique long master password for each account.
- Rotate high-risk secrets regularly:
  - Cloudflare API token
  - SMTP relay password
  - CI runner token
- Keep Vaultwarden and Traefik containers updated.
- Never store plaintext secrets in git-tracked files.

### 6) Backup and Restore
- Primary data path: `/mnt/data/vaultwarden`.
- Include this path in your backup pipeline.
- Validate restore in a test container before disaster.

Quick backup check:
```bash
ls -la /mnt/data/vaultwarden
```

### 7) Operational Commands
Restart Vaultwarden:
```bash
cd /home/sidhant/vaultwarden && docker-compose up -d
```

View logs:
```bash
docker logs vaultwarden --tail 100
```

Check status:
```bash
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep vaultwarden
```

## User Guide

### 1) Login
1. Go to `https://vault.homelabdev.space`.
2. Authenticate via Authelia if prompted.
3. Sign in with your Vaultwarden account.

### 2) Create Secure Vault Entries
For each login item:
- Use generated password (>= 20 chars).
- Add URI and username.
- Add notes for recovery context.
- Add item to correct folder/collection.

### 3) Browser and Device Setup
- Install Bitwarden browser extension.
- Point to self-hosted server URL if needed:
  - `https://vault.homelabdev.space`
- Enable vault lock timeout and biometrics/device PIN.

### 4) Enable 2FA (Strongly Recommended)
- Open account security settings.
- Enable TOTP with authenticator app.
- Save recovery code in a secure offline location.

### 5) Personal Security Rules
- Never share master password.
- Never store secrets in chat, docs, or repo files.
- Use unique passwords for every service.
- Rotate passwords after any suspicion of leak.

## Team Process Recommendation
- All new secrets go into Vaultwarden first.
- Runtime `.env` files are generated from Vaultwarden entries.
- Remove plaintext secret files after confirming import.
- Review secret rotation monthly.

## Troubleshooting

Vault UI not loading:
```bash
docker logs traefik --tail 100
docker logs vaultwarden --tail 100
```

Admin panel token rejected:
- Verify token in `/home/sidhant/vaultwarden/admin_token`.
- Restart container after token change.

Authelia redirect loops:
- Check `auth.homelabdev.space` availability.
- Check Traefik dynamic config route for `vault.homelabdev.space`.

---
Last updated: 2026-03-06
