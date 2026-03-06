#!/usr/bin/env bash
set -euo pipefail

SERVICE_PATH="/etc/systemd/system/homelab-weekly-chaos.service"
TIMER_PATH="/etc/systemd/system/homelab-weekly-chaos.timer"

cat > /tmp/homelab-weekly-chaos.service <<'EOF'
[Unit]
Description=Run weekly chaos drill and generate report
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
User=sidhant
Group=docker
WorkingDirectory=/home/sidhant/homelab
Environment=REPO_DIR=/home/sidhant/homelab
Environment=REPORT_DIR=/home/sidhant/homelab/docs/chaos-reports
ExecStart=/home/sidhant/scripts/chaos/weekly-chaos-drill.sh
EOF

cat > /tmp/homelab-weekly-chaos.timer <<'EOF'
[Unit]
Description=Weekly chaos drill (Sunday 03:30 UTC)

[Timer]
OnCalendar=Sun *-*-* 03:30:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo mv /tmp/homelab-weekly-chaos.service "$SERVICE_PATH"
sudo mv /tmp/homelab-weekly-chaos.timer "$TIMER_PATH"

sudo systemctl daemon-reload
sudo systemctl enable --now homelab-weekly-chaos.timer

echo "Installed weekly chaos timer: homelab-weekly-chaos.timer"
sudo systemctl list-timers homelab-weekly-chaos.timer --no-pager
