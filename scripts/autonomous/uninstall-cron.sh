#!/usr/bin/env bash
set -euo pipefail

CRON_TAG="# homelab-autonomous-agents"
CRON_FILE="$(mktemp)"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SYSTEMD_SERVICE="$SYSTEMD_USER_DIR/homelab-autonomous-agents.service"
SYSTEMD_TIMER="$SYSTEMD_USER_DIR/homelab-autonomous-agents.timer"

if command -v crontab >/dev/null 2>&1; then
  if crontab -l >/dev/null 2>&1; then
    crontab -l | grep -v "$CRON_TAG" > "$CRON_FILE"
    crontab "$CRON_FILE"
    rm -f "$CRON_FILE"
    echo "Removed autonomous agent cron entries"
    exit 0
  fi
fi

rm -f "$CRON_FILE"

if systemctl --user list-unit-files homelab-autonomous-agents.timer >/dev/null 2>&1; then
  systemctl --user disable --now homelab-autonomous-agents.timer >/dev/null 2>&1 || true
  rm -f "$SYSTEMD_TIMER" "$SYSTEMD_SERVICE"
  systemctl --user daemon-reload
  echo "Removed autonomous agent systemd user timer"
  exit 0
fi

echo "No autonomous schedule entries found"
