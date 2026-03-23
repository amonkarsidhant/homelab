# Phase 5: Decommission Docker & Cluster Hardening

## Goal
Remove Docker Compose services once k8s is verified, then harden the cluster with RBAC, network policies, and monitoring.

---

## Step 5.1: Verify k8s is Running All Services

Before decommissioning Docker, verify all services are accessible:

```bash
# List all k8s pods
kubectl get pods -A

# Check all ingresses
kubectl get ingress -A

# Test each service URL
for svc in auth gitea vault home n8n goalert backstage code chat ai prometheus grafana loki jaeger; do
  echo "Testing $svc.homelabdev.space..."
  curl -sfk https://$svc.homelabdev.space -o /dev/null && echo "  ✓" || echo "  ✗"
done
```

---

## Step 5.2: Stop and Remove Docker Services

```bash
# Stop all Docker Compose services
cd ~/traefik && docker compose down
cd ~/authelia && docker compose down
cd ~/gitea && docker compose down
cd ~/vaultwarden && docker compose down
cd ~/homarr && docker compose down
cd ~/n8n && docker compose down
cd ~/goalert && docker compose down
cd ~/backstage && docker compose down
cd ~/code-server && docker compose down
cd ~/chat-ui && docker compose down
cd ~/ai-gateway && docker compose down
cd ~/observability && docker compose down
cd ~/mailserver && docker compose down

# Verify no containers are running (except k3s system containers)
docker ps
```

---

## Step 5.3: Disable Docker (Optional)

If you want to fully commit to k8s:

```bash
# Disable Docker daemon
sudo systemctl disable docker
sudo systemctl stop docker

# Verify k3s is using containerd
kubectl get nodes -o wide
# Should show container runtime: containerd://1.x.x
```

---

## Step 5.4: RBAC — Create Service Accounts & Roles

### Developer namespace (for future use)

```yaml
# developer-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
---
# developer-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: development
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "configmaps", "secrets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["apps"]
    resources: ["deployments", "statefulsets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["pods/logs"]
    verbs: ["get"]
---
# developer-sa.yaml
apiVersion: vbac.authorization.k8s.io/v1
kind: ServiceAccount
metadata:
  name: developer
  namespace: development
---
# developer-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
  - kind: ServiceAccount
    name: developer
    namespace: development
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

---

## Step 5.5: Network Policies

Restrict namespace-to-namespace traffic:

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: traefik
      ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443
```

---

## Step 5.6: Enable Audit Logging

```bash
# Edit k3s config
sudo vi /etc/rancher/k3s/kubelet.config

# Add audit policy
sudo mkdir -p /var/lib/rancher/k3s/server/audit
cat <<EOF | sudo tee /var/lib/rancher/k3s/server/audit/audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: Metadata
    resources:
      - group: ""
        resources: ["secrets", "configmaps"]
  - level: RequestResponse
    resources:
      - group: "apps"
        resources: ["deployments", "statefulsets"]
EOF
```

---

## Step 5.7: Backup Strategy

### etcd backup (k3s stores cluster state)
```bash
# k3s creates automatic snapshots to /var/lib/rancher/k3s/server/db/snapshots/
# Configure in /etc/rancher/k3s/k3s.yaml:
#   etcd-snapshot-retention: 5
#   etcd-snapshot-schedule-cron: "0 */6 * * *"

# Manual snapshot
sudo k3s etcd-snapshot save
```

### PVC backup (Longhorn)
- Longhorn UI at `longhorn.homelabdev.space`
- Configure recurring backup to s3-compatible storage (Minio or Azure Blob)
- Backup schedule: daily snapshots, weekly backup to remote

---

## Step 5.8: Document Runbooks

Create runbooks for common operations:

| Operation | Runbook |
|-----------|---------|
| Restart a service | `kubectl rollout restart deployment/<name> -n <namespace>` |
| Check logs | `kubectl logs -f deployment/<name> -n <namespace>` |
| Scale a service | `kubectl scale deployment/<name> --replicas=3 -n <namespace>` |
| Upgrade a Helm chart | `helm upgrade <name> <chart> -n <namespace>` |
| Rollback a deployment | `kubectl rollout undo deployment/<name> -n <namespace>` |
| Check PVC usage | `kubectl get pvc -A` |
| Add a new service | See PHASE-4.md template |

---

## Deliverables

After Phase 5:
- [ ] All Docker Compose services stopped
- [ ] Docker daemon disabled (optional)
- [ ] RBAC policies configured
- [ ] Network policies applied
- [ ] etcd snapshot schedule configured
- [ ] Longhorn backup configured
- [ ] Runbooks documented

---

## Next Phase

Proceed to [PHASE-6.md](./PHASE-6.md) for production readiness and AKS migration planning.
