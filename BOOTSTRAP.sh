#!/usr/bin/env bash
# =============================================================================
# Homelab Bootstrap Script
# =============================================================================
# Run this on a FRESH Ubuntu 22.04 VM to rebuild the homelab.
# 
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/amonkarsidhant/homelab/main/BOOTSTRAP.sh | bash
#
# OR if you already have the repo cloned:
#   bash ~/homelab/BOOTSTRAP.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[boot]${NC} $*"; }
warn()  { echo -e "${YELLOW}[boot]${NC} $*"; }
error() { echo -e "${RED}[boot]${NC} $*" >&2; }

need() {
  if [ -z "$1" ]; then error "Required: $2"; exit 1; fi
}

# =============================================================================
# Step 1: Detect environment
# =============================================================================
info "=== Phase 1: Environment Check ==="

if [ "$(id -u)" -eq 0 ]; then
  warn "Running as root — will create a 'homelab' user if needed"
  IS_ROOT=true
else
  IS_ROOT=false
  info "Running as $(whoami)"
fi

# =============================================================================
# Step 2: System updates
# =============================================================================
info "=== Phase 2: System Updates ==="
if command -v apt-get &>/dev/null; then
  apt-get update -qq
  apt-get install -y -qq curl git gpg rsync lsof ca-certificates ufw \
    fail2ban unattended-upgradeschrony || true
  info "System packages installed"
elif command -v yum &>/dev/null; then
  yum install -y curl git gpg rsync lsof ca-certificates || true
  info "CentOS/RHEL packages installed"
fi

# =============================================================================
# Step 3: Docker
# =============================================================================
info "=== Phase 3: Docker ==="
if ! command -v docker &>/dev/null; then
  info "Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  $IS_ROOT && usermod -aG docker "$SUDO_USER" || true
  info "Docker installed"
else
  info "Docker already present: $(docker --version)"
fi

if ! docker compose version &>/dev/null; then
  info "Installing Docker Compose plugin..."
  apt-get install -y -qq docker-compose-plugin || true
fi
info "Docker Compose: $(docker compose version 2>/dev/null || echo 'not found')"

# =============================================================================
# Step 4: Clone repo
# =============================================================================
info "=== Phase 4: Clone Repository ==="
if [ ! -d /root/homelab ] && [ ! -d ~/homelab ]; then
  if $IS_ROOT && [ -n "${SUDO_USER:-}" ]; then
    NEED_SUDO_USER_HOME="/home/$SUDO_USER"
  else
    NEED_SUDO_USER_HOME="$HOME"
  fi
  info "Cloning homelab repo..."
  git clone https://github.com/amonkarsidhant/homelab.git "$NEED_SUDO_USER_HOME/homelab"
  info "Repo cloned to $NEED_SUDO_USER_HOME/homelab"
else
  info "Repo already present"
fi

HOMELAB_DIR="$NEED_SUDO_USER_HOME/homelab"
cd "$HOMELAB_DIR"

# =============================================================================
# Step 5: Create data directories
# =============================================================================
info "=== Phase 5: Data Directories ==="
DATA_DIRS=(
  traefik certs prometheus grafana loki jaeger alertmanager
  minio gitea act-runner backstage-postgres goalert-postgres
  vaultwarden authelia mailserver open-webui
)

for dir in "${DATA_DIRS[@]}"; do
  full="/mnt/data/$dir"
  if [ ! -d "$full" ]; then
    mkdir -p "$full"
    chmod 755 "$full"
    info "Created $full"
  else
    info "Exists: $full"
  fi
done

# =============================================================================
# Step 6: Create required files
# =============================================================================
info "=== Phase 6: Required Files ==="

# Traefik acme.json
if [ ! -f /mnt/data/traefik/acme.json ]; then
  touch /mnt/data/traefik/acme.json
  chmod 600 /mnt/data/traefik/acme.json
  info "Created /mnt/data/traefik/acme.json"
fi

# Docker network
docker network create homelab 2>/dev/null || info "Network 'homelab' exists"

# =============================================================================
# Step 7: Firewall
# =============================================================================
info "=== Phase 7: Firewall ==="
if command -v ufw &>/dev/null; then
  ufw --force enable 2>/dev/null || true
  ufw allow 22/tcp comment 'SSH'
  ufw allow 80/tcp comment 'HTTP'
  ufw allow 443/tcp comment 'HTTPS'
  info "Firewall configured (22, 80, 443 open)"
fi

# =============================================================================
# Step 8: Auto-updates
# =============================================================================
info "=== Phase 8: Auto-updates ==="
if command -v unattended-upgrades &>/dev/null; then
  cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'UPDATES'
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
UPDATES
  info "Auto-updates configured"
fi

# =============================================================================
# Step 9: Secrets prompt
# =============================================================================
info "=== Phase 9: Secrets ==="
if [ -f ~/.config/homelab/secrets.env ]; then
  info "secrets.env found — sourcing it"
  # shellcheck disable=SC1090
  source ~/.config/homelab/secrets.env
else
  warn "No secrets.env found at ~/.config/homelab/secrets.env"
  warn "Create it with: cp ~/homelab/docs/rebuild/SECRETS.md ~/.config/homelab/secrets.env"
  warn "Or: nano ~/.config/homelab/secrets.env"
fi

# =============================================================================
# Step 10: Start core services
# =============================================================================
info "=== Phase 10: Core Services ==="

start_service() {
  local svc="$1"
  local dir="$HOMELAB_DIR/$svc"
  if [ -d "$dir" ] && [ -f "$dir/docker-compose.yml" ]; then
    info "Starting $svc..."
    (cd "$dir" && docker compose up -d) 2>/dev/null || warn "Failed to start $svc"
  fi
}

# Critical order
start_service traefik
sleep 5
start_service authelia
sleep 5
start_service minio
sleep 5
start_service observability
sleep 3
start_service gitea

info ""
info "=== Bootstrap Complete ==="
info ""
info "Next steps:"
info "  1. Source secrets: source ~/.config/homelab/secrets.env"
info "  2. Start remaining: cd ~/homelab && for svc in */; do cd \$svc && docker compose up -d && cd ..; done"
info "  3. Verify: docker ps"
info "  4. Full guide: cat ~/homelab/docs/rebuild/AGENT.md"
info ""
info "Services started:"
docker ps --format "  {{.Names}}: {{.Status}}" 2>/dev/null | head -10 || true
