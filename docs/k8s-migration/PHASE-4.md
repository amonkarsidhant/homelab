# Phase 4: Migrate Application Services

## Goal
Migrate each homelab service from Docker Compose to Kubernetes, one by one, using Helm charts or raw manifests.

---

## Strategy

1. **Migrate services in order of dependency** — authelia (SSO) first, then apps
2. **Keep Docker versions running until k8s is verified** — blue/green migration
3. **Test each service in k8s before pointing DNS**
4. **Document the exact ConfigMap/Secret values used**

---

## Service Migration Order

| Order | Service | Notes |
|-------|---------|-------|
| 1 | Authelia | SSO — must work before others |
| 2 | Gitea | Git repos on PVC |
| 3 | Vaultwarden | SQLite on PVC |
| 4 | Homarr | SQLite on PVC |
| 5 | n8n | PostgreSQL backend |
| 6 | Goalert | PostgreSQL backend |
| 7 | Backstage | PostgreSQL backend |
| 8 | code-server | Project dirs on PVC |
| 9 | Open WebUI | Config on PVC |
| 10 | LiteLLM | Config on PVC |

---

## Example: Gitea Migration

### Export Gitea data from Docker

```bash
# Stop Gitea Docker
cd ~/gitea && docker compose down

# Backup git repos and DB
cp -r /mnt/data/gitea /mnt/data/gitea.bak
```

### Create Gitea Helm values

```yaml
# gitea-values.yaml
image:
  repository: gitea/gitea
  tag: "1.21"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: gitea.homelabdev.space
  tls:
    - secretName: gitea-tls
      hosts:
        - gitea.homelabdev.space

persistence:
  enabled: true
  storageClass: longhorn
  size: 20Gi

postgresql:
  enabled: true
  postgresqlDatabase: gitea
  postgresqlUsername: gitea
  persistence:
    enabled: true
    storageClass: longhorn
    size: 5Gi

config:
  server:
    DOMAIN: gitea.homelabdev.space
    ROOT_URL: https://gitea.homelabdev.space
  database:
    DB_TYPE: postgres
```

### Deploy

```bash
helm install gitea gitea/gitea \
  --namespace services \
  --create-namespace \
  --values gitea-values.yaml
```

---

## Example: Vaultwarden Migration

```yaml
# vaultwarden-values.yaml
image:
  repository: vaultwarden/server
  tag: "1.31"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: vault.homelabdev.space
  tls:
    - secretName: vaultwarden-tls
      hosts:
        - vault.homelabdev.space

persistence:
  enabled: true
  storageClass: longhorn
  size: 1Gi

env:
  SIGNUPS_ALLOWED: "false"
  WEBSOCKET_ENABLED: "true"
  SMTP_HOST: smtp.mailgun.org
  SMTP_FROM: sidhant.amonkar@homelabdev.space
```

---

## Example: Homarr Migration

```yaml
# homarr-values.yaml
image:
  repository: ghcr.io/ajnart/homarr
  tag: "latest"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: home.homelabdev.space
  tls:
    - secretName: homarr-tls
      hosts:
        - home.homelabdev.space

persistence:
  enabled: true
  storageClass: longhorn
  size: 1Gi
```

---

## Health Checks

Add readiness and liveness probes to each deployment:

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 10
  periodSeconds: 5
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10
```

---

## Resource Limits

Set reasonable resource limits per service:

```yaml
resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

---

## Next Phase

Proceed to [PHASE-5.md](./PHASE-5.md) for decommissioning Docker Compose services and cluster hardening.
