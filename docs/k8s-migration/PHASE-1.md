# Phase 1: k3s Cluster Setup

## Goal
Install k3s on the existing Azure VM, configure kubectl locally on your MacBook, and verify the cluster is operational.

---

## Step 1.1: Check VM Resources

```bash
# On the VM
free -h          # Check RAM (need at least 2GB free for k3s)
nproc            # CPU count
df -h /          # Root disk space (need 10GB+ free)
hostname -I      # Get VM IP address
```

If RAM < 4GB total, resize the Azure VM before proceeding.

---

## Step 1.2: Install k3s (Single-Node)

SSH into the VM and run:

```bash
# Install k3s (includes kubectl, helm, ctr)
curl -sfL https://get.k3s.io | sh -

# Wait for it to finish (~2 minutes)
# k3s installs to /usr/local/bin/, config to /etc/rancher/k3s/

# Verify it's running
sudo systemctl status k3s
kubectl get nodes
```

Expected output:
```
NAME        STATUS   ROLES                  AGE   VERSION
homelabvm   master  control-plane,master   10s   v1.28.x
```

---

## Step 1.3: Get kubeconfig for Local Machine

On the **VM**, get the kubeconfig:

```bash
sudo cat /etc/rancher/k3s/k3s.yaml
```

Copy this to your **MacBook**:

```bash
# On MacBook — create kube dir if it doesn't exist
mkdir -p ~/.kube

# Paste the config into ~/.kube/config
# Then edit the server line:
#   server: https://<YOUR-VM-PUBLIC-IP>:6443
# (k3s defaults to 6443 for the API server)

# Set correct permissions
chmod 600 ~/.kube/config
```

---

## Step 1.4: Install kubectl Tools on MacBook

```bash
# Using Homebrew
brew install kubectl kubectx stern k9s helm

# Verify connection to cluster
kubectl get nodes
kubectl version --client
```

---

## Step 1.5: Install Essential k8s Tools Inside the Cluster

Once k3s is running, install core add-ons:

```bash
# Add Helm chart repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add traefik https://traefik.github.io/charts
helm repo add authelia https://charts.authelia.com
helm repo update
```

### Traefik (already have — decide: keep Docker or migrate?)

Option A: Keep Docker Traefik (simpler, already works)
- Keep `traefik.homelabdev.space` working
- Migrate Ingress resources to k8s later

Option B: Migrate Traefik to k8s (recommended for learning)
```bash
helm install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --values <<EOF
ingressClass:
  isDefaultClass: true
ports:
  web:
    port: 80
    expose: true
  websecure:
    port: 443
    expose: true
EOF
```

### cert-manager (for TLS)
```bash
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --set solver.config.cloudflare.apiTokenSecretRef.name=cloudflare-api-token \
  --set solver.config.cloudflare.apiTokenSecretRef.key=api-key
```

### ExternalDNS (auto-create DNS records)
```bash
helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  --create-namespace \
  --set provider=cloudflare \
  --set cloudflare.apiToken=$CF_API_TOKEN \
  --set domainFilters[0]=homelabdev.space \
  --set policy=sync
```

---

## Step 1.6: Verify Cluster is Functional

```bash
kubectl get all -A
kubectl get nodes -o wide
kubectl get pods -A
kubectl get ingressClass
```

---

## Step 1.7: Copy kubeconfig to Homelab Git Repo

```bash
# On VM — export kubeconfig as a secret-ish file
sudo cat /etc/rancher/k3s/k3s.yaml > ~/homelab/k8s/kubeconfig

# Edit the server IP to your VM's public IP
# DO NOT commit the real kubeconfig to git — add to .gitignore
echo "k8s/kubeconfig" >> ~/.config/homelab/.gitignore_local
```

---

## Deliverables

After Phase 1:
- [ ] k3s running on Azure VM (`kubectl get nodes` shows 1 node)
- [ ] kubectl configured on MacBook
- [ ] Helm repos added
- [ ] Core add-ons (Traefik or cert-manager) deployed
- [ ] Cluster accessible from MacBook

---

## Common Issues

### k3s fails to start
```bash
# Check logs
sudo journalctl -u k3s -f

# Common cause: port 6443 already in use (Traefik on Docker)
# Solution: stop Docker Traefik first, or use a different port
```

### kubectl can't connect from MacBook
```bash
# Check the server IP in kubeconfig
# Must be the VM's PUBLIC IP, not 127.0.0.1
# Also check firewall: port 6443 must be open in Azure NSG
```

### Node shows NotReady
```bash
# Wait 30 seconds for kubelet to fully start
# Check: sudo systemctl status k3s-agent
```

---

## Next Phase

Once Phase 1 is complete, proceed to [PHASE-2.md](./PHASE-2.md) for core infrastructure deployment.
