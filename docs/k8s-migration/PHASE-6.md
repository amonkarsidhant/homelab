# Phase 6: Production Readiness & AKS Future

## Goal
Establish production-grade practices on k3s, then document the path to AKS migration.

---

## Step 6.1: Production Hardening on k3s

### Enable high availability (future: multi-node)

For now, optimize the single node:

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -A

# Set resource quotas per namespace
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: default-quota
  namespace: default
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "50"
EOF
```

---

## Step 6.2: Set Descheduler (Optional)

The descheduler can evict pods from nodes to allow rebalancing:

```bash
helm install descheduler prometheus-community/kube-descheduler \
  --namespace kube-system \
  --values <<EOF
descheduler:
  enabled: true
  strategies:
    RemoveDuplicates:
      enabled: true
    RemovePodsViolatingNodeAffinity:
      enabled: true
    RemovePodsViolatingTopologySpreadConstraint:
      enabled: true
EOF
```

---

## Step 6.3: Monitoring & Alerting

### Prometheus alerting rules

```yaml
# alert-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: homelab-alerts
  namespace: monitoring
spec:
  groups:
    - name: homelab
      rules:
        - alert: HighCPUUsage
          expr: cpu_usage > 80
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High CPU usage on {{ $labels.node }}"
        - alert: PodNotReady
          expr: kube_pod_status_ready_condition{condition="true"} == 0
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "Pod {{ $labels.pod }} not ready"
```

### Send alerts to Discord (existing webhook)

Use the existing Discord webhook in `~/.config/homelab/monitor.env` for alerts.

---

## Step 6.4: Disaster Recovery Runbook

### Complete cluster failure

```bash
# If k3s cluster fails:
# 1. Check k3s service
sudo systemctl status k3s

# 2. Check etcd
sudo crictl ps | grep etcd

# 3. Restore from snapshot
sudo k3s etcd-snapshot restore /var/lib/rancher/k3s/server/db/snapshots/<snapshot-file>

# 4. Restart k3s
sudo systemctl restart k3s
```

### PersistentVolume data loss

- Longhorn snapshots + backups to S3 (Azure Blob compatible)
- Restore: Longhorn UI → Select backup → Restore

---

## Step 6.5: Multi-Node k3s Cluster

Add worker nodes to the existing k3s cluster:

```bash
# On the NEW node (worker):
curl -sfL https://get.k3s.io | K3S_URL=https://<master-ip>:6443 K3S_TOKEN=<node-token> sh -

# Get the node token from the master:
sudo cat /var/lib/rancher/k3s/server/node-token
```

---

## Step 6.6: Path to AKS

### When to migrate to AKS
- When you want managed control plane (no more `k3s-uninstall.sh` on master failure)
- When you need multi-zone high availability
- When you want Azure integration (Azure AD auth, Azure Monitor, Azure Policy)
- When homelab becomes production workloads

### AKS Migration Steps

```bash
# 1. Create AKS cluster
az aks create \
  --resource-group homelab-rg \
  --name homelab-aks \
  --node-count 3 \
  --vm-size Standard_B4ms \
  --enable-oidc-issuer \
  --enable-workload-identity

# 2. Get credentials
az aks get-credentials --resource-group homelab-rg --name homelab-aks

# 3. Deploy Longhorn CSI (Azure Disk)
helm install azuredisk-csi-driver \
  --repo https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/charts \
  --namespace kube-system

# 4. Migrate workloads
# Export manifests from k3s
kubectl get all -A -o yaml > k8s-all-resources.yaml

# Apply to AKS
kubectl apply -f k8s-all-resources.yaml

# 5. Update DNS
# Point Cloudflare A record to AKS Load Balancer IP
```

### AKS Cost Estimate

| Component | Cost |
|-----------|------|
| 3x Standard_B4ms nodes | ~$90/month |
| Managed control plane (free tier) | $0 |
| Azure Disk CSI (50GB) | ~$5/month |
| Outbound bandwidth | ~$5/month |
| **Total** | **~$100/month** |

---

## Step 6.7: GitOps with ArgoCD

Once on k8s, set up GitOps:

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Point ArgoCD to your homelab git repo
argocd repo add https://github.com/amonkarsidhant/homelab \
  --username amonkarsidhant \
  --password <github-token>

# Create an Application
argocd app create homelab \
  --repo https://github.com/amonkarsidhant/homelab \
  --path k8s/manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

---

## Deliverables

After Phase 6:
- [ ] Resource quotas set
- [ ] Monitoring + alerting configured
- [ ] Disaster recovery runbook documented
- [ ] Path to multi-node k3s documented
- [ ] Path to AKS migration documented
- [ ] ArgoCD GitOps setup planned

---

## End State

After completing all phases:
- Full k3s cluster running on Azure VM
- All 14+ homelab services on k8s
- GitOps workflow with ArgoCD
- Disaster recovery tested
- Ready to migrate to AKS when needed
