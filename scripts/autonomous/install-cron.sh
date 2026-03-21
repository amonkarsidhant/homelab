#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNNER="$ROOT_DIR/scripts/autonomous/overnight-agent-runner.sh"
CRON_TAG="# homelab-autonomous-agents"
CRON_FILE="$(mktemp)"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SYSTEMD_SERVICE="$SYSTEMD_USER_DIR/homelab-autonomous-agents.service"
SYSTEMD_TIMER="$SYSTEMD_USER_DIR/homelab-autonomous-agents.timer"

chmod +x "$RUNNER"
chmod +x "$ROOT_DIR/scripts/autonomous/agents/"*.sh

if command -v crontab >/dev/null 2>&1; then
  if crontab -l >/dev/null 2>&1; then
    crontab -l | grep -v "$CRON_TAG" > "$CRON_FILE"
  else
    : > "$CRON_FILE"
  fi

  {
    echo ""
    echo "$CRON_TAG"
    echo "*/20 22-23,0-6 * * * $RUNNER >> $HOME/logs/autonomous-agents/cron.log 2>&1 $CRON_TAG"
    echo "10 7 * * * $RUNNER >> $HOME/logs/autonomous-agents/cron.log 2>&1 $CRON_TAG"
  } >> "$CRON_FILE"

  crontab "$CRON_FILE"
  rm -f "$CRON_FILE"

  echo "Installed autonomous overnight schedules using cron"
  echo "- every 20 minutes from 22:00 to 06:59"
  echo "- daily morning run at 07:10"
  exit 0
fi

mkdir -p "$SYSTEMD_USER_DIR" "$HOME/logs/autonomous-agents"

cat > "$SYSTEMD_SERVICE" <<EOF
[Unit]
Description=Homelab autonomous overnight agent run

[Service]
Type=oneshot
ExecStart=$RUNNER
StandardOutput=append:$HOME/logs/autonomous-agents/cron.log
StandardError=append:$HOME/logs/autonomous-agents/cron.log
EOF

cat > "$SYSTEMD_TIMER" <<EOF
[Unit]
Description=Run homelab autonomous agents overnight

[Timer]
OnCalendar=*-*-* 22..23:00/20
OnCalendar=*-*-* 00..06:00/20
OnCalendar=*-*-* 07:10:00
Persistent=true
Unit=homelab-autonomous-agents.service

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now homelab-autonomous-agents.timer

echo "Installed autonomous overnight schedules using systemd user timer"
echo "- timer unit: homelab-autonomous-agents.timer"
echo "- service unit: homelab-autonomous-agents.service"
