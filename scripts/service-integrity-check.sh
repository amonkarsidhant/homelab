#!/usr/bin/env bash
set -euo pipefail

CONTAINERS=(traefik minio prometheus grafana loki jaeger gitea act-runner authelia vaultwarden code-server mailserver promtail backstage backstage-postgres)
GITEA_REPO_PATH="${GITEA_REPO_PATH:-/data/git/repositories/sidhant/homelab.git}"

BAD_COUNT=0
WARN_COUNT=0

ok() { printf 'OK   %s\n' "$*"; }
info() { printf 'INFO %s\n' "$*"; }
warn() { WARN_COUNT=$((WARN_COUNT + 1)); printf 'WARN %s\n' "$*"; }
bad() { BAD_COUNT=$((BAD_COUNT + 1)); printf 'BAD  %s\n' "$*"; }

echo "=== Service Integrity Check ==="
echo "Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

echo
echo "[1/4] Container status"
for c in "${CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -qx "$c"; then
    status=$(docker ps --filter "name=^${c}$" --format '{{.Status}}')
    ok "$c -> $status"
  else
    bad "$c -> not running"
  fi
done

echo
echo "[2/4] Mount source path checks"
for c in "${CONTAINERS[@]}"; do
  while IFS=$'\t' read -r src dst; do
    [ -z "$src" ] && continue

    if [[ "$src" == /var/lib/docker/* ]]; then
      info "$c mount $dst <- $src (docker-managed path, skipped)"
      continue
    fi

    if [ -e "$src" ]; then
      ok "$c mount $dst <- $src"
    else
      bad "$c mount $dst <- $src (missing source)"
    fi
  done < <(docker inspect "$c" --format '{{range .Mounts}}{{printf "%s\t%s\n" .Source .Destination}}{{end}}' 2>/dev/null || true)
done

echo
echo "[3/4] Critical application path checks"
if docker exec gitea test -d /data/git/repositories; then
  ok "gitea repositories path exists"
else
  bad "gitea repositories path missing"
fi

if docker exec gitea test -d "$GITEA_REPO_PATH"; then
  ok "gitea repo path exists: $GITEA_REPO_PATH"
else
  warn "gitea repo path missing: $GITEA_REPO_PATH"
fi

if [ -d /mnt/data/loki ]; then
  owner=$(stat -c '%u:%g' /mnt/data/loki)
  if [ "$owner" = "10001:10001" ]; then
    ok "loki host data path ownership is $owner"
  else
    warn "loki host data path ownership is $owner (expected 10001:10001)"
  fi
else
  bad "loki host data path missing"
fi

echo
echo "[4/4] Recent critical log scan (last 2m)"
PATTERN='no such file|permission denied|broken repository|panic|failed to start server|unauthenticated: 401'
for c in "${CONTAINERS[@]}"; do
  out=$(docker logs --since 2m "$c" 2>&1 | grep -Ei "$PATTERN" || true)
  if [ -n "$out" ]; then
    warn "$c has critical log lines"
    echo "$out" | sed 's/^/  /'
  else
    ok "$c no critical log lines"
  fi
done

echo
echo "Summary: BAD=$BAD_COUNT WARN=$WARN_COUNT"

if [ "$BAD_COUNT" -gt 0 ]; then
  exit 1
fi

exit 0
