#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <title> <text>"
  exit 1
fi

TITLE="$1"
TEXT="$2"
GRAFANA_URL="${GRAFANA_URL:-http://127.0.0.1:3000}"
GRAFANA_USER="${GRAFANA_USER:-admin}"

PASS_FROM_ENV="${GRAFANA_PASSWORD:-}"
if [[ -z "$PASS_FROM_ENV" ]]; then
  PASS_FROM_ENV=$(grep '^GF_SECURITY_ADMIN_PASSWORD=' /home/sidhant/traefik/.env | cut -d= -f2-)
fi

if [[ -z "$PASS_FROM_ENV" ]]; then
  echo "Grafana password not found. Set GRAFANA_PASSWORD."
  exit 1
fi

PAYLOAD=$(cat <<EOF
{
  "time": $(date +%s%3N),
  "tags": ["chaos", "experiment"],
  "text": "${TITLE}: ${TEXT}"
}
EOF
)

curl -sS -u "$GRAFANA_USER:$PASS_FROM_ENV" \
  -H "Content-Type: application/json" \
  -X POST "$GRAFANA_URL/api/annotations" \
  -d "$PAYLOAD" >/dev/null

echo "Grafana annotation created: $TITLE"
