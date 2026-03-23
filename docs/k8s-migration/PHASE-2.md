# Phase 2: Core Infrastructure on k8s

## Goal
Deploy the foundational k8s components: Ingress (Traefik), TLS (cert-manager), DNS (ExternalDNS), Storage (Longhorn), and Authelia as SSO.

---

## Step 2.1: Stop Docker Traefik (Migrate to k8s Traefik)

**Important:** Back up your Traefik config before proceeding.

```bash
# On VM — stop Docker Traefik
cd ~/traefik
docker compose down

# Keep the config files safe
cp -r ~/traefik ~/traefik.bak
```

Verify DNS still works (services should be unreachable until k8s Traefik is up).

---

## Step 2.2: Install Traefik via Helm

```bash
# Create namespace
kubectl create namespace traefik

# Install Traefik
helm install traefik traefik/traefik \
  --namespace traefik \
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
hostNetwork: false
service:
  type: LoadBalancer
EOF

# Verify
kubectl get pods -n traefik
kubectl get svc -n traefik
```

---

## Step 2.3: Install cert-manager

```bash
kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true

# Create Cloudflare Issuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-cloudflare
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@homelabdev.space
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token
            key: api-key
EOF

# Create the secret
kubectl create secret generic cloudflare-api-token \
  --namespace cert-manager \
  --from-literal=api-key=$CF_API_TOKEN
```

---

## Step 2.4: Install ExternalDNS

```bash
kubectl create namespace external-dns

helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  --values <<EOF
provider: cloudflare
cloudflare:
  apiToken: $CF_API_TOKEN
domainFilters:
  - homelabdev.space
policy: sync
sources:
  - ingress
  - service
EOF
```

---

## Step 2.5: Install Longhorn (Persistent Storage)

```bash
kubectl create namespace longhorn-system

helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --values <<EOF
defaultSettings:
  backupTarget: ""
  createDefaultDiskLabelOnNodes: true
persistence:
  defaultClass: true
  defaultClassReplicaCount: 1
service:
  type: ClusterIP
ingress:
  enabled: true
  ingressClassName: traefik
  host: longhorn.homelabdev.space
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
    traefik.ingress.kubernetes.io/router.tls: "true"
EOF

# Wait for Longhorn to be ready
kubectl get pods -n longhorn-system
```

---

## Step 2.6: Install Authelia (SSO)

```bash
kubectl create namespace authelia

# Create config secret
kubectl create secret generic authelia-config \
  --namespace authelia \
  --from-file=configuration.yml=./authelia-configuration.yml \
  --from-file=users.yml=./authelia-users.yml

# Create storage secret
kubectl create secret generic authelia-storage-key \
  --namespace authelia \
  --from-literal=storage_encryption_key=$(openssl rand -hex 32)

# Deploy Authelia via Helm
helm install authelia authelia/authelia \
  --namespace authelia \
  --values <<EOF
config:
  existingConfigurationSecret: authelia-config
ingress:
  enabled: true
  className: traefik
  host: auth.homelabdev.space
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
    traefik.ingress.kubernetes.io/router.tls: "true"
persistence:
  size: 1Gi
  storageClass: longhorn
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
```

---

## Step 2.7: Verify Core Infrastructure

```bash
# Check all pods
kubectl get pods -A

# Check ingresses
kubectl get ingress -A

# Check certificates
kubectl get certificates
kubectl describe certificate letsencrypt-cert

# Test a service via ingress
curl -v https://auth.homelabdev.space
```

---

## Deliverables

After Phase 2:
- [ ] Traefik IngressController running (k8s, not Docker)
- [ ] cert-manager issuing Let's Encrypt certs
- [ ] ExternalDNS creating/updating Cloudflare records
- [ ] Longhorn providing persistent volumes
- [ ] Authelia SSO accessible at auth.homelabdev.space
- [ ] All traffic routed through k8s ingress

---

## Next Phase

Proceed to [PHASE-3.md](./PHASE-3.md) for migrating stateful workloads (PostgreSQL, Prometheus, etc).
