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

LOKI_UID=$(printf '%s' "$DATASOURCES" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(next((d.get("uid","") for d in data if d.get("type")=="loki"),""))')
if [[ -z "$LOKI_UID" ]]; then
  LOKI_PAYLOAD='{"name":"Loki","type":"loki","url":"http://loki:3100","access":"proxy","isDefault":false}'
  docker exec -i grafana curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
    -H "Content-Type: application/json" \
    -X POST "$GRAFANA_URL/api/datasources" \
    -d "$LOKI_PAYLOAD" >/dev/null || true
  DATASOURCES=$(docker exec grafana curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" "$GRAFANA_URL/api/datasources")
  LOKI_UID=$(printf '%s' "$DATASOURCES" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(next((d.get("uid","") for d in data if d.get("type")=="loki"),""))')
fi

read -r -d '' DASHBOARD_JSON <<EOF || true
{
  "dashboard": {
    "id": null,
    "uid": "chaos-reporting",
    "title": "Chaos Reporting",
    "tags": ["chaos", "reporting", "homelab"],
    "timezone": "browser",
    "schemaVersion": 39,
    "version": 1,
    "refresh": "30s",
    "panels": [
      {
        "type": "stat",
        "title": "Overall Availability (7d %)",
        "gridPos": {"h": 5, "w": 6, "x": 0, "y": 0},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "avg(avg_over_time(up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"}[7d])) * 100", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "stat",
        "title": "State Transitions (7d)",
        "gridPos": {"h": 5, "w": 6, "x": 6, "y": 0},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "sum(changes(up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"}[7d]))", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "stat",
        "title": "Currently Down Services",
        "gridPos": {"h": 5, "w": 6, "x": 12, "y": 0},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "count(up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"} == 0)", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "stat",
        "title": "Experiments Started (24h)",
        "gridPos": {"h": 5, "w": 6, "x": 18, "y": 0},
        "datasource": {"type": "loki", "uid": "$LOKI_UID"},
        "targets": [{"expr": "sum(count_over_time({job=\"chaos-events\"} |= \"CHAOS_EVENT\" |= \"phase=start\" [24h]))", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "stat",
        "title": "Experiments Recovered (24h)",
        "gridPos": {"h": 5, "w": 6, "x": 0, "y": 5},
        "datasource": {"type": "loki", "uid": "$LOKI_UID"},
        "targets": [{"expr": "sum(count_over_time({job=\"chaos-events\"} |= \"CHAOS_EVENT\" |= \"phase=end\" [24h]))", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "stat",
        "title": "Experiment Failures (24h)",
        "gridPos": {"h": 5, "w": 6, "x": 6, "y": 5},
        "datasource": {"type": "loki", "uid": "$LOKI_UID"},
        "targets": [{"expr": "sum(count_over_time({job=\"chaos-events\"} |= \"CHAOS_EVENT\" |= \"status=failed\" [24h]))", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "stat",
        "title": "Avg Recovery Time (s, 7d)",
        "gridPos": {"h": 5, "w": 6, "x": 12, "y": 5},
        "datasource": {"type": "loki", "uid": "$LOKI_UID"},
        "targets": [{"expr": "avg_over_time(({job=\"chaos-events\"} |= \"CHAOS_EVENT\" |= \"phase=end\" | logfmt | unwrap elapsed_sec)[7d])", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "stat",
        "title": "Integrity BAD Lines (24h)",
        "gridPos": {"h": 5, "w": 6, "x": 18, "y": 5},
        "datasource": {"type": "loki", "uid": "$LOKI_UID"},
        "targets": [{"expr": "sum(count_over_time({job=\"container-logs\"} |= \"service-integrity-check\" |= \"BAD\" [24h]))", "refId": "A"}],
        "options": {"reduceOptions": {"calcs": ["lastNotNull"]}}
      },
      {
        "type": "timeseries",
        "title": "Service Availability Trend (1h rolling %) ",
        "gridPos": {"h": 10, "w": 12, "x": 0, "y": 10},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "avg_over_time(up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"}[1h]) * 100", "refId": "A"}]
      },
      {
        "type": "timeseries",
        "title": "Transitions by Service (24h)",
        "gridPos": {"h": 10, "w": 12, "x": 12, "y": 10},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "changes(up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"}[24h])", "refId": "A"}]
      },
      {
        "type": "table",
        "title": "Current Service Status",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 20},
        "datasource": {"type": "prometheus", "uid": "$PROM_UID"},
        "targets": [{"expr": "up{job=~\"traefik|gitea|grafana|prometheus|minio|loki|jaeger\"}", "refId": "A", "instant": true}],
        "transformations": [
          {"id": "labelsToFields", "options": {"valueLabel": "status"}}
        ]
      },
      {
        "type": "logs",
        "title": "Recent Chaos / Integrity Logs",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 20},
        "datasource": {"type": "loki", "uid": "$LOKI_UID"},
        "targets": [{"expr": "{job=\"chaos-events\"} |= \"CHAOS_EVENT\" or {job=\"container-logs\"} |= \"service-integrity-check\"", "refId": "A"}]
      },
      {
        "type": "alertlist",
        "title": "Current Alerts",
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 28},
        "options": {"show": "current", "sortOrder": 1}
      }
    ]
  },
  "overwrite": true,
  "folderUid": "",
  "message": "Install/update Chaos Reporting dashboard"
}
EOF

docker exec -i grafana curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -X POST "$GRAFANA_URL/api/dashboards/db" \
  -d @- >/dev/null <<< "$DASHBOARD_JSON"

echo "Grafana dashboard installed: Chaos Reporting"
