#!/bin/bash
set -euo pipefail

APP_DIR="${APP_DIR:-/home/sidhant/homelab}"
LIVE_BASE="${LIVE_BASE:-/home/sidhant}"
BASELINE_FILE="${BASELINE_FILE:-$LIVE_BASE/.homelab-drift-baseline.sha256}"

DRIFT=0

log() {
  printf '[drift] %s\n' "$1"
}

report_drift() {
  DRIFT=$((DRIFT + 1))
  printf '[drift] MISMATCH %s\n' "$1"
}

compare_file() {
  local src="$1"
  local dst="$2"
  local key="$3"

  if [ ! -f "$src" ]; then
    report_drift "$key (missing source: $src)"
    return
  fi

  if [ ! -f "$dst" ]; then
    report_drift "$key (missing target: $dst)"
    return
  fi

  if ! cmp -s "$src" "$dst"; then
    report_drift "$key"
  fi
}

compare_dir() {
  local src="$1"
  local dst="$2"
  local key="$3"

  if [ ! -d "$src" ]; then
    report_drift "$key (missing source dir: $src)"
    return
  fi

  if [ ! -d "$dst" ]; then
    report_drift "$key (missing target dir: $dst)"
    return
  fi

  if ! diff -rq "$src" "$dst" >/dev/null 2>&1; then
    report_drift "$key"
  fi
}

check_repo_vs_live() {
  log "Checking repo-managed config drift"

  compare_file "$APP_DIR/traefik/docker-compose.yml" "$LIVE_BASE/traefik/docker-compose.yml" "traefik/docker-compose.yml"
  compare_file "$APP_DIR/traefik/traefik.yml" "$LIVE_BASE/traefik/traefik.yml" "traefik/traefik.yml"
  compare_file "$APP_DIR/traefik/dynamic/dynamic.yml" "$LIVE_BASE/traefik/dynamic/dynamic.yml" "traefik/dynamic/dynamic.yml"

  compare_file "$APP_DIR/gitea/docker-compose.yml" "$LIVE_BASE/gitea/docker-compose.yml" "gitea/docker-compose.yml"
  compare_file "$APP_DIR/act-runner/docker-compose.yml" "$LIVE_BASE/act-runner/docker-compose.yml" "act-runner/docker-compose.yml"

  compare_file "$APP_DIR/observability/docker-compose.yml" "$LIVE_BASE/observability/docker-compose.yml" "observability/docker-compose.yml"
  compare_file "$APP_DIR/observability/prometheus.yml" "$LIVE_BASE/observability/prometheus.yml" "observability/prometheus.yml"
  compare_file "$APP_DIR/observability/promtail.yml" "$LIVE_BASE/observability/promtail.yml" "observability/promtail.yml"
  compare_file "$APP_DIR/observability/alertmanager.yml" "$LIVE_BASE/observability/alertmanager.yml" "observability/alertmanager.yml"
  compare_file "$APP_DIR/observability/.env.example" "$LIVE_BASE/observability/.env.example" "observability/.env.example"
  compare_dir "$APP_DIR/observability/rules" "$LIVE_BASE/observability/rules" "observability/rules"

  compare_file "$APP_DIR/backstage/docker-compose.yml" "$LIVE_BASE/backstage/docker-compose.yml" "backstage/docker-compose.yml"
  compare_file "$APP_DIR/backstage/app-config.yaml" "$LIVE_BASE/backstage/app-config.yaml" "backstage/app-config.yaml"
  compare_file "$APP_DIR/backstage/app-config.production.yaml" "$LIVE_BASE/backstage/app-config.production.yaml" "backstage/app-config.production.yaml"
  compare_dir "$APP_DIR/backstage/catalog" "$LIVE_BASE/backstage/catalog" "backstage/catalog"

  compare_file "$APP_DIR/goalert/docker-compose.yml" "$LIVE_BASE/goalert/docker-compose.yml" "goalert/docker-compose.yml"
  compare_file "$APP_DIR/goalert/.env.example" "$LIVE_BASE/goalert/.env.example" "goalert/.env.example"

  compare_file "$APP_DIR/scripts/service-integrity-check.sh" "$LIVE_BASE/scripts/service-integrity-check.sh" "scripts/service-integrity-check.sh"
}

collect_live_hashes() {
  {
    sha256sum "$LIVE_BASE/traefik/docker-compose.yml"
    sha256sum "$LIVE_BASE/traefik/traefik.yml"
    sha256sum "$LIVE_BASE/traefik/dynamic/dynamic.yml"
    sha256sum "$LIVE_BASE/gitea/docker-compose.yml"
    sha256sum "$LIVE_BASE/act-runner/docker-compose.yml"
    sha256sum "$LIVE_BASE/observability/docker-compose.yml"
    sha256sum "$LIVE_BASE/observability/prometheus.yml"
    sha256sum "$LIVE_BASE/observability/promtail.yml"
    sha256sum "$LIVE_BASE/observability/alertmanager.yml"
    sha256sum "$LIVE_BASE/observability/.env.example"
    find "$LIVE_BASE/observability/rules" -type f -print0 | sort -z | xargs -0 sha256sum
    sha256sum "$LIVE_BASE/backstage/docker-compose.yml"
    sha256sum "$LIVE_BASE/backstage/app-config.yaml"
    sha256sum "$LIVE_BASE/backstage/app-config.production.yaml"
    find "$LIVE_BASE/backstage/catalog" -type f -print0 | sort -z | xargs -0 sha256sum
    sha256sum "$LIVE_BASE/goalert/docker-compose.yml"
    sha256sum "$LIVE_BASE/goalert/.env.example"
    sha256sum "$LIVE_BASE/scripts/service-integrity-check.sh"
  } 2>/dev/null
}

write_baseline() {
  log "Writing drift baseline to $BASELINE_FILE"
  collect_live_hashes > "$BASELINE_FILE"
  chmod 600 "$BASELINE_FILE" 2>/dev/null || true
}

check_baseline() {
  if [ ! -f "$BASELINE_FILE" ]; then
    log "No baseline file present at $BASELINE_FILE (skipping baseline check)"
    return
  fi

  log "Comparing live hashes to baseline"
  local current
  current="$(mktemp)"
  collect_live_hashes > "$current"
  if ! diff -u "$BASELINE_FILE" "$current" >/dev/null 2>&1; then
    report_drift "baseline-hash-manifest"
  fi
  rm -f "$current"
}

case "${1:-check}" in
  check)
    check_repo_vs_live
    check_baseline
    if [ "$DRIFT" -eq 0 ]; then
      log "No drift detected"
      exit 0
    fi
    log "Drift detected: $DRIFT mismatch(es)"
    exit 1
    ;;
  baseline)
    write_baseline
    log "Baseline updated"
    ;;
  *)
    echo "Usage: $0 {check|baseline}"
    exit 1
    ;;
esac
