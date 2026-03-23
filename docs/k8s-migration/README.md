# Kubernetes Migration Plan — Homelab

## Status: Planning

---

## 1. Why Kubernetes

**Learning objective:** Gain deep, hands-on Kubernetes expertise by migrating the homelab from Docker Compose to k3s, on the path to potentially running homelab services on AKS in production.

**What you'll learn:**
- Pods, Deployments, StatefulSets, DaemonSets
- Services (ClusterIP, LoadBalancer, NodePort)
- Ingress controllers and Ingress resources
- ConfigMaps, Secrets, RBAC
- Helm package management
- PersistentVolumes and StorageClasses
- Network policies
- kubectl, kubectx, stern, k9s tooling
- Disaster recovery and cluster operations

---

## 2. Architecture Decision

### Selected: k3s Single-Node on Existing Azure VM

| Aspect | Decision |
|--------|----------|
| Distribution | k3s (lightweight k8s, ~500MB RAM) |
| Nodes | 1 (existing Azure VM) |
| Control plane | Embedded on the node |
| Container runtime | containerd (k3s default) |
| Ingress | Traefik (already deployed — keep it) |
| Storage | Longhorn for PVCs, Azure Disk CSI for cloud-native |
| TLS | cert-manager with Let's Encrypt Cloudflare issuer |
| DNS | External-DNS with Cloudflare |
| Helm | Yes (helm3) |
| CI/CD | GitHub Actions + ArgoCD (future) |
| Monitoring | Prometheus Operator via kube-prometheus-stack |

### Why not AKS now
- AKS is managed — you learn less about the底层
- Costs ~$30-50/month for a usable cluster
- k3s on existing VM is free and gives full control
- Migrate to AKS once k8s fundamentals are solid

---

## 3. Current State

### Services to migrate (14 services)

| Service | Type | Persistence | Priority |
|---------|------|-------------|----------|
| Traefik | Ingress | Config only | 1 (run first) |
| Authelia | Auth | SQLite + users.yml | 1 |
| Gitea | App | PostgreSQL + git repos | 2 |
| Vaultwarden | App | SQLite | 2 |
| Homarr | Dashboard | SQLite | 3 |
| n8n | Workflow | PostgreSQL | 3 |
| Goalert | On-call | PostgreSQL | 3 |
| Backstage | Dev portal | PostgreSQL | 3 |
| Prometheus | Metrics | PVC | 1 |
| Grafana | Dashboards | PVC | 1 |
| Loki | Logs | PVC | 2 |
| Jaeger | Traces | PVC | 2 |
| code-server | IDE | Config + project dirs | 3 |
| Chat UI (Open WebUI) | App | Config | 3 |
| AI Gateway (LiteLLM) | App | Config | 3 |
| Minio | Storage | PVC | 2 |

### Current networking
- Docker Compose with `traefik_default` external network
- Traefik labels for routing
- Cloudflare for DNS + ACME
- Authelia as SSO (OIDC provider)

### Target networking
- Kubernetes cluster with Traefik as IngressController
- OIDC via Authelia remains (Authelia stays, or migrates to Dex/Keycloak)
- Ingresses route to ClusterIP services
- LoadBalancer services for external-facing apps (Gitea, Vaultwarden)

---

## 4. Migration Phases

### Phase 1: Cluster Setup
- [ ] Install k3s on existing Azure VM (single-node)
- [ ] Configure kubectl on MacBook/local machine
- [ ] Install essential tools: helm, k9s, kubectx, stern
- [ ] Set up kubeconfig context
- [ ] Verify all nodes ready: `kubectl get nodes`

### Phase 2: Core Infrastructure
- [ ] Deploy Traefik as IngressController (or keep existing Docker Traefik, migrate later)
- [ ] Deploy cert-manager with Cloudflare issuer
- [ ] Deploy ExternalDNS with Cloudflare
- [ ] Deploy Authelia (keep existing or containerize properly)
- [ ] Test TLS certificates for a subdomain

### Phase 3: Stateful Workloads
- [ ] Set up Longhorn for local persistent storage (or Azure Disk CSI)
- [ ] Migrate Prometheus + Grafana + Loki (observability stack)
- [ ] Migrate PostgreSQL operator (for Gitea, n8n, Goalert, Backstage)
- [ ] Migrate Minio

### Phase 4: Application Services
- [ ] Migrate Gitea (StatefulSet with git repos on PVC)
- [ ] Migrate Vaultwarden
- [ ] Migrate Homarr
- [ ] Migrate n8n
- [ ] Migrate Goalert
- [ ] Migrate Backstage
- [ ] Migrate code-server
- [ ] Migrate Chat UI (Open WebUI)
- [ ] Migrate AI Gateway (LiteLLM)

### Phase 5: Decommission & Harden
- [ ] Stop all Docker Compose services (verify k8s is running everything)
- [ ] Remove Docker containers from VM
- [ ] Set up RBAC policies (developer namespace, admin namespace)
- [ ] Configure network policies
- [ ] Enable audit logging
- [ ] Document runbooks for common operations
- [ ] Create backup strategy for etcd + PVCs

### Phase 6: Production Readiness (Future)
- [ ] Multi-node cluster (add 2-3 more nodes)
- [ ] Migrate to AKS
- [ ] Set up cluster autoscaling
- [ ] ArgoCD for GitOps

---

## 5. Per-Service Migration Guides

Each service will have a `SERVICES.md` entry with:
- Helm chart or raw manifests
- ConfigMap/Secret values from existing `.env`
- PersistentVolume claims
- Ingress resource
- Resource requests/limits
- Health checks (readiness/liveness probes)
- Backup strategy

See [SERVICES.md](./SERVICES.md) for detailed per-service instructions.

---

## 6. Prerequisites

### Before starting
1. Azure VM: at least 4vCPU, 8GB RAM recommended (currently 2vCPU, 8GB — may need to resize)
2. Domain: homelabdev.space managed on Cloudflare (already true)
3. Cloudflare API token with DNS edit permissions (already have)
4. Backup of all data before migration
5. macOS/Linux workstation with `kubectl` installed

### VM resize check
```bash
# Check current resources
free -h
nproc
df -h
```

If < 8GB RAM, resize Azure VM to Standard_B4ms (4vCPU, 16GB) or similar.

---

## 7. Rollback Plan

If k8s migration fails:
1. Keep Docker Compose services running on VM (do NOT remove containers until k8s is verified)
2. If k8s cluster fails, delete it: `k3s-uninstall.sh`
3. Docker Compose resumes normally
4. Investigate, fix, retry

---

## 8. kubectl Context Setup (for your MacBook)

```bash
# On your MacBook, install kubectl
brew install kubectl

# Copy kubeconfig from VM
scp sidhant@<vm-ip>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
# Edit to point to your VM IP (not 127.0.0.1)

# Install helpful tools
brew install kubectx stern k9s helm

# Rename context
kubectx homelab=<context-name>
```

---

## 9. Key Resources

| Resource | URL |
|----------|-----|
| k3s docs | https://docs.k3s.io |
| Traefik IngressController | https://doc.traefik.io/traefik/providers/kubernetes-ingress/ |
| cert-manager | https://cert-manager.io/docs/ |
| ExternalDNS | https://github.com/kubernetes-sigs/external-dns |
| Longhorn | https://longhorn.io/docs/ |
| Helm charts | https://artifacthub.io |
| k9s | https://k9scli.io |
| kube-prometheus-stack | https://github.com/prometheus-operator/kube-prometheus-stack |

---

## 10. Next Step

Proceed to [PHASE-1.md](./PHASE-1.md) to begin cluster setup.
