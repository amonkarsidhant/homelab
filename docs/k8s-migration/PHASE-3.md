# Phase 3: Stateful Workloads — Database & Observability

## Goal
Deploy PostgreSQL operator, then migrate observability stack (Prometheus, Grafana, Loki) and database-backed services.

---

## Step 3.1: Install PostgreSQL Operator (CNPG)

```bash
# Add PGO (PostgreSQL Operator) Helm repo
helm repo add enterprisedb https://enterprisedb.github.io/charts
helm repo update

# Install PostgreSQL Operator
helm install postgresql-operator enterprisedb/postgresql-operator \
  --namespace postgresql \
  --create-namespace
```

Or use the lightweight **K8ssandra** or just **bitnami/postgresql** Helm chart per-service.

---

## Step 3.2: Deploy PostgreSQL Instances

Create one PostgreSQL instance per service group:

```bash
# For Gitea + n8n + Goalert + Backstage
helm install postgres homelab bitnami/postgresql \
  --namespace databases \
  --create-namespace \
  --set auth.database=homelab \
  --set persistence.size=10Gi \
  --set persistence.storageClass=longhorn \
  --set resources.requests.memory=512Mi \
  --set resources.limits.memory=2Gi
```

Or use **Tidwall** approach — one Postgres per service for isolation.

---

## Step 3.3: Migrate Prometheus + Grafana (kube-prometheus-stack)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values <<EOF
prometheus:
  ingress:
    enabled: true
    className: traefik
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-cloudflare
    hosts:
      - prometheus.homelabdev.space
    tls:
      - secretName: prometheus-tls
        hosts:
          - prometheus.homelabdev.space
grafana:
  ingress:
    enabled: true
    className: traefik
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-cloudflare
    hosts:
      - grafana.homelabdev.space
    tls:
      - secretName: grafana-tls
        hosts:
          - grafana.homelabdev.space
  persistence:
    enabled: true
    storageClass: longhorn
    size: 5Gi
alertmanager:
  ingress:
    enabled: true
    className: traefik
    hosts:
      - alertmanager.homelabdev.space
EOF
```

---

## Step 3.4: Migrate Loki (Log Aggregation)

```bash
helm install loki grafana/loki \
  --namespace monitoring \
  --values <<EOF
persistence:
  enabled: true
  storageClassName: longhorn
  size: 5Gi
ingress:
  enabled: true
  className: traefik
  hosts:
    - loki.homelabdev.space
  tls:
    - secretName: loki-tls
      hosts:
        - loki.homelabdev.space
EOF

# Install Grafana datasources for Loki
```

---

## Step 3.5: Migrate Jaeger (Distributed Tracing)

```bash
helm install jaeger jaegertracing/jaeger \
  --namespace monitoring \
  --values <<EOF
ingress:
  enabled: true
  className: traefik
  host: jaeger.homelabdev.space
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
persistence:
  enabled: true
  storageClass: longhorn
  size: 5Gi
EOF
```

---

## Deliverables

After Phase 3:
- [ ] PostgreSQL running on k8s with Longhorn PVCs
- [ ] Prometheus + Grafana accessible (with historical data preserved)
- [ ] Loki for log aggregation
- [ ] Jaeger for distributed tracing
- [ ] All observability on k8s

---

## Next Phase

Proceed to [PHASE-4.md](./PHASE-4.md) for migrating application services.
