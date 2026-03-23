# Kubernetes Migration — Per-Service Guide

This document contains the detailed migration steps for each service. Always migrate in dependency order.

---

## Service Dependency Graph

```
Authelia (SSO)
    ↓
Gitea, Vaultwarden, Homarr, n8n, Goalert, Backstage, code-server, Chat UI, LiteLLM
    ↑
PostgreSQL (shared or per-service)
    ↑
Longhorn (storage)
    ↑
Traefik (ingress) + cert-manager (TLS)
    ↑
k3s cluster
```

---

## Service: Traefik (Ingress)

**Priority:** 1 (first to migrate, or keep on Docker)  
**Persistence:** Config files only  
**Migration:** Keep Docker or migrate to k8s Helm

### Option A: Keep Docker Traefik (simpler)

```bash
# Keep running as-is. In k8s, use NodePort or keep Docker.
# k8s Ingress resources will route to Docker services via ClusterIP.
```

### Option B: Migrate to k8s Helm

```bash
helm install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --values <<EOF
ingressClass:
  enabled: true
  isDefaultClass: true
  name: traefik
ports:
  web:
    port: 80
    expose: true
    exposedPort: 80
  websecure:
    port: 443
    expose: true
    exposedPort: 443
service:
  type: LoadBalancer
EOF
```

---

## Service: Authelia (SSO)

**Priority:** 1  
**Persistence:** SQLite database + users.yml  
**OIDC:** Provides authentication to all other services

### Pre-migration checklist
- [ ] Export users from `authelia/users.yml`
- [ ] Note all OIDC client configurations
- [ ] Backup `authelia/` directory

### Helm values

```yaml
# authelia-values.yaml
config:
  existingSecret: authelia-config

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: auth.homelabdev.space
  tls:
    - secretName: authelia-tls
      hosts:
        - auth.homelabdev.space

persistence:
  enabled: true
  storageClass: longhorn
  size: 1Gi
  accessMode: ReadWriteOnce

configmap:
  existingConfigMap: authelia-configmap

resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

---

## Service: Gitea

**Priority:** 2  
**Persistence:** Git repositories (large) + PostgreSQL  
**Backup first:** Copy `/mnt/data/gitea/` to backup location

### Helm values

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
  size: 30Gi
  accessMode: ReadWriteOnce

  # Git repos directory — CRITICAL
  mountPath: /data

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
    HTTP_PORT: 3000
    SSH_PORT: 22
  database:
    DB_TYPE: postgres
    DB_HOST: gitea-postgresql
    DB_NAME: gitea
    DB_USER: gitea
  session:
    PROVIDER: database
  cache:
    PROVIDER: database
```

### Migration steps

```bash
# 1. Stop Docker Gitea
cd ~/gitea && docker compose down

# 2. Copy git repos to temporary location
cp -r /mnt/data/gitea /tmp/gitea-backup

# 3. Deploy to k8s
helm install gitea gitea/gitea --namespace services --create-namespace -f gitea-values.yaml

# 4. Wait for pod
kubectl wait --for=condition=ready pod/gitea-0 -n services --timeout=300s

# 5. Copy git repos to PVC
kubectl cp /tmp/gitea-backup/* services/gitea-0:/data/ -c gitea

# 6. Restart Gitea
kubectl rollout restart statefulset gitea -n services
```

---

## Service: Vaultwarden

**Priority:** 2  
**Persistence:** SQLite database + attachments  
**Note:** Keep existing master password, no reset needed

### Helm values

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
  size: 2Gi
  mountPath: /data

env:
  SIGNUPS_ALLOWED: "false"
  WEBSOCKET_ENABLED: "true"
  SMTP_HOST: smtp.mailgun.org
  SMTP_PORT: "587"
  SMTP_USERNAME: sidhant.amonkar@homelabdev.space
  SMTP_FROM: sidhant.amonkar@homelabdev.space
  SMTP_FROM_NAME: Vaultwarden
  SMTP_SECURITY: starttls
  ADMIN_TOKEN_FILE: /run/secrets/admin_token

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi

securityContext:
  runAsUser: 1000
  runAsGroup: 1000
```

### Migration steps

```bash
# 1. Stop Docker
cd ~/vaultwarden && docker compose down

# 2. Copy SQLite DB
cp /mnt/data/vaultwarden/db.sqlite3 /tmp/vaultwarden.db

# 3. Deploy
helm install vaultwarden vwarden/vaultwarden --namespace services -f vaultwarden-values.yaml

# 4. Copy DB to PVC
kubectl cp /tmp/vaultwarden.db services/vaultwarden-0:/data/

# 5. Copy admin token
kubectl cp ~/vaultwarden/admin_token services/vaultwarden-0:/run/secrets/admin_token -c vaultwarden
```

---

## Service: Homarr

**Priority:** 3  
**Persistence:** SQLite database  

### Helm values

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
  mountPath: /app/data
```

---

## Service: n8n

**Priority:** 3  
**Persistence:** PostgreSQL + credentials file  
**Backup:** Export workflows from n8n UI first

### Helm values

```yaml
# n8n-values.yaml
image:
  repository: n8nio/n8n
  tag: "latest"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: n8n.homelabdev.space
  tls:
    - secretName: n8n-tls
      hosts:
        - n8n.homelabdev.space

postgresql:
  enabled: true
  postgresqlDatabase: n8n
  postgresqlUsername: n8n
  persistence:
    enabled: true
    storageClass: longhorn
    size: 5Gi

persistence:
  enabled: true
  storageClass: longhorn
  size: 1Gi
  accessMode: ReadWriteOnce

env:
  N8N_HOST: n8n.homelabdev.space
  N8N_PROTOCOL: https
  WEBHOOK_URL: https://n8n.homelabdev.space
  N8N_EMAIL_MODE: smtp
  N8N_SMTP_HOST: smtp.mailgun.org
  N8N_SMTP_PORT: "587"
  N8N_SMTP_USER: sidhant.amonkar@homelelabdev.space
  N8N_SMTP_PASS: <password>
  EXECUTIONS_DATA_PRUNE: "true"
  EXECUTIONS_DATA_MAX_AGE: "7"
  GENERIC_TIMEZONE: Europe/Amsterdam
```

---

## Service: Goalert

**Priority:** 3  
**Persistence:** PostgreSQL  

### Helm values

```yaml
# goalert-values.yaml
image:
  repository: goalert/goalert
  tag: "latest"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: goalert.homelabdev.space
  tls:
    - secretName: goalert-tls
      hosts:
        - goalert.homelabdev.space

postgresql:
  enabled: true
  postgresqlDatabase: goalert
  postgresqlUsername: goalert
  persistence:
    enabled: true
    storageClass: longhorn
    size: 5Gi

env:
  GOALERT_DB_URL: postgres://goalert:<password>@goalert-postgresql:5432/goalert?sslmode=disable
  GOALERT_HTTP_PORT: "8081"
  GOALERT_DATA_DIR: /var/data
  GOALERT_LOG_LEVEL: info

persistence:
  enabled: true
  storageClass: longhorn
  size: 1Gi
  mountPath: /var/data
```

---

## Service: Backstage

**Priority:** 3  
**Persistence:** PostgreSQL + app-config.yaml  

### Helm values

```yaml
# backstage-values.yaml
image:
  repository: backstage/backstage
  tag: "latest"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: backstage.homelabdev.space
  tls:
    - secretName: backstage-tls
      hosts:
        - backstage.homelabdev.space

postgresql:
  enabled: true
  postgresqlDatabase: backstage
  postgresqlUsername: backstage
  persistence:
    enabled: true
    storageClass: longhorn
    size: 5Gi

persistence:
  enabled: true
  storageClass: longhorn
  size: 1Gi

extraVolumes:
  - name: app-config
    secret:
      secretName: backstage-config

extraVolumeMounts:
  - name: app-config
    mountPath: /app/app-config.yaml
    subPath: app-config.yaml
```

---

## Service: code-server

**Priority:** 3  
**Persistence:** Config + project directories  
**Note:** Project dirs are large — ensure enough PVC space

### Helm values

```yaml
# code-server-values.yaml
image:
  repository: codercom/code-server
  tag: "latest"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: code.homelabdev.space
  tls:
    - secretName: code-server-tls
      hosts:
        - code.homelabdev.space

env:
  PASSWORD: <from ~/code-server/.env>
  PUID: "1000"
  PGID: "1000"
  TZ: Europe/Amsterdam

persistence:
  enabled: true
  storageClass: longhorn
  size: 50Gi
  accessMode: ReadWriteOnce
  mountPath: /home/coder

extraVolumes:
  - name: project-dir
    persistentVolumeClaim:
      claimName: code-server-projects
  - name: config
    persistentVolumeClaim:
      claimName: code-server-config

extraVolumeMounts:
  - name: project-dir
    mountPath: /home/coder/project
  - name: config
    mountPath: /home/coder/.config
```

---

## Service: Chat UI (Open WebUI)

**Priority:** 3  
**Persistence:** Config + SQLite  

### Helm values

```yaml
# chat-ui-values.yaml
image:
  repository: ghcr.io/open-webui/open-webui
  tag: "latest"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: chat.homelabdev.space
  tls:
    - secretName: chat-tls
      hosts:
        - chat.homelabdev.space

env:
  OLLAMA_BASE_URL: http://litellm:4000
  WEBUI_SECRET_KEY: <generate with openssl rand -hex 32>
  OLLAMA_API_BASE_URL: http://litellm:4000/v1

persistence:
  enabled: true
  storageClass: longhorn
  size: 2Gi
  mountPath: /app/backend/data
```

---

## Service: LiteLLM (AI Gateway)

**Priority:** 3  
**Persistence:** Config only  

### Helm values

```yaml
# litellm-values.yaml
image:
  repository: ghcr.io/berriai/litellm
  tag: "latest"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
  host: ai.homelabdev.space
  tls:
    - secretName: litellm-tls
      hosts:
        - ai.homelabdev.space

env:
  LITELLM_MASTER_KEY: <from ~/ai-gateway/.env>
  DATABASE_URL: <postgres-url>
  LITELLM_MODEL_LIST: <model-config>

persistence:
  enabled: false

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

---

## Common Patterns

### Converting Docker env to k8s env

```yaml
# Docker
environment:
  - SMTP_HOST=smtp.mailgun.org
  - SMTP_PORT=587

# Kubernetes
env:
  - name: SMTP_HOST
    value: smtp.mailgun.org
  - name: SMTP_PORT
    value: "587"

# Or from secret
env:
  - name: SMTP_PASSWORD
    valueFrom:
      secretKeyRef:
        name: smtp-credentials
        key: password
```

### Converting volumes

```yaml
# Docker
volumes:
  - /mnt/data/vaultwarden:/data

# Kubernetes PVC
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: vaultwarden-data
```

### Health checks

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 3

livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3
```
