#!/usr/bin/env bash
set -euo pipefail

BACKUP_SCRIPT="/home/sidhant/homelab/scripts/backup/backup-runner.sh"
ENV_FILE="$HOME/.config/homelab/backup.env"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

if [ -f "$HOME/.config/homelab/backup.env" ]; then
  source "$HOME/.config/homelab/backup.env"
fi

if [ ! -x "$BACKUP_SCRIPT" ]; then
  echo "Missing executable: $BACKUP_SCRIPT"
  exit 2
fi

"$BACKUP_SCRIPT"
