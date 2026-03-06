#!/usr/bin/env bash
set -euo pipefail

CHECK_SCRIPT="/home/sidhant/scripts/service-integrity-check.sh"
ENV_FILE="/home/sidhant/.config/homelab/monitor.env"
LOG_DIR="/home/sidhant/logs/integrity"

mkdir -p "$LOG_DIR"
TS=$(date -u +%Y%m%d-%H%M%S)
LOG_FILE="$LOG_DIR/integrity-$TS.log"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

set +e
"$CHECK_SCRIPT" >"$LOG_FILE" 2>&1
RESULT=$?
set -e

# Keep last 200 logs.
ls -1t "$LOG_DIR"/integrity-*.log 2>/dev/null | tail -n +201 | xargs -r rm -f

if [ "$RESULT" -eq 0 ]; then
  exit 0
fi

if [ -z "${DISCORD_WEBHOOK_URL:-}" ]; then
  exit "$RESULT"
fi

TAIL_OUTPUT=$(tail -n 40 "$LOG_FILE" | sed 's/"/\"/g')

curl -sS -X POST "$DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"embeds\": [{
      \"title\": \"Homelab Integrity Check Failed\",
      \"color\": 15158332,
      \"description\": \"One or more critical checks failed.\",
      \"fields\": [
        {\"name\": \"Host\", \"value\": \"$(hostname)\", \"inline\": true},
        {\"name\": \"Time (UTC)\", \"value\": \"$(date -u '+%Y-%m-%d %H:%M:%S')\", \"inline\": true},
        {\"name\": \"Log\", \"value\": \"$LOG_FILE\", \"inline\": false},
        {\"name\": \"Last Output\", \"value\": \"\`\`\`$TAIL_OUTPUT\`\`\`\", \"inline\": false}
      ]
    }]
  }" >/dev/null

exit "$RESULT"
