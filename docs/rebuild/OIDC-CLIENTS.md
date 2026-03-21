# OIDC Client Secrets — Template

> **CONFIDENTIAL — Copy this to `~/.config/homelab/oidc-secrets.env` and fill in real values.**
> See `docs/rebuild/SECRETS.md` for how to generate secrets.

| Service | Client ID | Client Secret |
|---------|-----------|--------------|
| Gitea | `gitea` | `REPLACEME_GITEA_SECRET` |
| Grafana | `grafana` | `REPLACEME_GRAFANA_SECRET` |
| Backstage | `backstage` | `REPLACEME_BACKSTAGE_SECRET` |
| n8n | `n8n` | `REPLACEME_N8N_SECRET` |
| Vaultwarden | `vaultwarden` | `REPLACEME_VAULTWARDEN_SECRET` |
| Homarr | `homarr` | `REPLACEME_HOMARR_SECRET` |
| Goalert | `goalert` | `REPLACEME_GOALERT_SECRET` |

## Authelia Core Secrets

| Secret | Value |
|--------|-------|
| `session.secret` | `REPLACEME_SESSION_SECRET` |
| `storage.encryption_key` | `REPLACEME_STORAGE_KEY` |

## How to Configure Each Service

### Grafana
1. Login as admin → **Configuration → Authentication → Authelia**
2. Enable Authelia OIDC
3. Use Client ID: `grafana`, Client Secret from `~/.config/homelab/oidc-secrets.env`

### Gitea
1. **Site Admin → Authentication → Add Source → OpenID Connect**
2. Use Client ID: `gitea`, Client Secret from secrets file

### Backstage
Add to `app-config.yaml`:
```yaml
auth:
  providers:
    oidc:
      development:
        clientId: backstage
        clientSecret: ${AUTHELIA_BACKSTAGE_SECRET}
        issuer: https://auth.homelabdev.space
```

### n8n
**Settings → NDV → OAuth2 API** → configure with Client ID and secret

### Vaultwarden
**Admin Panel → Security → Two-Factor → OIDC** → enable and configure

### Homarr
**Settings → User Management → OAuth** → configure with discovery URL

### Goalert
**Settings → Authentication → OIDC** → configure with issuer URL

See `OIDC-CLIENTS.md` (private, stored separately) for actual secrets.
