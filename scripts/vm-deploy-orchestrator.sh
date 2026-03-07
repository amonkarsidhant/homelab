#!/bin/bash
set -euo pipefail

APP_DIR="${APP_DIR:-/home/sidhant/homelab}"
LIVE_BASE="${LIVE_BASE:-/home/sidhant}"
VM_USER="${VM_USER:-sidhant}"

log() {
  printf '[vm-deploy] %s\n' "$1"
}

ensure_prereqs() {
  log "Ensuring data directories and Docker network"

  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    sudo mkdir -p /mnt/data/{traefik,gitea,act-runner,prometheus,grafana,loki,jaeger,minio,authelia,mailserver,backstage,backstage-postgres,goalert-postgres,alertmanager}
    sudo chown -R 65534:65534 /mnt/data/prometheus /mnt/data/grafana 2>/dev/null || true
    sudo chown -R "$VM_USER":"$VM_USER" /mnt/data
  else
    log "Passwordless sudo unavailable; using existing /mnt/data layout"
    mkdir -p /mnt/data/{traefik,gitea,act-runner,prometheus,grafana,loki,jaeger,minio,authelia,mailserver,backstage,backstage-postgres,goalert-postgres,alertmanager} 2>/dev/null || true
  fi

  if [ ! -d /mnt/data ]; then
    log "ERROR: /mnt/data is not available and cannot be initialized without sudo"
    exit 1
  fi

  docker network create traefik_default >/dev/null 2>&1 || true
}

copy_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

copy_dir() {
  local src="$1"
  local dst="$2"
  rm -rf "$dst"
  mkdir -p "$(dirname "$dst")"
  cp -r "$src" "$dst"
}

sync_service_files() {
  log "Syncing managed service files"

  copy_file "$APP_DIR/traefik/docker-compose.yml" "$LIVE_BASE/traefik/docker-compose.yml"
  copy_file "$APP_DIR/traefik/traefik.yml" "$LIVE_BASE/traefik/traefik.yml"
  copy_file "$APP_DIR/traefik/dynamic/dynamic.yml" "$LIVE_BASE/traefik/dynamic/dynamic.yml"

  copy_file "$APP_DIR/gitea/docker-compose.yml" "$LIVE_BASE/gitea/docker-compose.yml"
  copy_file "$APP_DIR/act-runner/docker-compose.yml" "$LIVE_BASE/act-runner/docker-compose.yml"

  copy_file "$APP_DIR/observability/docker-compose.yml" "$LIVE_BASE/observability/docker-compose.yml"
  copy_file "$APP_DIR/observability/prometheus.yml" "$LIVE_BASE/observability/prometheus.yml"
  copy_file "$APP_DIR/observability/promtail.yml" "$LIVE_BASE/observability/promtail.yml"
  copy_file "$APP_DIR/observability/alertmanager.yml" "$LIVE_BASE/observability/alertmanager.yml"
  copy_file "$APP_DIR/observability/.env.example" "$LIVE_BASE/observability/.env.example"
  copy_dir "$APP_DIR/observability/rules" "$LIVE_BASE/observability/rules"

  copy_file "$APP_DIR/backstage/docker-compose.yml" "$LIVE_BASE/backstage/docker-compose.yml"
  copy_file "$APP_DIR/backstage/app-config.yaml" "$LIVE_BASE/backstage/app-config.yaml"
  copy_file "$APP_DIR/backstage/app-config.production.yaml" "$LIVE_BASE/backstage/app-config.production.yaml"
  copy_dir "$APP_DIR/backstage/catalog" "$LIVE_BASE/backstage/catalog"

  copy_file "$APP_DIR/goalert/docker-compose.yml" "$LIVE_BASE/goalert/docker-compose.yml"
  copy_file "$APP_DIR/goalert/.env.example" "$LIVE_BASE/goalert/.env.example"

  copy_file "$APP_DIR/scripts/service-integrity-check.sh" "$LIVE_BASE/scripts/service-integrity-check.sh"
  chmod +x "$LIVE_BASE/scripts/service-integrity-check.sh"
}

ensure_runtime_env() {
  log "Ensuring runtime env files"

  if [ ! -f "$LIVE_BASE/backstage/.env" ]; then
    local pg_pw backend_secret
    pg_pw="$(openssl rand -hex 24)"
    backend_secret="$(openssl rand -hex 32)"
    printf 'POSTGRES_PASSWORD=%s\nBACKEND_SECRET=%s\n' "$pg_pw" "$backend_secret" > "$LIVE_BASE/backstage/.env"
    chmod 600 "$LIVE_BASE/backstage/.env"
  fi

  if [ ! -f "$LIVE_BASE/observability/.env" ]; then
    cp "$LIVE_BASE/observability/.env.example" "$LIVE_BASE/observability/.env"
    chmod 600 "$LIVE_BASE/observability/.env"
  fi

  if [ ! -f "$LIVE_BASE/goalert/.env" ]; then
    local db_pw enc_key admin_pw
    db_pw="$(openssl rand -hex 24)"
    enc_key="$(openssl rand -hex 48)"
    admin_pw="$(openssl rand -hex 16)"
    printf 'GOALERT_DB_PASSWORD=%s\nGOALERT_DATA_ENCRYPTION_KEY=%s\nGOALERT_ADMIN_PASSWORD=%s\n' "$db_pw" "$enc_key" "$admin_pw" > "$LIVE_BASE/goalert/.env"
    chmod 600 "$LIVE_BASE/goalert/.env"
  fi
}

start_services() {
  log "Starting services"
  (cd "$LIVE_BASE/traefik" && docker compose up -d)
  (cd "$LIVE_BASE/gitea" && docker compose up -d)
  (cd "$LIVE_BASE/act-runner" && docker compose up -d)
  (cd "$LIVE_BASE/observability" && docker compose up -d promtail cadvisor alertmanager)
  (cd "$LIVE_BASE/backstage" && docker compose up -d)
  (cd "$LIVE_BASE/goalert" && docker compose up -d)
}

seed_goalert_admin() {
  if [ -f "$LIVE_BASE/goalert/.env" ]; then
    # shellcheck disable=SC1090
    set -a && . "$LIVE_BASE/goalert/.env" && set +a
    docker exec goalert goalert add-user --admin --user admin --email amonkarsidhant@outlook.com --pass "$GOALERT_ADMIN_PASSWORD" >/tmp/goalert-add-user.log 2>&1 || true
  fi
}

verify_deploy() {
  log "Verifying deployment"
  echo "=== VM Status ==="
  uptime
  echo "=== Latest Commit ==="
  (cd "$APP_DIR" && git log -1 --oneline)
  echo "=== Containers ==="
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
}

deploy_all() {
  ensure_prereqs
  sync_service_files
  ensure_runtime_env
  start_services
  seed_goalert_admin
  verify_deploy
}

case "${1:-deploy}" in
  deploy)
    deploy_all
    ;;
  sync)
    ensure_prereqs
    sync_service_files
    ensure_runtime_env
    ;;
  start)
    start_services
    ;;
  verify)
    verify_deploy
    ;;
  status)
    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    ;;
  *)
    echo "Usage: $0 {deploy|sync|start|verify|status}"
    exit 1
    ;;
esac
