#!/usr/bin/env bash
set -euo pipefail

LABEL="homelab-backup"
DATE=$(date -u +%Y%m%d-%H%M%S)
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
DEST_PI="${DEST_PI:-}"
DEST_MAC="${DEST_MAC:-}"
STAGING=$(mktemp -d /tmp/backup-XXXX)
ARCHIVE="$BACKUP_DIR/${LABEL}-${DATE}.tar.gz"
MANIFEST="$STAGING/manifest.txt"

mkdir -p "$BACKUP_DIR"

log() { echo "[backup] $(date -u +%H:%M:%S) $*"; }

gpg_encrypt() {
  local src="$1"
  local out="${src}.gpg"
  local phrase="${BACKUP_PASSPHRASE:-}"
  if [ -z "$phrase" ]; then
    log "WARNING: BACKUP_PASSPHRASE not set — skipping encryption, saving raw tar"
    mv "$src" "$out"
    return 0
  fi
  echo "$phrase" | gpg --batch --yes --passphrase-fd 0 --compress-algo none --symmetric -o "$out" "$src"
}

log "Starting backup run"

{
  echo "DATE=$DATE"
  echo "HOST=$(hostname)"
  echo "KERNEL=$(uname -r)"
  docker ps --format '{{.Names}}:{{.Status}}'
} > "$MANIFEST"

tar -czf "$STAGING/configs.tar.gz" -C /home/sidhant \
  homelab/scripts \
  homelab/docs \
  traefik/docker-compose.yml \
  traefik/traefik.yml \
  traefik/dynamic \
  observability/docker-compose.yml \
  observability/prometheus.yml \
  observability/alertmanager.yml \
  gitea/docker-compose.yml \
  act-runner/docker-compose.yml \
  goalert/docker-compose.yml \
  backstage/docker-compose.yml \
  n8n/docker-compose.yml \
  authelia/docker-compose.yml \
  vaultwarden/docker-compose.yml \
  homelab/docker-compose.yml \
  homelab/ansible \
  homelab/terraform \
  homelab/.github \
  2>/dev/null || true

tar -czf "$STAGING/home-configs.tar.gz" -C /home/sidhant \
  .bashrc .profile .ssh/config .gitconfig \
  opencode.json .config/opencode/opencode.json \
  .config/systemd/user \
  .config/homelab \
  2>/dev/null || true

docker volume ls --format '{{.Name}}' > "$STAGING/volumes.txt" 2>/dev/null || true

tar -czf "$ARCHIVE" -C "$STAGING" .
gpg_encrypt "$ARCHIVE"

FINAL="$ARCHIVE.gpg"
SIZE=$(du -sh "${FINAL%.gpg}" 2>/dev/null || du -sh "$FINAL" | cut -f1)
log "Backup complete: $FINAL ($SIZE)"

git -C /home/sidhant/homelab push github main 2>/dev/null && log "GitHub mirror updated" || log "GitHub push failed"

if [ -n "$DEST_PI" ]; then
  rsync -avz "$FINAL" "$DEST_PI" 2>/dev/null && log "Pi sync done" || log "Pi sync failed"
fi

if [ -n "$DEST_MAC" ]; then
  rsync -avz "$FINAL" "$DEST_MAC" 2>/dev/null && log "Mac sync done" || log "Mac sync failed"
fi

rm -rf "$STAGING"
log "Run complete"
