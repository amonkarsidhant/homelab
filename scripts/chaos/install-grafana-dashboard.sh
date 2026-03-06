#!/usr/bin/env bash
set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-}"

if [[ -z "$GRAFANA_PASSWORD" ]]; then
  GRAFANA_PASSWORD=$(grep '^GF_SECURITY_ADMIN_PASSWORD=' /home/sidhant/traefik/.env | cut -d= -f2-)
fi

if [[ -z "$GRAFANA_PASSWORD" ]]; then
  echo "Grafana password not found. Set GRAFANA_PASSWORD."
  exit 1
fi

DATASOURCES=$(docker exec grafana curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" "$GRAFANA_URL/api/datasources")
PROM_UID=$(printf '%s' "$DATASOURCES" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(next((d.get("uid","") for d in data if d.get("type")=="prometheus"),""))')

if [[ -z "$PROM_UID" ]]; then
  echo "Prometheus datasource UID not found in Grafana"
  exit 1
fi

read -r -d '' DASHBOARD_JSON <<EOF || true
{
  "dashboard": {
    "id": null,
    "uid": "chaos-center",
    "title": "Chaos Control Center",
    "tags": ["chaos", "homelab"],
    "timezone": "browser",
    "schemaVersion": 39,
    "version": 1,
    "refresh": "10s",
    "panels": [
      {
        "type": "stat",
        "title": "Healthy Services (up)",
        "gridPos": {"h": 6, "w": 8, "x": 0, "y": 0},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "sum(up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"})", "refId": "A"}]
      },
      {
        "type": "timeseries",
        "title": "Service Availability (up)",
        "gridPos": {"h": 10, "w": 16, "x": 8, "y": 0},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"}", "refId": "A"}]
      },
      {
        "type": "timeseries",
        "title": "Scrape Duration P95",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 6},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "histogram_quantile(0.95, sum by (le, job) (rate(prometheus_target_interval_length_seconds_bucket[5m])))", "refId": "A"}]
      },
      {
        "type": "timeseries",
        "title": "TSDB Head Chunks (Prometheus)",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 6},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "prometheus_tsdb_head_chunks", "refId": "A"}]
      },
      {
        "type": "alertlist",
        "title": "Current Alerts",
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 14},
        "options": {"show": "current", "sortOrder": 1}
      }
    ]
  },
  "overwrite": true,
  "folderUid": "",
  "message": "Install/update Chaos Control Center"
}
EOF

docker exec -i grafana curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -X POST "$GRAFANA_URL/api/dashboards/db" \
  -d @- >/dev/null <<< "$DASHBOARD_JSON"

echo "Grafana dashboard installed: Chaos Control Center"
